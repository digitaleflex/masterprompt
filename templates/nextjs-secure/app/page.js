import styles from './page.module.css'

export default function Home() {
  return (
    <div className={styles.main}>
      <h1>Projet Next.js avec sécurité intégrée</h1>
      <p>
        Ce projet inclut des en-têtes de sécurité, des outils de qualité et de productivité.
      </p>
      <div className={styles.card}>
        <button onClick={() => alert('Sécurité activée !')}>
          Vérifier la sécurité
        </button>
      </div>
    </div>
  )
}