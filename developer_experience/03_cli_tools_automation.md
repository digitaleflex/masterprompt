# Outils CLI d'automatisation

## Description
Ce document répertorie les outils CLI utiles pour automatiser les tâches de développement courantes.

## Outils de gestion de packages

### npm-check-updates
```bash
# Installation globale
npm install -g npm-check-updates

# Vérifier les mises à jour disponibles
ncu

# Vérifier un package spécifique
ncu -f package-name

# Mettre à jour le package.json
ncu -u

# Mettre à jour avec des filtres
ncu -f "/^@types/"  # Seulement les types TypeScript
ncu --semverLevel minor  # Seulement les versions mineures
```

### yarn-deduplicate
```bash
# Installation
npm install -g yarn-deduplicate

# Dédupliquer les dépendances
yarn-deduplicate
```

## Outils de génération de code

### plop
```bash
# Installation
npm install --save-dev plop

# Créer un fichier de configuration plopfile.js
const generatorConfig = {
  description: 'Créer un nouveau composant React',
  prompts: [
    {
      type: 'input',
      name: 'name',
      message: 'Nom du composant:'
    }
  ],
  actions: [
    {
      type: 'add',
      path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.jsx',
      templateFile: 'plop-templates/component.hbs'
    },
    {
      type: 'add',
      path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.module.css',
      templateFile: 'plop-templates/component.css.hbs'
    }
  ]
};

module.exports = function (plop) {
  plop.setGenerator('component', generatorConfig);
};
```

### hygen
```bash
# Installation
npm install --save-dev hygen

# Initialiser
npx hygen init self

# Créer un générateur
npx hygen generator new component

# Utiliser le générateur
npx hygen component new --name Button
```

## Outils de sécurité

### npm audit
```bash
# Vérifier les vulnérabilités
npm audit

# Vérifier avec un niveau de gravité spécifique
npm audit --audit-level moderate

# Réparer automatiquement
npm audit fix

# Générer un rapport JSON
npm audit --json > audit-report.json
```

### Snyk CLI
```bash
# Installation
npm install -g @snyk/cli

# Vérifier les vulnérabilités
snyk test

# Vérifier les licences
snyk test --policy-path=.snyk

# Fixer automatiquement
snyk wizard

# Générer un rapport
snyk test --json > snyk-report.json
```

## Outils de linting et de formatage

### ESLint CLI
```bash
# Linter un fichier
npx eslint file.js

# Linter et corriger automatiquement
npx eslint --fix src/

# Linter avec une configuration spécifique
npx eslint --config .eslintrc.custom.js src/

# Générer un rapport au format JSON
npx eslint src/ --format json --output-file eslint-report.json
```

### Prettier CLI
```bash
# Formater un fichier
npx prettier --write file.js

# Vérifier le formatage sans modification
npx prettier --check src/**

# Formater avec une configuration spécifique
npx prettier --config .prettierrc --write src/

# Formater seulement les fichiers modifiés
npx prettier --write "$(git diff --name-only --diff-filter=ACMR | grep -E '\\.(js|jsx|ts|tsx|css|scss|json)$' | xargs)"
```

## Outils de test

### Jest CLI
```bash
# Exécuter tous les tests
npx jest

# Exécuter les tests en mode watch
npx jest --watch

# Générer un rapport de couverture
npx jest --coverage

# Exécuter un test spécifique
npx jest src/components/Button.test.js

# Mettre à jour les snapshots
npx jest -u
```

### Cypress CLI
```bash
# Ouvrir l'interface graphique
npx cypress open

# Exécuter les tests en mode headless
npx cypress run

# Exécuter avec un navigateur spécifique
npx cypress run --browser chrome

# Exécuter un test spécifique
npx cypress run --spec "cypress/integration/login.spec.js"
```

## Outils de build et de déploiement

### Vite CLI
```bash
# Démarrer le serveur de développement
npx vite

# Créer un build de production
npx vite build

# Prévisualiser le build
npx vite preview

# Créer un build avec une configuration spécifique
npx vite build --config vite.config.prod.js
```

### Next.js CLI
```bash
# Démarrer en mode développement
npx next dev

# Créer un build
npx next build

# Démarrer en mode production
npx next start

# Analyser le bundle
npx next build && npx next-bundle-analyzer
```

## Outils de gestion de versions

### semantic-release
```bash
# Installation
npm install --save-dev semantic-release @semantic-release/github @semantic-release/npm

# Exécuter une release
npx semantic-release

# Simuler une release
npx semantic-release --dry-run
```

### conventional-changelog
```bash
# Générer un changelog
npx conventional-changelog -p angular -i CHANGELOG.md -s

# Générer et remplacer le fichier
npx conventional-changelog -p angular -i CHANGELOG.md -s -r 0
```

## Outils de documentation

### Storybook CLI
```bash
# Initialiser Storybook
npx sb init

# Démarrer Storybook
npx storybook dev -p 6006

# Créer un build de production
npx build-storybook

# Tester les stories
npx test-storybook
```

### JSDoc CLI
```bash
# Générer la documentation
npx jsdoc src/ -d docs/

# Utiliser un template personnalisé
npx jsdoc src/ -d docs/ -t node_modules/minami
```

## Outils d'analyse de code

### Bundle analyzer
```bash
# Pour Webpack
npx webpack-bundle-analyzer dist/main.js

# Pour Vite
npx vite-bundle-analyzer

# Pour Next.js
npx @next/bundle-analyzer
```

### Complexity analysis
```bash
# Installation
npm install -g analyze-complexity

# Analyser la complexité cyclomatique
npx analyze-complexity src/

# Avec des options
npx analyze-complexity --max-complexity 5 --ignore "node_modules,test" src/
```

## Scripts d'automatisation personnalisés

### Script de validation de commit
```bash
#!/bin/bash
# validate-commit.sh

echo "🔍 Vérification du format du message de commit..."

COMMIT_MSG_FILE=$1
COMMIT_MESSAGE=$(cat $COMMIT_MSG_FILE)

# Vérifier le format conventional commits
if ! echo "$COMMIT_MESSAGE" | grep -Eq "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,}$"; then
  echo "❌ Le message de commit ne suit pas le format conventional commits"
  echo "Exemple: feat(auth): add login functionality"
  exit 1
fi

echo "✅ Message de commit valide"
```

### Script de pré-déploiement
```bash
#!/bin/bash
# pre-deploy.sh

echo "🚀 Préparation au déploiement..."

# Vérifier le statut Git
if ! git diff-index --quiet HEAD --; then
  echo "❌ Le dépôt contient des modifications non commitées"
  exit 1
fi

# Exécuter les tests
echo "🧪 Exécution des tests..."
npm run test:ci
if [ $? -ne 0 ]; then
  echo "❌ Les tests ont échoué"
  exit 1
fi

# Vérifier la couverture de test
echo "📊 Vérification de la couverture..."
npm run test:coverage
if [ $? -ne 0 ]; then
  echo "❌ La couverture de test n'est pas suffisante"
  exit 1
fi

# Vérifier la sécurité
echo "🔒 Vérification de la sécurité..."
npm run security:check
if [ $? -ne 0 ]; then
  echo "❌ Problèmes de sécurité détectés"
  exit 1
fi

echo "✅ Pré-déploiement terminé avec succès"
```

## Outils de collaboration

### Lint-staged CLI
```bash
# Exécuter des commandes sur les fichiers stagés
npx lint-staged

# Avec une configuration spécifique
npx lint-staged --config lint-staged.config.js
```

### Commitizen
```bash
# Installation
npm install --save-dev commitizen cz-conventional-changelog

# Initialiser
npx commitizen init cz-conventional-changelog --save-dev

# Utiliser
npx git-cz
```

## Outils de performance

### Lighthouse CLI
```bash
# Analyser un site web
npx lighthouse http://localhost:3000 --output json --output-path report.json

# Analyser avec des catégories spécifiques
npx lighthouse http://localhost:3000 --only-categories=performance,accessibility
```

### Bundle size
```bash
# Vérifier la taille des bundles
npx bundlesize

# Avec une configuration
npx bundlesize --config bundlesize.config.json
```

## Configuration des outils dans package.json

### Scripts utiles
```json
{
  "scripts": {
    "analyze": "npx webpack-bundle-analyzer dist/main.js",
    "security": "npm audit && npx snyk test",
    "validate": "npm run lint && npm run test && npm run type-check",
    "precommit": "npx lint-staged",
    "release": "npx semantic-release",
    "docs": "npx jsdoc src/ -d docs/",
    "perf": "npx lighthouse http://localhost:3000 --output json"
  }
}
```

## Création d'outils CLI personnalisés

### Exemple simple avec Node.js
```javascript
#!/usr/bin/env node
// generate-component.js

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const componentName = process.argv[2];

if (!componentName) {
  console.error('Usage: generate-component <ComponentName>');
  process.exit(1);
}

const componentDir = path.join('src', 'components', componentName);

// Créer le répertoire
if (!fs.existsSync(componentDir)) {
  fs.mkdirSync(componentDir, { recursive: true });
}

// Créer le fichier du composant
const componentContent = `import React from 'react';
import './${componentName}.module.css';

const ${componentName} = () => {
  return (
    <div className="${componentName}">
      <h1>${componentName} Component</h1>
    </div>
  );
};

export default ${componentName};
`;

fs.writeFileSync(path.join(componentDir, `${componentName}.jsx`), componentContent);

// Créer le fichier CSS
const cssContent = `.${componentName} {
  /* Styles pour ${componentName} */
}
`;

fs.writeFileSync(path.join(componentDir, `${componentName}.module.css`), cssContent);

console.log(`✅ Composant ${componentName} généré avec succès!`);
```

Rendez-le exécutable et ajoutez-le aux scripts :
```json
{
  "bin": {
    "generate-component": "./scripts/generate-component.js"
  },
  "scripts": {
    "generate": "node scripts/generate-component.js"
  }
}
```