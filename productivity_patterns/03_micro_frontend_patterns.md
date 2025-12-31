# Modèles de micro-frontend

## Description
Ce document présente des modèles et des architectures pour implémenter des systèmes de micro-frontends, permettant de diviser des applications web monolithiques en composants plus petits et indépendants.

## Concepts fondamentaux

### 1. Qu'est-ce qu'un micro-frontend ?
Les micro-frontends sont une approche d'architecture qui étend les principes des microservices au frontend. Chaque micro-frontend est un module fonctionnellement indépendant avec son propre cycle de vie de développement, de déploiement et de maintenance.

### 2. Avantages des micro-frontends
- **Indépendance technique** : Chaque équipe peut choisir ses propres technologies
- **Déploiement indépendant** : Mise à jour d'une partie sans toucher au reste
- **Scalabilité organisationnelle** : Équipes autonomes
- **Résilience** : Panne d'un micro-frontend n'affecte pas les autres
- **Maintenabilité** : Codebases plus petites et plus ciblées

### 3. Défis des micro-frontends
- **Complexité d'intégration** : Communication entre composants
- **Consistance de l'UI** : Maintenir un design uniforme
- **Gestion des dépendances** : Versions différentes de librairies
- **Performance** : Chargement multiple de frameworks
- **Sécurité** : Gestion des communications inter-domaines

## Modèles d'architecture

### 1. Modèle de composition côté serveur

#### Principe
- Assemblage des fragments HTML côté serveur
- Le serveur combine les réponses des différents micro-frontends
- Un seul bundle HTML envoyé au client

#### Implémentation
```html
<!-- Template principal -->
<!DOCTYPE html>
<html>
<head>
  <title>Application principale</title>
</head>
<body>
  <header>
    <!-- Fragment du header -->
    <!--# include virtual="/header" -->
  </header>
  
  <nav>
    <!-- Fragment de navigation -->
    <!--# include virtual="/navigation" -->
  </nav>
  
  <main>
    <!--# include virtual="/content" -->
  </main>
  
  <footer>
    <!--# include virtual="/footer" -->
  </footer>
</body>
</html>
```

#### Avantages
- Meilleures performances de chargement initial
- SEO optimisé
- Moins de complexité côté client

#### Inconvénients
- Moins de réactivité après chargement
- Couplage serveur-client
- Déploiement plus complexe

### 2. Modèle de composition côté client

#### Principe
- Chargement dynamique des micro-frontends côté client
- Communication via un bus d'événements
- Chaque micro-frontend est un module indépendant

#### Implémentation
```javascript
// Bus d'événements global
class EventBus {
  constructor() {
    this.events = {};
  }

  emit(event, data) {
    if (this.events[event]) {
      this.events[event].forEach(callback => callback(data));
    }
  }

  on(event, callback) {
    if (!this.events[event]) {
      this.events[event] = [];
    }
    this.events[event].push(callback);
  }

  off(event, callback) {
    if (this.events[event]) {
      this.events[event] = this.events[event].filter(cb => cb !== callback);
    }
  }
}

// Instance globale
window.EventBus = new EventBus();

// Micro-frontend header
class HeaderMF {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.render();
    this.bindEvents();
  }

  render() {
    this.container.innerHTML = `
      <header class="mf-header">
        <h1>Mon Application</h1>
        <div id="user-info"></div>
      </header>
    `;
  }

  bindEvents() {
    window.EventBus.on('user:login', (userData) => {
      this.updateUserInfo(userData);
    });

    window.EventBus.on('user:logout', () => {
      this.clearUserInfo();
    });
  }

  updateUserInfo(userData) {
    document.getElementById('user-info').innerHTML = `
      <span>Bienvenue, ${userData.name}</span>
      <button onclick="window.EventBus.emit('user:logout')">Déconnexion</button>
    `;
  }

  clearUserInfo() {
    document.getElementById('user-info').innerHTML = '';
  }
}

// Micro-frontend navigation
class NavigationMF {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.render();
    this.bindEvents();
  }

  render() {
    this.container.innerHTML = `
      <nav class="mf-navigation">
        <ul>
          <li><a href="#" onclick="window.EventBus.emit('route:change', 'dashboard')">Dashboard</a></li>
          <li><a href="#" onclick="window.EventBus.emit('route:change', 'profile')">Profil</a></li>
          <li><a href="#" onclick="window.EventBus.emit('route:change', 'settings')">Paramètres</a></li>
        </ul>
      </nav>
    `;
  }

  bindEvents() {
    window.EventBus.on('route:change', (route) => {
      // Gérer le changement de route
      this.highlightActiveRoute(route);
    });
  }

  highlightActiveRoute(route) {
    // Mettre en évidence la route active
  }
}
```

#### Avantages
- Grande flexibilité
- Expérience utilisateur fluide
- Déploiement indépendant
- Technologie agnostique

#### Inconvénients
- Complexité de communication
- Risque de duplication de code
- Performance de chargement initiale

### 3. Modèle d'intégration par iframe

#### Principe
- Chaque micro-frontend dans une iframe séparée
- Isolation complète des contextes
- Communication via postMessage

#### Implémentation
```html
<!-- Application principale -->
<!DOCTYPE html>
<html>
<head>
  <title>Application principale</title>
</head>
<body>
  <div class="app-container">
    <iframe src="/header-mf" class="micro-frontend" id="header-mf"></iframe>
    <iframe src="/navigation-mf" class="micro-frontend" id="navigation-mf"></iframe>
    <iframe src="/content-mf" class="micro-frontend" id="content-mf"></iframe>
    <iframe src="/footer-mf" class="micro-frontend" id="footer-mf"></iframe>
  </div>

  <script>
    // Communication avec les micro-frontends
    function sendMessageToMF(mfId, message) {
      const iframe = document.getElementById(mfId);
      iframe.contentWindow.postMessage(message, '*');
    }

    // Écoute des messages des micro-frontends
    window.addEventListener('message', (event) => {
      if (event.data.type === 'user:login') {
        // Gérer l'événement de login
        handleUserLogin(event.data.payload);
      } else if (event.data.type === 'route:change') {
        // Gérer le changement de route
        handleRouteChange(event.data.payload);
      }
    });

    function handleUserLogin(userData) {
      // Mettre à jour l'UI principale
      updateAppUI(userData);
    }

    function handleRouteChange(route) {
      // Charger le contenu approprié
      loadContent(route);
    }
  </script>
</body>
</html>
```

```javascript
// Dans le micro-frontend
window.addEventListener('message', (event) => {
  if (event.origin !== 'https://monapplication.com') {
    return; // Vérification de l'origine
  }

  if (event.data.type === 'update:user') {
    updateUserInterface(event.data.payload);
  }
});

// Envoyer un message à l'application principale
function notifyParent(eventType, payload) {
  parent.postMessage({
    type: eventType,
    payload: payload
  }, 'https://monapplication.com');
}

// Exemple d'utilisation
document.getElementById('login-btn').addEventListener('click', () => {
  const credentials = getCredentials();
  authenticate(credentials)
    .then(user => {
      notifyParent('user:login', user);
    })
    .catch(error => {
      notifyParent('user:login:error', error.message);
    });
});
```

#### Avantages
- Isolation totale
- Sécurité renforcée
- Aucun conflit de dépendances
- Facilité de migration

#### Inconvénients
- Limitations de communication
- Expérience utilisateur fragmentée
- Problèmes d'accessibilité
- Gestion complexe des dimensions

## Modèles de communication

### 1. Bus d'événements global

```javascript
// Implémentation avancée du bus d'événements
class MicroFrontendBus {
  constructor() {
    this.topics = {};
    this.subscriberInfo = {};
  }

  subscribe(topic, callback, context = null) {
    if (!this.topics[topic]) {
      this.topics[topic] = [];
    }

    const subscription = {
      callback,
      context,
      id: this.generateId()
    };

    this.topics[topic].push(subscription);

    // Stocker les informations d'abonnement pour le nettoyage
    if (!this.subscriberInfo[subscription.id]) {
      this.subscriberInfo[subscription.id] = { topic, subscription };
    }

    return subscription.id;
  }

  publish(topic, data, sender = null) {
    if (!this.topics[topic]) {
      return;
    }

    this.topics[topic].forEach(subscription => {
      try {
        subscription.callback.call(subscription.context, data, sender);
      } catch (error) {
        console.error(`Erreur dans l'abonné au topic ${topic}:`, error);
      }
    });
  }

  unsubscribe(subscriptionId) {
    const info = this.subscriberInfo[subscriptionId];
    if (!info) return;

    const { topic, subscription } = info;
    const topicSubscribers = this.topics[topic];
    
    if (topicSubscribers) {
      const index = topicSubscribers.findIndex(sub => sub.id === subscriptionId);
      if (index > -1) {
        topicSubscribers.splice(index, 1);
      }
    }

    delete this.subscriberInfo[subscriptionId];
  }

  generateId() {
    return `sub_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  // Nettoyage des abonnements pour un micro-frontend spécifique
  cleanupMicroFrontend(mfName) {
    Object.keys(this.subscriberInfo).forEach(subId => {
      const info = this.subscriberInfo[subId];
      if (info.subscription.context?.constructor?.name === mfName) {
        this.unsubscribe(subId);
      }
    });
  }
}

// Utilisation
const mfBus = new MicroFrontendBus();

// Abonnement
const subId = mfBus.subscribe('user:updated', (userData) => {
  console.log('Utilisateur mis à jour:', userData);
}, this);

// Publication
mfBus.publish('user:updated', { id: 1, name: 'Jean Dupont' }, 'user-micro-frontend');

// Désabonnement
mfBus.unsubscribe(subId);
```

### 2. Modèle de Store partagé

```javascript
// Store global partagé
class SharedStore {
  constructor(initialState = {}) {
    this.state = { ...initialState };
    this.listeners = [];
  }

  getState() {
    return { ...this.state };
  }

  setState(newState, microFrontendName) {
    const previousState = { ...this.state };
    this.state = { ...this.state, ...newState };

    this.notifyListeners(this.state, previousState, microFrontendName);
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  notifyListeners(currentState, previousState, changedBy) {
    this.listeners.forEach(listener => {
      listener(currentState, previousState, changedBy);
    });
  }

  // Méthode pour un micro-frontend pour s'abonner à des changements spécifiques
  subscribeToKeys(keys, callback) {
    let previousValues = {};
    
    keys.forEach(key => {
      previousValues[key] = this.state[key];
    });

    return this.subscribe((currentState, previousState) => {
      let hasChanged = false;
      const changedValues = {};

      keys.forEach(key => {
        if (currentState[key] !== previousState[key]) {
          hasChanged = true;
          changedValues[key] = currentState[key];
        }
      });

      if (hasChanged) {
        callback(changedValues, currentState, previousState);
      }
    });
  }
}

// Instance globale
window.MFSharedStore = new SharedStore({
  user: null,
  theme: 'light',
  language: 'fr',
  notifications: []
});

// Utilisation dans un micro-frontend
class UserProfileMF {
  constructor() {
    this.store = window.MFSharedStore;
    this.init();
  }

  init() {
    // S'abonner aux changements d'utilisateur
    this.unsubscribeUser = this.store.subscribeToKeys(['user'], (changedValues) => {
      if (changedValues.user) {
        this.renderUserProfile(changedValues.user);
      }
    });

    // Charger l'utilisateur initial
    const state = this.store.getState();
    if (state.user) {
      this.renderUserProfile(state.user);
    }
  }

  updateUserProfile(userData) {
    this.store.setState({ user: userData }, 'UserProfileMF');
  }

  renderUserProfile(user) {
    // Mettre à jour l'interface utilisateur
    document.getElementById('user-name').textContent = user.name;
  }

  destroy() {
    // Nettoyer les abonnements
    if (this.unsubscribeUser) {
      this.unsubscribeUser();
    }
  }
}
```

## Modèles de déploiement

### 1. Déploiement indépendant

```yaml
# docker-compose.microfrontends.yml
version: '3.8'

services:
  # Micro-frontend header
  header-mf:
    build: ./microfrontends/header
    ports:
      - "3001:3000"
    environment:
      - NODE_ENV=production
    networks:
      - microfrontends

  # Micro-frontend navigation
  navigation-mf:
    build: ./microfrontends/navigation
    ports:
      - "3002:3000"
    environment:
      - NODE_ENV=production
    networks:
      - microfrontends

  # Micro-frontend content
  content-mf:
    build: ./microfrontends/content
    ports:
      - "3003:3000"
    environment:
      - NODE_ENV=production
    networks:
      - microfrontends

  # Reverse proxy pour la composition
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - header-mf
      - navigation-mf
      - content-mf
    networks:
      - microfrontends

networks:
  microfrontends:
    driver: bridge
```

```nginx
# nginx.conf pour la composition côté serveur
events {
    worker_connections 1024;
}

http {
    upstream header_service {
        server header-mf:3000;
    }

    upstream navigation_service {
        server navigation-mf:3000;
    }

    upstream content_service {
        server content-mf:3000;
    }

    server {
        listen 80;

        # Proxy pour le header
        location /header {
            proxy_pass http://header_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Proxy pour la navigation
        location /navigation {
            proxy_pass http://navigation_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Proxy pour le contenu
        location /content {
            proxy_pass http://content_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Page principale qui compose les fragments
        location / {
            proxy_pass http://composition_service;
        }
    }
}
```

### 2. Déploiement avec module federation (Webpack 5)

```javascript
// webpack.config.js pour le micro-frontend header
const { ModuleFederationPlugin } = require("webpack").container;
const path = require("path");

module.exports = {
  entry: "./src/index",
  mode: "development",
  devServer: {
    contentBase: path.join(__dirname, "dist"),
    port: 3001,
  },
  output: {
    publicPath: "http://localhost:3001/",
  },
  plugins: [
    new ModuleFederationPlugin({
      name: "header",
      filename: "remoteEntry.js",
      exposes: {
        "./Header": "./src/Header",
      },
      shared: ["react", "react-dom"],
    }),
  ],
};
```

```javascript
// webpack.config.js pour l'application shell
const { ModuleFederationPlugin } = require("webpack").container;
const path = require("path");

module.exports = {
  entry: "./src/index",
  mode: "development",
  devServer: {
    contentBase: path.join(__dirname, "dist"),
    port: 3000,
  },
  plugins: [
    new ModuleFederationPlugin({
      name: "shell",
      remotes: {
        header: "header@http://localhost:3001/remoteEntry.js",
        navigation: "navigation@http://localhost:3002/remoteEntry.js",
        content: "content@http://localhost:3003/remoteEntry.js",
      },
      shared: ["react", "react-dom"],
    }),
  ],
  output: {
    publicPath: "auto",
  },
};
```

```javascript
// Application shell qui consomme les micro-frontends
import { createRemoteComponent } from './remote-loader';

function App() {
  const Header = createRemoteComponent('header', './Header');
  const Navigation = createRemoteComponent('navigation', './Navigation');
  const Content = createRemoteComponent('content', './Content');

  return (
    <div className="app">
      <Header />
      <Navigation />
      <Content />
    </div>
  );
}

export default App;
```

## Meilleures pratiques

### 1. Gestion des états

```javascript
// Modèle de gestion d'état pour micro-frontends
class MFStateManager {
  constructor() {
    this.states = new Map();
    this.globalState = {};
    this.middleware = [];
  }

  // Définir l'état pour un micro-frontend spécifique
  setState(microFrontend, newState, options = {}) {
    const currentState = this.states.get(microFrontend) || {};
    const updatedState = { ...currentState, ...newState };

    // Appliquer les middlewares
    this.middleware.forEach(middleware => {
      middleware.beforeSet(microFrontend, updatedState, currentState);
    });

    this.states.set(microFrontend, updatedState);

    // Éventuellement fusionner avec l'état global
    if (options.toGlobal) {
      this.globalState = { ...this.globalState, ...newState };
    }

    // Notifier les abonnés
    this.notifySubscribers(microFrontend, updatedState, currentState);
  }

  // Obtenir l'état d'un micro-frontend spécifique
  getState(microFrontend) {
    return this.states.get(microFrontend) || {};
  }

  // Obtenir l'état global
  getGlobalState() {
    return { ...this.globalState };
  }

  // S'abonner aux changements d'état
  subscribe(microFrontend, callback) {
    // Implémentation de l'abonnement
  }

  // Ajouter un middleware
  use(middleware) {
    this.middleware.push(middleware);
  }
}
```

### 2. Gestion des erreurs

```javascript
// Gestion centralisée des erreurs pour micro-frontends
class MFErrorHandler {
  constructor() {
    this.errorHandlers = new Map();
    this.globalErrorHandler = null;
  }

  registerErrorHandler(microFrontend, handler) {
    this.errorHandlers.set(microFrontend, handler);
  }

  setGlobalHandler(handler) {
    this.globalErrorHandler = handler;
  }

  handleError(error, microFrontend, context) {
    // Gestion spécifique au micro-frontend
    const specificHandler = this.errorHandlers.get(microFrontend);
    if (specificHandler) {
      specificHandler(error, context);
    }

    // Gestion globale
    if (this.globalErrorHandler) {
      this.globalErrorHandler(error, microFrontend, context);
    }

    // Journalisation
    this.logError(error, microFrontend, context);
  }

  logError(error, microFrontend, context) {
    console.error(`[${microFrontend}] Error:`, error, 'Context:', context);
    // Envoyer à un service de monitoring
  }
}

// Utilisation
const errorHandler = new MFErrorHandler();

// Enregistrer un gestionnaire spécifique
errorHandler.registerErrorHandler('user-profile', (error, context) => {
  // Gestion spécifique pour le micro-frontend user-profile
  showErrorMessage(`Erreur de chargement du profil: ${error.message}`);
});

// Gestion globale
errorHandler.setGlobalHandler((error, mf, context) => {
  // Logique globale de gestion d'erreurs
  if (error.severity === 'critical') {
    redirectToErrorPage();
  }
});
```

### 3. Tests et qualité

```javascript
// Modèle de tests pour micro-frontends
describe('Micro-frontend Communication', () => {
  let mockBus;
  let userProfileMF;
  let headerMF;

  beforeEach(() => {
    mockBus = new MockEventBus();
    userProfileMF = new UserProfileMF(mockBus);
    headerMF = new HeaderMF(mockBus);
  });

  afterEach(() => {
    userProfileMF.destroy();
    headerMF.destroy();
  });

  test('should update header when user logs in', () => {
    const mockCallback = jest.fn();
    mockBus.subscribe('user:updated', mockCallback);

    // Simuler la connexion d'un utilisateur
    userProfileMF.login({ id: 1, name: 'John Doe' });

    expect(mockCallback).toHaveBeenCalledWith(
      { id: 1, name: 'John Doe' },
      'UserProfileMF'
    );
  });

  test('should handle cross-micro-frontend state updates', () => {
    // Test de la propagation d'état entre micro-frontends
    const userState = { id: 1, preferences: { theme: 'dark' } };
    
    userProfileMF.updatePreferences(userState);
    
    // Vérifier que le header réagit au changement
    expect(headerMF.getCurrentTheme()).toBe('dark');
  });
});
```

Les modèles de micro-frontend permettent de créer des architectures front-end évolutives et modulaires, mais ils nécessitent une planification minutieuse pour gérer la complexité d'intégration et maintenir une expérience utilisateur cohérente.