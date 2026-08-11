# C02 — Broker detail

Statut : **Draft — capture de référence non approuvée**

## Contrat

- Route : `/client/explorer/brokers/:brokerId`
- Rôle : client invité ou identifié.
- But : décider si ce courtier/agence mérite un contact.
- Entrées : résultat C01, fiche bien C03, historique C04 ou deep link.
- Données : identité, vérification, zone, distance, note/volume, taux de réponse, biens disponibles,
  avis publiés et canaux disponibles.

## Hiérarchie visible

1. Top bar avec Retour et Écouter.
2. Identité : photo/logo, nom, individuel/agence et vérification.
3. Bloc de décision : distance, note/volume et réactivité.
4. Biens disponibles, puis avis récents ; les sections sont un flux, pas des cartes englobantes.
5. Barre Contact fixe respectant clavier, safe area et dernier contenu.

Le contact reste visible sans masquer le contenu. La première ouverture journalise une consultation
dédupliquée ; les rebuilds ne créent pas de nouveaux événements.

## Actions et destinations

| Action | Résultat |
|:--|:--|
| Retour | pop vers la position exacte de C01/C03/C04 |
| Écouter | lit identité, distance, note, réactivité et fourchette de biens |
| Bien | `push('/client/explorer/properties/:id')` |
| Tous les avis | développe la liste dans la même route et place le premier avis révélé à l'écran |
| Contacter | M04 ; si invité G03/G04 puis réouverture M04 |
| Canal externe | écrit ContactLog avant `url_launcher` |

## États

- Loading : identité et décision skeletonisées ; aucune action de contact avec données inconnues.
- Data : biens disponibles seulement, avis modérés publiés seulement.
- Empty biens : conserve la confiance et le contact, explique qu'aucun bien n'est publié.
- Empty avis : « Pas encore d'avis » sans note moyenne inventée.
- Error/not found : message, Réessayer et retour ; aucun profil partiel périmé présenté comme actuel.
- Canal absent : option masquée ou désactivée avec raison accessible.
- Demo : profils vérifié, en attente, sans avis, sans bien et plusieurs canaux.

## Accessibilité et confidentialité

- Vérification, note et disponibilité utilisent pictogramme + mot, jamais couleur seule.
- L'avatar est décoratif si le nom adjacent porte déjà l'identité.
- Le numéro du client n'est jamais affiché sur cette fiche.
- La barre Contact vient après le contenu dans l'ordre sémantique malgré sa position fixe.
- L'ouverture de fiche et la consultation journalisée restent silencieuses ; le CTA et le résultat
  de contact appliquent C02/M04 dans `../INTERACTION-FEEDBACK.md`.

## Acceptation visuelle et fonctionnelle

- Distance et confiance se comprennent avant le premier scroll sur 360×800.
- La barre Contact ne couvre ni le dernier bien, ni le dernier avis, ni le focus TalkBack.
- Retour restaure C01 sans requête supplémentaire ni perte de contexte.
- Un seul événement consultation par session/délai de déduplication documenté.
- Captures requises : 360×800 Android et 390×844 iPhone, clair/sombre, profil complet/sans avis,
  FR ×1.3.
