/**
 * Commande pwd - Affiche le répertoire de travail courant sur le serveur VPS.
 *
 * Cette commande retourne le chemin du répertoire de travail actuel
 * sur le serveur distant.
 */
export default {
  name: 'pwd',
  description: 'Affiche le répertoire de travail courant',

  /**
   * Exécute la commande pwd.
   * @returns {Promise<Object>} - Résultat contenant le répertoire courant
   */
  async execute() {
    const command = 'pwd';
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