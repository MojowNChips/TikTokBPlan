# Plan de test pour le plugin de connexion VPS

## 1. Test de connexion SSH valide (mock SSH server)

**Scénario détaillé :**
- Démarrer un serveur SSH mock (ex: mock-sshd)
- Configurer le serveur avec une clé SSH valide
- Utiliser le plugin pour se connecter avec la clé SSH
- Vérifier que la connexion est établie avec succès

**Résultat attendu :**
- La connexion SSH est établie avec succès
- Le terminal du plugin affiche un prompt de shell

**Méthode d'automatisation :**
- Tests unitaires avec des mocks de serveur SSH
- Utilisation de fixtures pour configurer le serveur mock
- Tests d'intégration avec un serveur SSH réel (dans un environnement contrôlé)

**Cas limites à couvrir :**
- Connexion avec clé SSH uniquement (pas de mot de passe)
- Connexion avec mot de passe uniquement (pas de clé SSH)
- Connexion avec les deux (clé et mot de passe)

## 2. Test avec mauvais mot de passe (vérifier qu'aucun replay)

**Scénario détaillé :**
- Utiliser le plugin pour se connecter avec un mot de passe incorrect
- Vérifier que le plugin ne tente pas de se reconnecter après un échec

**Résultat attendu :**
- Le plugin affiche une erreur d'authentification
- Aucune tentative de reconnexion n'est effectuée

**Méthode d'automatisation :**
- Tests unitaires avec des mocks de serveur SSH qui retournent un mot de passe incorrect
- Vérification que le plugin ne tente pas de reconnecter après un échec

**Cas limites à couvrir :**
- Nombre maximal de tentatives de connexion avant abandon
- Comportement en cas de blocage temporaire (ex: trop de tentatives)

## 3. Test délai timeout de connexion

**Scénario détaillé :**
- Configurer un serveur SSH qui ne répond pas (délai très long)
- Utiliser le plugin pour se connecter
- Vérifier que le plugin abandonne la connexion après le délai défini

**Résultat attendu :**
- Le plugin affiche un message d'erreur de timeout
- La connexion est abandonnée

**Méthode d'automatisation :**
- Tests unitaires avec des mocks de serveur SSH qui ne répondent pas
- Tests d'intégration avec un serveur SSH réel configuré pour un délai long

**Cas limites à couvrir :**
- Délai de timeout configurable
- Comportement en cas de réseau instable (perte de paquets)

## 4. Test interface interactive de saisie MDP

**Scénario détaillé :**
- Utiliser le plugin pour se connecter à un serveur SSH
- Entrer un mot de passe interactif
- Vérifier que le mot de passe est masqué dans l'interface

**Résultat attendu :**
- Le mot de passe est masqué (caractères masqués)
- Le plugin ne stocke pas le mot de passe en clair

**Méthode d'automatisation :**
- Tests d'interface utilisateur (UI) avec des scripts d'automatisation (ex: Selenium)
- Tests unitaires pour vérifier le masquage du mot de passe

**Cas limites à couvrir :**
- Gestion des erreurs de saisie (mot de passe vide, trop court)
- Comportement en cas de coupure de connexion pendant la saisie

## 5. Test gestion des erreurs SSH (host non trouvé, etc.)

**Scénario détaillé :**
- Utiliser le plugin pour se connecter à un hôte non existant
- Vérifier que le plugin gère correctement l'erreur

**Résultat attendu :**
- Le plugin affiche un message d'erreur clair
- Aucune tentative de connexion n'est effectuée

**Méthode d'automatisation :**
- Tests unitaires avec des mocks de serveur SSH qui retournent des erreurs (host non trouvé, refus de connexion, etc.)
- Tests d'intégration avec des serveurs SSH réels configurés pour retourner des erreurs

**Cas limites à couvrir :**
- Gestion des erreurs réseau (perte de paquets, timeout)
- Gestion des erreurs d'authentification (mot de passe incorrect, clé invalide)

## 6. Test sécurité (vérifier que les MDP ne sont pas loggués)

**Scénario détaillé :**
- Utiliser le plugin pour se connecter à un serveur SSH
- Vérifier que les MDP ne sont pas stockés dans les logs ou les fichiers temporaires

**Résultat attendu :**
- Aucune trace des MDP dans les logs ou fichiers temporaires
- Les MDP sont uniquement stockées en mémoire pendant la session

**Méthode d'automatisation :**
- Tests de sécurité avec analyse des logs et des fichiers temporaires
- Vérification que les MDP ne sont pas écrites sur disque

**Cas limites à couvrir :**
- Gestion des erreurs pendant la connexion (ex: timeout)
- Vérification que les MDP ne sont pas affichées dans l'interface

## 7. Test exécution commandes dans le terminal

**Scénario détaillé :**
- Utiliser le plugin pour exécuter une commande sur le serveur SSH
- Vérifier que la commande est exécutée correctement

**Résultat attendu :**
- La sortie de la commande est affichée dans le terminal du plugin
- La commande est exécutée avec les permissions appropriées

**Méthode d'automatisation :**
- Tests unitaires avec des mocks de commandes SSH
- Tests d'intégration avec un serveur SSH réel

**Cas limites à couvrir :**
- Gestion des commandes complexes (pipes, redirections)
- Gestion des erreurs de commande (commande non trouvée, permissions insuffisantes)

## 8. Test fermeture propre de la connexion

**Scénario détaillé :**
- Utiliser le plugin pour se connecter à un serveur SSH
- Fermer la connexion de manière propre (ex: en tapant 'exit' ou en utilisant Ctrl+D)
- Vérifier que la connexion est fermée correctement

**Résultat attendu :**
- La connexion est fermée proprement
- Aucune ressource n'est laissée en cours d'exécution

**Méthode d'automatisation :**
- Tests unitaires avec des mocks de fermeture de connexion
- Tests d'intégration avec un serveur SSH réel

**Cas limites à couvrir :**
- Gestion des erreurs pendant la fermeture (ex: connexion interrompue)
- Vérification que les ressources sont libérées correctement