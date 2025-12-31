# Suite d'extensions VS Code

## Description
Cette liste contient les extensions VS Code recommandées pour une expérience de développement optimale.

## Extensions de base

### Langages et frameworks
- **ES7+ React/Redux/React-Native snippets** - `dsznajder.es7-react-js-snippets`
  - Extraits de code pour React, Redux et React Native
  - Accélère le développement avec des snippets prédéfinis

- **Prettier - Code formatter** - `esbenp.prettier-vscode`
  - Formateur de code automatique
  - Supporte de nombreux langages
  - Intégration avec ESLint

- **ESLint** - `dbaeumer.vscode-eslint`
  - Linting en temps réel
  - Correction automatique
  - Supporte TypeScript et JavaScript

- **Tailwind CSS IntelliSense** - `bradlc.vscode-tailwindcss`
  - Autocomplétion pour Tailwind CSS
  - Validation d'erreurs
  - Extraction de classes

### Débogage et développement
- **Debugger for Chrome** - `msjsdiag.debugger-for-chrome`
  - Débogage directement depuis VS Code
  - Intégration avec le navigateur
  - Points d'arrêt et inspection de variables

- **Import Cost** - `wix.vscode-import-cost`
  - Affiche la taille des imports dans l'éditeur
  - Aide à optimiser les bundles
  - Supporte JavaScript et TypeScript

- **Bracket Pair Colorizer** - `coenraads.bracket-pair-colorizer`
  - Coloration des paires de parenthèses
  - Meilleure lisibilité du code
  - Personnalisation des couleurs

## Extensions de productivité

### Gestion de projet
- **Project Manager** - `alefragnani.project-manager`
  - Gestion des projets récents
  - Accès rapide aux différents projets
  - Supporte Git, Mercurial, SVN

- **Bookmarks** - `alefragnani.Bookmarks`
  - Marqueurs dans le code
  - Navigation rapide entre les sections importantes
  - Supporte les projets multi-fenêtres

- **GitLens** - `eamodio.gitlens`
  - Amélioration des fonctionnalités Git
  - Historique des modifications
  - Comparaison des versions

### Collaboration
- **Live Share** - `ms-vsliveshare.vsliveshare`
  - Collaboration en temps réel
  - Partage de session de développement
  - Débogage collaboratif

- **Code Spell Checker** - `streetsidesoftware.code-spell-checker`
  - Correction orthographique
  - Supporte de nombreux langages
  - Personnalisation des dictionnaires

## Extensions de sécurité

### Analyse de code
- **SonarLint** - `sonarsource.sonarlint`
  - Analyse de code en temps réel
  - Détection des vulnérabilités
  - Respect des normes de codage

- **Snyk Vulnerability Scanner** - `snyk-security.snyk-vulnerability-scanner`
  - Détection des vulnérabilités dans les dépendances
  - Intégration directe avec VS Code
  - Rapports détaillés

### Gestion des secrets
- **Secrets** - `ms-vscode.vscode-sqlite-viewer`
  - Détection des secrets dans le code
  - Empêche le commit d'informations sensibles
  - Configuration personnalisée possible

## Extensions pour le développement Web

### HTML/CSS
- **Auto Rename Tag** - `formulahendry.auto-rename-tag`
  - Renomme automatiquement les balises HTML
  - Gain de temps considérable
  - Évite les erreurs de balisage

- **CSS Peek** - `pranaygp.vscode-css-peek`
  - Accès rapide aux définitions CSS
  - Navigation entre HTML et CSS
  - Inspection des styles

### JavaScript/TypeScript
- **Path Intellisense** - `christian-kohler.path-intellisense`
  - Autocomplétion des chemins de fichiers
  - Supporte les chemins relatifs
  - Réduit les erreurs de cheminement

- **npm Intellisense** - `christian-kohler.npm-intellisense`
  - Autocomplétion des imports npm
  - Suggestions basées sur package.json
  - Vérification des modules existants

## Extensions pour React
- **ES7+ React/Redux/React-Native snippets** - `dsznajder.es7-react-js-snippets`
  - Snippets pour les composants React
  - Hooks, contexte et autres patterns
  - Supporte JSX et TypeScript

- **Simple React Snippets** - `burkeholland.simple-react-snippets`
  - Extraits de code React simples
  - Composants, hooks et tests
  - Syntaxe moderne

- **vscode-styled-components** - `jpoissonnier.vscode-styled-components`
  - Coloration syntaxique pour styled-components
  - Autocomplétion des propriétés
  - Supporte les thèmes

## Extensions pour Node.js
- **Node.js Extension Pack** - `ms-vscode.vscode-node-essentials`
  - Ensemble d'extensions pour Node.js
  - Débogage, snippets, outils
  - Intégration avec npm

- **NPM** - `eg2.vscode-npm`
  - Intégration avec le terminal npm
  - Exécution des scripts
  - Gestion des dépendances

## Extensions pour TypeScript
- **TypeScript Hero** - `rbbit.typescript-hero`
  - Améliorations pour TypeScript
  - Import automatique
  - Réorganisation des imports

- **TSLint** - `ms-vscode.vscode-typescript-tslint-plugin`
  - Linting pour TypeScript
  - Intégration avec ESLint
  - Correction automatique

## Configuration recommandée

### settings.json
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
  "prettier.configPath": "./.prettierrc",
  "prettier.requireConfig": true,
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "files.associations": {
    "*.js": "javascript",
    "*.jsx": "javascriptreact"
  }
}
```

### keybindings.json (raccourcis utiles)
```json
[
  {
    "key": "ctrl+shift+i",
    "command": "editor.action.organizeImports",
    "when": "editorTextFocus && !editorReadonly"
  },
  {
    "key": "ctrl+shift+p",
    "command": "editor.action.quickFix",
    "when": "editorHasCodeActionsProvider && editorTextFocus && !editorReadonly"
  }
]
```

## Extensions pour le déploiement et CI/CD
- **GitHub Pull Requests and Issues** - `GitHub.vscode-pull-request-github`
  - Gestion des PR directement dans VS Code
  - Revue de code intégrée
  - Commentaires en ligne

- **Azure Tools** - `ms-vscode.vscode-azureextensionpack`
  - Ensemble d'outils Azure
  - Déploiement et gestion
  - Intégration avec les services cloud

## Installation en bloc

Créez un fichier `extensions.json` dans le dossier `.vscode` de votre projet :
```json
{
  "recommendations": [
    "dsznajder.es7-react-js-snippets",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "msjsdiag.debugger-for-chrome",
    "wix.vscode-import-cost",
    "eamodio.gitlens",
    "snyk-security.snyk-vulnerability-scanner",
    "ms-vscode.vscode-json"
  ]
}
```

Installez toutes les extensions recommandées :
```bash
# Pour chaque extension dans la liste
code --install-extension extension-id
```

## Commandes utiles
- `Ctrl+Shift+P` - Palette de commandes
- `Ctrl+P` - Ouvrir rapidement un fichier
- `Ctrl+Shift+N` - Nouvelle fenêtre
- `Ctrl+Shift+M` - Panneau de problèmes
- `Ctrl+K V` - Visualiseur d'images