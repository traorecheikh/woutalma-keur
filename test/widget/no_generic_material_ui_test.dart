import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les widgets Material génériques restent hors UI app', () {
    final RegExp banned = RegExp(
      r'\b(AppBar|BottomNavigationBar|NavigationBar|Switch|'
      r'CircularProgressIndicator|LinearProgressIndicator|PhoneFormField|'
      r'Pinput)\s*\(',
    );
    final List<String> offenders = Directory('lib/app')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .expand((File file) sync* {
          final List<String> lines = file.readAsLinesSync();
          for (int i = 0; i < lines.length; i++) {
            if (banned.hasMatch(lines[i])) {
              yield '${file.path}:${i + 1}: ${lines[i].trim()}';
            }
          }
        })
        .toList();

    expect(offenders, isEmpty);
  });
}
