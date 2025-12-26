# 2. Pipeline CI/CD Sécurisé (Prompts 21-40)

*Focus : GitHub Actions, GitLab CI, Automatisation.*

## Prompt 21
Vérifie ce workflow GitHub Actions : les permissions des `GITHUB_TOKEN` sont-elles limitées au strict nécessaire ?

## Prompt 22
Ajoute une étape de 'Secret Scanning' dans mon pipeline pour bloquer tout commit contenant une clé privée.

## Prompt 23
Propose une étape de build qui génère une SBOM (Software Bill of Materials) pour mon application.

## Prompt 24
Comment implémenter une signature d'image (Cosign) pour garantir que seules mes images vérifiées sont déployées ?

## Prompt 25
Analyse ce pipeline : où devrais-je placer l'analyse statique (SAST) pour qu'elle ne ralentisse pas trop les développeurs ?

## Prompt 26
Configure une étape d'analyse dynamique (DAST) avec OWASP ZAP après le déploiement en environnement de staging.

## Prompt 27
Vérifie que le déploiement en production nécessite une approbation manuelle et des tests réussis à 100%.

## Prompt 28
Implémente une vérification de la validité des licences de mes dépendances (License Compliance).

## Prompt 29
Propose un système de 'Rollback' automatique si les tests de santé (Health Checks) échouent après un déploiement.

## Prompt 30
Comment sécuriser les 'Self-hosted Runners' pour éviter les attaques par injection de commande dans le CI ?

## Prompt 31
Comment implémenter un cache sécurisé dans le pipeline pour éviter les attaques par injection de dépendances ?

## Prompt 32
Analyse les tags de version : sont-ils correctement gérés et signés numériquement ?

## Prompt 33
Comment tracer chaque déploiement pour garantir la traçabilité complète des modifications ?

## Prompt 34
Vérifie si les artefacts de build sont stockés de manière sécurisée et signés.

## Prompt 35
Comment implémenter une vérification des signatures de code avant l'intégration dans le pipeline ?

## Prompt 36
Analyse les permissions des jobs CI/CD : sont-elles limitées au minimum requis ?

## Prompt 37
Propose une politique de nettoyage des artefacts obsolètes pour réduire la surface d'attaque.

## Prompt 38
Comment configurer des alertes en cas de modification non autorisée des workflows CI/CD ?

## Prompt 39
Analyse les logs du pipeline : sont-ils centralisés et protégés contre la modification ?

## Prompt 40
Comment implémenter un système de vérification des modifications de configuration avant déploiement ?