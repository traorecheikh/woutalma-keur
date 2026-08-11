import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';

void main() {
  late SimulatedAuthService auth;

  setUp(() {
    auth = SimulatedAuthService(
      brokerByPhone: const <String, String>{'221771234567': 'brk-moussa'},
    );
  });

  test('personne n\'est identifié au départ', () {
    expect(auth.current, isNull);
  });

  test('un mauvais code n\'identifie pas', () async {
    await auth.requestCode('+221771234567');

    expect(await auth.verify('+221771234567', '000000'), OtpResult.wrongCode);
    expect(auth.current, isNull);
  });

  test('le bon code identifie', () async {
    final String? code = await auth.requestCode('+221770000000');

    expect(await auth.verify('+221770000000', code!), OtpResult.verified);
    expect(auth.current?.phone, '+221770000000');
  });

  test('un numéro connu du seed ouvre son espace courtier', () async {
    final String? code = await auth.requestCode('+221 77 123 45 67');

    await auth.verify('+221 77 123 45 67', code!);

    // La comparaison ignore espaces et signes : personne ne tape un numéro
    // de la même façon deux fois.
    expect(auth.current?.brokerId, 'brk-moussa');
  });

  test('un numéro inconnu reste client', () async {
    final String? code = await auth.requestCode('+221779998877');

    await auth.verify('+221779998877', code!);

    expect(auth.current?.brokerId, isNull);
  });

  test('trop d\'essais bloque, et redemander un code débloque', () async {
    final SimulatedAuthService limited = SimulatedAuthService(maxAttempts: 2);
    await limited.requestCode('+221770000000');

    expect(
      await limited.verify('+221770000000', '111111'),
      OtpResult.wrongCode,
    );
    expect(
      await limited.verify('+221770000000', '222222'),
      OtpResult.wrongCode,
    );
    expect(
      await limited.verify('+221770000000', '333333'),
      OtpResult.tooManyAttempts,
    );

    // Redemander un code remet le compteur : on ne condamne pas quelqu'un qui
    // s'est trompé deux fois.
    await limited.requestCode('+221770000000');
    expect(
      await limited.verify('+221770000000', limited.code),
      OtpResult.verified,
    );
  });

  test('se déconnecter oublie l\'identité', () async {
    final String? code = await auth.requestCode('+221771234567');
    await auth.verify('+221771234567', code!);
    expect(auth.current, isNotNull);

    auth.signOut();

    expect(auth.current, isNull);
  });

  test('la simulation est déclarée, pas cachée', () {
    // L'écran s'appuie dessus pour afficher le code au lieu de faire croire
    // à un SMS qui n'arrivera jamais.
    expect(auth.isSimulated, isTrue);
  });
}
