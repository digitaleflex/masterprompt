# Modèles de conception de composants

## Description
Ce document présente des modèles et des patrons de conception pour créer des composants réutilisables, maintenables et évolutifs dans les applications modernes.

## Principes de conception de composants

### 1. Responsabilité unique
Chaque composant ne devrait avoir qu'une seule raison de changer.

```jsx
// Mauvais exemple - composant avec multiples responsabilités
const UserProfile = ({ userId }) => {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Chargement des données utilisateur
    fetchUser(userId).then(setUser);
    // Chargement des posts
    fetchUserPosts(userId).then(setPosts);
    setLoading(false);
  }, [userId]);

  if (loading) return <div>Loading...</div>;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <div>
        {posts.map(post => (
          <div key={post.id}>{post.title}</div>
        ))}
      </div>
    </div>
  );
};

// Bon exemple - composants séparés
const UserProfileLoader = ({ userId, children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;

  return children({ user });
};

const UserPostsLoader = ({ userId, children }) => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUserPosts(userId)
      .then(setPosts)
      .finally(() => setLoading(false));
  }, [userId]);

  return children({ posts, loading });
};

const UserProfile = ({ userId }) => (
  <UserProfileLoader userId={userId}>
    {({ user }) => (
      <div>
        <h1>{user.name}</h1>
        <p>{user.email}</p>
        <UserPostsLoader userId={userId}>
          {({ posts }) => (
            <div>
              {posts.map(post => (
                <div key={post.id}>{post.title}</div>
              ))}
            </div>
          )}
        </UserPostsLoader>
      </div>
    )}
  </UserProfileLoader>
);
```

### 2. Composition sur héritage
Préférez la composition à l'héritage pour créer des composants réutilisables.

```jsx
// Mauvais exemple - utilisation de l'héritage
class Button extends React.Component {
  render() {
    return <button className="base-button">{this.props.children}</button>;
  }
}

class PrimaryButton extends Button {
  render() {
    return <button className="primary-button">{this.props.children}</button>;
  }
}

// Bon exemple - composition
const Button = ({ variant = 'base', children, ...props }) => {
  const buttonVariants = {
    base: 'base-button',
    primary: 'primary-button',
    secondary: 'secondary-button',
    danger: 'danger-button'
  };

  return (
    <button className={buttonVariants[variant]} {...props}>
      {children}
    </button>
  );
};

// Ou avec composition
const withVariant = (WrappedComponent) => ({ variant, ...props }) => {
  const variants = {
    primary: 'primary-styles',
    secondary: 'secondary-styles'
  };
  
  return (
    <WrappedComponent 
      className={variants[variant]}
      {...props} 
    />
  );
};
```

## Modèles de conception avancés

### 1. Modèle Render Props
Permet de partager du code entre composants en utilisant une prop dont la valeur est une fonction.

```jsx
// Composant avec Render Props
class MouseTracker extends React.Component {
  constructor(props) {
    super(props);
    this.state = { x: 0, y: 0 };
  }

  handleMouseMove = (event) => {
    this.setState({
      x: event.clientX,
      y: event.clientY
    });
  };

  render() {
    return (
      <div style={{ height: '100vh' }} onMouseMove={this.handleMouseMove}>
        {this.props.render(this.state)}
      </div>
    );
  }
}

// Utilisation
const MouseDisplay = () => (
  <MouseTracker
    render={({ x, y }) => (
      <p>Position de la souris: {x}, {y}</p>
    )}
  />
);
```

### 2. Modèle Hooks
Permet de réutiliser l'état et les effets entre composants fonctionnels.

```jsx
// Hook personnalisé
const useApi = (url) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url);
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};

// Utilisation
const UserList = () => {
  const { data: users, loading, error } = useApi('/api/users');

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <ul>
      {users?.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
};
```

### 3. Modèle Container/Presenter
Séparation de la logique (container) et de la présentation (presenter).

```jsx
// Container - Logique métier
class UserProfileContainer extends React.Component {
  state = {
    user: null,
    loading: true,
    error: null
  };

  async componentDidMount() {
    try {
      const user = await fetchUser(this.props.userId);
      this.setState({ user, loading: false });
    } catch (error) {
      this.setState({ error, loading: false });
    }
  }

  render() {
    return (
      <UserProfilePresenter
        user={this.state.user}
        loading={this.state.loading}
        error={this.state.error}
        onEdit={this.handleEdit}
      />
    );
  }
}

// Presenter - Affichage
const UserProfilePresenter = ({ user, loading, error, onEdit }) => {
  if (loading) return <div>Chargement...</div>;
  if (error) return <div>Erreur: {error.message}</div>;
  if (!user) return <div>Utilisateur non trouvé</div>;

  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <p>Email: {user.email}</p>
      <button onClick={onEdit}>Modifier</button>
    </div>
  );
};
```

## Modèles de conception fonctionnels

### 1. Modèle Higher-Order Component (HOC)
Fonction qui prend un composant et retourne un nouveau composant avec des fonctionnalités supplémentaires.

```jsx
// HOC pour l'authentification
const withAuth = (WrappedComponent) => {
  return class extends React.Component {
    state = {
      isAuthenticated: false,
      user: null
    };

    componentDidMount() {
      // Vérification de l'authentification
      this.checkAuth();
    }

    checkAuth = async () => {
      try {
        const user = await getCurrentUser();
        this.setState({ isAuthenticated: true, user });
      } catch (error) {
        this.setState({ isAuthenticated: false });
      }
    };

    render() {
      if (!this.state.isAuthenticated) {
        return <Redirect to="/login" />;
      }

      return (
        <WrappedComponent
          {...this.props}
          user={this.state.user}
        />
      );
    }
  };
};

// Utilisation
const ProtectedProfile = withAuth(UserProfile);
```

### 2. Modèle Compound Components
Composants qui fonctionnent ensemble pour former une interface cohérente.

```jsx
// Menu composé
const Menu = ({ children, isOpen, onToggle }) => (
  <div className={`menu ${isOpen ? 'open' : ''}`}>
    {React.Children.map(children, child =>
      React.cloneElement(child, { onToggle })
    )}
  </div>
);

Menu.Button = ({ children, onToggle }) => (
  <button onClick={onToggle} className="menu-button">
    {children}
  </button>
);

Menu.List = ({ children }) => (
  <ul className="menu-list">
    {children}
  </ul>
);

Menu.Item = ({ children, onClick }) => (
  <li className="menu-item" onClick={onClick}>
    {children}
  </li>
);

// Utilisation
const AppMenu = () => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <Menu isOpen={isOpen} onToggle={() => setIsOpen(!isOpen)}>
      <Menu.Button>Menu</Menu.Button>
      <Menu.List>
        <Menu.Item onClick={() => console.log('Home')}>Home</Menu.Item>
        <Menu.Item onClick={() => console.log('About')}>About</Menu.Item>
      </Menu.List>
    </Menu>
  );
};
```

## Modèles de gestion d'état

### 1. Modèle State Machine
Gestion des états complexes avec des transitions explicites.

```jsx
// Définition de la machine à états
const loadingMachine = {
  initial: 'idle',
  states: {
    idle: {
      on: { FETCH: 'loading' }
    },
    loading: {
      on: { SUCCESS: 'success', ERROR: 'error' }
    },
    success: {
      on: { FETCH: 'loading', RESET: 'idle' }
    },
    error: {
      on: { RETRY: 'loading', RESET: 'idle' }
    }
  }
};

// Hook pour la machine à états
const useStateMachine = (initialState, config) => {
  const [state, setState] = useState(initialState);

  const send = (event) => {
    const nextState = config.states[state]?.on[event];
    if (nextState) {
      setState(nextState);
    }
  };

  return [state, send];
};

// Utilisation
const DataFetcher = ({ url }) => {
  const [currentState, send] = useStateMachine('idle', loadingMachine);

  const fetchData = async () => {
    send('FETCH');
    try {
      const data = await fetch(url).then(r => r.json());
      send('SUCCESS');
    } catch (error) {
      send('ERROR');
    }
  };

  return (
    <div>
      {currentState === 'idle' && <button onClick={fetchData}>Fetch</button>}
      {currentState === 'loading' && <div>Loading...</div>}
      {currentState === 'success' && <div>Data loaded!</div>}
      {currentState === 'error' && <div>Error!</div>}
    </div>
  );
};
```

### 2. Modèle Provider Pattern
Gestion de l'état partagé entre composants.

```jsx
// Contexte pour l'utilisateur
const UserContext = React.createContext();

export const UserProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const login = async (credentials) => {
    setLoading(true);
    try {
      const userData = await authenticate(credentials);
      setUser(userData);
    } catch (error) {
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    setUser(null);
  };

  const value = {
    user,
    loading,
    login,
    logout
  };

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
};

// Hook pour consommer le contexte
export const useUser = () => {
  const context = React.useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
};

// Utilisation
const ProfilePage = () => {
  const { user, loading } = useUser();

  if (loading) return <div>Loading...</div>;
  if (!user) return <div>Please log in</div>;

  return <div>Welcome, {user.name}!</div>;
};
```

## Meilleures pratiques

### 1. Composition de fonctions
Combiner des fonctions simples pour créer des composants complexes.

```jsx
// Fonctions de transformation de composants
const withLogging = (WrappedComponent) => (props) => {
  useEffect(() => {
    console.log(`Component mounted: ${WrappedComponent.name}`);
  }, []);

  return <WrappedComponent {...props} />;
};

const withErrorBoundary = (WrappedComponent) => {
  return class extends React.Component {
    state = { hasError: false };

    static getDerivedStateFromError(error) {
      return { hasError: true };
    }

    componentDidCatch(error, errorInfo) {
      console.error('Error caught by boundary:', error, errorInfo);
    }

    render() {
      if (this.state.hasError) {
        return <div>Something went wrong.</div>;
      }
      return <WrappedComponent {...this.props} />;
    }
  };
};

// Composition
const EnhancedComponent = withLogging(withErrorBoundary(MyComponent));
```

### 2. Modularité et réutilisabilité
Structurer les composants pour maximiser la réutilisation.

```jsx
// Composant générique de formulaire
const FormField = ({
  label,
  type = 'text',
  value,
  onChange,
  error,
  children,
  ...props
}) => (
  <div className="form-field">
    <label>{label}</label>
    {children || (
      <input
        type={type}
        value={value}
        onChange={onChange}
        className={error ? 'error' : ''}
        {...props}
      />
    )}
    {error && <span className="error-message">{error}</span>}
  </div>
);

// Composants spécialisés
const TextInput = (props) => (
  <FormField {...props} type="text" />
);

const PasswordInput = (props) => (
  <FormField {...props} type="password" />
);

const EmailInput = (props) => (
  <FormField {...props} type="email" />
);

// Utilisation
const LoginForm = () => {
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});

  const handleChange = (field) => (e) => {
    setFormData(prev => ({
      ...prev,
      [field]: e.target.value
    }));
    
    // Effacer l'erreur lors de la modification
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: null
      }));
    }
  };

  return (
    <form>
      <EmailInput
        label="Email"
        value={formData.email}
        onChange={handleChange('email')}
        error={errors.email}
      />
      <PasswordInput
        label="Password"
        value={formData.password}
        onChange={handleChange('password')}
        error={errors.password}
      />
    </form>
  );
};
```

Ces modèles de conception de composants permettent de créer des applications modulaires, maintenables et évolutives en favorisant la réutilisation du code, la séparation des préoccupations et la clarté de l'architecture.