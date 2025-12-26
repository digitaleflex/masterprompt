# GitHub Workflows DevSecOps - Suite complète de 50 workflows

Cette suite contient 50 workflows GitHub Actions spécialisés pour transformer un dépôt GitHub en infrastructure de niveau "Fortune 500".

## Catégories de workflows

1. [Sécurité du Code & Analyse Statique (SAST)](security/01_sast_workflows.md) - Workflows 1-10
2. [Sécurité de la Supply Chain (SCA)](supply_chain/02_sca_workflows.md) - Workflows 11-20
3. [Sécurité des Containers & Infrastructure (IaC)](containers_infrastructure/03_iac_workflows.md) - Workflows 21-30
4. [Tests de Résilience & DAST (Sécurité Dynamique)](resilience_dast/04_dast_workflows.md) - Workflows 31-40
5. [Gouvernance, Audit & Maintenance](governance/05_governance_workflows.md) - Workflows 41-50

## Documentation

- [Configuration des secrets](documentation/06_secret_configuration.md) - Instructions pour configurer les tokens et clés API

## Utilisation

Chaque workflow est fourni avec sa configuration YAML complète, ses dépendances et ses instructions d'installation. Copiez les fichiers de workflow dans le dossier `.github/workflows/` de votre dépôt pour activer les fonctionnalités.

## Prérequis

- Un dépôt GitHub public ou privé
- Les permissions appropriées pour configurer les workflows et les secrets
- Les tokens API pour les services tiers (SonarCloud, Snyk, etc.) selon vos besoins