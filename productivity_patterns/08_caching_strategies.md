# Stratégies de mise en cache

## Description
Ce document présente des modèles et des stratégies de mise en cache pour améliorer les performances des applications, avec des exemples concrets pour différents types de systèmes et environnements.

## Concepts fondamentaux

### 1. Types de cache

#### Cache applicatif
- **Client-side cache** : Dans le navigateur ou l'application
- **Server-side cache** : Sur le serveur applicatif
- **Infrastructure cache** : Reverse proxy, CDN, load balancer

#### Niveaux de cache
- **L1 Cache** : Cache CPU/Registres (très rapide)
- **L2 Cache** : Cache applicatif (rapide)
- **L3 Cache** : Cache distribué (moyen)
- **External Cache** : CDN, services externes (plus lent mais étendu)

### 2. Politiques de cache

#### Cache-Aside (Lazy Loading)
```javascript
class CacheAsidePattern {
  constructor(cacheProvider, dataProvider) {
    this.cache = cacheProvider;
    this.dataProvider = dataProvider;
  }

  async getData(key) {
    // 1. Vérifier dans le cache
    let data = await this.cache.get(key);
    
    if (data === null) {
      // 2. Si pas dans le cache, aller à la source
      data = await this.dataProvider.fetch(key);
      
      // 3. Mettre à jour le cache
      if (data) {
        await this.cache.set(key, data, { ttl: 300 }); // 5 minutes
      }
    }
    
    return data;
  }

  async updateData(key, value) {
    // 1. Mettre à jour la source
    await this.dataProvider.update(key, value);
    
    // 2. Mettre à jour le cache
    await this.cache.set(key, value, { ttl: 300 });
  }

  async deleteData(key) {
    // 1. Supprimer de la source
    await this.dataProvider.delete(key);
    
    // 2. Supprimer du cache
    await this.cache.delete(key);
  }
}

// Utilisation
const cacheProvider = new RedisCache({
  host: 'localhost',
  port: 6379
});

const dataProvider = new DatabaseProvider({
  connectionString: process.env.DATABASE_URL
});

const cacheManager = new CacheAsidePattern(cacheProvider, dataProvider);

// Récupération de données avec cache
const userData = await cacheManager.getData(`user:${userId}`);
```

#### Write-Through
```javascript
class WriteThroughCache {
  constructor(cacheProvider, dataProvider) {
    this.cache = cacheProvider;
    this.dataProvider = dataProvider;
  }

  async write(key, value, options = {}) {
    try {
      // 1. Écrire dans la base de données
      const result = await this.dataProvider.write(key, value);
      
      // 2. Écrire dans le cache de manière synchrone
      await this.cache.set(key, value, options);
      
      return result;
    } catch (error) {
      // En cas d'erreur, rollback éventuel
      await this.handleWriteError(key, value, error);
      throw error;
    }
  }

  async read(key) {
    // Toujours lire du cache (qui devrait être à jour)
    return await this.cache.get(key);
  }

  async handleWriteError(key, value, error) {
    // Logguer l'erreur
    console.error(`Erreur d'écriture dans le cache:`, error);
    
    // Éventuellement invalider le cache pour forcer la prochaine lecture
    await this.cache.delete(key);
  }
}
```

#### Write-Behind (Write-Back)
```javascript
class WriteBehindCache {
  constructor(cacheProvider, dataProvider, options = {}) {
    this.cache = cacheProvider;
    this.dataProvider = dataProvider;
    this.batchSize = options.batchSize || 10;
    this.flushInterval = options.flushInterval || 5000; // 5 secondes
    this.writeBuffer = new Map();
    this.flushTimer = null;
  }

  async write(key, value, options = {}) {
    // Écrire immédiatement dans le cache
    await this.cache.set(key, value, options);
    
    // Mettre en tampon pour écriture différée
    this.writeBuffer.set(key, {
      value,
      options,
      timestamp: Date.now(),
      attempts: 0
    });

    // Planifier le flush si nécessaire
    if (this.writeBuffer.size >= this.batchSize) {
      await this.flush();
    } else if (!this.flushTimer) {
      this.scheduleFlush();
    }
  }

  async flush() {
    if (this.writeBuffer.size === 0) return;

    const batch = new Map(this.writeBuffer);
    this.writeBuffer.clear();

    if (this.flushTimer) {
      clearTimeout(this.flushTimer);
      this.flushTimer = null;
    }

    try {
      // Écriture par lots dans la base de données
      const promises = Array.from(batch.entries()).map(async ([key, item]) => {
        try {
          await this.dataProvider.write(key, item.value, item.options);
          return { success: true, key };
        } catch (error) {
          return { success: false, key, error, attempts: item.attempts + 1 };
        }
      });

      const results = await Promise.all(promises);

      // Gérer les échecs
      const failedWrites = results.filter(r => !r.success);
      
      for (const failed of failedWrites) {
        if (failed.attempts < 3) { // Max 3 tentatives
          // Remettre dans le tampon
          const originalItem = batch.get(failed.key);
          this.writeBuffer.set(failed.key, {
            ...originalItem,
            attempts: failed.attempts
          });
        } else {
          // Logguer l'échec définitif
          console.error(`Échec définitif de l'écriture pour: ${failed.key}`, failed.error);
        }
      }

      // Réplanifier le flush si des écritures sont restées
      if (this.writeBuffer.size > 0 && !this.flushTimer) {
        this.scheduleFlush();
      }
    } catch (error) {
      console.error('Erreur lors du flush différé:', error);
      // Remettre tous les éléments dans le tampon
      for (const [key, item] of batch.entries()) {
        if (!this.writeBuffer.has(key)) {
          this.writeBuffer.set(key, item);
        }
      }
      // Réessayer plus tard
      this.scheduleFlush();
    }
  }

  scheduleFlush() {
    this.flushTimer = setTimeout(() => {
      this.flush().catch(console.error);
    }, this.flushInterval);
  }

  async read(key) {
    return await this.cache.get(key);
  }

  // Nettoyer les ressources
  destroy() {
    if (this.flushTimer) {
      clearTimeout(this.flushTimer);
    }
    this.flush(); // Forcer le flush final
  }
}
```

## Modèles de cache distribué

### 1. Cache Redis avec clustering

#### Configuration avancée
```javascript
const Redis = require('ioredis');

class DistributedCache {
  constructor(options = {}) {
    this.options = {
      nodes: options.nodes || [{ host: 'localhost', port: 6379 }],
      redisOptions: {
        connectTimeout: 30000,
        lazyConnect: true,
        maxRetriesPerRequest: 3,
        enableReadyCheck: true,
        ...options.redisOptions
      },
      ...options
    };

    this.cluster = new Redis.Cluster(
      this.options.nodes,
      this.options.redisOptions
    );

    this.setupEventHandlers();
  }

  setupEventHandlers() {
    this.cluster.on('connect', () => {
      console.log('Connecté au cluster Redis');
    });

    this.cluster.on('error', (error) => {
      console.error('Erreur Redis:', error);
    });

    this.cluster.on('close', () => {
      console.log('Connexion Redis fermée');
    });
  }

  async get(key) {
    try {
      const result = await this.cluster.get(key);
      return result ? JSON.parse(result) : null;
    } catch (error) {
      console.error(`Erreur de lecture du cache pour ${key}:`, error);
      return null;
    }
  }

  async set(key, value, options = {}) {
    try {
      const serializedValue = JSON.stringify(value);
      
      if (options.ttl) {
        await this.cluster.setex(key, options.ttl, serializedValue);
      } else {
        await this.cluster.set(key, serializedValue);
      }
      
      return true;
    } catch (error) {
      console.error(`Erreur d'écriture dans le cache pour ${key}:`, error);
      return false;
    }
  }

  async mget(keys) {
    try {
      const results = await this.cluster.mget(keys);
      return results.map(result => result ? JSON.parse(result) : null);
    } catch (error) {
      console.error('Erreur de lecture multiple du cache:', error);
      return Array(keys.length).fill(null);
    }
  }

  async mset(pairs) {
    try {
      const flatPairs = pairs.flatMap(([key, value]) => [
        key, 
        JSON.stringify(value)
      ]);
      
      await this.cluster.mset(...flatPairs);
      return true;
    } catch (error) {
      console.error('Erreur d\'écriture multiple dans le cache:', error);
      return false;
    }
  }

  async delete(keys) {
    try {
      if (Array.isArray(keys)) {
        await this.cluster.del(...keys);
      } else {
        await this.cluster.del(keys);
      }
      return true;
    } catch (error) {
      console.error('Erreur de suppression du cache:', error);
      return false;
    }
  }

  // Cache avec invalidation automatique
  async getWithAutoInvalidate(key, fetchFunction, ttl = 300) {
    let cached = await this.get(key);
    
    if (!cached) {
      cached = await fetchFunction();
      await this.set(key, cached, { ttl });
    }
    
    // Planifier l'invalidation automatique
    setTimeout(async () => {
      await this.delete(key);
    }, ttl * 1000);
    
    return cached;
  }

  // Cache avec versionnage
  async getVersioned(key, version) {
    return await this.get(`${key}:v${version}`);
  }

  async setVersioned(key, value, version, options = {}) {
    return await this.set(`${key}:v${version}`, value, options);
  }

  async invalidateByVersionPrefix(prefix) {
    // Trouver toutes les clés avec le préfixe
    const keys = await this.cluster.keys(`${prefix}:v*`);
    if (keys.length > 0) {
      await this.cluster.del(...keys);
    }
  }
}

// Utilisation
const distributedCache = new DistributedCache({
  nodes: [
    { host: 'redis-node-1', port: 6379 },
    { host: 'redis-node-2', port: 6379 },
    { host: 'redis-node-3', port: 6379 }
  ]
});
```

### 2. Cache de session distribué

#### Gestion des sessions avec cache
```javascript
class SessionManager {
  constructor(cacheProvider, options = {}) {
    this.cache = cacheProvider;
    this.sessionPrefix = options.sessionPrefix || 'session:';
    this.defaultTTL = options.defaultTTL || 3600; // 1 heure
    this.refreshThreshold = options.refreshThreshold || 300; // 5 minutes
  }

  async createSession(userId, data = {}) {
    const sessionId = this.generateSessionId();
    const sessionData = {
      ...data,
      userId,
      createdAt: new Date().toISOString(),
      lastAccessed: new Date().toISOString(),
      sessionId
    };

    await this.cache.set(
      `${this.sessionPrefix}${sessionId}`,
      sessionData,
      { ttl: this.defaultTTL }
    );

    return sessionId;
  }

  async getSession(sessionId) {
    if (!sessionId) return null;

    const key = `${this.sessionPrefix}${sessionId}`;
    let session = await this.cache.get(key);

    if (session) {
      // Rafraîchir la session si nécessaire
      const lastAccess = new Date(session.lastAccessed);
      const timeSinceAccess = (Date.now() - lastAccess.getTime()) / 1000;
      
      if (timeSinceAccess > this.refreshThreshold) {
        session.lastAccessed = new Date().toISOString();
        await this.cache.set(key, session, { ttl: this.defaultTTL });
      }
    }

    return session;
  }

  async updateSession(sessionId, updates) {
    if (!sessionId) return false;

    const session = await this.getSession(sessionId);
    if (!session) return false;

    const updatedSession = { ...session, ...updates, lastAccessed: new Date().toISOString() };
    
    await this.cache.set(
      `${this.sessionPrefix}${sessionId}`,
      updatedSession,
      { ttl: this.defaultTTL }
    );

    return true;
  }

  async invalidateSession(sessionId) {
    if (!sessionId) return false;
    return await this.cache.delete(`${this.sessionPrefix}${sessionId}`);
  }

  async invalidateUserSessions(userId) {
    // Trouver toutes les sessions de l'utilisateur (nécessite un scan ou une structure spécifique)
    // Cette implémentation dépend de la structure de votre cache
    const sessionKeys = await this.cache.keys(`${this.sessionPrefix}*`);
    const userSessionKeys = sessionKeys.filter(key => {
      const session = this.cache.get(key);
      return session && session.userId === userId;
    });
    
    if (userSessionKeys.length > 0) {
      await this.cache.delete(userSessionKeys);
    }
  }

  generateSessionId() {
    return `sess_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}

// Middleware Express pour la gestion des sessions
const sessionMiddleware = (sessionManager) => {
  return async (req, res, next) => {
    const sessionId = req.cookies?.sessionId || req.headers['x-session-id'];
    
    if (sessionId) {
      req.session = await sessionManager.getSession(sessionId);
    }
    
    // Méthodes utilitaires
    req.sessionManager = {
      create: (userId, data) => sessionManager.createSession(userId, data),
      update: (updates) => {
        if (req.session) {
          return sessionManager.updateSession(req.session.sessionId, updates);
        }
        return Promise.resolve(false);
      },
      destroy: () => {
        if (req.session) {
          return sessionManager.invalidateSession(req.session.sessionId);
        }
        return Promise.resolve(false);
      }
    };
    
    next();
  };
};
```

## Modèles de cache pour les API

### 1. Cache de réponse HTTP

#### Cache avec ETags et validation conditionnelle
```javascript
const crypto = require('crypto');

class HTTPResponseCache {
  constructor(cacheProvider, options = {}) {
    this.cache = cacheProvider;
    this.etagPrefix = options.etagPrefix || 'etag:';
    this.responsePrefix = options.responsePrefix || 'response:';
    this.defaultTTL = options.defaultTTL || 300; // 5 minutes
    this.maxCacheSize = options.maxCacheSize || 1000; // Nombre maximum de réponses en cache
  }

  async handleRequest(req, res, next, handler) {
    // Générer une clé de cache basée sur l'URL et les paramètres
    const cacheKey = this.generateCacheKey(req);
    const etagKey = `${this.etagPrefix}${cacheKey}`;

    // Vérifier si le client a déjà la version
    const ifNoneMatch = req.headers['if-none-match'];
    if (ifNoneMatch) {
      const cachedETag = await this.cache.get(etagKey);
      if (cachedETag === ifNoneMatch) {
        res.status(304).end(); // Not Modified
        return;
      }
    }

    // Vérifier le cache
    const cachedResponse = await this.cache.get(`${this.responsePrefix}${cacheKey}`);
    
    if (cachedResponse) {
      // Envoyer la réponse mise en cache
      res.set(cachedResponse.headers);
      res.send(cachedResponse.body);
      return;
    }

    // Intercepter la réponse originale
    const originalSend = res.send;
    res.send = async (body) => {
      // Appeler la fonction originale
      originalSend.call(res, body);

      // Calculer l'ETag
      const etag = this.generateETag(body);
      
      // Stocker dans le cache
      await this.cache.set(`${this.responsePrefix}${cacheKey}`, {
        body,
        headers: res.getHeaders(),
        timestamp: Date.now()
      }, { ttl: this.defaultTTL });

      await this.cache.set(etagKey, etag, { ttl: this.defaultTTL });
    };

    // Exécuter le gestionnaire original
    await handler(req, res, next);
  }

  generateCacheKey(req) {
    const url = req.originalUrl;
    const query = req.query ? Object.keys(req.query).sort().map(k => `${k}=${req.query[k]}`).join('&') : '';
    const method = req.method;
    
    const key = `${method}:${url}${query ? '?' + query : ''}`;
    return crypto.createHash('md5').update(key).digest('hex');
  }

  generateETag(content) {
    if (typeof content === 'string') {
      return `"${crypto.createHash('md5').update(content).digest('hex')}"`;
    } else if (typeof content === 'object') {
      return `"${crypto.createHash('md5').update(JSON.stringify(content)).digest('hex')}"`;
    }
    return `"${Date.now()}"`; // Fallback pour les types non pris en charge
  }

  // Invalidation du cache
  async invalidateByPattern(pattern) {
    const responseKeys = await this.cache.keys(`${this.responsePrefix}${pattern}`);
    const etagKeys = responseKeys.map(key => 
      key.replace(this.responsePrefix, this.etagPrefix)
    );
    
    await this.cache.delete([...responseKeys, ...etagKeys]);
  }

  async invalidateByPath(path) {
    // Invalider toutes les variantes d'une route
    return await this.invalidateByPattern(`${path}*`);
  }
}

// Utilisation dans une application Express
const httpResponseCache = new HTTPResponseCache(distributedCache);

app.get('/api/products', async (req, res, next) => {
  await httpResponseCache.handleRequest(req, res, next, async (req, res) => {
    const products = await productService.getAllProducts(req.query);
    res.json(products);
  });
});
```

### 2. Cache GraphQL

#### Cache de résolution GraphQL
```javascript
class GraphQLResolverCache {
  constructor(cacheProvider, options = {}) {
    this.cache = cacheProvider;
    this.cachePrefix = options.cachePrefix || 'gql:';
    this.defaultTTL = options.defaultTTL || 300; // 5 minutes
    this.resolverWhitelist = options.resolverWhitelist || null; // null = tous
    this.argumentBlacklist = options.argumentBlacklist || ['password', 'token', 'secret'];
  }

  createCachedResolvers(resolvers) {
    const cachedResolvers = {};

    for (const [typeName, typeResolvers] of Object.entries(resolvers)) {
      cachedResolvers[typeName] = {};

      for (const [fieldName, resolver] of Object.entries(typeResolvers)) {
        if (this.shouldCacheResolver(typeName, fieldName)) {
          cachedResolvers[typeName][fieldName] = this.wrapResolverWithCache(resolver, typeName, fieldName);
        } else {
          cachedResolvers[typeName][fieldName] = resolver;
        }
      }
    }

    return cachedResolvers;
  }

  shouldCacheResolver(typeName, fieldName) {
    if (this.resolverWhitelist) {
      return this.resolverWhitelist.includes(`${typeName}.${fieldName}`);
    }
    return true; // Cacher tous par défaut
  }

  wrapResolverWithCache(resolver, typeName, fieldName) {
    return async (parent, args, context, info) => {
      // Ne pas mettre en cache si explicitement désactivé
      if (args.noCache || context.noCache) {
        return await resolver(parent, args, context, info);
      }

      // Générer la clé de cache
      const cacheKey = this.generateCacheKey(typeName, fieldName, args, context);
      const cachedResult = await this.cache.get(cacheKey);

      if (cachedResult !== null) {
        return cachedResult;
      }

      // Exécuter le résolveur original
      const result = await resolver(parent, args, context, info);

      // Mettre en cache le résultat
      if (this.shouldCacheResult(result, args, context)) {
        const ttl = this.getTTLForResolver(typeName, fieldName, args);
        await this.cache.set(cacheKey, result, { ttl });
      }

      return result;
    };
  }

  generateCacheKey(typeName, fieldName, args, context) {
    // Nettoyer les arguments sensibles
    const sanitizedArgs = this.sanitizeArguments(args);
    
    const key = `${this.cachePrefix}${typeName}.${fieldName}:${JSON.stringify(sanitizedArgs)}`;
    return crypto.createHash('md5').update(key).digest('hex');
  }

  sanitizeArguments(args) {
    const sanitized = {};
    
    for (const [key, value] of Object.entries(args)) {
      if (!this.argumentBlacklist.includes(key.toLowerCase())) {
        sanitized[key] = value;
      }
    }
    
    return sanitized;
  }

  shouldCacheResult(result, args, context) {
    // Ne pas mettre en cache les résultats vides ou les erreurs
    if (result === null || result === undefined) {
      return false;
    }

    // Ne pas mettre en cache les mutations
    if (args.__mutation) {
      return false;
    }

    return true;
  }

  getTTLForResolver(typeName, fieldName, args) {
    // Politiques de TTL spécifiques
    if (typeName === 'User' && fieldName === 'profile') {
      return 3600; // 1 heure pour les profils
    }

    if (fieldName.includes('recent') || fieldName.includes('latest')) {
      return 60; // 1 minute pour les données récentes
    }

    return this.defaultTTL;
  }

  // Invalidation du cache
  async invalidateByType(typeName) {
    const keys = await this.cache.keys(`${this.cachePrefix}${typeName}.*`);
    await this.cache.delete(keys);
  }

  async invalidateByField(typeName, fieldName) {
    const keys = await this.cache.keys(`${this.cachePrefix}${typeName}.${fieldName}:*`);
    await this.cache.delete(keys);
  }

  async invalidateByArguments(typeName, fieldName, args) {
    const sanitizedArgs = this.sanitizeArguments(args);
    const pattern = `${this.cachePrefix}${typeName}.${fieldName}:${JSON.stringify(sanitizedArgs)}`;
    const keys = await this.cache.keys(pattern);
    await this.cache.delete(keys);
  }
}

// Utilisation avec Apollo Server
const gqlCache = new GraphQLResolverCache(distributedCache);

const server = new ApolloServer({
  typeDefs,
  resolvers: gqlCache.createCachedResolvers(originalResolvers),
  context: ({ req }) => ({
    // Ajouter des informations de contexte pour le cache
    userId: req.user?.id,
    cache: gqlCache
  })
});
```

## Modèles de cache pour les bases de données

### 1. Cache de requêtes

#### Cache intelligent de requêtes
```javascript
class QueryCache {
  constructor(cacheProvider, dbProvider, options = {}) {
    this.cache = cacheProvider;
    this.db = dbProvider;
    this.cachePrefix = options.cachePrefix || 'query:';
    this.defaultTTL = options.defaultTTL || 300; // 5 minutes
    this.queryWhitelist = options.queryWhitelist || null; // null = toutes
    this.tableDependencies = options.tableDependencies || new Map(); // table -> [cache keys]
  }

  async execute(query, params = [], options = {}) {
    // Vérifier si la requête est éligible au cache
    if (!this.shouldCacheQuery(query, options)) {
      return await this.db.query(query, params);
    }

    // Générer la clé de cache
    const cacheKey = this.generateCacheKey(query, params);
    const cachedResult = await this.cache.get(cacheKey);

    if (cachedResult !== null) {
      return cachedResult;
    }

    // Exécuter la requête
    const result = await this.db.query(query, params);

    // Stocker dans le cache
    const ttl = options.ttl || this.defaultTTL;
    await this.cache.set(cacheKey, result, { ttl });

    // Enregistrer la dépendance
    const tables = this.extractTablesFromQuery(query);
    for (const table of tables) {
      if (!this.tableDependencies.has(table)) {
        this.tableDependencies.set(table, []);
      }
      this.tableDependencies.get(table).push(cacheKey);
    }

    return result;
  }

  generateCacheKey(query, params) {
    // Normaliser la requête (enlever les espaces, majuscules, etc.)
    const normalizedQuery = query
      .toLowerCase()
      .replace(/\s+/g, ' ')
      .trim();
    
    const key = `${this.cachePrefix}${normalizedQuery}:${JSON.stringify(params)}`;
    return crypto.createHash('md5').update(key).digest('hex');
  }

  extractTablesFromQuery(query) {
    // Extraction simple des noms de tables (à améliorer selon les besoins)
    const tableMatches = query.match(/from\s+(\w+)|join\s+(\w+)/gi) || [];
    return tableMatches.map(match => {
      const parts = match.split(/\s+/);
      return parts[parts.length - 1].toLowerCase();
    }).filter(Boolean);
  }

  shouldCacheQuery(query, options) {
    // Ne pas cacher les requêtes de modification
    if (/(insert|update|delete|alter|drop|create)\s/i.test(query)) {
      return false;
    }

    // Vérifier la whitelist
    if (this.queryWhitelist) {
      const querySignature = this.getQuerySignature(query);
      return this.queryWhitelist.includes(querySignature);
    }

    return true;
  }

  getQuerySignature(query) {
    // Extraire la signature de la requête pour la whitelist
    return query.toLowerCase()
      .replace(/\s+/g, ' ')
      .replace(/\(.*?\)/g, '()')
      .trim();
  }

  // Invalidation du cache lors des modifications
  async invalidateForTable(tableName) {
    const cacheKeys = this.tableDependencies.get(tableName) || [];
    if (cacheKeys.length > 0) {
      await this.cache.delete(cacheKeys);
      // Supprimer les dépendances invalidées
      this.tableDependencies.set(tableName, []);
    }
  }

  async invalidateByQuery(query, params = []) {
    const cacheKey = this.generateCacheKey(query, params);
    await this.cache.delete(cacheKey);
  }

  // Méthode pour nettoyer les dépendances orphelines
  async cleanupOrphanedDependencies() {
    for (const [table, cacheKeys] of this.tableDependencies.entries()) {
      const existingKeys = [];
      
      for (const key of cacheKeys) {
        const exists = await this.cache.exists(key);
        if (exists) {
          existingKeys.push(key);
        }
      }
      
      this.tableDependencies.set(table, existingKeys);
    }
  }
}

// Wrapper pour les opérations de base de données
class CachedDatabase {
  constructor(dbProvider, cacheProvider) {
    this.db = dbProvider;
    this.queryCache = new QueryCache(cacheProvider, dbProvider);
  }

  async find(tableName, conditions = {}, options = {}) {
    const query = `SELECT * FROM ${tableName} WHERE ${this.buildConditions(conditions)}`;
    const params = Object.values(conditions);
    
    return await this.queryCache.execute(query, params, options);
  }

  async findOne(tableName, conditions = {}, options = {}) {
    const results = await this.find(tableName, conditions, { ...options, limit: 1 });
    return results[0] || null;
  }

  async findById(tableName, id, options = {}) {
    return await this.findOne(tableName, { id }, options);
  }

  async insert(tableName, data, options = {}) {
    const query = `INSERT INTO ${tableName} (${Object.keys(data).join(', ')}) VALUES (${Object.keys(data).map(() => '?').join(', ')})`;
    const params = Object.values(data);
    
    const result = await this.db.query(query, params);
    
    // Invalider le cache pour cette table
    await this.queryCache.invalidateForTable(tableName);
    
    return result;
  }

  async update(tableName, data, conditions, options = {}) {
    const setClause = Object.keys(data).map(key => `${key} = ?`).join(', ');
    const whereClause = this.buildConditions(conditions);
    const query = `UPDATE ${tableName} SET ${setClause} WHERE ${whereClause}`;
    
    const params = [...Object.values(data), ...Object.values(conditions)];
    
    const result = await this.db.query(query, params);
    
    // Invalider le cache pour cette table
    await this.queryCache.invalidateForTable(tableName);
    
    return result;
  }

  async delete(tableName, conditions, options = {}) {
    const query = `DELETE FROM ${tableName} WHERE ${this.buildConditions(conditions)}`;
    const params = Object.values(conditions);
    
    const result = await this.db.query(query, params);
    
    // Invalider le cache pour cette table
    await this.queryCache.invalidateForTable(tableName);
    
    return result;
  }

  buildConditions(conditions) {
    return Object.keys(conditions)
      .map(key => `${key} = ?`)
      .join(' AND ');
  }
}
```

### 2. Cache de résultats agrégés

#### Cache pour les rapports et analyses
```javascript
class AggregateCache {
  constructor(cacheProvider, dbProvider, options = {}) {
    this.cache = cacheProvider;
    this.db = dbProvider;
    this.cachePrefix = options.cachePrefix || 'agg:';
    this.refreshIntervals = options.refreshIntervals || {
      'hourly': 3600,    // 1 heure
      'daily': 86400,    // 24 heures  
      'weekly': 604800,  // 7 jours
      'monthly': 2592000 // 30 jours
    };
    this.precomputedQueries = options.precomputedQueries || new Map();
  }

  async getReport(reportName, params = {}, options = {}) {
    const cacheKey = this.generateReportKey(reportName, params);
    const cachedReport = await this.cache.get(cacheKey);

    if (cachedReport && !this.isStale(cachedReport, options)) {
      return cachedReport.data;
    }

    // Calculer le rapport
    const reportData = await this.computeReport(reportName, params);
    
    // Stocker dans le cache
    const cacheData = {
      data: reportData,
      timestamp: Date.now(),
      params
    };
    
    const ttl = this.getTTLForReport(reportName);
    await this.cache.set(cacheKey, cacheData, { ttl });

    return reportData;
  }

  async computeReport(reportName, params) {
    // Vérifier si le rapport est prédéfini
    if (this.precomputedQueries.has(reportName)) {
      const query = this.precomputedQueries.get(reportName);
      return await this.db.query(query, params);
    }

    // Sinon, utiliser une logique générique
    switch (reportName) {
      case 'sales_summary':
        return await this.computeSalesSummary(params);
      case 'user_activity':
        return await this.computeUserActivity(params);
      case 'performance_metrics':
        return await this.computePerformanceMetrics(params);
      default:
        throw new Error(`Rapport inconnu: ${reportName}`);
    }
  }

  async computeSalesSummary(params) {
    const { startDate, endDate, region } = params;
    
    const query = `
      SELECT 
        SUM(amount) as total_sales,
        COUNT(*) as transaction_count,
        AVG(amount) as average_sale,
        MAX(amount) as highest_sale,
        DATE(created_at) as date
      FROM sales 
      WHERE created_at BETWEEN ? AND ?
        ${region ? 'AND region = ?' : ''}
      GROUP BY DATE(created_at)
      ORDER BY date DESC
    `;
    
    const queryParams = region ? [startDate, endDate, region] : [startDate, endDate];
    return await this.db.query(query, queryParams);
  }

  async computeUserActivity(params) {
    const { startDate, endDate, userType } = params;
    
    const query = `
      SELECT 
        u.id,
        u.name,
        u.email,
        COUNT(l.id) as login_count,
        MAX(l.timestamp) as last_login,
        MIN(l.timestamp) as first_login_in_period
      FROM users u
      LEFT JOIN login_logs l ON u.id = l.user_id
      WHERE l.timestamp BETWEEN ? AND ?
        ${userType ? 'AND u.type = ?' : ''}
      GROUP BY u.id
      ORDER BY login_count DESC
    `;
    
    const queryParams = userType ? [startDate, endDate, userType] : [startDate, endDate];
    return await this.db.query(query, queryParams);
  }

  generateReportKey(reportName, params) {
    const key = `${this.cachePrefix}${reportName}:${JSON.stringify(params)}`;
    return crypto.createHash('md5').update(key).digest('hex');
  }

  isStale(cachedData, options) {
    const age = Date.now() - cachedData.timestamp;
    const maxAge = options.maxAge || this.getTTLForReport(options.reportName);
    
    return age > maxAge;
  }

  getTTLForReport(reportName) {
    // Déterminer le TTL basé sur la fréquence de mise à jour attendue
    if (reportName.includes('live') || reportName.includes('realtime')) {
      return this.refreshIntervals.hourly;
    } else if (reportName.includes('daily')) {
      return this.refreshIntervals.daily;
    } else if (reportName.includes('weekly')) {
      return this.refreshIntervals.weekly;
    } else if (reportName.includes('monthly')) {
      return this.refreshIntervals.monthly;
    }
    
    // Par défaut, utiliser daily
    return this.refreshIntervals.daily;
  }

  // Pré-calcul des rapports (à utiliser dans des tâches planifiées)
  async precomputeReports() {
    const reportsToPrecompute = [
      { name: 'daily_summary', params: { date: new Date().toISOString().split('T')[0] } },
      { name: 'weekly_summary', params: { week: this.getCurrentWeek() } },
      { name: 'monthly_summary', params: { month: this.getCurrentMonth() } }
    ];

    for (const report of reportsToPrecompute) {
      try {
        await this.getReport(report.name, report.params);
        console.log(`Rapport pré-calculé: ${report.name}`);
      } catch (error) {
        console.error(`Erreur de pré-calcul pour ${report.name}:`, error);
      }
    }
  }

  getCurrentWeek() {
    const now = new Date();
    const startOfYear = new Date(now.getFullYear(), 0, 1);
    const days = Math.floor((now - startOfYear) / (24 * 60 * 60 * 1000));
    return Math.ceil((days + startOfYear.getDay() + 1) / 7);
  }

  getCurrentMonth() {
    return new Date().toISOString().slice(0, 7); // YYYY-MM
  }

  // Invalidation conditionnelle
  async conditionalInvalidate(condition) {
    // Parcourir toutes les clés de cache et invalider celles qui correspondent à la condition
    const allKeys = await this.cache.keys(`${this.cachePrefix}*`);
    const keysToInvalidate = allKeys.filter(key => {
      // Appliquer la condition de suppression
      return condition(key);
    });
    
    if (keysToInvalidate.length > 0) {
      await this.cache.delete(keysToInvalidate);
    }
  }
}

// Service pour la planification des mises à jour de cache
class CacheRefreshScheduler {
  constructor(aggregateCache) {
    this.aggregateCache = aggregateCache;
    this.jobs = new Map();
  }

  schedule(reportName, interval, params = {}) {
    const jobId = `${reportName}_${Date.now()}`;
    
    const job = setInterval(async () => {
      try {
        await this.aggregateCache.getReport(reportName, params);
        console.log(`Rapport mis à jour: ${reportName}`);
      } catch (error) {
        console.error(`Erreur de mise à jour pour ${reportName}:`, error);
      }
    }, interval);

    this.jobs.set(jobId, job);
    
    return jobId;
  }

  unschedule(jobId) {
    const job = this.jobs.get(jobId);
    if (job) {
      clearInterval(job);
      this.jobs.delete(jobId);
    }
  }

  unscheduleAll() {
    for (const [jobId, job] of this.jobs) {
      clearInterval(job);
    }
    this.jobs.clear();
  }
}

// Utilisation
const aggregateCache = new AggregateCache(distributedCache, dbProvider);
const scheduler = new CacheRefreshScheduler(aggregateCache);

// Planifier la mise à jour des rapports
scheduler.schedule('daily_summary', 24 * 60 * 60 * 1000); // Toutes les 24h
scheduler.schedule('hourly_metrics', 60 * 60 * 1000);     // Toutes les heures
```

## Stratégies d'invalidation du cache

### 1. Invalidation basée sur les événements

#### Système d'événements pour l'invalidation
```javascript
class EventBasedCacheInvalidation {
  constructor(cacheProvider, eventBus) {
    this.cache = cacheProvider;
    this.eventBus = eventBus;
    this.invalidations = new Map(); // entityType -> [patterns]
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Écouter les événements de modification
    this.eventBus.subscribe('user.updated', (data) => {
      this.invalidateUserRelatedCache(data.userId);
    });

    this.eventBus.subscribe('user.deleted', (data) => {
      this.invalidateUserRelatedCache(data.userId);
    });

    this.eventBus.subscribe('product.updated', (data) => {
      this.invalidateProductRelatedCache(data.productId);
    });

    this.eventBus.subscribe('order.created', (data) => {
      this.invalidateOrderRelatedCache(data.orderId, data.userId);
    });

    this.eventBus.subscribe('inventory.changed', (data) => {
      this.invalidateInventoryRelatedCache(data.productId);
    });
  }

  async invalidateUserRelatedCache(userId) {
    const patterns = [
      `user:${userId}`,
      `user:${userId}:profile`,
      `user:${userId}:orders`,
      `user:${userId}:preferences`,
      `user:recent:*` // Tous les caches d'utilisateurs récents
    ];

    for (const pattern of patterns) {
      await this.invalidateByPattern(pattern);
    }
  }

  async invalidateProductRelatedCache(productId) {
    const patterns = [
      `product:${productId}`,
      `product:${productId}:details`,
      `product:${productId}:reviews`,
      `category:*:products`, // Tous les caches de catégories contenant ce produit
      `search:*:results` // Tous les résultats de recherche
    ];

    for (const pattern of patterns) {
      await this.invalidateByPattern(pattern);
    }
  }

  async invalidateByPattern(pattern) {
    // Cette méthode dépend de la capacité du cache à faire des recherches par motif
    // Pour Redis, on peut utiliser KEYS ou SCAN
    if (this.cache.type === 'redis') {
      const keys = await this.cache.keys(pattern);
      if (keys.length > 0) {
        await this.cache.delete(keys);
      }
    } else {
      // Pour d'autres systèmes, on pourrait maintenir un index inverse
      await this.invalidateByTracking(pattern);
    }
  }

  async invalidateByTracking(pattern) {
    // Maintenir une liste des clés de cache par motif
    // Cela nécessite un suivi actif lors de la création du cache
    const trackedKeys = this.trackedKeys.get(pattern) || new Set();
    
    for (const key of trackedKeys) {
      await this.cache.delete(key);
    }
    
    // Nettoyer les entrées orphelines
    this.trackedKeys.set(pattern, new Set());
  }

  // Méthode pour enregistrer une clé de cache avec ses motifs
  trackCacheKey(key, patterns) {
    for (const pattern of patterns) {
      if (!this.trackedKeys.has(pattern)) {
        this.trackedKeys.set(pattern, new Set());
      }
      this.trackedKeys.get(pattern).add(key);
    }
  }
}

// Système de tags pour le cache
class TaggedCache {
  constructor(cacheProvider) {
    this.cache = cacheProvider;
    this.tagIndex = new Map(); // tag -> Set<keys>
  }

  async set(key, value, options = {}) {
    const tags = options.tags || [];
    
    // Stocker la valeur
    await this.cache.set(key, value, options);
    
    // Enregistrer les tags
    for (const tag of tags) {
      if (!this.tagIndex.has(tag)) {
        this.tagIndex.set(tag, new Set());
      }
      this.tagIndex.get(tag).add(key);
    }
  }

  async invalidateByTag(tag) {
    const keys = this.tagIndex.get(tag);
    if (keys && keys.size > 0) {
      await this.cache.delete(Array.from(keys));
      this.tagIndex.set(tag, new Set()); // Réinitialiser l'index
    }
  }

  async invalidateByTags(tags) {
    const allKeys = new Set();
    
    for (const tag of tags) {
      const keys = this.tagIndex.get(tag);
      if (keys) {
        for (const key of keys) {
          allKeys.add(key);
        }
      }
    }
    
    if (allKeys.size > 0) {
      await this.cache.delete(Array.from(allKeys));
      
      // Réinitialiser les index concernés
      for (const tag of tags) {
        this.tagIndex.set(tag, new Set());
      }
    }
  }

  // Invalidation par combinaison de tags
  async invalidateByTagCombination(tagCombination) {
    // Ex: ['user:123', 'profile'] - invalider tout ce qui a ces deux tags
    const keySets = tagCombination.map(tag => this.tagIndex.get(tag) || new Set());
    
    // Intersection des ensembles de clés
    let resultKeys = keySets[0] || new Set();
    for (let i = 1; i < keySets.length; i++) {
      resultKeys = new Set(
        [...resultKeys].filter(key => keySets[i].has(key))
      );
    }
    
    if (resultKeys.size > 0) {
      await this.cache.delete(Array.from(resultKeys));
      
      // Réinitialiser les index concernés
      for (const tag of tagCombination) {
        const allTagKeys = this.tagIndex.get(tag);
        const keysToDelete = new Set([...resultKeys].filter(key => allTagKeys.has(key)));
        
        for (const key of keysToDelete) {
          allTagKeys.delete(key);
        }
      }
    }
  }
}

// Utilisation
const taggedCache = new TaggedCache(distributedCache);

// Stocker avec des tags
await taggedCache.set('user:123:profile', profileData, {
  ttl: 3600,
  tags: ['user:123', 'profile', 'public']
});

await taggedCache.set('user:123:orders', ordersData, {
  ttl: 1800,
  tags: ['user:123', 'orders', 'private']
});

// Invalidation
await taggedCache.invalidateByTag('user:123'); // Invalider tout pour l'utilisateur
await taggedCache.invalidateByTagCombination(['user:123', 'profile']); // Invalider que le profile
```

### 2. Modèle de cache avec expiration intelligente

#### Cache avec politiques d'expiration dynamiques
```javascript
class IntelligentCacheExpiration {
  constructor(cacheProvider, options = {}) {
    this.cache = cacheProvider;
    this.accessPatternAnalyzer = new AccessPatternAnalyzer();
    this.expirationStrategies = {
      'lru': this.lruExpiration.bind(this),
      'lfu': this.lfuExpiration.bind(this),
      'fifo': this.fifoExpiration.bind(this),
      'adaptive': this.adaptiveExpiration.bind(this)
    };
    this.defaultStrategy = options.defaultStrategy || 'adaptive';
    this.maxCacheSize = options.maxCacheSize || 1000;
  }

  async get(key) {
    const cached = await this.cache.get(key);
    
    if (cached) {
      // Mettre à jour les statistiques d'accès
      await this.accessPatternAnalyzer.recordAccess(key, cached.value);
      
      // Vérifier l'expiration intelligente
      if (await this.shouldExpire(key, cached)) {
        await this.cache.delete(key);
        return null;
      }
      
      return cached.value;
    }
    
    return null;
  }

  async set(key, value, options = {}) {
    const entry = {
      value,
      createdAt: Date.now(),
      accessCount: 1,
      lastAccessed: Date.now(),
      originalTTL: options.ttl || 300,
      adaptiveTTL: options.ttl || 300
    };
    
    await this.cache.set(key, entry, { ttl: entry.adaptiveTTL });
    
    // Vérifier la taille du cache
    await this.maintainCacheSize();
  }

  async shouldExpire(key, cached) {
    const now = Date.now();
    const age = now - cached.createdAt;
    
    // Vérifier l'expiration naturelle
    if (age > cached.adaptiveTTL * 1000) {
      return true;
    }
    
    // Vérifier les stratégies d'expiration intelligente
    const accessPattern = await this.accessPatternAnalyzer.getPattern(key);
    
    // Si l'élément n'est pas accédé fréquemment et est vieux
    if (accessPattern.frequency < 0.1 && age > 3600000) { // 1 heure
      return true;
    }
    
    // Si l'élément est de faible valeur (basé sur l'accès et l'âge)
    const valueScore = this.calculateValueScore(accessPattern, age);
    if (valueScore < 0.2) { // Seuil de valeur faible
      return true;
    }
    
    return false;
  }

  calculateValueScore(accessPattern, age) {
    // Calculer un score de valeur basé sur:
    // - Fréquence d'accès récente
    // - Récence des accès
    // - Importance relative
    
    const recencyFactor = Math.exp(-age / (24 * 60 * 60 * 1000)); // Décroissance sur 24h
    const frequencyFactor = accessPattern.frequency || 0;
    const burstFactor = accessPattern.burstiness || 0;
    
    return (frequencyFactor * 0.5) + (recencyFactor * 0.3) + (burstFactor * 0.2);
  }

  async maintainCacheSize() {
    const allKeys = await this.cache.keys('*');
    
    if (allKeys.length <= this.maxCacheSize) {
      return; // Taille correcte
    }
    
    // Déterminer les clés à supprimer en fonction de la stratégie
    const strategy = this.expirationStrategies[this.defaultStrategy];
    const keysToRemove = await strategy(allKeys, this.maxCacheSize);
    
    if (keysToRemove.length > 0) {
      await this.cache.delete(keysToRemove);
    }
  }

  async lruExpiration(keys, maxSize) {
    // Trier par dernier accès (Least Recently Used)
    const keyDetails = await Promise.all(
      keys.map(async key => {
        const entry = await this.cache.get(key);
        return { key, lastAccessed: entry?.lastAccessed || 0 };
      })
    );
    
    // Trier par date de dernier accès (les plus anciens en premier)
    keyDetails.sort((a, b) => a.lastAccessed - b.lastAccessed);
    
    // Retourner les clés excédentaires
    return keyDetails.slice(0, keys.length - maxSize).map(detail => detail.key);
  }

  async lfuExpiration(keys, maxSize) {
    // Trier par fréquence d'accès (Least Frequently Used)
    const keyDetails = await Promise.all(
      keys.map(async key => {
        const entry = await this.cache.get(key);
        return { 
          key, 
          accessCount: entry?.accessCount || 0,
          lastAccessed: entry?.lastAccessed || 0
        };
      })
    );
    
    // Trier par nombre d'accès (les moins accédés en premier)
    keyDetails.sort((a, b) => {
      if (a.accessCount !== b.accessCount) {
        return a.accessCount - b.accessCount;
      }
      // En cas d'égalité, utiliser la date de dernier accès
      return a.lastAccessed - b.lastAccessed;
    });
    
    return keyDetails.slice(0, keys.length - maxSize).map(detail => detail.key);
  }

  async adaptiveExpiration(keys, maxSize) {
    // Combinaison pondérée de LRU et LFU avec facteurs de récence
    const keyDetails = await Promise.all(
      keys.map(async key => {
        const entry = await this.cache.get(key);
        const accessPattern = await this.accessPatternAnalyzer.getPattern(key);
        
        // Calculer un score combiné
        const age = Date.now() - entry.createdAt;
        const recencyScore = 1 / (1 + age / (24 * 60 * 60 * 1000)); // Inverse de l'âge
        const frequencyScore = accessPattern.frequency || 0;
        const accessScore = (frequencyScore * 0.7) + (recencyScore * 0.3);
        
        return { 
          key, 
          score: accessScore,
          lastAccessed: entry.lastAccessed
        };
      })
    );
    
    // Trier par score (les plus faibles en premier)
    keyDetails.sort((a, b) => a.score - b.score);
    
    return keyDetails.slice(0, keys.length - maxSize).map(detail => detail.key);
  }

  // Méthode pour ajuster dynamiquement les TTL
  async adjustTTL(key, newTTL) {
    const entry = await this.cache.get(key);
    if (entry) {
      entry.adaptiveTTL = newTTL;
      await this.cache.set(key, entry, { ttl: newTTL });
    }
  }
}

// Analyseur de motifs d'accès
class AccessPatternAnalyzer {
  constructor() {
    this.patterns = new Map(); // key -> pattern data
    this.analysisWindow = 3600000; // 1 heure
  }

  async recordAccess(key, value) {
    if (!this.patterns.has(key)) {
      this.patterns.set(key, {
        accesses: [],
        total: 0,
        lastWindowStart: Date.now()
      });
    }

    const pattern = this.patterns.get(key);
    const now = Date.now();
    
    // Nettoyer les accès hors fenêtre
    pattern.accesses = pattern.accesses.filter(time => 
      now - time < this.analysisWindow
    );
    
    // Ajouter le nouvel accès
    pattern.accesses.push(now);
    pattern.total++;
    
    // Calculer les métriques
    pattern.frequency = pattern.accesses.length / (this.analysisWindow / 1000); // accès par seconde
    pattern.burstiness = this.calculateBurstiness(pattern.accesses);
  }

  calculateBurstiness(accessTimes) {
    if (accessTimes.length < 2) return 0;
    
    // Calculer l'intervalle moyen entre les accès
    const intervals = [];
    for (let i = 1; i < accessTimes.length; i++) {
      intervals.push(accessTimes[i] - accessTimes[i - 1]);
    }
    
    if (intervals.length === 0) return 0;
    
    const mean = intervals.reduce((a, b) => a + b, 0) / intervals.length;
    const variance = intervals.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / intervals.length;
    const stdDev = Math.sqrt(variance);
    
    // Coefficient de variation (inverse de la régularité)
    return mean > 0 ? stdDev / mean : 0;
  }

  async getPattern(key) {
    return this.patterns.get(key) || {
      accesses: [],
      total: 0,
      frequency: 0,
      burstiness: 0
    };
  }
}

// Utilisation
const intelligentCache = new IntelligentCacheExpiration(distributedCache, {
  defaultStrategy: 'adaptive',
  maxCacheSize: 5000
});
```

Ces modèles de mise en cache fournissent des approches complètes pour gérer efficacement les données dans les applications modernes, en optimisant les performances tout en maintenant la fraîcheur et la cohérence des données.