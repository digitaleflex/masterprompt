# 5. Gouvernance, Audit & Maintenance

*Gérer le cycle de vie du projet proprement.*

## 41. Auto-Labeler
Ajoute des labels `security` ou `bug` automatiquement selon le code modifié.

```yaml
# .github/workflows/auto-labeler.yml
name: Auto Labeler

on:
  pull_request:
    types: [opened, edited]

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/labeler@v4
      with:
        repo-token: "${{ secrets.GITHUB_TOKEN }}"
        configuration-path: .github/labeler.yml
```

```yaml
# .github/labeler.yml
security:
  - changed-files:
      - any-glob-to-any-file: ['**/security/**', '**/auth/**', '**/crypto/**']

bug:
  - changed-files:
      - any-glob-to-any-file: ['**/fix/**', '**/bug/**']

documentation:
  - changed-files:
      - any-glob-to-any-file: ['**/*.md', '**/*.txt']

frontend:
  - changed-files:
      - any-glob-to-any-file: ['**/*.js', '**/*.jsx', '**/*.tsx', '**/*.ts']

backend:
  - changed-files:
      - any-glob-to-any-file: ['**/server/**', '**/api/**', '**/*.py', '**/*.java']
```

## 42. Stale Probot
Ferme les tickets/PR abandonnés pour réduire la surface de désordre.

```yaml
# .github/workflows/stale.yml
name: Close Stale Issues

on:
  schedule:
    - cron: '30 1 * * *'  # Daily at 01:30 UTC

jobs:
  stale:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/stale@v8
      with:
        repo-token: ${{ secrets.GITHUB_TOKEN }}
        stale-issue-message: 'This issue is stale because it has been open 30 days with no activity. Remove stale label or comment or this will be closed in 5 days.'
        stale-pr-message: 'This PR is stale because it has been open 45 days with no activity. Remove stale label or comment or this will be closed in 10 days.'
        stale-issue-label: 'no-issue-activity'
        stale-pr-label: 'no-pr-activity'
        days-before-stale: 30
        days-before-close: 5
```

## 43. Release Drafter
Génère automatiquement des changelogs incluant les fix de sécurité.

```yaml
# .github/workflows/release-drafter.yml
name: Release Drafter

on:
  push:
    branches:
      - main

jobs:
  update_release_draft:
    runs-on: ubuntu-latest
    steps:
      - uses: release-drafter/release-drafter@v5
        with:
          config-name: release-drafter.yml
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```yaml
# .github/release-drafter.yml
name-template: 'v$RESOLVED_VERSION'
tag-template: 'v$RESOLVED_VERSION'
categories:
  - title: '🚀 Features'
    labels:
      - 'feature'
      - 'enhancement'
  - title: '🐛 Bug Fixes'
    labels:
      - 'fix'
      - 'bugfix'
      - 'bug'
  - title: '🔒 Security Fixes'
    labels:
      - 'security'
  - title: '🧰 Maintenance'
    label: 'chore'
change-template: '- $TITLE @$AUTHOR (#$NUMBER)'
change-title-escapes: '\<*_&' # You can add # and @ to disable mentions, and add ` to disable code blocks.
version-resolver:
  major:
    labels:
      - 'major'
  minor:
    labels:
      - 'minor'
  patch:
    labels:
      - 'patch'
  default: patch
template: |
  ## Changes in this release

  $CHANGES
```

## 44. Contributor Audit
Vérifie que les contributeurs ont activé la 2FA (Double Authentification).

```yaml
# .github/workflows/contributor-audit.yml
name: Contributor 2FA Audit

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  contributor-audit:
    runs-on: ubuntu-latest
    steps:
    - name: Check 2FA Status
      run: |
        # This would require a custom script or GitHub API calls
        # to check 2FA status of contributors
        echo "Checking 2FA status of contributors..."
        # Implementation would require GitHub API calls
```

## 45. Branch Protection Enforcer
Vérifie que les règles de branche (code review obligatoire) sont actives.

```yaml
# .github/workflows/branch-protection.yml
name: Branch Protection Check

on:
  pull_request:
    branches: [ main ]

jobs:
  branch-protection:
    runs-on: ubuntu-latest
    steps:
    - name: Check branch protection rules
      uses:imsnif/branch-protection-check-action@v1.0.2
      with:
        repo-token: ${{ secrets.GITHUB_TOKEN }}
```

## 46. Compliance Report
Compile tous les résultats de scan dans un PDF d'audit.

```yaml
# .github/workflows/compliance-report.yml
name: Compliance Report

on:
  schedule:
    - cron: '0 0 1 * *'  # Monthly
  workflow_dispatch:

jobs:
  compliance-report:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Generate Compliance Report
      run: |
        # Collect results from various scans
        mkdir -p reports
        # This would collect data from CodeQL, Snyk, Trivy, etc.
        echo "Collecting security scan results..." > reports/compliance-report.txt
        # Add logic to gather results from different tools
        # and format them into a comprehensive report
```

## 47. Automated Rollback
Workflow qui revient à la version précédente si les alertes explosent.

```yaml
# .github/workflows/automated-rollback.yml
name: Automated Rollback

on:
  repository_dispatch:
    types: [rollback-trigger]

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    - name: Get previous tag
      run: |
        PREVIOUS_TAG=$(git describe --tags --abbrev=0 $(git describe --tags --abbrev=0)^)
        echo "PREVIOUS_TAG=$PREVIOUS_TAG" >> $GITHUB_ENV
    - name: Deploy previous version
      run: |
        # Deploy previous version based on tag
        # Implementation depends on your deployment system
        echo "Rolling back to $PREVIOUS_TAG"
```

## 48. GitHub Pages Security
Scanne les sites statiques hébergés sur le dépôt.

```yaml
# .github/workflows/pages-security.yml
name: GitHub Pages Security Scan

on:
  push:
    branches: [ gh-pages ]
  pull_request:
    branches: [ gh-pages ]

jobs:
  pages-security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run security scan on static site
      run: |
        # Use a tool like Lighthouse or custom script to scan static site
        echo "Scanning GitHub Pages for security issues..."
        # Add security scanning logic for static content
```

## 49. Action Lint
Scanne vos propres fichiers de workflow GitHub pour détecter des failles de logique.

```yaml
# .github/workflows/action-lint.yml
name: Action Lint

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  action-lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.19'
    - name: Install actionlint
      run: go install github.com/rhysd/actionlint/cmd/actionlint@latest
    - name: Run actionlint
      run: actionlint -color
```

## 50. Project Health Scorecard
Calcule le score de sécurité global selon les critères OpenSSF.

```yaml
# .github/workflows/ossf-scorecard.yml
name: OSSF Scorecard Analysis

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

permissions: read-all

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      id-token: write

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        persist-credentials: false

    - name: Run analysis
      uses: ossf/scorecard-action@v2.4.0
      with:
        results_file: results.sarif
        results_format: sarif
        publish_results: true

    - name: Upload artifact
      uses: actions/upload-artifact@v4
      with:
        name: SARIF file
        path: results.sarif
        retention-days: 5

    - name: Upload to code scanning
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: results.sarif
```