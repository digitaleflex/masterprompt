# 4. Tests de Résilience & DAST (Sécurité Dynamique)

*Tester l'application pendant qu'elle tourne.*

## 31. OWASP ZAP Scan
Scan de pénétration automatique sur votre URL de staging.

```yaml
# .github/workflows/owasp-zap-scan.yml
name: OWASP ZAP Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  zap-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    - name: Run ZAP Scan
      uses: zaproxy/action-full-scan@v0.8.0
      with:
        target: 'https://staging.myapp.com'
        rules_file_name: '.zap/rules.tsv'
        cmd_options: '-a -d'
```

## 32. Mozilla Observatory Scan
Vérifie les headers HTTP (CSP, HSTS) de votre site en ligne.

```yaml
# .github/workflows/observatory-scan.yml
name: Mozilla Observatory Scan

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  observatory-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Run Observatory scan
      run: |
        curl -s "https://observatory.mozilla.org/api/v1/analyze?host=staging.myapp.com" | jq
        # Add logic to check score and fail if below threshold
```

## 33. Lighthouse CI
Audit de performance, SEO et accessibilité à chaque build.

```yaml
# .github/workflows/lighthouse-ci.yml
name: Lighthouse CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install Lighthouse CI
      run: npm install -g @lhci/cli@0.11.x
    - name: Run Lighthouse CI
      run: |
        lhci autorun
      env:
        LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

## 34. Artillery / K6 Load Test
Test de charge pour vérifier si l'app résiste aux attaques DoS.

```yaml
# .github/workflows/load-test.yml
name: Load Test

on:
  push:
    branches: [ main, develop ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install Artillery
      run: npm install -g artillery
    - name: Run Load Test
      run: |
        artillery run load-test.yml --target https://staging.myapp.com
      env:
        TARGET_URL: https://staging.myapp.com
```

## 35. Cypress/Playwright E2E Security
Tests simulant des injections de scripts dans les formulaires.

```yaml
# .github/workflows/e2e-security-test.yml
name: E2E Security Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  e2e-security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm install
    - name: Install Playwright
      run: npx playwright install --with-deps
    - name: Run E2E Security Tests
      run: npm run test:e2e:security
    - name: Upload test results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: playwright-report
        path: playwright-report/
        retention-days: 30
```

## 36. SSL Labs Audit
Vérifie la validité et la force de vos certificats SSL.

```yaml
# .github/workflows/ssl-labs-audit.yml
name: SSL Labs Audit

on:
  schedule:
    - cron: '0 0 1 * *'  # Monthly
  workflow_dispatch:

jobs:
  ssl-audit:
    runs-on: ubuntu-latest
    steps:
    - name: Run SSL Labs Test
      run: |
        curl -s "https://api.ssllabs.com/api/v3/analyze?host=staging.myapp.com&all=done" | jq
        # Add logic to check grade and fail if below threshold
```

## 37. Broken Link Checker
Évite que des liens morts ne mènent vers des domaines rachetés par des hackers.

```yaml
# .github/workflows/broken-link-check.yml
name: Broken Link Check

on:
  push:
    branches: [ main, develop ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  link-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Link Checker
      uses: lycheeverse/lychee-action@v1.9.0
      with:
        args: "*.md"
        fail: true
```

## 38. API Security Test (Postman/Newman)
Vérifie que les routes privées renvoient bien 401/403.

```yaml
# .github/workflows/api-security-test.yml
name: API Security Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  api-security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    - name: Install Newman
      run: npm install -g newman
    - name: Run API Security Tests
      run: |
        newman run security-tests.postman_collection.json \
          --environment staging.postman_environment.json \
          --reporters cli,junit \
          --reporter-junit-export newman-results.xml
    - name: Upload test results
      uses: actions/upload-artifact@v4
      with:
        name: api-test-results
        path: newman-results.xml
```

## 39. Chaos Mesh (K8s)
Simule des pannes de réseau dans votre environnement de test.

```yaml
# .github/workflows/chaos-mesh.yml
name: Chaos Mesh Testing

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  chaos-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Install kubectl
      uses: azure/setup-kubectl@v3
    - name: Run Chaos Tests
      run: |
        # Install Chaos Mesh
        kubectl apply -f https://github.com/chaos-mesh/chaos-mesh/releases/latest/download/chaos-mesh.yaml
        # Apply chaos experiments
        kubectl apply -f chaos-experiments/
```

## 40. Smoke Tests
Vérification ultra-rapide post-déploiement pour confirmer la stabilité.

```yaml
# .github/workflows/smoke-tests.yml
name: Smoke Tests

on:
  push:
    branches: [ main, develop ]

jobs:
  smoke-test:
    runs-on: ubuntu-latest
    steps:
    - name: Wait for deployment
      run: sleep 60  # Wait for deployment to complete
    - name: Run smoke tests
      run: |
        # Simple health check
        curl -f https://staging.myapp.com/health || exit 1
        # Check key endpoints
        curl -f https://staging.myapp.com/api/status || exit 1
        echo "Smoke tests passed!"
```