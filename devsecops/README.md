# Documentation du dossier devsecops

Ce dossier contient une suite complète de prompts spécialisés dans la sécurité du développement logiciel (DevSecOps).

## Structure

Le dossier est organisé en 6 catégories principales :

- **Sécurité de l'infrastructure & Configuration** - Docker, Kubernetes, Secrets et Cloud
- **Pipeline CI/CD Sécurisé** - GitHub Actions, GitLab CI, Automatisation
- **Gestion des Dépendances & Supply Chain** - npm, yarn, vulnérabilités tierces
- **Monitoring, Logs & Observabilité** - Détection d'incidents et réponse
- **Gouvernance & Compliance Code** - Standards de l'entreprise et législation
- **Tests de Résilience & Chaos Engineering** - Fiabilité sous pression

## Utilisation

Chaque fichier contient des prompts spécialisés que vous pouvez utiliser pour :
- Analyser votre infrastructure
- Sécuriser vos pipelines CI/CD
- Gérer vos dépendances de manière sécurisée
- Mettre en place une observabilité efficace
- Assurer la gouvernance de votre code
- Tester la résilience de vos systèmes

## Exemple d'utilisation

```bash
# Utilisez les prompts pour auditer votre Dockerfile
cat devsecops/01_infrastructure_security.md | grep "Analyse ce Dockerfile"
```