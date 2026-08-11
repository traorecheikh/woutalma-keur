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
| `DropdownButton`, `DropdownMenu`, `PopupMenuButton` | `WkSelectField` + `WkOptionSheet` |
| `AlertDialog`, `showDialog` | `WkConfirmSheet` |
| `SnackBar`, `ScaffoldMessenger` | `WkToast` |
| `AppBar` | `WkTopBar` |
| `Scaffold` nu dans un écran | `WkScaffold` |
| `ListTile` | `WkListAction` ou `WkInfoRow` |
| `Card` | `WkCard` et ses variantes |
| `ElevatedButton`, `TextButton`, `OutlinedButton`, `IconButton` | `WkButton`, `WkIconButton` |
| `Colors.*`, `Color(0x…)` dans un écran | `context.colors.*` |
| `TextStyle(...)` en ligne | `Theme.of(context).textTheme.*` |
| Nombre magique de padding ou de rayon | `AppSpacing.*`, `AppRadius.*` |
| Chaîne visible en dur | `context.l10n.*` |
| `Container` à `height:` fixe autour de texte | contrainte souple — sinon ×1.3 casse |
| `google_fonts` ou police embarquée | police système via `ThemeData` |

## 5. Obligations

- Tout widget partagé est préfixé **`Wk`**, vit dans `lib/app/shared/widgets/`, et possède un test
  widget avant d'être utilisé. Les goldens sont réservés aux composants structurants et aux
  écrans de référence : ils ne doivent pas ralentir chaque petit composant.
- Tout écran est un `StatelessWidget` ou `StatefulWidget`, ne contient **aucune logique métier**,
  et observe des modèles exposés par le package `provider`.
- Toute règle métier — distance, score de classement, éligibilité à noter — vit dans un service
  **Dart pur**, testé unitairement, sans dépendance à Flutter.
- Tout écran couvre explicitement **vide / chargement / peuplé / erreur**. Un écran sans état
  vide n'est pas terminé.
- Toute image passe par le mode léger : compression obligatoire, et substitution par un
  placeholder quand `modeLeger` est actif.
- `analysis_options.yaml` durci : `prefer_single_quotes`, `always_use_package_imports`,
  `require_trailing_commas`, `avoid_print`.

## 6. Catalogue des widgets

Chaque entrée existe **une seule fois**. Un écran ne compose jamais un bouton, une carte ou un
champ à la main. Un écran **Catalogue**, accessible depuis les Réglages, affiche tous les
composants dans tous leurs états — c'est là qu'on valide avant d'écrire le moindre écran métier.

**Structure** — `WkScaffold`, `WkTopBar`, `WkSectionHeader`, `WkBottomNav`, `WkBottomActionBar`.

**Actions** — `WkButton` (primary / secondary / ghost / danger / call / whatsapp, tailles lg et
md, état de chargement, pictogramme), `WkIconButton`, `WkListAction`.

**Saisie** — `WkTextField`, `WkPhoneField`, `WkOtpField`, `WkSelectField` + `WkOptionSheet<T>`,
`WkChipGroup`, `WkSearchBar`, `WkPhotoPicker`.

**Contenu** — `WkBrokerCard`, `WkPropertyCard`, `WkRating` (étoiles + valeur chiffrée),
`WkBadge`, `WkAvatar`, `WkInfoRow`, `WkPriceTag`.

**Vocal** — `WkVoiceButton`, `WkVoiceOverlay`, `WkSpeakButton`, `WkAudioRecorderTile`,
`WkAudioPlayerTile`.

**États** — `WkEmptyState`, `WkErrorState`, `WkSkeleton`.

**Retours** — `WkFieldStatus`, `WkLiveStatus`, `WkConfirmSheet`, `WkToast`.

## 7. Localisation

- Deux langues dès le départ : `app_fr.arb` et `app_wo.arb`, dans `lib/app/l10n/`.
- Aucune chaîne visible n'est écrite dans un widget.
- Chaque clé doit être **énonçable** : les libellés sont ce que la synthèse vocale lira.
- Le français livré n'est pas la chaîne la plus longue de demain : aucune mise en page ne fige une hauteur autour d'un texte.

## 8. Mode démo

Un `AppMode` (`demo` ou `reel`) est persisté dans la même base Isar que les autres réglages et
exposé par un `ChangeNotifierProvider`. Une seule technologie de persistance locale suffit.

- Passage en **démo** : purge d'Isar, chargement de `assets/seed/*.json`, écriture de toutes les
  collections, invalidation des providers de liste. Confirmation obligatoire avant la purge.
- Passage en **réel** : purge d'Isar, base vide, l'onboarding et le parcours normal reprennent.
- En test, le dépôt Isar est remplacé par un dépôt mémoire injecté dans `MultiProvider` ; le
  chargeur de seed reste le même chemin de code qu'en production.

## 9. Dépendances autorisées

On ajoute un package seulement au moment où un écran en a besoin. Le socle retenu est :

| Besoin | Package | Pourquoi |
|:--|:--|:--|
| Navigation | `go_router` | routes déclaratives, redirections et deep links |
| État | `provider` | choix du projet, API Flutter simple et testable |
| Données locales | `isar_community`, `isar_community_flutter_libs`, générateur associé | une base unique pour données, réglages et seed |
| Téléphone + pays | `phone_form_field` | validation, indicatif, drapeaux et sélecteur accessibles ; noms de pays fournis par notre l10n |
| OTP | `pinput` | collage SMS, focus et accessibilité déjà traités |
| Position | `geolocator` | permission et coordonnées |
| Carte | `flutter_map` + `latlong2` | carte indépendante d'un SDK propriétaire, tuiles asset/cache possibles ; vue liste toujours disponible |
| Liens externes | `url_launcher` | appel, SMS et WhatsApp |
| Photos | `image_picker` + `flutter_image_compress` | sélection native et mode léger |
| Vocal simulé/réel | `flutter_tts`, `record`, `just_audio` | lecture, enregistrement et écoute sans lecteur maison |
| Icônes | `lucide_icons_flutter` | vocabulaire cohérent ; aucune icône SVG dessinée à la main |

`speech_to_text` n'entre que lorsqu'un prototype démontre une qualité suffisante sur des voix africaines francophones. En phase
UX, `VoiceService` retourne des commandes déterministes ; l'interface reste identique.

## 10. Tests

- **Unitaires** — Haversine ; score de classement, dont le cas « un seul avis à 5 étoiles » ;
  impossibilité de noter sans `ContactLog` correspondant ; disparition des biens vendus ou loués
  de la recherche ; chargeur de seed ; bascule de mode ; transitions de validation, politique de
  feedback et déduplication des retours sensoriels.
- **Widget** — chaque widget du catalogue dans chacun de ses états ; chaque écran en vide,
  chargement, peuplé et erreur.
- **Golden** — les huit composants structurants, en clair et en sombre.
- **Garde-fou** — `test/widget/accessibility_guard_test.dart` parcourt les écrans et **échoue**
  si : une cible tactile descend sous 56 dp ; un contraste texte/fond passe sous 4.5:1 ; un
  widget interactif n'a pas de `Semantics` ; un texte visible ne provient pas de `l10n`.

## 11. Boucle de validation visuelle

Le code source ne prouve pas qu'un écran mobile fonctionne visuellement. Pour toute modification UI :

1. lancer l'écran avec l'état ciblé et les données déterministes du mode démo ;
2. capturer au minimum un petit Android (360×800) et un iPhone standard (390×844) ;
3. vérifier débordement, clavier, safe areas, action basse, contraste, ordre de lecture et retour ;
4. répéter l'état pertinent à ×1.3 de taille de texte ;
5. comparer aux tokens et au contrat d'écran, puis corriger avant de déclarer terminé.

Les trois premières références à faire approuver sont C01 Explorer, C02 Fiche courtier et B03
Éditeur de bien. Leurs contrats vivent dans `screen-contracts/`. Les goldens approuvés deviennent
la preuve de régression ; ils ne remplacent pas l'inspection sur simulateur lorsque l'interaction,
le clavier, le scroll ou une permission change.

## 12. Feedback interactif

`INTERACTION-FEEDBACK.md` est obligatoire pour chaque écran et overlay.

- Un `InteractionFeedbackService` injecté par Provider traduit les intentions `selection`,
  `stepValid`, `warning`, `error`, `success`, `recordingStarted`, `recordingStopped` et
  `announceStatus` vers `HapticFeedback`, audio et sémantique.
- Le service applique préférences, accessibilité, disponibilité plateforme et déduplication. Les
  widgets ne choisissent jamais une durée de vibration ou un fichier sonore.
- `WkFieldStatus` réserve l'espace de checking/valid/error pour éviter les sauts de layout.
- `WkLiveStatus` annonce résultat, progression et récupération sans toast répété.
- Les retours sont déclenchés par une transition d'état visible, jamais par `build()`.
- Avec TalkBack/VoiceOver, les live regions remplacent le TTS applicatif pour ne pas parler en même
  temps. Avec animations réduites, le nouvel état apparaît immédiatement.
- Sons, vibrations et guidage vocal sont trois préférences indépendantes avec aperçu dans S01.
