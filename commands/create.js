const { exec } = require('child_process');
const fs = require('fs-extra');
const path = require('path');
const inquirer = require('inquirer');
const ora = require('ora');
const chalk = require('chalk');

function createCommand(program) {
  program
    .command('create <project-name>')
    .description('Créer un nouveau projet avec des templates')
    .option('-t, --template <template>', 'Template spécifique à utiliser')
    .option('-d, --directory <directory>', 'Répertoire de destination')
    .action(async (projectName, options) => {
      const spinner = ora({
        text: chalk.blue('Création du projet...'),
        spinner: 'clock'
      });
      spinner.start();

      try {
        // Déterminer le chemin du projet
        const projectPath = options.directory 
          ? path.join(options.directory, projectName)
          : path.join(process.cwd(), projectName);

        // Vérifier si le répertoire existe déjà
        if (fs.existsSync(projectPath)) {
          spinner.fail(chalk.red('Le répertoire existe déjà !'));
          return;
        }

        // Créer le répertoire
        await fs.ensureDir(projectPath);
        
        // Déterminer le template à utiliser
        let template = options.template;
        if (!template) {
          const answers = await inquirer.prompt([
            {
              type: 'list',
              name: 'template',
              message: 'Quel template souhaitez-vous utiliser ?',
              choices: [
                { name: 'React avec DevSecOps', value: 'react-devsecops' },
                { name: 'Next.js avec sécurité', value: 'nextjs-secure' },
                { name: 'API Node.js avec authentification', value: 'node-api-auth' },
                { name: 'Full-stack avec sécurité', value: 'fullstack-secure' }
              ]
            }
          ]);
          template = answers.template;
        }

        // Copier les fichiers du template
        const templatePath = path.join(__dirname, '..', 'templates', template);
        if (!fs.existsSync(templatePath)) {
          throw new Error(`Template ${template} non trouvé`);
        }

        await fs.copy(templatePath, projectPath);
        
        // Créer le fichier de configuration
        const config = {
          projectName,
          template,
          createdAt: new Date().toISOString(),
          masterprompt: {
            version: '1.0.0',
            features: ['devsecops', 'automation', 'quality', 'productivity']
          }
        };
        
        await fs.writeJson(path.join(projectPath, '.masterpromptrc'), config, { spaces: 2 });
        
        spinner.succeed(chalk.green(`Projet ${projectName} créé avec succès !`));
        console.log(chalk.blue(`\nPour commencer :\n`));
        console.log(chalk.yellow(`cd ${projectName}`));
        console.log(chalk.yellow(`npm install`));
        console.log(chalk.yellow(`masterprompt analyze --security`));
        
      } catch (error) {
        spinner.fail(chalk.red(`Erreur lors de la création du projet : ${error.message}`));
        process.exit(1);
      }
    });
}

module.exports = createCommand;