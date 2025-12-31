# Modèles de performance

## Description
Ce document présente des modèles et des stratégies pour optimiser la performance des applications, avec des exemples concrets pour l'optimisation du frontend, du backend et des systèmes distribués.

## Optimisation du frontend

### 1. Optimisation du rendu

#### Techniques de virtualisation
```javascript
// Modèle de liste virtuelle
class VirtualList {
  constructor(container, itemHeight, totalItems, renderItem) {
    this.container = container;
    this.itemHeight = itemHeight;
    this.totalItems = totalItems;
    this.renderItem = renderItem;
    this.visibleStart = 0;
    this.visibleEnd = 0;
    this.buffer = 5; // Nombre d'éléments supplémentaires à charger
    
    this.setupContainer();
    this.bindEvents();
    this.render();
  }

  setupContainer() {
    this.container.style.position = 'relative';
    this.container.style.overflow = 'auto';
    this.container.style.height = '400px'; // Hauteur fixe
    
    // Conteneur pour le contenu virtuel
    this.contentContainer = document.createElement('div');
    this.contentContainer.style.position = 'relative';
    this.contentContainer.style.width = '100%';
    this.container.appendChild(this.contentContainer);
    
    // Calculer la hauteur totale du contenu
    this.containerHeight = this.container.clientHeight;
    this.visibleItemCount = Math.ceil(this.containerHeight / this.itemHeight) + this.buffer;
  }

  bindEvents() {
    this.container.addEventListener('scroll', this.onScroll.bind(this));
    window.addEventListener('resize', this.onResize.bind(this));
  }

  onScroll() {
    const scrollTop = this.container.scrollTop;
    const startIndex = Math.floor(scrollTop / this.itemHeight);
    const endIndex = Math.min(
      startIndex + this.visibleItemCount,
      this.totalItems
    );

    if (startIndex !== this.visibleStart || endIndex !== this.visibleEnd) {
      this.visibleStart = startIndex;
      this.visibleEnd = endIndex;
      this.render();
    }
  }

  onResize() {
    this.containerHeight = this.container.clientHeight;
    this.visibleItemCount = Math.ceil(this.containerHeight / this.itemHeight) + this.buffer;
    this.render();
  }

  render() {
    // Calculer la hauteur totale
    this.contentContainer.style.height = `${this.totalItems * this.itemHeight}px`;
    
    // Calculer le décalage
    const offsetTop = this.visibleStart * this.itemHeight;
    
    // Nettoyer le contenu visible
    this.contentContainer.innerHTML = '';
    
    // Ajouter un élément de décalage
    const spacerTop = document.createElement('div');
    spacerTop.style.height = `${offsetTop}px`;
    this.contentContainer.appendChild(spacerTop);
    
    // Rendre les éléments visibles
    for (let i = this.visibleStart; i < this.visibleEnd; i++) {
      const itemContainer = document.createElement('div');
      itemContainer.style.position = 'absolute';
      itemContainer.style.top = `${i * this.itemHeight - offsetTop}px`;
      itemContainer.style.width = '100%';
      itemContainer.style.height = `${this.itemHeight}px`;
      itemContainer.style.display = 'flex';
      itemContainer.style.alignItems = 'center';
      itemContainer.style.padding = '0 10px';
      itemContainer.style.borderBottom = '1px solid #eee';
      
      itemContainer.innerHTML = this.renderItem(i);
      this.contentContainer.appendChild(itemContainer);
    }
  }

  updateData(newTotalItems) {
    this.totalItems = newTotalItems;
    this.visibleStart = 0;
    this.visibleEnd = Math.min(this.visibleItemCount, newTotalItems);
    this.render();
  }
}

// Utilisation
const container = document.getElementById('virtual-list-container');
const virtualList = new VirtualList(
  container,
  50, // Hauteur de chaque élément
  10000, // Nombre total d'éléments
  (index) => `<div>Élément ${index + 1}</div>` // Fonction de rendu
);
```

#### Optimisation de la réconciliation React
```jsx
// Utilisation de React.memo pour les composants fonctionnels
const ExpensiveComponent = React.memo(({ data, onUpdate }) => {
  console.log('Rendu de ExpensiveComponent');
  
  return (
    <div className="expensive-component">
      <h3>{data.title}</h3>
      <p>{data.description}</p>
      <button onClick={() => onUpdate(data.id)}>
        Mettre à jour
      </button>
    </div>
  );
}, (prevProps, nextProps) => {
  // Fonction de comparaison personnalisée
  return (
    prevProps.data.id === nextProps.data.id &&
    prevProps.data.title === nextProps.data.title &&
    prevProps.data.description === nextProps.data.description
  );
});

// Utilisation de useMemo pour les calculs coûteux
const OptimizedComponent = ({ items, searchTerm }) => {
  // Calcul coûteux optimisé
  const filteredItems = useMemo(() => {
    console.log('Calcul de filteredItems');
    return items.filter(item => 
      item.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }, [items, searchTerm]);

  // Calcul de statistiques optimisé
  const statistics = useMemo(() => {
    console.log('Calcul de statistics');
    return {
      total: items.length,
      filtered: filteredItems.length,
      averagePrice: filteredItems.reduce((sum, item) => sum + item.price, 0) / filteredItems.length
    };
  }, [items, filteredItems]);

  return (
    <div>
      <h2>Résultats: {statistics.filtered} sur {statistics.total}</h2>
      <p>Prix moyen: {statistics.averagePrice.toFixed(2)}</p>
      {filteredItems.map(item => (
        <ExpensiveComponent 
          key={item.id} 
          data={item} 
          onUpdate={() => console.log('Update', item.id)} 
        />
      ))}
    </div>
  );
};

// Utilisation de useCallback pour les fonctions
const ListWithCallbacks = ({ items, onItemClick }) => {
  // Mémoriser la fonction pour éviter la reconstruction inutile
  const handleClick = useCallback((itemId) => {
    onItemClick(itemId);
  }, [onItemClick]);

  return (
    <ul>
      {items.map(item => (
        <li key={item.id}>
          <button onClick={() => handleClick(item.id)}>
            {item.name}
          </button>
        </li>
      ))}
    </ul>
  );
};

// Gestion de l'état avec useReducer pour les états complexes
const initialState = {
  items: [],
  loading: false,
  error: null,
  filter: '',
  sort: 'name'
};

function itemsReducer(state, action) {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, loading: true, error: null };
    
    case 'FETCH_SUCCESS':
      return { 
        ...state, 
        loading: false, 
        items: action.payload,
        error: null
      };
    
    case 'FETCH_ERROR':
      return { 
        ...state, 
        loading: false, 
        error: action.payload 
      };
    
    case 'SET_FILTER':
      return { ...state, filter: action.payload };
    
    case 'SET_SORT':
      return { ...state, sort: action.payload };
    
    case 'UPDATE_ITEM':
      return {
        ...state,
        items: state.items.map(item =>
          item.id === action.payload.id 
            ? { ...item, ...action.payload.updates }
            : item
        )
      };
    
    default:
      return state;
  }
}

const OptimizedList = () => {
  const [state, dispatch] = useReducer(itemsReducer, initialState);
  
  const loadData = useCallback(async () => {
    dispatch({ type: 'FETCH_START' });
    
    try {
      const response = await fetch('/api/items');
      const data = await response.json();
      dispatch({ type: 'FETCH_SUCCESS', payload: data });
    } catch (error) {
      dispatch({ type: 'FETCH_ERROR', payload: error.message });
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // Tri et filtrage optimisés
  const processedItems = useMemo(() => {
    let result = [...state.items];
    
    // Filtrage
    if (state.filter) {
      result = result.filter(item =>
        item.name.toLowerCase().includes(state.filter.toLowerCase())
      );
    }
    
    // Tri
    result.sort((a, b) => {
      if (state.sort === 'name') {
        return a.name.localeCompare(b.name);
      } else if (state.sort === 'date') {
        return new Date(b.date) - new Date(a.date);
      }
      return 0;
    });
    
    return result;
  }, [state.items, state.filter, state.sort]);

  return (
    <div>
      <input
        type="text"
        placeholder="Filtrer..."
        value={state.filter}
        onChange={(e) => dispatch({ type: 'SET_FILTER', payload: e.target.value })}
      />
      <select
        value={state.sort}
        onChange={(e) => dispatch({ type: 'SET_SORT', payload: e.target.value })}
      >
        <option value="name">Trier par nom</option>
        <option value="date">Trier par date</option>
      </select>
      
      {state.loading && <div>Chargement...</div>}
      {state.error && <div>Erreur: {state.error}</div>}
      
      <ul>
        {processedItems.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  );
};
```

### 2. Gestion de la mémoire

#### Détection des fuites de mémoire
```javascript
class MemoryLeakDetector {
  constructor(options = {}) {
    this.checkInterval = options.checkInterval || 5000; // 5 secondes
    this.threshold = options.threshold || 100; // 100 objets en plus
    this.objectRegistry = new Map(); // Suivi des objets
    this.checkTimer = null;
    this.isEnabled = options.enabled !== false;
  }

  start() {
    if (!this.isEnabled) return;
    
    this.checkTimer = setInterval(() => {
      this.performCheck();
    }, this.checkInterval);
  }

  stop() {
    if (this.checkTimer) {
      clearInterval(this.checkTimer);
      this.checkTimer = null;
    }
  }

  registerObject(obj, identifier) {
    if (!this.isEnabled) return;
    
    const objectId = this.getObjectId(obj);
    this.objectRegistry.set(objectId, {
      object: obj,
      identifier: identifier,
      createdAt: Date.now(),
      referenceCount: 1
    });
  }

  unregisterObject(obj) {
    if (!this.isEnabled) return;
    
    const objectId = this.getObjectId(obj);
    this.objectRegistry.delete(objectId);
  }

  getObjectId(obj) {
    if (!obj.__objectId) {
      obj.__objectId = `obj_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
    return obj.__objectId;
  }

  async performCheck() {
    // Utiliser l'API PerformanceObserver pour les mesures de performance
    if (typeof PerformanceObserver !== 'undefined') {
      const memoryUsage = await this.getMemoryUsage();
      const objectCount = this.objectRegistry.size;
      
      // Comparer avec les mesures précédentes
      if (this.previousMeasurements) {
        const objectGrowth = objectCount - this.previousMeasurements.objectCount;
        const memoryGrowth = memoryUsage.usedJSHeapSize - this.previousMeasurements.memoryUsed;
        
        if (objectGrowth > this.threshold) {
          this.reportPotentialLeak({
            type: 'object_growth',
            growth: objectGrowth,
            objects: Array.from(this.objectRegistry.entries())
              .slice(0, 10) // Limiter à 10 objets pour la performance
          });
        }
        
        if (memoryGrowth > this.threshold * 1024 * 1024) { // 100MB threshold
          this.reportPotentialLeak({
            type: 'memory_growth',
            growth: memoryGrowth,
            usage: memoryUsage
          });
        }
      }
      
      this.previousMeasurements = {
        objectCount,
        memoryUsed: memoryUsage.usedJSHeapSize,
        timestamp: Date.now()
      };
    }
  }

  async getMemoryUsage() {
    if (performance.memory) {
      return {
        usedJSHeapSize: performance.memory.usedJSHeapSize,
        totalJSHeapSize: performance.memory.totalJSHeapSize,
        jsHeapSizeLimit: performance.memory.jsHeapSizeLimit
      };
    }
    
    // Fallback pour les navigateurs sans l'API Memory
    return {
      usedJSHeapSize: 0,
      totalJSHeapSize: 0,
      jsHeapSizeLimit: 0
    };
  }

  reportPotentialLeak(leakInfo) {
    console.warn('Fuite de mémoire potentielle détectée:', leakInfo);
    
    // Éventuellement envoyer à un service de monitoring
    if (this.reportCallback) {
      this.reportCallback(leakInfo);
    }
  }

  // Analyse des objets pour les fuites potentielles
  analyzeObjects() {
    const suspiciousObjects = [];
    
    for (const [id, objInfo] of this.objectRegistry) {
      const age = Date.now() - objInfo.createdAt;
      
      // Objets très anciens mais encore en mémoire
      if (age > 300000) { // 5 minutes
        suspiciousObjects.push({
          ...objInfo,
          age,
          ageMinutes: Math.floor(age / 60000)
        });
      }
    }
    
    return suspiciousObjects;
  }

  // Nettoyage des objets expirés
  cleanupExpiredObjects(maxAge = 300000) { // 5 minutes par défaut
    const now = Date.now();
    let cleanedCount = 0;
    
    for (const [id, objInfo] of this.objectRegistry) {
      if (now - objInfo.createdAt > maxAge) {
        this.objectRegistry.delete(id);
        cleanedCount++;
      }
    }
    
    return cleanedCount;
  }
}

// Utilisation
const memoryDetector = new MemoryLeakDetector({ enabled: true });
memoryDetector.start();

// Dans les composants React
class ComponentWithCleanup extends React.Component {
  constructor(props) {
    super(props);
    this.componentId = `comp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    memoryDetector.registerObject(this, this.componentId);
  }

  componentWillUnmount() {
    memoryDetector.unregisterObject(this);
  }

  render() {
    // Contenu du composant
  }
}
```

#### Gestion de la mémoire avec WeakMap
```javascript
// Utilisation de WeakMap pour éviter les fuites de mémoire
class ComponentDataManager {
  constructor() {
    // WeakMap ne conserve pas de référence forte vers les objets clés
    this.componentData = new WeakMap();
    this.eventHandlers = new WeakMap();
  }

  setComponentData(component, data) {
    this.componentData.set(component, {
      ...data,
      timestamp: Date.now()
    });
  }

  getComponentData(component) {
    return this.componentData.get(component);
  }

  setEventHandlers(component, handlers) {
    this.eventHandlers.set(component, handlers);
  }

  cleanupComponent(component) {
    // Nettoyer les données du composant
    this.componentData.delete(component);
    
    // Supprimer les gestionnaires d'événements
    const handlers = this.eventHandlers.get(component);
    if (handlers) {
      Object.entries(handlers).forEach(([element, eventMap]) => {
        Object.entries(eventMap).forEach(([event, handler]) => {
          element.removeEventListener(event, handler);
        });
      });
      this.eventHandlers.delete(component);
    }
  }

  // Nettoyage automatique avec FinalizationRegistry (si disponible)
  setupAutomaticCleanup() {
    if (typeof FinalizationRegistry !== 'undefined') {
      this.registry = new FinalizationRegistry((component) => {
        this.cleanupComponent(component);
      });
    }
  }

  registerForCleanup(component) {
    if (this.registry) {
      this.registry.register(component, component, component);
    }
  }
}

// Optimisation des événements
class OptimizedEventManager {
  constructor() {
    this.throttledEvents = new Map();
    this.debouncedEvents = new Map();
    this.passiveListeners = true; // Utiliser des écouteurs passifs
  }

  // Événements throttled
  addThrottledListener(element, event, handler, delay = 100) {
    const key = `${element.tagName}-${event}-${handler.name}`;
    
    if (!this.throttledEvents.has(key)) {
      const throttledHandler = this.throttle(handler, delay);
      element.addEventListener(event, throttledHandler, { passive: this.passiveListeners });
      this.throttledEvents.set(key, { handler: throttledHandler, element, event });
    }
  }

  // Événements debounced
  addDebouncedListener(element, event, handler, delay = 300) {
    const key = `${element.tagName}-${event}-${handler.name}`;
    
    if (!this.debouncedEvents.has(key)) {
      const debouncedHandler = this.debounce(handler, delay);
      element.addEventListener(event, debouncedHandler, { passive: this.passiveListeners });
      this.debouncedEvents.set(key, { handler: debouncedHandler, element, event });
    }
  }

  throttle(func, limit) {
    let inThrottle;
    return function() {
      const args = arguments;
      const context = this;
      if (!inThrottle) {
        func.apply(context, args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  }

  debounce(func, delay) {
    let timeoutId;
    return function() {
      const context = this;
      const args = arguments;
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => func.apply(context, args), delay);
    };
  }

  removeListener(element, event, handler) {
    element.removeEventListener(event, handler, { passive: this.passiveListeners });
  }

  destroy() {
    // Nettoyer tous les écouteurs
    this.throttledEvents.forEach((data, key) => {
      data.element.removeEventListener(data.event, data.handler);
    });
    
    this.debouncedEvents.forEach((data, key) => {
      data.element.removeEventListener(data.event, data.handler);
    });
    
    this.throttledEvents.clear();
    this.debouncedEvents.clear();
  }
}
```

## Optimisation du backend

### 1. Optimisation des requêtes

#### Modèle de requête optimisée
```javascript
class OptimizedQueryBuilder {
  constructor(knex) {
    this.knex = knex;
    this.queryCache = new Map();
    this.queryOptimizer = new QueryOptimizer();
  }

  async findWithOptimizations(table, conditions = {}, options = {}) {
    // Normaliser la requête pour le cache
    const normalizedQuery = this.normalizeQuery(table, conditions, options);
    const cacheKey = this.generateCacheKey(normalizedQuery);
    
    // Vérifier le cache
    if (options.useCache !== false) {
      const cachedResult = await this.getFromCache(cacheKey);
      if (cachedResult) {
        return cachedResult;
      }
    }

    // Optimiser la requête
    const optimizedQuery = await this.queryOptimizer.optimize(
      this.knex(table),
      conditions,
      options
    );

    // Exécuter la requête
    const result = await optimizedQuery;

    // Mettre en cache
    if (options.useCache !== false) {
      await this.setToCache(cacheKey, result, options.cacheTTL || 300);
    }

    return result;
  }

  normalizeQuery(table, conditions, options) {
    return {
      table,
      conditions: this.sortObject(conditions),
      fields: options.fields || '*',
      orderBy: options.orderBy,
      limit: options.limit,
      offset: options.offset,
      joins: options.joins || []
    };
  }

  sortObject(obj) {
    if (obj === null || typeof obj !== 'object') {
      return obj;
    }

    if (Array.isArray(obj)) {
      return obj.map(item => this.sortObject(item));
    }

    const sortedKeys = Object.keys(obj).sort();
    const sortedObj = {};

    for (const key of sortedKeys) {
      sortedObj[key] = this.sortObject(obj[key]);
    }

    return sortedObj;
  }

  generateCacheKey(query) {
    const queryString = JSON.stringify(query);
    return crypto.createHash('md5').update(queryString).digest('hex');
  }

  async getFromCache(key) {
    // Implémentation du cache (Redis, mémoire, etc.)
    return this.cacheProvider.get(key);
  }

  async setToCache(key, value, ttl) {
    return this.cacheProvider.set(key, value, { ttl });
  }
}

// Optimiseur de requêtes
class QueryOptimizer {
  constructor() {
    this.indexAnalyzer = new IndexAnalyzer();
    this.queryPlanner = new QueryPlanner();
  }

  async optimize(queryBuilder, conditions, options) {
    // Analyser les conditions pour optimiser les index
    const indexSuggestions = await this.indexAnalyzer.analyze(conditions);
    
    // Appliquer les suggestions d'index
    await this.applyIndexSuggestions(queryBuilder, indexSuggestions);
    
    // Optimiser la structure de la requête
    let optimizedQuery = queryBuilder;

    // Sélectionner seulement les champs nécessaires
    if (options.fields && options.fields !== '*') {
      optimizedQuery = optimizedQuery.select(options.fields);
    }

    // Appliquer les conditions
    optimizedQuery = this.applyConditions(optimizedQuery, conditions);

    // Appliquer les jointures
    if (options.joins) {
      optimizedQuery = this.applyJoins(optimizedQuery, options.joins);
    }

    // Appliquer le tri
    if (options.orderBy) {
      optimizedQuery = this.applyOrderBy(optimizedQuery, options.orderBy);
    }

    // Appliquer la pagination
    if (options.limit) {
      optimizedQuery = optimizedQuery.limit(options.limit);
      if (options.offset) {
        optimizedQuery = optimizedQuery.offset(options.offset);
      }
    }

    return optimizedQuery;
  }

  applyConditions(query, conditions) {
    for (const [field, value] of Object.entries(conditions)) {
      if (value !== undefined && value !== null) {
        if (Array.isArray(value)) {
          query = query.whereIn(field, value);
        } else if (typeof value === 'object') {
          // Conditions complexes
          if (value.$gt !== undefined) query = query.where(field, '>', value.$gt);
          if (value.$gte !== undefined) query = query.where(field, '>=', value.$gte);
          if (value.$lt !== undefined) query = query.where(field, '<', value.$lt);
          if (value.$lte !== undefined) query = query.where(field, '<=', value.$lte);
          if (value.$ne !== undefined) query = query.where(field, '!=', value.$ne);
          if (value.$like !== undefined) query = query.where(field, 'like', value.$like);
        } else {
          query = query.where(field, value);
        }
      }
    }
    return query;
  }

  applyJoins(query, joins) {
    for (const join of joins) {
      switch (join.type) {
        case 'inner':
          query = query.innerJoin(join.table, join.on);
          break;
        case 'left':
          query = query.leftJoin(join.table, join.on);
          break;
        case 'right':
          query = query.rightJoin(join.table, join.on);
          break;
        default:
          query = query.join(join.table, join.on);
      }
    }
    return query;
  }

  applyOrderBy(query, orderBy) {
    if (typeof orderBy === 'string') {
      return query.orderBy(orderBy, 'ASC');
    } else if (Array.isArray(orderBy)) {
      for (const order of orderBy) {
        const [field, direction = 'ASC'] = Array.isArray(order) ? order : [order, 'ASC'];
        query = query.orderBy(field, direction);
      }
    } else if (typeof orderBy === 'object') {
      for (const [field, direction] of Object.entries(orderBy)) {
        query = query.orderBy(field, direction);
      }
    }
    return query;
  }

  async analyzeQueryPerformance(query, startTime) {
    const endTime = Date.now();
    const executionTime = endTime - startTime;

    // Enregistrer les métriques de performance
    await this.performanceMonitor.record({
      query: query.toString(),
      executionTime,
      timestamp: new Date().toISOString()
    });

    // Vérifier si la requête est lente
    if (executionTime > 1000) { // Plus de 1 seconde
      await this.slowQueryAnalyzer.analyze(query, executionTime);
    }
  }
}

// Analyseur d'index
class IndexAnalyzer {
  async analyze(conditions) {
    const suggestions = [];

    for (const [field, value] of Object.entries(conditions)) {
      // Vérifier si un index existe pour ce champ
      const indexExists = await this.checkIndexExists(field);
      
      if (!indexExists) {
        suggestions.push({
          field,
          type: 'missing_index',
          recommendation: `CREATE INDEX idx_${field} ON table_name (${field});`
        });
      }
    }

    return suggestions;
  }

  async checkIndexExists(fieldName) {
    // Implémentation spécifique au système de base de données
    // Pour PostgreSQL:
    const result = await this.db.raw(`
      SELECT 1 
      FROM pg_indexes 
      WHERE tablename = 'your_table' 
      AND indexdef LIKE '%${fieldName}%'
    `);
    
    return result.rows.length > 0;
  }
}
```

### 2. Modèle de pooling de connexions

#### Pooling optimisé
```javascript
class ConnectionPool {
  constructor(config) {
    this.config = {
      min: config.min || 2,
      max: config.max || 10,
      acquireTimeout: config.acquireTimeout || 30000,
      idleTimeout: config.idleTimeout || 60000,
      evictionRunIntervalMillis: config.evictionRunIntervalMillis || 30000,
      ...config
    };
    
    this.pool = [];
    this.waitingQueue = [];
    this.activeConnections = 0;
    this.evictionTimer = null;
    this.stats = {
      totalAcquired: 0,
      totalReleased: 0,
      totalWaitTime: 0,
      maxWaitTime: 0
    };
  }

  async initialize() {
    // Créer les connexions initiales
    for (let i = 0; i < this.config.min; i++) {
      const connection = await this.createConnection();
      this.pool.push({
        connection,
        lastUsed: Date.now(),
        borrowed: false
      });
    }
    
    // Démarrer le nettoyage périodique
    this.startEvictionTimer();
  }

  async acquire() {
    const startTime = Date.now();
    
    // Vérifier si une connexion est disponible
    const availableConnection = this.pool.find(conn => !conn.borrowed);
    
    if (availableConnection) {
      availableConnection.borrowed = true;
      availableConnection.lastUsed = Date.now();
      this.activeConnections++;
      
      this.recordWaitTime(Date.now() - startTime);
      return availableConnection.connection;
    }
    
    // Si pas de connexion disponible et pool pas plein
    if (this.pool.length < this.config.max) {
      const newConnection = await this.createConnection();
      const connectionWrapper = {
        connection: newConnection,
        lastUsed: Date.now(),
        borrowed: true
      };
      
      this.pool.push(connectionWrapper);
      this.activeConnections++;
      
      this.recordWaitTime(Date.now() - startTime);
      return newConnection;
    }
    
    // Ajouter à la file d'attente
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        const index = this.waitingQueue.findIndex(req => req.id === request.id);
        if (index > -1) {
          this.waitingQueue.splice(index, 1);
          reject(new Error('Délai de connexion dépassé'));
        }
      }, this.config.acquireTimeout);
      
      const request = {
        id: Date.now() + Math.random(),
        resolve,
        reject,
        timeout
      };
      
      this.waitingQueue.push(request);
    });
  }

  async release(connection) {
    const connectionWrapper = this.pool.find(
      wrapper => wrapper.connection === connection
    );
    
    if (connectionWrapper) {
      connectionWrapper.borrowed = false;
      connectionWrapper.lastUsed = Date.now();
      this.activeConnections--;
      
      // Si quelqu'un attend une connexion
      if (this.waitingQueue.length > 0) {
        const request = this.waitingQueue.shift();
        clearTimeout(request.timeout);
        
        connectionWrapper.borrowed = true;
        this.activeConnections++;
        
        request.resolve(connectionWrapper.connection);
      }
    }
  }

  async createConnection() {
    // Méthode à implémenter selon le type de base de données
    // Exemple pour MySQL:
    /*
    const mysql = require('mysql2/promise');
    return await mysql.createConnection({
      host: this.config.host,
      user: this.config.user,
      password: this.config.password,
      database: this.config.database
    });
    */
  }

  async validateConnection(connection) {
    try {
      // Vérifier si la connexion est toujours valide
      await connection.execute('SELECT 1');
      return true;
    } catch (error) {
      return false;
    }
  }

  async destroyConnection(connection) {
    try {
      await connection.end();
    } catch (error) {
      // La connexion est peut-être déjà fermée
      console.warn('Erreur lors de la fermeture de la connexion:', error);
    }
  }

  async evictIdleConnections() {
    const now = Date.now();
    const idleTimeout = this.config.idleTimeout;
    
    for (let i = this.pool.length - 1; i >= 0; i--) {
      const wrapper = this.pool[i];
      
      if (!wrapper.borrowed && (now - wrapper.lastUsed) > idleTimeout) {
        await this.destroyConnection(wrapper.connection);
        this.pool.splice(i, 1);
      }
    }
  }

  startEvictionTimer() {
    this.evictionTimer = setInterval(() => {
      this.evictIdleConnections().catch(console.error);
    }, this.config.evictionRunIntervalMillis);
  }

  async close() {
    if (this.evictionTimer) {
      clearInterval(this.evictionTimer);
    }
    
    // Libérer toutes les connexions
    for (const wrapper of this.pool) {
      await this.destroyConnection(wrapper.connection);
    }
    
    this.pool = [];
    this.waitingQueue = [];
  }

  getStats() {
    return {
      ...this.stats,
      poolSize: this.pool.length,
      activeConnections: this.activeConnections,
      waitingRequests: this.waitingQueue.length,
      utilization: this.activeConnections / this.config.max
    };
  }

  recordWaitTime(waitTime) {
    this.stats.totalWaitTime += waitTime;
    this.stats.maxWaitTime = Math.max(this.stats.maxWaitTime, waitTime);
    this.stats.totalAcquired++;
  }
}

// Utilisation avec Knex
class OptimizedKnex {
  constructor(config) {
    this.pool = new ConnectionPool(config.pool);
    this.knex = require('knex')(config);
  }

  async query(queryBuilder) {
    const connection = await this.pool.acquire();
    
    try {
      // Utiliser la connexion spécifique
      const result = await queryBuilder.connection(connection);
      return result;
    } finally {
      await this.pool.release(connection);
    }
  }

  async transaction(callback) {
    const connection = await this.pool.acquire();
    
    try {
      const trx = await this.knex.transactionProvider()(connection);
      const result = await callback(trx);
      await trx.commit();
      return result;
    } catch (error) {
      await trx.rollback(error);
      throw error;
    } finally {
      await this.pool.release(connection);
    }
  }

  async close() {
    await this.pool.close();
  }
}
```

## Optimisation du chargement des données

### 1. Modèle de chargement différé (Lazy Loading)

#### Chargement différé avec DataLoader
```javascript
const DataLoader = require('dataloader');

class OptimizedDataLoader {
  constructor(db) {
    this.db = db;
    this.loaders = new Map();
  }

  getLoader(entityType, options = {}) {
    const key = `${entityType}:${JSON.stringify(options)}`;
    
    if (!this.loaders.has(key)) {
      this.loaders.set(key, new DataLoader(
        async (ids) => {
          const entities = await this.batchLoadEntities(entityType, ids, options);
          
          // Mapper les résultats dans le même ordre que les IDs demandés
          return ids.map(id => 
            entities.find(entity => entity.id == id) || null
          );
        },
        {
          cache: true,
          cacheKeyFn: (key) => key.toString()
        }
      ));
    }
    
    return this.loaders.get(key);
  }

  async batchLoadEntities(entityType, ids, options) {
    const query = this.db(entityType)
      .whereIn('id', ids);
    
    if (options.fields) {
      query.select(options.fields);
    }
    
    if (options.include) {
      // Ajouter les jointures nécessaires
      for (const relation of options.include) {
        query.leftJoin(
          `${relation.table}`, 
          `${entityType}.${relation.foreignKey}`, 
          `${relation.table}.id`
        );
      }
    }
    
    return await query;
  }

  // Chargement multiple avec regroupement
  async loadMany(entityType, conditions = {}, options = {}) {
    // Regrouper les conditions similaires pour optimiser les requêtes
    const cacheKey = this.generateQueryCacheKey(entityType, conditions, options);
    
    if (options.useCache && this.queryCache.has(cacheKey)) {
      return this.queryCache.get(cacheKey);
    }
    
    const results = await this.db(entityType)
      .where(conditions)
      .select(options.fields || '*')
      .orderBy(options.orderBy || 'id');
    
    if (options.useCache) {
      this.queryCache.set(cacheKey, results);
    }
    
    return results;
  }

  generateQueryCacheKey(entityType, conditions, options) {
    return `${entityType}:${JSON.stringify({
      conditions: this.sortObject(conditions),
      fields: options.fields,
      orderBy: options.orderBy
    })}`;
  }

  sortObject(obj) {
    if (obj === null || typeof obj !== 'object') {
      return obj;
    }

    if (Array.isArray(obj)) {
      return obj.map(item => this.sortObject(item));
    }

    const sortedKeys = Object.keys(obj).sort();
    const sortedObj = {};

    for (const key of sortedKeys) {
      sortedObj[key] = this.sortObject(obj[key]);
    }

    return sortedObj;
  }

  // Préchargement des relations
  async preloadRelations(entities, relations) {
    if (!entities || entities.length === 0) {
      return entities;
    }

    const result = [...entities];

    for (const relation of relations) {
      // Extraire les IDs des entités parentes
      const parentIds = entities.map(entity => entity[relation.parentKey]).filter(id => id);
      
      if (parentIds.length === 0) continue;

      // Charger les entités filles
      const children = await this.db(relation.childTable)
        .whereIn(relation.childKey, parentIds)
        .select('*');

      // Associer les enfants aux parents
      for (const entity of result) {
        const entityChildren = children.filter(
          child => child[relation.childKey] == entity[relation.parentKey]
        );
        
        entity[relation.alias || relation.childTable] = entityChildren;
      }
    }

    return result;
  }

  // Chargement en cascade
  async loadWithCascade(entityType, id, cascadeLevels = 1, currentLevel = 0) {
    if (currentLevel >= cascadeLevels) {
      return await this.getLoader(entityType).load(id);
    }

    const entity = await this.getLoader(entityType).load(id);
    
    if (!entity) {
      return null;
    }

    // Charger les relations
    const relations = await this.getRelationsForEntity(entityType);
    
    for (const relation of relations) {
      if (relation.cascade && relation.type === 'hasMany') {
        const children = await this.loadMany(
          relation.target,
          { [relation.foreignKey]: entity.id }
        );
        
        const cascadeChildren = await Promise.all(
          children.map(child => 
            this.loadWithCascade(
              relation.target, 
              child.id, 
              cascadeLevels, 
              currentLevel + 1
            )
          )
        );
        
        entity[relation.property] = cascadeChildren;
      }
    }

    return entity;
  }

  async getRelationsForEntity(entityType) {
    // Retourner les relations configurées pour ce type d'entité
    const relationsConfig = {
      'users': [
        { 
          target: 'posts', 
          foreignKey: 'userId', 
          property: 'posts',
          cascade: true,
          type: 'hasMany'
        },
        {
          target: 'profile',
          foreignKey: 'userId',
          property: 'profile',
          cascade: true,
          type: 'hasOne'
        }
      ],
      'posts': [
        {
          target: 'comments',
          foreignKey: 'postId',
          property: 'comments',
          cascade: false, // Ne pas charger automatiquement pour les posts
          type: 'hasMany'
        }
      ]
    };

    return relationsConfig[entityType] || [];
  }
}

// Utilisation
const dataLoader = new OptimizedDataLoader(database);

// Chargement optimisé
const userLoader = dataLoader.getLoader('users');
const users = await Promise.all([
  userLoader.load(1),
  userLoader.load(2),
  userLoader.load(3)
]);

// Chargement avec relations
const userWithPosts = await dataLoader.loadWithCascade('users', 1, 2);
```

### 2. Modèle de mise en cache intelligente

#### Cache avec invalidation automatique
```javascript
class SmartCache {
  constructor(options = {}) {
    this.cache = new Map();
    this.ttls = new Map();
    this.dependencies = new Map(); // key -> [dependent_keys]
    this.dependents = new Map();   // dependent_key -> [keys]
    this.options = {
      maxEntries: options.maxEntries || 1000,
      defaultTTL: options.defaultTTL || 300000, // 5 minutes
      cleanupInterval: options.cleanupInterval || 60000, // 1 minute
      ...options
    };
    
    this.startCleanupTimer();
  }

  async get(key) {
    if (!this.cache.has(key)) {
      return undefined;
    }

    // Vérifier l'expiration
    const ttl = this.ttls.get(key);
    if (ttl && Date.now() > ttl) {
      await this.delete(key);
      return undefined;
    }

    return this.cache.get(key);
  }

  async set(key, value, options = {}) {
    const ttl = options.ttl || this.options.defaultTTL;
    const dependencies = options.dependencies || [];

    // Gérer la taille maximale
    if (this.cache.size >= this.options.maxEntries) {
      // Supprimer les entrées les plus anciennes
      const oldestKey = this.getOldestKey();
      await this.delete(oldestKey);
    }

    // Stocker la valeur
    this.cache.set(key, value);
    
    // Stocker le TTL
    if (ttl > 0) {
      this.ttls.set(key, Date.now() + ttl);
    }

    // Enregistrer les dépendances
    for (const dependency of dependencies) {
      if (!this.dependents.has(dependency)) {
        this.dependents.set(dependency, new Set());
      }
      this.dependents.get(dependency).add(key);
      
      if (!this.dependencies.has(key)) {
        this.dependencies.set(key, new Set());
      }
      this.dependencies.get(key).add(dependency);
    }
  }

  async delete(key) {
    this.cache.delete(key);
    this.ttls.delete(key);
    
    // Supprimer les références de dépendances
    if (this.dependencies.has(key)) {
      for (const dependency of this.dependencies.get(key)) {
        if (this.dependents.has(dependency)) {
          this.dependents.get(dependency).delete(key);
        }
      }
      this.dependencies.delete(key);
    }
  }

  async invalidateByDependency(dependency) {
    // Invalider toutes les clés dépendantes de cette dépendance
    const dependents = this.dependents.get(dependency) || new Set();
    
    for (const dependent of dependents) {
      await this.delete(dependent);
    }
    
    // Nettoyer la référence
    this.dependents.delete(dependency);
  }

  async invalidateByPattern(pattern) {
    const regex = new RegExp(pattern.replace(/\*/g, '.*'));
    const keysToDelete = [];
    
    for (const key of this.cache.keys()) {
      if (regex.test(key)) {
        keysToDelete.push(key);
      }
    }
    
    for (const key of keysToDelete) {
      await this.delete(key);
    }
  }

  getOldestKey() {
    let oldestKey = null;
    let oldestTime = Infinity;
    
    for (const [key, value] of this.ttls.entries()) {
      if (value < oldestTime) {
        oldestTime = value;
        oldestKey = key;
      }
    }
    
    return oldestKey;
  }

  startCleanupTimer() {
    this.cleanupTimer = setInterval(() => {
      this.cleanupExpired();
    }, this.options.cleanupInterval);
  }

  async cleanupExpired() {
    const now = Date.now();
    const expiredKeys = [];
    
    for (const [key, ttl] of this.ttls.entries()) {
      if (now > ttl) {
        expiredKeys.push(key);
      }
    }
    
    for (const key of expiredKeys) {
      await this.delete(key);
    }
  }

  async getStats() {
    const now = Date.now();
    let expiredCount = 0;
    let validCount = 0;
    
    for (const [key, ttl] of this.ttls.entries()) {
      if (now > ttl) {
        expiredCount++;
      } else {
        validCount++;
      }
    }
    
    return {
      totalEntries: this.cache.size,
      validEntries: validCount,
      expiredEntries: expiredCount,
      hitRate: this.hitCount / (this.hitCount + this.missCount),
      memoryUsage: JSON.stringify([...this.cache.entries()]).length
    };
  }

  // Méthode pour le cache conditionnel
  async getOrSet(key, fetcher, options = {}) {
    let value = await this.get(key);
    
    if (value === undefined) {
      this.missCount++;
      value = await fetcher();
      
      if (value !== undefined) {
        await this.set(key, value, options);
      }
    } else {
      this.hitCount++;
    }
    
    return value;
  }

  // Cache avec rafraîchissement automatique
  async getWithAutoRefresh(key, fetcher, options = {}) {
    const cached = await this.get(key);
    
    if (cached && cached.data) {
      // Vérifier si le cache doit être rafraîchi
      const shouldRefresh = options.refreshThreshold && 
                           (Date.now() - cached.timestamp) > options.refreshThreshold;
      
      if (shouldRefresh) {
        // Rafraîchir en arrière-plan
        this.refreshInBackground(key, fetcher, options);
      }
      
      return cached.data;
    }
    
    // Charger les données fraîches
    const freshData = await fetcher();
    await this.set(key, { data: freshData, timestamp: Date.now() }, options);
    
    return freshData;
  }

  async refreshInBackground(key, fetcher, options) {
    try {
      const freshData = await fetcher();
      await this.set(key, { data: freshData, timestamp: Date.now() }, options);
    } catch (error) {
      console.error('Erreur de rafraîchissement en arrière-plan:', error);
    }
  }

  async close() {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
    }
  }
}

// Utilisation dans une application
const smartCache = new SmartCache({
  maxEntries: 5000,
  defaultTTL: 600000, // 10 minutes
  cleanupInterval: 30000 // 30 secondes
});

// Exemple d'utilisation avec dépendances
app.get('/api/users/:id', async (req, res) => {
  const userId = req.params.id;
  
  try {
    const user = await smartCache.getOrSet(
      `user:${userId}`,
      async () => {
        return await User.findById(userId);
      },
      {
        ttl: 300000, // 5 minutes
        dependencies: [`user:${userId}`, 'users_list']
      }
    );
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Invalidation automatique lors de la mise à jour d'un utilisateur
app.put('/api/users/:id', async (req, res) => {
  const userId = req.params.id;
  
  try {
    await User.findByIdAndUpdate(userId, req.body);
    
    // Invalider les dépendances
    await smartCache.invalidateByDependency(`user:${userId}`);
    await smartCache.invalidateByDependency('users_list');
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

## Modèles de performance pour les systèmes distribués

### 1. Modèle de circuit breaker

#### Circuit breaker avec métriques
```javascript
class CircuitBreaker {
  constructor(options = {}) {
    this.options = {
      timeout: options.timeout || 10000,
      maxFailures: options.maxFailures || 5,
      resetTimeout: options.resetTimeout || 30000,
      ...options
    };
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.lastFailureTime = null;
    this.nextAttemptTime = null;
    
    // Pour le suivi des métriques
    this.metrics = {
      calls: 0,
      failures: 0,
      successes: 0,
      rejects: 0,
      timeouts: 0
    };
  }

  async call(fn, ...args) {
    this.metrics.calls++;

    if (this.isOpen()) {
      this.metrics.rejects++;
      throw new Error('Circuit breaker is OPEN');
    }

    try {
      const result = await this.executeWithTimeout(fn, args);
      this.onSuccess();
      return result;
    } catch (error) {
      this.onError(error);
      throw error;
    }
  }

  async executeWithTimeout(fn, args) {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        this.metrics.timeouts++;
        reject(new Error('Operation timeout'));
      }, this.options.timeout);

      fn(...args)
        .then(result => {
          clearTimeout(timeoutId);
          resolve(result);
        })
        .catch(error => {
          clearTimeout(timeoutId);
          reject(error);
        });
    });
  }

  onSuccess() {
    this.metrics.successes++;
    this.failureCount = 0;
    this.state = 'CLOSED';
  }

  onError(error) {
    this.metrics.failures++;
    this.failureCount++;

    if (this.failureCount >= this.options.maxFailures) {
      this.open();
    }
  }

  open() {
    this.state = 'OPEN';
    this.nextAttemptTime = Date.now() + this.options.resetTimeout;
    this.lastFailureTime = Date.now();
  }

  isOpen() {
    if (this.state === 'OPEN') {
      if (Date.now() >= this.nextAttemptTime) {
        this.state = 'HALF_OPEN';
        return false; // Autoriser une tentative
      }
      return true;
    }
    return false;
  }

  attempt(fn, ...args) {
    if (this.state === 'HALF_OPEN') {
      return this.call(fn, ...args)
        .then(result => {
          this.state = 'CLOSED';
          this.failureCount = 0;
          return result;
        })
        .catch(error => {
          this.open(); // Ré-ouvrir le circuit
          throw error;
        });
    }
    
    return this.call(fn, ...args);
  }

  getMetrics() {
    const failureRate = this.metrics.calls > 0 
      ? (this.metrics.failures / this.metrics.calls) * 100 
      : 0;

    return {
      ...this.metrics,
      state: this.state,
      failureRate: parseFloat(failureRate.toFixed(2)),
      failureCount: this.failureCount,
      lastFailureTime: this.lastFailureTime
    };
  }

  reset() {
    this.state = 'CLOSED';
    this.failureCount = 0;
    this.lastFailureTime = null;
    this.nextAttemptTime = null;
    
    // Réinitialiser les métriques
    this.metrics = {
      calls: 0,
      failures: 0,
      successes: 0,
      rejects: 0,
      timeouts: 0
    };
  }
}

// Utilisation avec une API externe
class ExternalAPIClient {
  constructor() {
    this.circuitBreaker = new CircuitBreaker({
      timeout: 5000,
      maxFailures: 3,
      resetTimeout: 30000
    });
  }

  async fetchData(url) {
    return await this.circuitBreaker.attempt(async () => {
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.json();
    });
  }

  getMetrics() {
    return this.circuitBreaker.getMetrics();
  }
}

// Middleware pour le circuit breaker
const circuitBreakerMiddleware = (breaker) => {
  return (req, res, next) => {
    const originalSend = res.send;
    
    res.send = function(body) {
      // Enregistrer les métriques de réponse
      if (this.statusCode >= 500) {
        // Traiter comme une erreur pour le circuit breaker
        // Cela pourrait être fait dans un hook séparé
      }
      
      originalSend.call(this, body);
    };
    
    req.circuitBreaker = breaker;
    next();
  };
};
```

### 2. Modèle de limitation de débit (Rate Limiting)

#### Rate limiter avancé
```javascript
class AdvancedRateLimiter {
  constructor(options = {}) {
    this.options = {
      points: options.points || 10,      // Nombre de requêtes
      duration: options.duration || 60,  // Durée en secondes
      blockDuration: options.blockDuration || 300, // Blocage en secondes
      keyPrefix: options.keyPrefix || 'rl:',
      ...options
    };
    
    this.storage = options.storage || new InMemoryStorage();
    this.penalties = new Map(); // key -> penalty points
    this.blockedKeys = new Map(); // key -> unblock time
  }

  async consume(key, pointsToConsume = 1) {
    const now = Date.now();
    const key = `${this.options.keyPrefix}${identifier}`;
    
    // Vérifier si la clé est bloquée
    const blockUntil = this.blockedKeys.get(key);
    if (blockUntil && now < blockUntil) {
      throw new RateLimitError('Too Many Requests', 429, {
        retryAfter: Math.ceil((blockUntil - now) / 1000)
      });
    }

    // Calculer la fenêtre de temps
    const windowStart = now - (this.options.duration * 1000);
    
    // Obtenir l'historique des requêtes
    const requestHistory = await this.getHistory(key, windowStart);
    
    // Calculer les points consommés dans la fenêtre
    const consumedPoints = requestHistory.reduce((sum, req) => sum + req.points, 0);
    
    // Vérifier la limite
    if (consumedPoints + pointsToConsume > this.options.points) {
      // Appliquer une pénalité
      await this.applyPenalty(key);
      
      throw new RateLimitError('Too Many Requests', 429, {
        limit: this.options.points,
        remaining: Math.max(0, this.options.points - consumedPoints),
        resetTime: new Date(windowStart + (this.options.duration * 1000))
      });
    }

    // Enregistrer la requête
    await this.recordRequest(key, pointsToConsume, now);
    
    const remaining = this.options.points - (consumedPoints + pointsToConsume);
    
    return {
      consumedPoints: consumedPoints + pointsToConsume,
      remaining: remaining,
      resetTime: new Date(windowStart + (this.options.duration * 1000))
    };
  }

  async getHistory(key, windowStart) {
    const history = await this.storage.get(key) || [];
    return history.filter(req => req.timestamp >= windowStart);
  }

  async recordRequest(key, points, timestamp) {
    const request = { points, timestamp };
    const history = await this.getHistory(key, 0); // Toute l'histoire pour ce slot
    history.push(request);
    
    await this.storage.set(key, history, { ttl: this.options.duration + 60 });
  }

  async applyPenalty(key) {
    const currentPenalty = this.penalties.get(key) || 0;
    const newPenalty = Math.min(currentPenalty + 1, 10); // Max 10 points de pénalité
    
    this.penalties.set(key, newPenalty);
    
    // Si la pénalité est élevée, bloquer la clé
    if (newPenalty >= 5) {
      this.blockedKeys.set(key, Date.now() + (this.options.blockDuration * 1000));
      
      // Réinitialiser la pénalité après un certain temps
      setTimeout(() => {
        this.penalties.delete(key);
        this.blockedKeys.delete(key);
      }, this.options.blockDuration * 1000);
    }
  }

  // Rate limiting par utilisateur
  async consumeForUser(userId, endpoint, points = 1) {
    const key = `user:${userId}:${endpoint}`;
    return await this.consume(key, points);
  }

  // Rate limiting par IP
  async consumeForIP(ipAddress, endpoint, points = 1) {
    const key = `ip:${ipAddress}:${endpoint}`;
    return await this.consume(key, points);
  }

  // Rate limiting par endpoint
  async consumeForEndpoint(endpoint, points = 1) {
    const key = `endpoint:${endpoint}`;
    return await this.consume(key, points);
  }

  // Combiner plusieurs stratégies
  async consumeCombined(identifier, endpoint, points = 1) {
    const results = await Promise.allSettled([
      this.consumeForIP(identifier.ip, endpoint, points),
      this.consumeForUser(identifier.userId, endpoint, points),
      this.consumeForEndpoint(endpoint, points)
    ]);

    // Vérifier si l'une des limitations a été dépassée
    const rejected = results.find(result => result.status === 'rejected');
    
    if (rejected) {
      throw rejected.reason;
    }

    // Retourner le résultat avec le minimum de points restants
    const fulfilledResults = results
      .filter(result => result.status === 'fulfilled')
      .map(result => result.value);

    return {
      consumedPoints: fulfilledResults[0].consumedPoints,
      remaining: Math.min(...fulfilledResults.map(r => r.remaining)),
      resetTime: fulfilledResults[0].resetTime
    };
  }

  // Réinitialiser la limite pour une clé spécifique
  async reset(key) {
    await this.storage.delete(`${this.options.keyPrefix}${key}`);
    this.penalties.delete(key);
    this.blockedKeys.delete(key);
  }

  // Obtenir les statistiques
  async getStats(key) {
    const history = await this.getHistory(key, Date.now() - (this.options.duration * 1000));
    const totalPoints = history.reduce((sum, req) => sum + req.points, 0);
    
    return {
      currentUsage: totalPoints,
      limit: this.options.points,
      remaining: Math.max(0, this.options.points - totalPoints),
      windowDuration: this.options.duration,
      penalty: this.penalties.get(key) || 0,
      isBlocked: !!this.blockedKeys.get(key)
    };
  }
}

// Stockage en mémoire (peut être remplacé par Redis, etc.)
class InMemoryStorage {
  constructor() {
    this.data = new Map();
    this.ttls = new Map();
  }

  async get(key) {
    const ttl = this.ttls.get(key);
    if (ttl && Date.now() > ttl) {
      await this.delete(key);
      return null;
    }
    return this.data.get(key) || null;
  }

  async set(key, value, options = {}) {
    this.data.set(key, value);
    if (options.ttl) {
      this.ttls.set(key, Date.now() + options.ttl * 1000);
    }
  }

  async delete(key) {
    this.data.delete(key);
    this.ttls.delete(key);
  }
}

// Erreur spécifique pour le rate limiting
class RateLimitError extends Error {
  constructor(message, statusCode, details = {}) {
    super(message);
    this.name = 'RateLimitError';
    this.statusCode = statusCode;
    this.details = details;
  }
}

// Middleware Express
const rateLimitMiddleware = (rateLimiter, options = {}) => {
  return async (req, res, next) => {
    try {
      const identifier = options.identifier || req.ip;
      const endpoint = req.route?.path || req.path;
      const points = options.points || 1;

      await rateLimiter.consumeCombined(
        { 
          ip: req.ip, 
          userId: req.user?.id 
        },
        endpoint,
        points
      );

      // Ajouter les headers de rate limiting
      const stats = await rateLimiter.getStats(`${req.ip}:${endpoint}`);
      
      res.setHeader('X-RateLimit-Limit', stats.limit);
      res.setHeader('X-RateLimit-Remaining', stats.remaining);
      res.setHeader('X-RateLimit-Reset', stats.resetTime?.toISOString());

      next();
    } catch (error) {
      if (error instanceof RateLimitError) {
        res.status(error.statusCode).json({
          error: 'Too Many Requests',
          message: error.message,
          ...error.details
        });
      } else {
        next(error);
      }
    }
  };
};

// Utilisation
const rateLimiter = new AdvancedRateLimiter({
  points: 100,
  duration: 60, // 100 requêtes par minute
  blockDuration: 300 // 5 minutes de blocage
});

app.use('/api/', rateLimitMiddleware(rateLimiter, {
  identifier: (req) => req.user?.id || req.ip,
  points: 1
}));
```

## Modèles de surveillance de performance

### 1. Système de métriques

#### Collecte de métriques avancées
```javascript
class PerformanceMetrics {
  constructor(options = {}) {
    this.metrics = new Map();
    this.aggregators = new Map();
    this.exporters = options.exporters || [];
    this.reportingInterval = options.reportingInterval || 30000; // 30 secondes
    this.maxMetrics = options.maxMetrics || 10000;
    
    this.startReporting();
  }

  // Métriques de compteur
  increment(metricName, value = 1, labels = {}) {
    const key = this.generateMetricKey(metricName, labels);
    
    if (!this.metrics.has(key)) {
      this.metrics.set(key, {
        type: 'counter',
        value: 0,
        labels,
        timestamp: Date.now()
      });
    }
    
    const metric = this.metrics.get(key);
    metric.value += value;
    metric.timestamp = Date.now();
    
    this.runAggregators(metricName, metric);
  }

  // Métriques de gauge
  setGauge(metricName, value, labels = {}) {
    const key = this.generateMetricKey(metricName, labels);
    
    this.metrics.set(key, {
      type: 'gauge',
      value,
      labels,
      timestamp: Date.now()
    });
    
    this.runAggregators(metricName, this.metrics.get(key));
  }

  // Métriques d'histogramme
  recordHistogram(metricName, value, labels = {}, buckets = [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]) {
    const key = this.generateMetricKey(metricName, labels);
    
    if (!this.metrics.has(key)) {
      this.metrics.set(key, {
        type: 'histogram',
        count: 0,
        sum: 0,
        buckets: buckets.map(bucket => ({ upperBound: bucket, count: 0 })),
        labels,
        timestamp: Date.now()
      });
    }
    
    const histogram = this.metrics.get(key);
    histogram.count++;
    histogram.sum += value;
    
    // Mettre à jour les buckets
    for (const bucket of histogram.buckets) {
      if (value <= bucket.upperBound) {
        bucket.count++;
      }
    }
    
    histogram.timestamp = Date.now();
    this.runAggregators(metricName, histogram);
  }

  // Métriques de timer
  async time(metricName, fn, labels = {}) {
    const startTime = process.hrtime.bigint();
    
    try {
      const result = await fn();
      const endTime = process.hrtime.bigint();
      const duration = Number(endTime - startTime) / 1000000; // en ms
      
      this.recordHistogram(`${metricName}_duration`, duration, labels);
      return result;
    } catch (error) {
      this.increment(`${metricName}_errors`, 1, labels);
      throw error;
    }
  }

  generateMetricKey(name, labels) {
    const labelStr = Object.entries(labels)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, value]) => `${key}="${value}"`)
      .join(',');
    
    return `${name}{${labelStr}}`;
  }

  // Agrégateurs pour les calculs avancés
  addAggregator(metricName, aggregatorFn) {
    if (!this.aggregators.has(metricName)) {
      this.aggregators.set(metricName, []);
    }
    this.aggregators.get(metricName).push(aggregatorFn);
  }

  runAggregators(metricName, metric) {
    const aggregators = this.aggregators.get(metricName) || [];
    
    for (const aggregator of aggregators) {
      try {
        aggregator(metric, this.metrics);
      } catch (error) {
        console.error('Erreur dans l\'agrégateur:', error);
      }
    }
  }

  // Agrégateur pour les percentiles
  addPercentileAggregator(metricName, percentile, label) {
    this.addAggregator(`${metricName}_histogram`, (metric) => {
      if (metric.type === 'histogram') {
        const percentileValue = this.calculatePercentile(metric, percentile);
        this.setGauge(`${metricName}_p${percentile}`, percentileValue, {
          ...metric.labels,
          percentile: `${percentile}th`
        });
      }
    });
  }

  calculatePercentile(histogram, percentile) {
    const totalCount = histogram.count;
    const targetCount = totalCount * (percentile / 100);
    
    let currentCount = 0;
    for (const bucket of histogram.buckets) {
      currentCount += bucket.count;
      if (currentCount >= targetCount) {
        return bucket.upperBound;
      }
    }
    
    return histogram.buckets[histogram.buckets.length - 1].upperBound;
  }

  // Agrégateur pour les taux
  addRateAggregator(metricName, windowMs = 60000) {
    const rateData = new Map();
    
    this.addAggregator(metricName, (metric) => {
      const key = this.generateMetricKey(metricName, metric.labels);
      const now = Date.now();
      
      if (!rateData.has(key)) {
        rateData.set(key, []);
      }
      
      const history = rateData.get(key);
      history.push({ timestamp: now, value: metric.value });
      
      // Nettoyer les anciennes valeurs
      const cutoff = now - windowMs;
      const cleanedHistory = history.filter(entry => entry.timestamp > cutoff);
      rateData.set(key, cleanedHistory);
      
      // Calculer le taux
      if (cleanedHistory.length > 1) {
        const duration = (cleanedHistory[cleanedHistory.length - 1].timestamp - cleanedHistory[0].timestamp) / 1000; // en secondes
        const totalValue = cleanedHistory.reduce((sum, entry) => sum + entry.value, 0);
        const rate = duration > 0 ? totalValue / duration : 0;
        
        this.setGauge(`${metricName}_rate_per_second`, rate, metric.labels);
      }
    });
  }

  startReporting() {
    this.reportingTimer = setInterval(() => {
      this.reportMetrics();
    }, this.reportingInterval);
  }

  async reportMetrics() {
    const metricsSnapshot = Array.from(this.metrics.values());
    
    // Calculer des métriques dérivées
    const derivedMetrics = this.calculateDerivedMetrics(metricsSnapshot);
    
    // Exporter vers tous les exporters
    for (const exporter of this.exporters) {
      try {
        await exporter.export([...metricsSnapshot, ...derivedMetrics]);
      } catch (error) {
        console.error('Erreur d\'exportation des métriques:', error);
      }
    }
  }

  calculateDerivedMetrics(metrics) {
    const derived = [];
    
    // Calculer des taux d'erreur
    const errorMetrics = metrics.filter(m => m.type === 'counter' && m.labels?.type === 'error');
    const totalMetrics = metrics.filter(m => m.type === 'counter' && m.labels?.type === 'request');
    
    if (errorMetrics.length > 0 && totalMetrics.length > 0) {
      const totalErrors = errorMetrics.reduce((sum, m) => sum + m.value, 0);
      const totalRequests = totalMetrics.reduce((sum, m) => sum + m.value, 0);
      const errorRate = totalRequests > 0 ? (totalErrors / totalRequests) * 100 : 0;
      
      derived.push({
        name: 'error_rate_percent',
        type: 'gauge',
        value: errorRate,
        labels: { type: 'overall' },
        timestamp: Date.now()
      });
    }
    
    return derived;
  }

  // Obtenir les métriques formatées pour l'exportation
  getMetricsForExport() {
    return Array.from(this.metrics.entries()).map(([key, metric]) => ({
      key,
      ...metric
    }));
  }

  // Réinitialiser les métriques
  reset() {
    this.metrics.clear();
  }

  // Nettoyer
  async close() {
    if (this.reportingTimer) {
      clearInterval(this.reportingTimer);
    }
    
    // Exporter les dernières métriques
    await this.reportMetrics();
  }
}

// Exporter vers Prometheus
class PrometheusExporter {
  constructor(options = {}) {
    this.prefix = options.prefix || 'app_';
    this.port = options.port || 9090;
  }

  async export(metrics) {
    const prometheusMetrics = this.convertToPrometheusFormat(metrics);
    
    // Ici, vous enverriez les métriques à votre serveur Prometheus
    // ou les écririez dans un endpoint /metrics
    console.log('Métriques Prometheus:', prometheusMetrics);
  }

  convertToPrometheusFormat(metrics) {
    let output = '';
    
    for (const metric of metrics) {
      const name = `${this.prefix}${metric.name}`;
      
      if (metric.type === 'counter') {
        output += `# TYPE ${name} counter\n`;
        output += `${name}{${this.formatLabels(metric.labels)}} ${metric.value}\n`;
      } else if (metric.type === 'gauge') {
        output += `# TYPE ${name} gauge\n`;
        output += `${name}{${this.formatLabels(metric.labels)}} ${metric.value}\n`;
      } else if (metric.type === 'histogram') {
        output += `# TYPE ${name} histogram\n`;
        output += `${name}_count{${this.formatLabels(metric.labels)}} ${metric.count}\n`;
        output += `${name}_sum{${this.formatLabels(metric.labels)}} ${metric.sum}\n`;
        
        let cumulativeCount = 0;
        for (const bucket of metric.buckets) {
          cumulativeCount += bucket.count;
          output += `${name}_bucket{${this.formatLabels(metric.labels)},le="${bucket.upperBound}"} ${cumulativeCount}\n`;
        }
        output += `${name}_bucket{${this.formatLabels(metric.labels)},le="+Inf"} ${cumulativeCount}\n`;
      }
    }
    
    return output;
  }

  formatLabels(labels) {
    return Object.entries(labels)
      .map(([key, value]) => `${key}="${value}"`)
      .join(',');
  }
}

// Utilisation
const metrics = new PerformanceMetrics({
  exporters: [new PrometheusExporter()],
  reportingInterval: 15000
});

// Ajouter des agrégateurs
metrics.addPercentileAggregator('api_response_time', 95);
metrics.addRateAggregator('api_requests_total');

// Utilisation dans une application
app.use(async (req, res, next) => {
  const startTime = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    
    metrics.increment('api_requests_total', 1, {
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode.toString()
    });
    
    metrics.recordHistogram('api_response_time', duration, {
      method: req.method,
      route: req.route?.path || req.path
    });
    
    if (res.statusCode >= 500) {
      metrics.increment('api_errors_total', 1, {
        method: req.method,
        route: req.route?.path || req.path,
        error_type: 'server_error'
      });
    }
  });
  
  next();
});
```

### 2. Modèle de profiling

#### Profiling des performances
```javascript
class PerformanceProfiler {
  constructor(options = {}) {
    this.profiles = new Map();
    this.activeProfiles = new Set();
    this.options = {
      enabled: options.enabled !== false,
      samplingInterval: options.samplingInterval || 10, // ms
      maxProfiles: options.maxProfiles || 100,
      ...options
    };
  }

  start(profileName, metadata = {}) {
    if (!this.options.enabled) return null;
    
    const profileId = `${profileName}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    this.profiles.set(profileId, {
      id: profileId,
      name: profileName,
      metadata,
      startTime: process.hrtime.bigint(),
      samples: [],
      active: true,
      createdAt: new Date().toISOString()
    });
    
    this.activeProfiles.add(profileId);
    
    // Démarrer l'échantillonnage
    if (this.options.samplingInterval > 0) {
      this.startSampling(profileId);
    }
    
    return profileId;
  }

  stop(profileId) {
    if (!this.options.enabled) return null;
    
    const profile = this.profiles.get(profileId);
    if (!profile || !profile.active) {
      return null;
    }
    
    profile.endTime = process.hrtime.bigint();
    profile.duration = Number(profile.endTime - profile.startTime) / 1000000; // en ms
    profile.active = false;
    this.activeProfiles.delete(profileId);
    
    return this.analyzeProfile(profile);
  }

  startSampling(profileId) {
    const sampleInterval = setInterval(() => {
      const profile = this.profiles.get(profileId);
      if (!profile || !profile.active) {
        clearInterval(sampleInterval);
        return;
      }
      
      // Collecter des échantillons de performance
      const sample = {
        timestamp: process.hrtime.bigint(),
        memory: process.memoryUsage(),
        cpu: process.cpuUsage ? process.cpuUsage() : null,
        eventLoopLag: this.getEventLoopLag()
      };
      
      profile.samples.push(sample);
      
      // Limiter la taille des échantillons
      if (profile.samples.length > 10000) {
        profile.samples = profile.samples.slice(-5000); // Garder les 5000 derniers
      }
    }, this.options.samplingInterval);
    
    // Stocker l'intervalle pour pouvoir l'arrêter
    const profile = this.profiles.get(profileId);
    profile.sampleInterval = sampleInterval;
  }

  getEventLoopLag() {
    const start = process.hrtime.bigint();
    setImmediate(() => {});
    return process.hrtime.bigint() - start;
  }

  analyzeProfile(profile) {
    if (!profile.samples || profile.samples.length === 0) {
      return {
        ...profile,
        analysis: {
          avgMemoryUsage: null,
          peakMemoryUsage: null,
          avgCPUsage: null,
          avgEventLoopLag: null,
          samplesCount: 0
        }
      };
    }
    
    const memorySamples = profile.samples.map(s => s.memory.heapUsed);
    const cpuSamples = profile.samples.filter(s => s.cpu).map(s => s.cpu);
    const lagSamples = profile.samples.map(s => s.eventLoopLag);
    
    const analysis = {
      avgMemoryUsage: memorySamples.reduce((a, b) => a + b, 0) / memorySamples.length,
      peakMemoryUsage: Math.max(...memorySamples),
      avgCPUsage: cpuSamples.length > 0 
        ? {
            user: cpuSamples.reduce((sum, cpu) => sum + cpu.user, 0) / cpuSamples.length,
            system: cpuSamples.reduce((sum, cpu) => sum + cpu.system, 0) / cpuSamples.length
          }
        : null,
      avgEventLoopLag: lagSamples.reduce((a, b) => a + b, 0n) / BigInt(lagSamples.length),
      samplesCount: profile.samples.length,
      memoryGrowthRate: this.calculateMemoryGrowthRate(memorySamples)
    };
    
    return {
      ...profile,
      analysis
    };
  }

  calculateMemoryGrowthRate(samples) {
    if (samples.length < 2) return 0;
    
    const first = samples[0];
    const last = samples[samples.length - 1];
    return ((last - first) / first) * 100;
  }

  // Profiling d'une fonction spécifique
  async profileFunction(fn, profileName, metadata = {}) {
    if (!this.options.enabled) {
      return await fn();
    }
    
    const profileId = this.start(profileName, metadata);
    let result, error;
    
    try {
      result = await fn();
    } catch (err) {
      error = err;
    }
    
    const profile = this.stop(profileId);
    
    // Logguer les résultats
    if (profile) {
      console.log(`Profile ${profileName}: ${profile.duration.toFixed(2)}ms`);
      console.log(`Memory: ${(profile.analysis.avgMemoryUsage / 1024 / 1024).toFixed(2)}MB avg`);
    }
    
    if (error) throw error;
    return result;
  }

  // Profiling d'une section de code
  profileSection(sectionName, fn, metadata = {}) {
    if (!this.options.enabled) {
      return fn();
    }
    
    const profileId = this.start(sectionName, metadata);
    let result, error;
    
    try {
      result = fn();
    } catch (err) {
      error = err;
    }
    
    const profile = this.stop(profileId);
    
    if (profile && !profile.active) {
      console.log(`Section ${sectionName}: ${profile.duration.toFixed(2)}ms`);
    }
    
    if (error) throw error;
    return result;
  }

  // Obtenir des rapports de performance
  getReports(filter = {}) {
    const profiles = Array.from(this.profiles.values());
    
    if (filter.name) {
      profiles = profiles.filter(p => p.name === filter.name);
    }
    
    if (filter.dateRange) {
      const [start, end] = filter.dateRange;
      profiles = profiles.filter(p => {
        const profileDate = new Date(p.createdAt);
        return profileDate >= start && profileDate <= end;
      });
    }
    
    return profiles.map(profile => this.analyzeProfile(profile));
  }

  // Nettoyer les anciens profils
  cleanup(maxAge = 3600000) { // 1 heure par défaut
    const now = Date.now();
    const profiles = Array.from(this.profiles.entries());
    
    for (const [id, profile] of profiles) {
      const profileAge = now - new Date(profile.createdAt).getTime();
      
      if (profileAge > maxAge) {
        this.profiles.delete(id);
      }
    }
  }

  // Obtenir des statistiques
  getStats() {
    const profiles = Array.from(this.profiles.values());
    const completedProfiles = profiles.filter(p => !p.active);
    
    return {
      totalProfiles: profiles.length,
      activeProfiles: this.activeProfiles.size,
      completedProfiles: completedProfiles.length,
      avgDuration: completedProfiles.length > 0
        ? completedProfiles.reduce((sum, p) => sum + p.duration, 0) / completedProfiles.length
        : 0,
      totalDuration: completedProfiles.reduce((sum, p) => sum + p.duration, 0)
    };
  }

  // Arrêter tous les profils actifs
  stopAll() {
    for (const profileId of this.activeProfiles) {
      this.stop(profileId);
    }
  }
}

// Utilisation
const profiler = new PerformanceProfiler({
  enabled: process.env.NODE_ENV === 'development',
  samplingInterval: 50
});

// Profiling d'une API
app.get('/api/expensive-operation', async (req, res) => {
  const result = await profiler.profileFunction(async () => {
    // Opération coûteuse
    await new Promise(resolve => setTimeout(resolve, 1000));
    return { data: 'result' };
  }, 'expensive_api_call', {
    userId: req.user?.id,
    endpoint: req.path
  });
  
  res.json(result);
});

// Profiling d'une section spécifique
function processData(data) {
  return profiler.profileSection('data_processing', () => {
    // Traitement des données
    return data.map(item => ({
      ...item,
      processed: true
    }));
  }, { dataSize: data.length });
}
```

Ces modèles de performance fournissent des approches complètes pour optimiser les applications, avec des techniques pour la gestion d'état, le chargement des données, la sécurité, la surveillance et le profiling des performances. Ils permettent de créer des applications rapides, évolutives et maintenables.