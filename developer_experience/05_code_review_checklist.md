# Checklist de revue de code

## Description
Ce document fournit une checklist complète pour effectuer des revues de code efficaces et maintenir une qualité élevée du code.

## Avant la revue

### 1. Préparation du revendeur
- [ ] Le titre de la pull request est clair et descriptif
- [ ] La description explique le *quoi* et le *pourquoi* du changement
- [ ] Les tests unitaires sont fournis et passent
- [ ] Le code respecte les conventions de codage du projet
- [ ] Les modifications sont limitées à une seule fonctionnalité/logicel
- [ ] La taille de la PR est raisonnable (moins de 400 lignes de changement)

### 2. Préparation du réviseur
- [ ] Lu et compris la description de la PR
- [ ] Vérifié que les tests CI passent
- [ ] Confirmé que la PR répond à un besoin ou corrige un problème documenté
- [ ] Affecté suffisamment de temps pour une revue approfondie

## Revue technique

### 1. Logique métier
- [ ] Le code implémente correctement la logique métier requise
- [ ] Tous les cas limites sont gérés
- [ ] Les validations d'entrée sont en place
- [ ] Le comportement en cas d'erreur est approprié
- [ ] Les performances sont optimales pour les opérations critiques

### 2. Sécurité
- [ ] Aucune injection de code possible (SQL, XSS, etc.)
- [ ] Les validations d'entrée sont strictes
- [ ] Les secrets ne sont pas exposés dans le code
- [ ] Les permissions sont correctement gérées
- [ ] Les données sensibles sont correctement protégées

### 3. Qualité du code
- [ ] Le code est lisible et bien commenté (quand nécessaire)
- [ ] Les noms de variables/fonctions sont descriptifs
- [ ] Pas de code dupliqué (DRY - Don't Repeat Yourself)
- [ ] Les fonctions sont de taille raisonnable (< 50 lignes)
- [ ] Les principes SOLID sont respectés

### 4. Tests
- [ ] Les tests unitaires couvrent les cas principaux
- [ ] Les tests de cas limites sont inclus
- [ ] Les tests d'intégration sont mis à jour si nécessaire
- [ ] Les tests existants continuent de passer
- [ ] La couverture de test est maintenue ou améliorée

## Revue architecturale

### 1. Structure du code
- [ ] Le code suit l'architecture du projet
- [ ] Les dépendances sont correctement gérées
- [ ] Pas de dépendances circulaires
- [ ] Les responsabilités sont clairement séparées
- [ ] Les patterns de conception sont utilisés correctement

### 2. Performance
- [ ] Pas de requêtes N+1 dans les opérations de base de données
- [ ] Les opérations lourdes sont correctement optimisées
- [ ] Le code ne bloque pas les threads principaux
- [ ] La mémoire est correctement gérée (pas de fuites)
- [ ] Les ressources externes sont correctement libérées

## Revue de style

### 1. Conventions de codage
- [ ] Le code suit les conventions de nommage du projet
- [ ] Le formatage est cohérent avec le reste du code
- [ ] Les imports sont organisés et sans imports inutiles
- [ ] Les commentaires sont pertinents et pas redondants
- [ ] Le code est aligné avec les standards du langage

### 2. Documentation
- [ ] Les fonctions complexes sont correctement documentées
- [ ] Les changements de comportement sont documentés
- [ ] Les API sont correctement documentées
- [ ] Les configurations sont expliquées si nécessaire
- [ ] Les exemples d'utilisation sont fournis si pertinent

## Revue de testabilité

### 1. Facilité de test
- [ ] Le code est facilement testable (pas de dépendances cachées)
- [ ] Les fonctions sont pures quand possible
- [ ] Les effets de bord sont clairement identifiés
- [ ] Les dépendances externes sont mockables
- [ ] Les points d'injection de dépendances sont clairs

### 2. Débogage
- [ ] Les messages d'erreur sont descriptifs
- [ ] Les logs sont pertinents et pas verbeux
- [ ] Les points de débogage sont faciles à identifier
- [ ] Les erreurs sont correctement gérées et remontées
- [ ] Les données sensibles ne sont pas loguées

## Revue de déploiement

### 1. Changements de configuration
- [ ] Les nouvelles variables d'environnement sont documentées
- [ ] Les changements de configuration sont réversibles
- [ ] Les valeurs par défaut sont raisonnables
- [ ] Les secrets sont gérés séparément du code
- [ ] Les configurations sont cohérentes entre environnements

### 2. Migration et compatibilité
- [ ] Les migrations de base de données sont fournies
- [ ] Les changements sont rétrocompatibles ou bien documentés
- [ ] Les API existantes ne sont pas cassées sans préavis
- [ ] Les changements de schéma sont documentés
- [ ] Les impacts sur les clients existants sont évalués

## Revue de sécurité

### 1. Gestion des données
- [ ] Les validations d'entrée sont strictes et complètes
- [ ] Les données sont correctement échappées pour la sortie
- [ ] Les permissions sont correctement vérifiées
- [ ] Les données sensibles sont chiffrées si nécessaire
- [ ] Les journaux ne contiennent pas d'informations sensibles

### 2. Authentification et autorisation
- [ ] Les sessions sont correctement gérées
- [ ] Les tokens sont sécurisés et avec durée de vie limitée
- [ ] Les contrôles d'accès sont en place et corrects
- [ ] Les mécanismes de sécurité sont à jour
- [ ] Les failles de sécurité connues sont vérifiées

## Revue d'accessibilité (si applicable)

### 1. Interface utilisateur
- [ ] Les éléments ont des labels appropriés
- [ ] Le code est navigable au clavier
- [ ] Les contrastes de couleurs sont suffisants
- [ ] Les descriptions alternatives sont présentes pour les images
- [ ] Les rôles et états ARIA sont correctement utilisés

## Checklist de fusion

### 1. Validation finale
- [ ] Tous les commentaires de revue sont résolus
- [ ] Les tests CI passent
- [ ] La base de code est stable
- [ ] Les performances sont acceptables
- [ ] La documentation est à jour

### 2. Processus de fusion
- [ ] Le nombre requis de revues positives est atteint
- [ ] Les modifications critiques ont été revues par des experts
- [ ] La stratégie de fusion est appropriée (merge, squash, rebase)
- [ ] La branche source sera supprimée après fusion
- [ ] Les tickets liés seront fermés après fusion

## Types de commentaires

### 1. Niveaux de sévérité
- **Critique** : Bloque la fusion - vulnérabilité de sécurité, bug majeur
- **Important** : Doit être corrigé - logique incorrecte, problème de performance
- **Recommandé** : Idéalement corrigé - amélioration de lisibilité, meilleure pratique
- **Question** : Clarification demandée - incertitude sur l'implémentation

### 2. Bonnes pratiques de commentaire
- Soyez spécifique et constructif
- Proposez des solutions alternatives quand possible
- Référez-vous aux standards ou documentation du projet
- Expliquez le *pourquoi* du commentaire
- Restez professionnel et respectueux

## Modèle de commentaire de revue

```
## Revue de code

### Points positifs
- [Liste des aspects bien implémentés]
- [Félicitations pour l'approche]

### Points à améliorer
- [Description du problème] → [Suggestion de correction]
- [Autre problème] → [Solution proposée]

### Questions
- [Question sur l'implémentation]
- [Question sur les choix techniques]

### Tests
- [Suggestion pour des tests supplémentaires si nécessaire]

### Documentation
- [Besoin de documentation supplémentaire]
```

## Indicateurs de qualité

### 1. Indicateurs pour les revendeurs
- Temps moyen entre PR et fusion
- Nombre de commentaires avant fusion
- Taux de réouverture après fusion
- Adhésion aux délais de livraison

### 2. Indicateurs pour les réviseurs
- Temps moyen de revue
- Qualité des commentaires (constructifs vs superficiels)
- Taux de détection des bugs avant production
- Équilibre entre vitesse et qualité

## Outils de revue de code

### 1. Outils d'analyse statique
- ESLint/Prettier pour le formatage
- SonarQube pour l'analyse de code
- Snyk pour la sécurité des dépendances
- CodeClimate pour la dette technique

### 2. Intégration dans le workflow
- Hooks Git pour le formatage automatique
- Actions CI pour les analyses automatiques
- Modèles de PR pour la structure
- Bots pour les suggestions automatisées

Cette checklist peut être adaptée selon les besoins spécifiques du projet et l'équipe de développement.