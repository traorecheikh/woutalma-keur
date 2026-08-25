# Woutalma Keur — Règles d'implémentation UI

Ce fichier complète `DESIGN.md`. Séparation stricte :

- **`DESIGN.md`** décrit l'identité visuelle au format [google-labs-code/design.md](https://github.com/google-labs-code/design.md) :
  jetons YAML + les huit sections canoniques. Il ne contient **rien** d'autre, pour rester
  lintable par l'outillage du format et lisible par tout agent qui le connaît.
- **`WOUTALMA-UI.md`** — ce fichier — porte ce qui est propre à ce produit et à Flutter : cibles
  tactiles, accessibilité pour non-lecteurs, chemin vocal, interdits de code, catalogue des
  widgets, localisation, tests.

**En cas de conflit, `DESIGN.md` fait autorité sur les valeurs ; ce fichier fait autorité sur les
règles d'usage.**

Ces règles s'adressent autant aux humains qu'aux agents IA travaillant sur ce dépôt. Une revue de
code les applique littéralement.

---

## 1. Cibles tactiles

| Jeton | Valeur | Application |
|:--|:--|:--|
| `touch.min` | **56 dp** | plancher absolu de toute cible tactile : icône seule, chip, bouton secondaire, fantôme, danger, appel, WhatsApp, étoile de notation |
| `touch.comfy` | **64 dp** | action primaire, champ de saisie, ligne de `WkOptionSheet`, ligne de liste actionnable |
| `touch.voice` | **96 dp** | bouton micro |

- Espacement minimal entre deux cibles : **12 dp**.
- Deux actions destructrices ne sont jamais adjacentes.
- **Un seul bouton primaire par écran.** Les autres sont secondaires ou fantômes.

Ces valeurs sont des **hauteurs minimales**, jamais figées : à ×1.3, un composant grandit.

**Résolution d'un conflit antérieur.** `DESIGN.md` fixait `button-primary` à 56 alors que cette
table réclamait 64 pour l'action primaire, et rangeait le chip en 64 alors que `DESIGN.md` le
fixait à 56. Tranché ainsi : **l'action primaire passe à 64** — un seul bouton par écran, c'est le
geste dominant d'une utilisatrice qui vise à une main, dehors, sur un petit écran — et **le chip
reste à 56**, sinon une rangée de filtres mange le premier résultat de C01. `DESIGN.md` porte
désormais ces deux valeurs.

## 2. Accessibilité et non-lecteurs

- Chaque widget interactif porte un `Semantics` avec un libellé **en langage naturel** — c'est ce
  que TalkBack énonce. Jamais un identifiant technique.
- Contraste minimal **4.5:1** pour tout texte, **3:1** pour toute bordure ou pictogramme porteur
  de sens.
- L'ordre de lecture suit l'ordre visuel. Aucune information n'est portée uniquement par la
  position.
- Chaque état porte **couleur + pictogramme + mot**. Aucune pastille de couleur nue.
- Un pictogramme familier peut être autonome ; toute icône ambiguë conserve un libellé visible.
  Dans tous les cas, `Semantics` fournit un nom d'action complet.
- Chaque écran survit à ×1.3 de taille de texte sans troncature.

## 3. Chemin vocal

> **État au 2026-08-14 — le micro est retiré des écrans produit.** Ce qui suit
> décrit la cible, pas ce qui est livré. `SimulatedVoiceService` rendait un
> script figé ; l'exposer comme une recherche vocale promettait à la cible qui
> ne lit pas quelque chose qui n'existait pas. `WkSearchTrigger.onVoice` et
> `WkSearchBar.onVoice` sont nullables et aucun appelant ne les fournit, donc
> le micro ne peut pas revenir par inadvertance. `M03` survit dans le catalogue
> S02. Les points 2 et 3 ci-dessous reprennent effet le jour où un moteur réel
> est branché ; la lecture à voix haute (`Écouter`), elle, n'a jamais été
> touchée.

Le vocal n'est pas une option, c'est un **chemin parallèle complet** : ouvrir l'application,
trouver un courtier et l'appeler doit être possible **sans lire un seul mot**.

1. Chaque écran possède un `WkSpeakButton` dans sa barre haute, qui lit l'écran à voix haute dans
   la langue courante — titre puis chaque élément, dans l'ordre visuel.
2. Chaque écran de saisie propose une alternative vocale : recherche → micro ; message → message
   vocal ; ajout de bien côté courtier → dictée.
3. Le bouton micro est le plus gros élément interactif de l'écran d'accueil, en bas à droite.
4. Les trois états d'écoute sont distinguables **sans texte**, et l'entrée en écoute est
   confirmée par un retour haptique.
5. **Phase 1 : la reconnaissance est simulée.** Toute la mécanique passe par l'interface
   `VoiceService` (`lib/app/data/services/voice/`). Le jour où un moteur réel existe, on
   remplace l'implémentation — aucun écran ne bouge.

## 4. Interdits de code

| Interdit | À la place |
|:--|:--|
| `DropdownButton`, `DropdownMenu`, `PopupMenuButton`, `showDialog`, `AlertDialog`, `showModalBottomSheet` | `pick()`, `confirm()`, `showAppSheet()` |
| `SnackBar`, `ScaffoldMessenger` | `toast()` |
| `AppBar`, `Scaffold` nu, `Card`, `ListTile`, `ElevatedButton`, `TextButton`, `IconButton`, `TextField` | `AppScaffold`, `AppCard`, `AppRow`, `AppButton`, `AppIconButton`, `AppField` |
| `Icons.*` | `FIcons.*` (Lucide) |
| `Colors.*`, `Color(0x…)`, `TextStyle(...)`, nombre magique de padding ou de rayon dans un écran | `context.colors`, `context.tones`, `context.text`, `Insets.*`, `Radii.*` |
| Chaîne visible en dur | `context.l10n.*` |
| Commentaire qui redit le code | un meilleur nom |

## 5. Obligations

- Tout widget partagé vit dans `lib/app/ui/ui.dart` (préfixe `App`), et n'y entre que si deux
  écrans s'en servent. Un widget propre à un écran reste privé dans le fichier de l'écran.
- Tout écran observe des modèles exposés par `provider` et ne contient aucune logique métier.
- Toute règle métier vit dans un service Dart pur, testé unitairement.
- Tout écran couvre vide / chargement (`AppSkeleton`) / peuplé / erreur (`failureState`).
- Paquets avant code maison : `forui`, `flutter_slidable`, `smooth_page_indicator`, `skeletonizer`,
  `record`, `audioplayers`, `phone_form_field`, `pinput`, `flutter_map`.

## 6. Catalogue des primitives (`lib/app/ui/ui.dart`)

**Structure** — `AppScaffold` (en-tête forui avec retour et actions, bandeau hors ligne, action
fixe en bas, `onRefresh`), `AppTitle`, `AppSection`, `AppNavBar`, `AppStrip`.

**Actions** — `AppButton` (primary / secondary / ghost / danger / call / whatsapp, `loading`),
`AppIconButton`, `AppPill`, `AppSegmented`, `AppChoice`.

**Saisie** — `AppField`, `AppSearchPill`, `pick()`, `AppPhotoPicker`, `AppVoiceNoteRecorder`.

**Contenu** — `AppCard` / `AppCard.rows` + `AppRow`, `AppAvatar`, `AppPhoto`, `AppStars`,
`AppTag`, `AppOverlayChip`, `AppMoney`, `AppKeyTile`, `AppStatCard`, `AppVoiceNotePlayer`,
`PhotoCarousel` / `PropertyCard` / `BrokerCard` (`modules/client/explore/cards.dart`).

**États et retours** — `AppState`, `AppSkeleton`, `failureState`, `toast()`, `confirm()`,
`showAppSheet()`.
