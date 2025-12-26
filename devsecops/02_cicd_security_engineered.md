# 2. Pipeline CI/CD Sécurisé (Prompts 21-40) - Version Ingénierie des Prompts

*Focus : GitHub Actions, GitLab CI, Automatisation.*

## Prompt 21
En tant qu'expert en sécurité CI/CD, examine le workflow GitHub Actions suivant pour évaluer les permissions du `GITHUB_TOKEN`.
Analyse spécifiquement :
- Les permissions accordées aux étapes du workflow
- Les scopes d'accès nécessaires
- Les risques liés à des permissions excessives
- Les meilleures pratiques de sécurité

Format de réponse :
1. Analyse détaillée des permissions actuelles
2. Identification des permissions excessives
3. Recommandations pour limiter les permissions au strict nécessaire
4. Exemples de configuration sécurisée

## Prompt 22
En tant qu'expert en sécurité DevSecOps, ajoute une étape de 'Secret Scanning' dans le pipeline CI/CD pour bloquer les commits contenant des clés privées.
Considère spécifiquement :
- Les outils de scanning disponibles (TruffleHog, GitGuardian, etc.)
- L'intégration dans le workflow
- Les actions à entreprendre en cas de détection
- Les faux positifs potentiels

Format de réponse :
1. Configuration recommandée pour le scanning de secrets
2. Intégration dans le pipeline CI/CD
3. Processus de réponse aux détections
4. Tests de validation de la solution

## Prompt 23
En tant qu'expert en sécurité logicielle, propose une étape de build qui génère une SBOM (Software Bill of Materials) pour l'application.
Considère spécifiquement :
- Les formats SBOM (SPDX, CycloneDX, SWID)
- Les outils disponibles (Syft, Grype, etc.)
- L'intégration dans le pipeline
- L'utilisation de la SBOM pour la sécurité

Format de réponse :
1. Configuration de la génération SBOM
2. Intégration dans le pipeline de build
3. Formats et outils recommandés
4. Utilisation de la SBOM pour la gestion des risques

## Prompt 24
En tant qu'expert en sécurité des images conteneurs, explique comment implémenter une signature d'image (Cosign) pour garantir que seules les images vérifiées sont déployées.
Analyse spécifiquement :
- La mise en place de Cosign ou d'autres outils de signature
- Le processus de signature dans le pipeline
- La vérification lors du déploiement
- Les clés et la gestion de confiance

Format de réponse :
1. Architecture de signature d'images
2. Processus de signature dans le CI/CD
3. Mécanismes de vérification au déploiement
4. Gestion des clés et de la chaîne de confiance

## Prompt 25
En tant qu'expert en optimisation CI/CD, analyse le pipeline pour déterminer où placer l'analyse statique (SAST) sans ralentir les développeurs.
Considère spécifiquement :
- Les étapes du pipeline
- Les types d'analyse (rapide vs complète)
- Les compromis entre sécurité et productivité
- Les outils SAST disponibles

Format de réponse :
1. Analyse de l'architecture actuelle du pipeline
2. Recommandations pour l'emplacement optimal de SAST
3. Stratégies pour minimiser l'impact sur les développeurs
4. Outils et configurations recommandés

## Prompt 26
En tant qu'expert en sécurité dynamique, configure une étape d'analyse dynamique (DAST) avec OWASP ZAP après le déploiement en environnement de staging.
Analyse spécifiquement :
- L'intégration de ZAP dans le pipeline
- Les configurations de scan appropriées
- L'analyse des résultats
- Les critères d'approbation pour le déploiement

Format de réponse :
1. Configuration de ZAP pour le scan DAST
2. Intégration dans le pipeline CI/CD
3. Processus d'analyse et d'interprétation des résultats
4. Critères de qualité de sécurité pour le déploiement

## Prompt 27
En tant qu'expert en gouvernance CI/CD, vérifie que le déploiement en production nécessite une approbation manuelle et des tests réussis à 100%.
Analyse spécifiquement :
- Les mécanismes d'approbation
- Les critères de qualité
- Les vérifications préalables
- Les processus de validation

Format de réponse :
1. Analyse de l'actuelle gouvernance de déploiement
2. Recommandations pour renforcer les contrôles
3. Processus d'approbation manuelle
4. Métriques de qualité requises

## Prompt 28
En tant qu'expert en conformité logicielle, implémente une vérification de la validité des licences de dépendances (License Compliance).
Considère spécifiquement :
- Les outils de vérification de licence
- Les types de licences à surveiller
- Les processus de blocage
- Les rapports de conformité

Format de réponse :
1. Solution de vérification des licences
2. Intégration dans le pipeline CI/CD
3. Politique de blocage des licences non conformes
4. Processus de gestion des exceptions

## Prompt 29
En tant qu'expert en déploiement CI/CD, propose un système de 'Rollback' automatique si les tests de santé échouent après un déploiement.
Analyse spécifiquement :
- Les critères de santé à surveiller
- Le processus de détection des échecs
- Le mécanisme de rollback
- Les tests de validation du rollback

Format de réponse :
1. Définition des indicateurs de santé
2. Configuration du monitoring post-déploiement
3. Processus de rollback automatique
4. Tests de validation de la solution

## Prompt 30
En tant qu'expert en sécurité CI/CD, explique comment sécuriser les 'Self-hosted Runners' pour éviter les attaques par injection de commande.
Analyse spécifiquement :
- Les risques liés aux runners auto-hébergés
- Les mesures de durcissement
- Les contrôles d'accès
- La surveillance des activités

Format de réponse :
1. Analyse des risques des runners auto-hébergés
2. Recommandations de durcissement
3. Contrôles de sécurité à implémenter
4. Processus de surveillance et de réponse