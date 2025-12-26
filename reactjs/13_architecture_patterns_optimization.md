# Prompts d'architecture et design patterns SOLID

## 1. Application du principe SRP
"Applique le principe de Responsabilité Unique (SRP) à ce composant de 300 lignes. Découpe-le en sous-composants logiques."

## 2. Extraction de la logique métier
"Transforme cette logique métier située dans l'UI en un Custom Hook réutilisable."

## 3. Structure de dossiers optimale
"Analyse la structure des dossiers. Est-elle organisée par 'Features' ou par 'Type' ? Recommande une structure Bulletproof React."

## 4. Gestion du state et évitement du prop drilling
"Vérifie si ce composant utilise trop de props (Prop Drilling). Propose une implémentation via Context API ou Zustand."

## 5. Patterns avancés de composants
"Identifie les composants qui pourraient être transformés en composants d'ordre supérieur (HOC) ou utiliser des Render Props."

## 6. Pureté des composants
"Ce composant est-il 'Pur' ? Vérifie qu'il n'a pas d'effets de bord imprévisibles en dehors de useEffect."

## 7. Typage strict avec TypeScript
"Analyse l'utilisation de TypeScript : y a-t-il trop de any ? Propose des interfaces strictes."

## 8. Conventions de nommage
"Vérifie la cohérence du nommage des fichiers et des variables selon les standards de l'industrie (Airbnb/Google)."

## 9. Injection de dépendances
"Propose une stratégie d'injection de dépendances pour faciliter les tests unitaires de ce service API."

## 10. Architecture de routage
"Est-ce que la logique de routage est centralisée ou éparpillée ? Optimise la configuration de React Router."

## 11. Abstraction des services
"Analyse les services API pour identifier les duplications et propose une abstraction commune."

## 12. Usage des enums et constantes
"Vérifie que les valeurs magiques sont remplacées par des enums ou des constantes bien nommées."

## 13. Principe OCP (Open/Closed)
"Applique le principe Ouvert/Fermé : ce composant est-il ouvert à l'extension mais fermé à la modification ?"

## 14. Principe LSP (Liskov Substitution)
"Analyse si les composants enfants respectent le principe de substitution de Liskov dans les hiérarchies d'héritage."

## 15. Principe ISP (Interface Segregation)
"Applique le principe de ségrégation des interfaces : les props des composants sont-elles minimales et spécifiques ?"

## 16. Principe DIP (Dependency Inversion)
"Vérifie que les composants dépendent d'abstractions plutôt que de détails concrets."

## 17. Gestion des erreurs architecturales
"Implémente une stratégie de gestion des erreurs au niveau architecture pour tous les composants."

## 18. Tests unitaires et couverture
"Analyse la testabilité du code et propose des tests unitaires pour les hooks et services critiques."

## 19. Réutilisabilité des composants
"Vérifie que les composants sont suffisamment génériques pour être réutilisables dans d'autres contextes."

## 20. Documentation et maintenabilité
"Documente l'architecture et propose des annotations pour améliorer la maintenabilité à long terme."