# Politique de Confidentialité — n8n TikTok Content Manager

**Dernière mise à jour :** 22 novembre 2026  
**Version :** 1.0  
**Éditeur :** [Ton Nom / Nom de ton entreprise]  
**Contact RGPD / DPO :** [ton@email.com]

---

## 1. Objet et Champ d'Application

Cette politique de confidentialité décrit comment l'application **« n8n TikTok Content Manager »** (ci-après « l'Application », « nous », « notre ») collecte, utilise, stocke et protège les données personnelles des utilisateurs qui s'authentifient via **TikTok Login Kit** et autorisent l'Application à publier du contenu via **TikTok Video Kit / Content Posting API**.

L'Application est un workflow n8n auto-hébergé permettant aux créateurs de contenu et gestionnaires de médias sociaux de :
- S'authentifier sécurisément via OAuth 2.0 (TikTok Login Kit)
- Programmer et publier des vidéos/photos sur leur compte TikTok (Video Kit)
- Gérer leurs brouillons et contenus planifiés

---

## 2. Responsable de Traitement

**Responsable :** [Ton Nom / Raison Sociale]  
**Adresse :** [Ton Adresse Complète]  
**Email DPO / Contact RGPD :** [ton@email.com]  
**Représentant UE (si hors UE) :** [le cas échéant]

---

## 3. Données Collectées

### 3.1 Données reçues de TikTok (via OAuth)

Lors de l'autorisation via **TikTok Login Kit**, nous recevons les champs suivants (selon les scopes demandés) :

| Donnée | Source | Finalité | Base Légale |
|--------|--------|----------|-------------|
| `open_id` | TikTok Login Kit | Identifiant unique utilisateur TikTok | Consentement (Art. 6.1.a RGPD) |
| `union_id` | TikTok Login Kit | Identifiant unifié cross-app (si même propriétaire) | Consentement |
| `avatar_url` | TikTok Login Kit | Photo de profil pour affichage dans l'app | Consentement |
| `display_name` | TikTok Login Kit | Nom d'affichage pour identification | Consentement |
| `email` (si scope `user.info.email`) | TikTok Login Kit | Contact utilisateur, notifications | Consentement |
| `profile_deep_link` | TikTok Login Kit | Lien vers profil TikTok | Consentement |

### 3.2 Données générées par l'Application

| Donnée | Description | Finalité | Base Légale |
|--------|-------------|----------|-------------|
| Access Token TikTok (chiffré) | Token OAuth courte durée (4h) | Appels API Video Kit pour publication | Exécution contrat (Art. 6.1.b) |
| Refresh Token TikTok (chiffré) | Token longue durée (60j ou jusqu'à révocation) | Renouvellement automatique access token | Exécution contrat |
| Workflows n8n créés | Configurations de publication (horaires, légendes, médias) | Fonctionnement du service | Exécution contrat |
| Logs d'exécution (horodatés) | Historique publications, erreurs, statuts | Débogage, audit, amélioration | Intérêt légitime (Art. 6.1.f) |
| Métadonnées médias (titre, description, hashtags) | Contenu préparé pour publication | Préparation et envoi à TikTok | Exécution contrat |

### 3.3 Données **NON** collectées

- ❌ Mots de passe TikTok (authentification déléguée à TikTok via OAuth)
- ❌ Données bancaires / paiement
- ❌ Localisation précise (GPS)
- ❌ Contacts / carnet d'adresses
- ❌ Contenu des messages privés TikTok
- ❌ Données de navigation hors de l'Application

---

## 4. Finalités du Traitement

| Finalité | Description | Base Légale | Durée Conservation |
|----------|-------------|-------------|---------------------|
| **Authentification utilisateur** | Connexion via TikTok OAuth, identification session | Consentement | Durée de la session + 30j inactivité |
| **Publication contenu** | Envoi vidéos/photos vers TikTok via Video Kit | Exécution contrat | Durée de vie du workflow + 90j |
| **Gestion brouillons / planification** | Stockage temporaire médias, légendes, horaires | Exécution contrat | Jusqu'à publication ou suppression user |
| **Notifications statut** | Succès/échec publication, expiration token | Exécution contrat / Intérêt légitime | 90 jours |
| **Sécurité / Audit** | Logs d'accès, détection abus, conformité API | Intérêt légitime / Obligation légale | 1 an (logs), 3 ans (audit) |
| **Support utilisateur** | Réponse demandes, dépannage | Intérêt légitime | Durée du ticket + 1 an |

---

## 5. Partage des Données

### 5.1 Destinataires

| Destinataire | Données Partagées | Finalité | Localisation | Garanties |
|--------------|-------------------|----------|--------------|-----------|
| **TikTok / ByteDance** | Access token, refresh token, contenu à publier (vidéo, métadonnées) | Publication via API Video Kit, validation token | Selon infrastructure TikTok (US, SG, EU) | Contrat API TikTok, SCC le cas échéant |
| **Hébergeur n8n (self-hosted)** | Toutes données applicatives | Exécution technique | [Ton serveur / Cloud provider] | Contrat sous-traitance (Art. 28 RGPD) |
| **Autorités compétentes** | Données nécessaires | Obligation légale, réquisition judiciaire | UE | Base légale |

### 5.2 Transferts Hors UE

Si ton instance n8n est hébergée hors UE ou si TikTok traite des données hors UE :
- **Mécanisme :** Clauses Contractuelles Types (SCC) 2021/914 + mesures supplémentaires (chiffrement, pseudonymisation)
- **Évaluation d'impact (TIAA) :** Réalisée et documentée

---

## 6. Sécurité

### 6.1 Mesures Techniques
- **Chiffrement au repos :** AES-256 pour tokens OAuth, base de données n8n chiffrée
- **Chiffrement en transit :** TLS 1.3 minimum pour tous les appels API (TikTok, n8n, frontend)
- **Gestion secrets :** Variables d'environnement / vault (pas de secrets en dur dans le code)
- **Rotation tokens :** Refresh token utilisé pour obtenir nouvel access token ; ancien révoqué
- **Révocation :** Déconnexion utilisateur = suppression immédiate tokens côté app + appel `revoke` TikTok si dispo

### 6.2 Mesures Organisationnelles
- Accès restreint aux logs (besoin d'en connaître)
- Procédure de réponse incident sécurité (72h notification CNIL si violation)
- Revue annuelle des accès et permissions
- Formation RGPD pour mainteneurs

---

## 7. Droits des Utilisateurs (RGPD Art. 15-22)

| Droit | Comment l'exercer | Délai |
|-------|-------------------|-------|
| **Accès** | Demande email → export JSON de toutes données | 1 mois |
| **Rectification** | Modification via interface n8n ou demande email | 1 mois |
| **Effacement (« droit à l'oubli »)** | Bouton « Supprimer mon compte » dans l'app ou email | 1 mois |
| **Limitation** | Demande email (ex: contestation exactitude) | 1 mois |
| **Portabilité** | Export JSON structuré (tokens exclus pour sécurité) | 1 mois |
| **Opposition** | Email pour traitement intérêt légitime (logs, analytics) | 1 mois |
| **Retrait consentement** | Déconnexion TikTok dans l'app = suppression tokens | Immédiat |

**Contact exercice droits :** [ton@email.com]  
**Réclamation CNIL :** https://www.cnil.fr/fr/plainte

---

## 8. Durée de Conservation

| Catégorie | Durée | Justification |
|-----------|-------|---------------|
| Tokens OAuth (chiffrés) | Durée autorisation + 30j après révocation | Renouvellement, sécurité |
| Workflows / Contenu programmé | Jusqu'à publication + 90j | Historique, reprise erreur |
| Logs d'exécution / audit | 1 an (logs) / 3 ans (audit) | Sécurité, conformité, debugging |
| Données profil (open_id, display_name, avatar) | Durée compte actif + 30j après suppression | Identification, support |
| Demandes exercice droits | 3 ans | Preuve conformité |

**Suppression automatique :** Script cron mensuel purge données expirées.

---

## 9. Cookies et Traceurs

L'Application n8n **n'utilise pas de cookies** tiers ni de traceurs publicitaires.
- Session n8n : cookie strictement nécessaire (technique, exempté consentement)
- Aucun pixel, analytics tiers, fingerprinting

---

## 10. Mineurs

L'Application n'est **pas destinée aux mineurs de moins de 13 ans** (ou 16 ans selon juridiction).
- TikTok impose 13+ pour créer un compte
- Nous ne collectons pas sciemment de données de mineurs
- Si découvert : suppression immédiate + notification autorité

---

## 11. Modifications de cette Politique

Toute modification substantielle :
- Notification par email 30 jours avant entrée en vigueur
- Affichage dans l'interface n8n (bannière)
- Version historique archivée et accessible

Historique versions :
- v1.0 (22/11/2026) : Création initiale pour soumission TikTok API

---

## 12. Contact

**Délégué à la Protection des Données (DPO) / Contact RGPD :**  
📧 [ton@email.com]  
📮 [Ton Adresse Postale Complète]

**Pour les utilisateurs TikTok :** Vous pouvez aussi révoquer l'accès directement depuis les paramètres TikTok > Sécurité > Applications autorisées.

---

## Annexe : Scopes TikTok Demandés et Justification

| Scope | Nom Affiché | Justification |
|-------|-------------|---------------|
| `user.info.basic` | Profil basique (open_id, union_id, avatar, display_name) | Identification utilisateur dans n8n, affichage nom/photo |
| `user.info.email` | Adresse email | Notifications publication, récupération compte, support |
| `video.publish` | Publication vidéos | **Cœur de métier** : envoi vidéos programmées vers TikTok |
| `video.upload` | Upload médias | Pré-upload vidéos/photos avant publication (requis par Video Kit) |

**Principe de minimisation :** Seuls les scopes strictement nécessaires aux fonctionnalités n8n sont demandés. Aucun scope « large » (ex: `user.info.stats`, `video.list`) n'est requis.