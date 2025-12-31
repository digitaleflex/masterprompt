# Stratégies de débogage

## Description
Ce document présente des techniques et outils avancés pour le débogage d'applications.

## Techniques de débogage

### 1. Débogage par inspection de code
```javascript
// Mauvaise pratique - débogage avec console.log
function calculateTotal(items) {
  console.log('items:', items); // Mauvais
  let total = 0;
  for (let i = 0; i < items.length; i++) {
    console.log('item:', items[i]); // Mauvais
    total += items[i].price;
  }
  console.log('total:', total); // Mauvais
  return total;
}

// Meilleure pratique - débogage avec breakpoints
function calculateTotal(items) {
  let total = 0;
  for (let i = 0; i < items.length; i++) {
    // Mettre un breakpoint ici dans le débogueur
    total += items[i].price;
  }
  return total;
}
```

### 2. Débogage conditionnel
```javascript
// Utilisation de conditions pour activer le débogage
const DEBUG = process.env.NODE_ENV === 'development';

function processData(data) {
  if (DEBUG) {
    console.log('Données reçues:', data);
  }
  
  // Traitement principal
  const result = complexProcessing(data);
  
  if (DEBUG) {
    console.log('Résultat:', result);
  }
  
  return result;
}
```

## Outils de débogage

### 1. Débogueur de navigateur (Chrome DevTools)
```javascript
// Utilisation de debugger statement
function problematicFunction(data) {
  // Quelque chose semble mal fonctionner ici
  debugger; // Le navigateur s'arrêtera ici
  
  return data.map(item => {
    // Continuer le débogage pas à pas
    return processItem(item);
  });
}
```

### 2. Débogage avec React
```jsx
// Utilisation de React DevTools
import React, { useState, useEffect } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    // Mettre un breakpoint ici pour voir les changements d'état
    fetchUser(userId).then(setUser).finally(() => setLoading(false));
  }, [userId]);
  
  // Utiliser React DevTools pour inspecter les props et state
  if (loading) return <div>Chargement...</div>;
  if (!user) return <div>Utilisateur non trouvé</div>;
  
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

## Débogage de performance

### 1. Analyse des performances avec DevTools
```javascript
// Mesure du temps d'exécution
function performanceTest() {
  console.time('Traitement des données');
  
  const result = heavyComputation();
  
  console.timeEnd('Traitement des données');
  
  return result;
}

// Profilage de la mémoire
function memoryTest() {
  const largeArray = new Array(1000000).fill(0).map((_, i) => i);
  
  // Prendre un snapshot de mémoire dans Memory panel
  return largeArray;
}
```

### 2. Détection des fuites de mémoire
```javascript
class DataManager {
  constructor() {
    this.data = [];
    this.eventListeners = [];
  }
  
  // Mauvaise pratique - fuite de mémoire possible
  addListener(callback) {
    document.addEventListener('event', callback);
    this.eventListeners.push(callback); // Garder une référence
  }
  
  // Meilleure pratique - nettoyage approprié
  destroy() {
    // Retirer tous les écouteurs d'événements
    this.eventListeners.forEach(callback => {
      document.removeEventListener('event', callback);
    });
    this.eventListeners = [];
    this.data = [];
  }
}
```

## Débogage asynchrone

### 1. Débogage des Promesses
```javascript
// Débogage des erreurs dans les Promesses
async function fetchUserData(userId) {
  try {
    console.log('Requête pour l\'utilisateur:', userId);
    
    const response = await fetch(`/api/users/${userId}`);
    
    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }
    
    const userData = await response.json();
    console.log('Données utilisateur reçues:', userData);
    
    return userData;
  } catch (error) {
    console.error('Erreur lors de la récupération des données:', error);
    throw error; // Re-lancer pour que l'appelant puisse gérer l'erreur
  }
}

// Utilisation avec débogage
fetchUserData(123)
  .then(data => console.log('Succès:', data))
  .catch(error => console.error('Échec:', error));
```

### 2. Débogage avec async/await
```javascript
async function complexProcess() {
  try {
    const step1 = await processStep1();
    console.log('Étape 1 terminée:', step1);
    
    const step2 = await processStep2(step1);
    console.log('Étape 2 terminée:', step2);
    
    const step3 = await processStep3(step2);
    console.log('Étape 3 terminée:', step3);
    
    return step3;
  } catch (error) {
    console.error('Erreur dans le processus complexe:', error);
    // Logique de gestion d'erreur
    throw error;
  }
}
```

## Débogage en production

### 1. Journalisation intelligente
```javascript
// Niveau de journalisation
const LOG_LEVELS = {
  ERROR: 0,
  WARN: 1,
  INFO: 2,
  DEBUG: 3
};

class Logger {
  constructor(level = LOG_LEVELS.INFO) {
    this.level = level;
  }
  
  log(level, message, data = null) {
    if (level <= this.level) {
      const logEntry = {
        timestamp: new Date().toISOString(),
        level: Object.keys(LOG_LEVELS).find(key => LOG_LEVELS[key] === level),
        message,
        data,
        // Ajouter des informations contextuelles
        context: this.getContext()
      };
      
      console.log(JSON.stringify(logEntry));
    }
  }
  
  error(message, data) {
    this.log(LOG_LEVELS.ERROR, message, data);
  }
  
  warn(message, data) {
    this.log(LOG_LEVELS.WARN, message, data);
  }
  
  info(message, data) {
    this.log(LOG_LEVELS.INFO, message, data);
  }
  
  debug(message, data) {
    this.log(LOG_LEVELS.DEBUG, message, data);
  }
  
  getContext() {
    // Ajouter des informations contextuelles
    return {
      userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : 'server',
      url: typeof window !== 'undefined' ? window.location.href : 'server',
      userId: this.getCurrentUserId()
    };
  }
  
  getCurrentUserId() {
    // Récupérer l'ID utilisateur si disponible
    return null;
  }
}

// Utilisation
const logger = new Logger(LOG_LEVELS.DEBUG);

async function apiCall(url, options) {
  logger.info('Appel API démarré', { url, method: options?.method });
  
  try {
    const response = await fetch(url, options);
    logger.info('Réponse API reçue', { status: response.status, url });
    
    if (!response.ok) {
      logger.error('Erreur de réponse API', { 
        status: response.status, 
        url,
        statusText: response.statusText 
      });
      throw new Error(`Erreur API: ${response.status}`);
    }
    
    const data = await response.json();
    logger.debug('Données API parsées', { url, dataSize: JSON.stringify(data).length });
    
    return data;
  } catch (error) {
    logger.error('Erreur lors de l\'appel API', { url, error: error.message });
    throw error;
  }
}
```

### 2. Outils de débogage à distance
```javascript
// Service de rapport d'erreurs
class ErrorReporter {
  constructor(apiEndpoint) {
    this.apiEndpoint = apiEndpoint;
  }
  
  async reportError(error, context = {}) {
    const errorReport = {
      message: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString(),
      context: {
        ...context,
        userAgent: navigator.userAgent,
        url: window.location.href,
        timestamp: Date.now()
      }
    };
    
    try {
      await fetch(this.apiEndpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(errorReport)
      });
    } catch (reportingError) {
      // Ne pas lancer d'erreur ici pour ne pas perturber l'application
      console.error('Erreur lors du rapport d\'erreur:', reportingError);
    }
  }
}

// Utilisation avec gestion d'erreurs
const errorReporter = new ErrorReporter('/api/errors');

window.addEventListener('error', (event) => {
  errorReporter.reportError(event.error, {
    type: 'javascript',
    source: event.filename,
    lineno: event.lineno,
    colno: event.colno
  });
});

window.addEventListener('unhandledrejection', (event) => {
  errorReporter.reportError(event.reason, {
    type: 'promise-rejection',
    unhandled: true
  });
});
```

## Débogage des hooks React

### 1. Débogage des useEffect
```jsx
import { useEffect, useState } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    // Déboguer les dépendances
    console.log('useEffect appelé avec userId:', userId);
    
    let cancelled = false;
    
    const fetchUser = async () => {
      try {
        setLoading(true);
        console.log('Fetching user:', userId);
        
        const response = await fetch(`/api/users/${userId}`);
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        
        const userData = await response.json();
        
        if (!cancelled) {
          setUser(userData);
          console.log('User data set:', userData);
        }
      } catch (error) {
        if (!cancelled) {
          console.error('Erreur lors du fetch:', error);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
          console.log('Loading finished');
        }
      }
    };
    
    fetchUser();
    
    // Nettoyage
    return () => {
      cancelled = true;
      console.log('User fetch cancelled for userId:', userId);
    };
  }, [userId]); // Dépendance importante
  
  if (loading) return <div>Chargement...</div>;
  if (!user) return <div>Utilisateur non trouvé</div>;
  
  return <div>Bonjour, {user.name}!</div>;
}
```

### 2. Hook de débogage personnalisé
```jsx
import { useState, useEffect } from 'react';

// Hook de débogage pour suivre les changements d'état
function useDebugState(initialValue, name = 'state') {
  const [state, setState] = useState(initialValue);
  
  useEffect(() => {
    console.log(`[DEBUG] ${name} changé à:`, state);
  }, [state, name]);
  
  return [state, setState];
}

// Hook de débogage pour les effets
function useDebugEffect(effect, deps, name = 'Effect') {
  useEffect(() => {
    console.log(`[DEBUG] ${name} exécuté`);
    return effect();
  }, deps);
}

// Utilisation
function MyComponent({ data }) {
  const [count, setCount] = useDebugState(0, 'count');
  const [items, setItems] = useState([]);
  
  useDebugEffect(() => {
    console.log('Traitement des données:', data);
    setItems(data || []);
  }, [data], 'Data Processing Effect');
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Incrémenter</button>
      <ul>
        {items.map((item, index) => (
          <li key={index}>{item}</li>
        ))}
      </ul>
    </div>
  );
}
```

## Débogage des tests

### 1. Débogage avec Jest
```javascript
// Utilisation de --runInBand et --detectOpenHandles pour le débogage
describe('Calculatrice', () => {
  test('devrait additionner correctement', () => {
    const result = add(2, 3);
    console.log('Résultat du test:', result); // Pour le débogage
    expect(result).toBe(5);
  });
  
  test('devrait gérer les erreurs', () => {
    expect(() => {
      divide(10, 0);
    }).toThrow('Division par zéro');
  });
});

// Débogage avec breakpoints dans les tests
test('test complexe avec débogage', async () => {
  const input = { id: 1, data: [1, 2, 3] };
  
  debugger; // Le test s'arrêtera ici
  
  const result = await processComplexData(input);
  
  debugger; // On peut vérifier le résultat ici
  
  expect(result.status).toBe('success');
});
```

## Outils de débogage avancés

### 1. Débogage avec des assertions
```javascript
// Fonction d'assertion pour le débogage
function assert(condition, message) {
  if (!condition) {
    const error = new Error(`Assertion échouée: ${message}`);
    console.error(error);
    
    // Arrêter l'exécution en mode développement
    if (process.env.NODE_ENV === 'development') {
      debugger; // S'arrêter dans le débogueur
    }
    
    throw error;
  }
}

// Utilisation
function calculateDiscount(price, discountPercent) {
  assert(typeof price === 'number', 'Le prix doit être un nombre');
  assert(typeof discountPercent === 'number', 'Le pourcentage de remise doit être un nombre');
  assert(price >= 0, 'Le prix ne doit pas être négatif');
  assert(discountPercent >= 0 && discountPercent <= 100, 'Le pourcentage de remise doit être entre 0 et 100');
  
  return price * (discountPercent / 100);
}
```

### 2. Débogage des performances
```javascript
// Outil de profilage simple
class Profiler {
  constructor() {
    this.marks = new Map();
  }
  
  mark(name) {
    this.marks.set(name, performance.now());
  }
  
  measure(startMark, endMark, description = '') {
    const start = this.marks.get(startMark);
    const end = this.marks.get(endMark) || performance.now();
    
    const duration = end - start;
    console.log(`${description} - Durée: ${duration.toFixed(2)}ms`);
    
    return duration;
  }
  
  // Pour React
  measureReactRender(componentName, renderFn) {
    this.mark(`${componentName}_start`);
    const result = renderFn();
    this.mark(`${componentName}_end`);
    this.measure(`${componentName}_start`, `${componentName}_end`, `Rendu de ${componentName}`);
    return result;
  }
}

// Utilisation
const profiler = new Profiler();

function complexCalculation() {
  profiler.mark('calculation_start');
  
  // Calcul complexe
  const result = heavyComputation();
  
  profiler.mark('calculation_end');
  profiler.measure('calculation_start', 'calculation_end', 'Calcul complexe');
  
  return result;
}
```

## Meilleures pratiques de débogage

### 1. Débogage préventif
- Écrire du code testable
- Utiliser des types (TypeScript)
- Mettre en place des validations précoces
- Utiliser des assertions

### 2. Documentation du débogage
- Commenter les points de débogage
- Maintenir un journal des problèmes résolus
- Créer des cas de test pour les bugs récurrents

### 3. Outils de débogage
- Utiliser les débogueurs intégrés
- Mettre en place des outils de journalisation
- Utiliser des outils de surveillance en production