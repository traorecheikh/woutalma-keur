# Console de modération — Draft

## Route, entrée et sortie

- Route web : `/admin`, ouverte directement depuis un navigateur de bureau ou mobile.
- Rôle : modérateur configuré par `ADMIN_EMAIL` et `ADMIN_PASSWORD` sur le serveur.
- Sortie : « Déconnexion » efface le jeton de la session du navigateur. Le retour navigateur ne
  restaure jamais une session expirée.

## Objectif et données

Décider rapidement, sans modifier les données métier à la main :

1. file des profils `PENDING` avec nom, type, téléphone, zone et date de demande ;
2. file des avis `PENDING` avec courtier, note, commentaire, motif du signalement et réponse ;
3. compte visible de chaque file.

Le jeton modérateur ne donne accès qu'aux routes `/admin-api`. Aucun mot de passe par défaut n'est
embarqué dans le code ou les assets web.

## Actions et décisions

- Profil : « Approuver » écrit `VERIFIED`. « Refuser » révèle un motif obligatoire de 300 caractères
  maximum puis écrit `REJECTED` et ce motif.
- Avis : « Publier » écrit `PUBLISHED`. « Retirer » écrit `REJECTED`.
- Une décision réussie retire l'élément de la file et annonce le résultat. Une erreur conserve
  l'élément et permet de réessayer.
- Une seule décision est envoyée à la fois. Aucun traitement en masse au MVP.

## États

| État                      | Réponse                                                        |
| ------------------------- | -------------------------------------------------------------- |
| Chargement                | deux squelettes stables, sans annoncer chaque bloc             |
| File vide                 | pictogramme, nom de la file et message « La file est à jour »  |
| Erreur réseau/serveur     | message visible, file conservée, bouton Actualiser disponible  |
| Session expirée/interdite | jeton effacé et retour à la connexion                          |
| Identifiants invalides    | message associé au formulaire, valeurs corrigeables            |
| Trop de tentatives        | blocage serveur de cinq minutes et message explicite           |
| Hors ligne                | même état d'erreur réseau ; aucune décision locale ou différée |

## Accessibilité et adaptation

- Libellé visible avec chaque pictogramme critique ; aucun statut par couleur seule.
- Ordre clavier : navigation, actualisation, contenu, décisions ; focus visible sur tous les contrôles.
- Messages d'erreur en `role=alert`, résultats dans une région `aria-live`.
- À moins de 1024 px, la navigation latérale devient une rangée en tête ; aucune action n'est cachée.

## Critères d'acceptation

1. Sans jeton valide, aucune file ni mutation n'est accessible.
2. Un profil refusé sans motif reste `PENDING`.
3. Une décision valide met à jour la base et retire l'élément de la file.
4. Recharger `/admin/` sert la console depuis le même service Render que l'API.
5. La connexion est limitée à cinq tentatives par minute et bloque cinq minutes après dépassement.
6. La console reste utilisable au clavier, à 320 px et avec un zoom texte de 130 %.
