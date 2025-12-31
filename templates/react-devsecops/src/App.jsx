import './App.css'

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Projet React avec DevSecOps intégré</h1>
        <p>
          Ce projet inclut des outils de sécurité, de qualité et de productivité.
        </p>
        <p>
          <button onClick={() => alert('Sécurité activée !')}>
            Vérifier la sécurité
          </button>
        </p>
      </header>
    </div>
  )
}

export default App