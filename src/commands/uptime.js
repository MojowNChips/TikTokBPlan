/**
 * Commande uptime - Affiche le temps d'activité du serveur VPS.
 *
 * Cette commande retourne depuis combien de temps le serveur est allumé,
 * la charge moyenne et le nombre d'utilisateurs connectés.
 */
export default {
  name: 'uptime',
  description: 'Affiche le temps d\'activité du serveur',

  /**
   * Exécute la commande uptime.
   * @returns {Promise<Object>} - Résultat contenant les informations de charge
   */
  async execute() {
    const command = 'uptime';
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