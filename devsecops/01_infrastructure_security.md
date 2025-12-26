# 1. Sécurité de l'Infrastructure & Configuration (Prompts 1-20)

*Focus : Docker, Kubernetes, Secrets et Cloud.*

## Prompt 1
Analyse ce `Dockerfile`. Est-il optimisé pour la sécurité (utilisation d'utilisateurs non-root, images de base 'alpine' ou 'distroless') ?

## Prompt 2
Vérifie si des secrets (clés API, mots de passe) sont présents en clair dans les fichiers de configuration ou les variables d'environnement.

## Prompt 3
Génère une configuration `.dockerignore` pour éviter d'inclure des fichiers sensibles (comme `.git` ou `.env`) dans l'image.

## Prompt 4
Examine ce fichier `docker-compose.yml`. Les volumes et les ports exposés respectent-ils le principe du moindre privilège ?

## Prompt 5
Propose une stratégie de rotation automatique des secrets via HashiCorp Vault ou AWS Secrets Manager.

## Prompt 6
Vérifie si les images Docker sont scannées contre les vulnérabilités (ex: avec Trivy ou Snyk) dans le pipeline.

## Prompt 7
Analyse les permissions de ce fichier de configuration Kubernetes (RBAC). Y a-t-il des droits trop larges ?

## Prompt 8
Propose une politique réseau (Network Policy) Kubernetes pour isoler le backend du frontend.

## Prompt 9
Vérifie que les communications entre services utilisent mTLS (Mutual TLS).

## Prompt 10
Comment configurer un WAF (Web Application Firewall) pour protéger les routes API exposées ?

## Prompt 11
Analyse ce fichier Terraform. Y a-t-il des configurations de sécurité non optimales (ex: stockage non chiffré, accès public) ?

## Prompt 12
Vérifie si les instances cloud ont des rôles IAM trop permissifs (ex: accès complet à S3).

## Prompt 13
Propose une configuration de durcissement d'OS pour les instances EC2 ou GCE (ex: désactivation des services inutiles).

## Prompt 14
Analyse les certificats SSL/TLS : sont-ils correctement renouvelés et validés ?

## Prompt 15
Vérifie si les sauvegardes sont chiffrées et si les politiques de rétention sont conformes à la réglementation.

## Prompt 16
Comment configurer des politiques de gouvernance cloud (ex: Azure Policy, AWS Config) pour bloquer les configurations non conformes ?

## Prompt 17
Analyse les configurations de sécurité des buckets de stockage (S3, GCS) : sont-ils publics ou protégés ?

## Prompt 18
Vérifie si les conteneurs sont exécutés avec les droits minimums (ex: non-root, capabilities limitées).

## Prompt 19
Comment implémenter une politique de sécurité des images (Image Policy) dans Kubernetes ?

## Prompt 20
Analyse les configurations de pare-feu : sont-elles restrictives et correctement mises à jour ?