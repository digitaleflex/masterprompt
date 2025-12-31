# Modèles de gestion d'état

## Description
Ce document présente des modèles et des patrons de conception pour la gestion d'état dans les applications modernes, avec des exemples concrets pour différents types d'applications et frameworks.

## Principes fondamentaux

### 1. Concepts de base de la gestion d'état

#### Types d'état
- **Local State** : État spécifique à un composant
- **Session State** : État persistant pendant la session utilisateur
- **Global State** : État partagé entre plusieurs composants
- **Persistent State** : État sauvegardé durablement
- **Server State** : État stocké côté serveur

#### Caractéristiques d'un bon système d'état
- **Prédictible** : Les modifications sont déterministes
- **Immuabilité** : L'état ne change pas directement
- **Traçabilité** : Historique des modifications
- **Performant** : Mise à jour efficace
- **Sérialisable** : Peut être sauvegardé/restauré

### 2. Modèle d'état immuable

#### Immutabilité avec des objets
```javascript
// Mauvais exemple - mutation directe
const state = { count: 0, user: { name: 'John' } };
state.count = 1; // Mutation directe
state.user.name = 'Jane'; // Mutation directe

// Bon exemple - création d'un nouvel objet
const newState = {
  ...state,
  count: state.count + 1,
  user: {
    ...state.user,
    name: 'Jane'
  }
};

// Utilisation de fonctions utilitaires
const updateState = (prevState, updates) => ({
  ...prevState,
  ...updates
});

const updateNestedState = (prevState, path, value) => {
  const [first, ...rest] = path;
  
  if (rest.length === 0) {
    return {
      ...prevState,
      [first]: value
    };
  }
  
  return {
    ...prevState,
    [first]: updateNestedState(prevState[first], rest, value)
  };
};

// Exemple d'utilisation
const initialState = {
  user: {
    profile: {
      name: 'John',
      age: 30
    },
    settings: {
      theme: 'light'
    }
  }
};

const updatedState = updateNestedState(
  initialState,
  ['user', 'profile', 'name'],
  'Jane'
);
```

#### Immutabilité avec des tableaux
```javascript
// Opérations immuables sur les tableaux
const immutableArrayOperations = {
  // Ajouter un élément
  add: (array, item) => [...array, item],
  
  // Insérer à un index spécifique
  insertAt: (array, index, item) => [
    ...array.slice(0, index),
    item,
    ...array.slice(index)
  ],
  
  // Supprimer par index
  removeAt: (array, index) => [
    ...array.slice(0, index),
    ...array.slice(index + 1)
  ],
  
  // Supprimer par valeur
  remove: (array, itemToRemove) => 
    array.filter(item => item !== itemToRemove),
  
  // Supprimer par condition
  removeWhere: (array, predicate) => 
    array.filter(item => !predicate(item)),
  
  // Mettre à jour un élément
  update: (array, index, newItem) => [
    ...array.slice(0, index),
    newItem,
    ...array.slice(index + 1)
  ],
  
  // Mettre à jour avec une fonction
  updateWhere: (array, predicate, updater) =>
    array.map(item => predicate(item) ? updater(item) : item),
  
  // Déplacer un élément
  move: (array, fromIndex, toIndex) => {
    const result = [...array];
    const [removed] = result.splice(fromIndex, 1);
    result.splice(toIndex, 0, removed);
    return result;
  }
};

// Exemple d'utilisation
const todos = [
  { id: 1, text: 'Faire les courses', completed: false },
  { id: 2, text: 'Appeler le médecin', completed: true }
];

const newTodos = immutableArrayOperations.add(todos, {
  id: 3,
  text: 'Réunion d\'équipe',
  completed: false
});
```

## Modèles de gestion d'état avancés

### 1. Modèle Flux/Redux

#### Architecture Redux
```javascript
// Définition des actions
const ActionTypes = {
  USER_LOGIN: 'USER_LOGIN',
  USER_LOGOUT: 'USER_LOGOUT',
  USER_UPDATE_PROFILE: 'USER_UPDATE_PROFILE',
  TODO_ADD: 'TODO_ADD',
  TODO_TOGGLE: 'TODO_TOGGLE',
  TODO_REMOVE: 'TODO_REMOVE'
};

// Actions creators
const userLogin = (userData) => ({
  type: ActionTypes.USER_LOGIN,
  payload: userData
});

const userLogout = () => ({
  type: ActionTypes.USER_LOGOUT
});

const addTodo = (text) => ({
  type: ActionTypes.TODO_ADD,
  payload: { id: Date.now(), text, completed: false }
});

const toggleTodo = (id) => ({
  type: ActionTypes.TODO_TOGGLE,
  payload: { id }
});

// Reducers
const userReducer = (state = null, action) => {
  switch (action.type) {
    case ActionTypes.USER_LOGIN:
      return action.payload;
    case ActionTypes.USER_LOGOUT:
      return null;
    case ActionTypes.USER_UPDATE_PROFILE:
      return { ...state, ...action.payload };
    default:
      return state;
  }
};

const todosReducer = (state = [], action) => {
  switch (action.type) {
    case ActionTypes.TODO_ADD:
      return [...state, action.payload];
    case ActionTypes.TODO_TOGGLE:
      return state.map(todo =>
        todo.id === action.payload.id
          ? { ...todo, completed: !todo.completed }
          : todo
      );
    case ActionTypes.TODO_REMOVE:
      return state.filter(todo => todo.id !== action.payload.id);
    default:
      return state;
  }
};

// Root reducer
const rootReducer = (state = {}, action) => ({
  user: userReducer(state.user, action),
  todos: todosReducer(state.todos, action)
});

// Store
class Store {
  constructor(reducer, initialState = {}) {
    this.reducer = reducer;
    this.state = initialState;
    this.listeners = [];
  }

  getState() {
    return this.state;
  }

  dispatch(action) {
    this.state = this.reducer(this.state, action);
    this.listeners.forEach(listener => listener());
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
}

// Utilisation
const store = new Store(rootReducer);

store.subscribe(() => {
  console.log('État mis à jour:', store.getState());
});

store.dispatch(userLogin({ id: 1, name: 'John' }));
store.dispatch(addTodo('Apprendre Redux'));
store.dispatch(toggleTodo(Date.now()));
```

#### Middleware Redux
```javascript
// Middleware pour les effets secondaires
const createThunkMiddleware = () => {
  return ({ dispatch, getState }) => next => action => {
    if (typeof action === 'function') {
      return action(dispatch, getState);
    }
    return next(action);
  };
};

// Middleware pour le logging
const loggerMiddleware = ({ getState }) => next => action => {
  console.group(`Action: ${action.type}`);
  console.log('%c Previous state', 'color: #9E9E9E; font-weight: bold;', getState());
  console.log('%c Action', 'color: #008800; font-weight: bold;', action);
  
  const result = next(action);
  
  console.log('%c Next state', 'color: #47B04B; font-weight: bold;', getState());
  console.groupEnd();
  
  return result;
};

// Middleware pour les appels API
const apiMiddleware = ({ dispatch }) => next => action => {
  if (action.type.endsWith('_REQUEST')) {
    // Effectuer l'appel API
    return fetch(action.endpoint, {
      method: action.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...action.headers
      },
      body: action.body ? JSON.stringify(action.body) : undefined
    })
    .then(response => response.json())
    .then(data => {
      dispatch({
        type: action.type.replace('_REQUEST', '_SUCCESS'),
        payload: data
      });
      return data;
    })
    .catch(error => {
      dispatch({
        type: action.type.replace('_REQUEST', '_FAILURE'),
        payload: error.message
      });
      throw error;
    });
  }
  
  return next(action);
};
```

### 2. Modèle Contexte React

#### Contexte avec réduction d'état
```jsx
import React, { createContext, useContext, useReducer, useMemo } from 'react';

// Contexte pour l'authentification
const AuthContext = createContext();

// Reducer pour l'authentification
const authReducer = (state, action) => {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, loading: true, error: null };
    case 'LOGIN_SUCCESS':
      return { 
        ...state, 
        user: action.payload.user,
        token: action.payload.token,
        loading: false,
        authenticated: true
      };
    case 'LOGIN_FAILURE':
      return { 
        ...state, 
        loading: false, 
        error: action.payload.error,
        authenticated: false
      };
    case 'LOGOUT':
      return { 
        ...state, 
        user: null, 
        token: null, 
        authenticated: false,
        loading: false
      };
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    default:
      return state;
  }
};

// Provider
export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, {
    user: null,
    token: null,
    authenticated: false,
    loading: false,
    error: null
  });

  // Actions
  const login = async (credentials) => {
    dispatch({ type: 'LOGIN_START' });
    
    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials)
      });
      
      const data = await response.json();
      
      if (data.success) {
        localStorage.setItem('token', data.token);
        dispatch({
          type: 'LOGIN_SUCCESS',
          payload: {
            user: data.user,
            token: data.token
          }
        });
      } else {
        dispatch({
          type: 'LOGIN_FAILURE',
          payload: { error: data.message }
        });
      }
    } catch (error) {
      dispatch({
        type: 'LOGIN_FAILURE',
        payload: { error: error.message }
      });
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    dispatch({ type: 'LOGOUT' });
  };

  const value = useMemo(() => ({
    ...state,
    login,
    logout
  }), [state]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

// Hook personnalisé
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

// Utilisation
const App = () => (
  <AuthProvider>
    <Router>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard" element={
          <ProtectedRoute>
            <DashboardPage />
          </ProtectedRoute>
        } />
      </Routes>
    </Router>
  </AuthProvider>
);

const LoginPage = () => {
  const { login, loading, error } = useAuth();
  const [credentials, setCredentials] = useState({ email: '', password: '' });

  const handleSubmit = (e) => {
    e.preventDefault();
    login(credentials);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={credentials.email}
        onChange={(e) => setCredentials({...credentials, email: e.target.value})}
        placeholder="Email"
      />
      <input
        type="password"
        value={credentials.password}
        onChange={(e) => setCredentials({...credentials, password: e.target.value})}
        placeholder="Mot de passe"
      />
      <button type="submit" disabled={loading}>
        {loading ? 'Connexion...' : 'Se connecter'}
      </button>
      {error && <div className="error">{error}</div>}
    </form>
  );
};
```

### 3. Modèle de gestion d'état avec Zustand

#### Store Zustand
```javascript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

// Store d'utilisateur
const useUserStore = create(
  devtools(
    persist(
      (set, get) => ({
        // État
        user: null,
        loading: false,
        error: null,
        
        // Actions
        login: async (credentials) => {
          set({ loading: true, error: null });
          
          try {
            const response = await fetch('/api/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(credentials)
            });
            
            const data = await response.json();
            
            if (data.success) {
              set({ user: data.user, loading: false });
              localStorage.setItem('token', data.token);
            } else {
              set({ error: data.message, loading: false });
            }
          } catch (error) {
            set({ error: error.message, loading: false });
          }
        },
        
        logout: () => {
          set({ user: null });
          localStorage.removeItem('token');
        },
        
        updateUser: (updates) => {
          set((state) => ({
            user: state.user ? { ...state.user, ...updates } : null
          }));
        },
        
        // Calculateurs
        isAdmin: () => {
          const user = get().user;
          return user && user.role === 'admin';
        },
        
        hasPermission: (permission) => {
          const user = get().user;
          return user && user.permissions?.includes(permission);
        }
      }),
      {
        name: 'user-storage', // Nom pour le stockage persistant
        partialize: (state) => ({ user: state.user }) // Stocker seulement l'utilisateur
      }
    )
  )
);

// Store de panier
const useCartStore = create(
  (set, get) => ({
    items: [],
    total: 0,
    
    addItem: (product) => {
      const currentItems = get().items;
      const existingItem = currentItems.find(item => item.id === product.id);
      
      if (existingItem) {
        set({
          items: currentItems.map(item =>
            item.id === product.id
              ? { ...item, quantity: item.quantity + 1 }
              : item
          )
        });
      } else {
        set({
          items: [...currentItems, { ...product, quantity: 1 }]
        });
      }
      
      get().calculateTotal();
    },
    
    removeItem: (productId) => {
      set({
        items: get().items.filter(item => item.id !== productId)
      });
      get().calculateTotal();
    },
    
    updateQuantity: (productId, quantity) => {
      if (quantity <= 0) {
        get().removeItem(productId);
        return;
      }
      
      set({
        items: get().items.map(item =>
          item.id === productId
            ? { ...item, quantity }
            : item
        )
      });
      get().calculateTotal();
    },
    
    calculateTotal: () => {
      const total = get().items.reduce((sum, item) => {
        return sum + (item.price * item.quantity);
      }, 0);
      
      set({ total });
    },
    
    clearCart: () => set({ items: [], total: 0 })
  })
);

// Utilisation
const ProductCard = ({ product }) => {
  const addItem = useCartStore(state => state.addItem);
  const hasItem = useCartStore(state => 
    state.items.some(item => item.id === product.id)
  );
  
  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>{product.price}€</p>
      <button 
        onClick={() => addItem(product)}
        disabled={hasItem}
      >
        {hasItem ? 'Dans le panier' : 'Ajouter au panier'}
      </button>
    </div>
  );
};

const CartSummary = () => {
  const items = useCartStore(state => state.items);
  const total = useCartStore(state => state.total);
  
  return (
    <div className="cart-summary">
      <h3>Panier ({items.length} articles)</h3>
      <p>Total: {total}€</p>
    </div>
  );
};
```

## Modèles de gestion d'état asynchrone

### 1. Modèle de gestion d'état avec charges utiles

#### Gestion des états de chargement
```javascript
// Modèle d'état asynchrone
class AsyncState {
  constructor(initialData = null) {
    this.data = initialData;
    this.loading = false;
    this.error = null;
    this.timestamp = null;
  }

  static create() {
    return new AsyncState();
  }

  start() {
    this.loading = true;
    this.error = null;
    return this;
  }

  success(data) {
    this.loading = false;
    this.error = null;
    this.data = data;
    this.timestamp = new Date();
    return this;
  }

  failure(error) {
    this.loading = false;
    this.error = error;
    return this;
  }

  reset() {
    this.data = null;
    this.loading = false;
    this.error = null;
    this.timestamp = null;
    return this;
  }

  isLoading() {
    return this.loading;
  }

  hasError() {
    return this.error !== null;
  }

  hasData() {
    return this.data !== null;
  }

  isStale(maxAge = 5 * 60 * 1000) { // 5 minutes par défaut
    if (!this.timestamp) return true;
    return Date.now() - this.timestamp.getTime() > maxAge;
  }
}

// Hook React pour l'état asynchrone
const useAsyncState = (initialData = null) => {
  const [state, setState] = useState(() => new AsyncState(initialData));

  const start = useCallback(() => {
    setState(prev => prev.start());
  }, []);

  const success = useCallback((data) => {
    setState(prev => prev.success(data));
  }, []);

  const failure = useCallback((error) => {
    setState(prev => prev.failure(error));
  }, []);

  const reset = useCallback(() => {
    setState(prev => prev.reset());
  }, []);

  return {
    state,
    start,
    success,
    failure,
    reset
  };
};

// Service avec gestion d'état
class DataService {
  constructor(baseURL) {
    this.baseURL = baseURL;
    this.cache = new Map();
    this.activeRequests = new Map();
  }

  async fetchWithState(url, options = {}) {
    const cacheKey = `${url}_${JSON.stringify(options)}`;
    
    // Vérifier le cache
    if (this.cache.has(cacheKey)) {
      const cached = this.cache.get(cacheKey);
      if (!cached.state.isStale(options.maxAge)) {
        return cached;
      }
    }

    // Vérifier si une requête est déjà en cours
    if (this.activeRequests.has(cacheKey)) {
      return await this.activeRequests.get(cacheKey);
    }

    // Créer une nouvelle requête
    const requestPromise = this.makeRequest(url, options, cacheKey);
    this.activeRequests.set(cacheKey, requestPromise);

    try {
      const result = await requestPromise;
      return result;
    } finally {
      this.activeRequests.delete(cacheKey);
    }
  }

  async makeRequest(url, options, cacheKey) {
    const state = new AsyncState();
    state.start();

    try {
      const response = await fetch(`${this.baseURL}${url}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      state.success(data);

      // Mettre en cache
      this.cache.set(cacheKey, { ...state });
      
      return { ...state };
    } catch (error) {
      state.failure(error.message);
      return { ...state };
    }
  }

  invalidateCache(pattern) {
    for (const key of this.cache.keys()) {
      if (key.includes(pattern)) {
        this.cache.delete(key);
      }
    }
  }
}

// Utilisation dans un composant
const UserProfile = ({ userId }) => {
  const [userState, setUserState] = useState(() => new AsyncState());
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  useEffect(() => {
    const fetchUser = async () => {
      setUserState(prev => prev.start());
      
      try {
        const response = await fetch(`/api/users/${userId}`);
        const userData = await response.json();
        
        setUserState(prev => prev.success(userData));
      } catch (error) {
        setUserState(prev => prev.failure(error.message));
      }
    };

    fetchUser();
  }, [userId, refreshTrigger]);

  if (userState.isLoading()) {
    return <div>Chargement...</div>;
  }

  if (userState.hasError()) {
    return (
      <div>
        <p>Erreur: {userState.error}</p>
        <button onClick={() => setRefreshTrigger(prev => prev + 1)}>
          Réessayer
        </button>
      </div>
    );
  }

  if (!userState.hasData()) {
    return <div>Aucune donnée</div>;
  }

  return (
    <div>
      <h1>{userState.data.name}</h1>
      <p>{userState.data.email}</p>
      <button onClick={() => setRefreshTrigger(prev => prev + 1)}>
        Actualiser
      </button>
    </div>
  );
};
```

### 2. Modèle de machine à états (State Machine)

#### Machine à états avec XState
```javascript
import { createMachine, assign } from 'xstate';
import { useMachine } from '@xstate/react';

// Définition de la machine à états pour une commande
const orderMachine = createMachine({
  id: 'order',
  initial: 'idle',
  context: {
    order: null,
    error: null,
    paymentMethod: null
  },
  states: {
    idle: {
      on: {
        INITIATE_ORDER: {
          target: 'creating',
          actions: assign({
            order: (context, event) => ({
              id: Date.now(),
              items: event.items,
              total: event.total,
              status: 'pending'
            })
          })
        }
      }
    },
    creating: {
      invoke: {
        src: 'createOrder',
        onDone: {
          target: 'pendingPayment',
          actions: assign({
            order: (context, event) => ({
              ...context.order,
              ...event.data,
              status: 'pending_payment'
            })
          })
        },
        onError: {
          target: 'creationFailed',
          actions: assign({
            error: (context, event) => event.data
          })
        }
      }
    },
    pendingPayment: {
      on: {
        SELECT_PAYMENT_METHOD: {
          actions: assign({
            paymentMethod: (context, event) => event.paymentMethod
          })
        },
        PROCESS_PAYMENT: 'processingPayment'
      }
    },
    processingPayment: {
      invoke: {
        src: 'processPayment',
        onDone: {
          target: 'confirmed',
          actions: assign({
            order: (context, event) => ({
              ...context.order,
              status: 'confirmed',
              payment: event.data
            })
          })
        },
        onError: {
          target: 'paymentFailed',
          actions: assign({
            error: (context, event) => event.data
          })
        }
      }
    },
    confirmed: {
      type: 'final'
    },
    creationFailed: {
      on: {
        RETRY: 'creating',
        CANCEL: 'idle'
      }
    },
    paymentFailed: {
      on: {
        RETRY_PAYMENT: 'processingPayment',
        CANCEL: 'idle'
      }
    }
  }
}, {
  services: {
    createOrder: async (context, event) => {
      // Simuler l'appel API
      await new Promise(resolve => setTimeout(resolve, 1000));
      return { id: context.order.id, status: 'pending_payment' };
    },
    processPayment: async (context, event) => {
      // Simuler le traitement du paiement
      await new Promise(resolve => setTimeout(resolve, 2000));
      return { status: 'completed', transactionId: 'txn_' + Date.now() };
    }
  }
});

// Composant avec machine à états
const OrderComponent = ({ items, total }) => {
  const [current, send] = useMachine(orderMachine);

  const initiateOrder = () => {
    send({
      type: 'INITIATE_ORDER',
      items,
      total
    });
  };

  const processPayment = () => {
    send('PROCESS_PAYMENT');
  };

  const selectPaymentMethod = (method) => {
    send({
      type: 'SELECT_PAYMENT_METHOD',
      paymentMethod: method
    });
  };

  if (current.matches('idle')) {
    return (
      <button onClick={initiateOrder}>
        Passer la commande
      </button>
    );
  }

  if (current.matches('creating')) {
    return <div>Création de la commande...</div>;
  }

  if (current.matches('pendingPayment')) {
    return (
      <div>
        <h3>Sélectionnez un mode de paiement</h3>
        <button onClick={() => selectPaymentMethod('credit_card')}>
          Carte de crédit
        </button>
        <button onClick={() => selectPaymentMethod('paypal')}>
          PayPal
        </button>
        <button onClick={processPayment} disabled={!current.context.paymentMethod}>
          Payer
        </button>
      </div>
    );
  }

  if (current.matches('processingPayment')) {
    return <div>Traitement du paiement...</div>;
  }

  if (current.matches('confirmed')) {
    return (
      <div>
        <h3>Commande confirmée !</h3>
        <p>ID: {current.context.order.id}</p>
        <p>Total: {current.context.order.total}€</p>
      </div>
    );
  }

  if (current.matches('creationFailed') || current.matches('paymentFailed')) {
    return (
      <div>
        <p>Erreur: {current.context.error}</p>
        <button onClick={() => send('RETRY')}>
          Réessayer
        </button>
        <button onClick={() => send('CANCEL')}>
          Annuler
        </button>
      </div>
    );
  }

  return null;
};
```

## Modèles de persistance d'état

### 1. Modèle de persistance locale

#### Persistance avec localStorage
```javascript
class LocalStorageManager {
  constructor(prefix = 'app_') {
    this.prefix = prefix;
  }

  getKey(key) {
    return `${this.prefix}${key}`;
  }

  set(key, value, options = {}) {
    const storageKey = this.getKey(key);
    
    try {
      const item = {
        value,
        timestamp: Date.now(),
        expiresAt: options.expiresIn 
          ? Date.now() + (options.expiresIn * 1000)
          : null
      };
      
      localStorage.setItem(storageKey, JSON.stringify(item));
      return true;
    } catch (error) {
      console.error('Erreur de stockage:', error);
      return false;
    }
  }

  get(key) {
    const storageKey = this.getKey(key);
    
    try {
      const itemStr = localStorage.getItem(storageKey);
      if (!itemStr) return null;
      
      const item = JSON.parse(itemStr);
      
      // Vérifier l'expiration
      if (item.expiresAt && Date.now() > item.expiresAt) {
        this.remove(key);
        return null;
      }
      
      return item.value;
    } catch (error) {
      console.error('Erreur de lecture:', error);
      return null;
    }
  }

  remove(key) {
    const storageKey = this.getKey(key);
    localStorage.removeItem(storageKey);
  }

  clear() {
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith(this.prefix)) {
        localStorage.removeItem(key);
      }
    });
  }

  // Méthode pour nettoyer les données expirées
  cleanup() {
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith(this.prefix)) {
        try {
          const itemStr = localStorage.getItem(key);
          const item = JSON.parse(itemStr);
          
          if (item.expiresAt && Date.now() > item.expiresAt) {
            localStorage.removeItem(key);
          }
        } catch (error) {
          // Supprimer les entrées corrompues
          localStorage.removeItem(key);
        }
      }
    });
  }
}

// Store persistant
class PersistentStore {
  constructor(initialState = {}, storageKey = 'app_state') {
    this.storage = new LocalStorageManager();
    this.storageKey = storageKey;
    
    // Charger l'état initial
    const persistedState = this.storage.get(this.storageKey);
    this.state = persistedState ? { ...initialState, ...persistedState } : initialState;
    
    // Nettoyer les données expirées
    this.storage.cleanup();
  }

  getState() {
    return { ...this.state };
  }

  setState(updates) {
    this.state = { ...this.state, ...updates };
    
    // Persister automatiquement
    this.storage.set(this.storageKey, this.state, {
      expiresIn: 24 * 60 * 60 // 24 heures
    });
  }

  subscribe(listener) {
    // Pour une implémentation complète, ajouter un système de listeners
    // Similaire à Redux
  }
}

// Hook React pour le store persistant
const usePersistentState = (key, initialValue) => {
  const storage = useMemo(() => new LocalStorageManager('state_'), []);
  
  const [state, setState] = useState(() => {
    const persistedValue = storage.get(key);
    return persistedValue !== null ? persistedValue : initialValue;
  });

  const updateState = useCallback((newValue) => {
    const value = typeof newValue === 'function' ? newValue(state) : newValue;
    setState(value);
    storage.set(key, value, { expiresIn: 7 * 24 * 60 * 60 }); // 1 semaine
  }, [key, state, storage]);

  return [state, updateState];
};

// Utilisation
const useUserPreferences = () => {
  return usePersistentState('user_prefs', {
    theme: 'light',
    language: 'fr',
    notifications: true,
    sidebarCollapsed: false
  });
};

const UserSettings = () => {
  const [prefs, setPrefs] = useUserPreferences();

  const updatePreference = (key, value) => {
    setPrefs(prev => ({
      ...prev,
      [key]: value
    }));
  };

  return (
    <div className="settings">
      <label>
        Thème:
        <select 
          value={prefs.theme} 
          onChange={(e) => updatePreference('theme', e.target.value)}
        >
          <option value="light">Clair</option>
          <option value="dark">Sombre</option>
        </select>
      </label>
      
      <label>
        Notifications:
        <input 
          type="checkbox" 
          checked={prefs.notifications}
          onChange={(e) => updatePreference('notifications', e.target.checked)}
        />
      </label>
    </div>
  );
};
```

### 2. Modèle de synchronisation d'état

#### Synchronisation avec WebSocket
```javascript
class StateSyncManager {
  constructor(websocketUrl) {
    this.url = websocketUrl;
    this.ws = null;
    this.state = new Map();
    this.listeners = new Map();
    this.syncQueue = [];
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }

  connect() {
    this.ws = new WebSocket(this.url);
    
    this.ws.onopen = () => {
      console.log('Connecté au serveur de synchronisation');
      this.reconnectAttempts = 0;
      
      // Synchroniser l'état local
      this.state.forEach((value, key) => {
        this.sendUpdate(key, value);
      });
    };

    this.ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data);
        this.handleMessage(message);
      } catch (error) {
        console.error('Erreur de parsing du message:', error);
      }
    };

    this.ws.onerror = (error) => {
      console.error('Erreur WebSocket:', error);
    };

    this.ws.onclose = () => {
      console.log('Déconnecté du serveur de synchronisation');
      
      if (this.reconnectAttempts < this.maxReconnectAttempts) {
        setTimeout(() => {
          this.reconnectAttempts++;
          this.connect();
        }, 1000 * this.reconnectAttempts); // Exponential backoff
      }
    };
  }

  handleMessage(message) {
    switch (message.type) {
      case 'STATE_UPDATE':
        this.updateLocalState(message.key, message.value, message.sender);
        break;
      case 'STATE_REQUEST':
        this.sendState(message.key, message.requester);
        break;
      case 'SYNC_COMPLETE':
        console.log('Synchronisation terminée');
        break;
    }
  }

  updateLocalState(key, value, senderId) {
    // Éviter la boucle de synchronisation
    if (senderId === this.getClientId()) {
      return;
    }

    this.state.set(key, value);
    
    // Notifier les listeners
    const listeners = this.listeners.get(key) || [];
    listeners.forEach(callback => {
      try {
        callback(value, { sender: senderId, type: 'sync' });
      } catch (error) {
        console.error('Erreur dans le listener:', error);
      }
    });
  }

  sendUpdate(key, value) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      const message = {
        type: 'STATE_UPDATE',
        key,
        value,
        sender: this.getClientId(),
        timestamp: Date.now()
      };
      
      this.ws.send(JSON.stringify(message));
    } else {
      // Mettre en file d'attente pour envoi plus tard
      this.syncQueue.push({ key, value });
    }
  }

  subscribe(key, callback) {
    if (!this.listeners.has(key)) {
      this.listeners.set(key, []);
    }
    
    this.listeners.get(key).push(callback);
    
    // Retourner une fonction de désabonnement
    return () => {
      const listeners = this.listeners.get(key) || [];
      const index = listeners.indexOf(callback);
      if (index > -1) {
        listeners.splice(index, 1);
      }
    };
  }

  setState(key, value) {
    this.state.set(key, value);
    this.sendUpdate(key, value);
  }

  getState(key) {
    return this.state.get(key);
  }

  getClientId() {
    // Générer un ID unique pour ce client
    if (!this.clientId) {
      this.clientId = `client_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
    return this.clientId;
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

// Hook React pour la synchronisation d'état
const useStateSync = (key, initialValue) => {
  const syncManager = useMemo(() => 
    new StateSyncManager('ws://localhost:8080/state-sync'), []
  );
  
  const [state, setState] = useState(() => {
    const saved = syncManager.getState(key);
    return saved !== undefined ? saved : initialValue;
  });

  useEffect(() => {
    // S'abonner aux mises à jour externes
    const unsubscribe = syncManager.subscribe(key, (value) => {
      setState(value);
    });

    // Charger l'état initial si disponible
    const initialValue = syncManager.getState(key);
    if (initialValue !== undefined) {
      setState(initialValue);
    }

    return unsubscribe;
  }, [key]);

  const updateState = useCallback((newValue) => {
    const value = typeof newValue === 'function' ? newValue(state) : newValue;
    setState(value);
    syncManager.setState(key, value);
  }, [key, state]);

  return [state, updateState];
};

// Utilisation dans une application collaborative
const CollaborativeEditor = () => {
  const [content, setContent] = useStateSync('editor_content', '');
  const [users, setUsers] = useStateSync('online_users', []);

  useEffect(() => {
    // Joindre la session collaborative
    const userId = `user_${Date.now()}`;
    setUsers(prev => [...prev, { id: userId, name: 'Current User' }]);
    
    return () => {
      // Quitter la session
      setUsers(prev => prev.filter(u => u.id !== userId));
    };
  }, []);

  return (
    <div className="collaborative-editor">
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="Éditer en collaboration..."
      />
      
      <div className="online-users">
        <h4>Utilisateurs en ligne:</h4>
        {users.map(user => (
          <div key={user.id} className="user-indicator">
            {user.name}
          </div>
        ))}
      </div>
    </div>
  );
};
```

Ces modèles de gestion d'état fournissent des approches éprouvées pour gérer l'état dans des applications de différentes tailles et complexités, en assurant la prédictibilité, la performance et la maintenabilité du code.