# Standards de linting

## Description
Ce document décrit les standards de linting et de formatage à utiliser dans les projets pour assurer une qualité de code cohérente.

## ESLint Configuration

### Base Configuration
```json
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "plugin:import/errors",
    "plugin:import/warnings"
  ],
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": [
    "react",
    "react-refresh",
    "import",
    "security"
  ],
  "rules": {
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "off",
    "react-refresh/only-export-components": [
      "warn",
      {
        "allowConstantExport": true
      }
    ],
    "import/order": [
      "error",
      {
        "groups": [
          "builtin",
          "external",
          "internal",
          "parent",
          "sibling",
          "index"
        ],
        "newlines-between": "always",
        "alphabetize": {
          "order": "asc",
          "caseInsensitive": true
        }
      }
    ],
    "security/detect-object-injection": "off",
    "no-console": "warn",
    "no-unused-vars": "error",
    "semi": ["error", "always"],
    "quotes": ["error", "single"]
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
```

## Prettier Configuration

### .prettierrc
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf"
}
```

## Husky & Lint-Staged

### package.json scripts
```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,css,md}": [
      "prettier --write"
    ]
  },
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint --fix .",
    "format": "prettier --write .",
    "prepare": "husky install"
  }
}
```

## TypeScript Configuration

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{"path": "./tsconfig.node.json"}]
}
```

## Git Hooks avec Husky

### .husky/pre-commit
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

## Scripts de validation

### Script de validation avant commit
```bash
#!/bin/bash

echo "Exécution des vérifications de code..."

# Linting
echo "Vérification ESLint..."
npx eslint src/ --ext .js,.jsx,.ts,.tsx

if [ $? -ne 0 ]; then
  echo "❌ Erreurs ESLint détectées"
  exit 1
fi

# Formatage
echo "Vérification du formatage..."
npx prettier --check src/**

if [ $? -ne 0 ]; then
  echo "❌ Fichiers mal formatés"
  exit 1
fi

echo "✅ Toutes les vérifications de code ont réussi"
```

## Configuration pour différents types de projets

### Projet React
- Utiliser `eslint-config-react-app` ou `@typescript-eslint/recommended`
- Activer les règles React spécifiques
- Vérifier les propriéts PropTypes

### Projet Node.js
- Activer les règles pour l'environnement Node.js
- Vérifier les imports/exports
- S'assurer de la sécurité des dépendances

### Projet Full-stack
- Appliquer des standards cohérents entre client et serveur
- Utiliser des configurations partagées
- Vérifier la cohérence du style de code
```