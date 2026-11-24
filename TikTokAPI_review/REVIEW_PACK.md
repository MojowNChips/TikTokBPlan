# TikTok Developer Review Pack

*All review texts in one file. The live pages are the `.html` files served at /privacy, /terms, /data-usage, /app-description.*

1. Submission checklist  2. App description  3. Privacy policy  4. Terms of service  5. Data usage  6. Logo specs


<div class="pb"></div>

## Checklist Complète — Soumission TikTok Developer Platform

**App :** n8n TikTok Content Manager  
**APIs :** Login Kit + Video Kit (Content Posting API)  
**Date :** 22 novembre 2026  

---

### 📋 Documents Obligatoires (À héberger sur ton domaine HTTPS)

| Document | Fichier Local | URL Cible (à créer) | Statut |
|----------|---------------|---------------------|--------|
| **Privacy Policy** | `PRIVACY_POLICY.md` | `https://ton-domaine.com/privacy` | ✅ Prêt |
| **Terms of Service** | `TERMS_OF_SERVICE.md` | `https://ton-domaine.com/terms` | ✅ Prêt |
| **Data Usage Description** | `DATA_USAGE.md` | `https://ton-domaine.com/data-usage` | ✅ Prêt |
| **App Description** | `APP_DESCRIPTION.md` | (Copier-coller dans formulaire) | ✅ Prêt |

---

### 🎨 Assets Visuels (À créer)

| Asset | Spécifications | Statut | Notes |
|-------|----------------|--------|-------|
| **Logo App** | 512×512 px, PNG, fond transparent, < 1MB | 🔄 À faire | Respecter [TikTok Brand Guidelines](https://developers.tiktok.com/doc/brand-guidelines) — pas de logo TikTok modifié |
| **Screenshots (min 3, max 10)** | 1280×720 min, PNG/JPG, interface n8n réelle | 🔄 À faire | 1. Dashboard 2. Workflow editor 3. Formulaire publication 4. Historique 5. Connexion OAuth |
| **Demo Video** | 3-5 min, MP4, 1080p, < 100MB | 🔄 À faire | Parcours complet : Connexion → Création workflow → Planification → Publication → Historique |
| **Cover Image (optionnel)** | 1280×720, pour fiche app store | ⏸️ Optionnel | Si tu vises l'App Marketplace TikTok |

---

### 🔧 Configuration Technique (À valider avant soumission)

| Élément | Valeur Requise | Ton Valeur | Statut |
|---------|----------------|------------|--------|
| **App Name** | Unique, descriptif | `n8n TikTok Content Manager` | ✅ |
| **Redirect URI (Prod)** | HTTPS, exact match | `https://ton-domaine.com/callback` | 🔄 À configurer |
| **Redirect URI (Dev)** | `http://localhost:5678/callback` ou ngrok HTTPS | `https://xxx.ngrok-free.app/callback` | 🔄 À configurer |
| **Scopes Demandés** | Minimaux, justifiés | `user.info.basic`, `user.info.email`, `video.upload`, `video.publish` | ✅ Justifiés dans docs |
| **Catégorie App** | Business / Productivity / Social | `Business` ou `Productivity` | ✅ |
| **Description Courte** | < 80 caractères | `Automatisez la publication TikTok via n8n` | ✅ |
| **Description Longue** | < 4000 caractères | Voir `APP_DESCRIPTION.md` | ✅ |

---

### 🏢 Vérification Entreprise (Business Verification)

| Document | Requis ? | Statut | Notes |
|----------|----------|--------|-------|
| **KBIS / Extrait SIRENE** (France) | Oui si entreprise | 🔄 À fournir | Moins de 3 mois |
| **Statuts / SIRET** | Oui | 🔄 À fournir | |
| **Piece identité dirigeant** | Parfois | 🔄 À fournir | Passeport/CNI |
| **Preuve adresse entreprise** | Parfois | 🔄 À fournir | Facture < 3 mois |
| **Tax ID / VAT Number** | Si applicable | 🔄 À fournir | FRxx xxxxxxxxx |

> **Note :** TikTok demande la vérification entreprise pour les apps qui publient du contenu (Video Kit). Prépare ces docs à l'avance.

---

### ✅ Tests Techniques Pré-Soumission

| Test | Critère de Succès | Statut |
|------|-------------------|--------|
| **OAuth Flow Complet** | Connexion → Consentement → Callback → Tokens stockés → Dashboard accessible | 🔄 À tester |
| **Token Refresh Auto** | Access token expiré → Refresh token utilisé → Nouvel access token → Publication OK | 🔄 À tester |
| **Révocation Tokens** | Déconnexion UI → Appel `/oauth2/revoke` → Tokens supprimés → Nouvel auth requis | 🔄 À tester |
| **Upload Média** | Vidéo 500Mo → Chunked upload → `video_id` reçu → Pas d'erreur timeout | 🔄 À tester |
| **Publication Programmée** | Workflow planifié → Exécution à l'heure → Post visible sur TikTok → Notification envoyée | 🔄 À tester |
| **Rate Limit Handling** | Simulation 429 → Backoff → Retry → Succès → Pas de blocage compte | 🔄 À tester |
| **Gestion Erreurs** | Format invalide → Erreur claire UI → Pas de crash worker → Log détaillé | 🔄 À tester |
| **RGPD Export** | Clic « Export mes données » → JSON complet reçu < 30s | 🔄 À tester |
| **RGPD Suppression** | Clic « Supprimer compte » → Tout purgé + revoke TikTok → Confirmation email | 🔄 À tester |
| **HTTPS Enforced** | Tout HTTP → Redirection 301 HTTPS → HSTS header présent | 🔄 À tester |

---

### 📝 Champs Formulaire TikTok (Copier-Coller)

#### Informations de Base
```
App Name: n8n TikTok Content Manager
Short Description: Automatisez la publication TikTok via workflows n8n visuels — planification, multi-comptes, file d'attente intelligente.
Category: Business / Productivity
Website: https://ton-domaine.com
Privacy Policy URL: https://ton-domaine.com/privacy
Terms of Service URL: https://ton-domaine.com/terms
Data Usage Description URL: https://ton-domaine.com/data-usage
Support Email: support@ton-domaine.com
```

#### Scopes Demandés (avec justifications courtes pour le formulaire)
```
user.info.basic → Identifier l'utilisateur, isoler workspaces multi-comptes, afficher nom/avatar dans dashboard
user.info.email → Notifications critiques service (échec publication, token expiré, quota API) — pas marketing
video.upload → Requis par Video Kit pour chunked upload médias (reprise, gros fichiers)
video.publish → Cœur de métier : publication programmée vidéos/photos sur le fil utilisateur
```

#### Use Case Description (version courte pour formulaire)
```
L'application permet aux créateurs et community managers de programmer et publier automatiquement du contenu sur TikTok via une interface visuelle de workflows n8n. Elle gère l'authentification OAuth sécurisée, l'upload chunked de médias, la file d'attente respectant les rate limits TikTok, les notifications de statut, et fournit un audit trail complet. Auto-hébergée, open-source, conforme RGPD, sans monétisation de données utilisateur.
```

---

### 🚀 Étapes de Soumission

1. **Héberger les docs** sur `https://ton-domaine.com/privacy`, `/terms`, `/data-usage` (HTML ou Markdown rendu)
2. **Créer les assets** : Logo (512×512 PNG), Screenshots (3-5), Demo video (3-5 min)
3. **Configurer Redirect URI** en prod sur ton serveur n8n (`/callback` endpoint)
4. **Rassembler docs entreprise** (KBIS, SIRET, pièce identité, justificatif adresse)
5. **Tester l'OAuth flow complet** sur compte test TikTok (mode sandbox)
6. **Remplir le formulaire** sur https://developers.tiktok.com → My Apps → Create App
7. **Soumettre pour review** → Attendre feedback (généralement 3-10 jours ouvrés)
8. **Répondre aux questions** de la review team si demandé (souvent : précisions data usage, demo video, business verification)

---

### 📞 Contacts Utiles

| Contact | Usage |
|---------|-------|
| **TikTok Developer Support** | https://developers.tiktok.com/support/ |
| **TikTok API Discord** | https://discord.gg/tiktokdevelopers |
| **Brand Guidelines** | https://developers.tiktok.com/doc/brand-guidelines |
| **API Reference** | https://developers.tiktok.com/doc/login-kit-web / https://developers.tiktok.com/doc/video-kit |
| **Platform Policies** | https://developers.tiktok.com/doc/platform-policies |

---

### 📁 Fichiers dans ce Dossier

```
TikTokAPI_review/
├── PRIVACY_POLICY.md         → Héberger sur /privacy
├── TERMS_OF_SERVICE.md       → Héberger sur /terms
├── DATA_USAGE.md             → Héberger sur /data-usage
├── APP_DESCRIPTION.md        → Copier dans formulaire "Description"
├── TIKTOK_SUBMISSION_CHECKLIST.md  → Ce fichier (suivi)
└── LOGO_SPECS.md             → Spécs pour designer (ci-dessous)
```

---

### ⚠️ Points d'Attention Fréquents (Rejets Communs)

| Cause de Rejet | Comment l'Éviter |
|----------------|------------------|
| **Redirect URI mismatch** | Copier EXACTEMENT la même URI dans formulaire ET config n8n (HTTPS, pas de slash final si pas dans config, port exact) |
| **Scopes non justifiés** | Chaque scope = une ligne dans Data Usage + App Description avec justification business claire |
| **Privacy Policy générique** | Doit mentionner TikTok explicitement, lister scopes, décrire flux données, durées, droits RGPD |
| **Pas de demo video** | Enregistrer un vrai parcours utilisateur (même imparfait) — 3-5 min suffisent |
| **Business verification manquante** | Préparer KBIS/SIRET AVANT soumission — requis pour Video Kit |
| **Logo non conforme** | Suivre Brand Guidelines : pas de logo TikTok modifié, fond transparent, 512×512 |
| **Rate limit non géré** | Démontrer file d'attente + retry + backoff dans demo video ou description technique |
| **Données stockées trop longtemps** | Durées définies + purge auto documentée dans Data Usage + Privacy Policy |

---

*Checklist mise à jour le 22/11/2026 — À cocher au fur et à mesure*

<div class="pb"></div>

## Description de l'Application — n8n TikTok Content Manager

**Nom de l'App :** n8n TikTok Content Manager  
**Version :** 1.0  
**Date :** 22 novembre 2026  
**Développeur :** [Ton Nom / Raison Sociale]  
**Contact :** [ton@email.com]  
**Site web / Landing page :** [https://ton-domaine.com]  

---

### 1. Résumé Exécutif (1-2 phrases)

**n8n TikTok Content Manager** est une application auto-hébergée construite sur **n8n** (plateforme d'automatisation low-code) qui permet aux créateurs de contenu, community managers et agences de **programmer, préparer et publier automatiquement des vidéos et photos sur TikTok** via une interface visuelle de workflows, tout en respectant scrupuleusement les politiques API et Community Guidelines de TikTok.

---

### 2. Problème Résolu (Use Case Principal)

#### Contexte
Les créateurs et gestionnaires de contenu TikTok font face à plusieurs défis :
- **Publication manuelle chronophage** : obligation d'être devant l'app au moment optimal
- **Gestion multi-comptes complexe** : basculer entre comptes pro/perso, clients
- **Absence de planification native avancée** : TikTok permet le brouillon mais pas la publication programmée récurrente avec files d'attente intelligentes
- **Workflow éclaté** : idée → script → tournage → montage → légende → hashtags → publication = outils multiples, pas de traçabilité

#### Solution Apportée
L'Application centralise **tout le pipeline de publication** dans des workflows n8n visuels :
1. **Collecte** : formulaires, webhooks, Google Sheets, Notion, Airtable → idées/contenu
2. **Préparation** : montage vidéo automatisé (FFmpeg), génération légendes (IA), sélection hashtags, miniatures
3. **Planification** : calendrier visuel, récurrence, fuseaux horaires, file d'attente prioritaire
4. **Publication** : envoi programmé via **TikTok Video Kit** (upload → publish) avec gestion erreurs/retry
5. **Suivi** : logs statut, métriques de base, notifications (email, Slack, Discord, Telegram)

---

### 3. Fonctionnalités Détaillées

| Module | Description | API TikTok Utilisée |
|--------|-------------|---------------------|
| **Authentification OAuth** | Connexion sécurisée via TikTok Login Kit, gestion multi-comptes, refresh token automatique | `Login Kit` (`user.info.basic`, `user.info.email`) |
| **Upload Média** | Pré-upload vidéos/photos (jusqu'à 10Go), validation format, compression si besoin, chunked upload | `Video Kit` → `video.upload` |
| **Publication Programmée** | Création post avec légende, hashtags, mentions, lieu, paramètres confidentialité, date/heure précise | `Video Kit` → `video.publish` |
| **Gestion Brouillons** | Sauvegarde brouillons côté n8n, édition avant envoi, duplication pour variantes A/B | Stockage local n8n (pre-publish) |
| **File d'Attente Intelligente** | Respect rate limits TikTok, retry exponentiel, priorisation, pause/reprise | Orchestration n8n (côté app) |
| **Multi-Comptes / Clients** | Isolation workspaces par compte TikTok, contrôle d'accès basé rôles (admin/editor/viewer) | Login Kit par compte |
| **Notifications & Alertes** | Succès/échec publication, token expiré, quota API proche, erreur média | Webhooks n8n → Email/Slack/Discord |
| **Audit & Conformité** | Journal immuable publications, export RGPD, suppression données à la demande | Logs n8n + API TikTok |

---

### 4. Architecture Technique

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Utilisateur   │────▶│  Interface n8n   │────▶│  Workflow Engine │
│  (Créateur/CM)  │     │  (Dashboard UI)  │     │  (n8n Core)     │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │
                              ┌───────────────────────────┼───────────────────────────┐
                              ▼                           ▼                           ▼
                     ┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
                     │  TikTok Login   │         │  TikTok Video   │         │   Stockage      │
                     │      Kit        │         │      Kit        │         │   (PostgreSQL/  │
                     │  (OAuth 2.0)    │         │ (Upload/Publish)│         │   SQLite + S3)  │
                     └─────────────────┘         └─────────────────┘         └─────────────────┘
```

#### Stack Technique
- **Orchestration :** n8n (self-hosted, Docker/K8s/VM)
- **Base de données :** PostgreSQL (prod) / SQLite (dev) — chiffrement au repos
- **Stockage médias :** S3-compatible (MinIO, AWS S3, Cloudflare R2) — cycle de vie auto (suppression post-publication)
- **Secrets :** HashiCorp Vault / Variables d'env chiffrées / n8n credentials
- **Monitoring :** Prometheus + Grafana / n8n execution logs
- **Reverse Proxy :** Traefik / Nginx (TLS 1.3, rate limiting, WAF basique)

#### Sécurité
- ✅ OAuth 2.0 + PKCE (Authorization Code Flow)
- ✅ Tokens chiffrés au repos (AES-256-GCM)
- ✅ Refresh token rotation + révocation à la déconnexion
- ✅ HTTPS obligatoire (TLS 1.3)
- ✅ Rate limiting propre + respect rate limits TikTok
- ✅ Aucune donnée sensible dans logs (masquage tokens)
- ✅ Suppression auto médias après publication confirmée (configurable)

---

### 5. Public Cible

| Segment | Description | Besoin Clé |
|---------|-------------|------------|
| **Créateurs individuels** | Influenceurs, artistes, éducateurs (10k-1M abonnés) | Gain de temps, régularité, multi-plateforme futur |
| **Community Managers / Agences** | Gestion 5-50 comptes clients | Multi-comptes, validation client, reporting, white-label |
| **Équipes Marketing / Marque** | Marques e-commerce, SaaS, médias | Calendrier éditorial, UGC, campagne produit, conformité marque |
| **Développeurs n8n / No-code** | Utilisateurs n8n souhaitant intégrer TikTok | Nœuds n8n réutilisables, templates workflows |

**Estimation utilisateurs cibles :** 500-2000 utilisateurs actifs première année (croissance organique via communauté n8n + bouche-à-oreille créateurs)

---

### 6. Flux Utilisateur Type (User Journey)

```
1. INSCRIPTION / CONNEXION
   └─> Landing page → "Connecter TikTok" → Redirection TikTok OAuth
       └─> Consentement scopes (profil + publication) → Callback n8n
           └─> Tokens stockés chiffrés → Dashboard accessible

2. CRÉATION CONTENU
   └─> Nouveau workflow / Template "Publication TikTok"
       └─> Upload vidéo (drag-drop) → Prévisualisation
           └─> Légende (éditeur riche + variables: {{date}}, {{hashtags}})
               └─> Hashtags (suggestions IA / liste prédéfinie)
                   └─> Paramètres: confidentialité, commentaires, duos, stitch
                       └─> Planification: date/heure + fuseau + récurrence

3. VALIDATION & ENVOI
   └─> Aperçu final → "Programmer" ou "Publier maintenant"
       └─> Entrée dans file d'attente n8n (respect rate limits)

4. EXÉCUTION (Automatique)
   └─> Au moment prévu: Upload média → Video Kit → Publish
       └─> Succès: Notification + Log + Métriques de base (post_id, URL)
       └─> Échec: Retry (3x backoff) → Alerte → Log détaillé

5. SUIVI & OPTIMISATION
   └─> Dashboard: Historique, statut, liens vers posts TikTok
       └─> Export CSV/JSON pour reporting client
```

---

### 7. Conformité TikTok API

#### Scopes Demandés (Minimisation)
| Scope | Justification Business |
|-------|------------------------|
| `user.info.basic` | Identifier l'utilisateur connecté, afficher nom/avatar dans dashboard n8n, isoler workspaces par compte |
| `user.info.email` | Notifications critiques (échec publication, expiration token), récupération compte, support |
| `video.upload` | **Requis** pour pré-uploader médias avant publication (chunked upload, reprise) |
| `video.publish` | **Cœur de métier** : publication programmée vidéos/photos sur le fil TikTok |

#### Scopes **NON** Demandés (et pourquoi)
| Scope | Pourquoi pas |
|-------|--------------|
| `user.info.stats` | Pas besoin d'analytics (TikTok Analytics suffit), minimisation |
| `video.list` | L'app gère son propre état (brouillons, planifié), pas besoin de lister l'existant |
| `comment.list/manage` | Hors scope MVP — modération commentaires gérée nativement sur TikTok |
| `live.*` | Pas de fonctionnalité live dans l'app |

#### Respect Rate Limits & Quotas
- **File d'attente n8n** : 1 worker par compte TikTok, séquentiel
- **Retry intelligent** : Backoff exponentiel (1min, 5min, 15min, 1h) + alerte
- **Monitoring quotas** : Alerte à 80% quota journalier
- **Batch upload** : Un média à la fois (pas de parallélisme qui risquerait 429)

#### Conformité Contenu
- Validation côté client : format vidéo (MP4, MOV, WebM), taille (<10Go), durée (<10min ou <60s selon type), ratio (9:16, 1:1, 16:9)
- Avertissement Community Guidelines dans l'UI avant publication
- Pas de modification contenu post-upload (respect intégrité média)
- Support suppression post via TikTok (si utilisateur supprime sur TikTok, sync statut dans n8n)

---

### 8. Modèle Économique / Business Model

| Modèle | Détails |
|--------|---------|
| **Open Source (Core)** | Workflows n8n, nœuds personnalisés, documentation → Gratuit, MIT/Apache 2.0 |
| **Hébergé SaaS (Optionnel)** | Instance n8n gérée, backup, monitoring, support → Abonnement mensuel (freemium) |
| **Services Pro** | Setup, formation, templates métier, développement nœuds custom → Facturation projet |
| **Partenariat Agences** | Licence multi-clients, white-label, support prioritaire → Partage revenus / licence annuelle |

**Pas de monétisation données utilisateur** — Pas de vente, pas de publicité, pas de tracking tiers.

---

### 9. Différenciateurs vs Concurrents

| Concurrent | Limite | Notre Avantage |
|------------|--------|----------------|
| **Buffer / Hootsuite / Later** | Payant, limité TikTok (pas toujours API officielle), pas n8n | **Auto-hébergé, gratuit (core), extensible à l'infini via n8n** |
| **Zapier / Make (Integromat)** | Coût par tâche, nodes TikTok limités/obsolètes | **Nodes natifs n8n, 0 coût marginal, contrôle total data** |
| **Scripts Python perso** | Maintenance, pas d'UI, pas de file d'attente robuste | **UI visuelle, retry, monitoring, multi-comptes, templates** |
| **TikTok Studio (natif)** | Pas de planification récurrente avancée, pas multi-comptes pro | **Workflow complet : idée → publication → suivi, automatisation** |

---

### 10. Roadmap (Prochains 12 Mois)

| Trimestre | Objectifs |
|-----------|-----------|
| **Q4 2026** | MVP : Auth + Upload + Publish + Queue + Dashboard de base + Docs |
| **Q1 2027** | Templates workflows (créateurs, agences, e-commerce), Multi-comptes avancé, Notifications riches |
| **Q2 2027** | Analytics basiques (vues, likes via API si dispo), IA légendes/hashtags, Support webhook TikTok (real-time) |
| **Q3 2027** | Version SaaS hébergée (beta), Marketplace templates communautaires, Certifications sécurité |

---

### 11. Liens Utiles pour la Revue TikTok

| Document | Lien (à héberger) |
|----------|-------------------|
| **Privacy Policy** | `https://ton-domaine.com/privacy` |
| **Terms of Service** | `https://ton-domaine.com/terms` |
| **Data Usage Description** | `https://ton-domaine.com/data-usage` |
| **Demo Video (3-5 min)** | `https://ton-domaine.com/demo.mp4` ou YouTube unlisted |
| **Screenshots Dashboard** | `https://ton-domaine.com/screenshots/` |
| **Logo App (512x512 PNG)** | `https://ton-domaine.com/logo.png` |
| **Redirect URI (Prod)** | `https://ton-domaine.com/callback` |
| **Contact Support** | `support@ton-domaine.com` (réponse < 48h) |
| **Repo GitHub (si public)** | `https://github.com/ton-user/n8n-tiktok-content-manager` |

---

### 12. Checklist Pré-Soumission

- [x] Privacy Policy RGPD-complète + scopes justifiés
- [x] Terms of Service conformes TikTok Developer Terms
- [x] Data Usage Description détaillée
- [x] Logo 512x512 PNG fond transparent (Brand Guidelines)
- [ ] Demo video enregistrée (workflow complet : connect → create → schedule → publish)
- [ ] Screenshots : Dashboard, Workflow editor, Publication form, Historique
- [ ] Redirect URI HTTPS configurée en prod + testée
- [ ] Compte développeur TikTok vérifié (email + téléphone)
- [ ] Business Verification (si requis : KBIS/SIRET/Tax ID)
- [ ] Test end-to-end sur compte test TikTok (sandbox)
- [ ] Rate limit handling validé (simulation 429)
- [ ] Token refresh + revoke testé
- [ ] Gestion erreurs médias (format, taille, durée) validée

---

*Document préparé pour la soumission **TikTok Developer Platform** — App : « n8n TikTok Content Manager » — APIs visées : **Login Kit** + **Video Kit (Content Posting API)***

<div class="pb"></div>

## Politique de Confidentialité — n8n TikTok Content Manager

**Dernière mise à jour :** 22 novembre 2026  
**Version :** 1.0  
**Éditeur :** [Ton Nom / Nom de ton entreprise]  
**Contact RGPD / DPO :** [ton@email.com]

---

### 1. Objet et Champ d'Application

Cette politique de confidentialité décrit comment l'application **« n8n TikTok Content Manager »** (ci-après « l'Application », « nous », « notre ») collecte, utilise, stocke et protège les données personnelles des utilisateurs qui s'authentifient via **TikTok Login Kit** et autorisent l'Application à publier du contenu via **TikTok Video Kit / Content Posting API**.

L'Application est un workflow n8n auto-hébergé permettant aux créateurs de contenu et gestionnaires de médias sociaux de :
- S'authentifier sécurisément via OAuth 2.0 (TikTok Login Kit)
- Programmer et publier des vidéos/photos sur leur compte TikTok (Video Kit)
- Gérer leurs brouillons et contenus planifiés

---

### 2. Responsable de Traitement

**Responsable :** [Ton Nom / Raison Sociale]  
**Adresse :** [Ton Adresse Complète]  
**Email DPO / Contact RGPD :** [ton@email.com]  
**Représentant UE (si hors UE) :** [le cas échéant]

---

### 3. Données Collectées

#### 3.1 Données reçues de TikTok (via OAuth)

Lors de l'autorisation via **TikTok Login Kit**, nous recevons les champs suivants (selon les scopes demandés) :

| Donnée | Source | Finalité | Base Légale |
|--------|--------|----------|-------------|
| `open_id` | TikTok Login Kit | Identifiant unique utilisateur TikTok | Consentement (Art. 6.1.a RGPD) |
| `union_id` | TikTok Login Kit | Identifiant unifié cross-app (si même propriétaire) | Consentement |
| `avatar_url` | TikTok Login Kit | Photo de profil pour affichage dans l'app | Consentement |
| `display_name` | TikTok Login Kit | Nom d'affichage pour identification | Consentement |
| `email` (si scope `user.info.email`) | TikTok Login Kit | Contact utilisateur, notifications | Consentement |
| `profile_deep_link` | TikTok Login Kit | Lien vers profil TikTok | Consentement |

#### 3.2 Données générées par l'Application

| Donnée | Description | Finalité | Base Légale |
|--------|-------------|----------|-------------|
| Access Token TikTok (chiffré) | Token OAuth courte durée (4h) | Appels API Video Kit pour publication | Exécution contrat (Art. 6.1.b) |
| Refresh Token TikTok (chiffré) | Token longue durée (60j ou jusqu'à révocation) | Renouvellement automatique access token | Exécution contrat |
| Workflows n8n créés | Configurations de publication (horaires, légendes, médias) | Fonctionnement du service | Exécution contrat |
| Logs d'exécution (horodatés) | Historique publications, erreurs, statuts | Débogage, audit, amélioration | Intérêt légitime (Art. 6.1.f) |
| Métadonnées médias (titre, description, hashtags) | Contenu préparé pour publication | Préparation et envoi à TikTok | Exécution contrat |

#### 3.3 Données **NON** collectées

- ❌ Mots de passe TikTok (authentification déléguée à TikTok via OAuth)
- ❌ Données bancaires / paiement
- ❌ Localisation précise (GPS)
- ❌ Contacts / carnet d'adresses
- ❌ Contenu des messages privés TikTok
- ❌ Données de navigation hors de l'Application

---

### 4. Finalités du Traitement

| Finalité | Description | Base Légale | Durée Conservation |
|----------|-------------|-------------|---------------------|
| **Authentification utilisateur** | Connexion via TikTok OAuth, identification session | Consentement | Durée de la session + 30j inactivité |
| **Publication contenu** | Envoi vidéos/photos vers TikTok via Video Kit | Exécution contrat | Durée de vie du workflow + 90j |
| **Gestion brouillons / planification** | Stockage temporaire médias, légendes, horaires | Exécution contrat | Jusqu'à publication ou suppression user |
| **Notifications statut** | Succès/échec publication, expiration token | Exécution contrat / Intérêt légitime | 90 jours |
| **Sécurité / Audit** | Logs d'accès, détection abus, conformité API | Intérêt légitime / Obligation légale | 1 an (logs), 3 ans (audit) |
| **Support utilisateur** | Réponse demandes, dépannage | Intérêt légitime | Durée du ticket + 1 an |

---

### 5. Partage des Données

#### 5.1 Destinataires

| Destinataire | Données Partagées | Finalité | Localisation | Garanties |
|--------------|-------------------|----------|--------------|-----------|
| **TikTok / ByteDance** | Access token, refresh token, contenu à publier (vidéo, métadonnées) | Publication via API Video Kit, validation token | Selon infrastructure TikTok (US, SG, EU) | Contrat API TikTok, SCC le cas échéant |
| **Hébergeur n8n (self-hosted)** | Toutes données applicatives | Exécution technique | [Ton serveur / Cloud provider] | Contrat sous-traitance (Art. 28 RGPD) |
| **Autorités compétentes** | Données nécessaires | Obligation légale, réquisition judiciaire | UE | Base légale |

#### 5.2 Transferts Hors UE

Si ton instance n8n est hébergée hors UE ou si TikTok traite des données hors UE :
- **Mécanisme :** Clauses Contractuelles Types (SCC) 2021/914 + mesures supplémentaires (chiffrement, pseudonymisation)
- **Évaluation d'impact (TIAA) :** Réalisée et documentée

---

### 6. Sécurité

#### 6.1 Mesures Techniques
- **Chiffrement au repos :** AES-256 pour tokens OAuth, base de données n8n chiffrée
- **Chiffrement en transit :** TLS 1.3 minimum pour tous les appels API (TikTok, n8n, frontend)
- **Gestion secrets :** Variables d'environnement / vault (pas de secrets en dur dans le code)
- **Rotation tokens :** Refresh token utilisé pour obtenir nouvel access token ; ancien révoqué
- **Révocation :** Déconnexion utilisateur = suppression immédiate tokens côté app + appel `revoke` TikTok si dispo

#### 6.2 Mesures Organisationnelles
- Accès restreint aux logs (besoin d'en connaître)
- Procédure de réponse incident sécurité (72h notification CNIL si violation)
- Revue annuelle des accès et permissions
- Formation RGPD pour mainteneurs

---

### 7. Droits des Utilisateurs (RGPD Art. 15-22)

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

### 8. Durée de Conservation

| Catégorie | Durée | Justification |
|-----------|-------|---------------|
| Tokens OAuth (chiffrés) | Durée autorisation + 30j après révocation | Renouvellement, sécurité |
| Workflows / Contenu programmé | Jusqu'à publication + 90j | Historique, reprise erreur |
| Logs d'exécution / audit | 1 an (logs) / 3 ans (audit) | Sécurité, conformité, debugging |
| Données profil (open_id, display_name, avatar) | Durée compte actif + 30j après suppression | Identification, support |
| Demandes exercice droits | 3 ans | Preuve conformité |

**Suppression automatique :** Script cron mensuel purge données expirées.

---

### 9. Cookies et Traceurs

L'Application n8n **n'utilise pas de cookies** tiers ni de traceurs publicitaires.
- Session n8n : cookie strictement nécessaire (technique, exempté consentement)
- Aucun pixel, analytics tiers, fingerprinting

---

### 10. Mineurs

L'Application n'est **pas destinée aux mineurs de moins de 13 ans** (ou 16 ans selon juridiction).
- TikTok impose 13+ pour créer un compte
- Nous ne collectons pas sciemment de données de mineurs
- Si découvert : suppression immédiate + notification autorité

---

### 11. Modifications de cette Politique

Toute modification substantielle :
- Notification par email 30 jours avant entrée en vigueur
- Affichage dans l'interface n8n (bannière)
- Version historique archivée et accessible

Historique versions :
- v1.0 (22/11/2026) : Création initiale pour soumission TikTok API

---

### 12. Contact

**Délégué à la Protection des Données (DPO) / Contact RGPD :**  
📧 [ton@email.com]  
📮 [Ton Adresse Postale Complète]

**Pour les utilisateurs TikTok :** Vous pouvez aussi révoquer l'accès directement depuis les paramètres TikTok > Sécurité > Applications autorisées.

---

### Annexe : Scopes TikTok Demandés et Justification

| Scope | Nom Affiché | Justification |
|-------|-------------|---------------|
| `user.info.basic` | Profil basique (open_id, union_id, avatar, display_name) | Identification utilisateur dans n8n, affichage nom/photo |
| `user.info.email` | Adresse email | Notifications publication, récupération compte, support |
| `video.publish` | Publication vidéos | **Cœur de métier** : envoi vidéos programmées vers TikTok |
| `video.upload` | Upload médias | Pré-upload vidéos/photos avant publication (requis par Video Kit) |

**Principe de minimisation :** Seuls les scopes strictement nécessaires aux fonctionnalités n8n sont demandés. Aucun scope « large » (ex: `user.info.stats`, `video.list`) n'est requis.

<div class="pb"></div>

## Conditions d'Utilisation — n8n TikTok Content Manager

**Dernière mise à jour :** 22 novembre 2026  
**Version :** 1.0  
**Éditeur :** [Ton Nom / Nom de ton entreprise]  
**Contact :** [ton@email.com]

---

### 1. Acceptation des Conditions

En accédant à l'Application **« n8n TikTok Content Manager »** (ci-après « l'Application », « le Service », « nous »), vous acceptez sans réserve les présentes Conditions d'Utilisation (ci-après « CGU »).

Si vous n'acceptez pas ces CGU, vous ne devez pas utiliser l'Application.

---

### 2. Description du Service

L'Application est un **workflow n8n auto-hébergé** permettant aux utilisateurs de :
- S'authentifier via **TikTok Login Kit** (OAuth 2.0)
- Programmer, préparer et publier des vidéos et photos sur leur compte TikTok via **TikTok Video Kit / Content Posting API**
- Gérer leurs brouillons, contenus planifiés et historique de publications

L'Application n'est **pas** un produit TikTok, ByteDance, ou n8n.io. C'est un outil tiers développé indépendamment.

---

### 3. Éligibilité

Pour utiliser l'Application, vous devez :
- Avoir **13 ans minimum** (ou l'âge minimum requis par TikTok dans votre juridiction)
- Disposer d'un **compte TikTok valide** et en règle
- Avoir la **capacité juridique** de contracter
- Ne pas être interdit d'utilisation des services TikTok

---

### 4. Compte et Authentification

#### 4.1 Connexion via TikTok
L'authentification est déléguée à **TikTok** via le protocole **OAuth 2.0** (Login Kit).
- Vous autorisez l'Application à accéder à votre profil basique et à publier du contenu en votre nom
- Vous pouvez révoquer cette autorisation à tout moment depuis les paramètres TikTok > Sécurité > Applications autorisées
- Nous ne stockons **jamais** votre mot de passe TikTok

#### 4.2 Sécurité du Compte
- Vous êtes responsable de la confidentialité de votre session n8n
- Déconnexion recommandée sur appareils partagés
- En cas d'accès non autorisé : contactez-nous immédiatement

---

### 5. Licence d'Utilisation

#### 5.1 Octroi de Licence
Nous vous accordons une licence **personnelle, non exclusive, non transférable, révocable** d'utiliser l'Application pour vos besoins personnels ou professionnels internes.

#### 5.2 Restrictions
Il vous est interdit de :
- ❌ Revendre, louer, sous-licencier l'Application
- ❌ Modifier, décompiler, faire de l'ingénierie inverse
- ❌ Utiliser l'Application pour du spam, contenu illégal, haineux, trompeur
- ❌ Contourner les limites de taux (rate limits) de l'API TikTok
- ❌ Publier du contenu enfreignant les **Community Guidelines TikTok**
- ❌ Utiliser l'Application pour des comptes dont vous n'êtes pas le propriétaire légitime

---

### 6. Contenu Utilisateur

#### 6.1 Propriété
Vous conservez **tous les droits** sur votre contenu (vidéos, images, légendes, métadonnées).

#### 6.2 Licence pour Publication
En publiant via l'Application, vous nous accordez une licence **mondiale, gratuite, non exclusive, limitée** pour :
- Transmettre votre contenu à l'API TikTok Video Kit
- Le stocker temporairement le temps de la publication
- Afficher les aperçus dans l'interface n8n

Cette licence prend fin à la publication effective ou à la suppression du brouillon.

#### 6.3 Responsabilité du Contenu
**Vous êtes seul responsable** du contenu que vous publiez.
- Respect des droits d'auteur, marques, vie privée, droit à l'image
- Conformité aux **Community Guidelines TikTok** et lois applicables
- Pas de contenu : illégal, haineux, harcèlement, désinformation, violence, nudité, contrefaçon

#### 6.4 Modération
Nous ne modérons **pas** le contenu avant publication (sauf contrainte technique API).
TikTok applique sa propre modération post-publication. Nous ne sommes pas responsables des suppressions, restrictions ou bannissements décidés par TikTok.

---

### 7. Utilisation de l'API TikTok

#### 7.1 Conformité
L'Application utilise les API officielles **TikTok Login Kit** et **Video Kit**.
Vous acceptez de respecter :
- [TikTok Developer Terms of Service](https://developers.tiktok.com/terms/)
- [TikTok API Terms of Use](https://developers.tiktok.com/doc/tt-api-terms-of-use/)
- [TikTok Community Guidelines](https://www.tiktok.com/community-guidelines)
- [TikTok Platform Policies](https://developers.tiktok.com/doc/platform-policies)

#### 7.2 Limites Techniques
- Respect des **rate limits** API TikTok (quotas quotidiens, par minute)
- L'Application implémente une file d'attente et retry automatique
- En cas de quota dépassé : publication retardée, notification envoyée

#### 7.3 Modifications API
TikTok peut modifier ses API, scopes, ou conditions à tout moment.
Nous ferons nos meilleurs efforts pour adapter l'Application, mais ne garantissons pas la continuité immédiate.

---

### 8. Disponibilité et Maintenance

#### 8.1 Service « Tel Quel »
L'Application est fournie **« en l'état »** et **« selon disponibilité »**.
- Aucune garantie de disponibilité 24/7 (auto-hébergé = vous gérez l'infra)
- Maintenance, mises à jour, correctifs peuvent causer des interruptions

#### 8.2 Sauvegardes
**Vous êtes responsable** de sauvegarder vos workflows n8n, configurations, et médias.
Nous recommandons : backup quotidien base n8n + versioning Git des workflows.

---

### 9. Propriété Intellectuelle

#### 9.1 Nos Droits
L'Application (code, workflows n8n fournis, documentation, marque « n8n TikTok Content Manager ») est notre propriété exclusive ou sous licence.

#### 9.2 n8n
L'Application s'appuie sur **n8n** (licence [Fair Code / Sustainable Use License](https://github.com/n8n-io/n8n/blob/master/LICENSE.md)).
Vous devez respecter la licence n8n pour votre instance auto-hébergée.

#### 9.3 TikTok
« TikTok », le logo TikTok, « Video Kit », « Login Kit » sont des marques de **ByteDance Ltd.** Utilisation conforme aux [Brand Guidelines TikTok](https://developers.tiktok.com/doc/brand-guidelines).

---

### 10. Données Personnelles et Confidentialité

Le traitement de vos données personnelles est régi par notre **[Politique de Confidentialité](PRIVACY_POLICY.md)**.
En utilisant l'Application, vous consentez aux traitements décrits dans cette politique.

---

### 11. Responsabilité et Garanties

#### 11.1 Exclusion de Garanties
L'Application est fournie **SANS GARANTIE** d'aucune sorte, expresse ou implicite :
- Pas de garantie de commercialité, adéquation à un usage particulier, non-contrefaçon
- Pas de garantie que le service sera ininterrompu, sans erreur, sécurisé
- Pas de garantie quant aux résultats (viralité, reach, engagement)

#### 11.2 Limitation de Responsabilité
**Notre responsabilité totale** pour tout dommage direct, indirect, accessoire, consécutif, punitif est limitée à **100 €** (ou montant payé le cas échéant).

Nous ne sommes **pas responsables** pour :
- Perte de données, profits, opportunité, réputation
- Suspension/bannissement compte TikTok
- Modifications API TikTok cassant la compatibilité
- Dysfonctionnements infrastructure tiers (hébergeur, CDN, DNS)

#### 11.3 Force Majeure
Aucune partie n'est responsable des retards/inexécution dus à force majeure (catastrophe, guerre, grève, panne infrastructure majeure, décision réglementaire).

---

### 12. Indemnisation

Vous acceptez d'**indemniser, défendre et tenir hors de cause** l'Éditeur contre toute réclamation, dommage, frais (honoraires d'avocat inclus) découlant de :
- Votre violation des présentes CGU
- Votre contenu publié (contrefaçon, diffamation, vie privée, etc.)
- Votre utilisation non autorisée de l'Application
- Votre violation des droits d'un tiers

---

### 13. Résiliation

#### 13.1 Par Vous
Vous pouvez cesser d'utiliser l'Application à tout moment :
- Déconnexion TikTok dans l'app = suppression tokens
- Suppression de votre instance n8n / workflows

#### 13.2 Par Nous
Nous pouvons suspendre ou résilier votre accès si :
- Violation grave ou répétée des CGU
- Utilisation frauduleuse, illégale, nuisible
- Demande de TikTok / autorité compétente
- Cessation de l'Application (préavis 30j par email)

#### 13.3 Effets de la Résiliation
- Accès à l'Application coupé
- Tokens OAuth révoqués (appel API TikTok `revoke` si dispo)
- Données conservées selon [Politique de Confidentialité](PRIVACY_POLICY.md) (durées maximales)
- Clauses 9, 10, 11, 12, 13, 14, 15 survivent

---

### 14. Droit Applicable et Juridiction

**Droit applicable :** Droit français (ou droit de votre pays de résidence si consommateur UE)  
**Juridiction compétente :** Tribunaux de [Votre Ville / Tribunal de Commerce]  
**Médiation préalable :** Tentative de résolution amiable (30j) avant toute action contentieuse

Pour les consommateurs UE : vous pouvez saisir le tribunal de votre lieu de résidence.

---

### 15. Dispositions Générales

#### 15.1 Intégralité
Ces CGU + Politique de Confidentialité = accord complet entre vous et nous.

#### 15.2 Nullité Partielle
Si une clause est invalide, les autres restent en vigueur. La clause invalide est remplacée par une clause valide au plus proche de l'intention initiale.

#### 15.3 Non-Renonciation
Le fait de ne pas exercer un droit ne constitue pas une renonciation.

#### 15.4 Cession
Nous pouvons céder nos droits/obligations (notification préalable). Vous ne pouvez pas céder les vôtres.

#### 15.5 Langue
Version française faisant foi. Traductions fournies à titre informatif.

---

### 16. Modifications des CGU

Nous pouvons modifier ces CGU à tout moment.
- **Modifications mineures** (clarifications, liens) : entrée en vigueur immédiate, notification in-app
- **Modifications substantielles** (nouvelles obligations, responsabilité, données) : notification **email 30 jours** avant entrée en vigueur + bannière in-app
- Votre utilisation continue après entrée en vigueur = acceptation

Historique versions :
- v1.0 (22/11/2026) : Création initiale pour soumission TikTok API

---

### 17. Contact

Pour toute question relative à ces CGU :

**Éditeur :** [Ton Nom / Raison Sociale]  
**Adresse :** [Ton Adresse Complète]  
**Email :** [ton@email.com]  
**Réponse sous :** 15 jours ouvrés

---

### Annexe : Checklist Conformité TikTok API

| Exigence TikTok | Statut | Preuve / Localisation |
|-----------------|--------|----------------------|
| Privacy Policy accessible via URL | ✅ | Hébergée sur [ton-domaine.com/privacy] |
| Terms of Service accessible via URL | ✅ | Hébergée sur [ton-domaine.com/terms] |
| Logo app conforme Brand Guidelines | ✅ | Fichier `logo.png` (512x512, PNG, fond transparent) |
| Redirect URI HTTPS (production) | ✅ | `https://ton-domaine.com/callback` |
| Scopes minimaux justifiés | ✅ | Voir Privacy Policy § Annexe |
| Data Usage Description fournie | ✅ | Fichier `DATA_USAGE.md` |
| Demo video / screenshots | 🔄 | À fournir avant soumission finale |
| Business verification (si requis) | 🔄 | KBIS / SIRET / Tax ID selon pays |
| Contact support fonctionnel | ✅ | [ton@email.com] — réponse < 48h |

---

*Document généré pour la soumission TikTok Developer Platform — App : « n8n TikTok Content Manager »*

<div class="pb"></div>

## Data Usage Description — n8n TikTok Content Manager

**App Name :** n8n TikTok Content Manager  
**APIs Used :** TikTok Login Kit + Video Kit (Content Posting API)  
**Version :** 1.0  
**Date :** 22 novembre 2026  
**Developer :** [Ton Nom / Raison Sociale]  

---

### 1. Vue d'Ensemble de l'Usage des Données

Cette application est un **outil d'automatisation auto-hébergé** (n8n) permettant aux utilisateurs de **programmer et publier du contenu sur leur propre compte TikTok**. Elle n'agrège pas de données entre utilisateurs, ne fait pas de profilage, ne revend pas de données, et ne les utilise **qu'aux fins strictes de publication de contenu** initiée par l'utilisateur.

**Principe directeur : Minimisation — Nous ne demandons, ne stockons, ne traitons que ce qui est strictement nécessaire pour la fonctionnalité de publication programmée.**

---

### 2. Données Reçues de TikTok (via API)

#### 2.1 Login Kit — `user.info.basic`

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

#### 2.2 Login Kit — `user.info.email`

| Champ | Type | Utilisation dans l'App | Stockage | Durée |
|-------|------|------------------------|----------|-------|
| `email` | String (email) | Notifications critiques : échec publication, token expiré, quota API, alerte sécurité ; récupération compte ; support technique | Chiffré (AES-256) en base n8n | Durée autorisation + 30j post-révocation |

**Finalité :** Communication transactionnelle essentielle au service (pas marketing).  
**Base légale :** Consentement explicite + Exécution contrat (notifications de service).  
**Partage :** Aucun — utilisé uniquement pour envoi emails via SMTP configuré par l'utilisateur.

---

#### 2.3 Video Kit — Données de Publication (Envoi vers TikTok)

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

### 3. Données Générées / Stockées par l'Application (Côté n8n)

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

### 4. Flux de Données (Data Flow Diagram)

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

### 5. Justification Détaillée par Scope Demandé

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

### 6. Mesures de Protection des Données

#### 6.1 Chiffrement
| Donnée | Au Repos | En Transit |
|--------|----------|------------|
| Access/Refresh Tokens | AES-256-GCM (n8n Credentials Store + DB chiffrée) | TLS 1.3 (tous appels API) |
| Email utilisateur | AES-256 (colonne chiffrée PostgreSQL / pgcrypto) | TLS 1.3 (SMTP STARTTLS) |
| Médias (vidéos/images) | SSE-S3 (AES-256) ou MinIO SSE | TLS 1.3 (presigned URLs HTTPS) |
| Workflows / Config | DB chiffrée (LUKS volume + pgcrypto) | TLS 1.3 (interface n8n) |

#### 6.2 Contrôle d'Accès
- **Authentification n8n** : MFA (TOTP) obligatoire pour admin, recommandé pour utilisateurs
- **RBAC n8n** : Rôles `owner` / `editor` / `viewer` par workspace
- **Isolation multi-locataire** : Un compte TikTok = un credential set = un workspace (ou dossier) isolé
- **Principe moindre privilège** : Worker n8n n'a accès qu'aux credentials de son compte assigné

#### 6.3 Gestion du Cycle de Vie
| Action | Déclencheur | Opération |
|--------|-------------|-----------|
| **Révocation tokens** | User clique « Déconnecter TikTok » dans UI n8N | 1. Suppression credentials n8n 2. Appel `POST /oauth2/revoke` TikTok (si token valide) 3. Purge médias temporaires associés 4. Log audit |
| **Expiration access_token** | 4h (standard TikTok) | Refresh automatique via refresh_token avant exécution publication (middleware n8n) |
| **Expiration refresh_token** | 60j ou révocation user | Alerte email 7j avant + jour J → User doit se reconnecter |
| **Suppression médias temp** | Publication confirmée (webhook TikTok ou polling statut) | Suppression S3 immédiate (cycle de vie config 0j) |
| **Purge logs exécution** | Cron mensuel | Suppression logs > 1 an (garde audit 3 ans sur bucket froid séparé) |
| **Demande suppression RGPD** | User exerce droit à l'effacement | Workflow n8n dédié : purge toutes tables, credentials, S3, logs → confirmation email |

#### 6.4 Sécurité Opérationnelle
- **Rate limiting propre** : File d'attente BullMQ (1 job/sec/compte max) + respect headers `X-RateLimit-*` TikTok
- **Monitoring alertes** : Prometheus rules sur taux erreurs 4xx/5xx, latence, quota TikTok > 80%
- **Backup chiffré** : Dump DB quotidien (chiffré GPG) vers bucket versionné (rétention 30j)
- **Plan incident** : Procédure documentée (detection → containment → notification 72h CNIL si violation données personnelles)

---

### 7. Conformité RGPD / Protection Données

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

### 8. Transferts Internationaux

| Flux | Origine → Destination | Mécanisme Juridique |
|------|----------------------|---------------------|
| API Calls | Instance n8n (UE) → TikTok API (US/SG/EU selon routage) | SCC 2021/914 (TikTok Developer Terms) + TIAA documentée |
| Stockage médias | Instance n8n → S3 (région choisie par user : eu-west-1, etc.) | Même région que l'instance = pas de transfert |
| Notifications email | Instance n8n → SMTP (provider user : OVH, SendGrid, AWS SES) | Contrat sous-traitance Art. 28 RGPD avec provider |
| Monitoring | Instance n8n → Prometheus/Grafana (self-hosted ou cloud EU) | Même infra ou SCC si cloud hors UE |

**Auto-hébergé = l'utilisateur choisit sa région d'hébergement** → contrôle total sur les transferts.

---

### 9. Aucun Usage Secondaire

| Usage | Statut | Preuve |
|-------|--------|--------|
| **Publicité ciblée** | ❌ Jamais | Pas de pixel, pas de tracking, pas d'IDFA/GAID |
| **Analytics produit** | ❌ Jamais (sauf logs techniques anonymes) | Pas de Mixpanel, Amplitude, GA ; logs n8n seulement |
| **Entraînement IA/ML** | ❌ Jamais | Pas de collecte contenu pour training |
| **Vente/Partage données** | ❌ Jamais | Business model = open source + services, pas data |
| **Profilage utilisateurs** | ❌ Jamais | Pas de scoring, recommandations cross-comptes |
| **Enrichissement tiers** | ❌ Jamais | Pas d'API Clearbit, FullContact, etc. |

---

### 10. Tests et Validation

| Test | Méthode | Fréquence |
|------|---------|-----------|
| **Fuite tokens dans logs** | Grep regex `access_token\|refresh_token` sur logs staging | Chaque déploiement (CI/CD) |
| **Chiffrement au repos** | Vérification `pgcrypto` / LUKS / S3 SSE headers | Audit trimestriel |
| **Révocation effective** | Test E2E : déconnexion → tentative appel API → 401 | Chaque release |
| **Purge médias temp** | Vérification bucket S3 : objets > 7j sans tag `published=true` | Cron hebdo + alerte |
| **Export RGPD complet** | Test manuel : export → vérif exhaustivité vs inventaire données | Avant chaque mise à jour schema DB |
| **Rate limit respect** | Simulation charge (Locust) : 100 publications séquentielles → 0 erreur 429 | Pré-release |

---

### 11. Checklist Soumission TikTok

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

### 12. Contact pour Questions TikTok Review Team

**Développeur / DPO :** [Ton Nom]  
**Email :** [ton@email.com]  
**Téléphone :** [+33 X XX XX XX XX]  
**Adresse :** [Ton Adresse Complète]  
**Instance Demo (si demandée) :** `https://demo.ton-domaine.com` (accès temporaire sur demande)  
**Repo GitHub :** `https://github.com/ton-user/n8n-tiktok-content-manager` (public ou privé avec accès review team)

---

*Document préparé pour la revue **TikTok Developer Platform** — App : « n8n TikTok Content Manager » — APIs : **Login Kit** + **Video Kit (Content Posting API)** — Conformité RGPD Art. 28, 30, 32, 33, 35*

<div class="pb"></div>

## Spécifications Logo — n8n TikTok Content Manager

**Pour designer / génération** — Respect strict des [TikTok Brand Guidelines](https://developers.tiktok.com/doc/brand-guidelines)

---

### 📐 Spécifications Techniques

| Propriété | Valeur |
|-----------|--------|
| **Dimensions** | 512 × 512 px (carré) |
| **Format** | PNG (transparence) — **pas de JPG** |
| **Taille max** | < 1 MB |
| **Espace colorimétrique** | sRGB |
| **Fond** | **Transparent** (alpha channel) — pas de fond blanc/noir/couleur |
| **Marge de sécurité** | Zone utile centrée : 400 × 400 px (marge 56px chaque côté) |

---

### 🎨 Consignes de Design

#### ✅ À FAIRE
- Logo **original** représentant ton app (n8n + TikTok + contenu/planification)
- Style **propre, lisible à petite taille** (test à 64×64 px)
- Couleurs **accessibles** (contraste WCAG AA minimum)
- Éléments vectoriels si possible (export PNG depuis SVG)

#### ❌ INTERDIT (Rejet garanti)
- **Logo TikTok officiel** ou version modifiée (couleur changée, rogné, effets)
- Marque « TikTok » dans le logo (nom seul = texte, pas logo)
- Icône « lecture » (play button) style TikTok
- Fond coloré ou blanc (doit être transparent)
- Texte illisible à 64×64 px
- Ombre portée, dégradés complexes, effets 3D

---

### 💡 Concepts Visuels Suggérés

#### Option A : « Workflow Node » (Recommandé)
```
┌─────────────────────────────────────┐
│   ████  ████  ████                  │  ← Nœuds n8n stylisés (3-4)
│   █  █  █  █  █  █                  │
│   ████  ████  ████        ▶         │  ← Flèche/flux vers la droite
│        █      █           ▶         │
│   ████  █      █         ▶          │
│                                 ♫   │  ← Note de musique / icône vidéo TikTok
└─────────────────────────────────────┘
```
**Symbolique :** Automatisation (nœuds n8n) → Publication (flèche) → TikTok (note musicale)

#### Option B : « Calendrier + Upload »
```
┌─────────────────────────────────────┐
│  ┌─────────┐     ┌─────────┐        │
│  │ 22  NOV │ ──▶ │  📤     │        │  ← Date + upload
│  └─────────┘     └─────────┘        │
│        ♫                            │  ← Touche TikTok subtile
└─────────────────────────────────────┘
```

#### Option C : « n8n + TikTok » Minimaliste
```
┌─────────────────────────────────────┐
│     n8n                             │  ← Typographie n8n (ou ton logo)
│      │                              │
│      ▼                              │
│    ┌───┐                            │
│    │ ▶ │  ♫                         │  ← Play button générique + note
│    └───┘                            │
└─────────────────────────────────────┘
```

---

### 🎨 Palette Couleurs Suggerée

| Usage | Hex | RGB | Note |
|-------|-----|-----|------|
| **Primaire (n8n)** | `#EA5B0C` | 234, 91, 12 | Orange n8n officiel |
| **Secondaire (TikTok)** | `#000000` / `#FFFFFF` | Noir/Blanc | Style TikTok monochrome |
| **Accent** | `#00F2EA` | 0, 242, 234 | Cyan TikTok (avec parcimonie) |
| **Neutre foncé** | `#1A1A2E` | 26, 26, 46 | Fond sombre si nécessaire |
| **Neutre clair** | `#F5F5F5` | 245, 245, 245 | Fond clair si nécessaire |

> **Important :** Ton logo doit fonctionner **sur fond clair ET foncé** (transparent = test les deux).

---

### 📱 Déclinaisons Requises

| Fichier | Dimensions | Usage |
|---------|------------|-------|
| `logo-512.png` | 512×512 | **Soumission TikTok (obligatoire)** |
| `logo-256.png` | 256×256 | Dashboard n8n, favicon large |
| `logo-128.png` | 128×128 | Notifications, toolbar |
| `logo-64.png` | 64×64 | Favicon, menu latéral |
| `logo-32.png` | 32×32 | Favicon browser |
| `logo.svg` | Vectoriel | Source maîtresses, redimensionnement infini |

---

### ✅ Checklist Validation Avant Envoi

- [ ] **512×512 px** exactement
- [ ] **PNG avec transparence** (vérifier : ouvrir dans navigateur, fond damier visible)
- [ ] **< 1 MB** (optimiser : `pngcrush`, `optipng`, TinyPNG)
- [ ] **Lisible à 64×64 px** (tester : réduire dans navigateur)
- [ ] **Pas de logo TikTok** ni marque protégée
- [ ] **Fonctionne sur fond blanc ET noir** (tester les deux)
- [ ] **Marge de sécurité 56px** respectée (éléments centrés dans 400×400)
- [ ] **Couleurs accessibles** (contraste ≥ 4.5:1 sur fond clair/sombre)
- [ ] **SVG source** conservé pour futures modifications

---

### 🛠 Outils Recommandés

| Outil | Usage |
|-------|-------|
| **Figma** (gratuit) | Design vectoriel, export multi-tailles, composants |
| **Inkscape** (gratuit, open-source) | Alternative Figma desktop |
| **Adobe Illustrator** | Si licence dispo |
| **TinyPNG / ImageOptim** | Compression PNG sans perte visible |
| **pngcrush / optipng** (CLI) | Optimisation automatisée en CI |

---

### 📤 Livraison au Designer (Brief Prêt à Copier)

> **Brief Logo — n8n TikTok Content Manager**
>
> App d'automatisation publication TikTok via n8n (workflows visuels). Public : créateurs, community managers, agences.
>
> **Livrables :** PNG 512×512 (transparent) + SVG source + déclinaisons 256/128/64/32.
>
> **Concept :** Automatisation (nœuds/flux n8n) → Publication (flèche/upload) → TikTok (note musicale subtile). Pas de logo TikTok officiel.
>
> **Couleurs :** Orange n8n (#EA5B0C) + Noir/Blanc + accent cyan TikTok (#00F2EA) optionnel.
>
> **Style :** Moderne, tech, propre, lisible petit. Flat design ou légère profondeur. Pas d'ombres portées lourdes.
>
> **Inspiration visuelle :** n8n logo + GitHub Actions + Zapier + TikTok brand guidelines (monochrome).
>
> **Deadline :** [Date] — Fichiers via [lien partage / repo]

---

### 🔗 Références

- [TikTok Brand Guidelines](https://developers.tiktok.com/doc/brand-guidelines) — **À lire impérativement**
- [n8n Brand Assets](https://n8n.io/brand) — Pour référence style n8n
- [Material Icons / Lucide / Phosphor] — Icônes libres pour inspiration (flèche, upload, calendrier, note musique)

---

*Spécs préparées pour la soumission TikTok Developer Platform — App : « n8n TikTok Content Manager »*
