#!/bin/bash
# Script de commit et push pour les modifications DevSecOps

echo "Début du processus de commit et push..."

# Vérifier l'état du dépôt
echo "Vérification de l'état du dépôt..."
git status

# Ajouter tous les fichiers modifiés
echo "Ajout des fichiers au staging..."
git add .

# Vérifier les fichiers ajoutés
echo "Fichiers ajoutés au staging :"
git status --porcelain

# Effectuer le commit
echo "Effectuer le commit..."
git commit -m "feat: Ajout des prompts DevSecOps - Suite complète de 100 prompts structurés
- Ajout du dossier devsecops avec 100 prompts DevSecOps structurés
- Création des versions originales et versions ingénierie des prompts
- Organisation par catégories : Infrastructure, CI/CD, Supply Chain, Monitoring, Gouvernance, Résilience
- Chaque catégorie a sa version originale et sa version optimisée pour l'IA"

# Afficher les détails du commit
echo "Détails du commit :"
git show --stat

# Effectuer le push
echo "Effectuer le push..."
git push

echo "Processus de commit et push terminé avec succès !"