# Woutalma Keur — définition produit

Version 1.0 — cahier des charges nettoyé pour le prototype Flutter local-first.

## 1. Vision

Woutalma Keur met en relation des particuliers cherchant un logement avec des courtiers ou agences
immobilières proches. L'application est un annuaire géolocalisé fondé sur la confiance. Elle ne
gère ni paiement, ni contrat, ni transaction immobilière.

La promesse client : **trouver un contact pertinent et l'appeler en trois écrans maximum**, par un
parcours lisible **ou vocal**.

### Langue

Le prototype livre **le français seul**. La machinerie de localisation est en place dès le premier
écran : ajouter une langue est un fichier ARB de plus, jamais une reprise d'écran.

Ce qui **ne change pas** avec cette décision : la cible reste une personne qui **lit mal**. Réduire
le nombre de langues ne réduit pas l'illettrisme. Le chemin vocal, les pictogrammes, les grandes
cibles et la lecture d'écran à voix haute restent des contraintes produit — simplement en français.

Ce qui **change** : une partie du public cible parle mal le français. C'est désormais un risque
produit assumé et suivi (§10), pas un détail d'interface.

## 2. Utilisateurs

### Client

Cherche une location, un achat ou un terrain près d'une zone. Peut avoir une faible maîtrise de
l'écrit et utiliser surtout la voix, les pictogrammes et l'appel.

### Courtier indépendant

Publie et tient à jour ses biens, gagne en visibilité locale, reçoit des contacts et construit une
réputation vérifiable.

### Agence immobilière

Utilise le même parcours courtier avec une identité d'entreprise, un registre de commerce et
plusieurs biens. Le MVP ne gère pas plusieurs employés ou permissions internes.

### Modérateur

Vérifie les profils et traite les avis signalés. La console modérateur n'appartient pas à
l'application mobile prototype ; ses résultats sont simulés par les données locales.

## 3. Périmètre MVP

### Découverte client

- Localisation GPS avec quartier/ville manuel toujours disponible.
- Recherche textuelle, vocale et par filtres.
- Filtres : location/vente, appartement/maison/terrain/studio/chambre, rayon et prix.
- Résultats courtiers et biens triés par score ; liste et carte partagent le même état.
- Fiches courtier/agence : identité, zone, vérification, note, volume d'avis, réactivité, biens et
  avis récents.
- Fiches bien : photos, type, transaction, prix, surface, pièces, position, courtier et statut.

### Contact

- Appel, SMS, WhatsApp et message vocal via les applications du téléphone.
- Journal local avant l'ouverture du canal externe.
- Résultat du contact : échange réussi, sans réponse ou à reprendre plus tard.
- Historique client pour retrouver un courtier déjà contacté.
- Événements consultation/contact visibles dans l'activité courtier du prototype.

### Avis et confiance

- Un avis n'est possible qu'après un contact journalisé et marqué comme échange réussi.
- Un seul avis par contact éligible.
- Note globale sur 5 ; critères réactivité, fiabilité des informations et courtoisie.
- Commentaire facultatif avec état de modération.
- Le courtier peut répondre ou signaler ; le modérateur décide hors de l'app.
- Profil vérifié et réactivité sont affichés sans dépendre uniquement de la couleur.

### Espace courtier/agence

- Création et modification du profil et de la zone de couverture.
- Parcours de vérification identité/registre avec en attente, validé et refusé.
- Ajout, modification, aperçu et suppression d'un bien.
- Photos multiples compressées ; limites de nombre et poids définies avant implémentation.
- Statuts disponible, réservé et vendu/loué.
- Saisie vocale facultative pour les champs pertinents.
- Tableau d'accueil, activité, avis et position dans le classement local.

### Accessibilité vocale

- Lecture de l'écran et des informations essentielles à voix haute.
- Recherche par commande vocale. **Retirée de l'application le 2026-08-14** :
  la reconnaissance n'a jamais été réelle, et un micro qui répond un script
  figé dessert précisément la personne qui ne lit pas. À rétablir dès qu'un
  moteur français mesuré sur des voix ouest-africaines existe — c'est déjà la
  condition posée en §« Hors périmètre ».
- Dictée dans l'ajout d'un bien.
- Enregistrement et lecture d'un message vocal.
- Permission refusée, silence et commande incomprise ont toujours une
  alternative tactile.
- Le moteur réel reste derrière `VoiceService`. L'interface du prototype
  survit dans le catalogue S02 ; elle n'est plus atteignable depuis un écran
  produit.

## 4. Règles métier verrouillées

1. Un client peut explorer sans compte. Le téléphone est demandé juste avant une action identifiée
   telle que contacter, noter ou gérer un profil courtier.
2. Un bien vendu ou loué disparaît immédiatement de la découverte et de la liste publique du
   courtier, mais reste dans sa gestion.
3. Un bien réservé reste visible avec son statut.
4. Le classement est déterministe et combine note, confiance statistique liée au volume d'avis,
   proximité et taux de réponse. Sa formule vit hors UI et est testée.
5. Un profil épinglé est explicitement identifié et ne masque pas son classement organique.
6. Un avis publié ou en modération n'est jamais modifiable par le courtier concerné.
7. Le numéro client n'est pas exposé dans une fiche ; un canal externe peut le révéler selon le
   fonctionnement du téléphone ou de WhatsApp.
8. Les applications client et courtier sont deux rôles dans le même binaire, avec changement de rôle
   depuis le profil.
9. Aucun paiement, contrat ou chat textuel interne n'est ajouté au MVP.

## 5. Mode local et mode démo

Le prototype utilise les mêmes contrats de repository dans les deux modes :

- `demo` : seed local complet, déterministe, versionné et idempotent couvrant profils, biens,
  statuts, avis, activités, contacts, vérification, erreurs et états vides. Toujours 100% local,
  sans réseau.
- `real` : connecté à l'API distante (voir §8bis) ; identification requise avant les actions qui
  écrivent des données, connectivité requise en usage normal. Un cache de lecture léger est
  autorisé (résultats de recherche récents, par exemple) mais rien d'important n'est mis en file
  d'attente hors-ligne.

Changer de mode demande confirmation. La transaction purge les données du mode précédent puis
charge le seed ou une base vide. Un échec ne doit jamais laisser un mélange de données.

## 6. Données principales

| Entité | Données essentielles |
|:--|:--|
| Utilisateur | identité locale, téléphone, rôle actif, langue, préférences |
| CourtierAgence | type, identité, coordonnées, zone, vérification, taux de réponse |
| Bien | propriétaire, type, transaction, contenu, prix, caractéristiques, position, photos, statut |
| Avis | client, courtier, contact éligible, notes, commentaire, réponse, modération, dates |
| ContactLog | client, courtier, bien facultatif, canal, date, résultat, éligibilité avis |
| ActivityEvent | consultation/contact, courtier, bien facultatif, date, état lu |
| AppSettings | langue, rôle, mode, thème, texte, mode léger, vocal, sons, vibrations, notifications, version seed |

Les schémas Isar définitifs et migrations sont décidés au moment de la première tranche verticale,
pas dans ce document produit.

## 7. Exigences non fonctionnelles

- Android prioritaire, iOS compatible avec le même code Flutter.
- Téléphones 320–390 dp, mémoire et stockage limités.
- Résultats utiles en moins de trois secondes sur 3G lorsque le futur backend existe.
- Images compressées, placeholders et liste disponible si la carte est trop coûteuse.
- Toutes les actions critiques utilisables avec TalkBack et une cible minimale de 56 dp.
- Chaque action significative reçoit un retour immédiat et multimodal proportionné : visuel,
  sémantique, mouvement, haptique et/ou sonore selon `INTERACTION-FEEDBACK.md`.
- Sons, vibrations et guidage vocal sont réglables séparément ; aucune modalité ne porte seule une
  réussite, un avertissement ou une erreur.
- Aucune troncature à ×1.3 de taille de texte.
- Aucun texte visible non localisé.
- Les données locales restent cohérentes après interruption, fermeture ou changement de mode.

## 8. Hors périmètre du prototype

- Paiement, abonnement premium, contrat ou signature.
- Chat textuel interne.
- Comptes multi-employés pour agences.
- Statistiques avancées de conversion.
- Reconnaissance vocale de production et engagement de précision STT.
- Wolof, pulaar, sérère.
- Authentification SMS OTP et WhatsApp Business Cloud API OTP (voir §8bis — construites derrière une
  abstraction serveur mais pas activées).

## 8bis. Résolution de conflit — pivot backend (2026-08-10)

Cette section documente et remplace la ligne « Backend distant, synchronisation multi-appareil et
notifications push réelles » qui figurait précédemment en §8 comme hors périmètre, ainsi que
« Console de modération et traitement humain réel » et « mode hors-ligne synchronisé avec un
serveur ».

**Conflit constaté** : ce document (version 1.0, prototype local-first) excluait explicitement un
backend distant, la synchronisation et les notifications push réelles du MVP. Le porteur produit a
depuis approuvé explicitement le développement d'un backend de production complet (API de
synchronisation, authentification réelle, notifications push FCM, console de modération) — en
contradiction directe avec l'exclusion ci-dessus.

**Résolution** : l'exclusion est levée. Le périmètre inclut désormais un backend NestJS +
PostgreSQL/PostGIS, une authentification Google Sign-In (client et courtier) et lien magique par
e-mail (secondaire pour le client, primaire pour courtier/agence), les notifications FCM, et une
console de modération séparée. L'authentification SMS OTP et WhatsApp Business restent hors
périmètre actif (voir §8) mais l'abstraction serveur d'authentification (`AuthProvider` côté
backend, miroir d'`AuthService` côté Flutter) est conçue pour les accueillir sans rupture de
contrat.

**Raison** : décision produit approuvée directement par le porteur produit, motivée par le besoin de
synchronisation multi-appareil réelle et de notifications, avec les contraintes suivantes déjà
tranchées : identifiants générés côté serveur (pas d'UUID client, pas de file d'écriture hors-ligne
— l'app nécessite une connectivité normale, un cache de lecture léger reste acceptable), génération
du client Dart depuis un spec OpenAPI auto-émis (`@nestjs/swagger`) plutôt qu'un client écrit à la
main, et rejet explicite de GraphQL (écrans à requêtes fixes déjà définis, une seule équipe cliente
mobile) et d'un admin auto-généré type AdminJS pour la console (contrôle UX voulu sur les deux
actions modérateur : approbation/rejet de vérification, modération d'avis).

Le §5 (« Mode local et mode démo ») est mis à jour en conséquence : `real` désigne maintenant le mode
connecté à cette API, `demo` reste inchangé. Le §7 (l. 144, budget « moins de trois secondes sur
3G ») cesse d'être une exigence différée : c'est désormais le budget de performance de cette API.

Livré en tranche verticale (Phase 1, voir le plan d'implémentation archivé) : lecture
courtier/bien, recherche classée server-side (portage exact de la formule de `RankingService`),
journalisation de contact et éligibilité d'avis server-side, authentification Google Sign-In.
Différé aux tranches suivantes : lien magique e-mail, notifications FCM, console de modération,
écriture courtier/bien distante.

## 9. Indicateurs futurs

- Contacts réussis par semaine.
- Conversion recherche vers contact.
- Avis moyens par profil actif.
- Usage vocal par rapport au texte.
- Rétention client à 30 jours.
- Part des profils actifs vérifiés.

Ces métriques guident le futur backend ; le prototype ne fabrique pas une couche analytics avant
qu'un service de collecte et une politique de consentement soient décidés.

## 10. Risques à valider tôt

- Part du public cible qui ne suit pas un parcours en français, maintenant que le wolof sort du MVP. Risque le plus élevé de la liste.
- Qualité réelle STT/TTS en français sur voix africaines francophones.
- Compréhension des pictogrammes et du vocabulaire par des utilisateurs peu lecteurs.
- Coût data et lisibilité de la carte sur appareils d'entrée de gamme.
- Fraude malgré le lien entre contact et avis.
- Adoption du parcours de publication par les courtiers peu numériques.
- Périmètre géographique et qualité des données du pilote.
