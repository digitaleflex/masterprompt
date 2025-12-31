const fs = require('fs-extra');
const path = require('path');
const ora = require('ora');
const chalk = require('chalk');

function initCommand(program) {
  program
    .command('init')
    .description('Initialiser un projet existant avec MasterPrompt')
    .option('-f, --force', 'Forcer l\'initialisation même si .masterpromptrc existe')
    .action(async (options) => {
      const spinner = ora({
        text: chalk.blue('Initialisation du projet...'),
        spinner: 'clock'
      });
      spinner.start();

      try {
        const configPath = path.join(process.cwd(), '.masterpromptrc');
        
        if (fs.existsSync(configPath) && !options.force) {
          spinner.warn(chalk.yellow('Le projet est déjà initialisé avec MasterPrompt'));
          console.log(chalk.blue('Utilisez --force pour réinitialiser'));
          return;
        }

        // Créer le fichier de configuration
        const config = {
          projectName: path.basename(process.cwd()),
          createdAt: new Date().toISOString(),
          masterprompt: {
            version: '1.0.0',
            features: ['devsecops', 'automation', 'quality', 'productivity'],
            enabled: true
          },
          settings: {
            security: {
              enabled: true,
              level: 'standard'
            },
            quality: {
              enabled: true,
              level: 'standard'
            },
            performance: {
              enabled: true,
              level: 'standard'
            }
          }
        };
        
        await fs.writeJson(configPath, config, { spaces: 2 });
        
        // Créer un dossier .masterprompt pour les configurations supplémentaires
        await fs.ensureDir(path.join(process.cwd(), '.masterprompt'));
        
        spinner.succeed(chalk.green('Projet initialisé avec MasterPrompt !'));
        console.log(chalk.blue('\nFonctionnalités activées :'));
        console.log(chalk.green('✓ Analyse de sécurité'));
        console.log(chalk.green('✓ Analyse de qualité'));
        console.log(chalk.green('✓ Analyse de performance'));
        console.log(chalk.blue('\nUtilisez les commandes suivantes pour commencer :'));
        console.log(chalk.yellow('masterprompt analyze --all'));
        console.log(chalk.yellow('masterprompt report --all'));
        
      } catch (error) {
        spinner.fail(chalk.red(`Erreur lors de l'initialisation : ${error.message}`));
        process.exit(1);
      }
    });
}

module.exports = initCommand;