# C01 — Client discovery

Statut : **Draft — capture de référence non approuvée**

## Contrat

- Route : `/client/explorer`
- Rôle : client invité ou identifié.
- But : comprendre où l'on cherche, exprimer le besoin et ouvrir un résultat pertinent.
- Entrées : ouverture client, retour d'une fiche, suppression/application de filtres, commande
  vocale, changement de quartier.
- Données : quartier/coordonnées, permission GPS, filtres, courtiers, biens, score, distance,
  disponibilité, mode léger et connectivité future.

## Hiérarchie visible

1. Top bar : marque compacte, quartier actuel et action Écouter.
2. Zone de recherche : champ texte et grand bouton vocal ; le quartier reste modifiable.
3. Filtres actifs : seulement les choix appliqués, avec suppression directe et accès M01.
4. Segments Courtiers/Biens puis Liste/Carte sans perdre l'état.
5. Résultats classés avec distance et confiance avant les détails secondaires.

Le premier viewport doit montrer la recherche et le début d'au moins un résultat. Aucun héros,
carrousel promotionnel ou carte imbriquée n'est autorisé.

## Actions et destinations

| Action | Résultat |
|:--|:--|
| Taper/rechercher | actualise la requête puis conserve le clavier seulement si utile |
| Micro | M06 au premier usage, puis M03 |
| Quartier | M02 |
| Filtres | M01 |
| Courtiers/Biens | remplace la collection, conserve requête et quartier |
| Liste/Carte | remplace la présentation, conserve sélection et filtres |
| Carte courtier | `push('/client/explorer/brokers/:brokerId')` |
| Carte bien | `push('/client/explorer/properties/:id')` |

Retour depuis une fiche restitue segment, filtres, carte/liste et position de scroll. Retour à la
racine laisse Android fermer l'application selon le comportement plateforme.

## États

- Loading : skeletons de même hauteur que les cartes, recherche toujours utilisable.
- Data : résultats et nombre annoncés ; profil épinglé explicitement marqué.
- Empty : élargir rayon, retirer filtres ou changer quartier.
- Error : résultats locaux précédents si disponibles, cause courte et Réessayer.
- GPS accordé : la position réelle est celle depuis laquelle on classe, relue à
  chaque lancement sans jamais redemander.
- GPS inconnu/refusé : quartier manuel dominant ; aucune boucle de permission.

> **Décision (2026-08-14) — le GPS passe devant.** Ce contrat plaçait la saisie
> manuelle en premier et le GPS en second. Le GPS est désormais la position par
> défaut : l'explication M06 est présentée une fois au premier lancement, puis
> la position réelle sert au classement. Ce qui ne change pas, et qui portait
> l'intention d'origine : un refus n'ampute rien. La liste des quartiers reste
> entière, aucune relance n'est faite, et « Pas maintenant » laisse un parcours
> complet. Motif : le classement par distance est la promesse du produit, et il
> partait jusqu'ici d'un point fixe quelle que soit la position réelle.
- Offline/low data : liste active ; tuiles absentes expliquées sans bloquer la recherche.
- Demo : seed couvrant résultats proches, lointains, épinglés et aucun résultat.
- Real local : base vide menant à l'état Empty, pas à une fausse erreur réseau.

## Accessibilité

- Recherche, micro, filtres et chaque résultat ont une sémantique distincte.
- Une carte est une cible unique ; pas de petit bouton Appeler dans la carte.
- La note est annoncée avec son échelle et son volume d'avis.
- Le mode carte garde une liste sémantique accessible ou permet de revenir à Liste immédiatement.
- Aucune langue n'est représentée uniquement par un drapeau.
- Recherche, résultats, filtres et vocal appliquent C01/F0–F7 dans
  `../INTERACTION-FEEDBACK.md`; un rebuild ne répète jamais annonce, son ou haptique.

## Acceptation visuelle et fonctionnelle

- Contact accessible en C01 → C02/C03 → M04.
- Aucun débordement à 320 dp et à ×1.3 de taille de texte.
- Les modes Courtiers/Biens et Liste/Carte ne réinitialisent pas les filtres.
- Refuser le GPS et le micro laisse un parcours complet.
- Captures requises : 360×800 Android et 390×844 iPhone, clair/sombre, data/empty, FR ×1.3.
