# Script PowerShell pour numéroter les fichiers dans le répertoire courant

# Obtenir tous les fichiers .md dans le répertoire courant
$files = Get-ChildItem -Path . -Filter "*.md" -File | Sort-Object Name

$counter = 1

foreach ($file in $files) {
    # Créer le nouveau nom avec un numéro à deux chiffres
    $newName = "{0:00}_{1}" -f $counter, $file.Name
    
    # Renommer le fichier
    Rename-Item -Path $file.FullName -NewName $newName
    
    Write-Output "Renommé: $($file.Name) -> $newName"
    
    # Incrémenter le compteur
    $counter++
}

Write-Output "Numérotation terminée!"