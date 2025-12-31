# Configuration de l'environnement de développement

## Description
Ce document décrit les étapes et outils nécessaires pour configurer un environnement de développement optimal et productif.

## Outils de base

### Node.js et npm
```bash
# Installation via nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
nvm use node

# Ou pour une version spécifique
nvm install 18.17.0
nvm alias default 18.17.0
```

### Gestion des versions avec asdf
```bash
# Installation d'asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

# Installation de plugins
asdf plugin add nodejs
asdf plugin add python
asdf plugin add java

# Installation des versions spécifiées dans .tool-versions
asdf install
```

## Configuration de l'environnement

### Fichier .env
```bash
# Variables d'environnement
NODE_ENV=development
PORT=3000
API_URL=http://localhost:5000
DATABASE_URL=postgresql://localhost:5432/myapp_dev
JWT_SECRET=dev_secret_key
REACT_APP_API_URL=http://localhost:5000
```

### Fichier .env.example
```bash
# Modèle pour .env
NODE_ENV=development
PORT=3000
API_URL=
DATABASE_URL=
JWT_SECRET=
REACT_APP_API_URL=
```

## Outils de productivité

### Installation des outils de développement
```bash
# Installation de outils CLI utiles
npm install -g npm-check-updates
npm install -g http-server
npm install -g nodemon
npm install -g concurrently
npm install -g pm2

# Outils de vérification
npm install -g @microsoft/secretscan
npm install -g lockfile-lint
```

### Configuration de Docker
```dockerfile
# Dockerfile pour l'environnement de développement
FROM node:18-alpine

WORKDIR /app

# Installer les dépendances système
RUN apk add --no-cache \
    dumb-init \
    git \
    openssh

# Installer les outils de développement
RUN npm install -g npm-check-updates nodemon concurrently

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000

ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "dev"]
```

### docker-compose.yml pour le développement
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://user:password@db:5432/myapp_dev
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp_dev
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

## Configuration VS Code

### .vscode/settings.json
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "emmet.includeLanguages": {
    "javascript": "javascriptreact"
  },
  "files.associations": {
    "*.js": "javascript",
    "*.jsx": "javascriptreact"
  },
  "terminal.integrated.env.windows": {
    "NODE_ENV": "development"
  }
}
```

### .vscode/extensions.json
```json
{
  "recommendations": [
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next",
    "ms-vscode.vscode-json",
    "ms-vscode.vscode-xml",
    "ms-vscode.vscode-markdown"
  ]
}
```

## Scripts de configuration

### Script de configuration initiale
```bash
#!/bin/bash

# Script d'initialisation de l'environnement de développement

echo "🚀 Configuration de l'environnement de développement..."

# Vérifier si Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    echo "Veuillez installer Node.js avant de continuer"
    exit 1
fi

# Vérifier la version de Node.js
NODE_VERSION=$(node --version | cut -d'v' -f2)
MIN_VERSION="18.0.0"

if [[ $(printf '%s\n' "$MIN_VERSION" "$NODE_VERSION" | sort -V | head -n1) != "$MIN_VERSION" ]]; then
    echo "❌ Version de Node.js trop ancienne: $NODE_VERSION, requis: $MIN_VERSION"
    exit 1
fi

echo "✅ Node.js version $NODE_VERSION détectée"

# Installer les dépendances
echo "📦 Installation des dépendances..."
npm install

# Créer le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    echo "📝 Création du fichier .env..."
    cp .env.example .env
    echo "Veuillez configurer vos variables d'environnement dans .env"
fi

# Installer les hooks Git
if [ -d .git ]; then
    echo "🔧 Installation des hooks Git..."
    npm run prepare  # Si husky est configuré
fi

echo "✅ Environnement de développement configuré avec succès!"
echo "💡 Pour commencer, exécutez : npm run dev"
```

## Configuration de l'environnement de développement local

### Fichier .nvmrc
```
18.17.0
```

### Initialisation avec nvm
```bash
# Utiliser la version spécifiée dans .nvmrc
nvm use

# Si la version n'est pas installée
nvm install
```

## Outils de développement avancés

### Configuration de TypeScript
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
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### Configuration de Jest pour le développement
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.js'],
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.js'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

## Configuration de l'environnement pour le travail d'équipe

### Configuration partagée ESLint
```json
{
  "extends": [
    "@masterprompt"
  ],
  "rules": {
    "max-lines-per-function": ["warn", 50],
    "complexity": ["warn", 5],
    "max-depth": ["warn", 3]
  }
}
```

### Fichier de configuration partagée
```json
{
  "name": "@masterprompt/eslint-config",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "eslint-config-airbnb": "^19.0.0",
    "eslint-config-prettier": "^8.5.0",
    "eslint-plugin-import": "^2.26.0",
    "eslint-plugin-jsx-a11y": "^6.6.1",
    "eslint-plugin-react": "^7.31.7",
    "eslint-plugin-react-hooks": "^4.6.0"
  }
}
```

## Scripts de développement

### package.json scripts utiles
```json
{
  "scripts": {
    "dev": "vite",
    "dev:api": "nodemon server.js",
    "dev:full": "concurrently \"npm run dev\" \"npm run dev:api\"",
    "setup": "bash scripts/setup-dev-env.sh",
    "setup:windows": "powershell -ExecutionPolicy Bypass -File scripts/setup-dev-env.ps1",
    "clean": "rm -rf node_modules package-lock.json && npm install",
    "clean:windows": "rmdir /s /q node_modules && del package-lock.json && npm install",
    "validate": "npm run lint && npm run test && npm run type-check"
  }
}
```

## Configuration de sécurité de l'environnement

### Vérification des secrets
```bash
#!/bin/bash
# Script de vérification des secrets avant le développement

echo "🔍 Vérification des secrets dans l'environnement..."

# Vérifier si les variables d'environnement critiques sont définies
required_vars=("DATABASE_URL" "JWT_SECRET" "API_KEY")

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "⚠️  Variable d'environnement manquante: $var"
    echo "Veuillez définir $var dans votre fichier .env"
  fi
done

echo "✅ Vérification des secrets terminée"
```