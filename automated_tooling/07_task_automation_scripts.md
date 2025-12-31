# Scripts d'automatisation de tâches

## Description
Ce document contient des scripts utiles pour automatiser les tâches récurrentes dans le développement logiciel.

## Scripts de développement

### Script de génération de composant React
```bash
#!/bin/bash

# Vérifier si le nom du composant est fourni
if [ -z "$1" ]; then
  echo "Usage: generate-component.sh <ComponentName>"
  exit 1
fi

COMPONENT_NAME=$1
COMPONENT_DIR="src/components/$COMPONENT_NAME"

# Créer le répertoire du composant
mkdir -p $COMPONENT_DIR

# Créer le fichier du composant
cat > "$COMPONENT_DIR/$COMPONENT_NAME.jsx" << EOF
import React from 'react';
import PropTypes from 'prop-types';

import './$COMPONENT_NAME.module.css';

const $COMPONENT_NAME = ({ children, className = '' }) => {
  return (
    <div className={'$COMPONENT_NAME ' + className}>
      <h2>$COMPONENT_NAME Component</h2>
      {children}
    </div>
  );
};

$COMPONENT_NAME.propTypes = {
  children: PropTypes.node,
  className: PropTypes.string
};

export default $COMPONENT_NAME;
EOF

# Créer le fichier CSS
cat > "$COMPONENT_DIR/$COMPONENT_NAME.module.css" << EOF
.$COMPONENT_NAME {
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  margin: 1rem 0;
}
EOF

# Créer le fichier de test
cat > "$COMPONENT_DIR/$COMPONENT_NAME.test.js" << EOF
import React from 'react';
import { render, screen } from '@testing-library/react';
import $COMPONENT_NAME from './$COMPONENT_NAME';

describe('$COMPONENT_NAME', () => {
  it('should render successfully', () => {
    const { baseElement } = render(<$COMPONENT_NAME />);
    expect(baseElement).toBeTruthy();
  });

  it('should render children', () => {
    render(<$COMPONENT_NAME>Test Content</$COMPONENT_NAME>);
    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });
});
EOF

echo "✅ Composant $COMPONENT_NAME généré avec succès dans $COMPONENT_DIR"
```

### Script de génération de service API
```bash
#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: generate-service.sh <ServiceName>"
  exit 1
fi

SERVICE_NAME=$1
SERVICE_DIR="src/services"

mkdir -p $SERVICE_DIR

cat > "$SERVICE_DIR/${SERVICE_NAME,,}.js" << EOF
class ${SERVICE_NAME}Service {
  constructor(baseURL) {
    this.baseURL = baseURL || process.env.API_BASE_URL;
    this.defaultHeaders = {
      'Content-Type': 'application/json',
    };
  }

  async request(endpoint, options = {}) {
    const url = this.baseURL + endpoint;
    const config = {
      headers: { ...this.defaultHeaders, ...options.headers },
      ...options,
    };

    try {
      const response = await fetch(url, config);
      if (!response.ok) {
        throw new Error(\`HTTP error! status: \${response.status}\`);
      }
      return await response.json();
    } catch (error) {
      console.error('API request error:', error);
      throw error;
    }
  }

  async get${SERVICE_NAME}(id) {
    return await this.request(\`/${SERVICE_NAME,,}/\${id}\`);
  }

  async getAll${SERVICE_NAME}s() {
    return await this.request(\`/${SERVICE_NAME,,}\`);
  }

  async create${SERVICE_NAME}(data) {
    return await this.request(\`/${SERVICE_NAME,,}\`, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async update${SERVICE_NAME}(id, data) {
    return await this.request(\`/${SERVICE_NAME,,}/\${id}\`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async delete${SERVICE_NAME}(id) {
    return await this.request(\`/${SERVICE_NAME,,}/\${id}\`, {
      method: 'DELETE',
    });
  }
}

export default ${SERVICE_NAME}Service;
EOF

echo "✅ Service ${SERVICE_NAME} généré avec succès"
```

## Scripts de test

### Script d'exécution des tests par type
```bash
#!/bin/bash

# Script pour exécuter différents types de tests

case "$1" in
  "unit")
    echo "🧪 Exécution des tests unitaires..."
    npm run test:unit
    ;;
  "integration")
    echo "🔬 Exécution des tests d'intégration..."
    npm run test:integration
    ;;
  "e2e")
    echo "🌐 Exécution des tests E2E..."
    npm run test:e2e
    ;;
  "all")
    echo "🧪🔬🌐 Exécution de tous les tests..."
    npm run test:unit
    npm run test:integration
    npm run test:e2e
    ;;
  *)
    echo "Usage: test-runner.sh [unit|integration|e2e|all]"
    exit 1
    ;;
esac
```

### Script de vérification de la couverture de test
```bash
#!/bin/bash

echo "📊 Analyse de la couverture de test..."

# Exécuter les tests avec couverture
npm run test:coverage

# Vérifier les seuils de couverture
COVERAGE_LINES=$(npx nyc report --reporter=text-summary | grep "Lines" | awk '{print $2}' | sed 's/%//')

if [ "$COVERAGE_LINES" -lt 80 ]; then
  echo "❌ Couverture de ligne insuffisante: $COVERAGE_LINES%"
  echo "⚠️  La couverture minimale est de 80%"
  exit 1
else
  echo "✅ Couverture de ligne: $COVERAGE_LINES%"
fi

echo "✅ Vérification de la couverture terminée"
```

## Scripts de sécurité

### Script de vérification des vulnérabilités
```bash
#!/bin/bash

echo "🔒 Vérification des vulnérabilités..."

# Vérifier avec npm audit
echo "🔍 Vérification avec npm audit..."
AUDIT_RESULT=$(npm audit --json | jq '.metadata.vulnerabilities')
HIGH_VULNS=$(echo $AUDIT_RESULT | jq '.high')
CRITICAL_VULNS=$(echo $AUDIT_RESULT | jq '.critical')

echo "Vulnérabilités trouvées:"
echo "  Hautes: $HIGH_VULNS"
echo "  Critiques: $CRITICAL_VULNS"

if [ "$CRITICAL_VULNS" -gt 0 ]; then
  echo "❌ Vulnérabilités critiques détectées"
  exit 1
fi

if [ "$HIGH_VULNS" -gt 0 ]; then
  echo "⚠️  Vulnérabilités hautes détectées"
  echo "Veuillez exécuter 'npm audit' pour plus de détails"
fi

# Vérifier les secrets
echo "🔍 Vérification des secrets..."
if command -v gitleaks &> /dev/null; then
  gitleaks detect --source . --verbose
else
  echo "⚠️  Gitleaks non installé, vérification des secrets ignorée"
fi

echo "✅ Vérification de sécurité terminée"
```

## Scripts de build

### Script de build conditionnel
```bash
#!/bin/bash

echo "🔨 Processus de build..."

# Vérifier les modifications
CHANGES=$(git diff --name-only HEAD~1 HEAD)

# Déterminer si un build complet est nécessaire
FULL_BUILD=false

for file in $CHANGES; do
  if [[ $file == *"package.json"* ]] || [[ $file == *"package-lock.json"* ]]; then
    FULL_BUILD=true
    break
  fi
done

if [ "$FULL_BUILD" = true ]; then
  echo "🔄 Build complet requis"
  npm run clean
  npm install
  npm run build
else
  echo "⚡ Build incrémental"
  npm run build
fi

echo "✅ Build terminé"
```

### Script de validation de build
```bash
#!/bin/bash

echo "✅ Validation du build..."

# Exécuter le build
npm run build

# Vérifier si le build a réussi
if [ $? -ne 0 ]; then
  echo "❌ Échec du build"
  exit 1
fi

# Vérifier la taille du bundle
BUNDLE_SIZE=$(du -sh dist/ | cut -f1)
echo "📦 Taille du bundle: $BUNDLE_SIZE"

# Vérifier la taille maximale autorisée (ex: 5MB)
MAX_SIZE="5M"
if [[ $(echo "$BUNDLE_SIZE > $MAX_SIZE" | bc -l) -eq 1 ]]; then
  echo "❌ Bundle trop volumineux: $BUNDLE_SIZE (max: $MAX_SIZE)"
  exit 1
fi

echo "✅ Validation du build terminée"
```

## Scripts de déploiement

### Script de déploiement avec validation
```bash
#!/bin/bash

# Variables
ENVIRONMENT=${1:-staging}
BRANCH=$(git branch --show-current)

echo "🚀 Déploiement vers $ENVIRONMENT sur la branche $BRANCH"

# Vérifier que nous sommes sur la bonne branche
case $ENVIRONMENT in
  "production")
    if [ "$BRANCH" != "main" ]; then
      echo "❌ Déploiement en production uniquement depuis main"
      exit 1
    fi
    ;;
  "staging")
    if [ "$BRANCH" != "develop" ]; then
      echo "❌ Déploiement en staging uniquement depuis develop"
      exit 1
    fi
    ;;
esac

# Exécuter les validations
echo "🔍 Validation avant déploiement..."
npm run validate

if [ $? -ne 0 ]; then
  echo "❌ Échec des validations"
  exit 1
fi

# Sauvegarder l'état actuel
echo "💾 Sauvegarde de l'état actuel..."
git tag "backup-$(date +%Y%m%d-%H%M%S)" || true

# Exécuter le déploiement
echo "🚀 Déploiement en cours..."
case $ENVIRONMENT in
  "production")
    # Commandes spécifiques à la production
    npm run deploy:prod
    ;;
  "staging")
    # Commandes spécifiques au staging
    npm run deploy:staging
    ;;
esac

if [ $? -eq 0 ]; then
  echo "✅ Déploiement réussi vers $ENVIRONMENT"
else
  echo "❌ Échec du déploiement"
  exit 1
fi
```

## Scripts de maintenance

### Script de nettoyage
```bash
#!/bin/bash

echo "🧹 Nettoyage du projet..."

# Supprimer les builds
echo "🗑️  Suppression des builds..."
rm -rf dist/ build/ .next/ coverage/

# Supprimer les modules node
echo "🗑️  Suppression des modules node..."
rm -rf node_modules/

# Supprimer les fichiers temporaires
echo "🗑️  Suppression des fichiers temporaires..."
find . -name "*.tmp" -type f -delete
find . -name "*.log" -type f -delete
find . -name ".DS_Store" -type f -delete

# Réinstaller les dépendances
echo "📦 Réinstallation des dépendances..."
npm install

echo "✅ Nettoyage terminé"
```

### Script de mise à jour des dépendances
```bash
#!/bin/bash

echo "🔄 Mise à jour des dépendances..."

# Sauvegarder le package-lock.json actuel
cp package-lock.json package-lock.json.backup

# Vérifier les mises à jour disponibles
echo "🔍 Vérification des mises à jour..."
npx npm-check-updates

# Mettre à jour les dépendances
echo "📦 Mise à jour des versions..."
npx npm-check-updates -u

# Installer les nouvelles versions
npm install

# Exécuter les tests pour s'assurer que tout fonctionne
echo "🧪 Vérification après mise à jour..."
npm test

if [ $? -ne 0 ]; then
  echo "❌ Tests échoués après mise à jour"
  echo "🔄 Restauration du package-lock.json précédent..."
  cp package-lock.json.backup package-lock.json
  npm install
  exit 1
fi

# Supprimer le backup
rm package-lock.json.backup

echo "✅ Mise à jour des dépendances terminée"
```

## Scripts de documentation

### Script de génération de documentation
```bash
#!/bin/bash

echo "📚 Génération de la documentation..."

# Générer la documentation avec JSDoc
npx jsdoc src/ -d docs/ -t node_modules/minami

# Générer la documentation d'API
if [ -f "swagger.json" ]; then
  npx redoc-cli build swagger.json --output docs/api.html
fi

# Vérifier la qualité de la documentation
echo "🔍 Vérification de la documentation..."
npx documentation lint src/**/*.js

if [ $? -ne 0 ]; then
  echo "⚠️  Problèmes détectés dans la documentation"
fi

echo "✅ Documentation générée dans le dossier docs/"
```

## Scripts utilitaires

### Script de recherche de code
```bash
#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: search-code.sh <pattern> [file-pattern]"
  exit 1
fi

PATTERN=$1
FILE_PATTERN=${2:-"*"}

echo "🔍 Recherche de '$PATTERN' dans $FILE_PATTERN..."

# Recherche dans les fichiers
grep -r -n -i --include="$FILE_PATTERN" "$PATTERN" src/

SEARCH_COUNT=$(grep -r -i --include="$FILE_PATTERN" "$PATTERN" src/ | wc -l)
echo "✅ $SEARCH_COUNT occurrences trouvées"
```

### Script de renommage de composant
```bash
#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: rename-component.sh <old-name> <new-name>"
  exit 1
fi

OLD_NAME=$1
NEW_NAME=$2

echo "🔄 Renommage du composant $OLD_NAME vers $NEW_NAME..."

# Trouver et renommer le répertoire
if [ -d "src/components/$OLD_NAME" ]; then
  mv "src/components/$OLD_NAME" "src/components/$NEW_NAME"
else
  echo "❌ Répertoire src/components/$OLD_NAME non trouvé"
  exit 1
fi

# Mettre à jour les noms dans les fichiers
find "src/components/$NEW_NAME" -type f -exec sed -i "s/$OLD_NAME/$NEW_NAME/g" {} \;
find "src/components/$NEW_NAME" -type f -exec sed -i "s/${OLD_NAME,,}/${NEW_NAME,,}/g" {} \;
find "src/components/$NEW_NAME" -type f -exec sed -i "s/${OLD_NAME^^}/${NEW_NAME^^}/g" {} \;

echo "✅ Composant renommé avec succès"
```

## Intégration dans les hooks Git

### Exemple de script pour pre-commit
```bash
#!/bin/bash

echo "🔍 Exécution des vérifications avant commit..."

# Vérifier le formatage
echo "📝 Vérification du formatage..."
npx prettier --check src/**

if [ $? -ne 0 ]; then
  echo "❌ Formatage incorrect, exécutez 'npx prettier --write src/**'"
  exit 1
fi

# Vérifier le linting
echo "🔍 Vérification du linting..."
npx eslint src/**

if [ $? -ne 0 ]; then
  echo "❌ Problèmes de linting détectés"
  exit 1
fi

# Exécuter les tests rapides
echo "🧪 Exécution des tests unitaires..."
npm run test:run

if [ $? -ne 0 ]; then
  echo "❌ Tests échoués"
  exit 1
fi

echo "✅ Toutes les vérifications avant commit ont réussi"
```

Ces scripts peuvent être adaptés selon les besoins spécifiques de chaque projet et ajoutés aux outils d'automatisation du développement.