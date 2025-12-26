#!/bin/bash
# Script de commit pour les workflows GitHub DevSecOps

echo "Début du processus de commit pour les workflows GitHub DevSecOps..."

# Vérifier l'état du dépôt
echo "Vérification de l'état du dépôt..."
git status

# Ajouter tous les fichiers modifiés dans le dossier github_workflows
echo "Ajout des fichiers au staging..."
git add .

# Vérifier les fichiers ajoutés
echo "Fichiers ajoutés au staging :"
git status --porcelain

# Effectuer le commit
echo "Effectuer le commit..."
git commit -m "feat: Ajout de la suite complète de 50 workflows GitHub Actions DevSecOps

- Création du dossier github_workflows avec 5 catégories de workflows
- Ajout de 50 workflows spécialisés pour le DevSecOps de niveau entreprise
- Inclusion des configurations YAML complètes pour chaque workflow
- Organisation par catégories : SAST, SCA, IaC, DAST, Gouvernance
- Ajout de la documentation pour la configuration des secrets
- Chaque workflow est prêt à être déployé dans un dépôt GitHub"

# Afficher les détails du commit
echo "Détails du commit :"
git show --stat

echo "Processus de commit terminé avec succès !"
echo "Pour effectuer le push, exécutez : git push"