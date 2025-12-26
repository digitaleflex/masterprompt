# Documentation : Configuration des Secrets

Pour que ces workflows fonctionnent, vous devez aller dans **Settings > Secrets and variables > Actions** de votre dépôt GitHub et ajouter les clés suivantes :

## Liste des Clés API à compléter :

| Secret Name | Utilité | Source |
| --- | --- | --- |
| `SONAR_TOKEN` | Analyse de code poussée | [sonarcloud.io](https://sonarcloud.io) |
| `SNYK_TOKEN` | Scan de vulnérabilités | [snyk.io](https://snyk.io) |
| `GITHUB_TOKEN` | (Auto-généré) | Déjà présent par défaut |
| `DOCKER_PASSWORD` | Pour push vos images | DockerHub / GHCR |
| `SLACK_WEBHOOK` | Alertes de sécurité sur Slack | Slack Apps |
| `AWS_OIDC_ROLE_ARN` | Déploiement Cloud sans mot de passe | AWS IAM (Recommandé) |
| `SENTRY_DSN` | Monitoring d'erreurs | [sentry.io](https://sentry.io) |

## Instructions pour configurer les secrets :

1. Allez dans votre dépôt GitHub
2. Cliquez sur l'onglet "Settings"
3. Dans le menu de gauche, sélectionnez "Secrets and variables" > "Actions"
4. Cliquez sur "New repository secret"
5. Entrez le nom du secret (ex: `SONAR_TOKEN`)
6. Collez la valeur du token
7. Cliquez sur "Add secret"

Répétez pour chaque secret requis par vos workflows.

## Exemple de documentation pour votre équipe (README_SECURITY.md)

> "Chaque Pull Request doit passer le 'Security Gate'. Si l'un des workflows de la catégorie 1 ou 2 échoue, le bouton 'Merge' est bloqué. Les vulnérabilités 'High' et 'Critical' doivent être corrigées sous 24h."