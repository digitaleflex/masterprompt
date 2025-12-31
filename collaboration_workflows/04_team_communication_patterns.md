# Modèles de communication d'équipe

## Description
Ce document présente les modèles et pratiques de communication efficaces pour les équipes de développement logiciel, incluant les canaux de communication, les rituels et les bonnes pratiques.

## Canaux de communication

### 1. Communication asynchrone

#### Courriel
- **Utilisation**: Communications formelles, documents importants, annonces
- **Meilleures pratiques**:
  - Sujets clairs et descriptifs
  - Corps concis et structuré
  - CC uniquement les personnes concernées
  - Utilisation de modèles pour les communications récurrentes

#### Messages instantanés (Slack, Discord, Teams)
- **Utilisation**: Discussions rapides, partage d'informations, questions courtes
- **Catégories de canaux**:
  - `#général`: Annonces importantes
  - `#tech`: Discussions techniques
  - `#random`: Discussions informelles
  - `#projets`: Canaux spécifiques aux projets
  - `#support`: Demandes d'aide techniques

#### Systèmes de tickets (Issues, Jira)
- **Utilisation**: Suivi des tâches, bugs, demandes de fonctionnalités
- **Meilleures pratiques**:
  - Descriptions complètes
  - Étiquettes appropriées
  - Assignations claires
  - Mises à jour régulières

### 2. Communication synchrone

#### Réunions
- **Daily Standup**: Mises à jour quotidiennes
- **Planning**: Planification des sprints
- **Rétrospectives**: Amélioration continue
- **Revues de code**: Discussions techniques
- **Présentations**: Partage de connaissances

#### Appels vidéo
- **Utilisation**: Discussions complexes, résolution de problèmes
- **Meilleures pratiques**:
  - Agenda préalable
  - Participants limités
  - Notes prises et partagées
  - Suivi des décisions

## Modèles de communication

### 1. Modèle SBAR (Situation, Background, Assessment, Recommendation)

#### Structure
- **Situation**: Quel est le problème actuel ?
- **Background**: Quel est le contexte ?
- **Assessment**: Quelle est votre analyse ?
- **Recommendation**: Quelle est votre recommandation ?

#### Exemple
```
S: Notre API de paiement rencontre des temps de réponse lents
B: Depuis hier soir, les requêtes prennent plus de 3 secondes
A: Après investigation, c'est dû à une requête de base de données non optimisée
R: Je recommande d'ajouter un index sur le champ transaction_id et de mettre en place un cache
```

### 2. Modèle 5W1H (What, Who, When, Where, Why, How)

#### Structure
- **What**: Qu'est-ce qui s'est produit ?
- **Who**: Qui est concerné ?
- **When**: Quand cela s'est-il produit ?
- **Where**: Où cela s'est-il produit ?
- **Why**: Pourquoi cela est-il important ?
- **How**: Comment allons-nous résoudre cela ?

#### Exemple
```
What: Incident de sécurité sur le serveur de production
Who: Équipe de sécurité et de développement impactée
When: Hier à 14h30
Where: Serveur API dans le datacenter est
Why: Risque de compromission des données clients
How: Investigation en cours, système mis hors-ligne temporairement
```

### 3. Modèle DESC (Describe, Express, Specify, Consequences)

#### Structure
- **Describe**: Décrivez la situation objectivement
- **Express**: Exprimez vos sentiments
- **Specify**: Spécifiez ce que vous attendez
- **Consequences**: Décrivez les conséquences positives

#### Exemple
```
Describe: Je remarque que les revues de code prennent souvent plus de 2 jours
Express: Cela me cause du stress car cela ralentit mes livraisons
Specify: Pourriez-vous s'il vous plaît prioriser les revues de code dans les 24h ?
Consequences: Cela nous permettrait de maintenir notre rythme de développement
```

## Rituel de communication

### 1. Daily Standup (15 minutes)

#### Format classique
```
1. Qu'avez-vous accompli hier ?
2. Qu'allez-vous faire aujourd'hui ?
3. Y a-t-il des obstacles ?
```

#### Meilleures pratiques
- Tenir la réunion debout
- Limiter à 15 minutes
- Se concentrer sur les obstacles
- Éviter les discussions techniques détaillées
- Encourager la participation de tous

### 2. Weekly Sync (1 heure)

#### Ordre du jour type
```
1. Mise à jour des indicateurs clés (30 min)
   - Avancement des projets
   - Problèmes récurrents
   - Dette technique

2. Discussions techniques (20 min)
   - Défis rencontrés
   - Nouvelles technologies
   - Améliorations de processus

3. Alignement (10 min)
   - Prochains objectifs
   - Besoins d'assistance
   - Décisions à prendre
```

### 3. Monthly Retro (2 heures)

#### Format
```
1. Check-in (15 min)
2. Collecte des données (30 min)
3. Génération d'insights (30 min)
4. Décision de ce que nous allons expérimenter (30 min)
5. Close (15 min)
```

## Communication dans les outils numériques

### 1. Slack/Discord

#### Bonnes pratiques
- Utiliser des canaux spécifiques au lieu de messages directs
- Épingler les informations importantes
- Utiliser des threads pour les discussions longues
- Réagir avec des emojis pour les réponses rapides
- Désactiver les notifications non essentielles

#### Modèles de messages

##### Demande d'aide
```
Hey team 👋, j'ai besoin d'aide avec [problème spécifique].
Contexte: [brève explication]
Ce que j'ai essayé: [solutions tentées]
Ce dont j'ai besoin: [aide spécifique]
Disponible pour une discussion: [heure de disponibilité]
```

##### Mise à jour de statut
```
Status update: [Nom du projet] - [Date]
✅ Accompli:
- [Tâche 1]
- [Tâche 2]

🔄 En cours:
- [Tâche en cours]

⚠️ Blocages:
- [Obstacle]
- [Obstacle]

📅 Prochaines étapes:
- [Action 1]
- [Action 2]
```

### 2. GitHub/GitLab

#### Commentaires dans les PR
```
Merci pour cette PR @username!

## Points positifs
- [Point fort 1]
- [Point fort 2]

## Suggestions d'amélioration
- [Suggestion 1] → [Solution proposée]
- [Suggestion 2] → [Explication]

## Questions
- [Question sur l'implémentation]
- [Question sur les performances]

## Tests
- [Suggestion pour des tests supplémentaires]
```

## Communication dans les documents

### 1. Documents de spécification

#### Structure recommandée
```
# [Nom du système/fonctionnalité]

## 1. Contexte
> Pourquoi ce système/feature est-il nécessaire ?

## 2. Objectifs
> Quels sont les objectifs principaux ?

## 3. Spécifications techniques
> Comment le système fonctionnera-t-il ?

## 4. Dépendances
> Quels sont les systèmes dépendants ?

## 5. Risques
> Quels sont les risques potentiels ?

## 6. Success metrics
> Comment mesurons-nous le succès ?
```

### 2. Notes de réunion

#### Format
```
# Réunion [Sujet] - [Date]

## Participants
- [Nom] - [Rôle]
- [Nom] - [Rôle]

## Points principaux
1. [Point 1]
2. [Point 2]
3. [Point 3]

## Décisions prises
- [Décision 1] - Responsable: [Nom]
- [Décision 2] - Responsable: [Nom]

## Actions à suivre
- [Action] - Échéance: [Date] - Responsable: [Nom]
- [Action] - Échéance: [Date] - Responsable: [Nom]

## Prochaine réunion
[Date] à [Heure] - [Ordre du jour préliminaire]
```

## Communication interculturelle

### 1. Sensibilité culturelle
- Être conscient des différences culturelles
- Utiliser un langage clair et simple
- Éviter les idiomes ou expressions locales
- Être patient avec les barrières linguistiques

### 2. Horaires mondiaux
- Utiliser des outils comme World Time Buddy
- Alterner les horaires pour l'équité
- Enregistrer les réunions pour les absents
- Partager les résumés écrits

## Communication en situation de crise

### 1. Incident communication

#### Modèle d'annonce d'incident
```
🚨 INCIDENT REPORT - [Heure]

## Statut: [Détection/En cours de résolution/Résolu]

## Impact:
- [Services affectés]
- [Utilisateurs impactés]
- [Durée estimée de l'incident]

## Cause probable:
- [Explication de la cause]

## Actions en cours:
- [Action 1]
- [Action 2]

## Prochaines étapes:
- [Suivi à court terme]
- [Suivi à long terme]

## Mise à jour prévue:
- [Heure de la prochaine mise à jour]
```

### 2. Communication post-incident
- Rapport d'incident détaillé
- Analyse des causes racines
- Plan d'action pour prévention
- Communication aux parties prenantes

## Outils de communication

### 1. Asynchrone
- **Courriel**: Communications formelles
- **Slack/Discord**: Discussions quotidiennes
- **GitHub Issues**: Suivi des tâches
- **Notion/Confluence**: Documentation
- **Calendrier**: Planification des réunions

### 2. Synchrone
- **Zoom/Teams**: Réunions vidéo
- **Miro/Mural**: Brainstorming visuel
- **Google Docs**: Édition collaborative
- **GitHub Live Share**: Programmation en binôme

## Mesure de l'efficacité

### 1. Indicateurs de performance
- Temps de réponse aux messages
- Taux de résolution des tickets
- Participation aux réunions
- Qualité des communications (feedback)

### 2. Feedback régulier
- Enquêtes de satisfaction
- Réunions de rétroaction
- Analyse des canaux de communication
- Ajustement des processus

Une communication efficace est la colonne vertébrale de toute équipe de développement réussie. Elle favorise la collaboration, réduit les malentendus et accélère la résolution des problèmes. L'important est de choisir les bons canaux, d'utiliser des modèles cohérents et de s'assurer que tous les membres de l'équipe comprennent les attentes de communication.