/**
 * Commande ls - Liste des fichiers et répertoires sur le serveur VPS.
 *
 * Cette commande exécute 'ls' (ou 'dir' sous Windows) sur le serveur distant
 * et retourne la liste des fichiers et répertoires.
 */
export default {
  name: 'ls',
  description: 'Liste les fichiers et répertoires du serveur distant',
  alias: ['dir'],

  /**
   * Exécute la commande ls.
   * @param {Object} options - Options de la commande
   * @param {string} [options.path] - Chemin spécifique à lister (par défaut: répertoire courant)
   * @returns {Promise<Object>} - Résultat de l'exécution
   */
  async execute(options = {}) {
    const path = options.path || '.';
    const command = `ls -la ${path}`;

    return this.sshService.executeCommand(command);
  },

  /**
   * Valide les options de la commande.
   * @param {Object} options - Options à valider
   * @returns {boolean} - true si valides
   */
  validateOptions(options) {
    return true;
  }
};