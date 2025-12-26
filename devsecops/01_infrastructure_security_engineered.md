# 1. Sécurité de l'Infrastructure & Configuration (Prompts 1-20) - Version Ingénierie des Prompts

*Focus : Docker, Kubernetes, Secrets et Cloud.*

## Prompt 1
En tant qu'expert en sécurité DevOps, analyse le fichier Dockerfile suivant pour évaluer sa sécurité.
Vérifie spécifiquement :
- L'utilisation d'utilisateurs non-root (utilisation de USER ou d'un utilisateur spécifique)
- Le choix d'images de base sécurisées (alpine, distroless, ou autres images minimales)
- Les permissions et droits d'accès accordés au conteneur
- Les bonnes pratiques de sécurité Docker

Format de réponse : 
1. Points de sécurité identifiés
2. Vulnérabilités potentielles
3. Recommandations concrètes pour améliorer la sécurité
4. Priorisation des correctifs

## Prompt 2
En tant qu'expert en sécurité, examine le code et les fichiers de configuration suivants pour détecter la présence de secrets en clair.
Recherche spécifiquement :
- Clés API
- Mots de passe
- Jetons d'accès
- Identifiants de base de données
- Clés privées

Format de réponse :
1. Liste des secrets trouvés avec leur emplacement
2. Niveau de criticité pour chaque secret découvert
3. Recommandations pour remplacer les secrets en clair
4. Méthodes de gestion sécurisée des secrets à implémenter

## Prompt 3
En tant qu'expert en sécurité de conteneurs, génère un fichier `.dockerignore` sécurisé pour une application.
Le fichier doit exclure :
- Fichiers de configuration sensibles
- Fichiers de développement
- Historique Git
- Variables d'environnement
- Fichiers de log

Format de réponse :
1. Contenu du fichier `.dockerignore` avec commentaires
2. Explication des motifs exclus
3. Recommandations pour personnaliser selon le type d'application

## Prompt 4
En tant qu'expert en sécurité de conteneurs, analyse le fichier `docker-compose.yml` suivant.
Évalue spécifiquement :
- Les volumes montés et leurs permissions
- Les ports exposés publiquement
- Les variables d'environnement
- Les configurations de réseau
- Les droits d'exécution des services

Format de réponse :
1. Analyse des configurations critiques
2. Recommandations pour appliquer le principe du moindre privilège
3. Correctifs de sécurité prioritaires

## Prompt 5
En tant qu'expert en gestion des secrets, propose une stratégie de rotation automatique des secrets.
Considère spécifiquement :
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- GCP Secret Manager

Format de réponse :
1. Architecture recommandée pour la gestion des secrets
2. Processus de rotation automatique
3. Intégration avec les pipelines CI/CD
4. Gestion des cas d'urgence

## Prompt 6
En tant qu'expert en sécurité des conteneurs, vérifie si les images Docker sont scannées contre les vulnérabilités.
Analyse spécifiquement :
- Intégration de scanners (Trivy, Snyk, Clair)
- Politiques de blocage des images vulnérables
- Processus d'analyse dans le pipeline CI/CD

Format de réponse :
1. Évaluation de l'actuelle stratégie de scan
2. Recommandations pour améliorer la détection
3. Intégration dans les workflows CI/CD
4. Processus de réponse aux vulnérabilités détectées

## Prompt 7
En tant qu'expert en sécurité Kubernetes, analyse les permissions du fichier de configuration RBAC suivant.
Vérifie spécifiquement :
- Les droits accordés aux rôles
- Les principes du moindre privilège
- Les abus potentiels de permissions
- Les violations des bonnes pratiques de sécurité

Format de réponse :
1. Analyse détaillée des droits excessifs
2. Recommandations de réduction des privilèges
3. Politiques RBAC sécurisées à implémenter
4. Contrôles de sécurité à renforcer

## Prompt 8
En tant qu'expert en sécurité réseau Kubernetes, propose une politique réseau (Network Policy) pour isoler les services backend et frontend.
Considère spécifiquement :
- Les flux de communication autorisés
- Les ports à restreindre
- Les namespaces à isoler
- Les bonnes pratiques de micro-segmentation

Format de réponse :
1. Configuration de la Network Policy
2. Explication des règles de sécurité
3. Recommandations pour l'implémentation
4. Tests de validation de l'isolation

## Prompt 9
En tant qu'expert en sécurité des communications, vérifie si les communications entre services utilisent mTLS (Mutual TLS).
Analyse spécifiquement :
- Les configurations TLS
- Les certificats et leur gestion
- L'authentification mutuelle
- Les points de vulnérabilité potentiels

Format de réponse :
1. Évaluation de l'implémentation actuelle
2. Recommandations pour implémenter mTLS
3. Outils et solutions disponibles
4. Processus de déploiement sécurisé

## Prompt 10
En tant qu'expert en sécurité des applications web, explique comment configurer un WAF (Web Application Firewall) pour protéger les routes API exposées.
Considère spécifiquement :
- Les types de menaces à bloquer
- Les règles de filtrage
- L'intégration avec les services existants
- Les impacts sur les performances

Format de réponse :
1. Architecture recommandée pour le WAF
2. Règles de protection spécifiques pour les APIs
3. Processus d'implémentation
4. Surveillance et ajustement des règles