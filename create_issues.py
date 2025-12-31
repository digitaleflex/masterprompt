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
    print("Création des issues GitHub pour le projet masterprompt...")
    
    # Liste des issues à créer
    issues = [
        {
            "title": "Créer une documentation complète du projet",
            "body": "Créer une documentation complète du projet avec un README principal détaillé, des README pour chaque dossier principal, des exemples d'utilisation concrets et des badges de statut.",
            "labels": "documentation,enhancement"
        },
        {
            "title": "Développer l'architecture de la CLI",
            "body": "Développer l'architecture de base pour une interface en ligne de commande qui permettra de générer des projets complets, exécuter des analyses de code, appliquer des refactoring automatisés et gérer les workflows DevSecOps.",
            "labels": "CLI,enhancement"
        },
        {
            "title": "Créer des templates de projets React/Next.js",
            "body": "Créer des templates complets pour applications React avec DevSecOps intégré, applications Next.js avec sécurité intégrée, APIs Node.js avec authentification et projets avec différents niveaux de sécurité.",
            "labels": "templates,enhancement"
        },
        {
            "title": "Créer des GitHub Actions prêtes à l'emploi",
            "body": "Créer des workflows GitHub Actions pour analyse de sécurité automatique, tests de qualité du code, déploiement sécurisé et validation des dépendances.",
            "labels": "CI/CD,automation"
        },
        {
            "title": "Développer des scripts d'automatisation",
            "body": "Développer des scripts pour mise en place d'environnements de développement, analyses de sécurité et de qualité, déploiements automatisés et gestion des dépendances.",
            "labels": "automation,enhancement"
        },
        {
            "title": "Intégrer des API d'IA pour la génération de code",
            "body": "Intégrer des API d'IA pour générer du code à partir de descriptions textuelles, analyser et suggérer des améliorations de code, créer des tests automatiquement et documenter le code.",
            "labels": "AI,enhancement"
        },
        {
            "title": "Créer un assistant de pair programming",
            "body": "Développer un assistant IA pour aider les développeurs en temps réel avec suggestions de code, détection d'erreurs, meilleures pratiques et sécurité du code.",
            "labels": "AI,enhancement"
        },
        {
            "title": "Créer un système de plugins",
            "body": "Créer un système de plugins pour permettre aux utilisateurs d'ajouter des outils supplémentaires avec système d'installation de plugins, catalogue d'outils, système de notation et documentation des plugins.",
            "labels": "enhancement,architecture"
        },
        {
            "title": "Créer des guidelines de contribution",
            "body": "Créer des guidelines pour encourager les contributions avec templates pour les issues et PR, code de conduite, labels good first issue et documentation pour les contributeurs.",
            "labels": "documentation,community"
        }
    ]
    
    # Créer les issues
    for i, issue in enumerate(issues, start=1):
        print(f"Création de l'issue #{i}: {issue['title']}")
        cmd = f'gh issue create --title "{issue["title"]}" --body "{issue["body"]}" --label "{issue["labels"]}"'
        success = run_gh_command(cmd)
        if success:
            print(f"Issue #{i} créée avec succès!")
        else:
            print(f"Échec de la création de l'issue #{i}")
        print("-" * 50)
    
    print("Processus terminé!")

if __name__ == "__main__":
    main()