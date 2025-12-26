#!/bin/bash
# Script de réorganisation des fichiers Jules-Ready pour React.js

# Créer un dossier backup
mkdir -p backup
cp *.md backup/

# Renommer les fichiers selon la structure ordonnée
# Série 01-10 : Audit Global et Setup
mv "02_audit_secu.md" "01_security_audit.md" 2>/dev/null || echo "02_audit_secu.md n'existe pas"
mv "18_react_architecture_audit.md" "02_architecture_audit.md" 2>/dev/null || echo "18_react_architecture_audit.md n'existe pas"
mv "19_react_performance_optimization.md" "03_performance_audit.md" 2>/dev/null || echo "19_react_performance_optimization.md n'existe pas"
mv "22_react_state_management.md" "04_state_management_audit.md" 2>/dev/null || echo "22_react_state_management.md n'existe pas"
mv "21_react_testing_strategy.md" "05_testing_audit.md" 2>/dev/null || echo "21_react_testing_strategy.md n'existe pas"
mv "24_react_accessibility_ux.md" "06_accessibility_audit.md" 2>/dev/null || echo "24_react_accessibility_ux.md n'existe pas"
mv "26_react_internationalization_seo.md" "07_internationalization_audit.md" 2>/dev/null || echo "26_react_internationalization_seo.md n'existe pas"
mv "05_error_handling.md" "08_error_handling_audit.md" 2>/dev/null || echo "05_error_handling.md n'existe pas"
mv "16_testing_quality.md" "09_ci_cd_audit.md" 2>/dev/null || echo "16_testing_quality.md n'existe pas"
mv "01_initial_project_setup.md" "10_project_setup_audit.md" 2>/dev/null || echo "01_initial_project_setup.md n'existe pas"

# Série 11-20 : Optimisation et Sécurité
mv "11_typescript_strict_typing.md" "11_typescript_hardening.md" 2>/dev/null || echo "11_typescript_strict_typing.md n'existe pas"
mv "20_react_security_vulnerability.md" "12_security_vulnerability_assessment.md" 2>/dev/null || echo "20_react_security_vulnerability.md n'existe pas"
mv "13_architecture_design_patterns.md" "13_architecture_patterns_optimization.md" 2>/dev/null || echo "13_architecture_design_patterns.md n'existe pas"
mv "14_performance_rendering_optimization.md" "14_performance_rendering_optimization.md" 2>/dev/null || echo "14_performance_rendering_optimization.md n'existe pas"
mv "15_state_management_data_fetching.md" "15_state_management_optimization.md" 2>/dev/null || echo "15_state_management_data_fetching.md n'existe pas"
mv "16_testing_quality.md" "16_testing_quality_assurance.md" 2>/dev/null || echo "16_testing_quality.md n'existe pas"
mv "17_accessibility_ux.md" "17_accessibility_ux_optimization.md" 2>/dev/null || echo "17_accessibility_ux.md n'existe pas"
mv "02_component_library_strategy.md" "18_component_library_strategy.md" 2>/dev/null || echo "02_component_library_strategy.md n'existe pas"
mv "07_routing_navigation.md" "19_routing_navigation_optimization.md" 2>/dev/null || echo "07_routing_navigation.md n'existe pas"
mv "08_form_handling_validation.md" "20_form_handling_validation.md" 2>/dev/null || echo "08_form_handling_validation.md n'existe pas"

# Série 21-30 : Approfondissement Technique
mv "09_animation_interactions.md" "21_animation_interactions_optimization.md" 2>/dev/null || echo "09_animation_interactions.md n'existe pas"
mv "06_error_handling_strategy.md" "22_error_handling_strategy.md" 2>/dev/null || echo "06_error_handling_strategy.md n'existe pas"
mv "06_performance_optimization.md" "23_performance_optimization.md" 2>/dev/null || echo "06_performance_optimization.md n'existe pas"
mv "08_safe_refactoring_guide.md" "24_safe_refactoring_guide.md" 2>/dev/null || echo "08_safe_refactoring_guide.md n'existe pas"
mv "07_refactoring_playbook.md" "25_refactoring_playbook.md" 2>/dev/null || echo "07_refactoring_playbook.md n'existe pas"
mv "01_aggressive_refactoring.md" "26_aggressive_refactoring.md" 2>/dev/null || echo "01_aggressive_refactoring.md n'existe pas"
mv "03_clean_architecture_refactor.md" "27_clean_architecture_refactor.md" 2>/dev/null || echo "03_clean_architecture_refactor.md n'existe pas"
mv "04_devops_ci_cd_setup.md" "28_devops_ci_cd_setup.md" 2>/dev/null || echo "04_devops_ci_cd_setup.md n'existe pas"
mv "05_security_implementation.md" "29_security_implementation.md" 2>/dev/null || echo "05_security_implementation.md n'existe pas"
mv "10_testing_strategy.md" "30_testing_strategy.md" 2>/dev/null || echo "10_testing_strategy.md n'existe pas"

# Renommer les fichiers restants pour qu'ils correspondent à la structure
mv "23_react_hooks_audit.md" "31_hooks_best_practices_audit.md" 2>/dev/null || echo "23_react_hooks_audit.md n'existe pas"
mv "25_react_build_deployment.md" "32_build_deployment_optimization.md" 2>/dev/null || echo "25_react_build_deployment.md n'existe pas"
mv "27_react_refactoring_plan.md" "33_refactoring_plan_generator.md" 2>/dev/null || echo "27_react_refactoring_plan.md n'existe pas"

echo "Réorganisation terminée. Les anciens fichiers sont sauvegardés dans le dossier backup/"