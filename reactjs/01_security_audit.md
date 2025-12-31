# Audit de sécurité React - Prompt 1

## Description
Ce prompt est conçu pour effectuer un audit de sécurité approfondi sur un projet React existant.

## Instructions détaillées

### Contexte
Vous êtes un expert en sécurité des applications React. Analysez ce projet React avec un accent particulier sur :

1. **Injection de code (XSS)**
   - Analysez l'utilisation de `dangerouslySetInnerHTML`
   - Vérifiez la validation des entrées utilisateur
   - Identifiez les risques d'injection de scripts

2. **Gestion des dépendances**
   - Vérifiez les vulnérabilités connues dans les dépendances
   - Analysez les versions obsolètes des bibliothèques
   - Identifiez les dépendances non maintenues

3. **Authentification et autorisation**
   - Vérifiez la gestion des tokens JWT
   - Analysez le stockage sécurisé des secrets
   - Identifiez les problèmes de gestion de session

4. **Communication API**
   - Analysez les requêtes HTTP pour les fuites d'informations
   - Vérifiez l'utilisation de CORS
   - Identifiez les risques de CSRF

5. **Gestion des erreurs**
   - Vérifiez si les erreurs exposent des informations sensibles
   - Analysez la journalisation des erreurs

## Étapes de l'audit

### Phase 1 : Analyse statique
1. Scanner le code pour les patterns de vulnérabilité
2. Vérifier les imports et dépendances
3. Analyser les composants critiques

### Phase 2 : Analyse dynamique (si applicable)
1. Vérifier les endpoints API exposés
2. Tester les points d'entrée utilisateur
3. Valider la sécurité des routes

### Phase 3 : Rapport de sécurité
1. Classer les vulnérabilités par gravité (Critique, Haute, Moyenne, Basse)
2. Fournir des exemples de code vulnérable
3. Proposer des correctifs spécifiques
4. Donner des recommandations de sécurité

## Format de sortie attendu

### 1. Résumé exécutif
- Nombre total de vulnérabilités identifiées
- Niveau de gravité global
- Risques critiques immédiats

### 2. Détail des vulnérabilités
Pour chaque vulnérabilité :
- Description du problème
- Fichiers/emplacements concernés
- Niveau de gravité
- Impact potentiel
- Correctif recommandé

### 3. Recommandations prioritaires
- Correctifs critiques à appliquer immédiatement
- Améliorations de sécurité à moyen terme
- Bonnes pratiques à adopter

## Exemple de recherche de vulnérabilités

### Recherche de XSS
```javascript
// Rechercher ces patterns dans le code :
dangerouslySetInnerHTML
innerHTML
eval(
Function(
```

### Recherche de gestion inappropriée des tokens
```javascript
// Rechercher ces mauvaises pratiques :
localStorage.setItem('token', 
sessionStorage.setItem('jwt', 
props.token
headers: { 'Authorization': `Bearer ${token}` }
```

## Outils recommandés pour l'audit
- npm audit pour les vulnérabilités de dépendances
- ESLint avec règles de sécurité
- Snyk ou OWASP Dependency Check
- OWASP ZAP pour les tests dynamiques (si applicable)

Soyez précis, concret et fournissez des exemples de code corrigé.