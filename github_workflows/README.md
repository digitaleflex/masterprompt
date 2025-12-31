# Documentation du dossier github_workflows

Ce dossier contient une collection de 50 workflows GitHub Actions spécialisés pour transformer un dépôt GitHub en infrastructure de niveau "Fortune 500".

## Structure

- `security/` - Workflows de sécurité du code et analyse statique (SAST)
- `supply_chain/` - Workflows de sécurité de la supply chain (SCA)
- `containers_infrastructure/` - Workflows de sécurité des containers et infrastructure (IaC)
- `resilience_dast/` - Workflows de tests de résilience et sécurité dynamique (DAST)
- `governance/` - Workflows de gouvernance, audit et maintenance
- `documentation/` - Documentation et configurations des secrets

## Utilisation

Chaque workflow est fourni avec sa configuration YAML, ses dépendances et ses instructions d'installation.

Pour utiliser un workflow :
1. Copiez le fichier YAML dans votre dossier `.github/workflows/`
2. Ajustez les paramètres selon vos besoins
3. Committez et poussez pour activer le workflow

## Exemple

```yaml
name: Security Scan
on: [push, pull_request]
jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run security scan
        run: |
          # Ajoutez ici votre scan de sécurité
```