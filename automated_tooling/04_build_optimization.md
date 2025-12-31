# Optimisation de build

## Description
Ce document contient des techniques et configurations pour optimiser les processus de build dans les projets de développement.

## Optimisation pour React/Vite

### vite.config.js
```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { visualizer } from 'rollup-plugin-visualizer'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    // Visualiser la taille des bundles
    visualizer({
      filename: './dist/stats.html',
      gzipSize: true,
      brotliSize: true
    })
  ],
  build: {
    outDir: 'dist',
    sourcemap: true,
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    },
    rollupOptions: {
      output: {
        manualChunks: {
          // Découper les bibliothèques volumineuses
          'react-vendor': ['react', 'react-dom'],
          'ui-vendor': ['@mui/material', '@emotion/react'],
          'utils-vendor': ['lodash', 'date-fns']
        }
      }
    }
  },
  esbuild: {
    // Optimiser la compilation
    minifyIdentifiers: true,
    minifySyntax: true,
    minifyWhitespace: true
  },
  server: {
    // Optimiser le développement
    watch: {
      usePolling: true,
      interval: 1000
    }
  }
})
```

## Optimisation pour Next.js

### next.config.js
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  compiler: {
    // Activer le mode production pour SWC
    removeConsole: {
      exclude: ['error', 'warn']
    }
  },
  webpack: (config, { isServer, dev }) => {
    if (!dev) {
      // Optimiser en production
      config.optimization.minimize = true;
    }
    
    if (!isServer) {
      // Optimiser le client
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
      };
    }
    
    // Ajouter le visualiseur de bundles
    if (!dev) {
      const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
      config.plugins.push(
        new BundleAnalyzerPlugin({
          analyzerMode: 'static',
          openAnalyzer: false,
          reportFilename: 'bundle-report.html',
        })
      );
    }
    
    return config;
  },
  images: {
    // Optimiser les images
    domains: ['example.com'],
    formats: ['image/avif', 'image/webp'],
  },
  experimental: {
    // Activer les fonctionnalités expérimentales
    scrollRestoration: true,
  }
}

module.exports = nextConfig
```

## Optimisation pour Node.js

### webpack.config.js
```javascript
const path = require('path');
const TerserPlugin = require('terser-webpack-plugin');
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');

module.exports = {
  mode: 'production',
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.[contenthash].js',
    clean: true
  },
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: {
            drop_console: true,
            drop_debugger: true,
            pure_funcs: ['console.log', 'console.info']
          }
        }
      })
    ],
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          chunks: 'all',
        }
      }
    }
  },
  plugins: [
    new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      openAnalyzer: false,
      reportFilename: 'bundle-report.html',
    })
  ]
};
```

## Scripts de build optimisés

### package.json
```json
{
  "scripts": {
    "build": "vite build",
    "build:analyze": "vite build --mode analyze",
    "build:stats": "vite build && npx vite-bundle-visualizer",
    "build:prod": "NODE_ENV=production vite build",
    "build:ci": "vite build --emptyOutDir",
    "preview": "vite preview",
    "preview:prod": "NODE_ENV=production vite preview"
  }
}
```

## Optimisation des dépendances

### Réduction de la taille des bundles
```javascript
// Utiliser des imports nommés pour réduire la taille
// Mauvais
import _ from 'lodash';

// Bon
import { debounce, throttle } from 'lodash';

// Meilleur - utiliser des bibliothèques plus légères
import { debounce } from 'lodash-es';
// ou
import debounce from 'lodash/debounce';
```

## Optimisation des images

### Optimisation avec Sharp (Node.js)
```javascript
const sharp = require('sharp');

async function optimizeImage(inputPath, outputPath) {
  await sharp(inputPath)
    .resize(800, 600, {
      fit: 'inside',
      withoutEnlargement: true
    })
    .webp({ quality: 80 })
    .toFile(outputPath);
}

// Utilisation
optimizeImage('input.jpg', 'output.webp');
```

## Cache de build

### Configuration de cache pour CI/CD
```yaml
# Exemple pour GitHub Actions
name: Build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Cache node modules
        uses: actions/cache@v3
        env:
          cache-name: cache-node-modules
        with:
          path: ~/.npm
          key: ${{ runner.os }}-build-${{ env.cache-name }}-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-build-${{ env.cache-name }}-
            ${{ runner.os }}-build-
            ${{ runner.os }}-
      - run: npm ci
      - run: npm run build
```

## Optimisation de la vitesse de build

### Configuration pour builds rapides
```javascript
// vite.config.js
export default defineConfig({
  esbuild: {
    // Désactiver les sourcemaps en développement pour plus de rapidité
    sourcemap: false
  },
  build: {
    // Désactiver les sourcemaps en développement
    sourcemap: false,
    rollupOptions: {
      // Réduire le nombre de fichiers de sortie
      output: {
        assetFileNames: (assetInfo) => {
          if (assetInfo.name.endsWith('.css')) {
            return 'css/[name].[hash][extname]';
          }
          return 'assets/[name].[hash][extname]';
        }
      }
    }
  },
  server: {
    // Activer le mode préchauffage pour accélérer le démarrage
    warmup: {
      clientFiles: [
        './src/components/**',
        './src/utils/**'
      ]
    }
  }
})
```

## Outils d'analyse de build

### Installation des outils d'analyse
```bash
npm install --save-dev rollup-plugin-visualizer
npm install --save-dev webpack-bundle-analyzer
npm install --save-dev vite-bundle-visualizer
```

### Utilisation de l'analyseur de bundles
```javascript
// Mode développement
if (process.env.ANALYZE) {
  config.plugins.push(
    visualizer({
      filename: './dist/stats.html',
      gzipSize: true,
      brotliSize: true
    })
  );
}
```