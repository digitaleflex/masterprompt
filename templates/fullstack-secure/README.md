# Template Full-Stack Sécurisé

Ce template contient une application full-stack avec sécurité intégrée, comprenant un client React et un serveur Node.js/Express.

## Structure

```
fullstack-secure/
├── client/           # Application React
└── server/           # API Node.js/Express
```

## Installation

1. Installez les dépendances pour le client et le serveur :
```bash
cd client && npm install
cd ../server && npm install
```

2. Configurez les variables d'environnement dans les fichiers `.env` de chaque dossier

## Développement

Pour exécuter l'application en mode développement :
```bash
npm run dev
```

Cela démarrera à la fois le client sur http://localhost:3000 et le serveur sur http://localhost:5000.

## Sécurité

Ce template inclut des mesures de sécurité côté client et serveur :
- Headers de sécurité (CSP, HSTS, etc.)
- Rate limiting
- Sanitization des données
- Protection contre XSS et injection MongoDB
- Authentification JWT
- Validation des entrées