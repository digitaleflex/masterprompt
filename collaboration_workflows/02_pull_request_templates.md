# Modèles de pull request

## Description
Ce document fournit des modèles et des directives pour créer des pull requests (PR) claires, complètes et efficaces.

## Modèle standard de pull request

```markdown
## Description

<!-- Décrivez brièvement les changements effectués -->

## Problème résolu

<!-- Lien vers l'issue ou description du problème résolu -->

## Changements apportés

<!-- Détaillez les changements principaux -->

- [ ] Changement 1
- [ ] Changement 2
- [ ] Changement 3

## Détails techniques

<!-- Détaillez les aspects techniques importants -->

## Comment tester

<!-- Instructions pour tester les changements -->

## Captures d'écran (si applicable)

<!-- Ajoutez des captures d'écran si pertinent -->

## Checklist

- [ ] Le code suit les conventions de codage
- [ ] Les tests existants passent
- [ ] Les nouveaux tests ont été ajoutés
- [ ] La documentation a été mise à jour
- [ ] Les variables d'environnement sont documentées
- [ ] Les migrations de base de données sont incluses
```

## Modèles spécifiques par type de changement

### 1. Modèle pour nouvelle fonctionnalité
```markdown
## 🚀 Nouvelle fonctionnalité : [Nom de la fonctionnalité]

### Description
Cette PR introduit [brève description de la fonctionnalité].

### Problème résolu
Fixe #<numéro-de-l-issue>

### Changements apportés
- Ajout de la fonctionnalité de [détail]
- Mise à jour des composants UI
- Ajout des tests unitaires
- Documentation mise à jour

### Détails techniques
- Utilisation de [technologie/pattern spécifique]
- Modifications apportées à [nom du module/composant]
- Nouvelles dépendances : [liste si applicable]

### Comment tester
1. Se rendre sur [chemin de la page]
2. Vérifier que [comportement attendu]
3. S'assurer que [autre vérification]

### Impact sur les performances
- [Aucun / Léger / Important] impact sur les performances
- [Détail de l'impact si pertinent]

### Checklist
- [ ] Tous les tests passent
- [ ] La fonctionnalité répond aux exigences
- [ ] Code couvert par des tests
- [ ] Documentation mise à jour
- [ ] A11y (accessibilité) vérifiée
- [ ] SEO mis à jour si nécessaire
```

### 2. Modèle pour correction de bug
```markdown
## 🐛 Correction de bug : [Brève description du bug]

### Problème
Le bug se manifestait par [description du problème] dans [contexte spécifique].

### Cause racine
[Explication de la cause du bug]

### Solution
La solution consiste à [description de la solution mise en œuvre].

### Étapes pour reproduire (avant correction)
1. Aller sur [page/section]
2. Faire [action spécifique]
3. Le bug se manifeste par [comportement incorrect]

### Étapes pour vérifier (après correction)
1. Répéter les étapes ci-dessus
2. Vérifier que [comportement correct]

### Tests ajoutés
- [ ] Test pour reproduire le bug
- [ ] Test pour valider la correction
- [ ] Test de régression

### Impact
- [ ] Affecte les utilisateurs existants
- [ ] Affecte les performances
- [ ] Affecte la sécurité
- [ ] Aucun impact notable

### Checklist
- [ ] Bug reproduit et corrigé
- [ ] Tests ajoutés pour prévenir le retour du bug
- [ ] Aucun régression introduite
- [ ] Code review effectuée
```

### 3. Modèle pour amélioration de performance
```markdown
## ⚡ Amélioration de performance : [Description]

### Problème de performance
- Page de chargement : [temps avant correction]
- Utilisation de la mémoire : [valeur avant]
- Temps de réponse API : [valeur avant]

### Solution implémentée
1. [Optimisation 1]
2. [Optimisation 2]
3. [Optimisation 3]

### Résultats mesurés
- Page de chargement : [temps après correction] (amélioration de X%)
- Utilisation de la mémoire : [valeur après] (réduction de X%)
- Temps de réponse API : [valeur après] (amélioration de X%)

### Outils de mesure utilisés
- [Outil 1] : [Méthode de mesure]
- [Outil 2] : [Méthode de mesure]

### Impact sur la fonctionnalité
- [ ] Aucun changement de comportement
- [ ] Changement mineur de comportement (détaillez)
- [ ] Changement majeur de comportement (justifiez)

### Checklist
- [ ] Amélioration mesurée et documentée
- [ ] Aucune régression fonctionnelle
- [ ] Tests de performance ajoutés
- [ ] Méthodologie de test documentée
```

### 4. Modèle pour refactoring
```markdown
## 🔧 Refactoring : [Description du refactoring]

### Objectif
Ce refactoring vise à [but du refactoring] en [méthode utilisée].

### Changements apportés
#### Avant
```javascript
// Exemple de code avant
```

#### Après
```javascript
// Exemple de code après
```

### Avantages
- [ ] Lisibilité améliorée
- [ ] Maintenabilité accrue
- [ ] Réduction de la dette technique
- [ ] Meilleure testabilité
- [ ] Moins de duplication de code

### Risques potentiels
- [Liste des risques identifiés et mitigations]

### Tests
- [ ] Tous les tests existants passent
- [ ] Tests unitaires mis à jour
- [ ] Tests d'intégration passés
- [ ] Tests manuels effectués

### Impact sur la dette technique
- [ ] Dette technique réduite
- [ ] Dette technique déplacée
- [ ] Aucun impact sur la dette technique

### Checklist
- [ ] Fonctionnalité inchangée
- [ ] Tests mis à jour
- [ ] Documentation mise à jour si nécessaire
- [ ] Aucune régression introduite
```

## Modèles pour différents types de projets

### 1. Projet React
```markdown
## 📦 Changements React : [Description]

### Composants modifiés
- [Nom du composant]: [Type de changement]
- [Nom du composant]: [Type de changement]

### Hooks personnalisés (si applicable)
- [Nom du hook]: [Description des changements]

### Breaking changes (si applicable)
- [Liste des changements cassants et migration]

### Performance
- [ ] Impact sur le rendu
- [ ] Nouveaux re-rendus
- [ ] Optimisations mises en place

### Accessibilité
- [ ] Tests A11y effectués
- [ ] Changements apportés pour l'accessibilité
- [ ] Outils utilisés pour vérifier

### Checklist React
- [ ] Props PropTypes correctement définis
- [ ] Hooks utilisés correctement
- [ ] State géré efficacement
- [ ] Context utilisé appropriément
- [ ] Performance optimisée (React.memo, etc.)
```

### 2. Projet API/Backend
```markdown
## 🌐 Changements API : [Description]

### Endpoints modifiés
- `GET /endpoint`: [Changements]
- `POST /endpoint`: [Changements]

### Changements de schéma
#### Avant
```json
{
  "ancienne_structure": "valeur"
}
```

#### Après
```json
{
  "nouvelle_structure": "valeur"
}
```

### Breaking changes
- [Liste des changements cassants]
- [Instructions de migration]

### Validation des données
- [ ] Nouvelles validations ajoutées
- [ ] Messages d'erreur améliorés
- [ ] Sécurité renforcée

### Tests d'API
- [ ] Tests d'intégration mis à jour
- [ ] Tests de sécurité ajoutés
- [ ] Tests de charge effectués (si pertinent)

### Documentation API
- [ ] Swagger/OpenAPI mis à jour
- [ ] Exemples de requêtes/réponses ajoutés
- [ ] Changements de version documentés
```

## Bonnes pratiques pour les pull requests

### 1. Taille des PR
- Limiter à 200-400 lignes de changement
- Faire des PR atomiques (un seul objectif par PR)
- Diviser les grosses fonctionnalités en plusieurs PR

### 2. Titre des PR
- Utiliser un format cohérent
- Être descriptif mais concis
- Inclure le type de changement (feat, fix, docs, etc.)

### 3. Description
- Expliquer le *quoi* et le *pourquoi*
- Inclure des captures d'écran si pertinent
- Fournir des instructions de test
- Lier aux issues pertinentes

### 4. Revue de code
- Auto-revue avant soumission
- Vérification des conventions
- Tests exécutés localement
- Documentation mise à jour

## Outils et automatisation

### 1. Modèles GitHub
Créer un fichier `.github/PULL_REQUEST_TEMPLATE.md` dans le dépôt pour appliquer un modèle par défaut.

### 2. Validations automatisées
- Hooks Git pour formatage
- Tests CI/CD
- Analyse de code
- Vérification des dépendances

### 3. Labels automatiques
- `needs review` pour les PR prêtes
- `work in progress` pour les PR en cours
- `breaking change` pour les changements cassants
- `security` pour les changements de sécurité

## Checklist finale

### Avant de soumettre
- [ ] Tests exécutés localement
- [ ] Formatage du code vérifié
- [ ] Documentation mise à jour
- [ ] Conventions de codage suivies
- [ ] PR divisée si trop volumineuse
- [ ] Titre descriptif choisi

### Après soumission
- [ ] Status des checks vérifié
- [ ] Feedback des revueurs suivi
- [ ] Changements demandés appliqués
- [ ] PR maintenue à jour avec main
- [ ] Tests CI passent

Ces modèles et pratiques aident à créer des pull requests plus claires, plus faciles à revuer et plus cohérentes à travers le projet.