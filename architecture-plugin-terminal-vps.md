# Architecture Plugin Terminal VPS Sécurisé

## 1. Schéma de Communication Détaillé

### 1.1 Flux Global

Le plugin terminal VPS suit ce schéma de communication :

```
┌─────────────────────────────────────────────────────────────────┐
│                   DSH Host Environment                          │
│                                                                 │
│  ┌─────────────┐  ┌─────────────────┐  ┌──────────────────┐       │
│  │  ctx.ssh    │  │ ctx.authorization│  │ ctx.terminalCtrl│       │
│  │ (SSH Service)│ │ (Auth Flows)   │  │ (Terminal API)  │       │
│  └──────┬──────┘  └───────┬─────────┘  └───────┬──────────┘       │
│         │                │                 │                 │
│         │                │                 │                 │
│  ┌──────▼──────┐  ┌───────▼───────┐  ┌──────▼────────┐         │
│  │ Connexion   │  │ Demande MDP   │  │ Création      │         │
│  │ SSH Init    │  │ Interactif    │  │ Terminal PTY  │         │
│  └──────┬──────┘  └───────┬───────┘  └──────┬────────┘         │
│         │                │                │                 │
│         │                │                │                 │
│  ┌──────▼──────┐  ┌───────▼───────┐  ┌──────▼────────┐         │
│  │ Canal SSH   │  │ Prompt Sécurized│  │ Terminal Live │         │
│  │ (Socket)    │  │ (Secret Input)  │  │ Rendering     │         │
│  └──────┬──────┘  └───────┬───────┘  └──────┬────────┘         │
│         │                │                │                 │
│         │                │                │                 │
│  └────────────►│◄────────────┘◄──────────┘◄────────────┘         │
│  (Commandes/Output)                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

### 1.2 Acteurs Clés

1. **ctx.ssh** : Service SSH non reconnectant (1 session SSH = 1 operation)
   - `ready`: Vérifie la coordination distante avant lancement
   - `connectStream(endpoint)`: Forward un flux authentifié via canal SSH
   - `request(method, params, result)`: Opération helper privé
   - `dispose()`: Démontage propre

2. **ctx.authorization** : Gestion des flows de credentials
   - `registerFlow(flow)`: Enregistre un flow d'autorization
   - `begin(request)`: Lance une attempt d'autorisation
   - Types: `AuthorizationPrompt` avec `kind: 'secret'` pour MDP

3. **ctx.terminalController** / **ctx.subprocess** : Gestion terminal
   - `create(agent, request, signal)`: Alloue terminal user shell
   - `spawnTerminal(spec)`: Lance processus terminal PTY
   - TerminalShell: shell, args, name

### 1.3 Flux de Communication Inter-Agent

```
Agent Plugin → Cordis Host → SSH Service → VPS Remote
     │                   │
     │                   ▼
     │            (Auth Flow via ctx.authorization)
     │                   │
     │                   ▼
     │          Terminal PTY Creation
     │                   │
     │                   ▼
     │          Interactive Prompt ←→ User
     │                   │
     │                   ▼
     │          SSH Commands Execution
     │                   │
     ▼                   ▼
User Interface ←──► Agent Reflexion ←──▏
```

## 2. Points de Sécurité Critiques

### 2.1 Sécurité des Mots de Passe

**Ne jamais logger le MDP en clair :**
- Utiliser `AuthorizationPrompt` avec `kind: 'secret'`
- Le type `AuthorizationPrompt` possède un mode `secret` qui masque la saisie
- Ne pas stocker les credentials dans les fichiers de log ou état

```typescript
// Exemple de prompt sécurisé
const prompt: AuthorizationPrompt = {
  kind: 'secret',
  message: 'Mot de passe VPS :',
  placeholder: '••••••••'
};

// Via ctx.authorization.begin()
const outcome = await ctx.authorization.begin({
  key: 'vps-credentials',
  method: 'password',
  interaction: {
    notify: (notice) => showNotice(notice.message),
    prompt: async (prompt) => {
      const input = await secureInput(prompt.message); // masque l'entrée
      return input;
    }
  },
  signal: abortSignal
});
```

### 2.2 Isolation des Connexions SSH

- Chaque connexion SSH est **non reconnectante** (comme indiqué dans la description du service)
- Perte de connexion invalide toutes les opérations actives
- Utiliser `dispose()` pour le démontage propre
- Gérer les signaux d'annulation via `AbortSignal`

### 2.3 Gestion des Flux d'Authorization

- **Une attempt par clé** : `one attempt per key at a time`
- Deux plugins revendiquant la même key entraînent que le dernier gagne
- Utiliser des clés uniques par session/plugin
- Appeler `cancel(key)` pour arrêter une attempt en cours

### 2.4 Sécurité du Terminal

- Les terminaux sont gérés par `ctx.terminalController` / `ctx.subprocess`
- Les shells s'exécutent dans des environnements sandbox
- Utiliser `TerminalSpawnSpec` avec des dimensions contrôlées
- Ne pas autoriser l'exécution de commandes sensibles sans validation

## 3. Choix Technologiques avec Justifications

### 3.1 Service SSH : `ctx.ssh` (Recommandé)

**Avantages :**
- Intégration native DSH
- Types TypeScript complets via Zod validation
- Gestion intégrée des signaux d'annulation
- API stream-oriented via `connectStream`
- Mode non-reconnecting forcé garantit la propreté

**Inconvénients :**
- Une session SSH = une opération (pas de reconnexion automatique)
- Doit être injecté en dur via configuration du contexte

**Alternative : bibliothèques externes**
- `node-sshd` / `ssh2` : Plus de flexibilité mais responsabilités sécurité
- Complexité accrue de gestion des clés, sessions, reconnexions
- Risque de logging accidental des credentials

### 3.2 Gestion des Credentials : `ctx.authorization` (Recommandé)

**Avantages :**
- Flux d'autorization conçus pour MDP/securisés
- Type `AuthorizationPrompt` avec `kind: 'secret'` built-in
- Gestion étatique par key (une attempt à la fois)
- Interface `AuthorizationInteraction` avec `prompt()` sécurisé

**Alternative : invites natives**
- `readline` natif : pas de masquage automatique
- `inquirer` : nécessite configuration manuelle du mask
- Risque plus élevé de logging

### 3.3 Contrôle Terminal : `ctx.terminalController` / `ctx.subprocess`

**Avantages :**
- Terminals PTY avec contrôle fin (rows, cols, shell)
- `SubprocessTerminalSpawnSpec` complet en types
- Stream input/output via `TerminalSendOperation`
- Intégration avec l'écosystème DSH

**Alternative : bibliothèques PTY**
- `pty.js` : Standalone, pas d'intégration DSH
- Gestion manuelle des signaux et cleanup
- Pas d'intégration avec authorization flows

### 3.4 Communication Utilisateur : `ctx.actionCards` (Alternative)

Pour les décisions utilisateur non critiques :
- Cartes d'action avec verbs personnalisés
- Interface graphique dans l'UI
- Moins adapté pour prompts secrets longs

## 4. Architecture Modulaire pour la Maintenance

### 4.1 Structure du Plugin

```
plugin-vps-terminal/
├── cordis.patch.yml          # Manifest du plugin
├── package.json              # Dépendances
├── src/
│   ├── index.ts              # Point d'entrée
│   ├── ssh-service.ts        # Wrapper ctx.ssh
│   ├── auth-service.ts       # Wrapper ctx.authorization
│   ├── terminal-service.ts   # Wrapper ctx.terminalController
│   ├── types.ts              # Types spécifiques VPS
│   └── ui/
│       ├── password-prompt.ts  # Prompt MDP sécurisé
│       └── terminal-display.ts # Affiche terminal output
└── README.md                 # Documentation
```

### 4.2 Points d'Extension

1. **Nouvelles méthodes SSH** : Étendre via `ctx.ssh.request(method, params, result)`
2. **Nouvelles flows d'auth** : Register via `ctx.authorization.registerFlow()`
3. **Nouveaux types de terminal** : Personnaliser `SubprocessTerminalSpawnSpec`
4. **Personnalisation UI** : Remplacer les composants `ui/` sans toucher au core

### 4.3 Gestion des Versions

- Le plugin s'installe via `plugin_manager install_bundle`
- Mises à jour via `plugin_manager updateBundle`
- Exemption de version disponible via `set_version_exemption` (avec risk acceptance)

## 5. Plan de Test Fonctionnel

### 5.1 Tests Unitaires

| Test | Description | Critères |
|------|-------------|----------|
| `testSSHConnection` | Vérifie la connexion SSH init | `ready` résout, `connectStream` crée socket |
| `testAuthFlow` | Teste le flow d'autorization | `begin` retourne `authorized`, pas de logging MDP |
| `testTerminalCreation` | Crée un terminal PTY | Terminal visible, shell par défaut actif |
| `testPasswordPrompt` | Affiche prompt MDP | Masquage visuel, input captured correctement |

### 5.2 Tests d'Intégration

1. **Connexion complète** :
   - Initier connexion SSH via `ctx.ssh.connectStream()`
   - Lancer flow d'autorization MDP
   - Saisir mot de passe dans terminal masqué
   - Exécuter commande distante
   - Vérifier output terminal

2. **Scénarios d'erreur** :
   - Connexion SSH refusée
   - Timeout d'attente MDP
   - Annulation flow via `cancel(key)`
   - Fermeture terminal inattendue

3. **Sécurité** :
   - Vérifier absence de MDP dans logs
   - Tester avec signal AbortSignal
   - Vérifier cleanup via `dispose()`

### 5.3 Tests de Sécurité

- [ ] Scanner les logs pour détecter toute fuite de MDP
- [ ] Tester la résistance aux attaques de side-channel
- [ ] Vérifier le masquage clavier dans le prompt
- [ ] Tester avec des environnements multi-utilisateurs

## 6. Exemple de Flux Interactif pour Mot de passe

### 6.1 Scénario : Connexion SSH avec Authentification par Mot de passe

```typescript
// 1. Initialisation de la connexion SSH
const ssh = ctx.ssh;
await ssh.ready; // Attendre la coordination distante

// 2. Démarrage du flow d'autorization du mot de passe
const authKey = 'vps-connection-' + sessionId;
await ctx.authorization.registerFlow({
  key: authKey as CredentialKey,
  label: 'Connexion VPS mot de passe',
  methods: [{ id: 'password', label: 'Mot de passe' }],
  run: async (session) => {
    // 3. Lancer la demande d'autorization
    const outcome = await ctx.authorization.begin({
      key: authKey,
      method: 'password',
      interaction: {
        notify: (notice) => {
          // Afficher notice à l'utilisateur
          showNotice(notice.message);
        },
        prompt: async (prompt) => {
          // Gérer le prompt selon son type
          if (prompt.kind === 'secret') {
            // Saisie sécurisée - masque l'entrée
            const password = await getSecureInput(prompt.message);
            // Committer le credential
            session.commit({
              kind: 'api-key',
              key: password,
              env: {}
            });
            return password;
          }
          return '';
        }
      },
      signal: session.signal // Signal d'annulation
    });

    // 4. Traiter le résultat
    if (outcome.status === 'authorized') {
      // 5. Établir la connexion SSH
      const endpoint = await ssh.request({
        method: 'createEndpoint',
        params: { auth: outcome },
        result: z.object({ endpoint: z.any() })
      });
      
      const socket = await ssh.connectStream(endpoint);
      
      // 6. Créer un terminal interactif
      const terminal = await ctx.terminalController.create({
        agent: currentAgent,
        request: {
          title: 'Connexion VPS Secure',
          cols: 80,
          rows: 24,
          shell: '/bin/bash'
        }
      });
      
      // 7. Envoyer le mot de passe au terminal
      await terminal.send(`password: ${password}\n`);
      
      // 8. Lire la réponse
      const output = await terminal.read();
      showOutput(output);
      
    } else if (outcome.status === 'cancelled') {
      showNotice('Connexion annulée par l\'utilisateur');
    }
  }
});
```

### 6.2 Gestion des Cas d'Erreur

```typescript
try {
  // ... flux complet ci-dessus ...
} catch (error) {
  // Gérer les erreurs spécifiques
  if (error.code === 'NO_FLOW') {
    showError('Aucun flow d\'autorization enregistré pour cette clé');
  } else if (error.code === 'ALREADY_IN_FLIGHT') {
    showError('Une tentative d\'autorization est déjà en cours');
  } else if (error.code === 'UNKNOWN_METHOD') {
    showError('Méthode d\'authentification inconnue');
  } else {
    showError('Erreur inattendue: ' + error.message);
  }
  
  // Nettoyage
  await ctx.authorization.cancel(authKey);
  await ssh.dispose();
}
```

### 6.3 Exemple d'Affichage Terminal

```
┌─────────────────────────────────────────────┤ Connexion VPS Secure ├─────────────────────────────────────┐
│                                                                                                     │
│   Linux version 5.15.0-91-generic (Ubuntu 22.04.3 LTS) x86_64                                        │
│                                                                                                     │
│   Last login: Mon Jan  1 12:00:00 2024 from 192.168.1.100                                           │
│                                                                                                     │
│   user@VPS:~$                                                                                         │
│                                                                                                     │
│   [Commandes en cours...]                                                                             │
│                                                                                                     │
└───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Conclusion

Cette architecture exploite les services natives DSH pour offrir :
- ✅ Sécurité intégrée via `ctx.authorization` avec prompts `secret`
- ✅ Gestion SSH native via `ctx.ssh` avec cleanup automatique
- ✅ Contrôle terminal PTY via `ctx.terminalController` / `ctx.subprocess`
- ✅ Modularité via structure de plugin claire
- ✅ Tests complets et scénarios d'erreur gérés

Le plugin peut être étendu pour supporter :
- Clés SSH alternatives
- Authentification multifacteur
- Tunneling de ports
- Gestion de sessions persistantes