/**
 * Commande cat - Affiche le contenu d'un fichier sur le serveur VPS.
 *
 * Cette commande retourne le contenu d'un fichier spécifié.
 * Attention : les très grands fichiers peuvent provoquer une sortie importante.
 */
export default {
  name: 'cat',
  description: 'Affiche le contenu d\'un fichier',

  /**
   * Exécute la commande cat.
   * @param {Object} options - Options de la commande
   * @param {string} options.filename - Chemin du fichier à afficher
   * @returns {Promise<Object>} - Résultat contenant le contenu du fichier
   */
  async execute(options = {}) {
    const filename = options.filename;

    if (!filename) {
      return {
        success: false,
        error: 'Nom de fichier requis pour la commande cat',
        stdout: '',
        stderr: '',
        exitCode: 1
      };
    }

    const command = `cat "${filename}"`;
    return this.sshService.executeCommand(command);
  },

  /**
   * Valide les options de la commande.
   * @param {Object} options - Options à valider
   * @returns {boolean} - true si valides
   */
  validateOptions(options) {
    return options && options.filename ? true : false;
  }
};