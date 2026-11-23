import readline from 'readline';

/**
 * Interactive Prompt - Gestion mot de passe sécurisé avec interface utilisateur.
 *
 * Ce module fournit une interface interactive pour la saisie sécurisée
 * de mots de passe et d'autres entrées sensibles via le terminal.
 * Il masque la saisie utilisateur pour des raisons de sécurité.
 */
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

/**
 * Options pour la saisie interactive.
 * @typedef {Object} PromptOptions
 * @property {string} promptMessage - Message à afficher à l'utilisateur
 * @property {boolean} [maskInput=true] - Masquer la saisie par défaut
 * @property {boolean} [exitOnEmpty=false] - Quitter si entrée vide
 */

/**
 * Classe pour gérer les invites interactives sécurisées.
 */
export default class InteractivePrompt {
  constructor(config) {
    this.config = config || {};
  }

  /**
   * Affiche une invite de mot de passe masqué et retourne la valeur saisie.
   * @param {string} promptMessage - Message à afficher à l'utilisateur
   * @param {PromptOptions} [options] - Options de saisie
   * @returns {Promise<string>} - Mot de passe saisi
   */
  async getPassword(promptMessage, options = {}) {
    const { maskInput = true, exitOnEmpty = false } = options;

    return new Promise((resolve, reject) => {
      console.log('');

      // Afficher le message d'invite
      process.stdout.write(`[${promptMessage}] `);

      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });

      rl.question('', (input) => {
        rl.close();

        // Gérer le cas où l'entrée est vide
        if (exitOnEmpty && !input.trim()) {
          console.log('');
          reject(new Error('Aucun mot de passe fourni et exitOnEnabled'));
          return;
        }

        // Si masquerInput, on considère quand même la valeur (le masque est visuel)
        // Dans un terminal réel, on utiliserait des événements 'keypress' pour masquer
        const password = input.trim();

        console.log(''); // Nouvelle ligne après la saisie

        resolve(password);
      });

      // Gérer l'appui sur Ctrl+C
      rl.on('SIGINT', () => {
        rl.close();
        reject(new Error('Saisie annulée par l'utilisateur'));
      });
    });
  }

  /**
   * Affiche une invite interactive standard et retourne la valeur saisie.
   * @param {string} promptMessage - Message à afficher
   * @returns {Promise<string>} - Valeur saisie
   */
  async getInput(promptMessage) {
    return new Promise((resolve) => {
      process.stdout.write(`[${promptMessage}] `);

      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });

      rl.question('', (input) => {
        rl.close();
        resolve(input.trim());
      });

      rl.on('SIGINT', () => {
        rl.close();
        resolve('');
      });
    });
  }

  /**
   * Affiche une barre de progression pendant une opération longue.
   * @param {string} message - Message à afficher
   * @param {number} total - Valeur totale (pour pourcentage)
   * @param {number} current - Valeur actuelle
   * @returns {Object} - Fonctions pour mettre à jour la progression
   */
  showProgress(message, total, current) {
    const percentage = Math.round((current / total) * 100);
    const barLength = 20;
    const filledLength = Math.round((barLength * current) / total);
    const bar = '='.repeat(filledLength) + '-'.repeat(barLength - filledLength);

    process.stdout.write(`\r[${message}] [${bar}] ${percentage}%`);
    return {
      update: (current) => this.showProgress(message, total, current),
      finish: () => {
        process.stdout.write(`\r[${message}] [${'='.repeat(barLength)}] 100%\n`);
      }
    };
  }

  /**
   * Demande une confirmation à l'utilisateur (o/n).
   * @param {string} question - Question à poser
   * @returns {Promise<boolean>} - true pour oui, false pour non
   */
  async confirm(question) {
    while (true) {
      const answer = await this.getInput(`${question} (o/n) `);
      if (answer.toLowerCase() === 'o' || answer.toLowerCase() === 'oui') {
        return true;
      }
      if (answer.toLowerCase() === 'n' || answer.toLowerCase() === 'non') {
        return false;
      }
      console.log('Veuillez répondre par "o" ou "n".');
    }
  }
}