# Architecture de la CLI MasterPrompt

Ce document décrit l'architecture de l'interface en ligne de commande (CLI) de MasterPrompt.

## Structure du projet

```
masterprompt-cli/
├── index.js                 # Point d'entrée principal
├── package.json            # Dépendances et configuration
├── commands/               # Commandes CLI
│   ├── create.js          # Commande pour créer un projet
│   ├── analyze.js         # Commande pour analyser un projet
│   ├── refactor.js        # Commande pour refactoriser
│   ├── report.js          # Commande pour générer des rapports
│   └── init.js            # Commande pour initialiser un projet
├── templates/              # Templates de projets (à venir)
└── README.md              # Documentation de l'architecture
```

## Fonctionnalités

### Commande `create`
- Crée un nouveau projet à partir de templates
- Supporte plusieurs types de projets (React, Next.js, Node.js API, Full-stack)
- Génère un fichier de configuration `.masterpromptrc`

### Commande `analyze`
- Analyse la sécurité du projet
- Analyse la qualité du code
- Analyse la performance
- Peut exécuter toutes les analyses en une fois

### Commande `refactor`
- Applique des refactoring automatisés pour la sécurité
- Applique des refactoring pour la performance
- Peut exécuter tous les refactoring en une fois

### Commande `report`
- Génère des rapports détaillés sur la sécurité
- Génère des rapports sur la qualité du code
- Génère des rapports sur la performance
- Peut sauvegarder les rapports dans un fichier

### Commande `init`
- Initialise un projet existant avec MasterPrompt
- Crée le fichier de configuration `.masterpromptrc`
- Configure les paramètres par défaut

## Dépendances

- `commander`: Gestion des commandes CLI
- `inquirer`: Interface utilisateur interactive
- `chalk`: Coloration du texte dans la console
- `fs-extra`: Opérations de système de fichiers améliorées
- `ora`: Indicateurs de chargement
- `axios`: Requêtes HTTP
- `shelljs`: Commandes shell
- `glob`: Recherche de fichiers

## Configuration

Le CLI utilise un fichier de configuration `.masterpromptrc` dans le répertoire du projet :

```json
{
  "projectName": "mon-projet",
  "createdAt": "2025-01-01T00:00:00.000Z",
  "masterprompt": {
    "version": "1.0.0",
    "features": ["devsecops", "automation", "quality", "productivity"]
  },
  "settings": {
    "security": {
      "enabled": true,
      "level": "standard"
    },
    "quality": {
      "enabled": true,
      "level": "standard"
    },
    "performance": {
      "enabled": true,
      "level": "standard"
    }
  }
}
```

## Utilisation

```bash
# Installation globale
npm install -g masterprompt-cli

# Création d'un nouveau projet
masterprompt create my-project

# Analyse d'un projet existant
masterprompt analyze --all

# Génération d'un rapport
masterprompt report --security --output security-report.txt
```