# Astuces de productivité IDE

## Description
Ce document présente des techniques, raccourcis et configurations pour améliorer la productivité dans les environnements de développement intégrés (IDE).

## Raccourcis clavier essentiels

### 1. Navigation
````
Windows/Linux        Mac
Ctrl + P            Cmd + P      # Ouvrir un fichier rapidement
Ctrl + Shift + P    Cmd + Shift + P  # Palette de commandes
Ctrl + Tab          Cmd + Tab    # Basculer entre fichiers
Ctrl + G            Cmd + G      # Aller à la ligne
Ctrl + Shift + O    Cmd + Shift + O  # Aller au symbole
Ctrl + T            Cmd + T      # Aller à la définition
Ctrl + Shift + F10  Cmd + Shift + F10 # Exécuter la configuration actuelle
```

### 2. Édition
````
Windows/Linux        Mac
Ctrl + D            Cmd + D      # Dupliquer la ligne
Ctrl + /            Cmd + /      # Commenter/décommenter
Ctrl + Shift + K    Cmd + Shift + K  # Supprimer la ligne
Ctrl + Shift + Up/Down  Cmd + Alt + Up/Down  # Déplacer la ligne
Alt + Up/Down       Alt + Up/Down # Déplacer le bloc
Shift + Alt + Up/Down  Cmd + Alt + Up/Down  # Dupliquer le bloc
F2                  F2           # Renommer
Ctrl + Space        Ctrl + Space # Autocomplétion
```

### 3. Sélection
````
Windows/Linux        Mac
Ctrl + D            Cmd + D      # Sélectionner l'occurrence suivante
Ctrl + Shift + L    Cmd + Shift + L  # Sélectionner toutes les occurrences
Ctrl + U            Cmd + U      # Annuler la sélection
Shift + Alt + I     Shift + Alt + I  # Insérer des curseurs à la fin de chaque ligne sélectionnée
```

## Configuration de l'IDE

### 1. VS Code settings.json
```json
{
  "editor.fontSize": 14,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.wordWrap": "on",
  "editor.minimap.enabled": true,
  "editor.renderWhitespace": "all",
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "editor.inlineSuggest.enabled": true,
  "editor.suggest.insertMode": "replace",
  "editor.suggest.snippetsPreventQuickSuggestions": false,
  "editor.snippetSuggestions": "top",
  "editor.acceptSuggestionOnCommitCharacter": false,
  "editor.acceptSuggestionOnEnter": "off",
  "editor.quickSuggestions": {
    "other": true,
    "comments": false,
    "strings": false
  },
  "editor.wordBasedSuggestions": "off",
  "editor.suggest.localityBonus": true,
  "editor.suggestSelection": "first",
  "editor.suggest.snippetsPreventQuickSuggestions": false,
  "editor.parameterHints.enabled": true,
  "editor.hover.delay": 300,
  "editor.hover.sticky": true,
  "editor.lightbulb.enabled": "on",
  "editor.codeLens": true,
  "editor.folding": true,
  "editor.foldingStrategy": "auto",
  "editor.foldingHighlight": true,
  "editor.showFoldingControls": "always",
  "editor.mouseWheelZoom": true,
  "editor.multiCursorModifier": "alt",
  "editor.renderLineHighlight": "all",
  "editor.renderWhitespace": "boundary",
  "editor.rulers": [80, 120],
  "editor.wordSeparators": "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/",
  "editor.unicodeHighlight.ambiguousCharacters": false,
  "editor.unicodeHighlight.invisibleCharacters": false,
  "editor.unicodeHighlight.includeComments": false,
  "editor.unicodeHighlight.includeStrings": false,
  "editor.unicodeHighlight.allowedCharacters": {},
  "editor.unicodeHighlight.allowedLocales": {},
  "editor.suggest.filteredTypes": {
    "snippets": false
  },
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/*.code-search": true,
    "**/._*": true,
    "**/Thumbs.db": true,
    "**/.DS_Store": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/*.code-search": true,
    "**/._*": true,
    "**/Thumbs.db": true,
    "**/.DS_Store": true
  },
  "telemetry.telemetryLevel": "off",
  "workbench.editor.showTabs": true,
  "workbench.editor.tabSizing": "shrink",
  "workbench.editor.labelFormat": "medium",
  "workbench.editor.untitled.hint": "hidden",
  "workbench.startupEditor": "newUntitledFile",
  "workbench.colorTheme": "Default Dark+",
  "workbench.iconTheme": "vscode-icons",
  "workbench.list.openMode": "singleClick",
  "workbench.list.smoothScrolling": true,
  "workbench.tree.indent": 20,
  "workbench.tree.renderIndentGuides": "always",
  "workbench.fontAliasing": "auto",
  "workbench.settings.editor": "json",
  "workbench.settings.openDefaultSettings": true,
  "workbench.settings.useSplitJSON": false,
  "workbench.editor.enablePreview": false,
  "workbench.editor.enablePreviewFromQuickOpen": false,
  "workbench.editor.closeOnFileDelete": false,
  "workbench.editor.restoreViewState": true,
  "workbench.commandPalette.history": 50,
  "workbench.commandPalette.preserveInput": true,
  "workbench.quickOpen.closeOnFocusLost": true,
  "workbench.quickOpen.preserveInput": true,
  "workbench.sideBar.location": "left",
  "workbench.statusBar.visible": true,
  "workbench.activityBar.visible": true,
  "workbench.view.alwaysShowHeaderActions": false,
  "workbench.fontFamily": "Consolas, 'Courier New', monospace",
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.fontFamily": "Consolas, 'Courier New', monospace",
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.rightClickBehavior": "copyPaste",
  "terminal.integrated.scrollback": 10000,
  "terminal.integrated.copyOnSelection": true,
  "terminal.integrated.enablePersistentSessions": false
}
```

### 2. Extensions essentielles VS Code
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
    "ms-vscode.vscode-markdown",
    "formulahendry.auto-rename-tag",
    "pranaygp.vscode-css-peek",
    "christian-kohler.path-intellisense",
    "christian-kohler.npm-intellisense",
    "wix.vscode-import-cost",
    "msjsdiag.debugger-for-chrome",
    "ms-vscode.vscode-github-actions",
    "ms-azuretools.vscode-docker",
    "ms-vscode.vscode-json",
    "ms-vscode.vscode-github-issue-notebooks",
    "ms-vscode.vscode-selfhost-test-provider"
  ]
}
```

## Techniques de navigation avancées

### 1. Navigation dans le code
```javascript
// Exemple de code avec commentaires pour la navigation

/**
 * @function calculateTotal
 * @description Calcule le total avec taxes
 * @param {number[]} items - Liste des articles
 * @param {number} taxRate - Taux de taxe
 * @returns {number} Total calculé
 */
function calculateTotal(items, taxRate) {
  // 1. Calcul du sous-total
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  
  // 2. Calcul des taxes
  const tax = subtotal * taxRate;
  
  // 3. Calcul du total
  return subtotal + tax;
}

// Utilisation de la fonction
const items = [
  { name: 'Produit A', price: 10 },
  { name: 'Produit B', price: 20 }
];

const total = calculateTotal(items, 0.15); // Taux de taxe de 15%
```

### 2. Techniques de recherche
````
Ctrl + F            # Rechercher dans le fichier
Ctrl + H            # Rechercher et remplacer
Ctrl + Shift + F    # Rechercher dans tous les fichiers
Ctrl + Shift + H    # Remplacer dans tous les fichiers
Alt + L             # Sélectionner toutes les occurrences de la sélection
Ctrl + Shift + L    # Sélectionner toutes les occurrences du mot
```

## Productivité avec les extensions

### 1. Code runners
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Node",
      "type": "shell",
      "command": "node",
      "args": ["${file}"],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      },
      "problemMatcher": ["$tsc"]
    }
  ]
}
```

### 2. Snippets personnalisés
```json
// .vscode/snippets/javascript.json
{
  "React Functional Component": {
    "prefix": "rfc",
    "body": [
      "import React from 'react';",
      "",
      "const ${1:ComponentName} = ({ $2 }) => {",
      "  return (",
      "    <div className=\"${1/(.*)/${1:/downcase}/}\">",
      "      $3",
      "    </div>",
      "  );",
      "};",
      "",
      "export default ${1:ComponentName};"
    ],
    "description": "Créer un composant React fonctionnel"
  },
  "Console Log": {
    "prefix": "cl",
    "body": ["console.log('$1:', $1);"],
    "description": "Insérer un console.log"
  },
  "Async Function": {
    "prefix": "asyncfn",
    "body": [
      "const ${1:functionName} = async (${2:params}) => {",
      "  try {",
      "    $3",
      "  } catch (error) {",
      "    console.error('Error in ${1:functionName}:', error);",
      "    throw error;",
      "  }",
      "};"
    ],
    "description": "Créer une fonction asynchrone avec gestion d'erreur"
  }
}
```

## Techniques de refactorisation

### 1. Renommage intelligent
```javascript
// Avant le renommage
class UserService {
  getUserData(userId) {
    // ...
  }
  
  updateUserData(userId, data) {
    // ...
  }
}

// Après le renommage (renommage de toutes les références)
class UserManagementService {
  fetchUserData(userId) {
    // ...
  }
  
  modifyUserData(userId, data) {
    // ...
  }
}
```

### 2. Extraction de fonctions
```javascript
// Code avant extraction
function processOrder(order) {
  // Validation de la commande
  if (!order.customerId) {
    throw new Error('Customer ID is required');
  }
  if (order.items.length === 0) {
    throw new Error('Order must have items');
  }
  
  // Calcul du total
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }
  
  // Application des taxes
  const taxRate = 0.15;
  const tax = total * taxRate;
  const totalWithTax = total + tax;
  
  return totalWithTax;
}

// Code après extraction
function processOrder(order) {
  validateOrder(order);
  const total = calculateOrderTotal(order);
  return calculateTotalWithTax(total);
}

function validateOrder(order) {
  if (!order.customerId) {
    throw new Error('Customer ID is required');
  }
  if (order.items.length === 0) {
    throw new Error('Order must have items');
  }
}

function calculateOrderTotal(order) {
  return order.items.reduce((total, item) => 
    total + item.price * item.quantity, 0
  );
}

function calculateTotalWithTax(total) {
  const taxRate = 0.15;
  const tax = total * taxRate;
  return total + tax;
}
```

## Productivité avec les terminaux intégrés

### 1. Configuration du terminal
```json
// settings.json
{
  "terminal.integrated.shellArgs.windows": ["-NoLogo"],
  "terminal.integrated.fontFamily": "Cascadia Code, Consolas, 'Courier New', monospace",
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.copyOnSelection": true,
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.rightClickBehavior": "copyPaste"
}
```

### 2. Tâches et scripts
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Project",
      "type": "shell",
      "command": "npm run build",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new",
        "showReuseMessage": true,
        "clear": false
      }
    },
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "npm test",
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      }
    }
  ]
}
```

## Outils de productivité

### 1. Extensions de productivité
- **Code Spell Checker**: Correction orthographique
- **Bookmarks**: Marqueurs dans le code
- **Project Manager**: Gestion des projets
- **GitLens**: Amélioration des fonctionnalités Git
- **Bracket Pair Colorizer**: Coloration des paires de parenthèses
- **Auto Rename Tag**: Renommer automatiquement les balises HTML

### 2. Snippets de productivité
```json
// React hooks snippets
{
  "UseState Hook": {
    "prefix": "useState",
    "body": [
      "const [${1:state}, set${1/(.*)/${1:/capitalize}/}] = useState(${2:initialValue});"
    ]
  },
  "UseEffect Hook": {
    "prefix": "useEffect",
    "body": [
      "useEffect(() => {",
      "  $1",
      "  return () => {",
      "    $2",
      "  };",
      "}, [${3:dependencies}]);"
    ]
  },
  "UseContext Hook": {
    "prefix": "useContext",
    "body": [
      "const ${1:contextValue} = useContext(${2:Context});"
    ]
  }
}
```

## Optimisation des performances

### 1. Réduction des extensions
- Désactiver les extensions inutilisées
- Utiliser des extensions légères
- Mettre à jour les extensions régulièrement

### 2. Paramètres de performance
```json
{
  "editor.suggest.localityBonus": true,
  "editor.quickSuggestions": false,
  "editor.acceptSuggestionOnCommitCharacter": false,
  "editor.suggest.insertMode": "replace",
  "editor.suggest.snippetsPreventQuickSuggestions": false,
  "editor.suggest.showClasses": false,
  "editor.suggest.showColors": false,
  "editor.suggest.showConstants": false,
  "editor.suggest.showConstructors": false,
  "editor.suggest.showCustomcolors": false,
  "editor.suggest.showDeprecated": false,
  "editor.suggest.showEnumMembers": false,
  "editor.suggest.showEnums": false,
  "editor.suggest.showEvents": false,
  "editor.suggest.showFields": false,
  "editor.suggest.showFiles": false,
  "editor.suggest.showFolders": false,
  "editor.suggest.showFunctions": false,
  "editor.suggest.showInterfaces": false,
  "editor.suggest.showKeywords": false,
  "editor.suggest.showMethods": false,
  "editor.suggest.showModules": false,
  "editor.suggest.showOperators": false,
  "editor.suggest.showPropertes": false,
  "editor.suggest.showReferences": false,
  "editor.suggest.showSnippets": false,
  "editor.suggest.showStructs": false,
  "editor.suggest.showTexts": false,
  "editor.suggest.showTypeParameters": false,
  "editor.suggest.showUnits": false,
  "editor.suggest.showUsers": false,
  "editor.suggest.showValues": false,
  "editor.suggest.showVariables": false
}
```

## Astuces spécifiques par langage

### 1. JavaScript/TypeScript
- Utiliser les paramètres IntelliSense
- Configurer les diagnostics
- Utiliser les refactoring suggestions

### 2. React
- Utiliser les snippets React
- Configurer ESLint et Prettier
- Utiliser React Developer Tools

### 3. Node.js
- Configuration du débogage
- Utilisation des intégrations npm
- Gestion des environnements

Ces astuces et configurations amélioreront considérablement votre productivité dans votre IDE en vous permettant de naviguer, éditer et comprendre le code plus efficacement.