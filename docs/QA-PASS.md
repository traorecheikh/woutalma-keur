# Passe de test — visiteur, client identifié, courtier

Build Android du 15 août 2026. À jour de l'ouverture de la connexion de recette.

Ce document s'adresse à quelqu'un qui n'a pas travaillé sur l'application. Il
couvre maintenant **trois** parcours, à faire dans l'ordre :

- **A. Le visiteur** — sans compte. Étapes 1 à 9.
- **B. Le client identifié** — se connecter, contacter, noter. Étapes 10 à 14.
- **C. Le courtier** — ouvrir un espace, publier un bien. Étapes 15 à 21.

Ce qui reste hors d'atteinte est listé en fin de page, pour ne pas y perdre une
après-midi.

## À lire avant de commencer

Ce qui échoue le dit maintenant. Une lecture qui rate affiche un panneau
**« Ça n'a pas marché. »** avec un bouton **Réessayer** ; un enregistrement qui
rate affiche un message en bas d'écran. Les boutons ne tournent plus dans le
vide.

Donc **si un bouton se met à tourner et ne s'arrête jamais, c'est un
signalement juste et utile** : notez lequel, et ce que vous veniez de faire.
C'était la règle générale du build précédent, c'est devenu l'exception.

En revanche le **texte** de ces messages est souvent trop vague : « Ça n'a pas
marché. » sert pour une panne de réseau, pour un refus du serveur et pour une
règle produit. Signalez un message qui vous a envoyé chercher au mauvais
endroit — c'est utile — mais ne signalez pas deux fois le même.

## Avant la première ouverture

| | |
|:--|:--|
| **Installation** | Désinstaller toute version antérieure. Une installation neuve compte : certaines étapes ne se produisent qu'au tout premier lancement. |
| **Le bon build** | La connexion de recette n'existe que dans un build produit par `tool/run_staging.sh`. Un APK ordinaire n'a ni code SMS simulé, ni espace courtier : la connexion y échoue en disant « Ce serveur n'accepte pas la connexion de recette. » Si vous voyez cette phrase, c'est le build qui est en cause, pas vous. |
| **Réseau** | Wi-Fi ou données mobiles réelles. L'application interroge un serveur à chaque écran. |
| **Premier chargement lent** | Le serveur s'endort quand personne ne l'utilise et met environ **50 secondes** à se réveiller. Ouvrir, attendre, et seulement ensuite commencer à mesurer quoi que ce soit. |
| **Langue** | Français uniquement. Il n'y a pas de réglage de langue. Tout texte en anglais est à signaler. |
| **Un numéro à vous** | Le parcours B et le parcours C demandent un numéro sénégalais à 9 chiffres. Aucun SMS n'est envoyé, aucun vrai numéro n'est nécessaire : `770000001` convient. Prenez-en **deux différents**, un par parcours. |

---

# A. Le visiteur

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

### 6. Contacter sans être connecté — *Contacter* — refus attendu

**Faire** — Toucher **Contacter**, puis **Appeler**. Une seule fois, pour l'avoir
vu.

**Ce qui se passe** — Le panneau se ferme, le téléphone ne s'ouvre pas, et un
message court apparaît en bas : **« Ça n'a pas marché. »** Le bouton
**Contacter** redevient utilisable immédiatement.

**Ne pas signaler** — Le refus lui-même est voulu : contacter exige un compte,
parce que le contact est journalisé et sert ensuite à autoriser un avis. Toutes
les voies — appel, SMS, WhatsApp, depuis un courtier ou depuis un bien —
refusent de la même façon.

**Déjà connu** — Le message ne dit pas qu'il faut se connecter, et l'application
ne propose pas de le faire depuis cet endroit. C'est le défaut le mieux compris
de la liste ; une ligne dans vos notes suffit. Le contact fonctionne vraiment à
l'étape 12, une fois connecté.

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

# B. Le client identifié

Aucun SMS n'est envoyé. Le code s'affiche à l'écran.

### 10. Se connecter — *Votre numéro* — devrait marcher

**Faire** — **Profil** (troisième onglet) → **M'identifier**. Laisser
l'interrupteur *Ouvrir un espace courtier* **éteint**. Taper votre premier
numéro à 9 chiffres, puis **Recevoir le code**.

**Attendu**

- L'écran s'appelle **Votre numéro** et explique pourquoi il le demande :
  « Pour garder la trace de vos contacts. »
- Le champ n'accepte que des chiffres. Un numéro incomplet affiche
  « Ce numéro n'est pas complet » **au moment où vous appuyez**, pas pendant la
  frappe.
- L'écran suivant, **Code reçu par SMS**, affiche lui-même le code :
  « Code de démonstration : 123456 ». Le recopier dans le champ.
- Le code se valide **tout seul au sixième chiffre**. Il n'y a pas de bouton
  Valider, c'est voulu.
- Vous revenez sur **Près de vous**, connecté.

**Pas un bug**

- Le bouton **Continuer avec Google** est présent et échouera : aucun client
  Google n'est configuré sur ce serveur. Il doit le dire —
  « La connexion Google n'est pas configurée sur ce serveur. » — et non parler
  de réseau. Un message qui parle de réseau ici **est** à signaler.
- Le même numéro donne **toujours le même code**, même après redémarrage du
  serveur. C'est voulu en recette.
- « Renvoyer dans 30 s » : le bouton de renvoi est inactif une demi-minute.

**À signaler** — Un code refusé alors que vous avez recopié celui affiché.

### 11. Vérifier qu'on est bien connecté — *Profil* — devrait marcher

**Faire** — Ouvrir **Profil**.

**Attendu** — La ligne *Compte* affiche maintenant
« Identifié avec le +221… » et votre numéro. Fermer et rouvrir l'application :
vous devez rester connecté.

**À signaler** — Être déconnecté au redémarrage.

### 12. Contacter pour de vrai — *Fiche courtier* — devrait marcher

**Faire** — **Explorer** → **Moussa Ndiaye** → **Contacter** → **Appeler**.
Le composeur du téléphone s'ouvre : **ne pas passer l'appel**, revenir en
arrière. Recommencer avec **Envoyer un SMS**, puis, sur un courtier qui en a
un, avec **WhatsApp**.

**Attendu**

- Le composeur Android s'ouvre avec le numéro déjà rempli.
- Revenir dans l'application vous ramène sur la fiche, telle que vous l'aviez
  laissée.
- WhatsApp n'apparaît que chez les courtiers qui en ont un (revoir l'étape 5).

**Pas un bug** — Le contact est enregistré **avant** que le composeur s'ouvre.
Si vous annulez l'appel, il reste dans votre historique : l'application note que
vous avez cherché à joindre quelqu'un, pas que vous lui avez parlé. C'est
l'étape 13 qui fait la différence.

**À signaler** — Le composeur ne s'ouvre pas alors que vous êtes connecté, ou
s'ouvre avec un mauvais numéro.

### 13. L'historique et la question du résultat — *Contacts* — devrait marcher

**Faire** — Ouvrir l'onglet **Contacts** (deuxième onglet).

**Attendu**

- Vos contacts, le plus récent en haut : nom du courtier, canal et date
  (« Appel · 15 août 2026 »), et une pastille d'état.
- Sur un contact tout neuf, la question **« Avez-vous eu cette personne ? »**
  avec deux réponses : **Oui, on a échangé** et **Pas de réponse**.
- Répondre **Pas de réponse** remplace la question par la phrase
  « Pas de réponse : on ne note que quelqu'un à qui on a parlé. » et **aucun
  bouton d'avis n'apparaît**. C'est la règle, pas un oubli.
- Répondre **Oui, on a échangé** fait apparaître **Donner un avis**.

**Pas un bug**

- Le courtier ne peut pas répondre à cette question à votre place : elle
  n'existe que de votre côté.
- Un même courtier peut être noté plusieurs fois, mais **une seule fois par
  contact**. Pour le noter à nouveau, il faut un nouveau contact, marqué à
  nouveau « on a échangé ».

**À signaler** — La liste reste vide alors que vous venez de contacter
quelqu'un ; ou l'état choisi ne tient pas après un aller-retour.

### 14. Laisser un avis — *Votre avis* — devrait marcher

**Faire** — **Donner un avis**. Mettre une note globale, puis, si vous voulez,
les trois notes détaillées et un commentaire. Envoyer.

**Attendu**

- Une seule note est obligatoire : **Comment s'est passé l'échange ?**
  *Réactivité*, *Informations exactes* et *Courtoisie* sont facultatives, comme
  le commentaire.
- Le bouton d'envoi n'est jamais grisé : appuyer sans note doit **dire** ce qui
  manque (« Choisissez d'abord une note »), pas rester muet.
- L'écran se ferme et le contact porte désormais **Avis envoyé**.

**Pas un bug**

- **Votre avis n'apparaîtra pas sur la fiche du courtier, et sa note ne
  bougera pas.** Tout avis part « en modération », et la console de modération
  n'existe pas encore : rien ne le publiera dans cette version. C'est le
  comportement voulu, pas une perte de données. Le courtier le voit compté
  parmi ses « avis en modération » (étape 16).
- **Un avis ne se modifie pas et ne se supprime pas.** Il n'y a ni l'un ni
  l'autre nulle part, c'est volontaire.

**Déjà connu** — Si l'envoi est refusé, le message affiché parle d'ouvrir les
réglages du téléphone alors qu'il s'agit d'une règle produit. Le texte est faux,
c'est consigné, ne pas re-signaler.

**À signaler** — Le badge **Avis envoyé** n'apparaît pas au retour sur la liste
alors que l'envoi a réussi. Changer d'onglet puis revenir : si le badge
apparaît seulement à ce moment-là, dites-le, c'est un rafraîchissement
manquant.

---

# C. Le courtier

À faire avec le **second** numéro, sur la même installation, après vous être
déconnecté : **Profil → la ligne Compte → Me déconnecter**.

### 15. Ouvrir un espace courtier — *Votre numéro* — devrait marcher

**Faire** — **Profil** → **M'identifier**. Cette fois, **allumer
l'interrupteur « Ouvrir un espace courtier »**. Taper le second numéro,
recevoir le code, le recopier.

**Attendu**

- L'interrupteur porte l'avertissement « Recette uniquement. Crée un profil
  courtier vide rattaché à ce numéro. »
- Après le code, vous arrivez directement dans l'espace courtier, quatre
  onglets en bas : **Accueil**, **Biens**, **Activité**, **Profil**.

**Pas un bug**

- Votre profil s'appelle **« Courtier »** suivi des quatre derniers chiffres de
  votre numéro. Il est **non vérifié**, sans photo, sans bien, sans avis, et sa
  seule zone couverte est *Plateau*. C'est exactement ce qu'un nouveau courtier
  doit voir. Le nom se change à l'étape 19.
- Vous êtes placé au centre du Plateau tant que vous n'avez rien publié.

**Autre chemin, à essayer aussi** — Depuis un compte déjà connecté :
**Profil → Rôle → Je propose des biens**. Si le compte n'a pas de profil
courtier, les quatre onglets affichent **« Espace courtier / Se connecter »**.
Ce bouton doit vous mener à l'écran du numéro avec l'interrupteur courtier
**déjà allumé**. **À signaler** : s'il vous renvoie une seconde fois au même
écran verrouillé, ou si vous ne pouvez pas en sortir sans fermer
l'application.

### 16. L'accueil courtier — *Mon activité* — devrait marcher

**Faire** — Regarder l'onglet **Accueil** sans rien toucher.

**Attendu**

- Un bloc **À traiter maintenant** avec **une seule** action proposée. Sur un
  profil neuf, c'est **Demander la vérification** — pas « Ajouter un bien ».
- Un bloc **Résumé** avec quatre chiffres, tous à zéro : « Aucun bien visible »,
  « Aucun contact reçu », « Aucun avis », « Aucun bien clos ».

**Pas un bug** — Une seule action est proposée à la fois, volontairement. Elle
change quand la précédente est faite.

### 17. Demander la vérification — *Vérification* — devrait marcher, puis s'arrêter

**Faire** — **Demander la vérification**, une fois.

**Attendu** — Le statut passe à **en attente**, et le bouton devient inactif
avec la raison « Un modérateur examine votre demande. »

**Pas un bug**

- Aucun document n'est demandé. La pièce justificative n'existe pas encore.
- **Le statut restera « en attente » pour toujours** : il n'y a pas de console
  de modération dans cette version, donc personne ne peut valider ni refuser.
  Ne pas attendre, ne pas re-signaler.

**À signaler** — Le message « La demande n'a pas été enregistrée. Réessayez. »
Il veut dire que le serveur n'a rien changé : c'est un vrai défaut.

### 18. Publier un bien — *Nouveau bien* — devrait marcher

**Faire** — **Biens** → **Ajouter un bien**. Traverser les trois étapes et
**Publier le bien**.

**Attendu**

- **Étape 1 sur 3 — Le bien et son quartier** : louer ou vendre, type de bien,
  quartier. Trois choix, **aucun clavier**.
- **Étape 2 sur 3 — Infos essentielles** : le **titre est déjà écrit** à partir
  de vos choix (« Appartement 3 pièces à Mermoz »), avec une mention disant
  qu'il vous est proposé. Le prix est le seul champ à taper. Surface et nombre
  de pièces sont des listes de valeurs, pas des champs libres.
- **Étape 3 sur 3 — Photos et publication** : jusqu'à **3 photos**, la limite
  étant annoncée avant de choisir.
- Après **Publier le bien** : le message « Bien publié » et le retour à la liste
  **Biens**, où le bien apparaît immédiatement.

**Pas un bug**

- **Le nombre de pièces disparaît si le type est *Terrain*.** Un terrain n'a pas
  de pièces ; la question n'est pas posée.
- **La question du statut n'existe pas à la création.** Publier, c'est rendre
  disponible. Le statut se change ensuite depuis la liste **Biens**.
- **Le titre est écrit par l'application** à partir de ce que vous avez choisi.
  Le corriger est prévu : la mention « proposé » doit disparaître dès votre
  première frappe. La description, elle, arrive encore vide dans ce build ;
  elle sera composée de la même façon plus tard.
- Le bouton n'est jamais grisé. C'est en appuyant qu'on apprend ce qui manque.

**À signaler**

- Un clavier qui s'ouvre ailleurs que sur le prix, le titre ou la description.
- Une erreur signalée qui vous renvoie à une étape où **rien** n'est marqué en
  rouge.
- Un titre proposé qui ne correspond pas aux choix que vous venez de faire.
- Refaire l'étape 9 (grands caractères) sur ces trois écrans : ils sont
  nouveaux et n'ont pas encore été relus à ×1,3.

### 19. Vérifier que le bien est vraiment publié — *Explorer* — devrait marcher

**Faire** — Ouvrir **Biens** : le bien doit y être avec son prix et son statut.
Toucher **Aperçu du bien**. Puis **Profil → Rôle → Je cherche un logement**, et
chercher votre bien dans **Explorer**, par son quartier.

**Attendu** — Le bien apparaît côté client, rattaché à votre nom de courtier, à
son quartier et à son prix.

**Pas un bug** — **Supprimer ce bien** ne le fait pas disparaître de votre
liste : il passe *Retiré*. Un bien retiré sort des recherches côté client mais
reste visible chez vous, pour que celui qui vous a déjà contacté à son sujet le
retrouve dans son historique.

### 20. Corriger son profil — *Modifier le profil* — devrait marcher

**Faire** — **Profil** (onglet courtier) → **Modifier le profil**. Changer le
nom, ajouter un numéro WhatsApp, écrire deux zones séparées par une virgule.
Enregistrer. Puis recommencer et **quitter sans enregistrer**.

**Attendu**

- Le nom corrigé s'affiche dès le retour sur la fiche.
- **Laisser WhatsApp vide est valide** et fait disparaître le bouton WhatsApp
  de votre fiche côté client (revoir l'étape 5). Le vérifier est un bon test.
- Quitter avec des modifications non enregistrées demande confirmation.

**Pas un bug** — Le statut de vérification et la mise en avant ne se modifient
pas ici, et l'écran le dit. Les zones couvertes se saisissent au clavier,
séparées par des virgules : le composant à pastilles viendra plus tard.

### 21. L'activité courtier — *Consultations et contacts* — devrait marcher

**Faire** — Avec l'autre numéro (parcours B), contacter votre propre courtier
depuis un second téléphone ou après déconnexion. Puis revenir côté courtier,
onglet **Activité**.

**Attendu** — Le contact apparaît : canal, date, bien concerné le cas échéant,
et un état.

**Pas un bug**

- **Aucune identité de client n'est affichée.** C'est voulu.
- **Le courtier ne peut pas dire si l'échange a eu lieu** : la ligne n'est pas
  touchable. Seul le client répond à cette question, depuis son onglet
  *Contacts*. Ce n'est pas un bouton oublié.

---

## À ne pas tester pour l'instant

Inachevé, et non cassé par accident. Les signalements sur ces points seront
fermés en doublon.

| Sujet | État |
|:--|:--|
| **La connexion Google** | Le bouton est là et échouera toujours : aucun client Google n'est configuré sur ce déploiement. Seul le code par téléphone fonctionne. |
| **Le vrai SMS** | Aucun SMS n'est envoyé, dans aucun cas. Le code s'affiche à l'écran. Un build hors recette dit « Le code par SMS n'est pas disponible dans cette version » — c'est exact. |
| **La modération** | Ni les avis ni les demandes de vérification ne peuvent être traités : la console de modération n'existe pas. Tout ce qui part « en attente » y reste. |
| **Modifier ou supprimer un avis** | N'existe nulle part, ni côté client ni côté courtier. |
| **Expiration de session** | Si votre session expire en cours d'usage, aucun bandeau ne le dit : l'écran suivant affiche seulement « Ça n'a pas marché. » Connu. |
| **Se connecter depuis l'écran de contact** | Contacter sans compte refuse sans proposer de se connecter (étape 6). Connu. |

L'interrupteur « mode démonstration » n'existe plus dans les réglages : il
appartenait à la version hors ligne et ne pouvait rien faire. Son absence est
normale. Il n'y a pas non plus de réglage de langue.

## Ce qui a l'air faux et ne l'est pas

- **Pas de bouton microphone.** La recherche vocale a été retirée
  volontairement : elle ne comprenait rien, elle rejouait un script figé. La
  dictée dans le formulaire de bien a été retirée pour la même raison.
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
- **Se déconnecter ne vide pas ce qui est affiché hors ligne.** Les courtiers
  déjà chargés restent lisibles sans compte : ce sont des fiches publiques.
- **La fiche courtier n'affiche qu'un seul bien.** Le reste se voit depuis
  l'onglet *Biens*.
- **Un bien publié garde la surface que vous aviez choisie même si elle ne
  figure plus dans la liste.** Rouvrir une annonce pour corriger son prix ne
  doit jamais changer sa surface ni son quartier.

## Comment le rédiger

Pour tout ce qui n'est pas couvert ci-dessus, cinq lignes suffisent :

1. **Écran** — le titre français en haut, par exemple *Près de vous*.
2. **Ce que vous avez touché**, dans l'ordre, depuis l'ouverture.
3. **Ce qui s'est passé.** « Rien ne s'est passé » est ici une réponse valable
   et importante.
4. **Ce que vous attendiez à la place.**
5. **Une capture d'écran**, et si vous étiez en Wi-Fi, en données mobiles ou en
   mode avion.

Précisez toujours **avec quel parcours** — visiteur, client identifié ou
courtier — et **avec quel numéro**. Un même défaut ne se comporte pas pareil des
deux côtés.

Si un bouton tourne puis meurt : dire lequel, et ce que vous veniez de faire.
Ce détail *est* le signalement.

---

Couvre les trois parcours atteignables sur le déploiement de recette. La
modération et la connexion Google rouvriront à la recette quand elles
existeront ; cette page sera alors complétée plutôt que remplacée.
