# Modèles d'architecture modulaire

## Description
Ce document présente des modèles et des patrons de conception pour créer des architectures logicielles modulaires et évolutives.

## Principes de base de l'architecture modulaire

### 1. Responsabilité unique (SRP)
Chaque module ne doit avoir qu'une seule raison de changer.

```javascript
// Mauvais exemple - module avec multiples responsabilités
class UserModule {
  // Gestion des données utilisateur
  getUser(id) { /* ... */ }
  createUser(data) { /* ... */ }
  
  // Gestion de l'authentification
  login(credentials) { /* ... */ }
  logout() { /* ... */ }
  
  // Gestion des logs
  logAction(action) { /* ... */ }
}

// Bon exemple - modules séparés
class UserRepository {
  getUser(id) { /* ... */ }
  createUser(data) { /* ... */ }
}

class AuthService {
  login(credentials) { /* ... */ }
  logout() { /* ... */ }
}

class Logger {
  logAction(action) { /* ... */ }
}
```

### 2. Ouvert/fermé (OCP)
Les modules doivent être ouverts à l'extension mais fermés à la modification.

```javascript
// Interface pour les stratégies de notification
class NotificationStrategy {
  send(message) {
    throw new Error('Méthode non implémentée');
  }
}

class EmailNotification extends NotificationStrategy {
  send(message) {
    // Envoi par email
  }
}

class SmsNotification extends NotificationStrategy {
  send(message) {
    // Envoi par SMS
  }
}

// Module utilisant la stratégie
class NotificationModule {
  constructor(strategy) {
    this.strategy = strategy;
  }
  
  notify(message) {
    return this.strategy.send(message);
  }
}
```

## Modèles d'architecture

### 1. Architecture en couches (Layered Architecture)

#### Structure
```
src/
├── presentation/     # Interface utilisateur
│   ├── components/
│   └── pages/
├── application/      # Logique applicative
│   ├── services/
│   └── dtos/
├── domain/          # Logique métier
│   ├── entities/
│   ├── repositories/
│   └── use-cases/
└── infrastructure/  # Infrastructure
    ├── database/
    ├── external/
    └── config/
```

#### Exemple d'implémentation
```javascript
// Domain layer
class User {
  constructor(id, name, email) {
    this.id = id;
    this.name = name;
    this.email = email;
  }
}

class UserRepository {
  async findById(id) {
    throw new Error('Méthode non implémentée');
  }
  
  async save(user) {
    throw new Error('Méthode non implémentée');
  }
}

// Application layer
class UserService {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }
  
  async getUser(id) {
    return await this.userRepository.findById(id);
  }
  
  async createUser(userData) {
    const user = new User(userData.id, userData.name, userData.email);
    return await this.userRepository.save(user);
  }
}

// Infrastructure layer
class DatabaseUserRepository extends UserRepository {
  async findById(id) {
    // Récupération depuis la base de données
  }
  
  async save(user) {
    // Sauvegarde dans la base de données
  }
}
```

### 2. Architecture hexagonale (Ports and Adapters)

#### Structure
```
src/
├── core/              # Logique métier
│   ├── domain/
│   └── application/
├── adapters/          # Adaptateurs externes
│   ├── inbound/      # Entrée (API, Web)
│   └── outbound/     # Sortie (DB, Services externes)
└── ports/            # Interfaces
    ├── inbound/
    └── outbound/
```

#### Exemple d'implémentation
```javascript
// Port d'entrée (interface utilisateur)
class UserController {
  constructor(userService) {
    this.userService = userService;
  }
  
  async getUser(req, res) {
    const user = await this.userService.getUser(req.params.id);
    res.json(user);
  }
}

// Port de sortie (interface vers l'extérieur)
class UserRepositoryPort {
  async findById(id) {
    throw new Error('Méthode non implémentée');
  }
}

// Adaptateur sortant (implémentation concrète)
class DatabaseUserAdapter extends UserRepositoryPort {
  constructor(db) {
    super();
    this.db = db;
  }
  
  async findById(id) {
    return await this.db.users.findById(id);
  }
}
```

### 3. Architecture orientée domaine (Domain-Driven Design)

#### Structure
```
src/
├── domains/
│   └── [domain-name]/
│       ├── domain/      # Entités, agrégats, value objects
│       ├── application/ # Services, DTOs, handlers
│       ├── infrastructure/ # Repositories, adapters
│       └── presentation/ # API, UI
```

#### Exemple d'implémentation
```javascript
// Domaine de commande
class Order {
  constructor(id, items, customer) {
    this.id = id;
    this.items = items;
    this.customer = customer;
    this.status = 'PENDING';
  }
  
  addProduct(product) {
    if (this.status !== 'PENDING') {
      throw new Error('Commande déjà traitée');
    }
    this.items.push(product);
  }
  
  confirm() {
    this.status = 'CONFIRMED';
  }
}

class OrderService {
  constructor(orderRepository, paymentService) {
    this.orderRepository = orderRepository;
    this.paymentService = paymentService;
  }
  
  async createOrder(orderData) {
    const order = new Order(orderData.id, orderData.items, orderData.customer);
    
    // Logique métier
    if (await this.paymentService.processPayment(order)) {
      order.confirm();
      await this.orderRepository.save(order);
    }
    
    return order;
  }
}
```

## Modèles de communication entre modules

### 1. Communication synchrone
```javascript
// Appel direct entre modules
class OrderModule {
  constructor(paymentModule) {
    this.paymentModule = paymentModule;
  }
  
  async processOrder(order) {
    const paymentResult = await this.paymentModule.processPayment(order.total);
    if (paymentResult.success) {
      // Traiter la commande
    }
  }
}
```

### 2. Communication asynchrone (Event-Driven)
```javascript
// Publication d'événements
class EventPublisher {
  constructor() {
    this.subscribers = new Map();
  }
  
  subscribe(eventType, handler) {
    if (!this.subscribers.has(eventType)) {
      this.subscribers.set(eventType, []);
    }
    this.subscribers.get(eventType).push(handler);
  }
  
  publish(event) {
    const handlers = this.subscribers.get(event.type) || [];
    handlers.forEach(handler => handler(event));
  }
}

// Utilisation
class OrderService {
  constructor(eventPublisher) {
    this.eventPublisher = eventPublisher;
  }
  
  async createOrder(orderData) {
    // Créer la commande
    const order = new Order(orderData);
    
    // Publier un événement
    this.eventPublisher.publish({
      type: 'ORDER_CREATED',
      data: { orderId: order.id, customerId: order.customerId }
    });
    
    return order;
  }
}
```

## Modèles de configuration

### Configuration centralisée
```javascript
// config/modules.js
const modules = {
  database: {
    enabled: true,
    type: 'postgresql',
    options: {
      host: process.env.DB_HOST,
      port: process.env.DB_PORT
    }
  },
  authentication: {
    enabled: true,
    strategy: 'jwt',
    options: {
      secret: process.env.JWT_SECRET
    }
  }
};

// Chargement conditionnel des modules
class ModuleLoader {
  static load(config) {
    const loadedModules = {};
    
    for (const [name, moduleConfig] of Object.entries(config)) {
      if (moduleConfig.enabled) {
        loadedModules[name] = this.loadModule(name, moduleConfig);
      }
    }
    
    return loadedModules;
  }
}
```

## Bonnes pratiques pour l'architecture modulaire

### 1. Dépendances unidirectionnelles
```javascript
// Bon - dépendances vers les couches inférieures
// Presentation → Application → Domain → Infrastructure

// Mauvais - dépendances circulaires
// Presentation ←→ Domain (à éviter)
```

### 2. Injection de dépendances
```javascript
// Utilisation d'un conteneur IoC
class DIContainer {
  constructor() {
    this.services = new Map();
  }
  
  register(name, factory, singleton = true) {
    this.services.set(name, { factory, singleton, instance: null });
  }
  
  resolve(name) {
    const service = this.services.get(name);
    if (!service) {
      throw new Error(`Service ${name} non trouvé`);
    }
    
    if (service.singleton && service.instance) {
      return service.instance;
    }
    
    const instance = service.factory(this);
    if (service.singleton) {
      service.instance = instance;
    }
    
    return instance;
  }
}

// Enregistrement des services
const container = new DIContainer();
container.register('userRepository', () => new DatabaseUserRepository());
container.register('userService', (c) => new UserService(c.resolve('userRepository')));
```

### 3. Tests unitaires par module
```javascript
// Tests pour le module utilisateur
describe('UserService', () => {
  let userService;
  let mockUserRepository;
  
  beforeEach(() => {
    mockUserRepository = {
      findById: jest.fn(),
      save: jest.fn()
    };
    
    userService = new UserService(mockUserRepository);
  });
  
  it('devrait récupérer un utilisateur', async () => {
    const mockUser = { id: 1, name: 'John' };
    mockUserRepository.findById.mockResolvedValue(mockUser);
    
    const user = await userService.getUser(1);
    
    expect(user).toEqual(mockUser);
    expect(mockUserRepository.findById).toHaveBeenCalledWith(1);
  });
});
```

## Mise en œuvre progressive

### Étapes de modularisation
1. **Identification des domaines** - Identifier les différentes parties du système
2. **Définition des interfaces** - Définir les points d'entrée/sortie
3. **Extraction progressive** - Déplacer le code par couches
4. **Tests de régression** - S'assurer que tout fonctionne toujours
5. **Documentation** - Documenter les interfaces et contrats