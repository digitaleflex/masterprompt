# Script corrigé pour créer les issues GitHub pour le projet masterprompt

# Créer les labels nécessaires s'ils n'existent pas
gh label create "documentation" --description "Documentation" --color 0075ca
gh label create "enhancement" --description "Enhancement" --color a2eeef
gh label create "CLI" --description "Command Line Interface" --color c2e0c6
gh label create "templates" --description "Project templates" --color b60205
gh label create "CI/CD" --description "Continuous Integration/Deployment" --color e11d21
gh label create "automation" --description "Automation tools" --color 0052cc
gh label create "AI" --description "Artificial Intelligence" --color 5319e7
gh label create "architecture" --description "Architecture decisions" --color 0e8a16
gh label create "community" --description "Community related" --color 0052cc

# Créer les issues selon le plan
echo "Création des issues pour le projet masterprompt..."

# Phase 1 : Fondations
gh issue create --title "Créer une documentation complète du projet" --body "# Description
Créer une documentation complète du projet avec :
- Un README principal détaillé
- Des README pour chaque dossier principal
- Des exemples d'utilisation concrets
- Des badges de statut

# Tâches
- [ ] Créer le README principal
- [ ] Créer des README pour chaque dossier
- [ ] Ajouter des exemples d'utilisation
- [ ] Ajouter des badges de statut" --label "documentation","enhancement"

gh issue create --title "Développer l'architecture de la CLI" --body "# Description
Développer l'architecture de base pour une interface en ligne de commande qui permettra de :
- Générer des projets complets
- Exécuter des analyses de code
- Appliquer des refactoring automatisés
- Gérer les workflows DevSecOps

# Tâches
- [ ] Définir l'architecture de la CLI
- [ ] Créer la structure de base
- [ ] Implémenter les commandes de base
- [ ] Écrire les tests" --label "CLI","enhancement"

gh issue create --title "Créer des templates de projets React/Next.js" --body "# Description
Créer des templates complets pour :
- Applications React avec DevSecOps intégré
- Applications Next.js avec sécurité intégrée
- APIs Node.js avec authentification
- Projets avec différents niveaux de sécurité

# Tâches
- [ ] Créer template React
- [ ] Créer template Next.js
- [ ] Créer template API Node.js
- [ ] Créer templates avec différents niveaux de sécurité" --label "templates","enhancement"

# Phase 2 : Automatisation
gh issue create --title "Créer des GitHub Actions prêtes à l'emploi" --body "# Description
Créer des workflows GitHub Actions pour :
- Analyse de sécurité automatique
- Tests de qualité du code
- Déploiement sécurisé
- Validation des dépendances

# Tâches
- [ ] Créer workflow d'analyse de sécurité
- [ ] Créer workflow de tests de qualité
- [ ] Créer workflow de déploiement sécurisé
- [ ] Créer workflow de validation des dépendances" --label "CI/CD","automation"

gh issue create --title "Développer des scripts d'automatisation" --body "# Description
Développer des scripts pour :
- Mise en place d'environnements de développement
- Analyses de sécurité et de qualité
- Déploiements automatisés
- Gestion des dépendances

# Tâches
- [ ] Créer script de mise en place d'environnement
- [ ] Créer script d'analyse de sécurité
- [ ] Créer script de déploiement
- [ ] Créer script de gestion des dépendances" --label "automation","enhancement"

# Phase 3 : Intelligence Artificielle
gh issue create --title "Intégrer des API d'IA pour la génération de code" --body "# Description
Intégrer des API d'IA pour :
- Générer du code à partir de descriptions textuelles
- Analyser et suggérer des améliorations de code
- Créer des tests automatiquement
- Documenter le code

# Tâches
- [ ] Intégrer API de génération de code
- [ ] Intégrer API d'analyse de code
- [ ] Intégrer API de génération de tests
- [ ] Intégrer API de documentation automatique" --label "AI","enhancement"

gh issue create --title "Créer un assistant de pair programming" --body "# Description
Développer un assistant IA pour aider les développeurs en temps réel avec :
- Suggestions de code
- Détection d'erreurs
- Meilleures pratiques
- Sécurité du code

# Tâches
- [ ] Implémenter suggestions de code
- [ ] Implémenter détection d'erreurs
- [ ] Intégrer meilleures pratiques
- [ ] Intégrer vérification de sécurité" --label "AI","enhancement"

# Phase 4 : Écosystème
gh issue create --title "Créer un système de plugins" --body "# Description
Créer un système de plugins pour permettre aux utilisateurs d'ajouter des outils supplémentaires :
- Système d'installation de plugins
- Catalogue d'outils
- Système de notation
- Documentation des plugins

# Tâches
- [ ] Créer architecture système de plugins
- [ ] Créer catalogue d'outils
- [ ] Implémenter système de notation
- [ ] Documenter le système de plugins" --label "enhancement","architecture"

# Phase 5 : Communauté
gh issue create --title "Créer des guidelines de contribution" --body "# Description
Créer des guidelines pour encourager les contributions :
- Templates pour les issues et PR
- Code de conduite
- Labels \"good first issue\"
- Documentation pour les contributeurs

# Tâches
- [ ] Créer template d'issues
- [ ] Créer template de PR
- [ ] Écrire code de conduite
- [ ] Créer documentation contributeurs" --label "documentation","community"

echo "Toutes les issues ont été créées avec succès !"