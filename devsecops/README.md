# DevSecOps Prompt Suite - 100 Prompts pour une forteresse automatisée

Cette suite de prompts vise à transformer votre pipeline de développement en une forteresse automatisée, en intégrant la sécurité à chaque étape du cycle de vie logicielle (CI/CD).

## 1. Sécurité de l'Infrastructure & Configuration (20 Prompts)

*Focus : Docker, Kubernetes, Secrets et Cloud.*

1. "Analyse ce `Dockerfile`. Est-il optimisé pour la sécurité (utilisation d'utilisateurs non-root, images de base 'alpine' ou 'distroless') ?"

2. "Vérifie si des secrets (clés API, mots de passe) sont présents en clair dans les fichiers de configuration ou les variables d'environnement."

3. "Génère une configuration `.dockerignore` pour éviter d'inclure des fichiers sensibles (comme `.git` ou `.env`) dans l'image."

4. "Examine ce fichier `docker-compose.yml`. Les volumes et les ports exposés respectent-ils le principe du moindre privilège ?"

5. "Propose une stratégie de rotation automatique des secrets via HashiCorp Vault ou AWS Secrets Manager."

6. "Vérifie si les images Docker sont scannées contre les vulnérabilités (ex: avec Trivy ou Snyk) dans le pipeline."

7. "Analyse les permissions de ce fichier de configuration Kubernetes (RBAC). Y a-t-il des droits trop larges ?"

8. "Propose une politique réseau (Network Policy) Kubernetes pour isoler le backend du frontend."

9. "Vérifie que les communications entre services utilisent mTLS (Mutual TLS)."

10. "Comment configurer un WAF (Web Application Firewall) pour protéger les routes API exposées ?"

11. "Analyse ce fichier Terraform. Y a-t-il des configurations de sécurité non optimales (ex: stockage non chiffré, accès public) ?"

12. "Vérifie si les instances cloud ont des rôles IAM trop permissifs (ex: accès complet à S3)."

13. "Propose une configuration de durcissement d'OS pour les instances EC2 ou GCE (ex: désactivation des services inutiles)."

14. "Analyse les certificats SSL/TLS : sont-ils correctement renouvelés et validés ?"

15. "Vérifie si les sauvegardes sont chiffrées et si les politiques de rétention sont conformes à la réglementation."

16. "Comment configurer des politiques de gouvernance cloud (ex: Azure Policy, AWS Config) pour bloquer les configurations non conformes ?"

17. "Analyse les configurations de sécurité des buckets de stockage (S3, GCS) : sont-ils publics ou protégés ?"

18. "Vérifie si les conteneurs sont exécutés avec les droits minimums (ex: non-root, capabilities limitées)."

19. "Comment implémenter une politique de sécurité des images (Image Policy) dans Kubernetes ?"

20. "Analyse les configurations de pare-feu : sont-elles restrictives et correctement mises à jour ?"

## 2. Pipeline CI/CD Sécurisé (20 Prompts)

*Focus : GitHub Actions, GitLab CI, Automatisation.*

21. "Vérifie ce workflow GitHub Actions : les permissions des `GITHUB_TOKEN` sont-elles limitées au strict nécessaire ?"

22. "Ajoute une étape de 'Secret Scanning' dans mon pipeline pour bloquer tout commit contenant une clé privée."

23. "Propose une étape de build qui génère une SBOM (Software Bill of Materials) pour mon application."

24. "Comment implémenter une signature d'image (Cosign) pour garantir que seules mes images vérifiées sont déployées ?"

25. "Analyse ce pipeline : où devrais-je placer l'analyse statique (SAST) pour qu'elle ne ralentisse pas trop les développeurs ?"

26. "Configure une étape d'analyse dynamique (DAST) avec OWASP ZAP après le déploiement en environnement de staging."

27. "Vérifie que le déploiement en production nécessite une approbation manuelle et des tests réussis à 100%."

28. "Implémente une vérification de la validité des licences de mes dépendances (License Compliance)."

29. "Propose un système de 'Rollback' automatique si les tests de santé (Health Checks) échouent après un déploiement."

30. "Comment sécuriser les 'Self-hosted Runners' pour éviter les attaques par injection de commande dans le CI ?"

31. "Comment implémenter un cache sécurisé dans le pipeline pour éviter les attaques par injection de dépendances ?"

32. "Analyse les tags de version : sont-ils correctement gérés et signés numériquement ?"

33. "Comment tracer chaque déploiement pour garantir la traçabilité complète des modifications ?"

34. "Vérifie si les artefacts de build sont stockés de manière sécurisée et signés."

35. "Comment implémenter une vérification des signatures de code avant l'intégration dans le pipeline ?"

36. "Analyse les permissions des jobs CI/CD : sont-elles limitées au minimum requis ?"

37. "Propose une politique de nettoyage des artefacts obsolètes pour réduire la surface d'attaque."

38. "Comment configurer des alertes en cas de modification non autorisée des workflows CI/CD ?"

39. "Analyse les logs du pipeline : sont-ils centralisés et protégés contre la modification ?"

40. "Comment implémenter un système de vérification des modifications de configuration avant déploiement ?"

## 3. Gestion des Dépendances & Supply Chain (15 Prompts)

*Focus : npm, yarn, vulnérabilités tierces.*

41. "Analyse mon `package-lock.json`. Y a-t-il des dépendances 'fantômes' ou non épinglées à des versions fixes ?"

42. "Configure un bot (Renovate ou Dependabot) pour mettre à jour les dépendances, mais avec un filtrage sur les versions majeures."

43. "Vérifie si mon projet est vulnérable aux attaques de 'Dependency Confusion' (registres publics vs privés)."

44. "Propose une méthode pour auditer les dépendances indirectes (transitives) qui ne sont pas listées dans mon `package.json`."

45. "Comment mettre en place un miroir local ou un proxy (Artifactory) pour contrôler les paquets externes ?"

46. "Analyse les checksums des dépendances : sont-ils vérifiés avant l'installation ?"

47. "Vérifie si les scripts de post-installation sont sécurisés et ne contiennent pas de code malveillant."

48. "Comment détecter les dépendances non maintenues ou abandonnées dans mon projet ?"

49. "Analyse les licences des dépendances : sont-elles conformes à la politique de l'entreprise ?"

50. "Comment vérifier l'intégrité des dépendances via des signatures ou des hashes connus ?"

51. "Analyse les dépendances de développement : sont-elles correctement séparées des dépendances de production ?"

52. "Vérifie si les dépendances sont installées dans un environnement isolé pour éviter les conflits."

53. "Comment détecter les dépendances avec des vulnérabilités connues (ex: via npm audit) ?"

54. "Analyse les sources des dépendances : sont-elles fiables et provenant de registres approuvés ?"

55. "Comment implémenter une politique de blocage automatique des dépendances non approuvées ?"

## 4. Monitoring, Logs & Observabilité (15 Prompts)

*Focus : Détection d'incidents et réponse.*

56. "Analyse la structure de mes logs. Sont-ils conformes au RGPD (anonymisation des IPs et emails) ?"

57. "Propose des alertes critiques basées sur le taux d'erreur 5xx et les tentatives de login échouées."

58. "Comment centraliser les logs de sécurité pour qu'ils soient immuables (non modifiables par un attaquant) ?"

59. "Génère un tableau de bord Grafana pour surveiller les métriques de sécurité en temps réel (ex: tentatives d'injection SQL)."

60. "Implémente un système de tracing (OpenTelemetry) pour suivre une requête suspecte à travers tous les microservices."

61. "Analyse les métriques de performance : comment détecter les anomalies qui pourraient indiquer une attaque ?"

62. "Comment implémenter un système de journalisation (audit trail) pour toutes les actions critiques ?"

63. "Vérifie si les logs contiennent des informations sensibles qui devraient être masquées."

64. "Propose une stratégie de rotation et de rétention des logs conformes aux réglementations."

65. "Comment configurer des alertes pour détecter les tentatives de brute force ?"

66. "Analyse les logs d'accès : comment détecter les accès suspects ou non autorisés ?"

67. "Comment implémenter un système de corrélation d'événements pour détecter des attaques complexes ?"

68. "Vérifie si les logs sont chiffrés pendant le transport et le stockage."

69. "Comment surveiller les ressources système pour détecter des comportements anormaux ?"

70. "Analyse les logs réseau : comment détecter des communications suspectes vers l'extérieur ?"

## 5. Gouvernance & Compliance Code (15 Prompts)

*Focus : Standards de l'entreprise et législation.*

71. "Vérifie si le code respecte les standards OWASP Top 10. Génère un rapport de conformité."

72. "Ajoute des hooks de pré-commit pour forcer l'exécution de `npm audit` avant chaque push."

73. "Comment automatiser la création d'un rapport de conformité pour un audit SOC2 ou ISO 27001 ?"

74. "Analyse si les données de santé ou bancaires sont chiffrées au repos (Encryption at Rest) dans ce schéma de base de données."

75. "Propose une politique de rétention des données conforme au RGPD (suppression auto après X temps)."

76. "Analyse les politiques d'accès aux données : sont-elles conformes au principe du moindre privilège ?"

77. "Comment implémenter des revues de code obligatoires pour les modifications critiques ?"

78. "Vérifie si les documents de sécurité sont à jour et facilement accessibles aux développeurs."

79. "Comment automatiser la vérification des licences open source dans le code ?"

80. "Analyse les processus de gestion des incidents : sont-ils documentés et testés régulièrement ?"

81. "Comment implémenter un système de gestion des vulnérabilités (Vulnerability Management) ?"

82. "Vérifie si les politiques de sécurité sont intégrées dans les outils de développement."

83. "Comment automatiser la vérification des standards de codage (ex: via ESLint, SonarQube) ?"

84. "Analyse les processus de gestion des changements : sont-ils conformes aux bonnes pratiques ?"

85. "Comment implémenter une documentation de sécurité intégrée au code (ex: README de sécurité) ?"

## 6. Tests de Résilience & Chaos Engineering (15 Prompts)

*Focus : Fiabilité sous pression.*

86. "Propose un scénario de 'Chaos Engineering' pour tester comment l'application réagit si la base de données devient inaccessible."

87. "Simule une attaque DoS sur ce service : à quel point le système d'auto-scaling réagit-il ?"

88. "Vérifie la robustesse de la gestion d'erreurs : l'application plante-t-elle si un service tiers renvoie un JSON malformé ?"

89. "Comment tester la procédure de Disaster Recovery (reprise après sinistre) de manière automatisée ?"

90. "Génère un test de charge pour identifier le point de rupture des connexions simultanées à l'API."

91. "Analyse la tolérance aux pannes : comment le système réagit-il à la perte d'un nœud ?"

92. "Comment tester le mécanisme de basculement (failover) entre les environnements de production ?"

93. "Vérifie la robustesse face à des latences réseau élevées ou des coupures temporaires."

94. "Comment simuler la perte de données pour tester les processus de restauration ?"

95. "Analyse la résilience face à des attaques par déni de service (DoS/DDoS)."

96. "Comment tester la récupération après une attaque de cryptomalware ou ransomware ?"

97. "Vérifie la capacité de l'application à gérer des volumes de données anormalement élevés."

98. "Comment simuler la perte d'un service tiers critique (ex: authentification, paiement) ?"

99. "Analyse la capacité de l'application à fonctionner en mode dégradé sans perdre de données critiques."

100. "Comment implémenter des tests de résilience automatiques dans le pipeline CI/CD ?"