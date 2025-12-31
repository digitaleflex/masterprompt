# Script pour créer les issues GitHub une par une pour le projet masterprompt

# Créer les issues selon le plan avec des corps de texte simples

# Phase 1 : Fondations
gh issue create --title "Créer une documentation complète du projet" --body "Créer une documentation complète du projet avec un README principal détaillé, des README pour chaque dossier principal, des exemples d'utilisation concrets et des badges de statut." --label "documentation,enhancement"

gh issue create --title "Développer l'architecture de la CLI" --body "Développer l'architecture de base pour une interface en ligne de commande qui permettra de générer des projets complets, exécuter des analyses de code, appliquer des refactoring automatisés et gérer les workflows DevSecOps." --label "CLI,enhancement"

gh issue create --title "Créer des templates de projets React/Next.js" --body "Créer des templates complets pour applications React avec DevSecOps intégré, applications Next.js avec sécurité intégrée, APIs Node.js avec authentification et projets avec différents niveaux de sécurité." --label "templates,enhancement"

# Phase 2 : Automatisation
gh issue create --title "Créer des GitHub Actions prêtes à l'emploi" --body "Créer des workflows GitHub Actions pour analyse de sécurité automatique, tests de qualité du code, déploiement sécurisé et validation des dépendances." --label "CI/CD,automation"

gh issue create --title "Développer des scripts d'automatisation" --body "Développer des scripts pour mise en place d'environnements de développement, analyses de sécurité et de qualité, déploiements automatisés et gestion des dépendances." --label "automation,enhancement"

# Phase 3 : Intelligence Artificielle
gh issue create --title "Intégrer des API d'IA pour la génération de code" --body "Intégrer des API d'IA pour générer du code à partir de descriptions textuelles, analyser et suggérer des améliorations de code, créer des tests automatiquement et documenter le code." --label "AI,enhancement"

gh issue create --title "Créer un assistant de pair programming" --body "Développer un assistant IA pour aider les développeurs en temps réel avec suggestions de code, détection d'erreurs, meilleures pratiques et sécurité du code." --label "AI,enhancement"

# Phase 4 : Écosystème
gh issue create --title "Créer un système de plugins" --body "Créer un système de plugins pour permettre aux utilisateurs d'ajouter des outils supplémentaires avec système d'installation de plugins, catalogue d'outils, système de notation et documentation des plugins." --label "enhancement,architecture"

echo "Toutes les issues principales ont été créées avec succès !"