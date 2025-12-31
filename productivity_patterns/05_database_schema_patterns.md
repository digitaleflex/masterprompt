# Modèles de schéma de base de données

## Description
Ce document présente des modèles et des patrons de conception pour la conception de schémas de base de données robustes, évolutifs et performants, avec des exemples concrets pour différents types de systèmes.

## Principes fondamentaux

### 1. Normalisation et dénormalisation

#### Niveaux de normalisation
- **1NF (Première forme normale)** : Atomicité des valeurs
- **2NF (Deuxième forme normale)** : Dépendance fonctionnelle totale
- **3NF (Troisième forme normale)** : Absence de dépendance transitive
- **BCNF (Forme normale de Boyce-Codd)** : Extension de 3NF

```sql
-- Mauvais exemple - non normalisé
CREATE TABLE orders_non_normalized (
    order_id INT,
    customer_name VARCHAR(100),      -- Violation 1NF si plusieurs noms
    customer_email VARCHAR(100),     -- Violation 2NF
    product_name VARCHAR(100),       -- Violation 3NF
    product_price DECIMAL(10,2),
    quantity INT,
    order_date DATE
);

-- Bon exemple - normalisé
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(12,2) GENERATED ALWAYS AS (
        (SELECT SUM(od.quantity * p.price) 
         FROM order_details od 
         JOIN products p ON od.product_id = p.product_id 
         WHERE od.order_id = orders.order_id)
    ) STORED
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    UNIQUE(order_id, product_id)
);
```

#### Quand dénormaliser
- **Performance** : Requêtes complexes fréquentes
- **Reporting** : Tables de faits et dimensions
- **Cache** : Données souvent lues
- **Historique** : Données de référence stables

```sql
-- Table dénormalisée pour les rapports
CREATE TABLE sales_summary (
    sale_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(100),     -- Copié de customers
    customer_city VARCHAR(50),      -- Copié de customers
    product_name VARCHAR(100),      -- Copié de products
    product_category VARCHAR(50),   -- Copié de products
    sale_amount DECIMAL(12,2),
    sale_date DATE,
    INDEX idx_customer_city (customer_city),
    INDEX idx_sale_date (sale_date)
);

-- Vue matérialisée pour les données dénormalisées
CREATE MATERIALIZED VIEW customer_sales_summary AS
SELECT 
    c.customer_id,
    c.name,
    c.city,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city;

-- Actualiser la vue périodiquement
CREATE OR REPLACE FUNCTION refresh_customer_summary()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW customer_sales_summary;
END;
$$ LANGUAGE plpgsql;
```

### 2. Modèles de conception relationnelle

#### Modèle de type
Gérer des entités similaires avec des comportements différents.

```sql
-- Modèle de type pour les utilisateurs
CREATE TYPE user_type AS ENUM ('customer', 'admin', 'moderator', 'guest');

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    type user_type NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tables spécialisées par type
CREATE TABLE customer_profiles (
    user_id INT PRIMARY KEY REFERENCES users(user_id),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    shipping_address TEXT
);

CREATE TABLE admin_profiles (
    user_id INT PRIMARY KEY REFERENCES users(user_id),
    department VARCHAR(50),
    permissions JSONB
);

-- Contrainte pour s'assurer de la cohérence entre type et profil
CREATE OR REPLACE FUNCTION check_user_profile_consistency()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type = 'customer' AND NOT EXISTS (
        SELECT 1 FROM customer_profiles WHERE user_id = NEW.user_id
    ) THEN
        RAISE EXCEPTION 'Customer user must have a customer profile';
    ELSIF NEW.type = 'admin' AND NOT EXISTS (
        SELECT 1 FROM admin_profiles WHERE user_id = NEW.user_id
    ) THEN
        RAISE EXCEPTION 'Admin user must have an admin profile';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_user_profile
    AFTER INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION check_user_profile_consistency();
```

#### Modèle de jointure
Gérer les relations many-to-many avec des attributs.

```sql
-- Relations many-to-many avec attributs
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2)
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE
);

CREATE TABLE project_assignments (
    assignment_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES projects(project_id),
    employee_id INT REFERENCES employees(employee_id),
    role VARCHAR(50),                    -- Attribut de la relation
    hourly_rate DECIMAL(8,2),           -- Attribut de la relation
    assigned_hours INT DEFAULT 0,       -- Attribut de la relation
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, employee_id)     -- Empêche double assignation
);

-- Index pour les requêtes fréquentes
CREATE INDEX idx_assignments_by_project ON project_assignments(project_id);
CREATE INDEX idx_assignments_by_employee ON project_assignments(employee_id);
CREATE INDEX idx_assignments_by_date ON project_assignments(start_date, end_date);
```

## Modèles pour systèmes évolutifs

### 1. Modèle de partitionnement

#### Partitionnement horizontal (sharding)
```sql
-- Exemple de partitionnement par plage de dates
CREATE TABLE orders_partitioned (
    order_id BIGINT,
    customer_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12,2),
    status VARCHAR(20)
) PARTITION BY RANGE (order_date);

-- Création des partitions
CREATE TABLE orders_2023_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');

CREATE TABLE orders_2023_q2 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');

CREATE TABLE orders_2023_q3 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2023-07-01') TO ('2023-10-01');

CREATE TABLE orders_2023_q4 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2023-10-01') TO ('2024-01-01');

-- Trigger pour la gestion automatique des partitions
CREATE OR REPLACE FUNCTION create_order_partition()
RETURNS TRIGGER AS $$
DECLARE
    partition_date TEXT;
    partition_name TEXT;
BEGIN
    partition_date := to_char(NEW.order_date, 'YYYY_MM');
    partition_name := 'orders_' || partition_date;

    -- Vérifier si la partition existe
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = partition_name
    ) THEN
        -- Créer la partition si elle n'existe pas
        EXECUTE format('
            CREATE TABLE %I PARTITION OF orders_partitioned
            FOR VALUES FROM (%L) TO (%L)',
            partition_name,
            date_trunc('month', NEW.order_date)::date,
            (date_trunc('month', NEW.order_date) + INTERVAL '1 month')::date
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### Partitionnement par hachage
```sql
-- Partitionnement par hachage pour la distribution uniforme
CREATE TABLE user_data (
    user_id BIGINT,
    data_key VARCHAR(100) NOT NULL,
    data_value JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY HASH (user_id);

-- Création de 8 partitions
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 0..7 LOOP
        EXECUTE format('
            CREATE TABLE user_data_p%d PARTITION OF user_data
            FOR VALUES WITH (MODULUS 8, REMAINDER %d)',
            i, i
        );
    END LOOP;
END $$;
```

### 2. Modèle de versionnage

#### Versionnage de schéma
```sql
-- Table de versionnage des schémas
CREATE TABLE schema_versions (
    version_id SERIAL PRIMARY KEY,
    version_number VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    applied_by VARCHAR(100),
    checksum VARCHAR(64)  -- Vérification d'intégrité
);

-- Table de données avec historique
CREATE TABLE products_history (
    history_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    version_number INT NOT NULL,  -- Numéro de version
    operation_type VARCHAR(10) NOT NULL,  -- INSERT, UPDATE, DELETE
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation_user VARCHAR(100),
    -- Index pour les recherches historiques
    INDEX idx_product_version (product_id, version_number),
    INDEX idx_operation_time (operation_timestamp)
);

-- Vue pour les données actuelles
CREATE VIEW current_products AS
SELECT DISTINCT ON (product_id)
    product_id,
    name,
    price,
    category,
    status,
    version_number
FROM products_history
WHERE operation_type != 'DELETE'
ORDER BY product_id, version_number DESC;

-- Trigger pour le versionnage automatique
CREATE OR REPLACE FUNCTION track_product_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO products_history (
            product_id, name, price, category, status, 
            version_number, operation_type, operation_user
        ) VALUES (
            NEW.product_id, NEW.name, NEW.price, NEW.category, NEW.status,
            1, 'INSERT', current_user
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO products_history (
            product_id, name, price, category, status,
            version_number, operation_type, operation_user
        ) VALUES (
            NEW.product_id, NEW.name, NEW.price, NEW.category, NEW.status,
            (SELECT COALESCE(MAX(version_number), 0) + 1 
             FROM products_history WHERE product_id = NEW.product_id),
            'UPDATE', current_user
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO products_history (
            product_id, name, price, category, status,
            version_number, operation_type, operation_user
        ) VALUES (
            OLD.product_id, OLD.name, OLD.price, OLD.category, OLD.status,
            (SELECT COALESCE(MAX(version_number), 0) + 1 
             FROM products_history WHERE product_id = OLD.product_id),
            'DELETE', current_user
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_track_product_changes
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION track_product_changes();
```

## Modèles pour systèmes de données complexes

### 1. Modèle de données hiérarchiques

#### Modèle Adjacency List
```sql
-- Structure hiérarchique simple
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT REFERENCES categories(category_id),
    depth INT GENERATED ALWAYS AS (
        CASE 
            WHEN parent_id IS NULL THEN 0
            ELSE (SELECT depth + 1 FROM categories WHERE category_id = categories.parent_id)
        END
    ) STORED,
    path TEXT,  -- Chemin complet pour les requêtes rapides
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les requêtes hiérarchiques
CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_path ON categories USING gin(path gin_trgm_ops);

-- Fonction pour construire le chemin
CREATE OR REPLACE FUNCTION build_category_path(cat_id INT)
RETURNS TEXT AS $$
DECLARE
    result_path TEXT := '';
    current_id INT := cat_id;
    cat_name VARCHAR(100);
BEGIN
    LOOP
        SELECT name, parent_id INTO cat_name, current_id
        FROM categories WHERE category_id = current_id;
        
        IF cat_name IS NULL THEN
            EXIT;
        END IF;
        
        result_path := cat_name || '/' || result_path;
        
        IF current_id IS NULL THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN '/' || LEFT(result_path, LENGTH(result_path) - 1);
END;
$$ LANGUAGE plpgsql;
```

#### Modèle Nested Set
```sql
-- Modèle Nested Set pour les requêtes hiérarchiques rapides
CREATE TABLE categories_nested (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    left_bound INT NOT NULL,    -- Bordure gauche
    right_bound INT NOT NULL,   -- Bordure droite
    depth INT NOT NULL,         -- Profondeur dans l'arbre
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (left_bound < right_bound)
);

-- Index pour les requêtes hiérarchiques
CREATE INDEX idx_categories_bounds ON categories_nested(left_bound, right_bound);
CREATE INDEX idx_categories_depth ON categories_nested(depth);

-- Vue pour les enfants directs
CREATE VIEW category_children AS
SELECT 
    p.category_id as parent_id,
    p.name as parent_name,
    c.category_id as child_id,
    c.name as child_name,
    c.depth as child_depth
FROM categories_nested p
JOIN categories_nested c 
    ON c.left_bound > p.left_bound 
    AND c.right_bound < p.right_bound 
    AND c.depth = p.depth + 1;

-- Fonction pour insérer un enfant
CREATE OR REPLACE FUNCTION insert_category_child(
    parent_id INT,
    new_name VARCHAR(100)
)
RETURNS INT AS $$
DECLARE
    parent_right INT;
    new_id INT;
BEGIN
    -- Obtenir la bordure droite du parent
    SELECT right_bound INTO parent_right
    FROM categories_nested WHERE category_id = parent_id;
    
    -- Décaler toutes les bordures à droite de 2 positions
    UPDATE categories_nested 
    SET left_bound = left_bound + 2 
    WHERE left_bound > parent_right - 1;
    
    UPDATE categories_nested 
    SET right_bound = right_bound + 2 
    WHERE right_bound >= parent_right;
    
    -- Insérer la nouvelle catégorie
    INSERT INTO categories_nested (name, left_bound, right_bound, depth)
    VALUES (new_name, parent_right, parent_right + 1, 
            (SELECT depth + 1 FROM categories_nested WHERE category_id = parent_id))
    RETURNING category_id INTO new_id;
    
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
```

### 2. Modèle de données polymorphiques

#### Modèle EAV (Entity-Attribute-Value)
```sql
-- Modèle EAV pour les données semi-structurées
CREATE TABLE entities (
    entity_id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,  -- 'user', 'product', 'order'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attributes (
    attribute_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    data_type VARCHAR(20) NOT NULL,  -- 'string', 'number', 'date', 'boolean'
    entity_type VARCHAR(50) NOT NULL, -- Type d'entité concerné
    is_required BOOLEAN DEFAULT FALSE,
    UNIQUE(name, entity_type)
);

CREATE TABLE entity_attribute_values (
    eav_id SERIAL PRIMARY KEY,
    entity_id INT REFERENCES entities(entity_id),
    attribute_id INT REFERENCES attributes(attribute_id),
    string_value TEXT,
    number_value NUMERIC,
    date_value DATE,
    boolean_value BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(entity_id, attribute_id),
    -- Contrainte pour s'assurer que seule la bonne colonne de valeur est remplie
    CONSTRAINT check_value_type CHECK (
        (SELECT data_type FROM attributes WHERE attribute_id = attributes.attribute_id) = 'string' AND string_value IS NOT NULL
        OR (SELECT data_type FROM attributes WHERE attribute_id = attributes.attribute_id) = 'number' AND number_value IS NOT NULL
        OR (SELECT data_type FROM attributes WHERE attribute_id = attributes.attribute_id) = 'date' AND date_value IS NOT NULL
        OR (SELECT data_type FROM attributes WHERE attribute_id = attributes.attribute_id) = 'boolean' AND boolean_value IS NOT NULL
    )
);

-- Vue pour les données typées
CREATE VIEW typed_entity_data AS
SELECT 
    e.entity_id,
    e.entity_type,
    a.name as attribute_name,
    a.data_type,
    CASE 
        WHEN a.data_type = 'string' THEN string_value
        WHEN a.data_type = 'number' THEN number_value::TEXT
        WHEN a.data_type = 'date' THEN date_value::TEXT
        WHEN a.data_type = 'boolean' THEN boolean_value::TEXT
    END as value,
    ev.created_at
FROM entities e
JOIN entity_attribute_values ev ON e.entity_id = ev.entity_id
JOIN attributes a ON ev.attribute_id = a.attribute_id;
```

#### Modèle avec JSONB (PostgreSQL)
```sql
-- Utilisation de JSONB pour les données flexibles
CREATE TABLE flexible_entities (
    entity_id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    name VARCHAR(100),
    metadata JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les recherches JSON
CREATE INDEX idx_metadata_gin ON flexible_entities USING gin(metadata);
CREATE INDEX idx_metadata_partial ON flexible_entities 
    USING gin((metadata->'category')) 
    WHERE entity_type = 'product';

-- Exemples de requêtes avec JSON
-- Trouver tous les produits électroniques
SELECT * FROM flexible_entities 
WHERE entity_type = 'product' 
AND metadata->>'category' = 'electronics';

-- Trouver les produits avec une garantie > 1 an
SELECT * FROM flexible_entities 
WHERE entity_type = 'product' 
AND (metadata->>'warranty_months')::INTEGER > 12;

-- Agréger des données JSON
SELECT 
    metadata->>'brand' as brand,
    COUNT(*) as product_count,
    AVG((metadata->>'price')::NUMERIC) as avg_price
FROM flexible_entities 
WHERE entity_type = 'product'
GROUP BY metadata->>'brand';
```

## Modèles de performance

### 1. Indexation stratégique

#### Modèles d'index avancés
```sql
-- Index fonctionnel pour les requêtes fréquentes
CREATE INDEX idx_users_lower_email ON users (LOWER(email));
CREATE INDEX idx_products_price_range ON products (price) WHERE price BETWEEN 10 AND 1000;
CREATE INDEX idx_orders_created_week ON orders (created_at) WHERE EXTRACT(dow FROM created_at) = 1; -- Lundi

-- Index de couverture pour les requêtes spécifiques
CREATE INDEX idx_user_orders_covering ON orders (customer_id, status, total_amount) 
WHERE status IN ('completed', 'shipped');

-- Index BRIN pour les grandes tables
CREATE INDEX idx_large_table_brin ON large_events USING brin (event_timestamp);

-- Index partiel pour les données actives
CREATE INDEX idx_active_users ON users (last_login) 
WHERE status = 'active' AND last_login > NOW() - INTERVAL '30 days';

-- Index inversé pour les UUID
CREATE INDEX idx_entities_uuid_reverse ON entities (reverse(uuid::text));
```

### 2. Modèles de caching de base de données

#### Modèle de cache matérialisé
```sql
-- Table de cache pour les données fréquemment consultées
CREATE TABLE materialized_cache (
    cache_key VARCHAR(255) PRIMARY KEY,
    cache_value JSONB NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hit_count INT DEFAULT 0
);

-- Fonction pour récupérer avec cache
CREATE OR REPLACE FUNCTION get_cached_data(
    cache_key VARCHAR,
    fetch_query TEXT,
    cache_duration INTERVAL DEFAULT '5 minutes'
)
RETURNS JSONB AS $$
DECLARE
    cached_result JSONB;
    fresh_result JSONB;
BEGIN
    -- Vérifier si le cache existe et n'est pas expiré
    SELECT cache_value INTO cached_result
    FROM materialized_cache
    WHERE cache_key = get_cached_data.cache_key
    AND expires_at > NOW();

    IF cached_result IS NOT NULL THEN
        -- Mettre à jour le compteur de hits
        UPDATE materialized_cache 
        SET hit_count = hit_count + 1
        WHERE cache_key = get_cached_data.cache_key;
        
        RETURN cached_result;
    END IF;

    -- Sinon, exécuter la requête originale
    EXECUTE fetch_query INTO fresh_result;

    -- Stocker le résultat dans le cache
    INSERT INTO materialized_cache (cache_key, cache_value, expires_at)
    VALUES (get_cached_data.cache_key, fresh_result, NOW() + cache_duration)
    ON CONFLICT (cache_key) 
    DO UPDATE SET 
        cache_value = EXCLUDED.cache_value,
        expires_at = EXCLUDED.expires_at,
        hit_count = 0;

    RETURN fresh_result;
END;
$$ LANGUAGE plpgsql;

-- Vue matérialisée pour les rapports fréquents
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    DATE_TRUNC('day', order_date) as day,
    COUNT(*) as total_orders,
    SUM(total_amount) as daily_revenue,
    AVG(total_amount) as avg_order_value,
    COUNT(DISTINCT customer_id) as unique_customers
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', order_date);

-- Index sur la vue matérialisée
CREATE INDEX idx_daily_sales_day ON daily_sales_summary(day);

-- Procédure pour rafraîchir le cache
CREATE OR REPLACE PROCEDURE refresh_cache()
LANGUAGE plpgsql AS $$
BEGIN
    -- Rafraîchir les vues matérialisées
    REFRESH MATERIALIZED VIEW daily_sales_summary;
    
    -- Supprimer les entrées de cache expirées
    DELETE FROM materialized_cache WHERE expires_at < NOW();
    
    -- Supprimer les entrées rarement utilisées
    DELETE FROM materialized_cache 
    WHERE hit_count < 5 AND created_at < NOW() - INTERVAL '1 hour';
END;
$$;
```

## Modèles de sécurité

### 1. Modèle de sécurité des données

#### Rôles et permissions
```sql
-- Création de rôles pour la sécurité
CREATE ROLE app_read_only;
CREATE ROLE app_read_write;
CREATE ROLE app_admin;

-- Permissions pour les rôles
GRANT USAGE ON SCHEMA public TO app_read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read_only;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_read_only;

GRANT app_read_only TO app_read_write;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_read_write;

GRANT app_read_write TO app_admin;
GRANT CREATE ON SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;

-- Utilisateurs spécifiques
CREATE USER app_backend WITH PASSWORD 'secure_password';
GRANT app_read_write TO app_backend;

CREATE USER app_reporting WITH PASSWORD 'secure_password';
GRANT app_read_only TO app_reporting;
```

#### Chiffrement des données sensibles
```sql
-- Table avec données chiffrées
CREATE TABLE sensitive_data (
    record_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    encrypted_pii BYTEA NOT NULL,  -- Données PII chiffrées
    encrypted_financial_data BYTEA NOT NULL,  -- Données financières chiffrées
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Fonctions pour le chiffrement/déchiffrement
CREATE OR REPLACE FUNCTION encrypt_sensitive(text, text)
RETURNS bytea AS $$
    SELECT pgp_sym_encrypt($1, $2)::bytea;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION decrypt_sensitive(bytea, text)
RETURNS text AS $$
    SELECT pgp_sym_decrypt($1::bytea, $2);
$$ LANGUAGE sql;

-- Vue sécurisée pour accéder aux données
CREATE VIEW secure_user_data AS
SELECT 
    record_id,
    user_id,
    -- Données non sensibles visibles
    created_at
FROM sensitive_data;

-- Procédure sécurisée pour accéder aux données chiffrées
CREATE OR REPLACE FUNCTION get_decrypted_data(
    p_record_id INT,
    p_decryption_key TEXT
)
RETURNS TABLE(
    user_id INT,
    pii_data TEXT,
    financial_data TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sd.user_id,
        decrypt_sensitive(sd.encrypted_pii, p_decryption_key),
        decrypt_sensitive(sd.encrypted_financial_data, p_decryption_key)
    FROM sensitive_data sd
    WHERE sd.record_id = p_record_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

Ces modèles de schéma de base de données fournissent des fondations solides pour créer des systèmes de données robustes, évolutifs et sécurisés, en couvrant les aspects de normalisation, de performance, de sécurité et de gestion des données complexes.