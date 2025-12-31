# Gestion des dépendances

## Description
Ce document décrit les meilleures pratiques et outils pour gérer efficacement les dépendances dans les projets de développement.

## Vérification des vulnérabilités

### npm audit
```bash
# Vérifier les vulnérabilités
npm audit

# Vérifier avec un niveau de gravité spécifique
npm audit --audit-level moderate

# Réparer automatiquement les vulnérabilités
npm audit fix

# Réparer avec des modifications majeures
npm audit fix --force

# Générer un rapport au format JSON
npm audit --json > audit-report.json
```

### Script de vérification dans package.json
```json
{
  "scripts": {
    "security:audit": "npm audit --audit-level moderate",
    "security:fix": "npm audit fix",
    "security:check": "npm audit --audit-level high && echo '✅ Aucune vulnérabilité critique'"
  }
}
```

## Mise à jour des dépendances

### npm-check-updates
```bash
# Installer l'outil
npm install -g npm-check-updates

# Vérifier les mises à jour disponibles
ncu

# Vérifier pour un package spécifique
ncu -f package-name

# Mettre à jour le package.json
ncu -u

# Mettre à jour avec des filtres
ncu -f "/^@types/"  # Seulement les types TypeScript
```

### Script de mise à jour dans package.json
```json
{
  "scripts": {
    "deps:check": "ncu",
    "deps:update": "ncu -u && npm install",
    "deps:security": "npm audit && ncu --audit",
    "deps:outdated": "npm outdated"
  }
}
```

## Analyse de la composition logicielle

### Utilisation de tools comme Snyk
```bash
# Installer Snyk CLI
npm install -g @snyk/cli

# Vérifier les vulnérabilités
snyk test

# Vérifier les licences
snyk test --policy-path=.snyk

# Générer un rapport
snyk test --json > snyk-report.json
```

## Gestion des dépendances de développement vs production

### Différences de gestion
```json
{
  "dependencies": {
    // Dépendances de production
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.4.0"
  },
  "devDependencies": {
    // Dépendances de développement
    "vite": "^4.3.2",
    "eslint": "^8.39.0",
    "jest": "^29.5.0",
    "@types/react": "^18.0.28"
  }
}
```

### Installation séparée
```bash
# Installation de dépendances de production
npm install package-name

# Installation de dépendances de développement
npm install package-name --save-dev
```

## Lockfiles et reproductibilité

### Utilisation de package-lock.json
```bash
# S'assurer que le lockfile est à jour
npm ci  # Utilise exactement les versions du lockfile

# Vérifier la cohérence
npm audit --package-lock-only
```

### Vérification de la validité du lockfile
```bash
# Vérifier que package.json et package-lock.json sont synchronisés
npm ls
```

## Gestion des scopes et alias

### Utilisation de scopes npm
```json
{
  "dependencies": {
    "@scope/package-name": "^1.0.0"
  }
}
```

### Alias de dépendances
```json
{
  "resolutions": {
    // Pour Yarn
    "lodash": "4.17.21"
  },
  "pnpm": {
    // Pour pnpm
    "overrides": {
      "lodash": "4.17.21"
    }
  }
}
```

## Détection des dépendances inutilisées

### Unimported
```bash
# Installer l'outil
npm install -g unimported

# Vérifier les dépendances inutilisées
unimported

# Générer un rapport
unimported --format json > unused-report.json
```

### Depcheck
```bash
# Installer
npm install -g depcheck

# Vérifier
depcheck

# Vérifier avec des options
depcheck --ignores="eslint,prettier,jest" --ignore-dirs="dist,build"
```

## Gestion des registres privés

### Configuration d'un registre privé
```bash
# Configurer un registre spécifique
npm set registry https://registry.company.com

# Utiliser un registre pour un scope spécifique
npm set @mycompany:registry https://registry.company.com
```

### .npmrc pour configuration du registre
```
registry=https://registry.npmjs.org/
@mycompany:registry=https://registry.company.com/
//registry.company.com/:_authToken=YOUR_TOKEN
```

## Stratégies de gestion des dépendances

### Dépendances fixes vs flexibles
```json
{
  "dependencies": {
    // Version exacte (fixe)
    "fixed-package": "1.2.3",
    
    // Version compatible avec le patch
    "patch-package": "~1.2.3",
    
    // Version compatible avec le mineur
    "minor-package": "^1.2.3",
    
    // Dernière version
    "latest-package": "*"
  }
}
```

### Gestion des dépendances transitoires
```json
{
  "pnpm": {
    // Pour pnpm - gestion stricte des dépendances transitoires
    "strict-peer-dependencies": true
  }
}
```

## Outils de gestion avancée

### Renovate
```json
{
  "extends": [
    "config:base"
  ],
  "schedule": [
    "before 4am on Monday"
  ],
  "labels": ["dependencies"],
  "packageRules": [
    {
      "depTypeList": ["devDependencies"],
      "automerge": true
    }
  ]
}
```

### Dependabot
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "automerge"
```

## Scripts de gestion des dépendances

### Script de vérification complète
```bash
#!/bin/bash

echo "🔍 Vérification des dépendances..."

# Vérifier les vulnérabilités
echo "🔒 Vérification de la sécurité..."
npm audit --audit-level moderate
if [ $? -ne 0 ]; then
  echo "❌ Vulnérabilités détectées"
  exit 1
fi

# Vérifier les dépendances inutilisées
echo "🧹 Vérification des dépendances inutilisées..."
npx depcheck
if [ $? -ne 0 ]; then
  echo "⚠️  Dépendances inutilisées détectées"
fi

# Vérifier les mises à jour
echo "🔄 Vérification des mises à jour..."
npx npm-check-updates --error-level 2
if [ $? -eq 0 ]; then
  echo "✅ Toutes les dépendances sont à jour"
else
  echo "ℹ️  Des mises à jour sont disponibles"
fi

echo "✅ Vérification des dépendances terminée"
```

## Politiques de gestion des dépendances

### Politique de sécurité
- Toutes les dépendances doivent être auditées pour les vulnérabilités
- Les dépendances avec des vulnérabilités critiques ne doivent pas être utilisées
- Les dépendances doivent être maintenues (dernière mise à jour < 1 an)

### Politique de licence
- Vérifier les licences des dépendances
- Éviter les licences restrictives pour les projets open source
- Maintenir une liste blanche de licences approuvées
```