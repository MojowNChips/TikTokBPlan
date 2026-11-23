# Description de l'Application — n8n TikTok Content Manager

**Nom de l'App :** n8n TikTok Content Manager  
**Version :** 1.0  
**Date :** 22 novembre 2026  
**Développeur :** [Ton Nom / Raison Sociale]  
**Contact :** [ton@email.com]  
**Site web / Landing page :** [https://ton-domaine.com]  

---

## 1. Résumé Exécutif (1-2 phrases)

**n8n TikTok Content Manager** est une application auto-hébergée construite sur **n8n** (plateforme d'automatisation low-code) qui permet aux créateurs de contenu, community managers et agences de **programmer, préparer et publier automatiquement des vidéos et photos sur TikTok** via une interface visuelle de workflows, tout en respectant scrupuleusement les politiques API et Community Guidelines de TikTok.

---

## 2. Problème Résolu (Use Case Principal)

### Contexte
Les créateurs et gestionnaires de contenu TikTok font face à plusieurs défis :
- **Publication manuelle chronophage** : obligation d'être devant l'app au moment optimal
- **Gestion multi-comptes complexe** : basculer entre comptes pro/perso, clients
- **Absence de planification native avancée** : TikTok permet le brouillon mais pas la publication programmée récurrente avec files d'attente intelligentes
- **Workflow éclaté** : idée → script → tournage → montage → légende → hashtags → publication = outils multiples, pas de traçabilité

### Solution Apportée
L'Application centralise **tout le pipeline de publication** dans des workflows n8n visuels :
1. **Collecte** : formulaires, webhooks, Google Sheets, Notion, Airtable → idées/contenu
2. **Préparation** : montage vidéo automatisé (FFmpeg), génération légendes (IA), sélection hashtags, miniatures
3. **Planification** : calendrier visuel, récurrence, fuseaux horaires, file d'attente prioritaire
4. **Publication** : envoi programmé via **TikTok Video Kit** (upload → publish) avec gestion erreurs/retry
5. **Suivi** : logs statut, métriques de base, notifications (email, Slack, Discord, Telegram)

---

## 3. Fonctionnalités Détaillées

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

## 4. Architecture Technique

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

### Stack Technique
- **Orchestration :** n8n (self-hosted, Docker/K8s/VM)
- **Base de données :** PostgreSQL (prod) / SQLite (dev) — chiffrement au repos
- **Stockage médias :** S3-compatible (MinIO, AWS S3, Cloudflare R2) — cycle de vie auto (suppression post-publication)
- **Secrets :** HashiCorp Vault / Variables d'env chiffrées / n8n credentials
- **Monitoring :** Prometheus + Grafana / n8n execution logs
- **Reverse Proxy :** Traefik / Nginx (TLS 1.3, rate limiting, WAF basique)

### Sécurité
- ✅ OAuth 2.0 + PKCE (Authorization Code Flow)
- ✅ Tokens chiffrés au repos (AES-256-GCM)
- ✅ Refresh token rotation + révocation à la déconnexion
- ✅ HTTPS obligatoire (TLS 1.3)
- ✅ Rate limiting propre + respect rate limits TikTok
- ✅ Aucune donnée sensible dans logs (masquage tokens)
- ✅ Suppression auto médias après publication confirmée (configurable)

---

## 5. Public Cible

| Segment | Description | Besoin Clé |
|---------|-------------|------------|
| **Créateurs individuels** | Influenceurs, artistes, éducateurs (10k-1M abonnés) | Gain de temps, régularité, multi-plateforme futur |
| **Community Managers / Agences** | Gestion 5-50 comptes clients | Multi-comptes, validation client, reporting, white-label |
| **Équipes Marketing / Marque** | Marques e-commerce, SaaS, médias | Calendrier éditorial, UGC, campagne produit, conformité marque |
| **Développeurs n8n / No-code** | Utilisateurs n8n souhaitant intégrer TikTok | Nœuds n8n réutilisables, templates workflows |

**Estimation utilisateurs cibles :** 500-2000 utilisateurs actifs première année (croissance organique via communauté n8n + bouche-à-oreille créateurs)

---

## 6. Flux Utilisateur Type (User Journey)

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

## 7. Conformité TikTok API

### Scopes Demandés (Minimisation)
| Scope | Justification Business |
|-------|------------------------|
| `user.info.basic` | Identifier l'utilisateur connecté, afficher nom/avatar dans dashboard n8n, isoler workspaces par compte |
| `user.info.email` | Notifications critiques (échec publication, expiration token), récupération compte, support |
| `video.upload` | **Requis** pour pré-uploader médias avant publication (chunked upload, reprise) |
| `video.publish` | **Cœur de métier** : publication programmée vidéos/photos sur le fil TikTok |

### Scopes **NON** Demandés (et pourquoi)
| Scope | Pourquoi pas |
|-------|--------------|
| `user.info.stats` | Pas besoin d'analytics (TikTok Analytics suffit), minimisation |
| `video.list` | L'app gère son propre état (brouillons, planifié), pas besoin de lister l'existant |
| `comment.list/manage` | Hors scope MVP — modération commentaires gérée nativement sur TikTok |
| `live.*` | Pas de fonctionnalité live dans l'app |

### Respect Rate Limits & Quotas
- **File d'attente n8n** : 1 worker par compte TikTok, séquentiel
- **Retry intelligent** : Backoff exponentiel (1min, 5min, 15min, 1h) + alerte
- **Monitoring quotas** : Alerte à 80% quota journalier
- **Batch upload** : Un média à la fois (pas de parallélisme qui risquerait 429)

### Conformité Contenu
- Validation côté client : format vidéo (MP4, MOV, WebM), taille (<10Go), durée (<10min ou <60s selon type), ratio (9:16, 1:1, 16:9)
- Avertissement Community Guidelines dans l'UI avant publication
- Pas de modification contenu post-upload (respect intégrité média)
- Support suppression post via TikTok (si utilisateur supprime sur TikTok, sync statut dans n8n)

---

## 8. Modèle Économique / Business Model

| Modèle | Détails |
|--------|---------|
| **Open Source (Core)** | Workflows n8n, nœuds personnalisés, documentation → Gratuit, MIT/Apache 2.0 |
| **Hébergé SaaS (Optionnel)** | Instance n8n gérée, backup, monitoring, support → Abonnement mensuel (freemium) |
| **Services Pro** | Setup, formation, templates métier, développement nœuds custom → Facturation projet |
| **Partenariat Agences** | Licence multi-clients, white-label, support prioritaire → Partage revenus / licence annuelle |

**Pas de monétisation données utilisateur** — Pas de vente, pas de publicité, pas de tracking tiers.

---

## 9. Différenciateurs vs Concurrents

| Concurrent | Limite | Notre Avantage |
|------------|--------|----------------|
| **Buffer / Hootsuite / Later** | Payant, limité TikTok (pas toujours API officielle), pas n8n | **Auto-hébergé, gratuit (core), extensible à l'infini via n8n** |
| **Zapier / Make (Integromat)** | Coût par tâche, nodes TikTok limités/obsolètes | **Nodes natifs n8n, 0 coût marginal, contrôle total data** |
| **Scripts Python perso** | Maintenance, pas d'UI, pas de file d'attente robuste | **UI visuelle, retry, monitoring, multi-comptes, templates** |
| **TikTok Studio (natif)** | Pas de planification récurrente avancée, pas multi-comptes pro | **Workflow complet : idée → publication → suivi, automatisation** |

---

## 10. Roadmap (Prochains 12 Mois)

| Trimestre | Objectifs |
|-----------|-----------|
| **Q4 2026** | MVP : Auth + Upload + Publish + Queue + Dashboard de base + Docs |
| **Q1 2027** | Templates workflows (créateurs, agences, e-commerce), Multi-comptes avancé, Notifications riches |
| **Q2 2027** | Analytics basiques (vues, likes via API si dispo), IA légendes/hashtags, Support webhook TikTok (real-time) |
| **Q3 2027** | Version SaaS hébergée (beta), Marketplace templates communautaires, Certifications sécurité |

---

## 11. Liens Utiles pour la Revue TikTok

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

## 12. Checklist Pré-Soumission

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