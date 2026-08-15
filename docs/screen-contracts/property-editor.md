# B03 — Broker property editor

Statut : **Draft — capture de référence non approuvée**

## Contrat

- Routes : `/broker/properties/new` et `/broker/properties/:id/edit`
- Rôle : courtier/agence identifié ; publication conditionnée par les règles de vérification produit.
- But : publier un bien complet en répondant à des questions, sans rédiger.
- Entrées : B01, B02 ou B04.
- Données : type, transaction, quartier, titre, prix, surface, pièces, description, photos, statut,
  limites média et permission photo/caméra.

## Structure du flow

Une route, trois étapes. `WkStepHeader` annonce « Étape n sur 3 ».

1. **Le bien et son quartier** — transaction (louer/vendre), type de bien, quartier.
2. **Infos essentielles** — titre, prix, surface, pièces, description.
3. **Photos et publication** — photos, statut (modification seulement), effet du statut.

Suivant reste l'action dominante ; à la dernière étape il devient Enregistrer. Retour revient à
l'étape précédente ; à la première étape il quitte l'écran.

**Le texte est composé, pas demandé.** Tout ce qu'un titre et une description utiles contiennent —
type, transaction, quartier, surface, pièces, prix — a déjà été choisi champ par champ. L'écran
écrit donc les deux à partir de ces choix, plutôt que d'ouvrir un clavier à quelqu'un qui lit mal :

- Le passage de l'étape 1 à l'étape 2 écrit le **titre** — « Appartement 3 pièces à Mermoz ».
- La **description** se compose de la même manière, à partir des mêmes données
  (`lib/app/domain/property_description.dart`) : rien qui ne soit dans les données saisies, aucun
  agrément inventé.

Les deux restent modifiables. Une mention dit que le texte a été proposé, et disparaît à la
première frappe. Rien n'est écrasé : sans quartier choisi, ou si un texte existe déjà, l'écran
n'écrit pas. Une description déjà enregistrée est reconnue comme composée ou non, pour ne jamais
remplacer une phrase que le courtier a écrite lui-même.

## Champs, et ce qu'ils acceptent

| Champ | Forme | Règle |
|:--|:--|:--|
| Transaction | choix, 2 options | requis, défaut *Louer* |
| Type de bien | choix, 5 options | requis, défaut *Appartement* |
| Quartier | choix dans la liste produit | requis ; porte son propre point, il n'y a pas d'autre saisie de position |
| Titre | texte libre | requis, non vide ; proposé par l'écran, corrigeable |
| Prix | clavier numérique, chiffres seuls | requis, entier CFA strictement positif |
| Surface | choix par paliers | facultatif ; paliers selon le type de bien |
| Pièces | choix, 1 à 6 | facultatif ; **absent pour un terrain** |
| Description | texte composé | facultatif, corrigeable ; jamais écrasée si le courtier l'a écrite |
| Photos | galerie/appareil | facultatif, 3 au plus |
| Statut | choix, 3 options | **modification seulement** |

Paliers de surface : chambre et studio de trois en trois jusqu'à 30 m² ; appartement et maison de
dix en dix jusqu'à 100 m² puis de cinquante en cinquante jusqu'à 300 ; terrain aux calibres de lot
courants (150, 200, 250, 300) puis en centaines jusqu'à 2000. Une valeur déjà enregistrée hors
palier est ajoutée à sa place plutôt qu'écrasée — rouvrir une annonce pour corriger son prix ne
change pas sa surface. Même règle pour un quartier absent de la liste et pour un nombre de pièces
supérieur à six.

Changer le type pour *Terrain* efface le nombre de pièces : sans cela un bien gardait « 3 pièces »
invisible dans le formulaire et visible dans l'annonce publiée.

## Actions et destinations

| Action | Résultat |
|:--|:--|
| Choisir une option | sélection typée, sans dialogue Material |
| Ajouter photo | M11 puis sélection/capture, compression et validation |
| Suivant/Retour | change d'étape sans perdre la saisie en cours |
| Enregistrer | validation globale puis retour à B02, qui se recharge |
| Retour à l'étape 1 | quitte l'écran |

## Validation et états

- Rien n'est évalué avant la soumission : le bouton n'est jamais grisé, c'est en appuyant qu'on
  apprend ce qui manque.
- La soumission renvoie à la **première** étape fautive dans l'ordre traversé, et annonce une seule
  erreur pour la soumission entière, pas une par champ vide.
- Un sélecteur n'a pas de ligne d'aide : un quartier manquant affiche son propre message sous le
  champ, sinon l'étape 1 se rouvrait sans rien montrer.
- Saisie refusée et enregistrement échoué sont deux états distincts. Un échec réseau affiche la
  cause en toast et **ne** renvoie **pas** au formulaire : renvoyer à l'étape 2 en annonçant
  « corrigez d'abord » faisait relire un formulaire sans faute.
- Prix : chiffres seuls à la saisie, stocké en entier, jamais une chaîne formatée.
- Photos : limite serveur (3) annoncée **avant** de choisir, pas après un refus ; compression
  échouée n'efface pas les autres photos.
- Le formulaire ne survit pas à la fermeture de l'écran : il n'y a pas de brouillon persistant.
- Édition concurrente n'existe pas ; ne pas créer de résolution de conflit.

## Limites côté serveur

Le serveur applique les mêmes bornes, parce que le formulaire n'est pas la seule porte d'entrée
(`backend/src/properties/dto/write-property.dto.ts`) :

- Titre et quartier sont **normalisés** — espaces de bord retirés, suites d'espaces réduites à un
  seul — et refusés vides. Les accents et les écritures non latines sont conservés tels quels.
- La description est rognée aux extrémités seulement : ses retours à la ligne sont voulus.
- Prix : de 1 à 10 000 000 000 FCFA.
- Surface : de 1 à 1 000 000 m². « Non précisé » voyage en `null`, jamais en 0.
- Pièces : de 0 à 50. Zéro est accepté et reste la réponse honnête pour un terrain.
- Le serveur **n'impose pas** la liste des quartiers : elle est incomplète par construction, et un
  courtier qui couvre un quartier qu'elle ne nomme pas encore a raison.

## Accessibilité et performance

- Chaque champ a un label persistant ; placeholder seul interdit.
- Clavier numérique pour le prix sans bloquer collage ou correction. Surface et pièces n'ouvrent
  plus de clavier du tout.
- Focus suivant suit l'ordre visible ; le bouton fixe ne masque pas le champ actif.
- Miniatures décodées à la taille affichée ; aucune photo pleine résolution dans une liste.
- Animations d'étapes courtes et désactivables par la préférence de mouvement plateforme.
- Validation de champ, étape prête, photo, erreur et publication appliquent B03/M11 dans
  `../INTERACTION-FEEDBACK.md` ; aucune vibration n'est déclenchée par chaque caractère valide.

## Acceptation visuelle et fonctionnelle

- Un terrain se publie sans jamais voir la question « combien de pièces ».
- Un bien se publie sans avoir tapé autre chose que le prix : titre proposé, quartier, surface et
  pièces choisis, description laissée vide.
- Publication impossible avec champs requis invalides ; la première étape fautive devient visible.
- Un échec réseau affiche un message et laisse la saisie en place.
- Un bien publié apparaît dans C01 et C02 ; vendu/loué en disparaît sans être supprimé de B02.
- Aucun dropdown, dialogue, champ ou carte Material non stylé n'apparaît.
- Captures requises : 360×800 Android et 390×844 iPhone, étapes 1 et 3, erreur, clavier visible,
  FR ×1.3.

## Conflits résolus

**Le formulaire demandait à taper, et demandait deux fois.** — 15 août 2026

Le responsable produit a testé la publication sur téléphone. Le formulaire ouvrait le clavier pour
le quartier, pour la surface, pour le nombre de pièces et pour un titre qui ne faisait que répéter
les trois réponses précédentes, à des utilisateurs peu lettrés tapant sur un clavier de téléphone.
Il posait aussi une question de statut à un bien qui n'existait pas encore, et une étape de position
qui ne demandait rien de plus que le quartier.

Ce contrat portait la version antérieure — quatre étapes, quartier et surface en texte libre, statut
à la création, étape carte, brouillon local, dictée par champ. Il perd contre l'arbitrage produit et
est réécrit ici :

| Avant | Maintenant | Pourquoi |
|:--|:--|:--|
| Quartier en texte libre | choix dans la liste produit | dix à vingt frappes, et une orthographe par courtier — « Medina », « Médina », « médina » — que la recherche client ne rapprochait pas |
| Surface et pièces au clavier | paliers | personne n'annonce une surface au mètre près |
| Étape « position » séparée | quartier porteur de son point | l'étape ne demandait rien que le quartier ne donne déjà |
| Titre et description à rédiger | composés, corrigeables | c'était mot pour mot ce à quoi les champs précédents venaient de répondre ; le champ restait vide ou recevait trois mots |
| Statut à la création | modification seulement | « Vendu » était proposé pour un bien qui n'existait pas ; B02 porte déjà « Changer le statut » |
| Quatre étapes | trois | conséquence des lignes ci-dessus |

**Brouillon local et dictée retirés.** Le brouillon appartenait à la version hors ligne : les
données vivent maintenant sur le serveur, et rien ne persiste un formulaire à moitié rempli. La
dictée a été retirée du produit avec la recherche vocale. Les deux sortent du contrat plutôt que d'y
rester comme des promesses non tenues ; les rétablir demandera une décision, pas un simple ajout.

Répercuté dans `../UX-FLOWS.md` (registre d'écrans, ligne B03), qui décrivait les quatre étapes.

**État d'implémentation au 15 août 2026.** Tout ce contrat est en place à l'écran sauf la
composition de la **description** : `lib/app/domain/property_description.dart` est écrit mais n'est
pas encore appelé par B03, où le champ reste vide à l'ouverture. Le contrat porte la cible, pas
l'état du jour ; la recette (`../QA-PASS.md`, étape 18) dit l'inverse parce qu'elle décrit un build.

