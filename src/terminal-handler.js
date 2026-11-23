import VpsSshService from './ssh-service.js';

/**
 * Terminal Handler - Gestion des commandes dans le terminal SSH.
 *
 * Ce module gère l'envoi de commandes sur une connexion SSH active,
 * la capture des sorties (stdout/stderr) et le traitement des résultats.
 */
export default class TerminalHandler {
  constructor(sshService) {
    this.sshService = sshService;
    this.commandHistory = [];
    this.maxHistory = 50;
  }

  /**
   * Initialise le gestionnaire de terminal.
   * @returns {Promise<void>}
   */
  async init() {
    // Initialisation quelconque du terminal
    console.log('[Terminal Handler] Initialisé');
  }

  /**
   * Exécute une commande sur la connexion SSH active.
   * @param {string} command - La commande à exécuter
   * @returns {Promise<Object>} - Résultat de l'exécution {success, stdout, stderr, exitCode}
   */
  async executeCommand(command) {
    if (!this.sshService.isConnected()) {
      return Promise.resolve({
        success: false,
        error: 'Aucune connexion SSH active',
        stdout: '',
        stderr: '',
        exitCode: -1
      });
    }

    return new Promise((resolve) => {
      const conn = this.sshService.connection;

      if (!conn) {
        return resolve({
          success: false,
          error: 'Connexion SSH non établie',
          stdout: '',
          stderr: '',
          exitCode: -1
        });
      }

      // Exécuter la commande
      const exec = conn.exec(command);

      let stdout = '';
      let stderr = '';

      // Collecter la sortie standard
      exec.on('data', (data) => {
        stdout += data.toString();
      });

      // Collecter la sortie d'erreur
      exec.on('stderr', (data) => {
        stderr += data.toString();
      });

      // Gérer la fin de l'exécution
      exec.on('exit', (code) => {
        const result = {
          success: code === 0,
          stdout: stdout.trim(),
          stderr: stderr.trim(),
          exitCode: code
        };

        // Garder l'historique
        this.commandHistory.push({
          command,
          ...result
        });

        // Garder seulement l'historique maximal
        if (this.commandHistory.length > this.maxHistory) {
          this.commandHistory = this.commandHistory.slice(-this.maxHistory);
        }

        resolve(result);
      });

      // Gérer les erreurs d'exécution
      exec.on('error', (err) => {
        resolve({
          success: false,
          error: err.message,
          stdout,
          stderr: stderr.trim(),
          exitCode: -1
        });
      });
    });
  }

  /**
   * Récupète l'historique des commandes exécutées.
   * @param {number} [limit] - Nombre maximum d'entrées à retourner
   * @returns {Array} - Historique des commandes
   */
  getCommandHistory(limit) {
    if (limit && limit > 0) {
      return this.commandHistory.slice(-limit);
    }
    return this.commandHistory;
  }

  /**
   * Envoie un signal au processus en cours d'exécution.
   * @param {string} signal - Signal à envoyer (ex: 'SIGINT', 'SIGTERM')
   */
  sendSignal(signal) {
    if (this.sshService.isConnected()) {
      // Note: Dans une implémentation complète, on garderait une référence
      // au processus en cours et enverrait le signal approprié
      console.log('[Terminal Handler] Signal envoyé:', signal);
    }
  }

  /**
   * Redimensionne le terminal si nécessaire.
   * @param {number} cols - Nombre de colonnes
   * @param {number} rows - Nombre de lignes
   */
  resize(cols, rows) {
    if (this.sshService.isConnected()) {
      // Dans une implémentation complète, on redimensionnerait le terminal SSH
      console.log('[Terminal Handler] Terminal redimensionné:', cols, 'x', rows);
    }
  }

  /**
   * Envoie une saisie clavier au terminal interactif.
   * @param {string} input - Texte à saisir
   */
  sendInput(input) {
    if (this.sshService.isConnected()) {
      console.log('[Terminal Handler] Saisie:', input);
    }
  }
}