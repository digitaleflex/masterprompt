# 3. Sécurité des Containers & Infrastructure (IaC)

*Vérifier vos fichiers Docker, Kubernetes et Cloud.*

## 21. Trivy Container Scan
Scanne l'image Docker finale (OS + Libs).

```yaml
# .github/workflows/trivy-container-scan.yml
name: Trivy Container Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Build an image from Dockerfile
      run: |
        docker build -t trivy-scanned-image .
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'trivy-scanned-image'
        format: 'sarif'
        output: 'trivy-results.sarif'
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
```

## 22. Hadolint
Linter pour Dockerfile (évite de tourner en `root`).

```yaml
# .github/workflows/hadolint.yml
name: Hadolint

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  hadolint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run hadolint
      uses: hadolint/hadolint-action@v3.0.0
      with:
        dockerfile: Dockerfile
```

## 23. Dockle
Vérifie les bonnes pratiques de sécurité des images Docker.

```yaml
# .github/workflows/dockle.yml
name: Dockle Security Check

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  dockle:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run Dockle
      uses: goodwithtech/dockle-action@v0.4.10
      with:
        image: 'myapp:latest'
        exit-code: '1'
        format: 'sarif'
        output: 'dockle-results.sarif'
    - name: Upload Dockle scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'dockle-results.sarif'
```

## 24. Kube-score
Analyse les fichiers YAML Kubernetes (sécurité, réseau, ressources).

```yaml
# .github/workflows/kube-score.yml
name: Kube-score

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  kube-score:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Install kube-score
      run: |
        wget https://github.com/zegl/kube-score/releases/download/v1.17.0/kube-score_1.17.0_linux_amd64.tar.gz
        tar -xzf kube-score_1.17.0_linux_amd64.tar.gz
        sudo mv kube-score /usr/local/bin/
    - name: Run kube-score
      run: |
        kube-score score --output-format=ci --exit-one-on-violation k8s/
```

## 25. Checkov
Scanne Terraform, CloudFormation et K8s pour les mauvaises configurations.

```yaml
# .github/workflows/checkov.yml
name: Checkov IaC Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  checkov:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repo
      uses: actions/checkout@v4
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    - name: Install Checkov
      run: pip install checkov
    - name: Run Checkov scan
      uses: bridgecrewio/checkov-action@v12
      with:
        directory: .
        framework: all
        output_format: sarif
        output_file_path: results.sarif
    - name: Upload Checkov results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: results.sarif
```

## 26. Anchor Grype
Scanner de vulnérabilités rapide pour les systèmes de fichiers.

```yaml
# .github/workflows/grype.yml
name: Grype Vulnerability Scanner

on:
  push:
    branches: [ main, develop ]
  schedule:
    - cron: '0 0 * * 0'

jobs:
  grype:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run Grype
      uses: anchore/scan-action/grype-scan@v3
      with:
        fail-build: true
        severity-cutoff: high
```

## 27. Cloudsploit
Vérifie la sécurité de votre compte AWS/Azure via le pipeline. *(Nécessite `AWS_ACCESS_KEY`)*.

```yaml
# .github/workflows/cloudsploit.yml
name: Cloudsploit Security Scan

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  cloudsploit:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    - name: Run Cloudsploit
      run: |
        # Install Cloudsploit
        npm install cloudsploit
        # Run scan (requires AWS credentials)
        aws configure set aws_access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws configure set aws_secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws configure set region ${{ secrets.AWS_DEFAULT_REGION }}
        # Execute Cloudsploit scan
```

## 28. Infracost
Affiche le coût cloud de votre PR avant le déploiement.

```yaml
# .github/workflows/infracost.yml
name: Infracost

on:
  pull_request:
    branches: [ main ]

jobs:
  infracost:
    runs-on: ubuntu-latest
    steps:
    - name: Setup Infracost
      uses: infracost/actions/setup@v2
      with:
        api-key: ${{ secrets.INFRACOST_API_KEY }}
    - name: Run Infracost
      uses: infracost/actions/comment@v2
      with:
        path: .
        github-token: ${{ secrets.GITHUB_TOKEN }}
        behavior: update
```

## 29. Docker BuildX Attestation
Signe vos images Docker pour prouver leur origine.

```yaml
# .github/workflows/docker-attestation.yml
name: Docker BuildX Attestation

on:
  push:
    branches: [ main ]

jobs:
  docker-build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    - name: Login to DockerHub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: user/app:latest
        attests: type=sbom,generator=user/syft
        attests: type=provenance,backend=spdx
```

## 30. Cosign (Sigstore)
Signe numériquement vos images pour garantir l'intégrité.

```yaml
# .github/workflows/cosign.yml
name: Cosign Sign

on:
  push:
    tags: ['*']

jobs:
  sign:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    - name: Install Cosign
      uses: sigstore/cosign-installer@v3.4.0
    - name: Sign the published Docker image
      run: |
        cosign sign --key env://COSIGN_PRIVATE_KEY ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.ref_name }}
      env:
        COSIGN_PRIVATE_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
        COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
```