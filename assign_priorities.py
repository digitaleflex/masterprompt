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
    print("Attribution des priorités aux issues...")
    
    # Définition des priorités pour les issues
    priority_mapping = [
        # Priorité critique
        {"issue": 19, "priority": "priority-critical"},  # Documentation complète
        {"issue": 20, "priority": "priority-critical"},  # Architecture CLI
        
        # Priorité haute
        {"issue": 21, "priority": "priority-high"},      # Templates projets
        {"issue": 22, "priority": "priority-high"},      # GitHub Actions
        {"issue": 23, "priority": "priority-high"},      # Scripts d'automatisation
        
        # Priorité moyenne
        {"issue": 24, "priority": "priority-medium"},    # API d'IA
        {"issue": 25, "priority": "priority-medium"},    # Assistant pair programming
        {"issue": 26, "priority": "priority-medium"},    # Système de plugins
        
        # Priorité basse
        {"issue": 27, "priority": "priority-low"},       # Guidelines contribution
    ]
    
    # Attribuer les priorités
    for mapping in priority_mapping:
        issue_number = mapping["issue"]
        priority = mapping["priority"]
        
        print(f"Ajout du label {priority} à l'issue #{issue_number}")
        
        # Supprimer les labels de priorité existants
        cmd_remove = f'gh issue edit {issue_number} --remove-label "priority-critical,priority-high,priority-medium,priority-low"'
        run_gh_command(cmd_remove)
        
        # Ajouter le nouveau label de priorité
        cmd_add = f'gh issue edit {issue_number} --add-label "{priority}"'
        success = run_gh_command(cmd_add)
        
        if success:
            print(f"Priorité {priority} attribuée à l'issue #{issue_number}")
        else:
            print(f"Échec de l'attribution de la priorité à l'issue #{issue_number}")
        print("-" * 50)
    
    print("Attribution des priorités terminée!")

if __name__ == "__main__":
    main()