# Data Usage Description — n8n TikTok Content Manager

**App Name :** n8n TikTok Content Manager  
**APIs Used :** TikTok Login Kit + Video Kit (Content Posting API)  
**Version :** 1.0  
**Date :** 22 novembre 2026  
**Developer :** [Ton Nom / Raison Sociale]  

---

## 1. Vue d'Ensemble de l'Usage des Données

Cette application est un **outil d'automatisation auto-hébergé** (n8n) permettant aux utilisateurs de **programmer et publier du contenu sur leur propre compte TikTok**. Elle n'agrège pas de données entre utilisateurs, ne fait pas de profilage, ne revend pas de données, et ne les utilise **qu'aux fins strictes de publication de contenu** initiée par l'utilisateur.

**Principe directeur : Minimisation — Nous ne demandons, ne stockons, ne traitons que ce qui est strictement nécessaire pour la fonctionnalité de publication programmée.**

---

## 2. Données Reçues de TikTok (via API)

### 2.1 Login Kit — `user.info.basic`

| Champ | Type | Utilisation dans l'App | Stockage | Durée |
|-------|------|------------------------|----------|-------|
| `open_id` | String (unique) | Clé primaire pour isoler workspaces multi-comptes ; identifier l'utilisateur dans logs/dashboards | Chiffré (AES-256) en base n8n | Durée autorisation + 30j post-révocation |
| `union_id` | String (optionnel) | Lier comptes même propriétaire cross-app (si applicable) | Chiffré | Idem |
| `avatar_url` | String (URL) | Affichage photo profil dans dashboard n8n (identification visuelle) | **Non stocké** — récupéré à la volée pour affichage UI | Session uniquement |
| `display_name` | String | Affichage nom utilisateur dans dashboard, logs, notifications | Chiffré en base | Durée autorisation + 30j |

**Finalité :** Identification utilisateur, isolation données multi-comptes, UX dashboard.  
**Base légale :** Consentement explicite via écran OAuth TikTok.  
**Partage :** Aucun — reste dans l'instance n8n de l'utilisateur.

---

### 2.2 Login Kit — `user.info.email`

| Champ | Type | Utilisation dans l'App | Stockage | Durée |
|-------|------|------------------------|----------|-------|
| `email` | String (email) | Notifications critiques : échec publication, token expiré, quota API, alerte sécurité ; récupération compte ; support technique | Chiffré (AES-256) en base n8n | Durée autorisation + 30j post-révocation |

**Finalité :** Communication transactionnelle essentielle au service (pas marketing).  
**Base légale :** Consentement explicite + Exécution contrat (notifications de service).  
**Partage :** Aucun — utilisé uniquement pour envoi emails via SMTP configuré par l'utilisateur.

---

### 2.3 Video Kit — Données de Publication (Envoi vers TikTok)

L'application **envoie** les données suivantes à l'API TikTok Video Kit **uniquement au moment de la publication** initiée par l'utilisateur :

| Donnée | Source | Description | Stockage côté App |
|--------|--------|-------------|-------------------|
| **Fichier vidéo/photo** | Upload utilisateur (drag-drop, URL, webhook) | Média à publier (MP4, MOV, WebM, JPEG, PNG) — max 10Go, <10min ou <60s | Stocké temporairement sur S3/local (cycle de vie : suppression auto post-publication confirmée, max 7j) |
| `post_info.title` / `description` | Saisie utilisateur dans workflow n8n | Légende du post (texte, mentions @, hashtags #, emojis) — max 2200 caractères | Stocké dans workflow n8n (chiffré) jusqu'à publication + 90j |
| `post_info.cover_image` | Optionnel — sélection utilisateur | Image de couverture personnalisée (JPEG/PNG) | Temporaire (même cycle que média) |
| `post_info.location` | Optionnel — saisie utilisateur | Lieu/POI (ID TikTok ou coordonnées) | Non stocké — envoyé à l'API uniquement |
| `post_info.privacy_level` | Choix utilisateur | `PUBLIC` / `FRIENDS` / `PRIVATE` / `FOLLOWERS` | Stocké dans config workflow |
| `post_info.disable_comment` | Booléen — choix utilisateur | Désactiver commentaires | Stocké dans config workflow |
| `post_info.disable_duet` | Booléen — choix utilisateur | Désactiver duos | Stocké dans config workflow |
| `post_info.disable_stitch` | Booléen — choix utilisateur | Désactiver stitch | Stocké dans config workflow |
| `post_info.brand_content_toggle` | Booléen — choix utilisateur | Marquer comme contenu de marque (partenariat) | Stocké dans config workflow |
| `post_info.brand_organic_toggle` | Booléen — choix utilisateur | Contenu organique de marque | Stocké dans config workflow |
| `schedule_time` | Choix utilisateur | Date/heure publication programmée (timezone utilisateur) | Stocké dans workflow n8n (exécution planifiée) |

**Finalité :** Publication du contenu sur le compte TikTok de l'utilisateur, selon ses paramètres.  
**Base légale :** Exécution contrat (l'utilisateur demande explicitement la publication).  
**Destination :** **Uniquement** API TikTok Video Kit (`/v2/video/upload/` + `/v2/video/publish/`).  
**Rétention côté TikTok :** Selon politiques TikTok (hors contrôle de l'app).

---

## 3. Données Générées / Stockées par l'Application (Côté n8n)

Ces données **ne viennent pas de TikTok** mais sont créées par l'usage de l'app :

| Catégorie | Exemples | Finalité | Stockage | Durée |
|-----------|----------|----------|----------|-------|
| **Workflows n8n** | JSON définition workflow (nœuds, connexions, config) | Logique métier : planification, file d'attente, retry, notifications | Base n8n (PostgreSQL/SQLite) chiffrée | Jusqu'à suppression user |
| **Credentials n8n** | Tokens OAuth chiffrés (access_token, refresh_token) | Authentification API TikTok | n8n Credentials Store (chiffré natif) | Durée autorisation + rotation auto |
| **Execution Logs** | Timestamp, statut (success/error), post_id TikTok, erreur détaillée, durée | Débogage, audit, support, conformité rate limits | Base n8n (table executions) | 1 an (logs) / 3 ans (audit) |
| **Médias temporaires** | Fichiers vidéo/image en attente de publication | Buffer upload (chunked upload, reprise) | Stockage S3-compatible (MinIO/S3/R2) | Suppression auto post-publish confirmé (max 7j) |
| **Notifications envoyées** | Email/Slack/Discord webhook payloads (succès, échec, alertes) | Preuve envoi, debug | Base n8n (table notifications) | 90 jours |
| **Config utilisateur** | Timezone, préférences notifications, modèles légendes, listes hashtags | Personnalisation UX | Base n8n (table user_settings) | Durée compte actif |

---

## 4. Flux de Données (Data Flow Diagram)

```
┌──────────────┐     OAuth 2.0      ┌──────────────────┐     API Calls      ┌─────────────┐
│   Utilisateur │ ◀────────────────▶ │  n8n Instance    │ ◀───────────────▶  │   TikTok    │
│  (Créateur)   │  (Authorization    │  (Auto-hébergée) │  (Video Kit:     │   API       │
│              │   Code Flow + PKCE)│                  │   upload/publish)│             │
└──────────────┘                    └────────┬─────────┘                  └─────────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    ▼                        ▼                        ▼
            ┌───────────────┐        ┌───────────────┐        ┌───────────────┐
            │  PostgreSQL/  │        │  Stockage     │        │  Files d'att. │
            │  SQLite       │        │  S3/MinIO/R2  │        │  n8n (BullMQ) │
            │  (Chiffré)    │        │  (Médias temp)│        │  (Rate limit) │
            └───────────────┘        └───────────────┘        └───────────────┘
                    │                        │                        │
                    └────────────────────────┼────────────────────────┘
                                             ▼
                                    ┌───────────────┐
                                    │  Monitoring   │
                                    │  (Prometheus/ │
                                    │   Grafana)    │
                                    └───────────────┘
```

**Points clés :**
- **Aucun transit** vers nos serveurs (self-hosted = l'utilisateur contrôle l'infra)
- **Chiffrement** au repos (DB, S3) et en transit (TLS 1.3)
- **Isolation** : chaque compte TikTok = credentials séparés, workspace n8n isolé
- **Pas de partage** inter-utilisateurs, pas d'agrégation, pas d'analytics cross-comptes

---

## 5. Justification Détaillée par Scope Demandé

| Scope | Justification Business (Minimisation) | Alternative envisagée (rejetée) |
|-------|----------------------------------------|----------------------------------|
| `user.info.basic` | **Indispensable** : identifier l'utilisateur connecté, isoler ses données/workflows, afficher son nom/avatar dans l'UI n8n pour éviter erreurs multi-comptes | Demander à l'utilisateur de saisir manuellement son `open_id` → UX catastrophique, source d'erreurs |
| `user.info.email` | **Nécessaire** : notifications critiques de service (échec publication = perte de temps/contenu, token expiré = blocage total, quota API = planification impossible). Pas d'alternative fiable in-app (pas de push mobile natif). | Webhooks TikTok pour événements → pas dispo pour ces événements ; notifications in-app seulement → utilisateur pas connecté = pas vu |
| `video.upload` | **Requis par l'API** : Video Kit impose un upload en 2 étapes (upload → publish). Chunked upload nécessaire pour gros fichiers (>100Mo), reprise sur erreur réseau. | Upload direct publish → non supporté par API ; URL externe → TikTok n'accepte pas |
| `video.publish` | **Cœur de métier** : action finale de publication programmée. Sans ce scope, l'app ne sert à rien. | Partage manuel (Share Kit) → pas de planification, pas d'automatisation, UX brisée |

**Scopes explicitement NON demandés (et pourquoi) :**
- `user.info.stats` → Analytics non nécessaires (TikTok Analytics natif suffit), minimisation RGPD
- `video.list` → L'app gère son propre état (brouillons, planifiés, publiés), pas besoin de lister l'historique TikTok
- `comment.*` → Modération commentaires hors scope MVP, gérée nativement sur TikTok
- `live.*` → Pas de fonctionnalité live
- `shop.*` → Pas d'e-commerce dans l'app

---

## 6. Mesures de Protection des Données

### 6.1 Chiffrement
| Donnée | Au Repos | En Transit |
|--------|----------|------------|
| Access/Refresh Tokens | AES-256-GCM (n8n Credentials Store + DB chiffrée) | TLS 1.3 (tous appels API) |
| Email utilisateur | AES-256 (colonne chiffrée PostgreSQL / pgcrypto) | TLS 1.3 (SMTP STARTTLS) |
| Médias (vidéos/images) | SSE-S3 (AES-256) ou MinIO SSE | TLS 1.3 (presigned URLs HTTPS) |
| Workflows / Config | DB chiffrée (LUKS volume + pgcrypto) | TLS 1.3 (interface n8n) |

### 6.2 Contrôle d'Accès
- **Authentification n8n** : MFA (TOTP) obligatoire pour admin, recommandé pour utilisateurs
- **RBAC n8n** : Rôles `owner` / `editor` / `viewer` par workspace
- **Isolation multi-locataire** : Un compte TikTok = un credential set = un workspace (ou dossier) isolé
- **Principe moindre privilège** : Worker n8n n'a accès qu'aux credentials de son compte assigné

### 6.3 Gestion du Cycle de Vie
| Action | Déclencheur | Opération |
|--------|-------------|-----------|
| **Révocation tokens** | User clique « Déconnecter TikTok » dans UI n8N | 1. Suppression credentials n8n 2. Appel `POST /oauth2/revoke` TikTok (si token valide) 3. Purge médias temporaires associés 4. Log audit |
| **Expiration access_token** | 4h (standard TikTok) | Refresh automatique via refresh_token avant exécution publication (middleware n8n) |
| **Expiration refresh_token** | 60j ou révocation user | Alerte email 7j avant + jour J → User doit se reconnecter |
| **Suppression médias temp** | Publication confirmée (webhook TikTok ou polling statut) | Suppression S3 immédiate (cycle de vie config 0j) |
| **Purge logs exécution** | Cron mensuel | Suppression logs > 1 an (garde audit 3 ans sur bucket froid séparé) |
| **Demande suppression RGPD** | User exerce droit à l'effacement | Workflow n8n dédié : purge toutes tables, credentials, S3, logs → confirmation email |

### 6.4 Sécurité Opérationnelle
- **Rate limiting propre** : File d'attente BullMQ (1 job/sec/compte max) + respect headers `X-RateLimit-*` TikTok
- **Monitoring alertes** : Prometheus rules sur taux erreurs 4xx/5xx, latence, quota TikTok > 80%
- **Backup chiffré** : Dump DB quotidien (chiffré GPG) vers bucket versionné (rétention 30j)
- **Plan incident** : Procédure documentée (detection → containment → notification 72h CNIL si violation données personnelles)

---

## 7. Conformité RGPD / Protection Données

| Droit Utilisateur | Implémentation Technique |
|-------------------|--------------------------|
| **Accès (Art. 15)** | Endpoint n8n `/api/v1/user/data-export` → JSON complet (workflows, credentials masqués, logs, config) |
| **Rectification (Art. 16)** | UI n8n : modification email, timezone, préférences ; credentials → reconnexion OAuth |
| **Effacement (Art. 17)** | Bouton « Supprimer mon compte » → workflow purge complet + appel revoke TikTok |
| **Limitation (Art. 18)** | Flag `processing_restricted` sur compte → stop workers, garde données |
| **Portabilité (Art. 20)** | Export JSON structuré (standard n8n + credentials export chiffré) |
| **Opposition (Art. 21)** | Opt-out notifications non-essentielles ; logs anonymisés (pseudonymisation `open_id` → hash) |
| **Retrait consentement** | = Déconnexion TikTok (voir cycle de vie) |

**DPO / Contact :** [ton@email.com] — réponse < 30 jours (visé 15j)

---

## 8. Transferts Internationaux

| Flux | Origine → Destination | Mécanisme Juridique |
|------|----------------------|---------------------|
| API Calls | Instance n8n (UE) → TikTok API (US/SG/EU selon routage) | SCC 2021/914 (TikTok Developer Terms) + TIAA documentée |
| Stockage médias | Instance n8n → S3 (région choisie par user : eu-west-1, etc.) | Même région que l'instance = pas de transfert |
| Notifications email | Instance n8n → SMTP (provider user : OVH, SendGrid, AWS SES) | Contrat sous-traitance Art. 28 RGPD avec provider |
| Monitoring | Instance n8n → Prometheus/Grafana (self-hosted ou cloud EU) | Même infra ou SCC si cloud hors UE |

**Auto-hébergé = l'utilisateur choisit sa région d'hébergement** → contrôle total sur les transferts.

---

## 9. Aucun Usage Secondaire

| Usage | Statut | Preuve |
|-------|--------|--------|
| **Publicité ciblée** | ❌ Jamais | Pas de pixel, pas de tracking, pas d'IDFA/GAID |
| **Analytics produit** | ❌ Jamais (sauf logs techniques anonymes) | Pas de Mixpanel, Amplitude, GA ; logs n8n seulement |
| **Entraînement IA/ML** | ❌ Jamais | Pas de collecte contenu pour training |
| **Vente/Partage données** | ❌ Jamais | Business model = open source + services, pas data |
| **Profilage utilisateurs** | ❌ Jamais | Pas de scoring, recommandations cross-comptes |
| **Enrichissement tiers** | ❌ Jamais | Pas d'API Clearbit, FullContact, etc. |

---

## 10. Tests et Validation

| Test | Méthode | Fréquence |
|------|---------|-----------|
| **Fuite tokens dans logs** | Grep regex `access_token\|refresh_token` sur logs staging | Chaque déploiement (CI/CD) |
| **Chiffrement au repos** | Vérification `pgcrypto` / LUKS / S3 SSE headers | Audit trimestriel |
| **Révocation effective** | Test E2E : déconnexion → tentative appel API → 401 | Chaque release |
| **Purge médias temp** | Vérification bucket S3 : objets > 7j sans tag `published=true` | Cron hebdo + alerte |
| **Export RGPD complet** | Test manuel : export → vérif exhaustivité vs inventaire données | Avant chaque mise à jour schema DB |
| **Rate limit respect** | Simulation charge (Locust) : 100 publications séquentielles → 0 erreur 429 | Pré-release |

---

## 11. Checklist Soumission TikTok

| Exigence | Statut | Preuve / Note |
|----------|--------|---------------|
| Data Minimization (scopes justifiés) | ✅ | Voir §5 — 4 scopes seulement, chacun justifié |
| Purpose Limitation (usage unique publication) | ✅ | §2, §3 — pas d'usage secondaire |
| Storage Limitation (durées définies, purge auto) | ✅ | §6.3 — tableau cycle de vie complet |
| Integrity & Confidentiality (chiffrement, RBAC) | ✅ | §6.1, §6.2 — AES-256, TLS 1.3, MFA, RBAC |
| User Rights (accès, effacement, portabilité) | ✅ | §7 — implémentation technique décrite |
| Transparency (Privacy Policy, cette doc) | ✅ | Documents fournis |
| Accountability (DPO, logs audit, TIAA) | ✅ | §6.4, §7, §8 — DPO nommé, TIAA faite |
| No Secondary Use | ✅ | §9 — déclaration formelle |
| International Transfers Documented | ✅ | §8 — SCC, TIAA, région user-controlled |
| Security Incident Process | ✅ | §6.4 — procédure 72h CNIL |

---

## 12. Contact pour Questions TikTok Review Team

**Développeur / DPO :** [Ton Nom]  
**Email :** [ton@email.com]  
**Téléphone :** [+33 X XX XX XX XX]  
**Adresse :** [Ton Adresse Complète]  
**Instance Demo (si demandée) :** `https://demo.ton-domaine.com` (accès temporaire sur demande)  
**Repo GitHub :** `https://github.com/ton-user/n8n-tiktok-content-manager` (public ou privé avec accès review team)

---

*Document préparé pour la revue **TikTok Developer Platform** — App : « n8n TikTok Content Manager » — APIs : **Login Kit** + **Video Kit (Content Posting API)** — Conformité RGPD Art. 28, 30, 32, 33, 35*