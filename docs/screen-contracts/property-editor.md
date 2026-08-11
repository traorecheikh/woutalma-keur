# B03 — Broker property editor

Statut : **Draft — capture de référence non approuvée**

## Contrat

- Routes : `/broker/properties/new` et `/broker/properties/:id/edit`
- Rôle : courtier/agence identifié ; publication conditionnée par les règles de vérification produit.
- But : créer ou corriger un bien complet sans perdre le travail.
- Entrées : B01, B02 ou B04.
- Données : brouillon, type, transaction, titre, description, prix, surface, pièces, position,
  photos, statut, limites média et permission photo/caméra.

## Structure du flow

Une route conserve un brouillon et présente quatre étapes :

1. Type de bien et vente/location.
2. Titre, description, prix, surface et pièces.
3. Quartier/adresse et point carte facultatif.
4. Photos, résumé et prévisualisation.

`WkStepHeader` annonce « Étape n sur 4 ». Suivant reste l'action dominante. Retour revient à
l'étape précédente ; à la première étape il ouvre M09 si le brouillon a changé. Chaque étape
sauvegarde localement sans attendre la publication.

## Actions et destinations

| Action | Résultat |
|:--|:--|
| Dictée d'un champ | M06 puis VoiceService ; résultat modifiable avant sauvegarde |
| Choisir une option | M07, résultat typé |
| Position | WkLocationPicker avec quartier manuel toujours disponible |
| Ajouter photo | M11 puis sélection/capture, compression et validation |
| Suivant/Retour | change d'étape sans perdre le brouillon |
| Prévisualiser | B04 en mode aperçu avec retour à l'étape 4 |
| Publier | validation globale, statut disponible, puis B04/B02 |
| Quitter | M09 : continuer, garder brouillon ou supprimer le brouillon |

## Validation et états

- Erreurs proches du champ, avec pictogramme, texte et focus sur la première erreur.
- Prix accepte la saisie locale et stocke une valeur numérique, jamais une chaîne formatée.
- Photos : limite et poids restant visibles ; compression échouée n'efface pas les autres photos.
- Permission refusée : galerie/caméra reste remplaçable par Continuer sans photo si produit autorise.
- Interruption/fermeture : reprise au dernier brouillon et à la dernière étape cohérente.
- Édition concurrente n'existe pas dans le prototype local ; ne pas créer de résolution de conflit.
- Demo : brouillon vide, partiel, complet, média en erreur et bien existant.

## Accessibilité et performance

- Chaque champ a un label persistant ; placeholder seul interdit.
- Clavier numérique adapté au prix/surface/pièces sans bloquer collage ou correction.
- Focus suivant suit l'ordre visible ; le bouton fixe ne masque pas le champ actif.
- Miniatures décodées à la taille affichée ; aucune photo pleine résolution dans une liste.
- Animations d'étapes courtes et désactivables par la préférence de mouvement plateforme.
- Validation de champ, étape prête, brouillon, photo, erreur et publication appliquent B03/M11 dans
  `../INTERACTION-FEEDBACK.md`; aucune vibration n'est déclenchée par chaque caractère valide.

## Acceptation visuelle et fonctionnelle

- Un brouillon survit à Retour, changement d'onglet simulé et redémarrage.
- Publication impossible avec champs requis invalides ; la première erreur devient visible.
- Un bien publié apparaît dans C01 et C02 ; vendu/loué en disparaît sans être supprimé de B02.
- Aucun dropdown, dialogue, champ ou carte Material non stylé n'apparaît.
- Captures requises : 360×800 Android et 390×844 iPhone, étapes 1 et 4, erreur, clavier visible,
  FR ×1.3.
