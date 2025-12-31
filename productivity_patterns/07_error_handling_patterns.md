# Modèles de gestion des erreurs

## Description
Ce document présente des modèles et des pratiques pour la gestion des erreurs dans les applications modernes, avec des exemples concrets pour différents types de systèmes et environnements.

## Principes fondamentaux

### 1. Catégorisation des erreurs

#### Par origine
- **Erreurs de programmation** : Bugs, erreurs logiques
- **Erreurs d'exécution** : Problèmes système, ressources indisponibles
- **Erreurs de l'utilisateur** : Données invalides, mauvaise utilisation
- **Erreurs externes** : Services tiers, réseaux, API

#### Par gravité
- **Critique** : Système inutilisable
- **Haute** : Fonctionnalité majeure affectée
- **Moyenne** : Fonctionnalité mineure affectée
- **Faible** : Expérience utilisateur affectée

#### Par type
- **Erreurs techniques** : Problèmes d'infrastructure
- **Erreurs métier** : Règles de validation
- **Erreurs de sécurité** : Tentatives d'intrusion
- **Erreurs de performance** : Problèmes de latence

### 2. Modèle de gestion des erreurs centralisée

#### Hiérarchie d'erreurs
```javascript
// Modèle de base pour les erreurs
class BaseError extends Error {
  constructor(message, options = {}) {
    super(message);
    this.name = this.constructor.name;
    this.code = options.code || 'UNKNOWN_ERROR';
    this.status = options.status || 500;
    this.timestamp = new Date().toISOString();
    this.correlationId = options.correlationId || this.generateCorrelationId();
    this.details = options.details || {};
    this.previous = options.previous || null;
    
    // Maintenir la pile d'appel
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }

  generateCorrelationId() {
    return `err_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  toJSON() {
    return {
      name: this.name,
      message: this.message,
      code: this.code,
      status: this.status,
      timestamp: this.timestamp,
      correlationId: this.correlationId,
      details: this.details,
      stack: process.env.NODE_ENV === 'development' ? this.stack : undefined
    };
  }

  toString() {
    return `${this.name} [${this.code}]: ${this.message}`;
  }
}

// Erreurs spécifiques
class ValidationError extends BaseError {
  constructor(message, field, value, options = {}) {
    super(message, {
      ...options,
      code: 'VALIDATION_ERROR',
      status: 400
    });
    
    this.field = field;
    this.value = value;
    this.validationRule = options.validationRule;
  }
}

class AuthenticationError extends BaseError {
  constructor(message, options = {}) {
    super(message, {
      ...options,
      code: 'AUTHENTICATION_ERROR',
      status: 401
    });
  }
}

class AuthorizationError extends BaseError {
  constructor(message, options = {}) {
    super(message, {
      ...options,
      code: 'AUTHORIZATION_ERROR',
      status: 403
    });
  }
}

class ResourceNotFoundError extends BaseError {
  constructor(resource, id, options = {}) {
    super(`Ressource ${resource} avec ID ${id} non trouvée`, {
      ...options,
      code: 'RESOURCE_NOT_FOUND',
      status: 404
    });
    
    this.resource = resource;
    this.id = id;
  }
}

class RateLimitError extends BaseError {
  constructor(message, options = {}) {
    super(message, {
      ...options,
      code: 'RATE_LIMIT_EXCEEDED',
      status: 429
    });
    
    this.retryAfter = options.retryAfter;
  }
}

class ExternalServiceError extends BaseError {
  constructor(service, originalError, options = {}) {
    super(`Erreur du service externe ${service}: ${originalError.message}`, {
      ...options,
      code: 'EXTERNAL_SERVICE_ERROR',
      status: 502
    });
    
    this.service = service;
    this.originalError = originalError;
    this.response = options.response;
  }
}

class DatabaseError extends BaseError {
  constructor(operation, originalError, options = {}) {
    super(`Erreur de base de données lors de ${operation}: ${originalError.message}`, {
      ...options,
      code: 'DATABASE_ERROR',
      status: 500
    });
    
    this.operation = operation;
    this.originalError = originalError;
    this.query = options.query;
  }
}
```

#### Créateur d'erreurs
```javascript
// Fabrique d'erreurs
class ErrorFactory {
  static create(type, message, options = {}) {
    switch (type.toLowerCase()) {
      case 'validation':
        return new ValidationError(message, options.field, options.value, options);
      case 'authentication':
        return new AuthenticationError(message, options);
      case 'authorization':
        return new AuthorizationError(message, options);
      case 'notfound':
        return new ResourceNotFoundError(options.resource, options.id, options);
      case 'rate_limit':
        return new RateLimitError(message, options);
      case 'external_service':
        return new ExternalServiceError(options.service, options.originalError, options);
      case 'database':
        return new DatabaseError(options.operation, options.originalError, options);
      default:
        return new BaseError(message, options);
    }
  }

  static from(originalError, options = {}) {
    if (originalError instanceof BaseError) {
      return originalError;
    }

    // Détecter le type d'erreur à partir de l'erreur originale
    if (originalError.code === 'ENOENT') {
      return new ResourceNotFoundError('file', originalError.path, options);
    }
    
    if (originalError.code === 'ECONNREFUSED' || originalError.code === 'ETIMEDOUT') {
      return new ExternalServiceError('network', originalError, options);
    }
    
    if (originalError.code === 'EACCES' || originalError.code === 'EPERM') {
      return new AuthorizationError('Accès refusé', options);
    }

    // Pour les erreurs de validation Joi
    if (originalError.isJoi) {
      return new ValidationError(
        originalError.details[0].message,
        originalError.details[0].path[0],
        originalError._object[originalError.details[0].path[0]],
        options
      );
    }

    // Pour les erreurs de validation Mongoose
    if (originalError.name === 'ValidationError') {
      const field = Object.keys(originalError.errors)[0];
      const errorDetail = originalError.errors[field];
      return new ValidationError(errorDetail.message, field, errorDetail.value, options);
    }

    // Pour les erreurs HTTP
    if (originalError.status) {
      switch (originalError.status) {
        case 400:
          return new ValidationError(originalError.message, null, null, options);
        case 401:
          return new AuthenticationError(originalError.message, options);
        case 403:
          return new AuthorizationError(originalError.message, options);
        case 404:
          return new ResourceNotFoundError('unknown', 'unknown', options);
        case 429:
          return new RateLimitError(originalError.message, options);
        default:
          return new BaseError(originalError.message, {
            ...options,
            status: originalError.status
          });
      }
    }

    // Erreur générique
    return new BaseError(originalError.message || 'Erreur inconnue', {
      ...options,
      previous: originalError
    });
  }
}
```

## Modèles de gestion des erreurs

### 1. Modèle de journalisation des erreurs

#### Système de journalisation
```javascript
// Niveaux de journalisation
const LogLevel = {
  TRACE: 0,
  DEBUG: 1,
  INFO: 2,
  WARN: 3,
  ERROR: 4,
  FATAL: 5
};

class Logger {
  constructor(options = {}) {
    this.level = options.level || LogLevel.INFO;
    this.transport = options.transport || console;
    this.formatters = options.formatters || [];
    this.filters = options.filters || [];
  }

  log(level, message, meta = {}) {
    if (level < this.level) {
      return;
    }

    const logEntry = {
      timestamp: new Date().toISOString(),
      level: this.getLogLevelName(level),
      message,
      ...meta
    };

    // Appliquer les filtres
    for (const filter of this.filters) {
      if (!filter(logEntry)) {
        return; // Filtrer l'entrée
      }
    }

    // Appliquer les formateurs
    let formattedEntry = logEntry;
    for (const formatter of this.formatters) {
      formattedEntry = formatter(formattedEntry);
    }

    // Écrire dans le transport
    this.transport[level === LogLevel.ERROR ? 'error' : 'log'](
      JSON.stringify(formattedEntry)
    );
  }

  getLogLevelName(level) {
    return Object.keys(LogLevel).find(key => LogLevel[key] === level) || 'UNKNOWN';
  }

  // Méthodes de raccourci
  trace(message, meta) { this.log(LogLevel.TRACE, message, meta); }
  debug(message, meta) { this.log(LogLevel.DEBUG, message, meta); }
  info(message, meta) { this.log(LogLevel.INFO, message, meta); }
  warn(message, meta) { this.log(LogLevel.WARN, message, meta); }
  error(message, meta) { this.log(LogLevel.ERROR, message, meta); }
  fatal(message, meta) { this.log(LogLevel.FATAL, message, meta); }
}

// Formateurs d'erreurs
const errorFormatter = (entry) => {
  if (entry.error && entry.error instanceof BaseError) {
    entry.error = entry.error.toJSON();
  }
  return entry;
};

const maskSensitiveData = (entry) => {
  if (entry.meta && typeof entry.meta === 'object') {
    const maskedMeta = { ...entry.meta };
    
    // Masquer les données sensibles
    Object.keys(maskedMeta).forEach(key => {
      if (key.toLowerCase().includes('password') ||
          key.toLowerCase().includes('token') ||
          key.toLowerCase().includes('secret') ||
          key.toLowerCase().includes('key')) {
        maskedMeta[key] = '[REDACTED]';
      }
    });
    
    entry.meta = maskedMeta;
  }
  
  return entry;
};

// Filtres
const errorOnlyFilter = (entry) => {
  return entry.level >= LogLevel.ERROR;
};

// Logger configuré
const logger = new Logger({
  level: LogLevel.INFO,
  formatters: [errorFormatter, maskSensitiveData],
  filters: [] // Peut inclure errorOnlyFilter pour les logs d'erreurs seulement
});
```

#### Journalisation des erreurs avec contexte
```javascript
class ErrorLogger {
  constructor(logger) {
    this.logger = logger;
    this.errorCounts = new Map();
    this.rateLimiting = new Map();
  }

  logError(error, context = {}) {
    const errorId = error.correlationId || this.generateErrorId();
    
    // Compter les erreurs similaires
    const errorKey = `${error.code}_${error.message}`;
    const currentCount = this.errorCounts.get(errorKey) || 0;
    this.errorCounts.set(errorKey, currentCount + 1);
    
    // Appliquer la limitation de débit pour les erreurs fréquentes
    const now = Date.now();
    const lastLogged = this.rateLimiting.get(errorKey) || 0;
    const timeSinceLast = now - lastLogged;
    
    if (timeSinceLast < 60000) { // Limite à 1 fois par minute
      return; // Trop fréquent, ignorer
    }
    
    this.rateLimiting.set(errorKey, now);
    
    // Loguer l'erreur
    this.logger.error('Erreur capturée', {
      error: error.toJSON(),
      context,
      errorCount: currentCount + 1,
      errorId
    });
    
    // Métriques pour la surveillance
    this.sendErrorMetrics(error, context);
  }

  generateErrorId() {
    return `err_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  sendErrorMetrics(error, context) {
    // Envoyer les métriques à un service de surveillance
    // (ex: Datadog, Prometheus, etc.)
    if (typeof process.send === 'function') {
      process.send({
        type: 'error_metric',
        error: {
          code: error.code,
          status: error.status,
          timestamp: error.timestamp
        },
        context
      });
    }
  }

  // Méthode pour réinitialiser les compteurs
  resetCounters() {
    this.errorCounts.clear();
    this.rateLimiting.clear();
  }
}

// Utilisation
const errorLogger = new ErrorLogger(logger);

// Dans un middleware d'erreur
const errorHandler = (err, req, res, next) => {
  const error = ErrorFactory.from(err, {
    correlationId: req.id || generateRequestId(),
    details: {
      url: req.url,
      method: req.method,
      userAgent: req.get('User-Agent'),
      ip: req.ip
    }
  });

  errorLogger.logError(error, {
    request: {
      url: req.url,
      method: req.method,
      params: req.params,
      query: req.query,
      body: req.body
    }
  });

  // Répondre en fonction du type d'erreur
  res.status(error.status).json({
    success: false,
    error: {
      code: error.code,
      message: error.message,
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    }
  });
};
```

### 2. Modèle de récupération d'erreurs

#### Stratégie de retry avec backoff exponentiel
```javascript
class RetryStrategy {
  constructor(options = {}) {
    this.maxRetries = options.maxRetries || 3;
    this.baseDelay = options.baseDelay || 1000; // 1 seconde
    this.maxDelay = options.maxDelay || 30000; // 30 secondes
    this.factor = options.factor || 2; // Multiplicateur
    this.jitter = options.jitter || true; // Randomisation
    this.retryableErrors = options.retryableErrors || [
      'NETWORK_ERROR',
      'TIMEOUT_ERROR',
      'EXTERNAL_SERVICE_ERROR',
      'DATABASE_ERROR'
    ];
  }

  async execute(operation, context = {}) {
    let lastError;
    
    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        return await operation(attempt);
      } catch (error) {
        lastError = error;
        
        // Vérifier si l'erreur est réparable
        if (!this.isRetryable(error)) {
          throw error;
        }
        
        // Ne pas attendre après le dernier essai
        if (attempt < this.maxRetries) {
          const delay = this.calculateDelay(attempt);
          await this.sleep(delay);
          
          logger.warn(`Tentative ${attempt + 1} échouée, nouvelle tentative dans ${delay}ms`, {
            error: error.message,
            attempt: attempt + 1,
            context
          });
        }
      }
    }
    
    throw lastError;
  }

  isRetryable(error) {
    // Vérifier le code d'erreur
    if (this.retryableErrors.includes(error.code)) {
      return true;
    }
    
    // Vérifier le statut HTTP
    if (error.status && [500, 502, 503, 504].includes(error.status)) {
      return true;
    }
    
    // Vérifier les erreurs réseau
    if (error.code && ['ECONNRESET', 'ETIMEDOUT', 'ECONNREFUSED'].includes(error.code)) {
      return true;
    }
    
    return false;
  }

  calculateDelay(attempt) {
    let delay = this.baseDelay * Math.pow(this.factor, attempt);
    
    // Limiter le délai maximum
    delay = Math.min(delay, this.maxDelay);
    
    // Ajouter du jitter pour éviter les pics de charge
    if (this.jitter) {
      delay = delay * (0.5 + Math.random() * 0.5);
    }
    
    return Math.round(delay);
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Utilisation
const retryStrategy = new RetryStrategy({
  maxRetries: 3,
  baseDelay: 1000,
  maxDelay: 10000
});

const fetchUserData = async (userId) => {
  return await retryStrategy.execute(async (attempt) => {
    const response = await fetch(`/api/users/${userId}`, {
      timeout: 5000
    });
    
    if (!response.ok) {
      throw new ExternalServiceError('user-api', 
        new Error(`HTTP ${response.status}`), 
        { response }
      );
    }
    
    return await response.json();
  }, { userId });
};
```

#### Circuit Breaker Pattern
```javascript
class CircuitBreaker {
  constructor(options = {}) {
    this.threshold = options.threshold || 5; // Nombre d'erreurs avant ouverture
    this.timeout = options.timeout || 60000; // Temps avant tentative de fermeture
    this.failureThreshold = options.failureThreshold || 0.5; // 50% de taux d'erreur
    this.windowDuration = options.windowDuration || 60000; // Fenêtre de mesure
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.successCount = 0;
    this.lastFailureTime = null;
    this.failureHistory = []; // Historique des échecs
  }

  async execute(operation) {
    if (this.isOpen()) {
      if (this.isHalfOpen()) {
        return await this.attemptHalfOpen(operation);
      } else {
        // Circuit ouvert, rejeter immédiatement
        throw new Error('Circuit breaker is OPEN');
      }
    }

    try {
      const result = await operation();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onError(error);
      throw error;
    }
  }

  isOpen() {
    if (this.state === 'OPEN') {
      return Date.now() - this.lastFailureTime >= this.timeout;
    }
    return false;
  }

  isHalfOpen() {
    return this.state === 'HALF_OPEN';
  }

  onSuccess() {
    this.successCount++;
    this.failureCount = 0;
    
    // Vérifier si on peut fermer le circuit
    if (this.state === 'HALF_OPEN') {
      this.close();
    }
    
    // Nettoyer l'historique ancien
    this.cleanupHistory();
  }

  onError(error) {
    this.failureCount++;
    this.lastFailureTime = Date.now();
    this.failureHistory.push({
      timestamp: Date.now(),
      error: error
    });
    
    // Vérifier si on doit ouvrir le circuit
    if (this.shouldOpen()) {
      this.open();
    }
    
    // Nettoyer l'historique ancien
    this.cleanupHistory();
  }

  shouldOpen() {
    const now = Date.now();
    
    // Vérifier le seuil absolu d'erreurs
    if (this.failureCount >= this.threshold) {
      return true;
    }
    
    // Vérifier le taux d'erreur dans la fenêtre
    const recentFailures = this.failureHistory.filter(
      f => now - f.timestamp <= this.windowDuration
    );
    
    if (recentFailures.length >= this.threshold) {
      const failureRate = recentFailures.length / 
                         (recentFailures.length + this.successCount);
      return failureRate >= this.failureThreshold;
    }
    
    return false;
  }

  open() {
    this.state = 'OPEN';
    logger.warn('Circuit breaker opened', {
      failureCount: this.failureCount,
      successCount: this.successCount
    });
  }

  close() {
    this.state = 'CLOSED';
    this.failureCount = 0;
    this.successCount = 0;
    this.failureHistory = [];
    logger.info('Circuit breaker closed');
  }

  async attemptHalfOpen(operation) {
    this.state = 'HALF_OPEN';
    
    try {
      const result = await operation();
      this.close();
      return result;
    } catch (error) {
      // Échec en mode HALF_OPEN, réouvrir le circuit
      this.open();
      throw error;
    }
  }

  cleanupHistory() {
    const now = Date.now();
    this.failureHistory = this.failureHistory.filter(
      f => now - f.timestamp <= this.windowDuration
    );
  }

  getStatus() {
    return {
      state: this.state,
      failureCount: this.failureCount,
      successCount: this.successCount,
      lastFailureTime: this.lastFailureTime,
      canTry: this.state === 'CLOSED' || 
              (this.state === 'OPEN' && Date.now() - this.lastFailureTime >= this.timeout)
    };
  }
}

// Utilisation
const userApiCircuitBreaker = new CircuitBreaker({
  threshold: 3,
  timeout: 30000,
  windowDuration: 60000
});

const fetchUserDataWithCircuitBreaker = async (userId) => {
  return await userApiCircuitBreaker.execute(async () => {
    const response = await fetch(`/api/users/${userId}`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  });
};
```

### 3. Modèle de traitement des erreurs asynchrones

#### Gestion des erreurs dans les microservices
```javascript
class DistributedErrorManager {
  constructor(options = {}) {
    this.publisher = options.publisher; // Service de publication d'événements
    this.subscriber = options.subscriber; // Service d'écoute
    this.errorStore = options.errorStore; // Stockage des erreurs
    this.retryManager = new RetryStrategy(options.retryOptions);
    this.circuitBreaker = new CircuitBreaker(options.circuitBreakerOptions);
  }

  async handleServiceCall(serviceName, operation, context = {}) {
    try {
      // Utiliser le circuit breaker
      const result = await this.circuitBreaker.execute(async () => {
        // Effectuer l'opération avec retry
        return await this.retryManager.execute(operation, {
          service: serviceName,
          ...context
        });
      });

      // Logguer le succès
      await this.logSuccess(serviceName, context);

      return result;
    } catch (error) {
      // Logguer l'erreur
      await this.logError(error, serviceName, context);

      // Déterminer le comportement approprié
      const behavior = await this.determineErrorBehavior(error, serviceName, context);

      switch (behavior.action) {
        case 'FAIL_FAST':
          throw error;
        case 'USE_FALLBACK':
          return behavior.fallback();
        case 'QUEUE_FOR_RETRY':
          await this.queueForRetry(error, serviceName, operation, context);
          return behavior.fallback();
        case 'CIRCUIT_BREAK':
          // Déjà géré par le circuit breaker
          throw error;
        default:
          throw error;
      }
    }
  }

  async determineErrorBehavior(error, serviceName, context) {
    // Logique de décision basée sur le type d'erreur et le service
    if (error.code === 'EXTERNAL_SERVICE_ERROR') {
      // Pour les erreurs de service externe, utiliser un fallback
      if (this.hasFallback(serviceName)) {
        return {
          action: 'USE_FALLBACK',
          fallback: () => this.getFallbackData(serviceName, context)
        };
      }
    }

    if (error.code === 'DATABASE_ERROR' && context.operation === 'read') {
      // Pour les lectures, on peut utiliser un cache
      if (await this.hasCachedData(context.key)) {
        return {
          action: 'USE_FALLBACK',
          fallback: () => this.getCachedData(context.key)
        };
      }
    }

    if (this.isTransientError(error)) {
      // Pour les erreurs transitoires, réessayer plus tard
      return {
        action: 'QUEUE_FOR_RETRY',
        fallback: () => this.getDefaultFallback(context.operation)
      };
    }

    // Par défaut, échouer rapidement
    return {
      action: 'FAIL_FAST'
    };
  }

  isTransientError(error) {
    // Erreurs qui pourraient être résolues par un retry
    return [
      'NETWORK_ERROR',
      'TIMEOUT_ERROR',
      'CONNECTION_ERROR',
      'TEMPORARY_UNAVAILABLE'
    ].includes(error.code) || 
    (error.status && [502, 503, 504].includes(error.status));
  }

  hasFallback(serviceName) {
    // Vérifier si un fallback est disponible pour ce service
    return !!this.fallbackRegistry[serviceName];
  }

  getFallbackData(serviceName, context) {
    // Récupérer les données de secours
    return this.fallbackRegistry[serviceName]?.get(context) || 
           this.getDefaultFallback(context.operation);
  }

  async queueForRetry(error, serviceName, operation, context) {
    // Mettre la requête en file d'attente pour retry
    await this.errorStore.save({
      error: error.toJSON(),
      service: serviceName,
      operation: operation.toString(),
      context,
      scheduledRetry: new Date(Date.now() + 5 * 60 * 1000), // Dans 5 minutes
      retryCount: 0,
      maxRetries: 3
    });
  }

  async logError(error, serviceName, context) {
    await errorLogger.logError(error, {
      service: serviceName,
      context,
      timestamp: new Date().toISOString()
    });

    // Publier un événement pour surveillance
    if (this.publisher) {
      await this.publisher.publish('error.occurred', {
        error: error.toJSON(),
        service: serviceName,
        context,
        timestamp: new Date().toISOString()
      });
    }
  }

  async logSuccess(serviceName, context) {
    // Logguer le succès pour surveillance
    if (this.publisher) {
      await this.publisher.publish('service.call.success', {
        service: serviceName,
        context,
        timestamp: new Date().toISOString()
      });
    }
  }
}

// Registry des fallbacks
const fallbackRegistry = {
  'user-service': {
    get: async (context) => {
      // Retourner des données par défaut pour l'utilisateur
      return {
        id: context.userId,
        name: 'Utilisateur temporaire',
        email: 'fallback@example.com',
        fallback: true
      };
    }
  },
  
  'payment-service': {
    get: async (context) => {
      // Retourner un état de paiement par défaut
      return {
        status: 'pending_verification',
        amount: context.amount,
        currency: context.currency,
        fallback: true
      };
    }
  }
};
```

## Modèles de surveillance des erreurs

### 1. Système de rapports d'erreurs

#### Collecte d'erreurs en production
```javascript
class ProductionErrorReporter {
  constructor(options = {}) {
    this.apiEndpoint = options.apiEndpoint || '/api/errors';
    this.batchSize = options.batchSize || 10;
    this.flushInterval = options.flushInterval || 30000; // 30 secondes
    this.maxBufferSize = options.maxBufferSize || 100;
    
    this.errorBuffer = [];
    this.flushTimer = null;
    this.isSending = false;
    
    // Capturer les erreurs non gérées
    this.setupGlobalHandlers();
  }

  setupGlobalHandlers() {
    // Erreurs non gérées
    window.addEventListener('error', (event) => {
      this.reportError({
        type: 'unhandled_exception',
        message: event.message,
        stack: event.error?.stack || event.reason?.stack,
        url: window.location.href,
        userAgent: navigator.userAgent,
        timestamp: new Date().toISOString(),
        error: event.error || event.reason
      });
    });

    window.addEventListener('unhandledrejection', (event) => {
      this.reportError({
        type: 'unhandled_promise_rejection',
        message: event.reason?.message || String(event.reason),
        stack: event.reason?.stack,
        url: window.location.href,
        userAgent: navigator.userAgent,
        timestamp: new Date().toISOString(),
        reason: event.reason
      });
    });

    // Erreurs dans React
    if (typeof React !== 'undefined') {
      // Pour les applications React, utiliser Error Boundaries
      this.setupReactErrorBoundary();
    }
  }

  setupReactErrorBoundary() {
    // Code pour React Error Boundary
    class ErrorBoundary extends React.Component {
      constructor(props) {
        super(props);
        this.state = { hasError: false, error: null, errorInfo: null };
      }

      static getDerivedStateFromError(error) {
        return { hasError: true };
      }

      componentDidCatch(error, errorInfo) {
        this.setState({
          error: error,
          errorInfo: errorInfo
        });

        // Rapporter l'erreur
        this.props.onError?.(error, errorInfo);
      }

      render() {
        if (this.state.hasError) {
          return this.props.fallback || <div>Quelque chose s'est mal passé.</div>;
        }

        return this.props.children;
      }
    }

    // Rendre ErrorBoundary disponible globalement
    this.ErrorBoundary = ErrorBoundary;
  }

  reportError(errorData) {
    // Ajouter des informations contextuelles
    const enrichedError = {
      ...errorData,
      correlationId: this.generateCorrelationId(),
      sessionId: this.getSessionId(),
      pageUrl: window.location.href,
      referrer: document.referrer,
      screenWidth: screen.width,
      screenHeight: screen.height,
      viewportWidth: window.innerWidth,
      viewportHeight: window.innerHeight,
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development'
    };

    this.errorBuffer.push(enrichedError);

    // Flusher si nécessaire
    if (this.errorBuffer.length >= this.batchSize) {
      this.flushErrors();
    } else if (!this.flushTimer) {
      this.scheduleFlush();
    }

    // Limiter la taille du buffer
    if (this.errorBuffer.length > this.maxBufferSize) {
      this.errorBuffer = this.errorBuffer.slice(-this.maxBufferSize);
    }
  }

  async flushErrors() {
    if (this.isSending || this.errorBuffer.length === 0) {
      return;
    }

    this.isSending = true;
    const errorsToSend = [...this.errorBuffer];
    this.errorBuffer = [];

    try {
      await fetch(this.apiEndpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Session-ID': this.getSessionId()
        },
        body: JSON.stringify({ errors: errorsToSend })
      });

      logger.info(`Erreurs envoyées: ${errorsToSend.length}`);
    } catch (error) {
      logger.error('Échec de l\'envoi des erreurs:', error);
      
      // Réintégrer les erreurs échouées
      this.errorBuffer.unshift(...errorsToSend);
      
      // Réessayer plus tard
      setTimeout(() => this.flushErrors(), 60000); // 1 minute
    } finally {
      this.isSending = false;
    }
  }

  scheduleFlush() {
    this.flushTimer = setTimeout(() => {
      this.flushErrors();
      this.flushTimer = null;
    }, this.flushInterval);
  }

  generateCorrelationId() {
    return `web_err_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  getSessionId() {
    if (!sessionStorage.getItem('sessionId')) {
      const sessionId = `sess_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      sessionStorage.setItem('sessionId', sessionId);
    }
    return sessionStorage.getItem('sessionId');
  }

  // Méthode pour forcer l'envoi des erreurs
  async forceFlush() {
    if (this.flushTimer) {
      clearTimeout(this.flushTimer);
      this.flushTimer = null;
    }
    await this.flushErrors();
  }

  // Méthode pour nettoyer
  destroy() {
    if (this.flushTimer) {
      clearTimeout(this.flushTimer);
    }
    this.forceFlush(); // Envoyer les erreurs restantes
  }
}

// Initialiser le reporter
const errorReporter = new ProductionErrorReporter({
  apiEndpoint: '/api/client-errors',
  batchSize: 5,
  flushInterval: 15000
});

// Utilisation dans l'application
window.reportError = (error, context = {}) => {
  errorReporter.reportError({
    type: 'manual_report',
    message: error.message || String(error),
    stack: error.stack,
    context,
    timestamp: new Date().toISOString()
  });
};
```

### 2. Système de surveillance proactive

#### Surveillance des erreurs et alertes
```javascript
class ErrorMonitor {
  constructor(alertService, metricsService) {
    this.alertService = alertService;
    this.metricsService = metricsService;
    this.errorPatterns = new Map();
    this.anomalyDetectors = [];
    this.alertThresholds = {
      errorRate: 0.05, // 5% de taux d'erreur
      errorCount: 10,  // Plus de 10 erreurs en 5 minutes
      responseTime: 5000 // Plus de 5 secondes
    };
  }

  async monitorError(error, context) {
    // Enregistrer l'erreur
    await this.recordError(error, context);
    
    // Analyser les motifs
    await this.analyzePatterns(error, context);
    
    // Détecter les anomalies
    await this.detectAnomalies(error, context);
    
    // Mettre à jour les métriques
    await this.updateMetrics(error, context);
  }

  async recordError(error, context) {
    const errorKey = `${error.code}_${context.service || 'unknown'}`;
    const currentTime = Date.now();
    
    if (!this.errorPatterns.has(errorKey)) {
      this.errorPatterns.set(errorKey, {
        count: 0,
        firstSeen: currentTime,
        lastSeen: currentTime,
        contexts: new Set()
      });
    }
    
    const pattern = this.errorPatterns.get(errorKey);
    pattern.count++;
    pattern.lastSeen = currentTime;
    pattern.contexts.add(JSON.stringify(context));
  }

  async analyzePatterns(error, context) {
    const errorKey = `${error.code}_${context.service || 'unknown'}`;
    const pattern = this.errorPatterns.get(errorKey);
    
    // Vérifier la fréquence
    const timeWindow = 5 * 60 * 1000; // 5 minutes
    const errorRate = pattern.count / (Math.max(1, (pattern.lastSeen - pattern.firstSeen) / timeWindow));
    
    // Vérifier les motifs suspects
    if (pattern.count > this.alertThresholds.errorCount && 
        errorRate > this.alertThresholds.errorRate) {
      
      await this.alertService.sendAlert({
        type: 'ERROR_SPIKE',
        message: `Augmentation suspecte des erreurs: ${errorKey}`,
        severity: 'HIGH',
        data: {
          errorKey,
          count: pattern.count,
          rate: errorRate,
          contexts: Array.from(pattern.contexts)
        }
      });
    }
  }

  async detectAnomalies(error, context) {
    // Détecter les erreurs inhabituelles
    const knownErrors = await this.getKnownErrors();
    const isUnknown = !knownErrors.includes(error.code);
    
    if (isUnknown) {
      await this.alertService.sendAlert({
        type: 'NEW_ERROR_TYPE',
        message: `Nouveau type d'erreur détecté: ${error.code}`,
        severity: 'MEDIUM',
        data: { error, context }
      });
    }
    
    // Détecter les erreurs de performance
    if (context.duration && context.duration > this.alertThresholds.responseTime) {
      await this.alertService.sendAlert({
        type: 'PERFORMANCE_ISSUE',
        message: `Temps de réponse anormalement élevé: ${context.duration}ms`,
        severity: 'MEDIUM',
        data: { error, context }
      });
    }
  }

  async updateMetrics(error, context) {
    // Mettre à jour les métriques
    await this.metricsService.increment('errors.total', 1);
    await this.metricsService.increment(`errors.by_code.${error.code}`, 1);
    await this.metricsService.increment(`errors.by_service.${context.service || 'unknown'}`, 1);
    
    if (context.duration) {
      await this.metricsService.histogram('response_time', context.duration);
    }
  }

  async getKnownErrors() {
    // Récupérer la liste des erreurs connues
    // (habituellement depuis une base de données ou configuration)
    return [
      'VALIDATION_ERROR',
      'AUTHENTICATION_ERROR',
      'RESOURCE_NOT_FOUND',
      'RATE_LIMIT_EXCEEDED',
      'EXTERNAL_SERVICE_ERROR'
    ];
  }

  // Méthode pour réinitialiser les compteurs
  reset() {
    this.errorPatterns.clear();
  }
}

// Service d'alerte
class AlertService {
  constructor(notificationChannels) {
    this.channels = notificationChannels;
  }

  async sendAlert(alert) {
    const enrichedAlert = {
      ...alert,
      id: `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString(),
      acknowledged: false
    };

    // Envoyer à tous les canaux
    await Promise.all(
      this.channels.map(channel => 
        channel.send(enrichedAlert)
      )
    );

    // Logguer l'alerte
    logger.warn('Alerte envoyée', enrichedAlert);
  }
}

// Canal de notification Slack
class SlackAlertChannel {
  constructor(webhookUrl) {
    this.webhookUrl = webhookUrl;
  }

  async send(alert) {
    const severityColors = {
      'LOW': '#00ff00',
      'MEDIUM': '#ffff00', 
      'HIGH': '#ff0000',
      'CRITICAL': '#ff00ff'
    };

    const message = {
      attachments: [{
        color: severityColors[alert.severity] || '#cccccc',
        title: alert.message,
        fields: [
          {
            title: 'Type',
            value: alert.type,
            short: true
          },
          {
            title: 'Gravité',
            value: alert.severity,
            short: true
          },
          {
            title: 'Horodatage',
            value: new Date(alert.timestamp).toLocaleString(),
            short: true
          }
        ],
        footer: 'Système de surveillance des erreurs',
        ts: Math.floor(Date.now() / 1000)
      }]
    };

    await fetch(this.webhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(message)
    });
  }
}

// Initialisation
const slackChannel = new SlackAlertChannel(process.env.SLACK_WEBHOOK_URL);
const alertService = new AlertService([slackChannel]);
const errorMonitor = new ErrorMonitor(alertService, metricsService);
```

Ces modèles de gestion des erreurs fournissent des approches complètes pour anticiper, capturer, traiter et surveiller les erreurs dans les applications modernes, en assurant la résilience, la maintenabilité et une bonne expérience utilisateur même en cas de problèmes.