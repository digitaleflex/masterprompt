# Optimisation du flux de travail Git

## Description
Ce document présente des stratégies et configurations pour optimiser le flux de travail Git et améliorer la collaboration au sein des équipes de développement.

## Modèles de branche

### 1. Git Flow
````
develop (branche principale de développement)
├── feature/ (fonctionnalités)
├── release/ (versions de pré-production)
├── hotfix/ (correctifs urgents)
└── main (production)
```

#### Configuration
```bash
# Installation de git-flow
brew install git-flow

# Initialisation dans un projet
git flow init

# Création d'une fonctionnalité
git flow feature start nom-fonctionnalite

# Fin d'une fonctionnalité
git flow feature finish nom-fonctionnalite

# Création d'une version
git flow release start 1.2.0

# Fin d'une version
git flow release finish 1.2.0

# Correctif urgent
git flow hotfix start 1.1.1
git flow hotfix finish 1.1.1
```

### 2. GitHub Flow
````
main (production)
└── branche temporaire (fonctionnalité/fix)
    └── pull request
```

#### Processus
```bash
# Création d'une branche
git checkout -b feature/nouvelle-fonctionnalite

# Développement
git add .
git commit -m "feat: ajouter nouvelle fonctionnalité"

# Pousser la branche
git push origin feature/nouvelle-fonctionnalite

# Créer une pull request sur GitHub
# Fusion via GitHub UI
# Supprimer la branche après fusion
```

### 3. GitLab Flow
````
production (branche stable)
├── pre-production (staging)
└── main (dernier développement)
    └── fonctionnalités
```

#### Configuration
```bash
# Branche de production
git checkout -b production
git push origin production

# Déploiement vers staging
git checkout pre-production
git merge main
git push origin pre-production

# Déploiement vers production
git checkout production
git merge pre-production
git push origin production
```

## Configuration optimisée de Git

### 1. Configuration globale
```bash
# Configuration de base
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@entreprise.com"

# Éditeur par défaut
git config --global core.editor "code --wait"

# Format de fusion par défaut
git config --global merge.conflictstyle diff3

# Couleurs dans le terminal
git config --global color.ui auto

# Cache des identifiants
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
```

### 2. Configuration de projet
```bash
# Configuration spécifique au projet
git config core.autocrlf true     # Windows
git config core.autocrlf input    # Mac/Linux
git config core.filemode false    # Ignorer les permissions

# Configuration de l'alias
git config alias.st status
git config alias.co checkout
git config alias.br branch
git config alias.ci commit
git config alias.unstage 'reset HEAD --'
git config alias.last 'log -1 HEAD'
git config alias.visual '!gitk'
```

## Messages de commit conventionnels

### 1. Format standard
````
type(scope): description

feat: nouvelle fonctionnalité
fix: correction de bug
docs: documentation
style: formatage, style
refactor: refactorisation de code
test: ajout de tests
chore: tâches de maintenance
```

### 2. Exemples
```bash
# Bon
git commit -m "feat(auth): ajouter l'authentification OAuth2"

# Mauvais
git commit -m "ajouter login"

# Bon
git commit -m "fix(api): corriger le bug de timeout dans l'API utilisateur"

# Mauvais
git commit -m "corriger truc"
```

### 3. Configuration de commitlint
```json
// package.json
{
  "commitlint": {
    "extends": ["@commitlint/config-conventional"]
  },
  "husky": {
    "hooks": {
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
    }
  }
}
```

## Gestion avancée des branches

### 1. Branches à long terme
```bash
# Création d'une branche de développement
git checkout -b develop
git push -u origin develop

# Synchronisation régulière
git checkout develop
git pull origin develop

# Fusion dans main
git checkout main
git merge develop
git push origin main
```

### 2. Branches de fonctionnalité
```bash
# Création depuis develop
git checkout develop
git pull origin develop
git checkout -b feature/nouvelle-fonctionnalite

# Travailler sur la fonctionnalité
# ...

# Intégration dans develop
git checkout develop
git pull origin develop
git merge --no-ff feature/nouvelle-fonctionnalite
git branch -d feature/nouvelle-fonctionnalite
```

### 3. Branches de correctif
```bash
# Depuis main pour un correctif urgent
git checkout main
git pull origin main
git checkout -b hotfix/correction-urgente

# Appliquer la correction
# ...

# Fusion dans main et develop
git checkout main
git merge --no-ff hotfix/correction-urgente
git tag -a v1.0.1 -m "Version 1.0.1 avec correction urgente"
git checkout develop
git merge hotfix/correction-urgente
git branch -d hotfix/correction-urgente
```

## Optimisation des workflows

### 1. Hooks Git
```bash
# .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Vérifier le formatage
npx prettier --check .

# Vérifier le linting
npx eslint .

# Exécuter les tests rapides
npm run test:quick

# Vérifier les vulnérabilités
npm audit --audit-level moderate
```

### 2. Intégration continue
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    - run: npm ci
    - run: npm test
    - run: npm run build
```

## Gestion des conflits de fusion

### 1. Prévention des conflits
```bash
# Synchroniser régulièrement
git fetch origin
git rebase origin/main

# Utiliser des branches courtes
git checkout -b feature/short-lived

# Mettre à jour avant de pousser
git pull --rebase origin main
```

### 2. Résolution des conflits
```bash
# Identifier les conflits
git status

# Voir les conflits
git diff

# Résoudre manuellement dans les fichiers
# Marquer comme résolu
git add fichier_resolu.js

# Continuer la fusion
git rebase --continue
# ou
git merge --continue
```

### 3. Outils de résolution
```bash
# Configurer un outil de fusion
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Utiliser l'outil
git mergetool
```

## Nettoyage et maintenance

### 1. Nettoyage des branches
```bash
# Supprimer les branches distantes supprimées
git remote prune origin

# Lister les branches fusionnées
git branch --merged

# Supprimer les branches locales fusionnées
git branch --merged | grep -v main | xargs git branch -d

# Supprimer les branches distantes fusionnées
git push origin --delete nom-branche
```

### 2. Réécriture de l'historique
```bash
# Modifier le dernier commit
git commit --amend

# Réorganiser les commits
git rebase -i HEAD~3

# Supprimer des fichiers de l'historique
git filter-branch --tree-filter 'rm -f nom-fichier' HEAD
```

## Stratégies de fusion

### 1. Merge standard
```bash
# Fusion avec commit de fusion
git merge feature/nouvelle-fonctionnalite
```

### 2. Squash et merge
```bash
# Fusion en un seul commit
git checkout main
git merge --squash feature/nouvelle-fonctionnalite
git commit -m "feat: ajouter nouvelle fonctionnalité"
```

### 3. Rebase
```bash
# Réorganiser l'historique
git checkout feature/nouvelle-fonctionnalite
git rebase main
git checkout main
git merge feature/nouvelle-fonctionnalite
```

## Sécurité Git

### 1. Vérification des signatures
```bash
# Configurer GPG
git config --global user.signingkey VOTRE_ID_GPG
git config --global commit.gpgsign true

# Signer un commit
git commit -S -m "message de commit"

# Vérifier les signatures
git log --show-signature
```

### 2. Protection des branches
```bash
# Configuration sur GitHub/GitLab
# - Branch protection rules
# - Required status checks
# - Required reviews
# - Restrictions on who can push
```

## Outils d'assistance

### 1. Git aliases utiles
```bash
# Navigation
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD --stat"

# Productivité
git config --global alias.sync "!git fetch origin && git rebase origin/main"
git config --global alias.felog "log --oneline --follow -p"
git config --global alias.visual "!gitk"
```

### 2. Outils de ligne de commande
```bash
# Git extras
brew install git-extras
git summary
git changelog
git commits-since yesterday
git delete-merged-branches

# Git flow
brew install git-flow
git flow feature start nom
git flow feature finish nom
```

## Meilleures pratiques

### 1. Fréquence de commit
- Commits atomiques (un seul changement logique par commit)
- Messages clairs et descriptifs
- Fréquence régulière pour éviter les grosses modifications

### 2. Gestion des branches
- Branches courtes et ciblées
- Synchronisation régulière avec la branche principale
- Suppression des branches après fusion

### 3. Revue de code
- Pull requests pour toutes les modifications
- Revue par un pair avant fusion
- Tests automatisés avant fusion

### 4. Documentation
- Garder les messages de commit informatifs
- Mettre à jour la documentation avec le code
- Utiliser des modèles de PR pour la cohérence

Cette configuration Git optimisée améliorera la productivité, la collaboration et la qualité du code dans votre équipe de développement.