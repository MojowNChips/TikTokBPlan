# Spécifications Logo — n8n TikTok Content Manager

**Pour designer / génération** — Respect strict des [TikTok Brand Guidelines](https://developers.tiktok.com/doc/brand-guidelines)

---

## 📐 Spécifications Techniques

| Propriété | Valeur |
|-----------|--------|
| **Dimensions** | 512 × 512 px (carré) |
| **Format** | PNG (transparence) — **pas de JPG** |
| **Taille max** | < 1 MB |
| **Espace colorimétrique** | sRGB |
| **Fond** | **Transparent** (alpha channel) — pas de fond blanc/noir/couleur |
| **Marge de sécurité** | Zone utile centrée : 400 × 400 px (marge 56px chaque côté) |

---

## 🎨 Consignes de Design

### ✅ À FAIRE
- Logo **original** représentant ton app (n8n + TikTok + contenu/planification)
- Style **propre, lisible à petite taille** (test à 64×64 px)
- Couleurs **accessibles** (contraste WCAG AA minimum)
- Éléments vectoriels si possible (export PNG depuis SVG)

### ❌ INTERDIT (Rejet garanti)
- **Logo TikTok officiel** ou version modifiée (couleur changée, rogné, effets)
- Marque « TikTok » dans le logo (nom seul = texte, pas logo)
- Icône « lecture » (play button) style TikTok
- Fond coloré ou blanc (doit être transparent)
- Texte illisible à 64×64 px
- Ombre portée, dégradés complexes, effets 3D

---

## 💡 Concepts Visuels Suggérés

### Option A : « Workflow Node » (Recommandé)
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

### Option B : « Calendrier + Upload »
```
┌─────────────────────────────────────┐
│  ┌─────────┐     ┌─────────┐        │
│  │ 22  NOV │ ──▶ │  📤     │        │  ← Date + upload
│  └─────────┘     └─────────┘        │
│        ♫                            │  ← Touche TikTok subtile
└─────────────────────────────────────┘
```

### Option C : « n8n + TikTok » Minimaliste
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

## 🎨 Palette Couleurs Suggerée

| Usage | Hex | RGB | Note |
|-------|-----|-----|------|
| **Primaire (n8n)** | `#EA5B0C` | 234, 91, 12 | Orange n8n officiel |
| **Secondaire (TikTok)** | `#000000` / `#FFFFFF` | Noir/Blanc | Style TikTok monochrome |
| **Accent** | `#00F2EA` | 0, 242, 234 | Cyan TikTok (avec parcimonie) |
| **Neutre foncé** | `#1A1A2E` | 26, 26, 46 | Fond sombre si nécessaire |
| **Neutre clair** | `#F5F5F5` | 245, 245, 245 | Fond clair si nécessaire |

> **Important :** Ton logo doit fonctionner **sur fond clair ET foncé** (transparent = test les deux).

---

## 📱 Déclinaisons Requises

| Fichier | Dimensions | Usage |
|---------|------------|-------|
| `logo-512.png` | 512×512 | **Soumission TikTok (obligatoire)** |
| `logo-256.png` | 256×256 | Dashboard n8n, favicon large |
| `logo-128.png` | 128×128 | Notifications, toolbar |
| `logo-64.png` | 64×64 | Favicon, menu latéral |
| `logo-32.png` | 32×32 | Favicon browser |
| `logo.svg` | Vectoriel | Source maîtresses, redimensionnement infini |

---

## ✅ Checklist Validation Avant Envoi

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

## 🛠 Outils Recommandés

| Outil | Usage |
|-------|-------|
| **Figma** (gratuit) | Design vectoriel, export multi-tailles, composants |
| **Inkscape** (gratuit, open-source) | Alternative Figma desktop |
| **Adobe Illustrator** | Si licence dispo |
| **TinyPNG / ImageOptim** | Compression PNG sans perte visible |
| **pngcrush / optipng** (CLI) | Optimisation automatisée en CI |

---

## 📤 Livraison au Designer (Brief Prêt à Copier)

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

## 🔗 Références

- [TikTok Brand Guidelines](https://developers.tiktok.com/doc/brand-guidelines) — **À lire impérativement**
- [n8n Brand Assets](https://n8n.io/brand) — Pour référence style n8n
- [Material Icons / Lucide / Phosphor] — Icônes libres pour inspiration (flèche, upload, calendrier, note musique)

---

*Spécs préparées pour la soumission TikTok Developer Platform — App : « n8n TikTok Content Manager »*