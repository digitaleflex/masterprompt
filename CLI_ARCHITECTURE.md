# masterprompt-cli

> Interface en ligne de commande pour le framework MasterPrompt

## Description

MasterPrompt CLI est une interface en ligne de commande qui permet :
- Générer des projets complets avec tous les outils intégrés
- Exécuter des analyses de code
- Appliquer des refactoring automatisés
- Gérer les workflows DevSecOps

## Installation

```bash
npm install -g masterprompt-cli
```

ou

```bash
yarn global add masterprompt-cli
```

## Utilisation

```bash
# Générer un nouveau projet
masterprompt create my-project

# Analyser un projet existant
masterprompt analyze --security
masterprompt analyze --quality
masterprompt analyze --performance

# Appliquer des refactoring
masterprompt refactor --security
masterprompt refactor --performance

# Générer des rapports
masterprompt report --security
masterprompt report --quality
```

## Commandes disponibles

- `create` - Créer un nouveau projet avec des templates
- `analyze` - Analyser un projet existant
- `refactor` - Appliquer des refactoring automatisés
- `report` - Générer des rapports d'analyse
- `init` - Initialiser un projet existant avec MasterPrompt
- `update` - Mettre à jour les configurations
- `help` - Afficher l'aide

## Configuration

Le CLI utilise un fichier de configuration `.masterpromptrc` dans le répertoire du projet pour personnaliser le comportement.