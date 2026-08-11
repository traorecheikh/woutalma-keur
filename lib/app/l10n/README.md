# Localisation

## Règle unique

**Aucune chaîne visible n'est écrite dans un widget.** Tout texte que l'utilisateur peut lire ou
entendre passe par `context.l10n`. Sans exception : ni un libellé « temporaire », ni un message
d'erreur de debug, ni un placeholder.

Cette règle n'est pas déclarative. `test/widget/no_hardcoded_text_test.dart` échoue si un `Text`
rendu porte une chaîne absente des valeurs de l'ARB.

## Langues

Le MVP livre **le français seul**. La machinerie i18n est en place dès maintenant pour qu'ajouter
une langue soit un fichier `.arb` de plus et une ligne dans `supportedLocales`, jamais une reprise
des écrans.

Ajouter une langue :

1. copier `app_fr.arb` en `app_<code>.arb`, changer `@@locale`, traduire les valeurs ;
2. lancer `flutter gen-l10n` ;
3. la locale apparaît automatiquement — `supportedLocales` est dérivé de `AppL10n.supportedLocales`.

Le wolof reste la cible produit — il figure en risque suivi dans `docs/PRODUCT.md` §10, parce
qu'une partie du public ne suit pas un parcours en français. Il entre quand un locuteur natif peut
relire l'intégralité du fichier : une traduction approximative, sur un produit dont le public lit
mal et se fie à la lecture vocale, est pire que pas de traduction du tout.

Attention à ne pas confondre deux choses. Livrer une seule langue **ne réduit pas** la contrainte
d'illettrisme : le chemin vocal, les pictogrammes et la lecture d'écran restent obligatoires.

## Écrire une clé

- `app_fr.arb` est le modèle : toute clé y porte sa `@description`. Une clé sans description est
  incomplète — c'est la description qui permet de traduire sans deviner le contexte.
- **Le libellé doit s'entendre.** Il sera lu à voix haute par le guidage vocal ; une tournure
  correcte à l'écrit mais lourde à l'oral est un mauvais libellé.
- **Le libellé doit être concret.** « Appeler », « Écouter », « Ajouter un bien » — jamais
  « Valider », « Confirmer », « Soumettre », vides de sens à l'oreille.
- Un message d'erreur dit **quoi faire**, pas ce qui est faux : « Il manque 2 chiffres » plutôt que
  « Numéro invalide ».

## Mise en page

Le français n'est pas la chaîne la plus longue une fois d'autres langues ajoutées. Aucun écran ne
fige une hauteur autour d'un texte, et chaque écran est vérifié à ×1.3 avant d'être déclaré
terminé.
