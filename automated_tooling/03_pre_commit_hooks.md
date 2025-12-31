# Hooks de pré-commit

## Description
Ce document décrit les hooks de pré-commit à utiliser pour garantir la qualité du code avant chaque commit.

## Installation de Husky

### Initialisation
```bash
npm install --save-dev husky
npm pkg set scripts.prepare="husky install"
npm run prepare
```

### Activation des hooks
```bash
npx husky add .husky/pre-commit "npx lint-staged"
```

## Hooks de pré-commit complets

### .husky/pre-commit
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Vérifier le formatage et le linting
npx lint-staged

# Exécuter les tests unitaires
npm run test:run

# Vérifier la sécurité
npm run security:check

echo "✅ Pré-commit checks terminés avec succès"
```

### .husky/commit-msg
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Vérifier le format du message de commit
npx commitlint --edit "$1"
```

## Configuration de lint-staged

### package.json
```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "git add"
    ],
    "*.{json,css,md}": [
      "prettier --write",
      "git add"
    ],
    "*.{js,jsx,ts,tsx}": [
      "npm run test:file"
    ]
  }
}
```

## Hooks de pré-push

### .husky/pre-push
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Exécuter tous les tests avant le push
npm run test

# Vérifier la couverture de test
npm run test:coverage

# Vérifier les vulnérabilités
npm audit

# Vérifier les dépendances
npx lockfile-lint --path package-lock.json --validate-https --allowed-hosts npm

echo "✅ Pré-push checks terminés avec succès"
```

## Hooks de sécurité

### .husky/pre-commit (sécurité)
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Vérifier les secrets dans le code
npx @microsoft/secretscan --include . --exclude node_modules

# Vérifier les vulnérabilités
npm audit --audit-level moderate

# Vérifier les dépendances non approuvées
npx npm-check-updates --error-level 2

echo "✅ Vérifications de sécurité terminées"
```

## Hooks de qualité de code

### .husky/pre-commit (qualité)
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Vérifier le linting
npx eslint --fix .

# Vérifier le formatage
npx prettier --write .

# Vérifier la qualité du code avec SonarQube local
npx sonarqube-scanner

# Vérifier la duplication de code
npx jscpd src/**

echo "✅ Vérifications de qualité terminées"
```

## Hooks de test

### .husky/pre-commit (tests)
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Exécuter les tests unitaires
npm run test:run

# Exécuter les tests de mutation
npx stryker run

# Vérifier la couverture de test
npx nyc report --reporter=html --report-dir=./coverage

# Vérifier que la couverture est suffisante
npx nyc check-coverage --lines 80 --functions 80 --branches 80

echo "✅ Tests terminés avec succès"
```

## Hooks personnalisés

### Vérification de la convention de nommage
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Vérifier que les fichiers suivent la convention de nommage
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx|ts|tsx)$'); do
  if [[ $file =~ [A-Z] ]] && [[ ! $file =~ node_modules ]]; then
    echo "❌ Le fichier $file contient des majuscules. Utilisez le format kebab-case ou camelCase."
    exit 1
  fi
done

echo "✅ Vérification de la convention de nommage terminée"
```

### Vérification de la taille des fichiers
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Vérifier que les fichiers n'excèdent pas une certaine taille
MAX_SIZE=100000  # 100KB en octets

for file in $(git diff --cached --name-only --diff-filter=ACM); do
  size=$(stat -c%s "$file" 2>/dev/null || echo 0)
  if [ $size -gt $MAX_SIZE ]; then
    echo "❌ Le fichier $file est trop volumineux ($size octets). Maximum: $MAX_SIZE octets."
    exit 1
  fi
done

echo "✅ Vérification de la taille des fichiers terminée"
```

## Exemple complet de configuration

### .husky/pre-commit (complet)
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Fonction pour afficher les messages avec des couleurs
print_status() {
  echo "\033[0;34m$1\033[0m"
}

print_success() {
  echo "\033[0;32m$1\033[0m"
}

print_error() {
  echo "\033[0;31m$1\033[0m"
}

print_status "🔍 Vérification du formatage et du linting..."
npx lint-staged
if [ $? -ne 0 ]; then
  print_error "❌ Échec du formatage ou du linting"
  exit 1
fi

print_status "🧪 Exécution des tests..."
npm run test:run
if [ $? -ne 0 ]; then
  print_error "❌ Échec des tests"
  exit 1
fi

print_status "🔒 Vérification de la sécurité..."
npm audit --audit-level moderate
if [ $? -ne 0 ]; then
  print_error "❌ Problèmes de sécurité détectés"
  exit 1
fi

print_success "✅ Tous les hooks de pré-commit ont réussi!"
```