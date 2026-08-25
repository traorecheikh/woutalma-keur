---
version: 1.0.0
name: Woutalma Keur
description: Annuaire immobilier géolocalisé et vocal-first reliant un client aux courtiers et agences proches de lui.
colors:
  primary: "#0B3B66"
  on-primary: "#FFFFFF"
  primary-container: "#DCE7F2"
  on-primary-container: "#06253F"
  primary-dark: "#7FB3E0"
  on-primary-dark: "#0B0F14"
  background: "#F3F5F7"
  surface: "#FFFFFF"
  surface-variant: "#E9EDF2"
  on-surface: "#0F1419"
  on-surface-variant: "#59616B"
  outline: "#C4CBD4"
  outline-variant: "#DCE1E8"
  dark-background: "#0B0F14"
  dark-surface: "#141A21"
  dark-surface-variant: "#1E262F"
  dark-on-surface: "#E6EAEF"
  dark-on-surface-variant: "#98A1AC"
  dark-outline: "#333C47"
  dark-outline-variant: "#232B34"
  call: "#0F7B3F"
  on-call: "#FFFFFF"
  whatsapp: "#25D366"
  on-whatsapp: "#0F1419"
  error: "#C42B1C"
  on-error: "#FFFFFF"
  error-container: "#FBE1DE"
  on-error-container: "#480B04"
  success: "#0F7B3F"
  success-container: "#E1F2E8"
  on-success-container: "#073B20"
  warning: "#805B10"
  warning-container: "#FFF1CC"
  on-warning-container: "#352300"
  status-available: "#0F7B3F"
  status-reserved: "#0B3B66"
  status-closed: "#59616B"
typography:
  display-lg:
    fontFamily: system
    fontSize: 40px
    fontWeight: 800
    lineHeight: 1.10
    letterSpacing: 0
  display-md:
    fontFamily: system
    fontSize: 32px
    fontWeight: 800
    lineHeight: 1.15
    letterSpacing: 0
  headline-lg:
    fontFamily: system
    fontSize: 26px
    fontWeight: 700
    lineHeight: 1.20
    letterSpacing: 0
  headline-md:
    fontFamily: system
    fontSize: 21px
    fontWeight: 700
    lineHeight: 1.30
  body-lg:
    fontFamily: system
    fontSize: 18px
    fontWeight: 500
    lineHeight: 1.50
  body-md:
    fontFamily: system
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.50
  body-sm:
    fontFamily: system
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.45
  label-lg:
    fontFamily: system
    fontSize: 17px
    fontWeight: 700
    lineHeight: 1.20
  label-md:
    fontFamily: system
    fontSize: 15px
    fontWeight: 700
    lineHeight: 1.20
  label-sm:
    fontFamily: system
    fontSize: 13px
    fontWeight: 700
    lineHeight: 1.20
    letterSpacing: 0
rounded:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  "2xl": 28px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  "2xl": 48px
  "3xl": 64px
  page: 20px
motion:
  instant: 80ms
  fast: 140ms
  standard: 220ms
  slow: 320ms
components:
  page:
    backgroundColor: "{colors.background}"
    paddingHorizontal: "{spacing.page}"
  page-dark:
    backgroundColor: "{colors.dark-background}"
    paddingHorizontal: "{spacing.page}"
  sheet:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.2xl}"
    padding: "{spacing.lg}"
  sheet-dark:
    backgroundColor: "{colors.dark-surface}"
    rounded: "{rounded.2xl}"
    padding: "{spacing.lg}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    minHeight: 64px
    paddingHorizontal: "{spacing.lg}"
  button-primary-dark:
    backgroundColor: "{colors.primary-dark}"
    textColor: "{colors.on-primary-dark}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    minHeight: 64px
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    borderColor: "{colors.outline}"
    borderWidth: 1.5px
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    minHeight: 56px
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.primary}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    minHeight: 56px
  button-danger:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-error}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    minHeight: 56px
  button-call:
    backgroundColor: "{colors.call}"
    textColor: "{colors.on-call}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    minHeight: 56px
  button-whatsapp:
    backgroundColor: "{colors.whatsapp}"
    textColor: "{colors.on-whatsapp}"
    typography: "{typography.label-lg}"
    rounded: "{rounded.md}"
    minHeight: 56px
  voice-button:
    backgroundColor: "{colors.primary}"
    iconColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    height: 96px
    width: 96px
  voice-button-listening:
    backgroundColor: "{colors.error}"
    iconColor: "{colors.on-error}"
    rounded: "{rounded.full}"
    height: 96px
    width: 96px
  voice-overlay:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
  card-broker:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md}"
    minHeight: 96px
  card-broker-dark:
    backgroundColor: "{colors.dark-surface}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md}"
  card-property:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.sm}"
    padding: "0px"
  badge-verified:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.full}"
    paddingHorizontal: "{spacing.md}"
  badge-available:
    backgroundColor: "#E1F2E8"
    textColor: "{colors.status-available}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.full}"
    paddingHorizontal: "{spacing.md}"
  badge-reserved:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.status-reserved}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.full}"
    paddingHorizontal: "{spacing.md}"
  badge-closed:
    backgroundColor: "{colors.surface-variant}"
    textColor: "{colors.status-closed}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.full}"
    paddingHorizontal: "{spacing.md}"
  chip:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface-variant}"
    borderColor: "{colors.outline}"
    borderWidth: 1.5px
    typography: "{typography.label-md}"
    rounded: "{rounded.full}"
    height: 56px
    paddingHorizontal: "{spacing.md}"
  chip-selected:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
    borderColor: "{colors.primary}"
    borderWidth: 1.5px
    typography: "{typography.label-md}"
    rounded: "{rounded.full}"
    height: 56px
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    borderColor: "{colors.outline}"
    borderWidth: 1.5px
    rounded: "{rounded.md}"
    minHeight: 64px
    typography: "{typography.body-lg}"
  input-focused:
    borderColor: "{colors.primary}"
    borderWidth: 2px
    rounded: "{rounded.md}"
  input-error:
    borderColor: "{colors.error}"
    borderWidth: 2px
    rounded: "{rounded.md}"
  input-valid:
    borderColor: "{colors.success}"
    borderWidth: 2px
    rounded: "{rounded.md}"
  input-warning:
    borderColor: "{colors.warning}"
    borderWidth: 2px
    rounded: "{rounded.md}"
  input-dark:
    backgroundColor: "{colors.dark-surface-variant}"
    textColor: "{colors.dark-on-surface}"
    borderColor: "{colors.dark-outline}"
    borderWidth: 1.5px
    rounded: "{rounded.md}"
    minHeight: 64px
  search-bar:
    backgroundColor: "{colors.surface}"
    borderColor: "{colors.outline}"
    borderWidth: 1.5px
    rounded: "{rounded.full}"
    minHeight: 64px
    typography: "{typography.body-lg}"
  top-bar:
    backgroundColor: "{colors.background}"
    textColor: "{colors.on-surface}"
    typography: "{typography.headline-md}"
    height: 64px
  nav-bar:
    backgroundColor: "{colors.surface}"
    borderColor: "{colors.outline-variant}"
    borderWidth: 1px
    height: 72px
  nav-item-active:
    textColor: "{colors.primary}"
    iconColor: "{colors.primary}"
    typography: "{typography.label-sm}"
  nav-item-inactive:
    textColor: "{colors.on-surface-variant}"
    iconColor: "{colors.on-surface-variant}"
    typography: "{typography.label-sm}"
  rating-star:
    color: "{colors.on-surface}"
    emptyColor: "{colors.outline}"
  rating-value:
    textColor: "{colors.on-surface}"
    typography: "{typography.headline-lg}"
  divider:
    backgroundColor: "{colors.outline-variant}"
    height: 1px
  toast:
    backgroundColor: "{colors.on-surface}"
    textColor: "{colors.surface}"
    rounded: "{rounded.lg}"
    padding: "{spacing.md}"
---

## Overview

**Woutalma Keur — « Un écran, une décision. »**

L'utilisatrice de référence n'est pas un designer, ni une urbaine connectée. C'est une femme de
35 ans **qui ne lit pas bien**, sur un téléphone d'entrée de gamme, en plein soleil, sur un
réseau 3G capricieux. Tout ce document découle de cette contrainte unique.

Le registre est celui des applications de service à très large diffusion en Afrique de l'Ouest :
aplat franc, énorme respiration, trois à quatre éléments par écran, gros boutons, zéro chrome
décoratif. Ce n'est pas du minimalisme esthétique — c'est une réduction de charge cognitive.

Trois lois priment sur toutes les autres :

1. **Un écran, une décision.** S'il faut hésiter sur ce que l'utilisateur doit y faire, l'écran
   est raté.
2. **Rien n'existe uniquement en texte.** Chaque information porte un pictogramme.
3. **Rien n'existe uniquement en couleur.** Chaque état porte un pictogramme **et** un mot.

Répartition **60-30-10** : 60 % de fond gris `#F3F5F7`, 30 % de surfaces blanches, 10 % de
marine. Au-delà de 10 %, le bouton principal cesse d'être lu comme *le* bouton.

## Colors

### Pourquoi le marine, et pourquoi rien d'autre

La contrainte décisive n'est pas esthétique, elle est fonctionnelle : **dans cette catégorie, le
vert et le rouge ne sont pas disponibles.** Ils appartiennent aux boutons Appeler et WhatsApp,
qui sont l'action centrale du produit. Property Finder, Bayut et Zillow font tous ce constat :
leur barre de contact est rouge et verte, et leur marque vit ailleurs.

S'y ajoutent trois exclusions locales : le cyan clair appartient à Wave, l'orange à Orange Money,
le rouge à Free. Sur un téléphone d'Afrique de l'Ouest, ces trois applications sont installées ;
reprendre leur teinte crée une confusion d'appartenance.

Reste le marine — qui se trouve être la convention de l'immobilier mondial (Nawy, Zillow, Bayut).
Ici, « attendu » est un atout : le produit vend de la confiance à des gens qui n'en ont pas.

- **`#0B3B66` Marine** — la seule couleur d'action. Boutons primaires, onglet actif, bordure de
  champ focalisé, chip sélectionné. **11.5:1 sur blanc**, largement au-delà de l'AAA. Aucun
  rapport avec le cyan clair de Wave.
- **`#DCE7F2` Marine pâle** — le seul endroit où la marque occupe une surface : fond de chip
  sélectionné et de badge. Texte `#06253F` dessus, **12.5:1**.
- **`#7FB3E0` Marine clair** — variante mode sombre uniquement, **8.6:1** sur `#0B0F14`. En
  sombre, le texte du bouton primaire passe en **encre**, pas en blanc.

### Neutres

Ils occupent 90 % de l'écran. Jamais de noir pur `#000000` : fatigue oculaire et halo sur les
dalles bas de gamme.

| Jeton | Valeur | Rôle | Contraste |
|:--|:--|:--|:--|
| `background` | `#F3F5F7` | fond de toute page | — |
| `surface` | `#FFFFFF` | cartes, sheets — c'est de là que vient la profondeur | — |
| `surface-variant` | `#E9EDF2` | surfaces secondaires | — |
| `on-surface` | `#0F1419` | texte principal | 18.5:1 sur blanc, 16.9:1 sur la page |
| `on-surface-variant` | `#59616B` | texte secondaire, placeholders | 6.3:1 sur blanc, 5.7:1 sur la page |
| `outline` | `#C4CBD4` | bordure d'élément interactif, 1.5 px pour rester visible au soleil | — |
| `outline-variant` | `#DCE1E8` | séparateurs | — |

### Mode sombre

Le sombre n'est pas l'inverse du clair : c'est une palette distincte. La hiérarchie vient des
**paliers de surface** — `#0B0F14` → `#141A21` → `#1E262F` — jamais des ombres. Le texte
`#E6EAEF` donne **15.9:1** sur le fond. Seul le primaire change de valeur.

### Couleurs sémantiques

Elles ne servent **jamais** de fond de section ni d'ornement.

| Jeton | Valeur | Usage | Contraste |
|:--|:--|:--|:--|
| `call` | `#0F7B3F` | bouton Appeler, texte blanc | 5.3:1 |
| `whatsapp` | `#25D366` | bouton WhatsApp, texte encre — couleur de marque, pour la reconnaissance avant lecture | 9.4:1 |
| `error` | `#C42B1C` | erreurs, actions destructrices, texte blanc | 5.7:1 |

### Notation : pas d'étoiles dorées

Contrairement à l'usage, les étoiles ne sont **pas** dorées. Elles sont en encre `#0F1419`, les
vides en `outline`. L'or ajouterait une quatrième teinte pour une information que le chiffre
porte mieux : **la note est affichée en gros, en `headline-lg`, à côté des étoiles**. Un
utilisateur qui ne lit pas compte les étoiles pleines ; un utilisateur pressé lit le chiffre.
Aucun des deux n'a besoin d'or.

### Statuts de bien

Trois statuts, aucune teinte nouvelle, chacun avec pictogramme et mot :

| Statut | Couleur | Support obligatoire |
|:--|:--|:--|
| Disponible | `#0F7B3F` sur `#E1F2E8` | pictogramme + le mot « Disponible » |
| Réservé | `#0B3B66` sur `#DCE7F2` | pictogramme + le mot « Réservé » |
| Vendu / loué | `#59616B` sur `#E9EDF2` | pictogramme + le mot |

Une partie des utilisateurs ne distingue pas les teintes, une autre ne lit pas du tout. Les deux
doivent réussir le parcours : c'est pourquoi la couleur ne porte jamais seule une information.

## Typography

**La police système uniquement** : Roboto sur Android et San Francisco sur iOS. Elle est déjà
présente, optimisée pour la plateforme, gratuite en poids applicatif et disponible hors ligne.
L'application ne charge ni police distante ni fichier de police embarqué.

Aucune échelle n'est inventée : les neuf jetons se branchent sur les emplacements standards du
thème de texte de la plateforme.

| Jeton | Taille | Graisse | Usage |
|:--|:--|:--|:--|
| `display-lg` | 40 | 800 | accueil vocal, onboarding |
| `display-md` | 32 | 800 | titre de section héros |
| `headline-lg` | 26 | 700 | nom de courtier, titre de page, **valeur de note** |
| `headline-md` | 21 | 700 | titre de carte, en-tête de sheet |
| `body-lg` | 18 | 500 | **corps de texte par défaut**, champs de saisie |
| `body-md` | 16 | 500 | texte secondaire dense |
| `body-sm` | 14 | 500 | métadonnées |
| `label-lg` | 17 | 700 | libellé de bouton |
| `label-md` | 15 | 700 | chip, onglet |
| `label-sm` | 13 | 700 | badge |

**Planchers.** Rien sous 13. Un prix, une distance, une note, un nom de courtier ne descendent
jamais sous `body-md`. Le corps de texte par défaut est **18**, pas 16 : la cible lit mal, il
faut de la matière.

Le réglage de taille de texte multiplie l'échelle par 1.0, 1.15 ou 1.3. Chaque écran doit
survivre à ×1.3 sans troncature — donc **aucune hauteur figée autour d'un conteneur de texte**.

## Layout

Grille de 8 px. Marge de page de 20 px de chaque côté, sur tous les écrans.

- **Trois à quatre éléments maximum** au-dessus de la ligne de flottaison. À six, il faut
  découper l'écran ou déplacer vers un sheet.
- **Espace entre blocs : 24 px** au minimum ; **32 px** entre sections. La respiration n'est pas
  un luxe : c'est ce qui rend une cible atteignable au pouce, en marchant.
- **Padding interne d'un composant interactif : 16 px.**
- Zone sûre système toujours respectée. L'action principale est ancrée en bas, pleine largeur,
  jamais perdue dans le défilement.
- **Une liste défile ; une page de décision ne défile pas.** Contact, notation et confirmation
  tiennent dans un écran à taille de texte normale.

## Elevation & Depth

La profondeur vient du **contraste tonal** : carte blanche sur fond gris. C'est gratuit en rendu
et lisible au soleil, là où une ombre disparaît.

Les ombres sont réservées aux éléments flottants, et ne sont jamais colorées :

- `sm` — `0 1px 2px rgba(0,0,0,0.06)` : barre de navigation basse.
- `md` — `0 4px 16px rgba(0,0,0,0.10)` : bottom sheets, overlay vocal.
- `lg` — `0 12px 32px rgba(0,0,0,0.16)` : modales bloquantes, rares.

**En mode sombre, aucune ombre** : la hiérarchie passe par les paliers de surface.

## Shapes

| Jeton | Valeur | Usage |
|:--|:--|:--|
| `xs` | 4 | détail interne |
| `sm` | 8 | vignette photo |
| `md` | 12 | champ de saisie |
| `lg` | 16 | petite carte |
| `xl` | 20 | carte courtier, carte bien |
| `2xl` | 28 | bottom sheet, modale |
| `full` | 9999 | boutons, chips, badges, avatars, bouton vocal |

Les boutons d'action utilisent un rayon 12. Les pilules sont réservées aux chips, badges et
sélecteurs compacts ; les cercles aux avatars, icônes seules et au bouton vocal.

## Components

**Bouton primaire** — rectangle arrondi marine, texte blanc, hauteur minimale 64. Un seul par écran. L'état de
chargement remplace le libellé par un indicateur sans changer la largeur.

**Bouton Appeler et bouton WhatsApp** — vert `#0F7B3F` texte blanc, et vert de marque `#25D366`
texte encre. Ce sont les deux seules dérogations à la règle « une seule couleur d'action » : ce
sont des marques externes que l'utilisateur reconnaît avant même de lire.

**Bouton vocal** — cercle de 96, le plus gros élément interactif de l'écran d'accueil, placé en
bas à droite dans la zone du pouce. Trois états distinguables sans texte : repos marine, écoute
rouge avec onde animée, traitement marine avec points. Le passage en écoute est confirmé par un
retour haptique — il ne faut pas avoir à regarder.

**Carte courtier** — surface blanche, rayon 8, hauteur minimale 96. Ordre de lecture : avatar,
nom en `headline-md`, distance en `body-md`, note (chiffre en `headline-lg` + étoiles encre),
badges, bouton d'appel à droite. **Distance et note sont les deux informations que l'œil doit
attraper en premier** — elles sont typographiquement plus fortes que le reste.

**Carte bien** — photo 16:9 arrondie en haut, badge de statut en superposition, puis prix en
`headline-md`, type et surface en `body-md`, distance en `body-sm`.

**Étoiles et note** — étoiles pleines en encre, vides en `outline`, cible de 56 par étoile en
saisie. Le chiffre est toujours affiché.

**Badges** — vérifié (marine pâle), disponible (vert pâle), réservé (marine pâle), vendu/loué
(gris). Chacun porte un pictogramme et un mot.

**Champ de saisie** — surface blanche, bordure 1.5, rayon 12, hauteur minimale 64, texte `body-lg`. Focus :
bordure marine 2 px. Une valeur stable et valide affiche une coche verte et une aide positive ;
une erreur affiche bordure rouge **plus** message correctif **plus** pictogramme. La hauteur utile
est réservée pour éviter qu'un message déplace le champ sous le doigt.

**Sélecteur d'option** — un bottom sheet pleine largeur, une option par ligne de 64, pictogramme
+ libellé + coche sur la sélection. Il remplace tout menu déroulant : un menu déroulant natif est
illisible au soleil, minuscule au doigt, et impossible à énoncer proprement à voix haute.

**Feuille de confirmation** — remplace les boîtes de dialogue. Titre, corps, action primaire
pleine largeur, annulation en dessous. Une action destructrice nomme explicitement ce qu'elle
détruit.

**État vide** — grand pictogramme, une phrase courte, un bouton d'action, et une invite vocale.
Un écran vide est le moment où un non-lecteur décroche : c'est là que la voix compte le plus.

**Barre de navigation basse** — surface blanche, hauteur 72, pictogramme et libellé toujours
visibles, actif en marine. Les onglets changent selon le rôle, client ou courtier.

**Feedback et mouvement** — toute action reçoit immédiatement un état pressé tonal. Sélections et
validations apparaissent en 140 ms ; remplacement de contenu et progression en 220 ms ; une
confirmation finale peut durer 320 ms. Aucun champ ne tremble, aucun bouton ne pulse et aucune
animation ne change la taille stable d'un contrôle. Si la plateforme réduit les animations, les
états deviennent immédiats. Les recettes visuelles, haptiques, sonores et parlées sont définies dans
`INTERACTION-FEEDBACK.md`.

## Do's and Don'ts

**Do** garder le marine sous 10 % de la surface de l'écran.
**Don't** teinter un fond de section en marine : le bouton primaire y perdrait son statut.

**Do** laisser le vert et le rouge aux seuls boutons Appeler, WhatsApp et aux erreurs.
**Don't** les utiliser pour décorer quoi que ce soit — leur rareté est ce qui les rend lisibles.

**Do** afficher la note en chiffres, en gros, à côté des étoiles.
**Don't** dorer les étoiles ni compter sur la couleur seule pour transmettre une note.

**Do** ancrer l'action principale en bas, pleine largeur, dans la zone du pouce.
**Don't** la placer en haut à droite : inatteignable à une main sur un grand écran.

**Do** écrire des libellés concrets : « Appeler », « Écouter », « Ajouter un bien ».
**Don't** écrire « Valider », « Confirmer », « Soumettre » — vides de sens à l'oreille.

**Do** faire tenir une page de décision dans un seul écran.
**Don't** faire défiler un écran de contact ou de notation : ce qui sort du cadre n'existe pas.

**Do** doubler chaque statut d'un pictogramme et d'un mot.
**Don't** livrer une pastille de couleur nue.

**Do** vérifier chaque écran à ×1.3 de taille de texte et en mode sombre.
**Don't** figer une hauteur autour d'un texte : le français d'aujourd'hui n'est pas la chaîne la plus longue de demain.

## Journal des décisions

| Date | Décision | Raison |
|---|---|---|
| 2026-08-25 | **Système d'interface remplacé** : `forui` + icônes Lucide, police embarquée Plus Jakarta Sans, primitives `App*` dans `lib/app/ui/ui.dart`, fond gris clair `#F6F7F9`, cartes blanches à rayon 24 avec une ombre douce, bouton principal en encre, marine `#0B3B66` réservé à l'accent (onglet actif, liens, sélection). Les composants `Wk*`, le catalogue S02 et le mode démonstration sont retirés. | L'interface précédente lisait comme un gabarit Material et l'accueil montrait une liste de résultats. Référence assumée : Airbnb, même système que Gnawalma. Les jetons de l'en-tête YAML ci-dessus restent la source des couleurs sémantiques (appel, WhatsApp, statuts) ; la typographie système est abandonnée. |
| 2026-08-25 | Accueil C01 = recherche, catégories, rangées horizontales ; résultats et filtres dans M14 ; « Mes biens » en cartes avec glissement latéral et appui long pour les actions. | Un écran de découverte ne montre pas une liste de résultats ; les actions d'un bien doivent être atteignables sans ouvrir la fiche. |
