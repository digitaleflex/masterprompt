# Optimisation du CI/CD

## Description
Ce document présente des stratégies et configurations pour optimiser les pipelines CI/CD (Intégration Continue / Déploiement Continue).

## Optimisation des builds

### Cache dans CI/CD
```yaml
# Exemple pour GitHub Actions
name: CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'  # Activer le cache npm
      
      - name: Cache node modules
        uses: actions/cache@v3
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-modules-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-modules-
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
```

### Cache multi-niveaux
```yaml
# Cache des dépendances + build
name: Optimized CI
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # Cache des dépendances
      - name: Cache dependencies
        id: cache-deps
        uses: actions/cache@v3
        with:
          path: |
            node_modules
            ~/.cache/Cypress
          key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}
      
      - name: Install dependencies
        if: steps.cache-deps.outputs.cache-hit != 'true'
        run: npm ci
      
      # Cache des builds
      - name: Cache build
        id: cache-build
        uses: actions/cache@v3
        with:
          path: |
            dist/
            build/
            .next/
          key: ${{ runner.os }}-build-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-build-
      
      - name: Build if needed
        if: steps.cache-build.outputs.cache-hit != 'true'
        run: npm run build
      
      - name: Run tests
        run: npm test
```

## Optimisation des tests

### Tests parallèles
```yaml
# GitHub Actions avec tests parallèles
name: Parallel Tests
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # Diviser les tests en 4 lots
        partition: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run partition ${{ matrix.partition }}
        run: |
          npm run test -- --shard=${{ matrix.partition }}/4
```

### Tests conditionnels
```yaml
# Exécuter des tests spécifiques selon les fichiers modifiés
name: Conditional Tests
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      frontend-tests: ${{ steps.changes.outputs.frontend }}
      backend-tests: ${{ steps.changes.outputs.backend }}
    steps:
      - uses: actions/checkout@v3
      
      - name: Check for changes
        uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'src/components/**'
              - 'src/pages/**'
              - 'src/hooks/**'
            backend:
              - 'api/**'
              - 'server/**'
              - 'models/**'
  
  frontend-tests:
    needs: test
    if: ${{ needs.test.outputs.frontend-tests == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm run test:frontend
  
  backend-tests:
    needs: test
    if: ${{ needs.test.outputs.backend-tests == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm run test:backend
```

## Optimisation des déploiements

### Déploiement par environnement
```yaml
# Déploiement conditionnel par branche
name: Deploy
on:
  push:
    branches: [main, develop, staging]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.ref_name == 'main' && 'production' || github.ref_name == 'staging' && 'staging' || 'development' }}
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to ${{ env.ENVIRONMENT }}
        run: |
          case ${{ github.ref_name }} in
            "main")
              echo "Deploying to production"
              npm run deploy:prod
              ;;
            "staging")
              echo "Deploying to staging"
              npm run deploy:staging
              ;;
            *)
              echo "Deploying to development"
              npm run deploy:dev
              ;;
          esac
        env:
          ENVIRONMENT: ${{ github.ref_name }}
```

### Déploiement incrémental
```yaml
# Déploiement basé sur les modifications
name: Incremental Deploy
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Récupérer l'historique complet
      
      - name: Detect changes
        run: |
          # Vérifier les fichiers modifiés
          CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
          echo "Files changed: $CHANGED_FILES"
          
          # Déterminer ce qu'il faut déployer
          if [[ $CHANGED_FILES == *"src/"* ]]; then
            echo "FRONTEND_CHANGED=true" >> $GITHUB_ENV
          fi
          
          if [[ $CHANGED_FILES == *"api/"* ]]; then
            echo "BACKEND_CHANGED=true" >> $GITHUB_ENV
          fi
      
      - name: Deploy frontend
        if: env.FRONTEND_CHANGED == 'true'
        run: |
          npm run build:frontend
          # Déployer le frontend
      
      - name: Deploy backend
        if: env.BACKEND_CHANGED == 'true'
        run: |
          npm run build:backend
          # Déployer le backend
```

## Optimisation de la sécurité

### Vérification de sécurité avant déploiement
```yaml
# Pipeline de sécurité intégré
name: Secure Pipeline
on: [push]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Dependency Security Scan
        run: |
          npm audit --audit-level high
          # ou
          npx @microsoft/sbom-tool generate -o ./sbom
          npx @microsoft/sbom-tool validate -f ./sbom
        
      - name: Code Security Scan
        uses: github/super-linter@v4
        env:
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        
      - name: Secret Detection
        uses: trufflesecurity/truffleHog@main
        with:
          path: ./
```

### Scan des vulnérabilités
```yaml
# Scan des vulnérabilités en parallèle
name: Security Scans
on: [push, pull_request]

jobs:
  security-scans:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        scan-type: [npm-audit, snyk, codeql]
    steps:
      - uses: actions/checkout@v3
      
      - name: Run ${{ matrix.scan-type }} scan
        run: |
          case ${{ matrix.scan-type }} in
            "npm-audit")
              npm audit --audit-level moderate --json > npm-audit-report.json
              ;;
            "snyk")
              npx snyk test --json > snyk-report.json
              ;;
            "codeql")
              # CodeQL est géré par une action GitHub
              ;;
          esac
```

## Optimisation des ressources

### Utilisation conditionnelle des ressources
```yaml
# Utilisation de machines différentes selon les besoins
name: Resource Optimized CI
on: [push]

jobs:
  lightweight-tests:
    runs-on: ubuntu-20.04  # Machine légère pour tests rapides
    steps:
      - uses: actions/checkout@v3
      - run: npm run test:unit  # Tests unitaires rapides
  
  heavy-tests:
    runs-on: ubuntu-latest  # Machine plus puissante pour tests lourds
    steps:
      - uses: actions/checkout@v3
      - run: npm run test:e2e  # Tests end-to-end qui nécessitent plus de ressources
  
  build:
    runs-on: ubuntu-latest
    needs: [lightweight-tests, heavy-tests]  # Ne commence que si les tests passent
    steps:
      - uses: actions/checkout@v3
      - run: npm run build
```

### Matrice de tests optimisée
```yaml
# Matrice de tests avec exclusion stratégique
name: Optimized Test Matrix
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest]
        exclude:
          # Exclure les combinaisons inutiles
          - os: windows-latest
            node-version: 16  # Ne pas tester Node 16 sur Windows si non nécessaire
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test
```

## Optimisation des temps d'exécution

### Préchargement des dépendances
```yaml
# Utilisation d'images préchargées avec dépendances
name: Fast CI
on: [push]

jobs:
  build:
    runs-on: self-hosted  # ou une image personnalisée
    container:
      image: node:18-alpine  # Image avec les outils préinstallés
    steps:
      - uses: actions/checkout@v3
      # Pas besoin d'installer les dépendances de base
      
      - name: Install project dependencies
        run: npm ci  # Seulement les dépendances du projet
```

### Exécution conditionnelle
```yaml
# Exécution basée sur les labels ou les branches
name: Conditional Execution
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  run-if-not-wip:
    if: ${{ !contains(github.event.pull_request.title, 'WIP') && !contains(github.event.pull_request.labels.*.name, 'do-not-merge') }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
```

## Optimisation des dépôts Docker

### Build Docker optimisé
```dockerfile
# Dockerfile optimisé pour CI
# Utiliser une image multi-stage
FROM node:18-alpine AS builder

# Installer les dépendances d'abord pour le cache
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Copier le code source
COPY . .
RUN npm run build

# Image finale minimale
FROM node:18-alpine AS runner
WORKDIR /app

# Copier les dépendances du stage précédent
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Cache Docker dans CI
```yaml
# GitHub Actions avec cache Docker
name: Optimized Docker Build
on: [push]

jobs:
  docker-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Cache Docker layers
        uses: actions/cache@v3
        with:
          path: /tmp/.buildx-cache
          key: ${{ runner.os }}-buildx-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-buildx-
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: false
          tags: myapp:${{ github.sha }}
          cache-from: type=local,src=/tmp/.buildx-cache
          cache-to: type=local,dest=/tmp/.buildx-cache-new
          
      # Sauvegarder le cache pour la prochaine exécution
      - name: Move cache
        run: |
          rm -rf /tmp/.buildx-cache
          mv /tmp/.buildx-cache-new /tmp/.buildx-cache
```

## Monitoring et alerting

### Monitoring des performances CI
```yaml
# Collecte des métriques de performance
name: Performance Monitoring
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests with timing
        run: |
          START_TIME=$(date +%s)
          npm test
          END_TIME=$(date +%s)
          DURATION=$((END_TIME - START_TIME))
          echo "TEST_DURATION=$DURATION" >> $GITHUB_ENV
          
      - name: Report performance
        run: |
          echo "Tests took ${{ env.TEST_DURATION }} seconds"
          # Envoyer les métriques à un service de monitoring
```

## Bonnes pratiques d'optimisation

### 1. Cache stratégique
- Mettre en cache les dépendances
- Mettre en cache les builds
- Utiliser des clés de cache intelligentes

### 2. Parallélisation
- Exécuter les tests en parallèle
- Diviser les tâches lourdes
- Utiliser des matrices pour tester différentes configurations

### 3. Exécution conditionnelle
- N'exécuter que les tests affectés
- Déployer seulement si nécessaire
- Vérifier les changements avant d'exécuter

### 4. Optimisation des ressources
- Utiliser les bonnes machines pour chaque tâche
- Réutiliser les résultats de builds
- Minimiser les images Docker

### 5. Feedback rapide
- Exécuter les tests rapides en premier
- Avoir des checks préliminaires
- Fournir des retours immédiats aux développeurs
```