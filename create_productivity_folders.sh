#!/bin/bash

# Script shell pour créer automatiquement les dossiers et fichiers de productivité

# Dossiers à créer
folders=(
    "productivity_patterns"
    "developer_experience" 
    "automated_tooling"
    "collaboration_workflows"
    "learning_resources"
    "performance_monitoring"
)

# Fichiers pour chaque dossier
productivity_patterns_files=(
    "01_modular_architecture_patterns.md"
    "02_component_design_patterns.md"
    "03_micro_frontend_patterns.md" 
    "04_api_design_patterns.md"
    "05_database_schema_patterns.md"
    "06_state_management_patterns.md"
    "07_error_handling_patterns.md"
    "08_caching_strategies.md"
    "09_performance_patterns.md"
    "10_testing_patterns.md"
)

developer_experience_files=(
    "01_dev_environment_setup.md"
    "02_vscode_extensions_suite.md"
    "03_cli_tools_automation.md"
    "04_debugging_strategies.md" 
    "05_code_review_checklist.md"
    "06_pair_programming_guidelines.md"
    "07_git_workflow_optimization.md"
    "08_ide_productivity_hacks.md"
    "09_documentation_best_practices.md"
    "10_knowledge_sharing_systems.md"
)

automated_tooling_files=(
    "01_code_generation_templates.md"
    "02_linting_standards.md"
    "03_pre_commit_hooks.md"
    "04_build_optimization.md"
    "05_dependency_management.md" 
    "06_monorepo_strategies.md"
    "07_task_automation_scripts.md"
    "08_code_scaffolding.md"
    "09_ci_cd_optimization.md"
    "10_deployment_automation.md"
)

collaboration_workflows_files=(
    "01_agile_practices.md"
    "02_pull_request_templates.md"
    "03_issue_tracking_systems.md"
    "04_team_communication_patterns.md"
    "05_remote_work_productivity.md"
    "06_code_ownership_models.md" 
    "07_kanban_board_setup.md"
    "08_sprint_planning_templates.md"
    "09_retrospective_frameworks.md"
    "10_cross_team_collaboration.md"
)

learning_resources_files=(
    "01_skill_assessment_framework.md"
    "02_learning_path_recommendations.md"
    "03_technical_interview_prep.md"
    "04_mentoring_programs.md"
    "05_code_retreat_sessions.md"
    "06_kata_programming_exercises.md"
    "07_tech_debt_management.md"
    "08_architecture_decision_records.md" 
    "09_refactoring_techniques.md"
    "10_coding_dojo_sessions.md"
)

performance_monitoring_files=(
    "01_developer_velocity_metrics.md"
    "02_code_quality_indicators.md"
    "03_pull_request_analytics.md"
    "04_bug_prevention_strategies.md"
    "05_time_tracking_methods.md"
    "06_workload_balancing.md"
    "07_productivity_kpis.md"
    "08_feedback_loop_optimization.md"
    "09_team_health_metrics.md"
    "10_continuous_improvement_cycles.md"
)

# Créer les dossiers
for folder in "${folders[@]}"; do
    if [ ! -d "$folder" ]; then
        mkdir "$folder"
        echo "Dossier créé: $folder"
    else
        echo "Le dossier existe déjà: $folder"
    fi
done

# Créer les fichiers dans chaque dossier
echo -e "\nCréation des fichiers dans le dossier productivity_patterns..."
for file in "${productivity_patterns_files[@]}"; do
    filepath="productivity_patterns/$file"
    if [ ! -f "$filepath" ]; then
        touch "$filepath"
        echo "Fichier créé: $filepath"
    else
        echo "Le fichier existe déjà: $filepath"
    fi
done

echo -e "\nCréation des fichiers dans le dossier developer_experience..."
for file in "${developer_experience_files[@]}"; do
    filepath="developer_experience/$file"
    if [ ! -f "$filepath" ]; then
        touch "$filepath"
        echo "Fichier créé: $filepath"
    else
        echo "Le fichier existe déjà: $filepath"
    fi
done

echo -e "\nCréation des fichiers dans le dossier automated_tooling..."
for file in "${automated_tooling_files[@]}"; do
    filepath="automated_tooling/$file"
    if [ ! -f "$filepath" ]; then
        touch "$filepath"
        echo "Fichier créé: $filepath"
    else
        echo "Le fichier existe déjà: $filepath"
    fi
done

echo -e "\nCréation des fichiers dans le dossier collaboration_workflows..."
for file in "${collaboration_workflows_files[@]}"; do
    filepath="collaboration_workflows/$file"
    if [ ! -f "$filepath" ]; then
        touch "$filepath"
        echo "Fichier créé: $filepath"
    else
        echo "Le fichier existe déjà: $filepath"
    fi
done

echo -e "\nCréation des fichiers dans le dossier learning_resources..."
for file in "${learning_resources_files[@]}"; do
    filepath="learning_resources/$file"
    if [ ! -f "$filepath" ]; then
        touch "$filepath"
        echo "Fichier créé: $filepath"
    else
        echo "Le fichier existe déjà: $filepath"
    fi
done

echo -e "\nCréation des fichiers dans le dossier performance_monitoring..."
for file in "${performance_monitoring_files[@]}"; do
    filepath="performance_monitoring/$file"
    if [ ! -f "$filepath" ]; then
        touch "$filepath"
        echo "Fichier créé: $filepath"
    else
        echo "Le fichier existe déjà: $filepath"
    fi
done

echo -e "\nTous les dossiers et fichiers ont été créés avec succès!"