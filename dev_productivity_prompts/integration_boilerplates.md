# Boilerplates d'intégration

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
```

## Exemple d'utilisation dans un projet
```javascript
// Utilisation d'une API de scraping
const products = await callAPI('/scrape/amazon', {
  searchQuery: 'laptop',
  maxResults: 50
});

// Traitement des données
const processedData = processData(products);
```