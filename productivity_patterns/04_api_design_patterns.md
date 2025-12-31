# Modèles de conception d'API

## Description
Ce document présente des modèles et des pratiques pour concevoir des API robustes, évolutives et faciles à utiliser, avec des exemples concrets et des recommandations pour différents types d'API.

## Principes fondamentaux

### 1. RESTful API Design Principles

#### Ressources et URI
- Utiliser des noms pluriels pour les collections
- Utiliser des verbes HTTP appropriés
- Éviter les verbes dans les URIs
- Utiliser des tirets pour les mots composés

```http
# Bonnes pratiques
GET    /users              # Liste des utilisateurs
GET    /users/123          # Détail d'un utilisateur
POST   /users              # Créer un utilisateur
PUT    /users/123          # Mettre à jour complètement
PATCH  /users/123          # Mise à jour partielle
DELETE /users/123          # Supprimer un utilisateur

# Mauvaises pratiques
GET    /getUser?id=123     # Verbe dans l'URI
POST   /updateUser         # Verbe dans l'URI
GET    /users/getById/123  # Mauvaise utilisation de GET
```

#### Codes de statut HTTP
```javascript
// Modèle de réponse API
const ApiResponse = {
  success: boolean,
  data: any,           // Données de réponse
  message: string,     // Message descriptif
  timestamp: string,   // Horodatage ISO
  requestId: string,   // ID pour le tracing
  errors: [Error]      // Liste des erreurs
};

// Codes de statut courants
const HttpStatusCodes = {
  // Succès
  OK: 200,           // Récupération réussie
  CREATED: 201,      // Ressource créée
  ACCEPTED: 202,     // Requête acceptée, traitement en cours
  NO_CONTENT: 204,   // Succès sans contenu
  
  // Erreurs clientes
  BAD_REQUEST: 400,     // Requête mal formée
  UNAUTHORIZED: 401,    // Authentification requise
  FORBIDDEN: 403,       // Accès refusé
  NOT_FOUND: 404,       // Ressource non trouvée
  CONFLICT: 409,        // Conflit (doublon)
  UNPROCESSABLE_ENTITY: 422,  // Entité non traitable
  TOO_MANY_REQUESTS: 429,     // Trop de requêtes
  
  // Erreurs serveur
  INTERNAL_SERVER_ERROR: 500,   // Erreur interne
  NOT_IMPLEMENTED: 501,         // Non implémenté
  BAD_GATEWAY: 502,             // Mauvaise passerelle
  SERVICE_UNAVAILABLE: 503,     // Service indisponible
  GATEWAY_TIMEOUT: 504          // Délai d'attente
};
```

### 2. Modèle de documentation API

#### OpenAPI 3.0
```yaml
openapi: 3.0.3
info:
  title: API Utilisateur
  description: API pour la gestion des utilisateurs
  version: 1.0.0
servers:
  - url: https://api.example.com/v1
    description: Serveur de production
paths:
  /users:
    get:
      summary: Récupérer la liste des utilisateurs
      description: Récupérer tous les utilisateurs avec pagination
      parameters:
        - name: page
          in: query
          description: Numéro de page
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: limit
          in: query
          description: Nombre d'éléments par page
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 10
      responses:
        '200':
          description: Liste des utilisateurs
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
        '400':
          $ref: '#/components/responses/BadRequest'
  /users/{id}:
    get:
      summary: Récupérer un utilisateur par ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
            minimum: 1
      responses:
        '200':
          description: Détail de l'utilisateur
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          $ref: '#/components/responses/NotFound'
components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: integer
          example: 1
        name:
          type: string
          example: "Jean Dupont"
        email:
          type: string
          format: email
          example: "jean.dupont@example.com"
        createdAt:
          type: string
          format: date-time
          example: "2023-01-01T00:00:00Z"
    Pagination:
      type: object
      properties:
        currentPage:
          type: integer
        totalPages:
          type: integer
        totalItems:
          type: integer
        itemsPerPage:
          type: integer
  responses:
    BadRequest:
      description: Requête mal formée
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
    NotFound:
      description: Ressource non trouvée
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
    Error:
      type: object
      properties:
        success:
          type: boolean
          example: false
        message:
          type: string
          example: "Ressource non trouvée"
        errorCode:
          type: string
          example: "RESOURCE_NOT_FOUND"
```

## Modèles d'API avancés

### 1. Modèle GraphQL

#### Schéma GraphQL
```graphql
# schema.graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  publishedAt: DateTime
  tags: [String!]!
  comments: [Comment!]!
}

type Comment {
  id: ID!
  content: String!
  author: User!
  post: Post!
  createdAt: DateTime!
}

type Query {
  # Utilisateurs
  users(limit: Int, offset: Int): [User!]!
  user(id: ID!): User
  me: User
  
  # Posts
  posts(limit: Int, offset: Int, authorId: ID): [Post!]!
  post(id: ID!): Post
  postsByTag(tag: String!): [Post!]!
  
  # Recherche
  search(query: String!, type: SearchType!): SearchResult!
}

type Mutation {
  # Utilisateurs
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
  
  # Posts
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
  deletePost(id: ID!): Boolean!
  
  # Comments
  addComment(input: AddCommentInput!): Comment!
  deleteComment(id: ID!): Boolean!
}

input CreateUserInput {
  name: String!
  email: String!
  password: String!
}

input UpdateUserInput {
  name: String
  email: String
}

input CreatePostInput {
  title: String!
  content: String!
  tags: [String!] = []
}

input UpdatePostInput {
  title: String
  content: String
  tags: [String!]
}

input AddCommentInput {
  postId: ID!
  content: String!
}

enum SearchType {
  USERS
  POSTS
  COMMENTS
}

union SearchResult = User | Post | Comment

scalar DateTime
```

#### Résolveurs GraphQL
```javascript
// resolvers.js
const { User, Post, Comment } = require('./models');

const resolvers = {
  Query: {
    users: async (_, { limit = 10, offset = 0 }) => {
      return await User.find()
        .limit(limit)
        .skip(offset)
        .sort({ createdAt: -1 });
    },

    user: async (_, { id }) => {
      return await User.findById(id);
    },

    posts: async (_, { limit = 10, offset = 0, authorId }) => {
      const query = authorId ? { authorId } : {};
      return await Post.find(query)
        .populate('author')
        .limit(limit)
        .skip(offset)
        .sort({ publishedAt: -1 });
    },

    post: async (_, { id }) => {
      return await Post.findById(id).populate('author');
    }
  },

  Mutation: {
    createUser: async (_, { input }) => {
      const user = new User(input);
      return await user.save();
    },

    createPost: async (_, { input }, { user }) => {
      if (!user) {
        throw new AuthenticationError('Non authentifié');
      }

      const post = new Post({
        ...input,
        authorId: user.id
      });

      return await post.save();
    }
  },

  User: {
    posts: async (user) => {
      return await Post.find({ authorId: user.id });
    }
  },

  Post: {
    author: async (post) => {
      return await User.findById(post.authorId);
    },

    comments: async (post) => {
      return await Comment.find({ postId: post.id });
    }
  }
};
```

### 2. Modèle d'API événementielle (Event-Driven)

#### Définition des événements
```javascript
// events.js
class Event {
  constructor(type, data, metadata = {}) {
    this.id = `evt_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this.type = type;
    this.data = data;
    this.timestamp = new Date().toISOString();
    this.metadata = {
      version: '1.0.0',
      source: metadata.source || 'unknown',
      userId: metadata.userId,
      correlationId: metadata.correlationId
    };
  }
}

// Types d'événements
const EventType = {
  USER_REGISTERED: 'user.registered',
  USER_PROFILE_UPDATED: 'user.profile.updated',
  ORDER_CREATED: 'order.created',
  PAYMENT_PROCESSED: 'payment.processed',
  NOTIFICATION_SENT: 'notification.sent'
};

// Gestionnaire d'événements
class EventManager {
  constructor() {
    this.handlers = new Map();
    this.middleware = [];
  }

  subscribe(eventType, handler) {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, []);
    }
    this.handlers.get(eventType).push(handler);
  }

  async publish(event) {
    // Appliquer les middlewares
    for (const middleware of this.middleware) {
      await middleware(event);
    }

    const handlers = this.handlers.get(event.type) || [];
    const promises = handlers.map(handler => 
      this.executeHandler(handler, event)
    );

    return Promise.all(promises);
  }

  async executeHandler(handler, event) {
    try {
      return await handler(event);
    } catch (error) {
      console.error(`Erreur dans le gestionnaire d'événement ${event.type}:`, error);
      // Logique de retry ou de fallback
    }
  }

  use(middleware) {
    this.middleware.push(middleware);
  }
}

// Utilisation
const eventManager = new EventManager();

// S'abonner à un événement
eventManager.subscribe(EventType.USER_REGISTERED, async (event) => {
  const { data: { userId, email } } = event;
  
  // Envoyer un email de bienvenue
  await sendWelcomeEmail(email);
  
  // Créer un profil utilisateur
  await createProfile(userId);
});

// Publier un événement
const userRegisteredEvent = new Event(
  EventType.USER_REGISTERED,
  { userId: '123', email: 'user@example.com' },
  { source: 'auth-service', userId: '123' }
);

await eventManager.publish(userRegisteredEvent);
```

### 3. Modèle d'API WebSocket/Streaming

#### Serveur WebSocket
```javascript
const WebSocket = require('ws');
const { EventEmitter } = require('events');

class APIServer extends EventEmitter {
  constructor(port = 3000) {
    super();
    this.port = port;
    this.wss = new WebSocket.Server({ port });
    this.clients = new Map();
    this.setupWebSocket();
  }

  setupWebSocket() {
    this.wss.on('connection', (ws, req) => {
      const clientId = this.generateClientId();
      this.clients.set(clientId, ws);

      ws.clientId = clientId;
      ws.send(JSON.stringify({ type: 'connected', clientId }));

      ws.on('message', (message) => {
        this.handleMessage(ws, message);
      });

      ws.on('close', () => {
        this.clients.delete(clientId);
        this.emit('clientDisconnected', clientId);
      });

      ws.on('error', (error) => {
        console.error('WebSocket error:', error);
      });

      this.emit('clientConnected', clientId);
    });
  }

  handleMessage(ws, message) {
    try {
      const data = JSON.parse(message);
      
      switch (data.type) {
        case 'subscribe':
          this.handleSubscribe(ws, data.channel);
          break;
        case 'unsubscribe':
          this.handleUnsubscribe(ws, data.channel);
          break;
        case 'broadcast':
          this.broadcastToChannel(data.channel, data.payload);
          break;
        default:
          ws.send(JSON.stringify({
            type: 'error',
            message: 'Type de message inconnu'
          }));
      }
    } catch (error) {
      ws.send(JSON.stringify({
        type: 'error',
        message: 'Message invalide'
      }));
    }
  }

  handleSubscribe(ws, channel) {
    if (!ws.channels) ws.channels = new Set();
    ws.channels.add(channel);
    
    ws.send(JSON.stringify({
      type: 'subscribed',
      channel
    }));
  }

  broadcastToChannel(channel, payload) {
    for (const [clientId, clientWs] of this.clients) {
      if (clientWs.channels && clientWs.channels.has(channel)) {
        clientWs.send(JSON.stringify({
          type: 'broadcast',
          channel,
          payload,
          timestamp: new Date().toISOString()
        }));
      }
    }
  }

  generateClientId() {
    return `client_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  // Méthode pour envoyer des données aux clients
  sendToClient(clientId, data) {
    const client = this.clients.get(clientId);
    if (client && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  }

  // Diffuser à tous les clients
  broadcast(data) {
    for (const client of this.clients.values()) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(data));
      }
    }
  }
}

// Utilisation
const apiServer = new APIServer(8080);

// Écouter les événements serveur
apiServer.on('clientConnected', (clientId) => {
  console.log(`Client ${clientId} connecté`);
});

apiServer.on('clientDisconnected', (clientId) => {
  console.log(`Client ${clientId} déconnecté`);
});

// Diffuser des mises à jour en temps réel
setInterval(() => {
  apiServer.broadcast({
    type: 'systemUpdate',
    message: 'Données mises à jour',
    timestamp: new Date().toISOString()
  });
}, 30000);
```

## Modèles de sécurité

### 1. Authentification et autorisation

#### JWT avec rafraîchissement
```javascript
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

class JWTManager {
  constructor(secret, refreshTokenSecret) {
    this.secret = secret;
    this.refreshTokenSecret = refreshTokenSecret;
  }

  // Générer un access token
  generateAccessToken(payload, expiresIn = '15m') {
    return jwt.sign(payload, this.secret, { expiresIn });
  }

  // Générer un refresh token
  generateRefreshToken(payload) {
    const refreshToken = crypto.randomBytes(40).toString('hex');
    // Stocker le refresh token dans une base de données
    // avec une expiration plus longue
    return refreshToken;
  }

  // Vérifier un access token
  verifyAccessToken(token) {
    try {
      return jwt.verify(token, this.secret);
    } catch (error) {
      throw new Error('Token invalide ou expiré');
    }
  }

  // Rafraîchir un token
  async refreshAccessToken(refreshToken) {
    // Vérifier que le refresh token existe et est valide
    const storedToken = await this.findStoredRefreshToken(refreshToken);
    if (!storedToken || storedToken.isRevoked) {
      throw new Error('Refresh token invalide');
    }

    // Générer un nouveau access token
    const newAccessToken = this.generateAccessToken(
      { userId: storedToken.userId },
      '15m'
    );

    return { accessToken: newAccessToken };
  }

  async findStoredRefreshToken(token) {
    // Implémentation pour rechercher dans la base de données
    // Cette méthode dépend de votre système de stockage
    return await RefreshToken.findOne({ token });
  }
}

// Middleware d'authentification
const authenticate = (required = true) => {
  return (req, res, next) => {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      if (required) {
        return res.status(401).json({
          error: 'Token d\'authentification requis'
        });
      }
      return next();
    }

    const token = authHeader.split(' ')[1]; // Bearer TOKEN
    
    try {
      const decoded = jwtManager.verifyAccessToken(token);
      req.user = decoded;
      next();
    } catch (error) {
      if (required) {
        return res.status(401).json({
          error: 'Token invalide ou expiré'
        });
      }
      next();
    }
  };
};

// Middleware d'autorisation
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Authentification requise'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Accès refusé'
      });
    }

    next();
  };
};

// Utilisation
app.get('/api/profile', authenticate(), (req, res) => {
  // Accès à req.user
  res.json({ user: req.user });
});

app.delete('/api/admin/users/:id', 
  authenticate(), 
  authorize('admin', 'moderator'), 
  (req, res) => {
    // Seuls les admins et modérateurs peuvent supprimer
  }
);
```

### 2. Rate Limiting

#### Middleware de limitation de débit
```javascript
class RateLimiter {
  constructor(options = {}) {
    this.maxRequests = options.maxRequests || 100;
    this.windowMs = options.windowMs || 15 * 60 * 1000; // 15 minutes
    this.storage = new Map(); // Simple en mémoire
  }

  getRateLimit(identifier) {
    const now = Date.now();
    let record = this.storage.get(identifier);

    if (!record) {
      record = { count: 0, resetTime: now + this.windowMs };
      this.storage.set(identifier, record);
    }

    // Nettoyer les anciens enregistrements
    if (now > record.resetTime) {
      record.count = 0;
      record.resetTime = now + this.windowMs;
    }

    return record;
  }

  check(identifier) {
    const record = this.getRateLimit(identifier);
    record.count++;

    const timeLeft = Math.ceil((record.resetTime - Date.now()) / 1000);

    return {
      limit: this.maxRequests,
      current: record.count,
      remaining: Math.max(this.maxRequests - record.count, 0),
      resetTime: record.resetTime,
      timeLeft: timeLeft,
      blocked: record.count > this.maxRequests
    };
  }

  middleware(options = {}) {
    return (req, res, next) => {
      // Identifier le client (IP, utilisateur, etc.)
      const identifier = options.keyGenerator 
        ? options.keyGenerator(req)
        : req.ip;

      const rateLimit = this.check(identifier);

      // Ajouter les headers de limite
      res.setHeader('X-RateLimit-Limit', rateLimit.limit);
      res.setHeader('X-RateLimit-Remaining', rateLimit.remaining);
      res.setHeader('X-RateLimit-Reset', rateLimit.resetTime);

      if (rateLimit.blocked) {
        return res.status(429).json({
          error: 'Trop de requêtes',
          retryAfter: rateLimit.timeLeft
        });
      }

      next();
    };
  }
}

// Utilisation
const apiRateLimiter = new RateLimiter({
  maxRequests: 100,
  windowMs: 15 * 60 * 1000
});

app.use('/api/', apiRateLimiter.middleware());

// Limite spécifique pour certaines routes
const authRateLimiter = new RateLimiter({
  maxRequests: 5,
  windowMs: 15 * 60 * 1000
});

app.post('/api/auth/login', authRateLimiter.middleware(), (req, res) => {
  // Route de login avec limite stricte
});
```

## Modèles de performance

### 1. Caching

#### Stratégie de mise en cache
```javascript
class CacheManager {
  constructor(options = {}) {
    this.cache = new Map();
    this.ttls = new Map(); // Temps d'expiration
    this.maxSize = options.maxSize || 1000;
    this.defaultTtl = options.defaultTtl || 5 * 60 * 1000; // 5 minutes
  }

  async get(key) {
    // Vérifier si la clé existe
    if (!this.cache.has(key)) {
      return null;
    }

    // Vérifier l'expiration
    const ttl = this.ttls.get(key);
    if (Date.now() > ttl) {
      this.delete(key);
      return null;
    }

    return this.cache.get(key);
  }

  async set(key, value, ttl = this.defaultTtl) {
    // Vérifier la taille maximale
    if (this.cache.size >= this.maxSize) {
      // Supprimer la moitié des entrées les plus anciennes
      const keys = Array.from(this.cache.keys());
      const half = Math.ceil(keys.length / 2);
      for (let i = 0; i < half; i++) {
        this.delete(keys[i]);
      }
    }

    this.cache.set(key, value);
    this.ttls.set(key, Date.now() + ttl);
  }

  delete(key) {
    this.cache.delete(key);
    this.ttls.delete(key);
  }

  clear() {
    this.cache.clear();
    this.ttls.clear();
  }

  // Méthode pour récupérer avec fallback
  async getOrSet(key, fetcher, ttl = this.defaultTtl) {
    let value = await this.get(key);
    
    if (value === null) {
      value = await fetcher();
      await this.set(key, value, ttl);
    }

    return value;
  }
}

// Utilisation avec une API
const cacheManager = new CacheManager({
  maxSize: 500,
  defaultTtl: 10 * 60 * 1000 // 10 minutes
});

app.get('/api/users/:id', async (req, res) => {
  const userId = req.params.id;
  const cacheKey = `user:${userId}`;

  try {
    const user = await cacheManager.getOrSet(
      cacheKey,
      () => fetchUserFromDatabase(userId),
      5 * 60 * 1000 // 5 minutes pour les utilisateurs
    );

    res.json({ data: user });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});
```

### 2. Pagination

#### Modèle de pagination avancée
```javascript
class Paginator {
  constructor(model) {
    this.model = model;
  }

  async paginate(query = {}, options = {}) {
    const {
      page = 1,
      limit = 10,
      sortBy = '_id',
      sortOrder = 'desc',
      populate = [],
      select = ''
    } = options;

    const skip = (page - 1) * limit;

    // Construire la requête
    let queryBuilder = this.model.find(query);

    // Appliquer les sélections
    if (select) {
      queryBuilder = queryBuilder.select(select);
    }

    // Appliquer le tri
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    queryBuilder = queryBuilder.sort(sort);

    // Appliquer la pagination
    queryBuilder = queryBuilder.skip(skip).limit(limit);

    // Appliquer les peuplements
    if (populate && populate.length > 0) {
      populate.forEach(pop => {
        if (typeof pop === 'string') {
          queryBuilder = queryBuilder.populate(pop);
        } else {
          queryBuilder = queryBuilder.populate(pop);
        }
      });
    }

    // Exécuter la requête
    const results = await queryBuilder.exec();

    // Compter le total
    const total = await this.model.countDocuments(query).exec();

    // Calculer la pagination
    const totalPages = Math.ceil(total / limit);
    const hasNextPage = page < totalPages;
    const hasPrevPage = page > 1;

    return {
      data: results,
      pagination: {
        currentPage: page,
        totalPages,
        totalItems: total,
        itemsPerPage: limit,
        hasNextPage,
        hasPrevPage,
        nextPage: hasNextPage ? page + 1 : null,
        prevPage: hasPrevPage ? page - 1 : null
      }
    };
  }
}

// Middleware de pagination
const paginationMiddleware = (defaultLimit = 10, maxLimit = 100) => {
  return (req, res, next) => {
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(
      parseInt(req.query.limit) || defaultLimit,
      maxLimit
    );
    const sortBy = req.query.sortBy || '_id';
    const sortOrder = req.query.sortOrder === 'asc' ? 'asc' : 'desc';

    req.pagination = { page, limit, sortBy, sortOrder };
    next();
  };
};

// Utilisation
app.get('/api/users', paginationMiddleware(20, 50), async (req, res) => {
  try {
    const paginator = new Paginator(UserModel);
    const result = await paginator.paginate(
      {}, // filtres
      req.pagination
    );

    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Erreur de pagination' });
  }
});
```

## Modèles de tests

### 1. Tests d'API

#### Structure de tests
```javascript
const request = require('supertest');
const app = require('../app');
const { User } = require('../models');

describe('API Utilisateurs', () => {
  let authToken;
  let testUser;

  beforeAll(async () => {
    // Créer un utilisateur de test
    testUser = await User.create({
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123'
    });

    // Obtenir un token d'authentification
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123'
      });

    authToken = response.body.token;
  });

  afterAll(async () => {
    // Nettoyer les données de test
    await User.deleteMany({ email: 'test@example.com' });
  });

  describe('GET /api/users', () => {
    it('devrait retourner une liste d\'utilisateurs', async () => {
      const response = await request(app)
        .get('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('data');
      expect(response.body).toHaveProperty('pagination');
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it('devrait supporter la pagination', async () => {
      const response = await request(app)
        .get('/api/users?page=1&limit=5')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.pagination.currentPage).toBe(1);
      expect(response.body.pagination.itemsPerPage).toBe(5);
    });
  });

  describe('GET /api/users/:id', () => {
    it('devrait retourner un utilisateur spécifique', async () => {
      const response = await request(app)
        .get(`/api/users/${testUser._id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.data._id).toBe(testUser._id.toString());
      expect(response.body.data.name).toBe('Test User');
    });

    it('devrait retourner 404 pour un utilisateur inexistant', async () => {
      await request(app)
        .get('/api/users/507f1f77bcf86cd799439011')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe('POST /api/users', () => {
    it('devrait créer un nouvel utilisateur', async () => {
      const newUser = {
        name: 'New User',
        email: 'newuser@example.com',
        password: 'password123'
      };

      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send(newUser)
        .expect(201);

      expect(response.body.data).toHaveProperty('_id');
      expect(response.body.data.name).toBe(newUser.name);
      expect(response.body.data.email).toBe(newUser.email);
    });

    it('devrait valider les données d\'entrée', async () => {
      const invalidUser = {
        name: '', // nom vide
        email: 'invalid-email', // email invalide
        password: '123' // mot de passe trop court
      };

      await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidUser)
        .expect(400);
    });
  });
});
```

Ces modèles de conception d'API fournissent des fondations solides pour créer des API robustes, évolutives et faciles à maintenir, en couvrant les aspects techniques, la sécurité, la performance et la qualité du code.