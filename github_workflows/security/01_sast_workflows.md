# 1. Sécurité du Code & Analyse Statique (SAST)

*Vérifier les failles dans votre propre logiciel de code.*

## 1. CodeQL Analysis
Analyse sémantique de GitHub pour trouver les failles de sécurité courantes.

```yaml
# .github/workflows/codeql-analysis.yml
name: "CodeQL Analysis"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript', 'python', 'java', 'cpp' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
```

## 2. SonarCloud Scan
Mesure la qualité, les bugs et les "security hotspots". *(Nécessite `SONAR_TOKEN`)*.

```yaml
# .github/workflows/sonarcloud-analysis.yml
name: SonarCloud Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  sonarcloud:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

## 3. ESLint Security Rules
Utilise `eslint-plugin-security` pour détecter les patterns dangereux.

```yaml
# .github/workflows/eslint-security.yml
name: ESLint Security Check

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm install
    - name: Install security plugin
      run: npm install eslint-plugin-security --save-dev
    - name: Run ESLint with security rules
      run: npx eslint . --ext .js,.jsx,.ts,.tsx --max-warnings 0
```

## 4. Husky Pre-commit Shield
Empêche le push si les tests de sécurité locaux échouent.

```yaml
# .github/workflows/husky-precommit.yml
name: Husky Pre-commit Check

on:
  pull_request:
    branches: [ main ]

jobs:
  precommit:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm install
    - name: Run pre-commit hooks
      run: npx lint-staged
```

## 5. Gitleaks/TruffleHog
Scan chaque commit pour détecter des clés API ou mots de passe oubliés.

```yaml
# .github/workflows/secret-scanning.yml
name: Secret Scanning

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - name: Gitleaks
      uses: gitleaks/gitleaks-action@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }}
```

## 6. Semgrep OSS
Analyse statique ultra-rapide pour détecter les vulnérabilités logiques.

```yaml
# .github/workflows/semgrep.yml
name: Semgrep Analysis

on:
  pull_request:
    branches: [ main ]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    container:
      image: returntocorp/semgrep
    steps:
    - uses: actions/checkout@v4
    - run: semgrep ci
      env:
        SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_TOKEN }}
```

## 7. Checkmarx/Snyk Code
Analyse de code propriétaire pour la conformité entreprise.

```yaml
# .github/workflows/snyk-code-analysis.yml
name: Snyk Code Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  snyk:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --sarif-file-output=snyk.sarif
    - name: Upload result to GitHub Code Scanning
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: snyk.sarif
```

## 8. Secret Linting
Vérifie que les fichiers `.env.example` ne contiennent pas de vraies données.

```yaml
# .github/workflows/secret-lint.yml
name: Secret Linting

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  secret-lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Secret Lint
      uses: secretlint/action-secretlint@v1
      with:
        config: .secretlintrc.json
```

## 9. OWASP Dependency Check
Vérifie si votre code appelle des fonctions dépréciées ou risquées.

```yaml
# .github/workflows/dependency-check.yml
name: OWASP Dependency Check

on:
  push:
    branches: [ main, develop ]
  schedule:
    - cron: '0 0 * * 0'

jobs:
  dependency-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: OWASP Dependency Check
      uses: dependency-check/dependency-check-github-action@v2
      with:
        project: 'My Project'
        path: '.'
        format: 'JUNIT'
    - name: Publish Test Results
      uses: EnricoMi/publish-unit-test-result-action@v2
      with:
        files: "**/target/test-results/**/*.xml"
```

## 10. Terrascan/Tfsec
Si vous avez du Terraform, scanne les erreurs de config cloud.

```yaml
# .github/workflows/terraform-security.yml
name: Terraform Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  tfsec:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Terraform Security Scan
      uses: tfsec/tfsec-github-action@v0.0.4
      with:
        soft_fail: false
        github_token: ${{ secrets.GITHUB_TOKEN }}
    - name: Upload SARIF file
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: tfsec.sarif
```