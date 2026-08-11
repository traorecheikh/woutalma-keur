import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/main.dart';

void main() {
  test('les paquets qui affichent du texte sont traduits eux aussi', () {
    // Vu à l'écran : le sélecteur de pays s'ouvrait sur « Search »,
    // « Algeria », « Germany ». Traduire nos propres chaînes ne suffit pas si
    // un paquet en affiche d'autres.
    for (final LocalizationsDelegate<Object?> delegate
        in PhoneFieldLocalization.delegates) {
      expect(
        wkLocalizationsDelegates,
        contains(delegate),
        reason: 'délégation absente : $delegate',
      );
    }
  });

  test('chaque langue déclarée est réellement servie', () {
    for (final Locale locale in AppL10n.supportedLocales) {
      for (final LocalizationsDelegate<Object?> delegate
          in wkLocalizationsDelegates) {
        expect(
          delegate.isSupported(locale),
          isTrue,
          reason: '$delegate ne couvre pas $locale',
        );
      }
    }
  });
}
