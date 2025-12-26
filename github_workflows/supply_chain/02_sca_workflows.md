# 2. Sécurité de la Supply Chain (SCA)

*Vérifier les failles dans les bibliothèques tierces (npm, pip, etc.).*

## 11. Dependabot Version Updates
Garde vos dépendances à jour automatiquement.

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
```

## 12. Dependabot Security Updates
Crée des PR immédiates en cas de faille critique (CVE).

```yaml
# .github/dependabot.yml (ajouter à la configuration précédente)
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 20
    # Prioritize security updates
    target-branch: "main"
    labels:
      - "security"
      - "dependencies"
```

## 13. npm Audit / Yarn Audit
Bloque la CI si une lib vulnérable est installée.

```yaml
# .github/workflows/npm-audit.yml
name: npm Audit

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  npm-audit:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Run npm audit
      run: npm audit --audit-level high
    - name: Run npm audit --json and generate report
      run: |
        npm audit --audit-level moderate --json > audit-report.json
        cat audit-report.json
```

## 14. Snyk Open Source Scan
Monitoring continu des vulnérabilités de dépendances. *(Nécessite `SNYK_TOKEN`)*.

```yaml
# .github/workflows/snyk-open-source.yml
name: Snyk Open Source Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'

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
        args: --fail-on=high
```

## 15. License Compliance
Bloque l'usage de libs avec des licences incompatibles (ex: GPL sans autorisation).

```yaml
# .github/workflows/license-compliance.yml
name: License Compliance Check

on:
  pull_request:
    branches: [ main ]

jobs:
  license-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Run license check
      run: npx license-checker --summary --production
    - name: Run OSADL check
      run: npx osadl-check
```

## 16. SBOM Generation (CycloneDX)
Génère un inventaire complet de tous vos composants logiciels.

```yaml
# .github/workflows/sbom-generation.yml
name: SBOM Generation

on:
  push:
    branches: [ main, develop ]

jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Install CycloneDX CLI
      run: npm install @cyclonedx/bom --save-dev
    - name: Generate SBOM
      run: npx @cyclonedx/bom -o bom.json
    - name: Upload SBOM
      uses: actions/upload-artifact@v4
      with:
        name: sbom
        path: bom.json
```

## 17. Dependency Review
Affiche les risques de sécurité directement dans les commentaires de Pull Request.

```yaml
# .github/workflows/dependency-review.yml
name: Dependency Review

on:
  pull_request:
    branches: [ main ]

permissions:
  contents: read
  pull-requests: write

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
    - name: Repository checkout
      uses: actions/checkout@v4
    - name: Dependency Review
      uses: actions/dependency-review-action@v4
      with:
        fail-on-severity: high
```

## 18. Verify Package Integrity
Vérifie les hashs (SHA) des paquets téléchargés.

```yaml
# .github/workflows/package-integrity.yml
name: Package Integrity Check

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  integrity-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Verify package integrity
      run: npm audit signatures
    - name: Verify package lockfile
      run: |
        npm audit --audit-level high
        npm ls
```

## 19. Step-Security/harden-runner
Empêche le pipeline de sortir vers des domaines inconnus (anti-exfiltration).

```yaml
# .github/workflows/harden-runner.yml
name: Harden Runner

on:
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Harden Runner
      uses: step-security/harden-runner@v2
      with:
        egress-policy: audit
    - name: Checkout code
      uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
```

## 20. Audit CI Scripts
Scanne les `scripts` dans `package.json` pour détecter des commandes malveillantes.

```yaml
# .github/workflows/audit-ci-scripts.yml
name: Audit CI Scripts

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  audit-scripts:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Audit package.json scripts
      run: |
        echo "Checking package.json scripts for potential security issues..."
        cat package.json | grep -i "script"
        # Add custom script validation logic here
        npm run build --dry-run || true
```