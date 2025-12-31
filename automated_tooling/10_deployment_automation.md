# Automatisation du déploiement

## Description
Ce document présente des stratégies et outils pour automatiser les déploiements d'applications dans différents environnements.

## Déploiement continu (CD)

### Pipeline de déploiement basique
```yaml
# .github/workflows/deploy.yml
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
        with:
          fetch-depth: 0
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build application
        run: npm run build
        env:
          NODE_ENV: ${{ github.ref_name == 'main' && 'production' || 'development' }}
      
      - name: Deploy to ${{ vars.ENVIRONMENT_NAME }}
        run: |
          # Déploiement selon l'environnement
          case ${{ github.ref_name }} in
            "main")
              echo "Deploying to production"
              ./scripts/deploy-production.sh
              ;;
            "staging")
              echo "Deploying to staging"
              ./scripts/deploy-staging.sh
              ;;
            *)
              echo "Deploying to development"
              ./scripts/deploy-development.sh
              ;;
          esac
        env:
          API_URL: ${{ secrets.API_URL }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          JWT_SECRET: ${{ secrets.JWT_SECRET }}
```

## Déploiement avec validation

### Déploiement avec étape de validation manuelle
```yaml
# .github/workflows/deploy-with-approval.yml
name: Deploy with Approval

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
      - run: npm run build
  
  approval:
    needs: test
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Wait for approval
        run: echo "Waiting for manual approval"
  
  deploy:
    needs: [test, approval]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to production
        run: ./scripts/deploy-production.sh
```

## Déploiement blue-green

### Script de déploiement blue-green
```bash
#!/bin/bash

# Variables
APP_NAME="my-app"
BLUE_PORT=3000
GREEN_PORT=3001
NEW_PORT=$BLUE_PORT
OLD_PORT=$GREEN_PORT
LOAD_BALANCER="http://localhost:8080"

# Déterminer les ports à utiliser
if [ "$(curl -s $LOAD_BALANCER/status)" == "green" ]; then
  NEW_PORT=$BLUE_PORT
  OLD_PORT=$GREEN_PORT
  NEW_COLOR="blue"
  OLD_COLOR="green"
else
  NEW_PORT=$GREEN_PORT
  OLD_PORT=$BLUE_PORT
  NEW_COLOR="green"
  OLD_COLOR="blue"
fi

echo "Déploiement vers $NEW_COLOR (port $NEW_PORT)"

# Démarrer la nouvelle version
echo "Démarrage de la nouvelle version sur le port $NEW_PORT..."
npm run build
PORT=$NEW_PORT npm start &

# Attendre que la nouvelle version soit prête
sleep 10

# Vérifier que la nouvelle version fonctionne
if curl -f http://localhost:$NEW_PORT/health; then
  echo "✅ Nouvelle version prête sur $NEW_COLOR"
  
  # Rediriger le trafic vers la nouvelle version
  echo "🔄 Redirection du trafic vers $NEW_COLOR..."
  curl -X POST $LOAD_BALANCER/switch -d "port=$NEW_PORT"
  
  # Attendre un peu pour s'assurer que le trafic est redirigé
  sleep 5
  
  # Arrêter l'ancienne version
  echo "🛑 Arrêt de l'ancienne version sur $OLD_COLOR..."
  curl -X POST http://localhost:$OLD_PORT/stop
  
  echo "✅ Déploiement blue-green terminé avec succès"
else
  echo "❌ La nouvelle version n'est pas prête, rollback vers l'ancienne version"
  exit 1
fi
```

## Déploiement canary

### Configuration de déploiement canary avec Nginx
```nginx
# nginx-canary.conf
upstream backend {
  # 90% du trafic vers la version stable
  server backend-stable:3000 weight=90;
  # 10% du trafic vers la nouvelle version
  server backend-canary:3001 weight=10;
}

server {
  listen 80;
  
  location / {
    proxy_pass http://backend;
  }
  
  # Endpoint pour forcer le trafic vers la nouvelle version (pour les tests)
  location /canary-test {
    proxy_pass http://backend-canary:3001;
  }
}
```

### Script de déploiement canary
```bash
#!/bin/bash

# Variables
CANARY_TRAFFIC_PERCENT=10
MAX_TRAFFIC_PERCENT=100
STEP=10
APP_NAME="my-app"

echo "🚀 Début du déploiement canary pour $APP_NAME"

# Déployer la nouvelle version
echo "📦 Déploiement de la nouvelle version..."
kubectl apply -f k8s/canary-deployment-new.yaml

# Attendre que la nouvelle version soit prête
sleep 30

# Graduellement augmenter le trafic vers la nouvelle version
for percentage in $(seq $STEP $STEP $MAX_TRAFFIC_PERCENT); do
  echo "📊 Ajustement du trafic vers $percentage% pour la nouvelle version..."
  
  # Mettre à jour la configuration du load balancer
  ./scripts/update-canary-weight.sh $percentage
  
  # Attendre un peu pour observer les métriques
  sleep 60
  
  # Vérifier les métriques de santé
  if ! ./scripts/check-health-metrics.sh; then
    echo "❌ Métriques de santé dégradées à $percentage%, rollback!"
    ./scripts/rollback-canary.sh
    exit 1
  fi
  
  echo "✅ Métriques OK à $percentage%"
done

echo "✅ Déploiement canary terminé avec succès"
```

## Déploiement avec Kubernetes

### Déploiement avec Helm
```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 3000
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          env:
            - name: NODE_ENV
              value: {{ .Values.environment }}
            - name: API_URL
              valueFrom:
                secretKeyRef:
                  name: {{ include "myapp.fullname" . }}-secrets
                  key: api_url
```

### Values pour environnements différents
```yaml
# environments/production.yaml
replicaCount: 3
image:
  repository: my-registry/my-app
  tag: "v1.2.3"
  pullPolicy: Always

environment: production

resources:
  limits:
    cpu: 500m
    memory: 1Gi
  requests:
    cpu: 250m
    memory: 512Mi

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  hosts:
    - host: myapp.com
      paths:
        - path: /
          pathType: ImplementationSpecific
```

## Déploiement sur différents clouds

### Déploiement sur AWS avec AWS Copilot
```yaml
# copilot/my-app/manifest.yml
# Application Load Balanced Web Service
name: my-app
type: Load Balanced Web Service

http:
  path: '/'
  healthcheck: '/health'

image:
  build: Dockerfile
  cache_from:
    - my-registry/my-app:latest

variables:
  NODE_ENV: production

secrets:
  - DB_PASSWORD
  - JWT_SECRET

count: 2
memory: 1024
cpu: 512

variables:
  LOG_LEVEL: info
```

### Déploiement sur Vercel
```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/node",
      "config": {
        "includeFiles": ["dist/**"]
      }
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/index.js"
    },
    {
      "src": "/(.*)",
      "dest": "/dist/index.html"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  }
}
```

### Déploiement sur Netlify
```toml
# netlify.toml
[build]
  command = "npm run build"
  publish = "dist"
  functions = "functions"

[context.production]
  command = "npm run build:prod"

[context.deploy-preview]
  command = "npm run build:preview"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[template.environment]
  API_URL = "API endpoint URL"
```

## Déploiement avec Docker

### Docker Compose pour différents environnements
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    build: .
    image: my-registry/my-app:${IMAGE_TAG:-latest}
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    ports:
      - "3000:3000"
    depends_on:
      - db
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    restart: unless-stopped

volumes:
  postgres_data:
```

### Script de déploiement Docker
```bash
#!/bin/bash

# Variables
IMAGE_NAME="my-registry/my-app"
ENVIRONMENT=${1:-production}
IMAGE_TAG=${2:-$(git rev-parse --short HEAD)}

echo "🚀 Déploiement de l'image $IMAGE_NAME:$IMAGE_TAG dans $ENVIRONMENT"

# Connexion au registry
echo "🔐 Connexion au registry..."
docker login my-registry.com

# Construction de l'image
echo "🔨 Construction de l'image..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Tagging pour le registry
docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest

# Pousser l'image
echo "📤 Pousser l'image vers le registry..."
docker push $IMAGE_NAME:$IMAGE_TAG
docker push $IMAGE_NAME:latest

# Mise à jour du déploiement Kubernetes
echo "🔄 Mise à jour du déploiement Kubernetes..."
kubectl set image deployment/my-app app=$IMAGE_NAME:$IMAGE_TAG
kubectl rollout status deployment/my-app

if [ $? -eq 0 ]; then
  echo "✅ Déploiement terminé avec succès"
  
  # Attendre que le déploiement soit terminé
  kubectl rollout status deployment/my-app --timeout=300s
  
  # Vérifier les pods
  PODS=$(kubectl get pods -l app=my-app -o json | jq '.items | length')
  READY_PODS=$(kubectl get pods -l app=my-app --field-selector=status.phase=Running -o json | jq '.items | length')
  
  if [ "$PODS" -eq "$READY_PODS" ]; then
    echo "✅ Tous les pods sont prêts"
  else
    echo "⚠️  Certains pods ne sont pas prêts"
  fi
else
  echo "❌ Échec du déploiement"
  echo "🔄 Rollback en cours..."
  kubectl rollout undo deployment/my-app
  exit 1
fi
```

## Déploiement avec vérification de santé

### Script de vérification de santé post-déploiement
```bash
#!/bin/bash

# Variables
HEALTH_CHECK_URL=${HEALTH_CHECK_URL:-"http://localhost:3000/health"}
MAX_RETRIES=30
RETRY_INTERVAL=10
DEPLOYMENT_NAME=${1:-"my-app"}

echo "🏥 Vérification de la santé de $DEPLOYMENT_NAME..."

# Attendre que le service soit disponible
for i in $(seq 1 $MAX_RETRIES); do
  if curl -f $HEALTH_CHECK_URL > /dev/null 2>&1; then
    echo "✅ Service disponible"
    break
  else
    echo "⏳ Attente du service... ($i/$MAX_RETRIES)"
    sleep $RETRY_INTERVAL
  fi
done

if [ $i -eq $MAX_RETRIES ]; then
  echo "❌ Service non disponible après $MAX_RETRIES tentatives"
  exit 1
fi

# Vérifier les métriques de performance
echo "📊 Vérification des métriques de performance..."
./scripts/check-performance-metrics.sh

if [ $? -ne 0 ]; then
  echo "❌ Métriques de performance dégradées"
  exit 1
fi

# Vérifier les logs pour les erreurs
echo "🔍 Vérification des logs pour les erreurs..."
kubectl logs deployment/$DEPLOYMENT_NAME | grep -i error

if [ $? -eq 0 ]; then
  echo "⚠️  Erreurs détectées dans les logs"
  exit 1
fi

echo "✅ Vérification de santé terminée avec succès"
```

## Rollback automatique

### Script de rollback
```bash
#!/bin/bash

# Variables
DEPLOYMENT_NAME=${1:-"my-app"}
ROLLBACK_TO=${2:-"previous"}

echo "🔄 Rollback du déploiement $DEPLOYMENT_NAME vers $ROLLBACK_TO"

case $ROLLBACK_TO in
  "previous")
    echo "🔙 Rollback vers la version précédente..."
    kubectl rollout undo deployment/$DEPLOYMENT_NAME
    ;;
  "specific")
    echo "🔙 Rollback vers une version spécifique..."
    kubectl set image deployment/$DEPLOYMENT_NAME app=$IMAGE_TO_ROLLBACK_TO
    ;;
  *)
    echo "❌ Option de rollback inconnue: $ROLLBACK_TO"
    exit 1
    ;;
esac

# Attendre la fin du rollback
echo "⏳ Attente de la fin du rollback..."
kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=300s

if [ $? -eq 0 ]; then
  echo "✅ Rollback terminé avec succès"
  
  # Vérifier que le service est sain
  sleep 30
  ./scripts/check-health-metrics.sh
  
  if [ $? -ne 0 ]; then
    echo "⚠️  Le service peut ne pas être complètement sain après le rollback"
  fi
else
  echo "❌ Échec du rollback"
  exit 1
fi
```

## Déploiement avec notifications

### Script de notification de déploiement
```bash
#!/bin/bash

# Variables
SLACK_WEBHOOK_URL=$SLACK_WEBHOOK_URL
DEPLOYMENT_STATUS=$1
APP_NAME=${2:-"my-app"}
ENVIRONMENT=${3:-"production"}
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_MESSAGE=$(git log --format=%B -n 1 HEAD)

# Fonction d'envoi à Slack
send_slack_notification() {
  local status=$1
  local color=$2
  local message=$3
  
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"attachments\":[{\"color\":\"$color\",\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"$message\"}}]}]}" \
    $SLACK_WEBHOOK_URL
}

case $DEPLOYMENT_STATUS in
  "started")
    send_slack_notification "info" "warning" "🔄 *Déploiement démarré* pour $APP_NAME dans $ENVIRONMENT\nCommit: $COMMIT_HASH - $COMMIT_MESSAGE"
    ;;
  "success")
    send_slack_notification "success" "good" "✅ *Déploiement réussi* pour $APP_NAME dans $ENVIRONMENT\nCommit: $COMMIT_HASH - $COMMIT_MESSAGE"
    ;;
  "failed")
    send_slack_notification "error" "danger" "❌ *Déploiement échoué* pour $APP_NAME dans $ENVIRONMENT\nCommit: $COMMIT_HASH - $COMMIT_MESSAGE"
    ;;
  "rollback")
    send_slack_notification "warning" "warning" "🔄 *Rollback effectué* pour $APP_NAME dans $ENVIRONMENT\nCommit: $COMMIT_HASH - $COMMIT_MESSAGE"
    ;;
esac
```

## Bonnes pratiques de déploiement

### 1. Validation préalable
- Tests automatisés avant déploiement
- Validation de la configuration
- Vérification des dépendances

### 2. Stratégies de déploiement
- Blue-green pour zéro temps d'arrêt
- Canary pour tests progressifs
- Rolling pour déploiement progressif

### 3. Surveillance post-déploiement
- Vérification de santé
- Surveillance des performances
- Surveillance des erreurs

### 4. Rollback planifié
- Sauvegarde de l'état précédent
- Tests de rollback
- Processus de rollback automatisé

### 5. Documentation
- Processus de déploiement documenté
- Procédures d'urgence
- Rôles et responsabilités
```