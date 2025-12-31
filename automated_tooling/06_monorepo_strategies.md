# Stratégies de monorepo

## Description
Ce document décrit les stratégies et outils pour gérer efficacement un monorepo (un seul dépôt pour plusieurs projets).

## Introduction au monorepo

Un monorepo est une approche de gestion de code source où plusieurs projets sont stockés dans un seul dépôt. Cette approche présente des avantages et inconvénients par rapport aux multi-repos.

### Avantages
- Modifications atomiques entre projets
- Partage de code plus facile
- Contrôle de version centralisé
- Processus CI/CD unifié
- Gestion des dépendances simplifiée

### Inconvénients
- Complexité de configuration
- Plus grande surface d'attaque pour les erreurs
- Déploiements couplés
- Outils plus complexes

## Outils de gestion de monorepo

### Lerna
```bash
# Installation
npm install --global lerna

# Initialisation d'un monorepo
lerna init

# Installation des dépendances
lerna bootstrap

# Exécution d'une commande dans tous les packages
lerna exec -- npm run test

# Publication des packages
lerna publish
```

### Configuration de base (lerna.json)
```json
{
  "packages": [
    "packages/*"
  ],
  "version": "independent",
  "npmClient": "yarn",
  "useWorkspaces": true,
  "command": {
    "publish": {
      "ignoreChanges": [
        "ignored-file",
        "*.md"
      ],
      "message": "chore(release): publish new version"
    }
  }
}
```

### Yarn Workspaces
```json
// package.json racine
{
  "private": true,
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "build": "yarn workspaces run build",
    "test": "yarn workspaces run test",
    "lint": "yarn workspaces run lint"
  }
}
```

### Nx
```bash
# Création d'un nouveau workspace Nx
npx create-nx-workspace@latest

# Génération d'un nouvel application
nx generate @nx/react:application my-app

# Génération d'une bibliothèque
nx generate @nx/react:library my-lib

# Exécution de tests impactés
nx affected --target=test

# Visualisation des dépendances
nx dep-graph
```

## Structure typique d'un monorepo

```
monorepo/
├── apps/
│   ├── frontend/
│   ├── backend/
│   └── mobile/
├── libs/
│   ├── ui/
│   ├── utils/
│   ├── auth/
│   └── data-access/
├── tools/
│   ├── scripts/
│   └── generators/
├── docs/
└── package.json
```

## Configuration avancée

### Nx configuration (nx.json)
```json
{
  "npmScope": "myorg",
  "affected": {
    "defaultBase": "main"
  },
  "tasksRunnerOptions": {
    "default": {
      "runner": "@nx/workspace/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "lint", "test", "e2e"]
      }
    }
  },
  "targetDependencies": {
    "build": [
      {
        "target": "build",
        "projects": "dependencies"
      }
    ]
  },
  "projects": {
    "my-app": {
      "tags": ["type:app", "scope:frontend"]
    },
    "my-lib": {
      "tags": ["type:lib", "scope:shared"]
    }
  }
}
```

## Gestion des dépendances dans un monorepo

### Dépendances inter-packages
```json
// packages/my-lib/package.json
{
  "name": "@myorg/my-lib",
  "version": "1.0.0",
  "dependencies": {
    "@myorg/utils": "^1.0.0"
  }
}
```

### Dépendances partagées
```javascript
// libs/shared/utils/src/lib/date-utils.ts
export const formatDate = (date) => {
  return new Date(date).toISOString().split('T')[0];
};

export const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};
```

## Stratégies de déploiement

### Déploiement indépendant
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        app: [frontend, backend, admin]
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: yarn install
      - name: Build ${{ matrix.app }}
        run: yarn nx build ${{ matrix.app }}
      - name: Deploy ${{ matrix.app }}
        run: |
          # Déploiement spécifique à chaque app
```

### Détection des changements
```javascript
// scripts/check-changes.js
const { execSync } = require('child_process');

function getChangedFiles() {
  const output = execSync('git diff --name-only HEAD~1 HEAD', { encoding: 'utf8' });
  return output.trim().split('\n');
}

function getAffectedProjects(changedFiles) {
  const projectMap = {
    'libs/ui': ['app1', 'app2'],
    'libs/utils': ['app1', 'admin'],
    'apps/app1': ['app1']
  };

  const affected = new Set();
  changedFiles.forEach(file => {
    for (const [lib, apps] of Object.entries(projectMap)) {
      if (file.startsWith(lib)) {
        apps.forEach(app => affected.add(app));
      }
    }
  });

  return Array.from(affected);
}

const changedFiles = getChangedFiles();
const affectedProjects = getAffectedProjects(changedFiles);
console.log('Projects affected by changes:', affectedProjects);
```

## Optimisation du CI/CD

### Cache dans Nx
```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: yarn install
      - name: Test affected projects only
        run: |
          npx nx affected --target=test --parallel=3
```

### Déploiement conditionnel
```json
// package.json
{
  "scripts": {
    "affected:build": "nx affected --target=build",
    "affected:test": "nx affected --target=test",
    "affected:deploy": "nx affected --target=deploy"
  }
}
```

## Gestion des versions

### Versioning indépendant vs verrouillé
```json
// Pour versioning indépendant (lerna)
{
  "version": "independent"
}
```

```json
// Pour versioning verrouillé
{
  "version": "1.0.0"
}
```

### Conventional commits dans monorepo
```json
// packages.json
{
  "release": {
    "branches": ["main"],
    "plugins": [
      "@semantic-release/github",
      [
        "@semantic-release/npm",
        {
          "pkgRoot": "dist/packages/my-package"
        }
      ]
    ]
  }
}
```

## Stratégies de test

### Tests unitaires
```javascript
// nx.json - configuration des tests
{
  "targetDefaults": {
    "test": {
      "dependsOn": ["^build"],
      "inputs": ["default", "^default"]
    }
  }
}
```

### Tests d'intégration
```bash
# Exécuter les tests d'intégration pour les packages affectés
nx affected --target=integration-test --parallel=2
```

## Génération de code

### Générateurs Nx
```bash
# Créer un générateur personnalisé
nx generate @nx/workspace:generator my-generator

# Utiliser un générateur
nx generate @myorg/my-generator:component --name=Button
```

### Exemple de générateur
```typescript
// tools/generators/component/index.ts
import { Tree, generateFiles, joinPathFragments } from '@nx/devkit';
import * as path from 'path';

interface Schema {
  name: string;
  directory?: string;
}

export default function (tree: Tree, options: Schema) {
  const projectRoot = options.directory 
    ? `libs/${options.directory}/src/lib/${options.name}`
    : `libs/ui/src/lib/${options.name}`;
    
  generateFiles(
    tree,
    path.join(__dirname, 'files'),
    projectRoot,
    { name: options.name }
  );
}
```

## Bonnes pratiques

### Organisation des packages
1. **Packages UI** : Composants réutilisables
2. **Packages Utils** : Fonctions utilitaires
3. **Packages Data Access** : Logique de gestion des données
4. **Applications** : Applications spécifiques

### Dépendances
- Éviter les cycles de dépendance
- Utiliser des tags Nx pour contrôler les dépendances
- Maintenir une architecture claire

### Performance
- Utiliser le cache Nx
- Exécuter uniquement les tests affectés
- Configurer correctement les entrées/sorties

### Sécurité
- Scanner les dépendances à chaque build
- Gérer les secrets de manière centralisée
- Appliquer des politiques de sécurité cohérentes
```