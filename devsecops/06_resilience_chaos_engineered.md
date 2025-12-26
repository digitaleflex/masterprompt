# 6. Tests de Résilience & Chaos Engineering (Prompts 86-100) - Version Ingénierie des Prompts

*Focus : Fiabilité sous pression.*

## Prompt 86
En tant qu'expert en Chaos Engineering, propose un scénario de 'Chaos Engineering' pour tester comment l'application réagit si la base de données devient inaccessible.
Considère spécifiquement :
- Les composants critiques
- Les points de défaillance
- Les mécanismes de tolérance
- Les indicateurs de performance

Format de réponse :
1. Scénario de Chaos Engineering détaillé
2. Méthodologie de test
3. Indicateurs de performance à surveiller
4. Processus de validation et de sécurité

## Prompt 87
En tant qu'expert en tests de charge, simule une attaque DoS sur le service pour évaluer la réaction du système d'auto-scaling.
Analyse spécifiquement :
- Les seuils de charge
- Les mécanismes d'auto-scaling
- Les points de rupture
- Les stratégies de mitigation

Format de réponse :
1. Scénario de test de charge
2. Évaluation de la réaction d'auto-scaling
3. Identification des points de rupture
4. Recommandations d'optimisation

## Prompt 88
En tant qu'expert en gestion des erreurs, vérifie la robustesse de la gestion d'erreurs : l'application résiste-t-elle si un service tiers renvoie un JSON malformé ?
Vérifie spécifiquement :
- Les mécanismes de validation
- Les stratégies de gestion des erreurs
- Les comportements de repli
- Les systèmes de journalisation

Format de réponse :
1. Analyse de la gestion des erreurs
2. Tests de résistance aux données invalides
3. Identification des failles
4. Recommandations d'amélioration

## Prompt 89
En tant qu'expert en reprise d'activité, explique comment tester la procédure de Disaster Recovery (reprise après sinistre) de manière automatisée.
Considère spécifiquement :
- Les procédures de sauvegarde
- Les processus de restauration
- Les tests d'intégrité
- Les mécanismes de validation

Format de réponse :
1. Architecture des tests de Disaster Recovery
2. Processus de test automatisé
3. Indicateurs de succès
4. Intégration dans les workflows

## Prompt 90
En tant qu'expert en tests de performance, génère un test de charge pour identifier le point de rupture des connexions simultanées à l'API.
Analyse spécifiquement :
- Les seuils de performance
- Les points de contention
- Les mécanismes de limitation
- Les indicateurs de défaillance

Format de réponse :
1. Scénario de test de charge
2. Méthodologie d'évaluation
3. Identification du point de rupture
4. Recommandations d'optimisation

## Prompt 91
En tant qu'expert en tolérance aux pannes, analyse comment le système réagit à la perte d'un nœud.
Vérifie spécifiquement :
- Les mécanismes de détection
- Les processus de basculement
- Les stratégies de répartition
- Les indicateurs de performance

Format de réponse :
1. Analyse de la tolérance aux pannes
2. Tests de perte de nœud
3. Évaluation des mécanismes de basculement
4. Recommandations d'amélioration

## Prompt 92
En tant qu'expert en haute disponibilité, explique comment tester le mécanisme de basculement (failover) entre les environnements de production.
Considère spécifiquement :
- Les processus de basculement
- Les temps de récupération
- Les tests de validation
- Les risques opérationnels

Format de réponse :
1. Architecture des tests de failover
2. Processus de validation du basculement
3. Évaluation des temps de récupération
4. Mécanismes de sécurité des tests

## Prompt 93
En tant qu'expert en résilience réseau, vérifie la robustesse face à des latences réseau élevées ou des coupures temporaires.
Analyse spécifiquement :
- Les seuils de tolérance
- Les stratégies de temporisation
- Les mécanismes de reconnexion
- Les comportements de repli

Format de réponse :
1. Tests de résilience réseau
2. Évaluation des seuils de tolérance
3. Analyse des comportements de repli
4. Recommandations d'optimisation

## Prompt 94
En tant qu'expert en sécurité des données, explique comment simuler la perte de données pour tester les processus de restauration.
Considère spécifiquement :
- Les procédures de sauvegarde
- Les processus de restauration
- Les tests de validation
- Les mécanismes de sécurité

Format de réponse :
1. Scénario de test de perte de données
2. Processus de restauration à tester
3. Méthodes de validation
4. Sécurité des tests

## Prompt 95
En tant qu'expert en sécurité des services, analyse la résilience face à des attaques par déni de service (DoS/DDoS).
Vérifie spécifiquement :
- Les mécanismes de protection
- Les stratégies de limitation
- Les seuils de tolérance
- Les processus de réponse

Format de réponse :
1. Analyse de la résilience DoS/DDoS
2. Tests de résistance aux attaques
3. Évaluation des mécanismes de protection
4. Recommandations d'amélioration

## Prompt 96
En tant qu'expert en cybersécurité, explique comment tester la récupération après une attaque de cryptomalware ou ransomware.
Considère spécifiquement :
- Les procédures de sauvegarde
- Les processus de nettoyage
- Les systèmes de restauration
- Les mesures de prévention

Format de réponse :
1. Scénario de test de récupération post-attaque
2. Processus de validation de la restauration
3. Évaluation de la sécurité des sauvegardes
4. Recommandations de sécurité

## Prompt 97
En tant qu'expert en scalabilité, vérifie la capacité de l'application à gérer des volumes de données anormalement élevés.
Analyse spécifiquement :
- Les seuils de traitement
- Les mécanismes d'auto-scaling
- Les points de contention
- Les stratégies de limitation

Format de réponse :
1. Tests de résilience aux volumes élevés
2. Évaluation des mécanismes de scaling
3. Identification des goulets d'étranglement
4. Recommandations d'optimisation

## Prompt 98
En tant qu'expert en dépendances externes, explique comment simuler la perte d'un service tiers critique (ex: authentification, paiement).
Considère spécifiquement :
- Les comportements de repli
- Les stratégies de cache
- Les systèmes de notification
- Les processus de récupération

Format de réponse :
1. Scénario de test de dépendance externe
2. Analyse des comportements de repli
3. Évaluation des stratégies de cache
4. Recommandations de résilience

## Prompt 99
En tant qu'expert en mode dégradé, analyse la capacité de l'application à fonctionner en mode dégradé sans perdre de données critiques.
Vérifie spécifiquement :
- Les fonctionnalités critiques
- Les stratégies de dégradation
- Les mécanismes de persistance
- Les indicateurs de performance

Format de réponse :
1. Analyse du mode dégradé
2. Tests de fonctionnement réduit
3. Évaluation de la persistance des données
4. Recommandations d'optimisation

## Prompt 100
En tant qu'expert en intégration continue, explique comment implémenter des tests de résilience automatiques dans le pipeline CI/CD.
Considère spécifiquement :
- Les types de tests à automatiser
- Les environnements de test
- Les seuils d'acceptation
- Les processus d'intégration

Format de réponse :
1. Architecture des tests de résilience CI/CD
2. Types de tests à intégrer
3. Processus d'automatisation
4. Intégration avec les workflows existants