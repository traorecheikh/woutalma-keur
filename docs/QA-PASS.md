# Passe de test — parcours visiteur

Build Android du 15 août 2026. À jour du passage au serveur distant.

Ce document s'adresse à quelqu'un qui n'a pas travaillé sur l'application. Il
couvre **uniquement** le parcours qu'un visiteur non connecté peut terminer.
Tout ce qui se trouve après l'écran de connexion est sciemment inachevé et
listé en fin de page, pour ne pas y perdre une après-midi.

## À lire avant de commencer

Dans ce build, ce qui échoue échoue **en silence**. Un bouton se met à tourner,
reste à tourner, et cesse de répondre. Pas de texte rouge, pas de fenêtre
d'erreur.

Donc « le bouton tourne indéfiniment et je ne peux plus le toucher » est un
signalement juste et utile : notez lequel, et ce que vous veniez de faire.
Ce n'est jamais une fausse manipulation de votre part.

## Avant la première ouverture

| | |
|:--|:--|
| **Installation** | Désinstaller toute version antérieure. Une installation neuve compte : certaines étapes ne se produisent qu'au tout premier lancement. |
| **Réseau** | Wi-Fi ou données mobiles réelles. L'application interroge un serveur à chaque écran. |
| **Premier chargement lent** | Le serveur s'endort quand personne ne l'utilise et met environ **50 secondes** à se réveiller. Ouvrir, attendre, et seulement ensuite commencer à mesurer quoi que ce soit. |
| **Langue** | Français uniquement. Tout texte en anglais est à signaler. |

---

## Le premier lancement, étape par étape

À faire dans l'ordre sur une application fraîchement installée. Les étapes 1 et
2 ne surviennent qu'une fois par installation : pour les rejouer, désinstaller
puis réinstaller.

### 1. Ouvrir l'application — *Explorer* — devrait marcher

**Faire** — Toucher l'icône. Ne rien toucher d'autre, observer une minute.

**Attendu**

- Un écran de liste titré **Près de vous** apparaît presque immédiatement, avec
  des blocs gris à la place des résultats.
- Si le serveur dormait, un bandeau gris annonce
  « Le service se réveille, quelques secondes… ».
- En moins d'une minute, les blocs gris deviennent **6 résultats** et une liste
  de courtiers.

**Pas un bug** — L'attente elle-même. Et pendant cette attente, il se peut que
« Ça n'a pas marché » s'affiche avec un bouton **Réessayer** alors même que le
bandeau au-dessus annonce que le service se réveille. Les deux se contredisent,
c'est déjà connu. Réessayer répare.

### 2. La question de la position — premier lancement seulement — devrait marcher

**Faire** — Un panneau monte depuis le bas : « Trouver ce qui est près de vous ».
Le lire, puis toucher **Continuer**.

**Attendu**

- Notre explication vient **d'abord**. La demande d'autorisation d'Android
  arrive **après** Continuer, jamais avant.
- Android propose **Précise** et **Approximative**. Les deux conviennent.
- Choisir « Lorsque l'application est utilisée ». Les distances de la liste
  doivent se recalculer depuis l'endroit où vous êtes réellement.

**Pas un bug** — La question n'est posée qu'une seule fois, définitivement. Si
vous touchez **Pas maintenant**, l'application ne doit plus jamais insister :
c'est voulu. Pour donner sa position plus tard :
**Quartier → Utiliser ma position**. À signaler seulement si le panneau
revient de lui-même.

### 3. Refuser, et vérifier qu'on ne perd rien — *Explorer* — devrait marcher

**Faire** — Sur une seconde installation neuve, toucher **Pas maintenant**.

**Attendu** — La liste complète des 6 courtiers, distances mesurées depuis le
centre de Dakar. Rien de grisé, rien de manquant, aucune relance. Refuser ne
doit coûter que de la précision.

### 4. Rechercher et filtrer — *Explorer* — partiellement cassé

**Faire** — Toucher la barre de recherche, taper `mermoz`, puis `sacre` (sans
accent), puis `appart`. Basculer entre **Courtiers** et **Biens**. Puis ouvrir
**Filtres** et poser un prix et un type.

**Attendu**

- Taper sans accent trouve quand même les noms accentués : `sacre` doit trouver
  **Sacré-Cœur**.
- Basculer Courtiers/Biens conserve ce qui a été tapé.
- Les filtres posés apparaissent en pastilles retirables sur la liste.

**Déjà connu** — Le panneau **Filtres** peut rester bloqué sur « Un instant… »
sur son bouton de validation, sans jamais afficher de décompte. Cela se produit
quand le serveur est encore froid. Déjà consigné, ne pas re-signaler.

### 5. Ouvrir un courtier — *Fiche courtier* — devrait marcher

**Faire** — Toucher **Moussa Ndiaye**. Lire toute la fiche. Revenir, puis ouvrir
**Fatou Sarr**.

**Attendu**

- Note, distance, taux de réponse, zones couvertes, biens proposés.
- **Fatou Sarr n'a pas de WhatsApp.** Son panneau de contact ne doit proposer
  que *Appeler* et *Envoyer un SMS* : le bouton WhatsApp doit être **absent**,
  pas grisé.
- Revenir en arrière restitue la même position dans la liste.

**Pas un bug** — Certaines fiches affichent *Réservé* ou *Retiré* sur un bien.
C'est une vraie donnée, pas un défaut d'affichage.

### 6. Essayer de contacter — *Contacter* — cassé, connu : s'arrêter là

**Faire** — Toucher **Contacter**, puis **Appeler**. Une seule fois, pour l'avoir
vu, puis passer à la suite.

**Ce qui se passe aujourd'hui** — Le panneau se ferme, le téléphone ne
s'ouvre jamais, et le bouton **Contacter** tourne indéfiniment puis cesse de
répondre. Sortir de la fiche et y revenir est le seul moyen de récupérer.

**Ne pas signaler** — C'est le premier défaut de la liste et la cause est
comprise : contacter exige d'être connecté, et la connexion ne fonctionne pas
encore. Toutes les voies — appel, SMS, WhatsApp, depuis un courtier ou depuis
un bien — échouent de la même façon. Une ligne dans vos notes suffit.

### 7. Vue carte — *Carte* — devrait marcher

**Faire** — Toucher **Carte** en haut à droite des résultats. Déplacer, zoomer,
toucher une épingle. Puis activer le mode avion et rouvrir la carte.

**Attendu** — En ligne : une vraie carte, épingles cliquables menant à un
courtier. **Hors ligne, la carte doit rester lisible aux endroits déjà
regardés** : les images de carte sont conservées sur le téléphone. Une zone
jamais ouverte reste vide, avec une légende qui l'explique.

**À signaler** — Si une zone que vous venez de regarder en ligne redevient vide
en mode avion, c'est un défaut.

### 8. Perdre le réseau en cours d'usage — *Explorer* — devrait marcher

**Faire** — Naviguer normalement, puis activer le mode avion et rafraîchir la
liste.

**Attendu** — Les courtiers déjà chargés restent affichés, avec un bandeau gris
« Hors ligne. Informations enregistrées… » et l'ancienneté approximative. Sur un
téléphone qui n'a **jamais** rien chargé : un simple « Pas de connexion » avec
un bouton Réessayer. Jamais un écran blanc, jamais des courtiers inventés.

**À signaler** — Ce bandeau doit apparaître sur **tous** les écrans, pas
seulement sur la liste. Ouvrez une fiche courtier en mode avion : si elle
affiche des informations anciennes **sans** le bandeau, c'est un défaut.

**Pas un bug** — Hors ligne, les notes disparaissent des cartes et les
courtiers affichent « Pas encore d'avis ». Les avis ne font pas partie de ce
qui est enregistré pour la recherche : hors réseau l'application ne les connaît
pas, et préfère ne rien afficher plutôt qu'un chiffre périmé. Distances,
classement et noms restent justes.

### 9. Grands caractères et petits écrans — partout — devrait marcher

**Faire** — Dans les réglages Android, passer la taille de police au maximum.
Rouvrir l'application et refaire les étapes 1 à 7.

**Attendu** — Rien de coupé, aucun mot terminé par « … », chaque bouton
entièrement visible et atteignable. C'est une exigence produit réelle : tout ce
qui est tronqué ici **est à signaler**, capture d'écran à l'appui.

---

## À ne pas tester pour l'instant

Inachevé, et non cassé par accident. Les signalements sur ces points seront
fermés en doublon.

| Sujet | État |
|:--|:--|
| **La connexion** | Les deux boutons — Google et le code par SMS — tournent indéfiniment sans jamais signaler d'erreur. Aucun moyen de se connecter ne fonctionne sur ce build. |
| **Tout ce qui exige un compte** | Contacter un courtier, l'onglet *Contacts* et laisser un avis exigent la connexion : les trois sont donc hors d'atteinte. |
| **Le côté courtier** | Passer son rôle à *Courtier* dans les réglages affiche quatre écrans identiques « Espace courtier — Se connecter », sans retour possible vers les réglages. Fermer et rouvrir l'application pour récupérer. Rien derrière cette porte n'est testable. |

L'interrupteur « mode démonstration » n'existe plus dans les réglages : il
appartenait à la version hors ligne et ne pouvait rien faire. Son absence est
normale.

## Ce qui a l'air faux et ne l'est pas

- **Pas de bouton microphone.** La recherche vocale a été retirée
  volontairement : elle ne comprenait rien, elle rejouait un script figé.
- **« Agence Teranga Immo » passe devant malgré une note plus basse.** C'est un
  profil mis en avant, marqué *Mis en avant*. Ces profils sortent toujours en
  tête.
- **9 biens et non 10.** L'un est loué et disparaît correctement de la
  recherche.
- **Une fiche de bien montre un pictogramme de maison au lieu d'une photo.** Ce
  bien n'a pas de photo. Le pictogramme est le repli prévu.
- **L'icône haut-parleur en haut à droite.** *Écouter* lit l'écran à voix haute.
  Ce n'est pas le microphone retiré.
- **Supprimer ne retire pas une annonce.** Retirer un bien le marque *Retiré* et
  le conserve, pour que celui qui a déjà contacté le courtier à son sujet le
  retrouve dans son historique.

## Comment le rédiger

Pour tout ce qui n'est pas couvert ci-dessus, cinq lignes suffisent :

1. **Écran** — le titre français en haut, par exemple *Près de vous*.
2. **Ce que vous avez touché**, dans l'ordre, depuis l'ouverture.
3. **Ce qui s'est passé.** « Rien ne s'est passé » est ici une réponse valable
   et importante.
4. **Ce que vous attendiez à la place.**
5. **Une capture d'écran**, et si vous étiez en Wi-Fi, en données mobiles ou en
   mode avion.

Si un bouton tourne puis meurt : dire lequel, et ce que vous veniez de faire.
Ce détail *est* le signalement.

---

Couvre le parcours visiteur non connecté uniquement. Les parcours connecté et
courtier rouvriront à la recette une fois la connexion réparée ; cette page sera
alors complétée plutôt que remplacée.
