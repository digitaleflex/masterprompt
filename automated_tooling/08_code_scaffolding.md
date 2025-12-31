# Génération de code (Scaffolding)

## Description
Ce document décrit les techniques et outils pour générer automatiquement du code, des fichiers et des structures de projet.

## Introduction au scaffolding

Le scaffolding (échafaudage) est le processus de génération automatique de code, fichiers et structures de base pour accélérer le développement. Cela permet de standardiser les pratiques et d'éviter les erreurs de configuration.

## Outils de scaffolding

### Plop.js
Plop est un générateur de micro-templates léger.

#### Installation
```bash
npm install --save-dev plop
```

#### Configuration (plopfile.js)
```javascript
module.exports = function (plop) {
  // Générateur de composant React
  plop.setGenerator('react-component', {
    description: 'Créer un composant React avec tests et styles',
    prompts: [
      {
        type: 'input',
        name: 'name',
        message: 'Nom du composant:'
      },
      {
        type: 'confirm',
        name: 'withTests',
        message: 'Inclure des tests?',
        default: true
      }
    ],
    actions: [
      {
        type: 'add',
        path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.jsx',
        templateFile: 'plop-templates/component.hbs'
      },
      {
        type: 'add',
        path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.module.css',
        templateFile: 'plop-templates/component.css.hbs'
      },
      {
        type: 'add',
        path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.test.js',
        templateFile: 'plop-templates/component.test.hbs',
        skip: (data) => !data.withTests
      }
    ]
  });

  // Générateur de service API
  plop.setGenerator('api-service', {
    description: 'Créer un service API',
    prompts: [
      {
        type: 'input',
        name: 'name',
        message: 'Nom du service:'
      }
    ],
    actions: [
      {
        type: 'add',
        path: 'src/services/{{camelCase name}}Service.js',
        templateFile: 'plop-templates/service.hbs'
      }
    ]
  });
};
```

#### Modèles Handlebars (plop-templates/component.hbs)
```handlebars
import React from 'react';
import PropTypes from 'prop-types';

import './{{pascalCase name}}.module.css';

const {{pascalCase name}} = ({ children, className = '' }) => {
  return (
    <div className="{{pascalCase name}} {{className}}">
      <h1>{{pascalCase name}} Component</h1>
      {children}
    </div>
  );
};

{{pascalCase name}}.propTypes = {
  children: PropTypes.node,
  className: PropTypes.string
};

export default {{pascalCase name}};
```

#### Utilisation
```bash
npx plop react-component
# ou
npx plop api-service
```

### Hygen
Hygen est un générateur de code basé sur des conventions.

#### Installation
```bash
npm install --save-dev hygen
npx hygen init self
npx hygen generator new component
```

#### Structure
```
hygen/
├── component/
│   ├── new/
│   │   ├── component.ejs.t
│   │   └── test.ejs.t
```

#### Modèle (component/new/component.ejs.t)
```
---
to: src/components/<%= name %>/<%= name %>.jsx
---
import React from 'react';

const <%= name %> = () => {
  return (
    <div className="<%= name %>">
      <h1><%= name %> Component</h1>
    </div>
  );
};

export default <%= name %>;
```

## Générateurs personnalisés

### Générateur de composant avec TypeScript
```javascript
// scripts/generate-component.js
const fs = require('fs');
const path = require('path');

const componentName = process.argv[2];

if (!componentName) {
  console.error('Usage: node generate-component.js <ComponentName>');
  process.exit(1);
}

const componentDir = path.join('src', 'components', componentName);

// Créer le répertoire
if (!fs.existsSync(componentDir)) {
  fs.mkdirSync(componentDir, { recursive: true });
}

// Fichier TypeScript
const tsxContent = `import React from 'react';

interface ${componentName}Props {
  children?: React.ReactNode;
  className?: string;
}

const ${componentName}: React.FC<${componentName}Props> = ({ 
  children, 
  className = '' 
}) => {
  return (
    <div className={\`\${componentName} \${className}\`}>
      <h1>${componentName} Component</h1>
      {children}
    </div>
  );
};

export default ${componentName};
`;

// Fichier CSS
const cssContent = `.${componentName} {
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  margin: 1rem 0;
}
`;

// Fichier de test
const testContent = `import React from 'react';
import { render, screen } from '@testing-library/react';
import ${componentName} from './${componentName}';

describe('${componentName}', () => {
  it('should render successfully', () => {
    const { baseElement } = render(<${componentName} />);
    expect(baseElement).toBeTruthy();
  });

  it('should render children', () => {
    render(<${componentName}>Test Content</${componentName}>);
    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });
});
`;

// Fichier de storybook
const storyContent = `import React from 'react';
import { ComponentStory, ComponentMeta } from '@storybook/react';
import ${componentName} from './${componentName}';

export default {
  title: 'Components/${componentName}',
  component: ${componentName},
  argTypes: {
    className: { control: 'text' }
  }
} as ComponentMeta<typeof ${componentName}>;

const Template: ComponentStory<typeof ${componentName}> = (args) => <${componentName} {...args} />;

export const Primary = Template.bind({});
Primary.args = {
  children: 'Sample Content'
};
`;

// Écriture des fichiers
fs.writeFileSync(path.join(componentDir, `${componentName}.tsx`), tsxContent);
fs.writeFileSync(path.join(componentDir, `${componentName}.module.css`), cssContent);
fs.writeFileSync(path.join(componentDir, `${componentName}.test.tsx`), testContent);
fs.writeFileSync(path.join(componentDir, `${componentName}.stories.tsx`), storyContent);

console.log(`✅ Composant ${componentName} généré avec succès!`);
```

### Générateur de page Next.js
```javascript
// scripts/generate-page.js
const fs = require('fs');
const path = require('path');

const pageName = process.argv[2];
const pageType = process.argv[3] || 'app'; // 'app' ou 'pages'

if (!pageName) {
  console.error('Usage: node generate-page.js <PageName> [app|pages]');
  process.exit(1);
}

let pageDir;
if (pageType === 'app') {
  pageDir = path.join('src', 'app', pageName);
} else {
  pageDir = path.join('src', 'pages');
}

// Créer le répertoire
if (!fs.existsSync(pageDir)) {
  fs.mkdirSync(pageDir, { recursive: true });
}

// Fichier de page
const pageContent = `import React from 'react';

interface ${pageName.charAt(0).toUpperCase() + pageName.slice(1)}PageProps {
  // Définir les props ici
}

const ${pageName.charAt(0).toUpperCase() + pageName.slice(1)}Page: React.FC<${pageName.charAt(0).toUpperCase() + pageName.slice(1)}PageProps> = () => {
  return (
    <div className="${pageName}">
      <h1>${pageName.charAt(0).toUpperCase() + pageName.slice(1)} Page</h1>
      <p>Contenu de la page ${pageName}</p>
    </div>
  );
};

export default ${pageName.charAt(0).toUpperCase() + pageName.slice(1)}Page;
`;

// Fichier CSS
const cssContent = `.${pageName} {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
`;

// Fichier de test
const testContent = `import React from 'react';
import { render, screen } from '@testing-library/react';
import ${pageName.charAt(0).toUpperCase() + pageName.slice(1)}Page from './${pageName}';

describe('${pageName.charAt(0).toUpperCase() + pageName.slice(1)}Page', () => {
  it('should render successfully', () => {
    const { baseElement } = render(<${pageName.charAt(0).toUpperCase() + pageName.slice(1)}Page />);
    expect(baseElement).toBeTruthy();
  });

  it('should render page title', () => {
    render(<${pageName.charAt(0).toUpperCase() + pageName.slice(1)}Page />);
    expect(screen.getByText('${pageName.charAt(0).toUpperCase() + pageName.slice(1)} Page')).toBeInTheDocument();
  });
});
`;

// Écriture des fichiers
const fileName = pageType === 'app' ? 'page.tsx' : `${pageName}.tsx`;
fs.writeFileSync(path.join(pageDir, fileName), pageContent);
fs.writeFileSync(path.join(pageDir, `${pageName}.module.css`), cssContent);
fs.writeFileSync(path.join(pageDir, `${pageName}.test.tsx`), testContent);

console.log(`✅ Page ${pageName} générée avec succès dans ${pageDir}!`);
```

## Modèles de scaffolding

### Modèle de hook personnalisé
```javascript
// plop-templates/custom-hook.hbs
import { useState, useEffect } from 'react';

export const use{{pascalCase name}} = (initialValue) => {
  const [value, setValue] = useState(initialValue);

  useEffect(() => {
    // Logique personnalisée
  }, []);

  return [value, setValue];
};
```

### Modèle de contexte React
```javascript
// plop-templates/context.hbs
import React, { createContext, useContext, useReducer } from 'react';

// Types
export interface {{pascalCase name}}State {
  // Définir les propriétés d'état
}

export interface {{pascalCase name}}Actions {
  type: string;
  payload?: any;
}

// Initial State
const initialState: {{pascalCase name}}State = {
  // Initialiser l'état
};

// Reducer
const {{camelCase name}}Reducer = (state: {{pascalCase name}}State, action: {{pascalCase name}}Actions): {{pascalCase name}}State => {
  switch (action.type) {
    // Gérer les actions
    default:
      return state;
  }
};

// Context
const {{pascalCase name}}Context = createContext<{
  state: {{pascalCase name}}State;
  dispatch: React.Dispatch<{{pascalCase name}}Actions>;
}>({
  state: initialState,
  dispatch: () => null
});

// Provider
export const {{pascalCase name}}Provider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer({{camelCase name}}Reducer, initialState);

  return (
    <{{pascalCase name}}Context.Provider value={{ state, dispatch }}>
      {children}
    </{{pascalCase name}}Context.Provider>
  );
};

// Hook personnalisé
export const use{{pascalCase name}} = () => {
  const context = useContext({{pascalCase name}}Context);
  if (!context) {
    throw new Error('use{{pascalCase name}} must be used within a {{pascalCase name}}Provider');
  }
  return context;
};
```

### Modèle de service API
```javascript
// plop-templates/api-service.hbs
import axios, { AxiosInstance } from 'axios';

export interface {{pascalCase name}}Entity {
  id: string;
  // Définir les propriétés de l'entité
}

export class {{pascalCase name}}Service {
  private api: AxiosInstance;

  constructor(baseURL: string) {
    this.api = axios.create({
      baseURL,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  async getAll(): Promise<{{pascalCase name}}Entity[]> {
    try {
      const response = await this.api.get('/{{kebabCase name}}');
      return response.data;
    } catch (error) {
      console.error('Error fetching {{kebabCase name}}:', error);
      throw error;
    }
  }

  async getById(id: string): Promise<{{pascalCase name}}Entity> {
    try {
      const response = await this.api.get(\`/{{kebabCase name}}/\${id}\`);
      return response.data;
    } catch (error) {
      console.error(\`Error fetching {{kebabCase name}} \${id}:\`, error);
      throw error;
    }
  }

  async create(data: Omit<{{pascalCase name}}Entity, 'id'>): Promise<{{pascalCase name}}Entity> {
    try {
      const response = await this.api.post('/{{kebabCase name}}', data);
      return response.data;
    } catch (error) {
      console.error('Error creating {{kebabCase name}}:', error);
      throw error;
    }
  }

  async update(id: string, data: Partial<{{pascalCase name}}Entity>): Promise<{{pascalCase name}}Entity> {
    try {
      const response = await this.api.put(\`/{{kebabCase name}}/\${id}\`, data);
      return response.data;
    } catch (error) {
      console.error(\`Error updating {{kebabCase name}} \${id}:\`, error);
      throw error;
    }
  }

  async delete(id: string): Promise<void> {
    try {
      await this.api.delete(\`/{{kebabCase name}}/\${id}\`);
    } catch (error) {
      console.error(\`Error deleting {{kebabCase name}} \${id}:\`, error);
      throw error;
    }
  }
}
```

## Génération conditionnelle

### Modèle avec conditions
```handlebars
---
to: src/components/{{pascalCase name}}/{{pascalCase name}}.tsx
---
import React from 'react';

interface {{pascalCase name}}Props {
  children?: React.ReactNode;
  className?: string;
{{#if withStyle}}
  variant?: 'primary' | 'secondary';
{{/if}}
}

const {{pascalCase name}}: React.FC<{{pascalCase name}}Props> = ({ 
  children, 
  className = '',
{{#if withStyle}}
  variant = 'primary'
{{/if}}
}) => {
  return (
    <div 
      className={\`{{pascalCase name}} \${className}\${{{#if withStyle}} variant ? \` \${variant}\` : ''{{/if}}}\`}
    >
      <h1>{{pascalCase name}} Component</h1>
      {children}
    </div>
  );
};

export default {{pascalCase name}};
```

## Intégration dans les outils de développement

### Intégration avec VS Code
Créer un fichier `snippets/code-snippets.json`:
```json
{
  "React Component": {
    "prefix": "reactcmp",
    "body": [
      "import React from 'react';",
      "",
      "interface ${1:ComponentName}Props {",
      "  children?: React.ReactNode;",
      "  className?: string;",
      "}",
      "",
      "const ${1:ComponentName}: React.FC<${1:ComponentName}Props> = ({",
      "  children,",
      "  className = ''",
      "}) => {",
      "  return (",
      "    <div className={`${1:ComponentName} \${className}`}>\n      {children}",
      "    </div>",
      "  );",
      "};",
      "",
      "export default ${1:ComponentName};"
    ],
    "description": "Génère un composant React avec TypeScript"
  }
}
```

### Intégration avec CLI
```javascript
#!/usr/bin/env node
// bin/generate.js

const { program } = require('commander');
const fs = require('fs');
const path = require('path');

program
  .name('generate')
  .description('CLI pour générer des composants et services')
  .version('1.0.0');

program
  .command('component <name>')
  .description('Générer un composant React')
  .option('-t, --typescript', 'Générer avec TypeScript')
  .option('-s, --with-styles', 'Inclure un fichier de styles')
  .option('-t, --with-tests', 'Inclure des tests')
  .action((name, options) => {
    // Logique de génération de composant
    console.log(`Génération du composant: ${name}`);
    console.log('Options:', options);
  });

program
  .command('service <name>')
  .description('Générer un service API')
  .option('-t, --typescript', 'Générer avec TypeScript')
  .action((name, options) => {
    // Logique de génération de service
    console.log(`Génération du service: ${name}`);
  });

program.parse();
```

## Bonnes pratiques de scaffolding

### 1. Modèles réutilisables
- Créer des modèles génériques qui peuvent être adaptés
- Utiliser des variables dans les modèles pour la personnalisation
- Maintenir une bibliothèque de modèles éprouvés

### 2. Cohérence
- Suivre les conventions de nommage du projet
- Maintenir une structure de fichiers cohérente
- Utiliser les mêmes outils et bibliothèques dans tous les modèles

### 3. Extensibilité
- Créer des générateurs paramétrables
- Permettre l'ajout de fonctionnalités supplémentaires
- Prévoir des options pour différents types de projets

### 4. Documentation
- Documenter chaque générateur et ses options
- Fournir des exemples d'utilisation
- Maintenir une liste des générateurs disponibles
```