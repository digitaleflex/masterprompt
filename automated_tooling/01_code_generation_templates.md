# Modèles de génération de code

## Description
Ce document contient des modèles et des exemples pour la génération automatisée de code dans divers contextes de développement.

## Modèles de composants React

### Composant fonctionnel de base
```jsx
import React from 'react';

const {NomComposant} = () => {
  return (
    <div className="{nomComposant}">
      {/* Ajouter votre contenu ici */}
    </div>
  );
};

export default {NomComposant};
```

### Composant avec props
```jsx
import React from 'react';
import PropTypes from 'prop-types';

const {NomComposant} = ({ titre, contenu }) => {
  return (
    <div className="{nomComposant}">
      <h2>{titre}</h2>
      <p>{contenu}</p>
    </div>
  );
};

{NomComposant}.propTypes = {
  titre: PropTypes.string.isRequired,
  contenu: PropTypes.string
};

export default {NomComposant};
```

## Modèles de hooks personnalisés

### Hook de gestion d'état local
```jsx
import { useState, useEffect } from 'react';

const useLocalStorage = (key, initialValue) => {
  const [value, setValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  useEffect(() => {
    try {
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(error);
    }
  }, [key, value]);

  return [value, setValue];
};

export default useLocalStorage;
```

## Modèles de services API

### Service de base
```javascript
class ApiService {
  constructor(baseURL) {
    this.baseURL = baseURL;
    this.defaultHeaders = {
      'Content-Type': 'application/json',
    };
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      headers: { ...this.defaultHeaders, ...options.headers },
      ...options,
    };

    try {
      const response = await fetch(url, config);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.error('API request error:', error);
      throw error;
    }
  }
}

export default ApiService;
```

## Modèles de tests

### Test unitaire avec Jest
```javascript
import { fonctionATester } from './fichier';

describe('Description de la fonctionnalité', () => {
  test('devrait faire telle chose', () => {
    // Arrange
    const input = 'valeur d\'entrée';
    const expected = 'résultat attendu';

    // Act
    const result = fonctionATester(input);

    // Assert
    expect(result).toBe(expected);
  });
});
```

## Modèles de configuration

### Fichier de configuration
```javascript
const config = {
  apiUrl: process.env.REACT_APP_API_URL || 'http://localhost:5000',
  apiKey: process.env.REACT_APP_API_KEY,
  debug: process.env.NODE_ENV === 'development',
  features: {
    analytics: true,
    notifications: true,
  },
};

export default config;
```

## Générateurs de code

### CLI pour la génération de composants
```bash
#!/bin/bash

# Script pour générer un composant React
if [ -z "$1" ]; then
  echo "Usage: generate-component.sh <ComponentName>"
  exit 1
fi

COMPONENT_NAME=$1
COMPONENT_DIR="src/components/$COMPONENT_NAME"

mkdir -p $COMPONENT_DIR

cat > "$COMPONENT_DIR/$COMPONENT_NAME.jsx" << EOF
import React from 'react';

const $COMPONENT_NAME = () => {
  return (
    <div className="$COMPONENT_NAME">
      {/* $COMPONENT_NAME component */}
    </div>
  );
};

export default $COMPONENT_NAME;
EOF

cat > "$COMPONENT_DIR/$COMPONENT_NAME.module.css" << EOF
.$COMPONENT_NAME {
  /* Styles pour $COMPONENT_NAME */
}
EOF

echo "Composant $COMPONENT_NAME généré avec succès!"
```