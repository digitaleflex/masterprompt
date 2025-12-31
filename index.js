#!/usr/bin/env node

const { Command } = require('commander');
const chalk = require('chalk');
const ora = require('ora');
const createCommand = require('./commands/create');
const analyzeCommand = require('./commands/analyze');
const refactorCommand = require('./commands/refactor');
const reportCommand = require('./commands/report');
const initCommand = require('./commands/init');

const program = new Command();

console.log(chalk.blue('  _____     _       _   _                 '));
console.log(chalk.blue(' |  __ \\   | |     | | (_)                '));
console.log(chalk.blue(' | |__) |__| |_   _| |_ _ _ __   __ _ ___ '));
console.log(chalk.blue(' |  ___/ _ \\ | | | | __| | \'_ \\ / _` / __|'));
console.log(chalk.blue(' | |  |  __/ | |_| | |_| | | | | (_| \\__ \\'));
console.log(chalk.blue(' |_|   \\___|_|\\__,_|\\__|_|_| |_|\\__, |___/'));
console.log(chalk.blue('                                 __/ |    '));
console.log(chalk.blue('                                |___/     '));
console.log('');
console.log(chalk.green('MasterPrompt CLI - Framework de Développement Complet'));
console.log('');

program
  .name('masterprompt')
  .description('CLI pour le framework MasterPrompt - Développement moderne, sécurisé et productif')
  .version('1.0.0');

// Ajouter les commandes
createCommand(program);
analyzeCommand(program);
refactorCommand(program);
reportCommand(program);
initCommand(program);

// Gestion des erreurs
program.on('command:*', (operands) => {
  console.error(chalk.red(`Commande inconnue: ${operands[0]}`));
  console.log(chalk.yellow('Utilisez --help pour voir les commandes disponibles.'));
  process.exit(1);
});

program.parse();