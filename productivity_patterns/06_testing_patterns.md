# Modèles de test

## Description
Ce document présente des modèles et des stratégies de test complets pour les applications modernes, avec des exemples concrets pour différents types de tests et environnements.

## Types de tests

### 1. Tests unitaires

#### Modèle de test unitaire avancé
```javascript
// helpers/test-helpers.js
const sinon = require('sinon');
const chai = require('chai');
const { expect } = chai;

class TestHelper {
  constructor() {
    this.sandbox = sinon.createSandbox();
    this.mocks = new Map();
    this.stubs = new Map();
  }

  // Créer un mock pour un service
  mockService(serviceName, methods = {}) {
    const mock = this.sandbox.mock(serviceName);
    
    for (const [methodName, returnValue] of Object.entries(methods)) {
      mock.expects(methodName).returns(returnValue);
    }
    
    this.mocks.set(serviceName, mock);
    return mock;
  }

  // Créer un stub pour une fonction
  stubFunction(fn, returnValues = []) {
    const stub = this.sandbox.stub();
    
    if (Array.isArray(returnValues)) {
      stub.onCall(0).returns(returnValues[0]);
      for (let i = 1; i < returnValues.length; i++) {
        stub.onCall(i).returns(returnValues[i]);
      }
    } else {
      stub.returns(returnValues);
    }
    
    return stub;
  }

  // Créer un spy pour une méthode
  spyMethod(obj, methodName) {
    const spy = this.sandbox.spy(obj, methodName);
    return spy;
  }

  // Configurer un environnement de test
  setupTestEnvironment(config = {}) {
    // Sauvegarder les valeurs originales
    this.originalEnv = { ...process.env };
    
    // Configurer les variables d'environnement de test
    process.env.NODE_ENV = 'test';
    process.env.DATABASE_URL = config.databaseUrl || 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = config.jwtSecret || 'test-secret';
    
    // Autres configurations spécifiques
    if (config.mockDatabase) {
      this.mockDatabase();
    }
    
    if (config.mockExternalServices) {
      this.mockExternalServices();
    }
  }

  mockDatabase() {
    // Exemple avec Mongoose
    this.dbMock = {
      connect: this.sandbox.stub().resolves(),
      disconnect: this.sandbox.stub().resolves(),
      connection: {
        on: this.sandbox.stub(),
        once: this.sandbox.stub()
      }
    };
  }

  mockExternalServices() {
    // Mock des services externes comme Stripe, SendGrid, etc.
    this.externalServices = {
      stripe: {
        customers: {
          create: this.sandbox.stub().resolves({ id: 'cus_test123' })
        },
        charges: {
          create: this.sandbox.stub().resolves({ id: 'ch_test123', status: 'succeeded' })
        }
      },
      sendgrid: {
        send: this.sandbox.stub().resolves()
      }
    };
  }

  // Réinitialiser l'environnement de test
  reset() {
    this.sandbox.restore();
    this.mocks.clear();
    this.stubs.clear();
    
    // Restaurer l'environnement original
    if (this.originalEnv) {
      process.env = { ...this.originalEnv };
    }
  }

  // Assertions personnalisées
  expectAsync(fn, assertion) {
    return fn.catch(error => {
      assertion(error);
      throw error;
    });
  }

  // Vérifier que les attentes de mock sont satisfaites
  verifyMocks() {
    for (const [serviceName, mock] of this.mocks) {
      try {
        mock.verify();
      } catch (error) {
        console.error(`Erreur de vérification du mock pour ${serviceName}:`, error);
        throw error;
      }
    }
  }

  // Attendre que toutes les promesses soient résolues
  async waitForPromises() {
    // Pour les tests asynchrones
    await new Promise(resolve => setImmediate(resolve));
  }
}

// Utilisation dans les tests
describe('Service utilisateur', () => {
  let testHelper;
  let userService;
  let userRepository;

  before(() => {
    testHelper = new TestHelper();
    testHelper.setupTestEnvironment({
      mockDatabase: true,
      mockExternalServices: true
    });
  });

  beforeEach(() => {
    // Réinitialiser avant chaque test
    testHelper.reset();
    
    // Créer les dépendances du service
    userRepository = {
      findById: testHelper.stubFunction(),
      findByEmail: testHelper.stubFunction(),
      create: testHelper.stubFunction(),
      update: testHelper.stubFunction()
    };
    
    userService = new UserService({ userRepository });
  });

  after(() => {
    testHelper.reset();
  });

  describe('getUserProfile', () => {
    it('devrait retourner le profil utilisateur', async () => {
      // Arrange
      const userId = '123';
      const expectedUser = { id: userId, name: 'John Doe', email: 'john@example.com' };
      
      userRepository.findById.resolves(expectedUser);

      // Act
      const result = await userService.getUserProfile(userId);

      // Assert
      expect(result).to.deep.equal(expectedUser);
      expect(userRepository.findById.calledOnce).to.be.true;
      expect(userRepository.findById.firstCall.args[0]).to.equal(userId);
    });

    it('devrait lever une erreur si l\'utilisateur n\'existe pas', async () => {
      // Arrange
      const userId = '999';
      userRepository.findById.resolves(null);

      // Act & Assert
      await expect(
        userService.getUserProfile(userId)
      ).to.be.rejectedWith('Utilisateur non trouvé');
    });

    it('devrait appeler les services externes lors de la création d\'un utilisateur', async () => {
      // Arrange
      const userData = { name: 'Jane Doe', email: 'jane@example.com' };
      const createdUser = { id: '456', ...userData };
      
      userRepository.create.resolves(createdUser);
      testHelper.externalServices.stripe.customers.create.resolves({ id: 'cus_456' });

      // Act
      const result = await userService.createUser(userData);

      // Assert
      expect(result).to.deep.equal(createdUser);
      expect(testHelper.externalServices.stripe.customers.create.calledOnce).to.be.true;
      expect(testHelper.externalServices.stripe.customers.create.firstCall.args[0])
        .to.deep.equal({ email: userData.email });
    });
  });

  // Tests paramétrés
  describe('validation des emails', () => {
    const emailTestCases = [
      { email: 'valid@example.com', isValid: true },
      { email: 'user.name+tag@example.co.uk', isValid: true },
      { email: 'invalid-email', isValid: false },
      { email: '@example.com', isValid: false },
      { email: 'user@', isValid: false }
    ];

    emailTestCases.forEach(({ email, isValid }) => {
      it(`devrait ${isValid ? 'valider' : 'rejeter'} l'email ${email}`, () => {
        const result = userService.validateEmail(email);
        expect(result).to.equal(isValid);
      });
    });
  });

  // Tests de performance
  describe('performance des opérations', () => {
    it('devrait exécuter getUserProfile en moins de 100ms', async function() {
      this.timeout(200); // Timeout pour ce test spécifique
      
      const userId = '123';
      userRepository.findById.resolves({ id: userId, name: 'Test User' });
      
      const startTime = Date.now();
      await userService.getUserProfile(userId);
      const endTime = Date.now();
      
      const executionTime = endTime - startTime;
      expect(executionTime).to.be.lessThan(100);
    });
  });
});
```

#### Tests de composants React
```javascript
// tests/Component.test.js
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { setupServer } from 'msw/node';

// Mock du serveur pour les tests API
const server = setupServer(
  rest.get('/api/users/:id', (req, res, ctx) => {
    const { id } = req.params;
    return res(
      ctx.json({ id, name: 'Test User', email: 'test@example.com' })
    );
  }),
  rest.post('/api/users', (req, res, ctx) => {
    const { name, email } = req.body;
    return res(
      ctx.status(201),
      ctx.json({ id: '123', name, email })
    );
  })
);

// Setup avant tous les tests
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// Helper pour le rendu des composants
const renderWithProviders = (
  ui,
  {
    preloadedState = {},
    store = configureStore({ 
      reducer: { 
        // Ajouter vos reducers ici
      },
      preloadedState 
    }),
    ...renderOptions
  } = {}
) => {
  const Wrapper = ({ children }) => (
    <Provider store={store}>
      <BrowserRouter>
        {children}
      </BrowserRouter>
    </Provider>
  );

  return render(ui, { wrapper: Wrapper, ...renderOptions });
};

// Tests du composant utilisateur
describe('UserProfile Component', () => {
  const defaultProps = {
    userId: '123'
  };

  beforeEach(() => {
    // Nettoyer les appels de mock avant chaque test
    jest.clearAllMocks();
  });

  it('devrait afficher les détails de l\'utilisateur', async () => {
    renderWithProviders(<UserProfile {...defaultProps} />);

    // Vérifier le chargement
    expect(screen.getByText(/chargement/i)).toBeInTheDocument();

    // Attendre que les données soient chargées
    await waitFor(() => {
      expect(screen.getByText(/test user/i)).toBeInTheDocument();
    });

    expect(screen.getByText(/test@example.com/i)).toBeInTheDocument();
  });

  it('devrait gérer les erreurs de chargement', async () => {
    server.use(
      rest.get('/api/users/:id', (req, res, ctx) => {
        return res(ctx.status(500), ctx.json({ error: 'Internal Server Error' }));
      })
    );

    renderWithProviders(<UserProfile {...defaultProps} />);

    await waitFor(() => {
      expect(screen.getByText(/erreur/i)).toBeInTheDocument();
    });
  });

  it('devrait permettre la mise à jour du profil', async () => {
    const user = userEvent.setup();
    renderWithProviders(<UserProfile {...defaultProps} />);

    // Attendre le chargement
    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: /nom/i })).toBeInTheDocument();
    });

    // Simuler la modification
    const nameInput = screen.getByRole('textbox', { name: /nom/i });
    await user.clear(nameInput);
    await user.type(nameInput, 'Updated Name');

    const saveButton = screen.getByRole('button', { name: /sauvegarder/i });
    await user.click(saveButton);

    // Vérifier que l'appel API a été fait
    await waitFor(() => {
      expect(screen.getByText(/profil mis à jour/i)).toBeInTheDocument();
    });
  });

  // Tests d'accessibilité
  it('devrait être accessible', async () => {
    const { container } = renderWithProviders(<UserProfile {...defaultProps} />);
    
    // Vérifier l'accessibilité avec axe
    const axe = require('axe-core');
    const results = await axe.run(container);
    
    expect(results.violations).toHaveLength(0);
  });

  // Tests de performance de rendu
  it('devrait se rendre rapidement', () => {
    const startTime = performance.now();
    renderWithProviders(<UserProfile {...defaultProps} />);
    const endTime = performance.now();
    
    const renderTime = endTime - startTime;
    expect(renderTime).toBeLessThan(100); // Rendu en moins de 100ms
  });
});

// Tests de hooks personnalisés
describe('useApi hook', () => {
  const TestComponent = ({ url, options = {} }) => {
    const { data, loading, error } = useApi(url, options);
    
    if (loading) return <div>Chargement...</div>;
    if (error) return <div>Erreur: {error.message}</div>;
    if (data) return <div data-testid="data">{JSON.stringify(data)}</div>;
    
    return <div>Pas de données</div>;
  };

  it('devrait charger les données avec succès', async () => {
    server.use(
      rest.get('/api/test', (req, res, ctx) => {
        return res(ctx.json({ message: 'success' }));
      })
    );

    renderWithProviders(<TestComponent url="/api/test" />);

    expect(screen.getByText(/chargement/i)).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByTestId('data')).toHaveTextContent('success');
    });
  });

  it('devrait gérer les erreurs', async () => {
    server.use(
      rest.get('/api/test-error', (req, res, ctx) => {
        return res(ctx.status(500), ctx.json({ error: 'Server Error' }));
      })
    );

    renderWithProviders(<TestComponent url="/api/test-error" />);

    await waitFor(() => {
      expect(screen.getByText(/erreur/i)).toBeInTheDocument();
    });
  });

  it('devrait permettre le rechargement', async () => {
    let callCount = 0;
    
    server.use(
      rest.get('/api/retry', (req, res, ctx) => {
        callCount++;
        if (callCount === 1) {
          return res(ctx.status(500), ctx.json({ error: 'First attempt failed' }));
        }
        return res(ctx.json({ message: 'Success after retry' }));
      })
    );

    const { rerender } = renderWithProviders(<TestComponent url="/api/retry" />);
    
    // Premier appel échoue
    await waitFor(() => {
      expect(screen.getByText(/erreur/i)).toBeInTheDocument();
    });

    // Réessayer
    rerender(<TestComponent url="/api/retry" retry={true} />);
    
    await waitFor(() => {
      expect(screen.getByTestId('data')).toHaveTextContent('Success after retry');
    });
  });
});
```

### 2. Tests d'intégration

#### Modèle de test d'intégration
```javascript
// integration-tests/helpers/db-helpers.js
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

class DatabaseTestHelper {
  constructor() {
    this.mongoServer = null;
    this.connection = null;
  }

  async start() {
    this.mongoServer = await MongoMemoryServer.create();
    const uri = this.mongoServer.getUri();
    
    this.connection = await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
  }

  async stop() {
    if (this.connection) {
      await this.connection.disconnect();
    }
    if (this.mongoServer) {
      await this.mongoServer.stop();
    }
  }

  async clearCollections() {
    const collections = Object.keys(this.connection.connection.collections);
    for (const collectionName of collections) {
      const collection = this.connection.connection.collections[collectionName];
      await collection.deleteMany({});
    }
  }

  async seedData(seedFunction) {
    await this.clearCollections();
    return await seedFunction(this.connection);
  }
}

// integration-tests/user.integration.test.js
const request = require('supertest');
const app = require('../../src/app');
const DatabaseTestHelper = require('./helpers/db-helpers');

describe('API Utilisateur - Tests d\'intégration', () => {
  let dbTestHelper;

  beforeAll(async () => {
    dbTestHelper = new DatabaseTestHelper();
    await dbTestHelper.start();
  });

  beforeEach(async () => {
    await dbTestHelper.clearCollections();
  });

  afterAll(async () => {
    await dbTestHelper.stop();
  });

  describe('GET /api/users/:id', () => {
    it('devrait retourner un utilisateur existant', async () => {
      // Préparer les données
      const user = await createUserInDb({ name: 'Test User', email: 'test@example.com' });

      // Exécuter la requête
      const response = await request(app)
        .get(`/api/users/${user._id}`)
        .expect(200);

      // Vérifier la réponse
      expect(response.body).toMatchObject({
        id: user._id.toString(),
        name: 'Test User',
        email: 'test@example.com'
      });
    });

    it('devrait retourner 404 pour un utilisateur inexistant', async () => {
      const fakeId = '507f1f77bcf86cd799439011';

      await request(app)
        .get(`/api/users/${fakeId}`)
        .expect(404);
    });

    it('devrait valider l\'ID de l\'utilisateur', async () => {
      await request(app)
        .get('/api/users/invalid-id')
        .expect(400);
    });
  });

  describe('POST /api/users', () => {
    it('devrait créer un nouvel utilisateur', async () => {
      const userData = {
        name: 'New User',
        email: 'newuser@example.com',
        password: 'SecurePassword123!'
      };

      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      expect(response.body).toMatchObject({
        name: 'New User',
        email: 'newuser@example.com'
      });

      // Vérifier que l'utilisateur existe dans la base de données
      const createdUser = await findUserByEmail('newuser@example.com');
      expect(createdUser).toBeDefined();
      expect(createdUser.name).toBe('New User');
    });

    it('devrait valider les données d\'entrée', async () => {
      const invalidUserData = {
        name: '', // Nom vide
        email: 'invalid-email', // Email invalide
        password: '123' // Mot de passe trop court
      };

      const response = await request(app)
        .post('/api/users')
        .send(invalidUserData)
        .expect(400);

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors.length).toBeGreaterThan(0);
    });

    it('devrait empêcher la duplication d\'email', async () => {
      const userData = {
        name: 'User One',
        email: 'unique@example.com',
        password: 'SecurePassword123!'
      };

      // Créer le premier utilisateur
      await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      // Essayer de créer un utilisateur avec le même email
      await request(app)
        .post('/api/users')
        .send(userData)
        .expect(409); // Conflict
    });
  });

  describe('PUT /api/users/:id', () => {
    it('devrait mettre à jour un utilisateur existant', async () => {
      const user = await createUserInDb({ 
        name: 'Original Name', 
        email: 'original@example.com' 
      });

      const updateData = { name: 'Updated Name', email: 'updated@example.com' };

      const response = await request(app)
        .put(`/api/users/${user._id}`)
        .send(updateData)
        .expect(200);

      expect(response.body).toMatchObject({
        name: 'Updated Name',
        email: 'updated@example.com'
      });

      // Vérifier la mise à jour dans la base de données
      const updatedUser = await findUserById(user._id);
      expect(updatedUser.name).toBe('Updated Name');
    });

    it('devrait valider les permissions', async () => {
      const user = await createUserInDb({ 
        name: 'Test User', 
        email: 'test@example.com',
        role: 'user'
      });

      // Essayer de mettre à jour avec un token d'utilisateur non autorisé
      const token = generateToken({ id: 'other-user-id', role: 'user' });

      await request(app)
        .put(`/api/users/${user._id}`)
        .set('Authorization', `Bearer ${token}`)
        .send({ role: 'admin' })
        .expect(403); // Forbidden
    });
  });

  describe('Sécurité des API', () => {
    it('devrait bloquer les requêtes sans authentification', async () => {
      await request(app)
        .get('/api/users/profile')
        .expect(401); // Unauthorized
    });

    it('devrait protéger contre les attaques de type injection', async () => {
      const maliciousPayload = {
        name: 'John',
        email: 'john@example.com',
        bio: '<script>alert("XSS")</script>'
      };

      const response = await request(app)
        .post('/api/users')
        .send(maliciousPayload)
        .expect(201);

      // Vérifier que le contenu dangereux a été nettoyé
      expect(response.body.bio).not.toContain('<script>');
    });

    it('devrait limiter les requêtes', async () => {
      // Simuler de nombreuses requêtes
      const promises = [];
      for (let i = 0; i < 100; i++) {
        promises.push(
          request(app)
            .get('/api/users/nonexistent')
            .set('X-Forwarded-For', '192.168.1.1')
        );
      }

      const responses = await Promise.all(promises);
      const tooManyRequests = responses.filter(r => r.status === 429);
      
      expect(tooManyRequests.length).toBeGreaterThan(0);
    });
  });
});

// Helper functions
async function createUserInDb(userData) {
  const User = require('../../src/models/User');
  const user = new User(userData);
  return await user.save();
}

async function findUserByEmail(email) {
  const User = require('../../src/models/User');
  return await User.findOne({ email });
}

async function findUserById(id) {
  const User = require('../../src/models/User');
  return await User.findById(id);
}

function generateToken(payload) {
  const jwt = require('jsonwebtoken');
  return jwt.sign(payload, process.env.JWT_SECRET || 'test-secret');
}
```

### 3. Tests E2E avec Cypress

#### Modèle de test E2E
```javascript
// cypress/support/commands.js
// Commandes personnalisées pour les tests E2E

Cypress.Commands.add('login', (email, password) => {
  cy.visit('/login');
  
  cy.get('[data-cy=email-input]').type(email);
  cy.get('[data-cy=password-input]').type(password);
  cy.get('[data-cy=login-button]').click();
  
  // Vérifier que la connexion a réussi
  cy.url().should('include', '/dashboard');
  cy.get('[data-cy=user-menu]').should('be.visible');
});

Cypress.Commands.add('logout', () => {
  cy.get('[data-cy=user-menu]').click();
  cy.get('[data-cy=logout-button]').click();
  cy.url().should('include', '/login');
});

Cypress.Commands.add('seedDatabase', (seedData) => {
  cy.task('seedDatabase', seedData);
});

Cypress.Commands.add('resetDatabase', () => {
  cy.task('resetDatabase');
});

Cypress.Commands.add('interceptGraphQL', (operationName, fixture) => {
  cy.intercept('POST', '/graphql', (req) => {
    if (req.body.operationName === operationName) {
      req.reply({ fixture });
    }
  }).as(operationName);
});

// cypress/e2e/auth-flow.cy.js
describe('Flux d\'authentification', () => {
  beforeEach(() => {
    cy.resetDatabase();
    cy.visit('/');
  });

  it('devrait permettre à un utilisateur de se connecter', () => {
    // Se rendre sur la page de connexion
    cy.get('[data-cy=login-link]').click();
    cy.url().should('include', '/login');

    // Remplir le formulaire
    cy.get('[data-cy=email-input]').type('test@example.com');
    cy.get('[data-cy=password-input]').type('password123');
    cy.get('[data-cy=login-button]').click();

    // Vérifier la redirection vers le dashboard
    cy.url().should('include', '/dashboard');
    cy.contains('Bienvenue, Test User').should('be.visible');

    // Vérifier que les cookies sont correctement définis
    cy.getCookie('authToken').should('exist');
  });

  it('devrait afficher une erreur pour les identifiants invalides', () => {
    cy.get('[data-cy=email-input]').type('wrong@example.com');
    cy.get('[data-cy=password-input]').type('wrongpassword');
    cy.get('[data-cy=login-button]').click();

    cy.contains('Identifiants invalides').should('be.visible');
    cy.url().should('include', '/login');
  });

  it('devrait permettre à un utilisateur de se déconnecter', () => {
    cy.login('test@example.com', 'password123');
    
    cy.get('[data-cy=user-menu]').click();
    cy.get('[data-cy=logout-button]').click();

    cy.url().should('include', '/login');
    cy.contains('Vous avez été déconnecté').should('be.visible');
    cy.getCookie('authToken').should('not.exist');
  });

  it('devrait rediriger vers la page de connexion si non authentifié', () => {
    cy.visit('/dashboard');
    cy.url().should('include', '/login');
    cy.contains('Veuillez vous connecter').should('be.visible');
  });
});

// cypress/e2e/user-profile.cy.js
describe('Profil utilisateur', () => {
  beforeEach(() => {
    cy.seedDatabase({
      users: [{
        id: 'user-123',
        email: 'profile@example.com',
        name: 'Profile User',
        role: 'user'
      }]
    });
    
    cy.login('profile@example.com', 'password123');
  });

  it('devrait permettre la mise à jour du profil', () => {
    cy.visit('/profile');
    
    // Vérifier les données initiales
    cy.get('[data-cy=name-input]').should('have.value', 'Profile User');
    cy.get('[data-cy=email-input]').should('have.value', 'profile@example.com');

    // Mettre à jour les informations
    cy.get('[data-cy=name-input]').clear().type('Updated Name');
    cy.get('[data-cy=bio-input]').type('This is my bio');
    
    cy.get('[data-cy=save-button]').click();
    
    // Vérifier la confirmation
    cy.contains('Profil mis à jour avec succès').should('be.visible');
    
    // Vérifier que les données sont mises à jour
    cy.reload();
    cy.get('[data-cy=name-input]').should('have.value', 'Updated Name');
    cy.get('[data-cy=bio-input]').should('have.value', 'This is my bio');
  });

  it('devrait valider les entrées du formulaire', () => {
    cy.visit('/profile');
    
    // Essayer de soumettre un nom vide
    cy.get('[data-cy=name-input]').clear();
    cy.get('[data-cy=save-button]').click();
    
    cy.contains('Le nom est requis').should('be.visible');
  });

  it('devrait permettre le téléchargement d\'avatar', () => {
    cy.visit('/profile');
    
    // Uploader un avatar
    cy.get('[data-cy=avatar-upload]').attachFile('avatar.jpg');
    
    // Vérifier que l'upload est en cours
    cy.get('[data-cy=upload-progress]').should('be.visible');
    
    // Vérifier que l'avatar est affiché après upload
    cy.get('[data-cy=user-avatar]').should('be.visible');
  });
});

// cypress/e2e/dashboard.cy.js
describe('Tableau de bord', () => {
  beforeEach(() => {
    cy.seedDatabase({
      users: [{ id: 'user-123', email: 'dashboard@example.com', name: 'Dashboard User' }],
      projects: [
        { id: 'proj-1', name: 'Project 1', userId: 'user-123' },
        { id: 'proj-2', name: 'Project 2', userId: 'user-123' }
      ]
    });
    
    cy.login('dashboard@example.com', 'password123');
  });

  it('devrait afficher les projets de l\'utilisateur', () => {
    cy.visit('/dashboard');
    
    cy.contains('Project 1').should('be.visible');
    cy.contains('Project 2').should('be.visible');
    
    // Vérifier le nombre de projets
    cy.get('[data-cy=project-card]').should('have.length', 2);
  });

  it('devrait permettre la création d\'un nouveau projet', () => {
    cy.visit('/dashboard');
    
    cy.get('[data-cy=create-project-button]').click();
    
    cy.get('[data-cy=project-name-input]').type('New Project');
    cy.get('[data-cy=project-description-textarea]').type('Project description');
    
    cy.get('[data-cy=save-project-button]').click();
    
    // Vérifier que le projet est créé
    cy.contains('New Project').should('be.visible');
  });

  it('devrait permettre de filtrer les projets', () => {
    cy.visit('/dashboard');
    
    // Filtrer par nom
    cy.get('[data-cy=search-input]').type('Project 1');
    
    // Vérifier qu'un seul projet est affiché
    cy.get('[data-cy=project-card]').should('have.length', 1);
    cy.contains('Project 1').should('be.visible');
    cy.contains('Project 2').should('not.exist');
  });

  it('devrait charger les données de manière asynchrone', () => {
    // Intercepter les appels API
    cy.intercept('GET', '/api/projects*', {
      statusCode: 200,
      body: {
        data: [
          { id: '1', name: 'Delayed Project', createdAt: '2023-01-01' }
        ],
        pagination: { total: 1, page: 1, limit: 10 }
      }
    }).as('getProjects');

    cy.visit('/dashboard');
    
    // Vérifier l'indicateur de chargement
    cy.get('[data-cy=loading-spinner]').should('be.visible');
    
    // Attendre la fin du chargement
    cy.wait('@getProjects');
    cy.get('[data-cy=loading-spinner]').should('not.exist');
    
    // Vérifier les données chargées
    cy.contains('Delayed Project').should('be.visible');
  });
});

// cypress.config.js
const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // Implémentation des tâches
      on('task', {
        seedDatabase(seedData) {
          // Implémenter le seeding de la base de données
          // Cela pourrait impliquer de se connecter à la base de données
          // et d'insérer les données de test
          console.log('Seeding database with:', seedData);
          return null;
        },
        
        resetDatabase() {
          // Réinitialiser la base de données
          console.log('Resetting database');
          return null;
        },
        
        async clearUploads() {
          // Nettoyer les fichiers uploadés
          const fs = require('fs-extra');
          await fs.emptyDir('uploads');
          return null;
        }
      });
    },
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 30000
  }
});
```

## Modèles de test de performance

### 1. Tests de charge avec Artillery

#### Modèle de test de charge
```yaml
# performance-tests/load-test.yml
config:
  target: 'http://localhost:3000'
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Progressive ramp-up"
    - duration: 300
      arrivalRate: 50
      name: "Sustained load"
    - duration: 60
      arrivalRate: 10
      name: "Cool down"
  
  defaults:
    headers:
      Content-Type: "application/json"
      User-Agent: "Artillery Load Test"
  
  plugins:
    ensure: 
      thresholds:
        - actual: p95
          expected: '< 1000'
          comparator: '<'
        - actual: p99
          expected: '< 2000'
          comparator: '<'
        - actual: http.response_time.median
          expected: '< 500'
          comparator: '<'
        - actual: http.responses
          expected: '>= 95'
          comparator: '>='

scenarios:
  - name: "Test d'API utilisateur"
    weight: 40
    flow:
      - post:
          url: "/api/users"
          json:
            name: "{{ profile.name }}"
            email: "{{ profile.email }}"
            password: "{{ profile.password }}"
          capture:
            - json: "$.id"
              as: "userId"
      - get:
          url: "/api/users/{{ userId }}"
          expect:
            - statusCode: 200
            - contentType: "application/json"
  
  - name: "Test d'authentification"
    weight: 30
    flow:
      - post:
          url: "/api/auth/login"
          json:
            email: "{{ login.email }}"
            password: "{{ login.password }}"
          capture:
            - json: "$.token"
              as: "authToken"
      - get:
          url: "/api/users/profile"
          headers:
            Authorization: "Bearer {{ authToken }}"
          expect:
            - statusCode: 200
  
  - name: "Test de consultation de données"
    weight: 30
    flow:
      - get:
          url: "/api/products"
          qs:
            limit: 20
            page: 1
          expect:
            - statusCode: 200
            - contentType: "application/json"
      - get:
          url: "/api/products/{{ $randomInt(1, 1000) }}"

# Fichiers de données pour les tests
# users.csv
# name,email,password
# John Doe,john{{ $randomInt(1, 10000) }}@example.com,Password123!
# Jane Smith,jane{{ $randomInt(1, 10000) }}@example.com,Password123!

# Variables de profil
before:
  flow:
    - function: generateProfile

functions:
  generateProfile: |
    const faker = require('faker');
    return {
      profile: {
        name: faker.name.findName(),
        email: faker.internet.email(),
        password: faker.internet.password(8, true, /[A-Z]/, 'Password1!')
      },
      login: {
        email: 'test@example.com',
        password: 'password123'
      }
    };
```

#### Script de test de performance avancé
```javascript
// performance-tests/performance-suite.js
const autocannon = require('autocannon');
const fs = require('fs').promises;
const path = require('path');

class PerformanceTestSuite {
  constructor(options = {}) {
    this.tests = [];
    this.results = [];
    this.options = {
      connections: options.connections || 100,
      pipelining: options.pipelining || 1,
      duration: options.duration || 30,
      ...options
    };
  }

  addTest(name, url, options = {}) {
    this.tests.push({
      name,
      url,
      options: { ...this.options, ...options }
    });
  }

  async runAllTests() {
    const results = [];
    
    for (const test of this.tests) {
      console.log(`Exécution du test: ${test.name}`);
      const result = await this.runSingleTest(test);
      results.push({ ...test, result });
    }
    
    this.results = results;
    return results;
  }

  async runSingleTest(test) {
    return new Promise((resolve, reject) => {
      const instance = autocannon(
        {
          url: test.url,
          connections: test.options.connections,
          pipelining: test.options.pipelining,
          duration: test.options.duration,
          method: test.options.method || 'GET',
          headers: test.options.headers || {},
          body: test.options.body || undefined
        },
        (err, result) => {
          if (err) {
            reject(err);
          } else {
            resolve(result);
          }
        }
      );

      // Afficher la progression
      autocannon.track(instance, { renderProgressBar: true });
    });
  }

  async generateReport() {
    const report = {
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
      tests: this.results.map(testResult => ({
        name: testResult.name,
        url: testResult.url,
        connections: testResult.result.connections,
        duration: testResult.result.duration,
        requests: {
          sent: testResult.result.requests.sent,
          received: testResult.result.requests.received,
          throughput: testResult.result.throughput.mean
        },
        latency: {
          average: testResult.result.latency.mean,
          p50: testResult.result.latency.p50,
          p95: testResult.result.latency.p95,
          p99: testResult.result.latency.p99,
          max: testResult.result.latency.max
        },
        errors: testResult.result.errors
      })),
      summary: {
        totalTests: this.results.length,
        totalRequests: this.results.reduce((sum, test) => 
          sum + test.result.requests.received, 0),
        averageLatency: this.results.reduce((sum, test) => 
          sum + test.result.latency.mean, 0) / this.results.length,
        averageThroughput: this.results.reduce((sum, test) => 
          sum + test.result.throughput.mean, 0) / this.results.length
      }
    };

    // Sauvegarder le rapport
    const reportPath = path.join('performance-reports', `report-${Date.now()}.json`);
    await fs.mkdir(path.dirname(reportPath), { recursive: true });
    await fs.writeFile(reportPath, JSON.stringify(report, null, 2));

    return report;
  }

  async compareWithBaseline(baselinePath) {
    const baseline = JSON.parse(await fs.readFile(baselinePath, 'utf8'));
    const current = await this.generateReport();

    const comparison = {
      ...current,
      comparisons: current.tests.map((currentTest, index) => {
        const baselineTest = baseline.tests[index];
        if (!baselineTest) return null;

        return {
          testName: currentTest.name,
          latencyImprovement: baselineTest.latency.average - currentTest.latency.average,
          throughputChange: currentTest.requests.throughput - baselineTest.requests.throughput,
          regressionDetected: currentTest.latency.p95 > baselineTest.latency.p95 * 1.1
        };
      }).filter(Boolean)
    };

    return comparison;
  }

  async setupDatabaseForTest() {
    // Préparer la base de données avec des données de test
    console.log('Préparation de la base de données pour les tests de performance...');
    
    // Créer des utilisateurs de test
    const testUsers = Array.from({ length: 1000 }, (_, i) => ({
      id: `test-user-${i}`,
      email: `test${i}@example.com`,
      name: `Test User ${i}`
    }));

    // Sauvegarder dans un fichier temporaire pour les tests
    await fs.writeFile(
      'temp/test-users.json', 
      JSON.stringify(testUsers)
    );

    console.log('Base de données préparée avec 1000 utilisateurs de test');
  }

  async cleanup() {
    // Nettoyer les ressources après les tests
    try {
      await fs.unlink('temp/test-users.json');
    } catch (error) {
      // Le fichier peut ne pas exister
    }
  }

  async runWithMonitoring() {
    // Exécuter les tests avec surveillance système
    const os = require('os');
    const cluster = require('cluster');
    
    if (cluster.isMaster) {
      // Processus maître - surveillance système
      const numWorkers = os.cpus().length;
      
      for (let i = 0; i < numWorkers; i++) {
        cluster.fork();
      }

      // Surveillance des ressources
      const systemMonitor = setInterval(() => {
        const cpuUsage = process.cpuUsage();
        const memoryUsage = process.memoryUsage();
        
        console.log('Ressources système:', {
          cpu: cpuUsage,
          memory: memoryUsage,
          timestamp: new Date().toISOString()
        });
      }, 1000);

      cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker ${worker.process.pid} died`);
      });

      // Exécuter les tests
      const results = await this.runAllTests();
      
      // Arrêter la surveillance
      clearInterval(systemMonitor);
      cluster.disconnect();
      
      return results;
    } else {
      // Workers - exécuter les tests
      return await this.runAllTests();
    }
  }
}

// Utilisation
async function runPerformanceTests() {
  const perfSuite = new PerformanceTestSuite({
    connections: 50,
    duration: 60
  });

  // Ajouter des tests pour différentes endpoints
  perfSuite.addTest(
    'API Utilisateurs - Lecture', 
    'http://localhost:3000/api/users',
    { method: 'GET' }
  );

  perfSuite.addTest(
    'API Utilisateurs - Création',
    'http://localhost:3000/api/users',
    { 
      method: 'POST',
      body: JSON.stringify({
        name: 'Performance Test User',
        email: 'perf-test@example.com',
        password: 'SecurePassword123!'
      }),
      headers: { 'Content-Type': 'application/json' }
    }
  );

  perfSuite.addTest(
    'API Produits - Recherche',
    'http://localhost:3000/api/products?limit=20&page=1',
    { method: 'GET' }
  );

  try {
    await perfSuite.setupDatabaseForTest();
    const results = await perfSuite.runWithMonitoring();
    const report = await perfSuite.generateReport();
    
    console.log('Tests de performance terminés avec succès!');
    console.log(`Rapport sauvegardé: ${report.timestamp}`);
    
    return report;
  } catch (error) {
    console.error('Erreur lors des tests de performance:', error);
    throw error;
  } finally {
    await perfSuite.cleanup();
  }
}

// Exécuter les tests si ce fichier est exécuté directement
if (require.main === module) {
  runPerformanceTests().catch(console.error);
}

module.exports = PerformanceTestSuite;
```

### 2. Tests de sécurité

#### Modèle de test de sécurité
```javascript
// security-tests/security-suite.js
const axios = require('axios');
const fs = require('fs').promises;
const path = require('path');

class SecurityTestSuite {
  constructor(baseURL, options = {}) {
    this.baseURL = baseURL;
    this.client = axios.create({
      baseURL,
      timeout: 10000,
      validateStatus: (status) => status < 500 // Ne pas traiter les erreurs 4xx comme des erreurs
    });
    this.results = [];
    this.options = {
      verbose: options.verbose || false,
      includeSlowTests: options.includeSlowTests || true,
      ...options
    };
  }

  async runAllTests() {
    const tests = [
      this.testAuthentication,
      this.testAuthorization,
      this.testInputValidation,
      this.testXSSProtection,
      this.testCSRFProtection,
      this.testSQLInjection,
      this.testRateLimiting,
      this.testSecurityHeaders,
      this.testInformationDisclosure,
      this.testSecureCookies
    ];

    const results = [];

    for (const test of tests) {
      try {
        const result = await test.call(this);
        results.push(result);
        if (this.options.verbose) {
          console.log(`✓ ${result.name}: ${result.status}`);
        }
      } catch (error) {
        results.push({
          name: test.name,
          status: 'FAILED',
          error: error.message,
          details: error.details || {}
        });
        if (this.options.verbose) {
          console.log(`✗ ${test.name}: FAILED - ${error.message}`);
        }
      }
    }

    this.results = results;
    return results;
  }

  async testAuthentication() {
    const testName = 'Authentication Security';
    
    // Test 1: Endpoint protégé sans authentification
    const protectedResponse = await this.client.get('/api/users/profile');
    if (protectedResponse.status !== 401 && protectedResponse.status !== 403) {
      throw new Error('Endpoint protégé accessible sans authentification', {
        details: { status: protectedResponse.status }
      });
    }

    // Test 2: Authentification avec identifiants invalides
    try {
      const authResponse = await this.client.post('/api/auth/login', {
        email: 'nonexistent@example.com',
        password: 'wrongpassword'
      });
      
      if (authResponse.status === 200) {
        throw new Error('Authentification réussie avec identifiants invalides');
      }
    } catch (error) {
      // C'est normal que cela échoue
    }

    // Test 3: Format du token JWT
    const loginResponse = await this.client.post('/api/auth/login', {
      email: 'test@example.com',
      password: 'password123'
    });

    if (loginResponse.data && loginResponse.data.token) {
      const tokenParts = loginResponse.data.token.split('.');
      if (tokenParts.length !== 3) {
        throw new Error('Format JWT invalide');
      }
    }

    return {
      name: testName,
      status: 'PASSED',
      details: { tokenValidation: true }
    };
  }

  async testAuthorization() {
    const testName = 'Authorization Security';
    
    // Se connecter en tant qu'utilisateur standard
    const loginResponse = await this.client.post('/api/auth/login', {
      email: 'user@example.com',
      password: 'password123'
    });

    const token = loginResponse.data.token;
    this.client.defaults.headers.common['Authorization'] = `Bearer ${token}`;

    // Essayer d'accéder à une ressource d'administrateur
    const adminResponse = await this.client.get('/api/admin/users');
    if (adminResponse.status !== 403) {
      throw new Error('Utilisateur standard a accédé à une ressource admin', {
        details: { status: adminResponse.status }
      });
    }

    return {
      name: testName,
      status: 'PASSED',
      details: { adminAccessDenied: true }
    };
  }

  async testInputValidation() {
    const testName = 'Input Validation Security';
    
    // Test d'injection SQL
    const sqlInjectionPayloads = [
      "' OR '1'='1",
      "'; DROP TABLE users; --",
      "' UNION SELECT password FROM users --",
      "admin'--",
      "%27%20OR%20%271%27%3D%271"
    ];

    for (const payload of sqlInjectionPayloads) {
      try {
        const response = await this.client.post('/api/users/search', {
          query: payload
        });

        // Si la requête réussit ou retourne des erreurs spécifiques à SQL, c'est un problème
        if (response.status === 500) {
          const errorBody = response.data;
          if (errorBody.message && 
              (errorBody.message.includes('SQL') || 
               errorBody.message.includes('syntax') ||
               errorBody.message.includes('database'))) {
            throw new Error(`Vulnérabilité potentielle à l'injection SQL détectée: ${payload}`, {
              details: { payload, response: errorBody }
            });
          }
        }
      } catch (error) {
        // Si c'est une erreur de connexion ou timeout, continuer
        if (error.code !== 'ECONNREFUSED' && error.code !== 'ECONNABORTED') {
          throw error;
        }
      }
    }

    return {
      name: testName,
      status: 'PASSED',
      details: { sqlInjectionTested: sqlInjectionPayloads.length }
    };
  }

  async testXSSProtection() {
    const testName = 'XSS Protection Security';
    
    // Test avec payload XSS
    const xssPayloads = [
      '<script>alert("XSS")</script>',
      'javascript:alert("XSS")',
      '<img src=x onerror=alert("XSS")>',
      '<svg onload=alert("XSS")>',
      '"><script>alert("XSS")</script>'
    ];

    for (const payload of xssPayloads) {
      try {
        const response = await this.client.post('/api/users', {
          name: payload,
          email: `test${Date.now()}@example.com`,
          bio: payload
        });

        // Vérifier que le payload n'est pas retourné tel quel
        if (response.data && 
            JSON.stringify(response.data).includes('<script>')) {
          throw new Error(`Vulnérabilité XSS détectée avec payload: ${payload}`, {
            details: { payload, response: response.data }
          });
        }
      } catch (error) {
        // Gérer les erreurs spécifiques aux tests XSS
        if (error.response?.status === 400) {
          // C'est probablement correct - le serveur a rejeté le payload
          continue;
        }
        throw error;
      }
    }

    return {
      name: testName,
      status: 'PASSED',
      details: { xssPayloadsTested: xssPayloads.length }
    };
  }

  async testSecurityHeaders() {
    const testName = 'Security Headers';
    
    const response = await this.client.get('/');
    const headers = response.headers;

    const requiredHeaders = [
      { name: 'X-Content-Type-Options', expected: 'nosniff' },
      { name: 'X-Frame-Options', expected: 'DENY' },
      { name: 'X-XSS-Protection', expected: '1; mode=block' },
      { name: 'Strict-Transport-Security', present: true },
      { name: 'Content-Security-Policy', present: true }
    ];

    const missingHeaders = [];
    const incorrectHeaders = [];

    for (const header of requiredHeaders) {
      const actualValue = headers[header.name.toLowerCase()];
      
      if (!actualValue && !header.present) {
        missingHeaders.push(header.name);
      } else if (header.expected && actualValue !== header.expected) {
        incorrectHeaders.push({
          name: header.name,
          expected: header.expected,
          actual: actualValue
        });
      } else if (header.present && !actualValue) {
        missingHeaders.push(header.name);
      }
    }

    if (missingHeaders.length > 0 || incorrectHeaders.length > 0) {
      throw new Error('En-têtes de sécurité manquants ou incorrects', {
        details: { missingHeaders, incorrectHeaders }
      });
    }

    return {
      name: testName,
      status: 'PASSED',
      details: { 
        headersChecked: requiredHeaders.length,
        missingHeaders: missingHeaders.length,
        incorrectHeaders: incorrectHeaders.length
      }
    };
  }

  async testRateLimiting() {
    const testName = 'Rate Limiting Security';
    
    const requests = [];
    for (let i = 0; i < 100; i++) {
      requests.push(
        this.client.get('/api/public/health')
          .catch(error => error.response || { status: 500 })
      );
    }

    const responses = await Promise.all(requests);
    const tooManyRequests = responses.filter(r => r.status === 429);

    if (tooManyRequests.length === 0) {
      throw new Error('Limitation de débit non détectée - trop de requêtes acceptées', {
        details: { 
          totalRequests: responses.length,
          tooManyRequests: tooManyRequests.length,
          rateLimitActive: false
        }
      });
    }

    return {
      name: testName,
      status: 'PASSED',
      details: {
        totalRequests: responses.length,
        rateLimitedRequests: tooManyRequests.length,
        rateLimitActive: true
      }
    };
  }

  async generateSecurityReport() {
    const report = {
      timestamp: new Date().toISOString(),
      target: this.baseURL,
      environment: process.env.NODE_ENV || 'development',
      tests: this.results,
      summary: {
        total: this.results.length,
        passed: this.results.filter(r => r.status === 'PASSED').length,
        failed: this.results.filter(r => r.status === 'FAILED').length,
        vulnerabilities: this.results.filter(r => r.status === 'FAILED').map(r => r.name)
      }
    };

    // Sauvegarder le rapport
    const reportPath = path.join('security-reports', `security-report-${Date.now()}.json`);
    await fs.mkdir(path.dirname(reportPath), { recursive: true });
    await fs.writeFile(reportPath, JSON.stringify(report, null, 2));

    return report;
  }

  async runPenetrationTesting() {
    // Tests avancés de pénétration
    const penetrationTests = [
      this.testBruteForce,
      this.testSessionFixation,
      this.testMassAssignment,
      this.testInsecureDirectObjectReference
    ];

    const penTestResults = [];

    for (const test of penetrationTests) {
      try {
        const result = await test.call(this);
        penTestResults.push(result);
      } catch (error) {
        penTestResults.push({
          name: test.name,
          status: 'VULNERABILITY_FOUND',
          error: error.message,
          details: error.details || {}
        });
      }
    }

    return penTestResults;
  }

  async testBruteForce() {
    const testName = 'Brute Force Protection';
    
    // Tenter plusieurs connexions échouées
    const requests = [];
    for (let i = 0; i < 20; i++) {
      requests.push(
        this.client.post('/api/auth/login', {
          email: 'victim@example.com',
          password: `wrongpassword${i}`
        })
      );
    }

    const responses = await Promise.allSettled(requests);
    const successResponses = responses.filter(r => r.status === 'fulfilled' && r.value.status === 200);

    // Normalement, il ne devrait y avoir aucune connexion réussie
    if (successResponses.length > 0) {
      throw new Error('Protection contre le brute force insuffisante', {
        details: { 
          totalAttempts: responses.length,
          successfulLogins: successResponses.length
        }
      });
    }

    return {
      name: testName,
      status: 'PASSED',
      details: { bruteForceAttempts: 20, blockedLogins: responses.length }
    };
  }

  async testMassAssignment() {
    const testName = 'Mass Assignment Protection';
    
    // Tenter de créer un utilisateur avec des propriétés sensibles
    const response = await this.client.post('/api/users', {
      name: 'Attacker',
      email: `attacker${Date.now()}@example.com`,
      password: 'password123',
      role: 'admin',  // Propriété sensible
      isVerified: true,  // Propriété sensible
      createdAt: '2020-01-01'  // Propriété sensible
    });

    // Vérifier que les propriétés sensibles n'ont pas été assignées
    if (response.data && (response.data.role === 'admin' || response.data.isVerified === true)) {
      throw new Error('Protection contre l\'assignment massif insuffisante', {
        details: { 
          assignedProperties: Object.keys(response.data),
          sensitivePropertiesAssigned: ['role', 'isVerified'].filter(prop => response.data[prop])
        }
      });
    }

    return {
      name: testName,
      status: 'PASSED',
      details: { massAssignmentBlocked: true }
    };
  }
}

// Utilisation
async function runSecurityTests() {
  const securitySuite = new SecurityTestSuite('http://localhost:3000', {
    verbose: true
  });

  try {
    console.log('Démarrage des tests de sécurité...');
    
    // Tests de sécurité de base
    const basicResults = await securitySuite.runAllTests();
    
    // Tests de pénétration
    const penetrationResults = await securitySuite.runPenetrationTesting();
    
    // Générer le rapport
    const report = await securitySuite.generateSecurityReport();
    
    console.log(`Tests de sécurité terminés!`);
    console.log(`Rapport: ${report.summary.passed}/${report.summary.total} tests passés`);
    console.log(`Rapport sauvegardé: ${report.timestamp}`);
    
    if (report.summary.failed > 0) {
      console.log('Vulnérabilités détectées:', report.summary.vulnerabilities);
    }
    
    return { basicResults, penetrationResults, report };
  } catch (error) {
    console.error('Erreur lors des tests de sécurité:', error);
    throw error;
  }
}

// Exécuter les tests si ce fichier est exécuté directement
if (require.main === module) {
  runSecurityTests().catch(console.error);
}

module.exports = SecurityTestSuite;
```

## Modèles de test de qualité du code

### 1. Tests de dette technique

#### Analyse de dette technique
```javascript
// quality-tests/technical-debt-analyzer.js
const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');

class TechnicalDebtAnalyzer {
  constructor(options = {}) {
    this.options = {
      maxComplexity: options.maxComplexity || 10,
      maxLinesPerFunction: options.maxLinesPerFunction || 50,
      maxParamsPerFunction: options.maxParamsPerFunction || 5,
      maxDepthPerFunction: options.maxDepthPerFunction || 4,
      ...options
    };
    this.metrics = {
      complexity: 0,
      longFunctions: 0,
      largeClasses: 0,
      duplicatedCode: 0,
      testCoverage: 0
    };
  }

  async analyzeProject(projectPath) {
    const results = {
      summary: {},
      files: [],
      debtScore: 0,
      recommendations: []
    };

    // Analyser tous les fichiers JavaScript/TypeScript
    const files = await this.findFiles(projectPath, ['.js', '.ts', '.jsx', '.tsx']);
    
    for (const filePath of files) {
      const fileAnalysis = await this.analyzeFile(filePath);
      results.files.push(fileAnalysis);
    }

    // Calculer les métriques globales
    results.summary = this.calculateProjectMetrics(results.files);
    results.debtScore = this.calculateDebtScore(results.summary);
    results.recommendations = this.generateRecommendations(results.summary);

    return results;
  }

  async findFiles(dir, extensions) {
    const files = [];
    const items = await fs.readdir(dir, { withFileTypes: true });

    for (const item of items) {
      const fullPath = path.join(dir, item.name);
      
      if (item.isDirectory()) {
        const subFiles = await this.findFiles(fullPath, extensions);
        files.push(...subFiles);
      } else if (extensions.includes(path.extname(item.name))) {
        files.push(fullPath);
      }
    }

    return files;
  }

  async analyzeFile(filePath) {
    const content = await fs.readFile(filePath, 'utf8');
    const lines = content.split('\n');
    
    const analysis = {
      filePath,
      metrics: {
        linesOfCode: lines.length,
        functions: 0,
        complexity: 0,
        longFunctions: [],
        duplicatedBlocks: [],
        testCoverage: 0
      },
      issues: []
    };

    // Analyser la complexité cyclomatique
    analysis.metrics.complexity = this.calculateComplexity(content);
    
    // Analyser les fonctions longues
    const longFunctions = this.findLongFunctions(content, lines);
    analysis.metrics.longFunctions = longFunctions;
    analysis.metrics.functions = longFunctions.length;
    
    // Analyser les duplications de code
    analysis.metrics.duplicatedBlocks = await this.findCodeDuplicates(content, filePath);
    
    // Identifier les problèmes
    if (analysis.metrics.complexity > this.options.maxComplexity) {
      analysis.issues.push({
        type: 'HIGH_COMPLEXITY',
        message: `Complexité trop élevée: ${analysis.metrics.complexity}`,
        severity: 'HIGH'
      });
    }

    for (const func of longFunctions) {
      if (func.lines > this.options.maxLinesPerFunction) {
        analysis.issues.push({
          type: 'LONG_FUNCTION',
          message: `Fonction trop longue: ${func.name} (${func.lines} lignes)`,
          severity: 'MEDIUM',
          line: func.line
        });
      }
    }

    if (analysis.metrics.duplicatedBlocks.length > 0) {
      analysis.issues.push({
        type: 'DUPLICATED_CODE',
        message: `Code dupliqué détecté: ${analysis.metrics.duplicatedBlocks.length} blocs`,
        severity: 'MEDIUM'
      });
    }

    return analysis;
  }

  calculateComplexity(code) {
    // Calcul de la complexité cyclomatique
    let complexity = 1; // Commencer à 1 pour le chemin de base
    
    // Compter les points de décision
    const decisionPoints = [
      /if\s*\(/g,
      /for\s*\(/g,
      /while\s*\(/g,
      /catch\s*\(/g,
      /\|\|/g,
      /&&/g,
      /\?/g,
      /case\s+/g
    ];

    for (const regex of decisionPoints) {
      const matches = code.match(regex);
      if (matches) {
        complexity += matches.length;
      }
    }

    return complexity;
  }

  findLongFunctions(code, lines) {
    const functions = [];
    const functionRegex = /(function\s+\w+|const\s+\w+\s*=|var\s+\w+\s*=|let\s+\w+\s*=|(\w+)\s*:\s*function|\w+\s*=\s*\(|class\s+\w+)/g;
    
    let match;
    while ((match = functionRegex.exec(code)) !== null) {
      const functionName = match[1] || match[2] || 'anonymous';
      const startIdx = match.index;
      
      // Trouver la fin de la fonction (compter les accolades)
      let braceCount = 0;
      let inString = false;
      let stringChar = '';
      let i = startIdx;
      
      while (i < code.length) {
        const char = code[i];
        
        // Gérer les chaînes de caractères
        if ((char === '"' || char === "'" || char === '`') && !inString) {
          inString = true;
          stringChar = char;
        } else if (char === stringChar && code[i - 1] !== '\\') {
          inString = false;
        }
        
        if (!inString) {
          if (char === '{') {
            braceCount++;
          } else if (char === '}') {
            braceCount--;
            if (braceCount === 0) {
              break;
            }
          }
        }
        
        i++;
      }
      
      const functionCode = code.substring(startIdx, i + 1);
      const functionLines = functionCode.split('\n').length;
      
      if (functionLines > this.options.maxLinesPerFunction) {
        const startLine = code.substring(0, startIdx).split('\n').length;
        functions.push({
          name: functionName,
          lines: functionLines,
          line: startLine,
          complexity: this.calculateComplexity(functionCode)
        });
      }
    }
    
    return functions;
  }

  async findCodeDuplicates(content, filePath) {
    const blocks = [];
    const minLength = 10; // Minimum de 10 lignes pour considérer comme duplication
    const lines = content.split('\n');
    
    // Simplifier le code pour la comparaison (enlever les espaces, commentaires)
    const simplifiedLines = lines.map(line => 
      line.trim()
        .replace(/\/\/.*$/, '') // Enlever les commentaires de fin de ligne
        .replace(/\/\*[\s\S]*?\*\//g, '') // Enlever les commentaires multilignes
        .replace(/\s+/g, ' ') // Normaliser les espaces
    ).filter(line => line.length > 0); // Enlever les lignes vides
    
    // Comparer les blocs de code
    for (let i = 0; i < simplifiedLines.length; i++) {
      for (let j = i + minLength; j < Math.min(i + 50, simplifiedLines.length); j++) {
        const block = simplifiedLines.slice(i, j).join(' ');
        
        // Chercher des duplications
        for (let k = j + 1; k < simplifiedLines.length - (j - i); k++) {
          const candidateBlock = simplifiedLines.slice(k, k + (j - i)).join(' ');
          
          if (block === candidateBlock && block.length > 50) { // 50 caractères minimum
            blocks.push({
              content: lines.slice(i, j).join('\n'),
              startLine: i + 1,
              endLine: j,
              duplicateAt: k + 1,
              similarity: 100
            });
          }
        }
      }
    }
    
    return blocks;
  }

  calculateProjectMetrics(fileAnalyses) {
    const metrics = {
      totalFiles: fileAnalyses.length,
      totalLOC: 0,
      totalComplexity: 0,
      totalLongFunctions: 0,
      totalDuplicatedBlocks: 0,
      highSeverityIssues: 0,
      mediumSeverityIssues: 0,
      lowSeverityIssues: 0
    };

    for (const fileAnalysis of fileAnalyses) {
      metrics.totalLOC += fileAnalysis.metrics.linesOfCode;
      metrics.totalComplexity += fileAnalysis.metrics.complexity;
      metrics.totalLongFunctions += fileAnalysis.metrics.longFunctions.length;
      metrics.totalDuplicatedBlocks += fileAnalysis.metrics.duplicatedBlocks.length;
      
      for (const issue of fileAnalysis.issues) {
        switch (issue.severity) {
          case 'HIGH':
            metrics.highSeverityIssues++;
            break;
          case 'MEDIUM':
            metrics.mediumSeverityIssues++;
            break;
          case 'LOW':
            metrics.lowSeverityIssues++;
            break;
        }
      }
    }

    metrics.averageComplexity = metrics.totalComplexity / metrics.totalFiles;
    metrics.averageLOC = metrics.totalLOC / metrics.totalFiles;
    metrics.issueDensity = (metrics.highSeverityIssues + metrics.mediumSeverityIssues) / metrics.totalLOC;

    return metrics;
  }

  calculateDebtScore(metrics) {
    // Calculer un score de dette technique basé sur les métriques
    let score = 0;
    
    // Pénalités pour les indicateurs de dette technique
    score += metrics.highSeverityIssues * 10;
    score += metrics.mediumSeverityIssues * 5;
    score += metrics.totalDuplicatedBlocks * 3;
    score += metrics.totalLongFunctions * 2;
    
    // Bonus pour les bonnes pratiques
    if (metrics.averageComplexity < this.options.maxComplexity * 0.5) {
      score -= 10;
    }
    
    // Normaliser le score (0-100, plus bas est meilleur)
    const maxPossibleScore = 100;
    return Math.max(0, Math.min(100, maxPossibleScore - score));
  }

  generateRecommendations(metrics) {
    const recommendations = [];

    if (metrics.averageComplexity > this.options.maxComplexity) {
      recommendations.push({
        priority: 'HIGH',
        title: 'Réduire la complexité cyclomatique',
        description: `La complexité moyenne (${metrics.averageComplexity.toFixed(2)}) dépasse la limite recommandée (${this.options.maxComplexity})`,
        actions: [
          'Découper les fonctions complexes en fonctions plus petites',
          'Utiliser des modèles de conception pour réduire la complexité',
          'Appliquer le principe de responsabilité unique'
        ]
      });
    }

    if (metrics.totalLongFunctions > 0) {
      recommendations.push({
        priority: 'MEDIUM',
        title: 'Réduire la taille des fonctions',
        description: `${metrics.totalLongFunctions} fonctions dépassent la limite de ${this.options.maxLinesPerFunction} lignes`,
        actions: [
          'Découper les fonctions longues en sous-fonctions',
          'Extraire la logique métier dans des services dédiés',
          'Utiliser des composants ou modules plus petits'
        ]
      });
    }

    if (metrics.totalDuplicatedBlocks > 0) {
      recommendations.push({
        priority: 'MEDIUM',
        title: 'Éliminer le code dupliqué',
        description: `${metrics.totalDuplicatedBlocks} blocs de code dupliqués détectés`,
        actions: [
          'Créer des fonctions utilitaires partagées',
          'Extraire le code commun dans des modules dédiés',
          'Utiliser l\'héritage ou la composition pour le code partagé'
        ]
      });
    }

    if (metrics.issueDensity > 0.01) { // Plus de 1% de densité de bugs
      recommendations.push({
        priority: 'HIGH',
        title: 'Améliorer la qualité du code',
        description: `Densité d'issues élevée (${(metrics.issueDensity * 100).toFixed(2)}%)`,
        actions: [
          'Mettre en place des revues de code obligatoires',
          'Automatiser les tests de qualité',
          'Former l\'équipe aux bonnes pratiques de développement'
        ]
      });
    }

    return recommendations;
  }

  async generateDetailedReport(results) {
    const report = `
# Rapport de Dette Technique

## Résumé
- **Fichiers analysés**: ${results.summary.totalFiles}
- **Lignes de code totales**: ${results.summary.totalLOC.toLocaleString()}
- **Score de dette technique**: ${results.debtScore}/100
- **Fonctions longues**: ${results.summary.totalLongFunctions}
- **Blocs de code dupliqués**: ${results.summary.totalDuplicatedBlocks}

## Métriques détaillées
- **Complexité moyenne**: ${results.summary.averageComplexity.toFixed(2)}
- **Densité d'issues**: ${(results.summary.issueDensity * 100).toFixed(2)}%
- **Issues critiques**: ${results.summary.highSeverityIssues}
- **Issues moyennes**: ${results.summary.mediumSeverityIssues}
- **Issues faibles**: ${results.summary.lowSeverityIssues}

## Recommandations prioritaires
${results.recommendations.map(rec => `
### ${rec.priority}: ${rec.title}
**Description**: ${rec.description}

**Actions recommandées**:
${rec.actions.map(action => `- ${action}`).join('\n')}

`).join('\n')}

## Détail par fichier
${results.files.map(file => `
### ${file.filePath}
- Lignes: ${file.metrics.linesOfCode}
- Complexité: ${file.metrics.complexity}
- Fonctions: ${file.metrics.functions}
- Fonctions longues: ${file.metrics.longFunctions.length}
- Duplications: ${file.metrics.duplicatedBlocks.length}
- Issues: ${file.issues.length}
`).join('\n')}

## Conclusion
${this.generateConclusion(results)}
    `;

    return report;
  }

  generateConclusion(results) {
    const score = results.debtScore;
    
    if (score >= 80) {
      return "La dette technique est bien maîtrisée. Continuez à appliquer les bonnes pratiques de développement.";
    } else if (score >= 60) {
      return "La dette technique est modérée. Certaines améliorations sont nécessaires pour maintenir la qualité à long terme.";
    } else if (score >= 40) {
      return "La dette technique est significative. Des efforts importants sont nécessaires pour améliorer la qualité du code.";
    } else {
      return "La dette technique est critique. Une refonte partielle du code est fortement recommandée.";
    }
  }

  async runWithTools() {
    // Exécuter des outils d'analyse de code existants
    const toolsResults = {};
    
    try {
      // Exécuter ESLint
      const eslintResult = await this.runESLint();
      toolsResults.eslint = eslintResult;
    } catch (error) {
      console.warn('ESLint non disponible ou erreur:', error.message);
    }
    
    try {
      // Exécuter SonarQube scanner si disponible
      const sonarResult = await this.runSonarScanner();
      toolsResults.sonarqube = sonarResult;
    } catch (error) {
      console.warn('SonarQube scanner non disponible ou erreur:', error.message);
    }
    
    return toolsResults;
  }

  runESLint() {
    return new Promise((resolve, reject) => {
      const child = spawn('npx', ['eslint', '.', '--format', 'json'], {
        cwd: process.cwd(),
        shell: true
      });

      let output = '';
      let errorOutput = '';

      child.stdout.on('data', (data) => {
        output += data.toString();
      });

      child.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });

      child.on('close', (code) => {
        if (code === 0 || code === 1) { // 1 signifie qu'il y a des erreurs mais pas d'erreur d'exécution
          try {
            const results = JSON.parse(output);
            resolve(results);
          } catch (parseError) {
            reject(new Error(`Impossible de parser la sortie ESLint: ${parseError.message}`));
          }
        } else {
          reject(new Error(`ESLint exited with code ${code}: ${errorOutput}`));
        }
      });
    });
  }
}

// Utilisation
async function analyzeProjectTechnicalDebt() {
  const analyzer = new TechnicalDebtAnalyzer({
    maxComplexity: 8,
    maxLinesPerFunction: 30
  });

  try {
    console.log('Analyse de la dette technique en cours...');
    
    const results = await analyzer.analyzeProject('./src');
    const report = await analyzer.generateDetailedReport(results);
    
    // Sauvegarder le rapport
    await fs.writeFile('technical-debt-report.md', report);
    
    console.log(`Analyse terminée! Score: ${results.debtScore}/100`);
    console.log(`Rapport sauvegardé dans: technical-debt-report.md`);
    
    return { results, report };
  } catch (error) {
    console.error('Erreur lors de l\'analyse de la dette technique:', error);
    throw error;
  }
}

// Exécuter l'analyse si ce fichier est exécuté directement
if (require.main === module) {
  analyzeProjectTechnicalDebt().catch(console.error);
}

module.exports = TechnicalDebtAnalyzer;
```

### 2. Tests de couverture de code

#### Modèle de test de couverture
```javascript
// coverage-tests/coverage-analyzer.js
const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

class CoverageAnalyzer {
  constructor(options = {}) {
    this.options = {
      minCoverage: options.minCoverage || 80,
      minBranchCoverage: options.minBranchCoverage || 70,
      minFunctionCoverage: options.minFunctionCoverage || 85,
      minStatementCoverage: options.minStatementCoverage || 80,
      ...options
    };
    this.coverageData = null;
  }

  async runCoverageTests() {
    try {
      // Exécuter les tests avec couverture
      const { stdout, stderr } = await execAsync('npm run test:coverage');
      
      // Lire le rapport de couverture généré
      const coveragePath = path.join(process.cwd(), 'coverage', 'coverage-final.json');
      const coverageRaw = await fs.readFile(coveragePath, 'utf8');
      this.coverageData = JSON.parse(coverageRaw);
      
      return this.analyzeCoverage();
    } catch (error) {
      console.error('Erreur lors de l\'exécution des tests de couverture:', error);
      throw error;
    }
  }

  analyzeCoverage() {
    if (!this.coverageData) {
      throw new Error('Aucune donnée de couverture disponible');
    }

    const analysis = {
      summary: this.calculateOverallCoverage(),
      files: this.analyzeFileCoverage(),
      recommendations: this.generateCoverageRecommendations(),
      status: 'PASS'
    };

    // Vérifier si les seuils sont atteints
    if (analysis.summary.branches.pct < this.options.minBranchCoverage ||
        analysis.summary.functions.pct < this.options.minFunctionCoverage ||
        analysis.summary.statements.pct < this.options.minStatementCoverage) {
      analysis.status = 'FAIL';
    }

    return analysis;
  }

  calculateOverallCoverage() {
    let totalStatements = 0;
    let coveredStatements = 0;
    let totalBranches = 0;
    let coveredBranches = 0;
    let totalFunctions = 0;
    let coveredFunctions = 0;
    let totalLines = 0;
    let coveredLines = 0;

    for (const [filePath, fileData] of Object.entries(this.coverageData)) {
      if (this.shouldIncludeFile(filePath)) {
        const { s, f, b } = fileData;
        
        // Statements
        Object.values(s).forEach(count => {
          totalStatements++;
          if (count > 0) coveredStatements++;
        });

        // Branches
        Object.values(b).forEach(branches => {
          branches.forEach(count => {
            totalBranches++;
            if (count > 0) coveredBranches++;
          });
        });

        // Functions
        Object.values(f).forEach(count => {
          totalFunctions++;
          if (count > 0) coveredFunctions++;
        });

        // Lines
        const lineCoverage = fileData.l;
        Object.values(lineCoverage).forEach(count => {
          totalLines++;
          if (count > 0) coveredLines++;
        });
      }
    }

    return {
      statements: {
        total: totalStatements,
        covered: coveredStatements,
        pct: totalStatements > 0 ? (coveredStatements / totalStatements) * 100 : 100
      },
      branches: {
        total: totalBranches,
        covered: coveredBranches,
        pct: totalBranches > 0 ? (coveredBranches / totalBranches) * 100 : 100
      },
      functions: {
        total: totalFunctions,
        covered: coveredFunctions,
        pct: totalFunctions > 0 ? (coveredFunctions / totalFunctions) * 100 : 100
      },
      lines: {
        total: totalLines,
        covered: coveredLines,
        pct: totalLines > 0 ? (coveredLines / totalLines) * 100 : 100
      }
    };
  }

  analyzeFileCoverage() {
    const filesAnalysis = [];

    for (const [filePath, fileData] of Object.entries(this.coverageData)) {
      if (this.shouldIncludeFile(filePath)) {
        const fileAnalysis = this.analyzeSingleFile(filePath, fileData);
        filesAnalysis.push(fileAnalysis);
      }
    }

    return filesAnalysis;
  }

  analyzeSingleFile(filePath, fileData) {
    const { s, f, b, l } = fileData;
    
    // Calculer les métriques pour ce fichier
    const statements = {
      total: Object.keys(s).length,
      covered: Object.values(s).filter(count => count > 0).length,
      pct: Object.keys(s).length > 0 ? (Object.values(s).filter(count => count > 0).length / Object.keys(s).length) * 100 : 100
    };

    const functions = {
      total: Object.keys(f).length,
      covered: Object.values(f).filter(count => count > 0).length,
      pct: Object.keys(f).length > 0 ? (Object.values(f).filter(count => count > 0).length / Object.keys(f).length) * 100 : 100
    };

    const branches = {
      total: Object.values(b).reduce((sum, branches) => sum + branches.length, 0),
      covered: Object.values(b).reduce((sum, branches) => 
        sum + branches.filter(count => count > 0).length, 0),
      pct: Object.values(b).length > 0 ? 
        (Object.values(b).reduce((sum, branches) => 
          sum + branches.filter(count => count > 0).length, 0) / 
         Object.values(b).reduce((sum, branches) => sum + branches.length, 0)) * 100 : 100
    };

    const lines = {
      total: Object.keys(l).length,
      covered: Object.values(l).filter(count => count > 0).length,
      pct: Object.keys(l).length > 0 ? (Object.values(l).filter(count => count > 0).length / Object.keys(l).length) * 100 : 100
    };

    // Identifier les lignes non couvertes
    const uncoveredLines = Object.entries(l)
      .filter(([line, count]) => count === 0)
      .map(([line]) => parseInt(line));

    // Identifier les fonctions non couvertes
    const uncoveredFunctions = Object.entries(f)
      .filter(([funcId, count]) => count === 0)
      .map(([funcId]) => this.getFunctionName(fileData.fnMap[funcId]));

    return {
      filePath,
      metrics: { statements, functions, branches, lines },
      uncoveredLines,
      uncoveredFunctions,
      needsAttention: lines.pct < 80 || functions.pct < 80 || branches.pct < 70
    };
  }

  getFunctionName(fnMap) {
    return fnMap ? fnMap.name : 'unknown';
  }

  shouldIncludeFile(filePath) {
    // Exclure les fichiers de test, node_modules, etc.
    return !filePath.includes('node_modules/') &&
           !filePath.includes('__tests__/') &&
           !filePath.includes('test/') &&
           !filePath.includes('spec/') &&
           (filePath.endsWith('.js') || 
            filePath.endsWith('.ts') || 
            filePath.endsWith('.jsx') || 
            filePath.endsWith('.tsx'));
  }

  generateCoverageRecommendations() {
    const recommendations = [];
    const summary = this.calculateOverallCoverage();

    if (summary.statements.pct < this.options.minStatementCoverage) {
      recommendations.push({
        priority: 'HIGH',
        category: 'statements',
        message: `La couverture des instructions est faible (${summary.statements.pct.toFixed(2)}%)`,
        suggestions: [
          'Ajouter des tests pour les chemins d\'exécution non couverts',
          'Vérifier les conditions complexes dans les if/else',
          'S\'assurer que tous les cas dans les switch sont testés'
        ]
      });
    }

    if (summary.branches.pct < this.options.minBranchCoverage) {
      recommendations.push({
        priority: 'HIGH',
        category: 'branches',
        message: `La couverture des branches est faible (${summary.branches.pct.toFixed(2)}%)`,
        suggestions: [
          'Ajouter des tests pour tous les chemins de branchement',
          'Tester les conditions booléennes avec toutes les combinaisons possibles',
          'S\'assurer que les opérateurs logiques sont complètement testés'
        ]
      });
    }

    if (summary.functions.pct < this.options.minFunctionCoverage) {
      recommendations.push({
        priority: 'MEDIUM',
        category: 'functions',
        message: `La couverture des fonctions est faible (${summary.functions.pct.toFixed(2)}%)`,
        suggestions: [
          'Ajouter des tests unitaires pour les fonctions non testées',
          'S\'assurer que toutes les fonctions publiques sont testées',
          'Vérifier que les cas d\'erreur sont testés'
        ]
      });
    }

    // Analyser les fichiers individuels pour des recommandations spécifiques
    const lowCoverageFiles = this.analyzeFileCoverage()
      .filter(file => file.metrics.lines.pct < 50);

    if (lowCoverageFiles.length > 0) {
      recommendations.push({
        priority: 'HIGH',
        category: 'files',
        message: `${lowCoverageFiles.length} fichiers ont une couverture inférieure à 50%`,
        suggestions: [
          `Examiner les fichiers suivants : ${lowCoverageFiles.slice(0, 5).map(f => f.filePath).join(', ')}`,
          'Créer des tests spécifiques pour ces fichiers critiques',
          'Considérer la simplification du code si les tests sont difficiles à écrire'
        ]
      });
    }

    return recommendations;
  }

  async generateCoverageReport() {
    const analysis = this.analyzeCoverage();
    
    const report = `
# Rapport de Couverture de Code

## Résumé Général
- **Instructions**: ${analysis.summary.statements.pct.toFixed(2)}% (${analysis.summary.statements.covered}/${analysis.summary.statements.total})
- **Branches**: ${analysis.summary.branches.pct.toFixed(2)}% (${analysis.summary.branches.covered}/${analysis.summary.branches.total})
- **Fonctions**: ${analysis.summary.functions.pct.toFixed(2)}% (${analysis.summary.functions.covered}/${analysis.summary.functions.total})
- **Lignes**: ${analysis.summary.lines.pct.toFixed(2)}% (${analysis.summary.lines.covered}/${analysis.summary.lines.total})

## Statut
**${analysis.status === 'PASS' ? '✅ SATISFAISANT' : '❌ INSUFFISANT'}**

## Fichiers à haute priorité

${analysis.files
  .filter(file => file.needsAttention)
  .sort((a, b) => a.metrics.lines.pct - b.metrics.lines.pct)
  .slice(0, 10)
  .map(file => `
### ${path.basename(file.filePath)}
- **Chemin**: \`${file.filePath}\`
- **Couverture lignes**: ${file.metrics.lines.pct.toFixed(2)}%
- **Couverture fonctions**: ${file.metrics.functions.pct.toFixed(2)}%
- **Couverture branches**: ${file.metrics.branches.pct.toFixed(2)}%
- **Lignes non couvertes**: ${file.uncoveredLines.length > 0 ? file.uncoveredLines.join(', ') : 'Aucune'}
`).join('\n')}

## Recommandations
${analysis.recommendations.map(rec => `
### ${rec.priority}: ${rec.message}
${rec.suggestions.map(sug => `- ${sug}`).join('\n')}
`).join('\n')}

## Conclusion
${this.generateCoverageConclusion(analysis)}
    `;

    return report;
  }

  generateCoverageConclusion(analysis) {
    const avgCoverage = (analysis.summary.statements.pct + 
                        analysis.summary.branches.pct + 
                        analysis.summary.functions.pct + 
                        analysis.summary.lines.pct) / 4;

    if (avgCoverage >= 90) {
      return "Excellent! La couverture de code est exceptionnelle. Continuez à maintenir ce niveau élevé de test.";
    } else if (avgCoverage >= 80) {
      return "Bonne couverture de code. La majorité du code est testée, mais quelques améliorations peuvent encore être apportées.";
    } else if (avgCoverage >= 70) {
      return "Couverture de code modérée. Des efforts sont nécessaires pour augmenter la couverture, particulièrement pour les branches et les cas limites.";
    } else {
      return "Couverture de code insuffisante. Il est fortement recommandé d'augmenter la couverture de test avant de continuer le développement.";
    }
  }

  async setCoverageThresholds(thresholds) {
    // Créer ou mettre à jour le fichier de configuration de couverture
    const coverageConfig = {
      ...this.options,
      ...thresholds
    };

    // Pour Jest
    const jestConfigPath = path.join(process.cwd(), 'jest.config.js');
    if (await this.fileExists(jestConfigPath)) {
      await this.updateJestCoverageConfig(jestConfigPath, coverageConfig);
    }

    // Pour Istanbul/nyc
    const nycConfigPath = path.join(process.cwd(), '.nycrc');
    if (await this.fileExists(nycConfigPath)) {
      await this.updateNycCoverageConfig(nycConfigPath, coverageConfig);
    }

    this.options = coverageConfig;
  }

  async fileExists(filePath) {
    try {
      await fs.access(filePath);
      return true;
    } catch {
      return false;
    }
  }

  async updateJestCoverageConfig(configPath, thresholds) {
    let configContent = await fs.readFile(configPath, 'utf8');
    
    // Mettre à jour la configuration de couverture
    const newConfig = `
    ${configContent.replace(
      /"collectCoverageFrom": \[([^\]]*)\]/,
      `"collectCoverageFrom": ["src/**/*.{js,ts,jsx,tsx}", "!src/**/*.d.ts"]`
    ).replace(
      /"coverageThreshold": {([^}]*)}/,
      `"coverageThreshold": {
        "global": {
          "branches": ${thresholds.minBranchCoverage},
          "functions": ${thresholds.minFunctionCoverage},
          "lines": ${thresholds.minStatementCoverage},
          "statements": ${thresholds.minStatementCoverage}
        }
      }`
    )}`;

    await fs.writeFile(configPath, newConfig);
  }

  async updateNycCoverageConfig(configPath, thresholds) {
    const config = {
      branches: thresholds.minBranchCoverage,
      functions: thresholds.minFunctionCoverage,
      lines: thresholds.minStatementCoverage,
      statements: thresholds.minStatementCoverage,
      exclude: [
        "**/node_modules/**",
        "**/__tests__/**",
        "**/test/**",
        "**/spec/**",
        "**/*.test.*",
        "**/*.spec.*",
        "**/coverage/**"
      ]
    };

    await fs.writeFile(configPath, JSON.stringify(config, null, 2));
  }

  async createCoverageBadge() {
    if (!this.coverageData) {
      await this.runCoverageTests();
    }

    const summary = this.calculateOverallCoverage();
    const percentage = Math.round(summary.statements.pct);
    
    // Générer un badge de couverture de code
    const badgeUrl = `https://img.shields.io/badge/coverage-${percentage}%25-${percentage >= 80 ? 'success' : percentage >= 60 ? 'orange' : 'red'}.svg`;
    
    return {
      percentage,
      badgeUrl,
      status: percentage >= 80 ? 'excellent' : percentage >= 60 ? 'good' : 'needs_improvement'
    };
  }
}

// Utilisation
async function runCoverageAnalysis() {
  const analyzer = new CoverageAnalyzer({
    minCoverage: 85,
    minBranchCoverage: 75,
    minFunctionCoverage: 85,
    minStatementCoverage: 85
  });

  try {
    console.log('Exécution des tests avec couverture...');
    
    const analysis = await analyzer.analyzeCoverage();
    const report = await analyzer.generateCoverageReport();
    
    // Sauvegarder le rapport
    await fs.writeFile('coverage-report.md', report);
    
    // Créer un badge de couverture
    const badge = await analyzer.createCoverageBadge();
    console.log(`Badge de couverture: ${badge.badgeUrl}`);
    
    console.log(`Analyse de couverture terminée!`);
    console.log(`Statut: ${analysis.status}`);
    console.log(`Couverture moyenne: ${(analysis.summary.statements.pct + analysis.summary.branches.pct + analysis.summary.functions.pct + analysis.summary.lines.pct) / 4}%`);
    
    return { analysis, report, badge };
  } catch (error) {
    console.error('Erreur lors de l\'analyse de la couverture:', error);
    throw error;
  }
}

// Exécuter l'analyse si ce fichier est exécuté directement
if (require.main === module) {
  runCoverageAnalysis().catch(console.error);
}

module.exports = CoverageAnalyzer;
```

Ces modèles de test fournissent des approches complètes pour tester les applications modernes, couvrant les tests unitaires, d'intégration, E2E, de performance, de sécurité et de qualité du code. Ils permettent de s'assurer que les applications sont non seulement fonctionnelles mais aussi sécurisées, performantes et maintenables.