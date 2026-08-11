import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app stores do not expose Flutter starter identity', () {
    final Map<String, Object?> manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, Object?>;
    final String webIndex = File('web/index.html').readAsStringSync();
    final String androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final String iosInfo = File('ios/Runner/Info.plist').readAsStringSync();

    expect(manifest['name'], 'Woutalma Keur');
    expect(manifest['short_name'], 'Woutalma');
    expect(manifest['description'], contains('courtier immobilier'));
    expect(webIndex, contains('<title>Woutalma Keur</title>'));
    expect(androidManifest, contains('android:label="Woutalma Keur"'));
    expect(iosInfo, contains('<string>Woutalma Keur</string>'));

    for (final String source in <String>[
      jsonEncode(manifest),
      webIndex,
      androidManifest,
      iosInfo,
    ]) {
      expect(source, isNot(contains('A new Flutter project')));
      expect(source, isNot(contains('Flutter Demo')));
      expect(source, isNot(contains('woutalma_keur')));
    }
  });
}
