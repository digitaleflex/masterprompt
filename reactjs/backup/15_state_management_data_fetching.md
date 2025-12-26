# Prompts de gestion d'état et data fetching

## 1. Évaluation de la gestion d'état global
"Évalue la gestion d'état global. Est-ce que Redux est nécessaire ici ou une solution plus légère suffirait ?"

## 2. Migration vers une solution d'API robuste
"Refactorise ces appels fetch manuels vers une implémentation robuste avec Axios et des intercepteurs."

## 3. Stratégie de gestion d'erreurs globale
"Implémente une stratégie de gestion d'erreurs globale pour les appels API (Error Boundaries + Toast notifications)."

## 4. Logique de retry et polling
"Ajoute une logique de 'Retry' automatique et de 'Polling' sur cette requête critique."

## 5. Filtrage des données sensibles
"Vérifie si les données sensibles du backend sont correctement filtrées avant d'atteindre le state React."

## 6. Implémentation d'Optimistic UI
"Propose une implémentation d'Optimistic UI pour cette action de mise à jour (ex: bouton Like)."

## 7. Synchronisation d'état entre composants
"Analyse la synchronisation d'état entre les composants enfants et parents. Propose une solution avec useReducer si nécessaire."

## 8. Pré-chargement des données
"Implémente une stratégie de pré-chargement des données pour les routes critiques avec React Query ou SWR."

## 9. Gestion du cache client
"Optimise la gestion du cache client pour éviter les requêtes inutiles et améliorer les performances."

## 10. Gestion des états de chargement
"Implémente une gestion élégante des états de chargement (loading, error, success) pour une meilleure UX."

## 11. Gestion des données en temps réel
"Propose une solution pour gérer les données en temps réel (WebSocket, Server-Sent Events) avec mise en cache appropriée."

## 12. Pagination et infinite scroll
"Implémente une solution de pagination ou d'infinite scroll avec React Query pour les grandes listes de données."

## 13. Gestion des formulaires complexes
"Utilise une bibliothèque de gestion de formulaires (React Hook Form, Formik) pour les formulaires complexes."

## 14. Optimisation des requêtes
"Analyse les requêtes multiples et propose des solutions pour les optimiser (batching, caching, etc.)."

## 15. Gestion des tokens d'authentification
"Mets en place une gestion sécurisée des tokens d'authentification avec renouvellement automatique."