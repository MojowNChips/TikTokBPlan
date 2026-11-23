# VPS Connection Plugin - DETAIL

## Aperçu
Plugin permettant une connexion SSH sécurisée vers des serveurs VPS (Virtual Private Servers) via DeepSeek Harness.

## Fonctionnalités
- Connexion SSH avec authentification par mot de passe ou clé privée
- Terminal interactif pour l'exécution de commandes
- Saisie sécurisée des mots de passe (masquage)
- Commandes intégrées : `ls`, `pwd`, `cat`, `uptime`
- Gestion interactive des invites

## Utilisation
1. Initialiser la connexion SSH avec `connect(host, port, username, passwordOrKey)`
2. Exécuter des commandes avec `executeCommand(command)`
3. Saisir des mots de passe de manière sécurisée avec `getSecurePassword(prompt)`
4. Fermer la connexion avec `disconnect()`

## Sécurité
- Les mots de passe ne sont jamais stockés en clair
- Saisie masquée dans l'interface terminal
- Aucune trace des credentials dans les logs

## Dépendances
- Package `ssh2` pour les connexions SSH
- Module `readline` pour les invites interactives