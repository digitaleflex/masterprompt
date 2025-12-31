#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import sys

def run_gh_command(cmd):
    """Exécuter une commande gh et retourner le résultat"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(result.stdout.strip())
        else:
            print(f"Erreur: {result.stderr.strip()}")
        return result.returncode == 0
    except Exception as e:
        print(f"Exception lors de l'exécution de la commande: {e}")
        return False

def main():
    print("Attribution des labels de contribution aux issues...")
    
    # Définition des issues pour les nouveaux contributeurs
    good_first_issues = [21, 22, 23, 27]  # Issues avec priorité moyenne ou basse
    
    # Définition des issues qui ont besoin d'aide
    help_wanted_issues = [20, 24, 25, 26]  # Issues complexes
    
    # Attribuer les labels "good-first-issue"
    for issue_number in good_first_issues:
        print(f"Ajout du label good-first-issue à l'issue #{issue_number}")
        cmd = f'gh issue edit {issue_number} --add-label "good-first-issue"'
        success = run_gh_command(cmd)
        
        if success:
            print(f"Label good-first-issue attribué à l'issue #{issue_number}")
        else:
            print(f"Échec de l'attribution du label à l'issue #{issue_number}")
        print("-" * 50)
    
    # Attribuer les labels "help-wanted"
    for issue_number in help_wanted_issues:
        print(f"Ajout du label help-wanted à l'issue #{issue_number}")
        cmd = f'gh issue edit {issue_number} --add-label "help-wanted"'
        success = run_gh_command(cmd)
        
        if success:
            print(f"Label help-wanted attribué à l'issue #{issue_number}")
        else:
            print(f"Échec de l'attribution du label à l'issue #{issue_number}")
        print("-" * 50)
    
    print("Attribution des labels de contribution terminée!")

if __name__ == "__main__":
    main()