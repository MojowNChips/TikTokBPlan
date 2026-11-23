import VpsSshService from './ssh-service.js';
import TerminalHandler from './terminal-handler.js';
import InteractivePrompt from './interactive-prompt.js';

/**
 * Plugin VPS Connection - Gestion des connexions SSH vers des serveurs virtuels privés.
 * Ce module est le point d'entrée principal du plugin DeepSeek Harness.
 */
export default class VpsConnectionPlugin {
  constructor(config = {}) {
    this.config = {
      host: config.host || '',
      port: config.port || 22,
      username: config.username || '',
      password: config.password || '',
      promptConfig: config.promptConfig || {},
      ...config
    };

    this.sshService = new VpsSshService(this.config);
    this.terminalHandler = new TerminalHandler(this.sshService);
    this.interactivePrompt = new InteractivePrompt(this.config);

    this.initialized = false;
  }

  /**
   * Initialise le plugin et ses composants.
   * @returns {Promise<void>}
   */
  async init() {
    if (this.initialized) {
      return;
    }

    await this.sshService.init();
    await this.terminalHandler.init();
    await this.interactivePrompt.init();

    this.initialized = true;
    console.log('[VPS Plugin] Plugin initialisé avec succès');
  }

  /**
   * Démarre une connexion SSH vers le serveur VPS.
   * @param {Object} connectionConfig - Configuration de la connexion
   * @param {string} connectionConfig.host - Adresse du serveur
   * @param {number} connectionConfig.port - Port SSH (par défaut: 22)
   * @param {string} connectionConfig.username - Nom d'utilisateur
   * @param {string} connectionConfig.password - Mot de passe (optionnel, clavier interactif)
   * @returns {Promise<Object>} - Résultat de la connexion
   */
  async connect(connectionConfig) {
    try {
      await this.sshService.connect(connectionConfig);
      return {
        success: true,
        message: 'Connexion SSH établie avec succès'
      };
    } catch (error) {
      console.error('[VPS Plugin] Erreur de connexion:', error);
      return {
        success: false,
        message: error.message || 'Erreur inconnue lors de la connexion'
      };
    }
  }

  /**
   * Envoie une commande sur la connexion SSH active.
   * @param {string} command - Commande à exécuter
   * @returns {Promise<Object>} - Résultat de l'exécution
   */
  async executeCommand(command) {
    if (!this.sshService.isConnected()) {
      throw new Error('Aucune connexion SSH active');
    }
    return this.terminalHandler.executeCommand(command);
  }

  /**
   * Gère une invite de mot de passe interactif.
   * @param {string} promptMessage - Message d'invite à afficher
   * @returns {Promise<string>} - Mot de passe saisi
   */
  async getSecurePassword(promptMessage) {
    return this.interactivePrompt.getPassword(promptMessage);
  }

  /**
   * Arrête la connexion SSH en cours.
   * @returns {Promise<void>}
   */
  async disconnect() {
    await this.sshService.disconnect();
    console.log('[VPS Plugin] Connexion fermée');
  }

  /**
   * Vérifie si une connexion SSH est active.
   * @returns {boolean} - Statut de connexion
   */
  isConnected() {
    return this.sshService.isConnected();
  }

  /**
   * Ajoute une commande personnalisée au gestionnaire de terminal.
   * @param {string} name - Nom de la commande
   * @param {Function} callback - Fonction de rappel exécutée lors de l'exécution
   */
  registerCommand(name, callback) {
    this.terminalHandler.registerCommand(name, callback);
  }
}

/**
 * Initialise le plugin quand le module est importé.
 * @param {Object} config - Configuration du plugin
 * @returns {Promise<VpsConnectionPlugin>}
 */
export async function createVpsPlugin(config) {
  const plugin = new VpsConnectionPlugin(config);
  await plugin.init();
  return plugin;
}