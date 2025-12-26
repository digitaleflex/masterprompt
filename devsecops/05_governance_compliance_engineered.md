# 5. Gouvernance & Compliance Code (Prompts 71-85) - Version Ingénierie des Prompts

*Focus : Standards de l'entreprise et législation.*

## Prompt 71
En tant qu'expert en sécurité logicielle OWASP, vérifie si le code respecte les standards OWASP Top 10 et génère un rapport de conformité.
Analyse spécifiquement :
- Les vulnérabilités OWASP Top 10 présentes
- Les contrôles de sécurité implémentés
- Les lacunes de sécurité
- Les processus de vérification

Format de réponse :
1. Analyse des vulnérabilités OWASP Top 10
2. Identification des non-conformités
3. Recommandations de sécurité
4. Rapport de conformité détaillé

## Prompt 72
En tant qu'expert en intégration continue sécurisée, ajoute des hooks de pré-commit pour forcer l'exécution de `npm audit` avant chaque push.
Considère spécifiquement :
- Les outils de gestion des hooks
- Les configurations de sécurité
- Les processus d'automatisation
- Les politiques de blocage

Format de réponse :
1. Configuration des hooks de pré-commit
2. Intégration de `npm audit` dans les hooks
3. Processus de blocage des commits non sécurisés
4. Mécanismes de contournement pour les exceptions

## Prompt 73
En tant qu'expert en conformité réglementaire, explique comment automatiser la création d'un rapport de conformité pour un audit SOC2 ou ISO 27001.
Analyse spécifiquement :
- Les exigences des audits
- Les outils de génération de rapports
- Les processus d'automatisation
- Les contrôles à documenter

Format de réponse :
1. Spécification des exigences d'audit
2. Architecture du système de génération de rapports
3. Processus d'automatisation
4. Intégration avec les frameworks d'audit

## Prompt 74
En tant qu'expert en cryptographie, analyse si les données de santé ou bancaires sont chiffrées au repos (Encryption at Rest) dans le schéma de base de données.
Vérifie spécifiquement :
- Les données sensibles identifiées
- Les méthodes de chiffrement
- Les clés de chiffrement
- Les processus de gestion

Format de réponse :
1. Analyse de la protection des données sensibles
2. Évaluation des méthodes de chiffrement
3. Identification des lacunes de sécurité
4. Recommandations de chiffrement

## Prompt 75
En tant qu'expert en conformité RGPD, propose une politique de rétention des données conforme au RGPD (suppression automatique après X temps).
Considère spécifiquement :
- Les catégories de données
- Les délais de conservation
- Les processus de suppression
- Les exigences légales

Format de réponse :
1. Politique de rétention des données
2. Catégories de données et délais de conservation
3. Processus de suppression automatique
4. Conformité avec les exigences RGPD

## Prompt 76
En tant qu'expert en gestion des accès, analyse les politiques d'accès aux données pour vérifier leur conformité au principe du moindre privilège.
Analyse spécifiquement :
- Les rôles et permissions
- Les accès excessifs
- Les politiques de sécurité
- Les processus de vérification

Format de réponse :
1. Analyse des politiques d'accès actuelles
2. Identification des accès excessifs
3. Recommandations pour le moindre privilège
4. Processus de mise en œuvre

## Prompt 77
En tant qu'expert en qualité logicielle, explique comment implémenter des revues de code obligatoires pour les modifications critiques.
Considère spécifiquement :
- Les critères de modifications critiques
- Les processus de revue
- Les outils d'automatisation
- Les politiques de blocage

Format de réponse :
1. Définition des modifications critiques
2. Processus de revue de code obligatoire
3. Intégration avec les systèmes de gestion de code
4. Politiques de validation et de blocage

## Prompt 78
En tant qu'expert en documentation technique, vérifie si les documents de sécurité sont à jour et facilement accessibles aux développeurs.
Analyse spécifiquement :
- La pertinence des documents
- L'accessibilité des informations
- Les processus de mise à jour
- Les canaux de diffusion

Format de réponse :
1. Évaluation de la documentation de sécurité
2. Identification des lacunes
3. Recommandations d'amélioration
4. Processus de maintenance et de diffusion

## Prompt 79
En tant qu'expert en licences logicielles, explique comment automatiser la vérification des licences open source dans le code.
Considère spécifiquement :
- Les outils de vérification
- Les bases de données de licences
- Les processus d'analyse
- Les politiques de blocage

Format de réponse :
1. Solution d'analyse des licences open source
2. Intégration dans le pipeline CI/CD
3. Processus de vérification automatique
4. Politiques de gestion des licences

## Prompt 80
En tant qu'expert en gestion des incidents, analyse si les processus de gestion des incidents sont documentés et testés régulièrement.
Vérifie spécifiquement :
- Les procédures documentées
- Les rôles et responsabilités
- Les processus de test
- Les mécanismes de mise à jour

Format de réponse :
1. Analyse des processus de gestion des incidents
2. Identification des lacunes
3. Recommandations d'amélioration
4. Processus de test et de validation

## Prompt 81
En tant qu'expert en gestion des vulnérabilités, explique comment implémenter un système de gestion des vulnérabilités (Vulnerability Management).
Analyse spécifiquement :
- Les processus de détection
- Les politiques de classification
- Les flux de travail
- Les outils de gestion

Format de réponse :
1. Architecture du système de gestion des vulnérabilités
2. Processus de détection et de classification
3. Flux de travail pour la gestion
4. Intégration avec les systèmes existants

## Prompt 82
En tant qu'expert en intégration de la sécurité, vérifie si les politiques de sécurité sont intégrées dans les outils de développement.
Analyse spécifiquement :
- Les outils de développement concernés
- Les politiques de sécurité implémentées
- Les processus d'intégration
- Les mécanismes de vérification

Format de réponse :
1. Analyse de l'intégration de la sécurité
2. Identification des lacunes d'intégration
3. Recommandations d'amélioration
4. Processus de mise en œuvre

## Prompt 83
En tant qu'expert en qualité du code, explique comment automatiser la vérification des standards de codage (ex: via ESLint, SonarQube).
Considère spécifiquement :
- Les outils de vérification
- Les règles de codage
- Les processus d'automatisation
- Les politiques d'application

Format de réponse :
1. Solution d'automatisation de la vérification du code
2. Configuration des outils d'analyse
3. Processus d'intégration dans le workflow
4. Politiques d'application et de correction

## Prompt 84
En tant qu'expert en gestion des changements, analyse si les processus de gestion des changements sont conformes aux bonnes pratiques.
Vérifie spécifiquement :
- Les procédures de changement
- Les validations requises
- Les processus de test
- Les mécanismes de suivi

Format de réponse :
1. Analyse des processus de gestion des changements
2. Identification des écarts aux bonnes pratiques
3. Recommandations d'amélioration
4. Processus de mise en conformité

## Prompt 85
En tant qu'expert en documentation de sécurité, explique comment implémenter une documentation de sécurité intégrée au code (ex: README de sécurité).
Considère spécifiquement :
- Les éléments de documentation requis
- Les formats de documentation
- Les processus de mise à jour
- Les canaux de diffusion

Format de réponse :
1. Spécification de la documentation de sécurité
2. Formats et structures recommandés
3. Processus d'intégration dans le code
4. Mécanismes de maintenance et de diffusion