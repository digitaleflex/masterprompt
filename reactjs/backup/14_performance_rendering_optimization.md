# Prompts de performance et optimisation du rendu

## 1. Identification des re-renders inutiles
"Identifie les re-renders inutiles dans ce composant. Où devrais-je placer React.memo, useMemo ou useCallback ?"

## 2. Analyse de la taille du bundle
"Analyse la taille du bundle. Propose des points d'entrée pour le Code Splitting avec React.lazy et Suspense."

## 3. Optimisation des listes et des keys
"Vérifie si les listes (.map()) utilisent des key d'index. Propose une méthode de génération d'ID unique plus stable."

## 4. Chargement optimisé des images
"Optimise le chargement des images : implémente le lazy loading et les formats modernes (WebP)."

## 5. Mise en cache des appels API
"Ce composant fait-il des appels API dans une boucle ou un rendu fréquent ? Propose une solution de mise en cache avec TanStack Query."

## 6. Optimisation des bibliothèques tierces
"Analyse l'utilisation des bibliothèques tierces. Existe-t-il des alternatives plus légères (ex: date-fns au lieu de moment) ?"

## 7. Parallélisation des requêtes réseau
"Vérifie la gestion du 'Waterfall' de requêtes réseau. Comment paralléliser ces appels API ?"

## 8. Virtual Scrolling pour les grandes listes
"Implémente le virtual scrolling pour une liste de plus de 1000 éléments avec react-window ou react-virtualized."

## 9. Optimisation des polices
"Optimise le chargement des polices : implémente font-display: swap et le préchargement des polices critiques."

## 10. Gestion de la mémoire
"Vérifie s'il y a des fuites de mémoire potentielles dans les useEffect et les gestionnaires d'événements."

## 11. Optimisation des animations
"Analyse les animations pour s'assurer qu'elles n'utilisent que les propriétés CSS optimisées pour les performances (transform, opacity)."

## 12. Préchargement et prélecture
"Implémente les stratégies de préchargement (preload) et de prélecture (prefetch) pour les ressources critiques."

## 13. Minification et compression
"Vérifie la configuration de minification et de compression pour les builds de production."

## 14. Gestion des événements
"Optimise la gestion des événements pour éviter la création inutile de fonctions dans les rendus."

## 15. Surveillance des performances
"Mets en place des métriques de performance (Core Web Vitals) avec Web Vitals API pour surveiller les performances en production."