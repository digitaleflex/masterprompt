# Script pour créer la structure d'intégration des API

$apiFolders = @(
    "api_integration_tools/automation_apis",
    "api_integration_tools/developer_tools_apis", 
    "api_integration_tools/integration_apis",
    "dev_productivity_prompts"
)

# Créer les dossiers
foreach ($folder in $apiFolders) {
    $folderPath = Join-Path -Path "." -ChildPath $folder
    if (!(Test-Path -Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath -Force
        Write-Host "Dossier créé: $folderPath"
    }
}

# Créer les fichiers avec contenu initial
New-Item -ItemType File -Path "api_integration_tools/automation_apis/social_media_apis.md" -Value "# Prompts pour les API de réseaux sociaux

## Twitter/X Scraper
**Objectif** : Extraire des données de Twitter/X pour analyse de contenu ou veille stratégique
**Prompt** : `"Utilise l'API Twitter Scraper (Ultimate) pour collecter des tweets pertinents sur [sujet] dans la période [dates]. Analyse les tendances, les hashtags populaires et les interactions. Fournis un rapport avec les insights clés et les comptes influents.`"

## Instagram Post Scraper
**Objectif** : Analyser les publications Instagram pour une campagne de marketing
**Prompt** : `"Utilise l'API Instagram Post & Video Scraper pour extraire les données de publication pour [compte ou hashtag]. Analyse les métriques d'engagement, les types de contenu les plus performants et les tendances visuelles.`"

## LinkedIn Jobs Scraper
**Objectif** : Analyser le marché de l'emploi pour un poste spécifique
**Prompt** : `"Utilise l'API LinkedIn Jobs Scraper pour collecter les offres d'emploi pour [poste] dans [localisation]. Identifie les compétences les plus demandées, les tendances salariales et les entreprises les plus actives.`""
if (!(Test-Path "api_integration_tools/automation_apis/social_media_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/automation_apis/social_media_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/automation_apis/web_scraping_apis.md" -Value "# Prompts pour les API de scraping web

## Google Search Results Scraper
**Objectif** : Extraire des résultats de recherche Google pour analyse de contenu
**Prompt** : `"Utilise l'API Google Search Results Scraper pour collecter des résultats de recherche sur [sujet]. Analyse les domaines les plus présents, les tendances de contenu et les mots-clés associés.`"

## Amazon Product Scraper
**Objectif** : Analyser les produits Amazon pour veille concurrentielle
**Prompt** : `"Utilise l'API Amazon Product Scraper pour collecter des données sur [produit ou catégorie]. Analyse les prix, les évaluations, les caractéristiques et les tendances du marché.`""
if (!(Test-Path "api_integration_tools/automation_apis/web_scraping_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/automation_apis/web_scraping_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/automation_apis/data_extraction_apis.md" -Value "# Prompts pour les API d'extraction de données

## YouTube Transcript Downloader
**Objectif** : Extraire des transcriptions YouTube pour analyse de contenu
**Prompt** : `"Utilise l'API YouTube Transcript Downloader pour extraire les transcriptions de vidéos sur [sujet]. Analyse les thèmes principaux, les mots-clés récurrents et les structures narratives.`""
if (!(Test-Path "api_integration_tools/automation_apis/data_extraction_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/automation_apis/data_extraction_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/automation_apis/workflow_automation_apis.md" -Value "# Prompts pour les API d'automatisation de workflow

## Any Website URL to Article Summarizer
**Objectif** : Résumer automatiquement des articles web
**Prompt** : `"Utilise l'API Any Website URL to Article Summarizer pour résumer automatiquement le contenu de [URL]. Génère un résumé structuré avec les points clés, les insights et les recommandations.`""
if (!(Test-Path "api_integration_tools/automation_apis/workflow_automation_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/automation_apis/workflow_automation_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/developer_tools_apis/code_analysis_apis.md" -Value "# Prompts pour les API d'analyse de code

## AI Code Review Agent
**Objectif** : Effectuer des revues de code automatisées
**Prompt** : `"Utilise l'API AI Code Review Agent pour analyser le code dans [dossier ou fichier]. Identifie les bugs potentiels, les problèmes de sécurité et les opportunités d'amélioration. Fournis des recommandations concrètes.`""
if (!(Test-Path "api_integration_tools/developer_tools_apis/code_analysis_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/developer_tools_apis/code_analysis_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/developer_tools_apis/testing_apis.md" -Value "# Prompts pour les API de test

"
if (!(Test-Path "api_integration_tools/developer_tools_apis/testing_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/developer_tools_apis/testing_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/developer_tools_apis/monitoring_apis.md" -Value "# Prompts pour les API de surveillance

"
if (!(Test-Path "api_integration_tools/developer_tools_apis/monitoring_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/developer_tools_apis/monitoring_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/developer_tools_apis/deployment_apis.md" -Value "# Prompts pour les API de déploiement

"
if (!(Test-Path "api_integration_tools/developer_tools_apis/deployment_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/developer_tools_apis/deployment_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/integration_apis/validation_apis.md" -Value "# Prompts pour les API de validation

## Vies VAT number validation
**Objectif** : Valider des numéros de TVA pour la conformité fiscale
**Prompt** : `"Utilise l'API Vies VAT number validation pour vérifier la validité du numéro de TVA [numéro]. Confirme la conformité fiscale et l'identité de l'entreprise pour les transactions B2B.`""
if (!(Test-Path "api_integration_tools/integration_apis/validation_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/integration_apis/validation_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/integration_apis/search_apis.md" -Value "# Prompts pour les API de recherche

## GPT Search [Private API]
**Objectif** : Effectuer des recherches avancées avec GPT
**Prompt** : `"Utilise l'API GPT Search pour effectuer une recherche approfondie sur [sujet]. Fournis une synthèse structurée avec des sources vérifiables et des recommandations basées sur les dernières informations disponibles.`""
if (!(Test-Path "api_integration_tools/integration_apis/search_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/integration_apis/search_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/integration_apis/content_generation_apis.md" -Value "# Prompts pour les API de génération de contenu

## LinkedIn Posts Generator
**Objectif** : Générer des publications LinkedIn avec IA
**Prompt** : `"Utilise l'API LinkedIn Posts Generator pour créer des publications engageantes sur [sujet]. Produis du contenu aligné avec la stratégie de marque et optimisé pour l'engagement.`""
if (!(Test-Path "api_integration_tools/integration_apis/content_generation_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/integration_apis/content_generation_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/integration_apis/business_intelligence_apis.md" -Value "# Prompts pour les API d'intelligence d'affaires

## Company Research Intelligence Tool
**Objectif** : Générer des rapports d'intelligence d'entreprise
**Prompt** : `"Utilise l'API Company Research Intelligence Tool pour créer un rapport complet sur [entreprise ou domaine]. Inclus des informations sur la structure, les produits, la concurrence, les tendances du marché et les opportunités.`""
if (!(Test-Path "api_integration_tools/integration_apis/business_intelligence_apis.md")) {
    Write-Host "Fichier créé: api_integration_tools/integration_apis/business_intelligence_apis.md"
}

New-Item -ItemType File -Path "api_integration_tools/api_integration_guides.md" -Value "# Guides d'intégration des API

## Guide de démarrage rapide

1. Identifiez le besoin spécifique dans votre projet
2. Recherchez l'API correspondante dans les catégories appropriées
3. Adaptez le prompt fourni à votre contexte spécifique
4. Intégrez l'API dans votre workflow de développement
5. Surveillez les résultats et optimisez selon les besoins

## Bonnes pratiques

- Respectez toujours les limites de taux d'utilisation des API
- Mettez en cache les résultats lorsque possible pour réduire les appels répétés
- Gérez les erreurs et exceptions de manière appropriée
- Documentez l'utilisation des API dans votre projet
- Vérifiez la conformité avec les politiques d'utilisation des services"
if (!(Test-Path "api_integration_tools/api_integration_guides.md")) {
    Write-Host "Fichier créé: api_integration_tools/api_integration_guides.md"
}

New-Item -ItemType File -Path "dev_productivity_prompts/api_automation_patterns.md" -Value "# Modèles d'automatisation avec API

## Modèle de scraping de contenu
- Identifie la source de données
- Configure les paramètres d'extraction
- Définit les transformations de données
- Planifie les exécutions récurrentes
- Gère les erreurs et la journalisation

## Modèle de validation de données
- Définit les critères de validation
- Intègre les API de validation appropriées
- Met en place des contrôles de qualité
- Génère des rapports de conformité
- Alertes en cas de non-conformité"
if (!(Test-Path "dev_productivity_prompts/api_automation_patterns.md")) {
    Write-Host "Fichier créé: dev_productivity_prompts/api_automation_patterns.md"
}

New-Item -ItemType File -Path "dev_productivity_prompts/scraping_workflows.md" -Value "# Workflows de scraping

## Workflow d'analyse de marché
1. Utilise Google Search Results Scraper pour identifier les concurrents
2. Applique Amazon Product Scraper pour analyser les prix et les caractéristiques
3. Utilise LinkedIn Jobs Scraper pour comprendre les tendances de l'emploi
4. Génère un rapport d'analyse de marché consolidé

## Workflow de veille concurrentielle
1. Configure les alertes pour les nouveaux produits concurrentiels
2. Suit les évaluations et commentaires clients
3. Analyse les stratégies de contenu sur les réseaux sociaux
4. Produit des recommandations stratégiques"
if (!(Test-Path "dev_productivity_prompts/scraping_workflows.md")) {
    Write-Host "Fichier créé: dev_productivity_prompts/scraping_workflows.md"
}

New-Item -ItemType File -Path "dev_productivity_prompts/integration_boilerplates.md" -Value "# Boilerplates d'intégration

## Boilerplate d'intégration API
```javascript
// Configuration de base
const apiConfig = {
  apiKey: process.env.API_KEY,
  baseUrl: 'https://api.example.com',
  timeout: 10000
};

// Fonction d'appel API
async function callAPI(endpoint, params) {
  try {
    const response = await fetch(`${apiConfig.baseUrl}${endpoint}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${apiConfig.apiKey}`,
        'Content-Type': 'application/json'
      },
      ...params
    });
    
    if (!response.ok) {
      throw new Error(`API call failed: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('API call error:', error);
    throw error;
  }
}
```"
if (!(Test-Path "dev_productivity_prompts/integration_boilerplates.md")) {
    Write-Host "Fichier créé: dev_productivity_prompts/integration_boilerplates.md"
}

New-Item -ItemType File -Path "README_API_INTEGRATION.md" -Value "# Intégration des API dans le projet

Ce dossier contient des prompts et des guides pour intégrer efficacement les API dans vos projets de développement. Les API proviennent du dépôt `"API-mega-list`" qui contient plus de 10 000 API prêtes à l'emploi.

## Catégories d'API

- **Automation APIs** : Outils pour automatiser diverses tâches
- **Developer Tools APIs** : Outils pour aider au développement et à l'analyse de code
- **Integration APIs** : Outils pour intégrer des services tiers

## Utilisation

1. Identifiez le besoin dans votre projet
2. Consultez les prompts dans la catégorie appropriée
3. Adaptez le prompt à votre contexte spécifique
4. Intégrez l'API dans votre workflow

## Avantages

- Gain de temps important dans le développement
- Accès à des données riches pour l'analyse
- Automatisation de tâches répétitives
- Amélioration de la productivité des développeurs"
if (!(Test-Path "README_API_INTEGRATION.md")) {
    Write-Host "Fichier créé: README_API_INTEGRATION.md"
}