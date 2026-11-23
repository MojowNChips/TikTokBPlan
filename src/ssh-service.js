/**
 * SSH Service - Gestion de la connexion SSH vers les serveurs VPS.
 * Utilise le package 'ssh2' pour les connexions sécurisées.
 *
 * Ce module encapsule toute la logique de connexion SSH,
 * y gestion des clés, authentification et état de connexion.
 */
import { Client } from 'ssh2';

/**
 * Configuration par défaut pour la connexion SSH.
 * @typedef {Object} SshConfig
 * @property {string} host - Adresse IP ou nom d'hôte du serveur
 * @property {number} [port=22] - Port SSH
 * @property {string} [username] - Nom d'utilisateur
 * @property {string} [password] - Mot de passe (non recommandé pour la production)
 * @property {string} [privateKey] - Chemin vers la clé privée SSH
 * @property {string} [passphrase] - Passphrase de la clé privée
 */

/**
 * Classe pour gérer les connexions SSH vers des serveurs VPS.
 */
export default class VpsSshService {
  constructor(config = {}) {
    this.config = {
      host: config.host || '',
      port: config.port || 22,
      username: config.username || '',
      password: config.password || '',
      privateKey: config.privateKey || '',
      passphrase: config.passphrase || ''
    };

    this.connection = null;
    this.isConnectedFlag = false;
    this.client = new Client();
  }

  /**
   * Initialise le client SSH et configure les événements.
   * @returns {Promise<void>}
   */
  async init() {
    return new Promise((resolve) => {
      this.client.on('ready', () => {
        this.isConnectedFlag = true;
        console.log('[SSH Service] Connexion SSH prête');
        resolve();
      });

      this.client.on('error', (err) => {
        console.error('[SSH Service] Erreur de connexion SSH:', err.message);
        this.isConnectedFlag = false;
        resolve();
      });

      this.client.on('close', () => {
        this.isConnectedFlag = false;
        console.log('[SSH Service] Connexion SSH fermée');
        resolve();
      });

      // Nettoyage à la destruction
      this.client.on('end', () => {
        this.isConnectedFlag = false;
      });

      resolve();
    });
  }

  /**
   * Établit une connexion SSH vers le serveur VPS.
   * Utilise l'authentification par mot de passe ou par clé privée.
   * @param {Object} connectionConfig - Configuration de connexion
   * @param {string} connectionConfig.hôte - Adresse du serveur
   * @param {number} [connectionConfig.port=22] - Port SSH
   * @param {string} [connectionConfig.username] - Nom d'utilisateur
   * @param {string} [connectionConfig.password] - Mot de passe
   * @param {string} [connectionConfig.privateKey] - Chemin vers clé privée
   * @param {string} [connectionConfig.passphrase] - Passphrase de la clé
   * @returns {Promise<void>}
   */
  async connect(connectionConfig) {
    return new Promise((resolve, reject) => {
      const config = {
        ...this.config,
        ...connectionConfig
      };

      if (!config.host) {
        reject(new Error('Adresse hôte SSH requise'));
        return;
      }

      if (!config.username) {
        reject(new Error('Nom d'utilisateur SSH requis'));
        return;
      }

      const connConfig = {
        host: config.host,
        port: config.port,
        username: config.username
      };

      // Authentification par clé privée si fournie
      if (config.privateKey) {
        connConfig.privateKey = require('fs').readFileSync(config.privateKey);
        if (config.passphrase) {
          connConfig.passphrase = config.passphrase;
        }
      }
      // Authentification par mot de passe
      else if (config.password) {
        connConfig.password = config.password;
      }

      this.connection = this.client.connect(connConfig);

      // Gestionnaire de réussite de la connexion
      this.connection.on('ready', () => {
        this.isConnectedFlag = true;
        console.log(`[SSH Service] Connecté à ${config.host}:${config.port}`);
        resolve();
      });

      // Gestionnaire d'erreur
      this.connection.on('error', (err) => {
        console.error('[SSH Service] Erreur de connexion:', err.message);
        this.isConnectedFlag = false;
        reject(new Error(`Connexion échouée: ${err.message}`));
      });

      // Gestionnaire de fermeture
      this.connection.on('close', () => {
        this.isConnectedFlag = false;
        console.log('[SSH Service] Connexion fermée');
        resolve();
      });
    });
  }

  /**
   * Ferme la connexion SSH en cours.
   * @returns {Promise<void>}
   */
  async disconnect() {
    if (this.connection) {
      return new Promise((resolve) => {
        this.connection.end();
        resolve();
      });
    }
    return Promise.resolve();
  }

  /**
   * Vérifie si une connexion SSH est active.
   * @returns {boolean} - true si connecté, false sinon
   */
  isConnected() {
    return this.isConnectedFlag && this.connection ? this.connection.connected : false;
  }

  /**
   * Crée un tunnel SSH vers le serveur.
   * @param {Object} tunnelConfig - Configuration du tunnel
   * @param {number} tunnelConfig.localPort - Port local
   * @param {number} tunnelConfig.remotePort - Port distant
   * @param {string} [tunnelConfig.remoteHost] - Hôte distant (par défaut: localhost)
   * @returns {Promise<Object>} - Informations sur le tunnel
   */
  async createTunnel(tunnelConfig) {
    if (!this.isConnected()) {
      throw new Error('Aucune connexion SSH active pour créer un tunnel');
    }

    return new Promise((resolve, reject) => {
      const { localPort, remotePort, remoteHost = 'localhost' } = tunnelConfig;

      this.connection.forwardOut(
        'localhost',
        localPort,
        '127.0.0.1',
        remotePort,
        (err, stream) => {
          if (err) {
            reject(new Error(`Erreur création tunnel: ${err.message}`));
            return;
          }

          console.log(`[SSH Service] Tunnel créé: localhost:${localPort} -> ${remoteHost}:${remotePort}`);
          resolve({
            localPort,
            remotePort,
            remoteHost,
            stream
          });
        }
      );
    });
  }
}