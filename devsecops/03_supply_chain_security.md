# 3. Gestion des Dépendances & Supply Chain (Prompts 41-55)

*Focus : npm, yarn, vulnérabilités tierces.*

## Prompt 41
Analyse mon `package-lock.json`. Y a-t-il des dépendances 'fantômes' ou non épinglées à des versions fixes ?

## Prompt 42
Configure un bot (Renovate ou Dependabot) pour mettre à jour les dépendances, mais avec un filtrage sur les versions majeures.

## Prompt 43
Vérifie si mon projet est vulnérable aux attaques de 'Dependency Confusion' (registres publics vs privés).

## Prompt 44
Propose une méthode pour auditer les dépendances indirectes (transitives) qui ne sont pas listées dans mon `package.json`.

## Prompt 45
Comment mettre en place un miroir local ou un proxy (Artifactory) pour contrôler les paquets externes ?

## Prompt 46
Analyse les checksums des dépendances : sont-ils vérifiés avant l'installation ?

## Prompt 47
Vérifie si les scripts de post-installation sont sécurisés et ne contiennent pas de code malveillant.

## Prompt 48
Comment détecter les dépendances non maintenues ou abandonnées dans mon projet ?

## Prompt 49
Analyse les licences des dépendances : sont-elles conformes à la politique de l'entreprise ?

## Prompt 50
Comment vérifier l'intégrité des dépendances via des signatures ou des hashes connus ?

## Prompt 51
Analyse les dépendances de développement : sont-elles correctement séparées des dépendances de production ?

## Prompt 52
Vérifie si les dépendances sont installées dans un environnement isolé pour éviter les conflits.

## Prompt 53
Comment détecter les dépendances avec des vulnérabilités connues (ex: via npm audit) ?

## Prompt 54
Analyse les sources des dépendances : sont-elles fiables et provenant de registres approuvés ?

## Prompt 55
Comment implémenter une politique de blocage automatique des dépendances non approuvées ?