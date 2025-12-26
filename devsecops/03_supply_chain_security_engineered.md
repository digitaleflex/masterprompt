# 3. Gestion des Dépendances & Supply Chain (Prompts 41-55) - Version Ingénierie des Prompts

*Focus : npm, yarn, vulnérabilités tierces.*

## Prompt 41
En tant qu'expert en gestion des dépendances, analyse le fichier `package-lock.json` suivant pour identifier les dépendances 'fantômes' ou non épinglées à des versions fixes.
Vérifie spécifiquement :
- Les dépendances sans version fixe
- Les dépendances inutilisées
- Les conflits de versions
- Les dépendances avec des vulnérabilités connues

Format de réponse :
1. Analyse détaillée des dépendances non sécurisées
2. Identification des dépendances 'fantômes'
3. Recommandations pour épingler les versions
4. Processus de nettoyage des dépendances inutiles

## Prompt 42
En tant qu'expert en automatisation DevSecOps, configure un bot (Renovate ou Dependabot) pour mettre à jour les dépendances avec un filtrage sur les versions majeures.
Considère spécifiquement :
- Les configurations de sécurité
- Les filtres de mise à jour
- Les tests d'intégration
- Les processus d'approbation

Format de réponse :
1. Configuration du bot de mise à jour
2. Filtres de sécurité pour les mises à jour majeures
3. Processus de test des mises à jour
4. Intégration dans le workflow de développement

## Prompt 43
En tant qu'expert en sécurité des dépendances, vérifie si le projet est vulnérable aux attaques de 'Dependency Confusion' entre registres publics et privés.
Analyse spécifiquement :
- Les configurations des registres
- Les noms de paquets ambigus
- Les priorités de résolution
- Les mécanismes de protection

Format de réponse :
1. Analyse de la configuration actuelle des registres
2. Identification des risques de confusion
3. Recommandations de configuration sécurisée
4. Mise en place de protections

## Prompt 44
En tant qu'expert en gestion des dépendances, propose une méthode pour auditer les dépendances indirectes (transitives) qui ne sont pas listées dans le `package.json`.
Considère spécifiquement :
- Les outils d'analyse de dépendances
- Les méthodes de détection
- Les rapports de sécurité
- Les processus de surveillance

Format de réponse :
1. Outils recommandés pour l'analyse des dépendances transitives
2. Processus d'audit des dépendances
3. Méthodes de surveillance continue
4. Intégration dans le pipeline CI/CD

## Prompt 45
En tant qu'expert en sécurité logicielle, explique comment mettre en place un miroir local ou un proxy (Artifactory) pour contrôler les paquets externes.
Analyse spécifiquement :
- Les solutions de miroir disponibles
- Les configurations de sécurité
- Les processus de validation
- Les politiques de contrôle

Format de réponse :
1. Architecture recommandée pour le miroir de paquets
2. Configuration de la solution de miroir
3. Processus de validation des paquets
4. Intégration avec les outils de gestion de dépendances

## Prompt 46
En tant qu'expert en intégrité logicielle, analyse les checksums des dépendances pour vérifier s'ils sont correctement vérifiés avant l'installation.
Vérifie spécifiquement :
- Les mécanismes de vérification existants
- Les politiques de contrôle
- Les outils de validation
- Les processus de sécurité

Format de réponse :
1. Évaluation de l'actuelle vérification d'intégrité
2. Identification des lacunes de sécurité
3. Recommandations pour renforcer la vérification
4. Outils et configurations recommandés

## Prompt 47
En tant qu'expert en sécurité des scripts, vérifie si les scripts de post-installation sont sécurisés et ne contiennent pas de code malveillant.
Analyse spécifiquement :
- Les scripts exécutés automatiquement
- Les permissions d'exécution
- Les sources de code
- Les mécanismes de contrôle

Format de réponse :
1. Analyse des scripts de post-installation
2. Identification des risques de sécurité
3. Recommandations pour sécuriser les scripts
4. Processus de validation des scripts

## Prompt 48
En tant qu'expert en maintenance logicielle, explique comment détecter les dépendances non maintenues ou abandonnées dans le projet.
Considère spécifiquement :
- Les indicateurs de maintenance
- Les outils de surveillance
- Les critères d'évaluation
- Les processus de remplacement

Format de réponse :
1. Méthodes de détection des dépendances abandonnées
2. Outils de surveillance de la maintenance
3. Critères d'évaluation de la viabilité
4. Processus de remplacement des dépendances

## Prompt 49
En tant qu'expert en conformité logicielle, analyse les licences des dépendances pour vérifier leur conformité avec la politique de l'entreprise.
Vérifie spécifiquement :
- Les types de licences
- Les restrictions d'utilisation
- Les obligations légales
- Les conflits potentiels

Format de réponse :
1. Analyse des licences des dépendances
2. Identification des non-conformités
3. Recommandations de remplacement
4. Processus de gestion des licences

## Prompt 50
En tant qu'expert en sécurité logicielle, explique comment vérifier l'intégrité des dépendances via des signatures ou des hashes connus.
Analyse spécifiquement :
- Les mécanismes de signature disponibles
- Les outils de vérification
- Les processus d'intégration
- Les politiques de sécurité

Format de réponse :
1. Méthodes de vérification de l'intégrité
2. Outils de signature et de vérification
3. Intégration dans le pipeline CI/CD
4. Processus de gestion des signatures

## Prompt 51
En tant qu'expert en gestion des dépendances, analyse si les dépendances de développement sont correctement séparées des dépendances de production.
Vérifie spécifiquement :
- Les classifications des dépendances
- Les processus d'installation
- Les environnements d'exécution
- Les risques de fuite

Format de réponse :
1. Analyse de la séparation des dépendances
2. Identification des erreurs de classification
3. Recommandations pour une séparation correcte
4. Processus de validation

## Prompt 52
En tant qu'expert en sécurité d'exécution, vérifie si les dépendances sont installées dans un environnement isolé pour éviter les conflits.
Analyse spécifiquement :
- Les méthodes d'isolation
- Les configurations d'environnement
- Les risques de contamination
- Les bonnes pratiques

Format de réponse :
1. Évaluation de l'actuelle isolation des dépendances
2. Identification des risques de conflits
3. Recommandations d'isolation sécurisée
4. Outils et configurations recommandés

## Prompt 53
En tant qu'expert en sécurité logicielle, explique comment détecter les dépendances avec des vulnérabilités connues (ex: via npm audit).
Considère spécifiquement :
- Les outils d'analyse de sécurité
- Les bases de données de vulnérabilités
- Les processus d'analyse
- Les politiques de réponse

Format de réponse :
1. Outils de détection des vulnérabilités
2. Intégration dans le pipeline CI/CD
3. Processus d'analyse et de triage
4. Politiques de réponse aux vulnérabilités

## Prompt 54
En tant qu'expert en provenance logicielle, analyse les sources des dépendances pour vérifier si elles sont fiables et provenant de registres approuvés.
Vérifie spécifiquement :
- Les registres de provenance
- Les politiques de contrôle
- Les mécanismes de vérification
- Les sources non approuvées

Format de réponse :
1. Analyse de la provenance des dépendances
2. Identification des sources non approuvées
3. Recommandations de contrôle de provenance
4. Processus de vérification des sources

## Prompt 55
En tant qu'expert en sécurité logicielle, explique comment implémenter une politique de blocage automatique des dépendances non approuvées.
Analyse spécifiquement :
- Les critères d'approbation
- Les mécanismes de blocage
- Les processus de validation
- Les exceptions possibles

Format de réponse :
1. Politique de contrôle des dépendances
2. Mécanismes de blocage automatique
3. Processus d'approbation des exceptions
4. Intégration dans le pipeline CI/CD