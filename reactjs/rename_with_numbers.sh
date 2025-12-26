#!/bin/bash

# Script pour numéroter les fichiers dans le répertoire courant
# Utilisation: ./rename_with_numbers.sh

counter=1

# Lister tous les fichiers .md dans le répertoire courant
for file in *.md; do
  # Vérifier si le fichier existe (pour éviter le cas où il n'y a pas de fichiers .md)
  if [ -f "$file" ]; then
    # Créer le nouveau nom avec un numéro à deux chiffres
    new_name=$(printf "%02d_%s" $counter "$file")
    
    # Renommer le fichier
    mv "$file" "$new_name"
    
    echo "Renommé: $file -> $new_name"
    
    # Incrémenter le compteur
    counter=$((counter + 1))
  fi
done

echo "Numérotation terminée!"