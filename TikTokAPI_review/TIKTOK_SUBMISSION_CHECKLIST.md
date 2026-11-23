# Checklist Complète — Soumission TikTok Developer Platform

**App :** n8n TikTok Content Manager  
**APIs :** Login Kit + Video Kit (Content Posting API)  
**Date :** 22 novembre 2026  

---

## 📋 Documents Obligatoires (À héberger sur ton domaine HTTPS)

| Document | Fichier Local | URL Cible (à créer) | Statut |
|----------|---------------|---------------------|--------|
| **Privacy Policy** | `PRIVACY_POLICY.md` | `https://ton-domaine.com/privacy` | ✅ Prêt |
| **Terms of Service** | `TERMS_OF_SERVICE.md` | `https://ton-domaine.com/terms` | ✅ Prêt |
| **Data Usage Description** | `DATA_USAGE.md` | `https://ton-domaine.com/data-usage` | ✅ Prêt |
| **App Description** | `APP_DESCRIPTION.md` | (Copier-coller dans formulaire) | ✅ Prêt |

---

## 🎨 Assets Visuels (À créer)

| Asset | Spécifications | Statut | Notes |
|-------|----------------|--------|-------|
| **Logo App** | 512×512 px, PNG, fond transparent, < 1MB | 🔄 À faire | Respecter [TikTok Brand Guidelines](https://developers.tiktok.com/doc/brand-guidelines) — pas de logo TikTok modifié |
| **Screenshots (min 3, max 10)** | 1280×720 min, PNG/JPG, interface n8n réelle | 🔄 À faire | 1. Dashboard 2. Workflow editor 3. Formulaire publication 4. Historique 5. Connexion OAuth |
| **Demo Video** | 3-5 min, MP4, 1080p, < 100MB | 🔄 À faire | Parcours complet : Connexion → Création workflow → Planification → Publication → Historique |
| **Cover Image (optionnel)** | 1280×720, pour fiche app store | ⏸️ Optionnel | Si tu vises l'App Marketplace TikTok |

---

## 🔧 Configuration Technique (À valider avant soumission)

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

## 🏢 Vérification Entreprise (Business Verification)

| Document | Requis ? | Statut | Notes |
|----------|----------|--------|-------|
| **KBIS / Extrait SIRENE** (France) | Oui si entreprise | 🔄 À fournir | Moins de 3 mois |
| **Statuts / SIRET** | Oui | 🔄 À fournir | |
| **Piece identité dirigeant** | Parfois | 🔄 À fournir | Passeport/CNI |
| **Preuve adresse entreprise** | Parfois | 🔄 À fournir | Facture < 3 mois |
| **Tax ID / VAT Number** | Si applicable | 🔄 À fournir | FRxx xxxxxxxxx |

> **Note :** TikTok demande la vérification entreprise pour les apps qui publient du contenu (Video Kit). Prépare ces docs à l'avance.

---

## ✅ Tests Techniques Pré-Soumission

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

## 📝 Champs Formulaire TikTok (Copier-Coller)

### Informations de Base
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

### Scopes Demandés (avec justifications courtes pour le formulaire)
```
user.info.basic → Identifier l'utilisateur, isoler workspaces multi-comptes, afficher nom/avatar dans dashboard
user.info.email → Notifications critiques service (échec publication, token expiré, quota API) — pas marketing
video.upload → Requis par Video Kit pour chunked upload médias (reprise, gros fichiers)
video.publish → Cœur de métier : publication programmée vidéos/photos sur le fil utilisateur
```

### Use Case Description (version courte pour formulaire)
```
L'application permet aux créateurs et community managers de programmer et publier automatiquement du contenu sur TikTok via une interface visuelle de workflows n8n. Elle gère l'authentification OAuth sécurisée, l'upload chunked de médias, la file d'attente respectant les rate limits TikTok, les notifications de statut, et fournit un audit trail complet. Auto-hébergée, open-source, conforme RGPD, sans monétisation de données utilisateur.
```

---

## 🚀 Étapes de Soumission

1. **Héberger les docs** sur `https://ton-domaine.com/privacy`, `/terms`, `/data-usage` (HTML ou Markdown rendu)
2. **Créer les assets** : Logo (512×512 PNG), Screenshots (3-5), Demo video (3-5 min)
3. **Configurer Redirect URI** en prod sur ton serveur n8n (`/callback` endpoint)
4. **Rassembler docs entreprise** (KBIS, SIRET, pièce identité, justificatif adresse)
5. **Tester l'OAuth flow complet** sur compte test TikTok (mode sandbox)
6. **Remplir le formulaire** sur https://developers.tiktok.com → My Apps → Create App
7. **Soumettre pour review** → Attendre feedback (généralement 3-10 jours ouvrés)
8. **Répondre aux questions** de la review team si demandé (souvent : précisions data usage, demo video, business verification)

---

## 📞 Contacts Utiles

| Contact | Usage |
|---------|-------|
| **TikTok Developer Support** | https://developers.tiktok.com/support/ |
| **TikTok API Discord** | https://discord.gg/tiktokdevelopers |
| **Brand Guidelines** | https://developers.tiktok.com/doc/brand-guidelines |
| **API Reference** | https://developers.tiktok.com/doc/login-kit-web / https://developers.tiktok.com/doc/video-kit |
| **Platform Policies** | https://developers.tiktok.com/doc/platform-policies |

---

## 📁 Fichiers dans ce Dossier

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

## ⚠️ Points d'Attention Fréquents (Rejets Communs)

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