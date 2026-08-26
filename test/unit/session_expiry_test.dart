import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/data/services/dio_auth_interceptor.dart';
import 'package:woutalma_keur/app/data/services/session_expiry.dart';
import 'package:woutalma_keur/app/data/services/token_store.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';

/// Ce que `main.dart` branche sur l'expiration : fermer la session ouverte.
void _closeSession(AuthService auth, SessionExpiry expiry) {
  if (!expiry.isExpired) {
    return;
  }
  expiry.acknowledge();
  auth.signOut();
}

/// Serveur qui refuse tout, sans toucher à une socket.
class _Refuses implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('{"message":"Unauthorized"}', 401);

  @override
  void close({bool force = false}) {}
}

void main() {
  test('un 401 sans jeton de renouvellement termine la session', () async {
    final TokenStore tokens = TokenStore(InMemoryTokenStorage());
    await tokens.save(accessToken: 'mort');
    final SessionExpiry expiry = SessionExpiry();
    final AuthService auth = SimulatedAuthService();
    await auth.verify('+221770000000', '123456');
    expiry.addListener(() => _closeSession(auth, expiry));

    final Dio dio = Dio(BaseOptions(baseUrl: 'https://exemple.test'))
      ..httpClientAdapter = _Refuses()
      ..interceptors.add(
        DioAuthInterceptor(
          tokens: tokens,
          baseUrl: 'https://exemple.test',
          options: BaseOptions(),
          onSessionExpired: expiry.expire,
        ),
      );
    await expectLater(dio.get<void>('/contacts'), throwsA(isA<DioException>()));

    expect(tokens.accessToken, isNull);
    expect(auth.current, isNull);
    // Ré-armé : la prochaine expiration doit être signalée elle aussi.
    expect(expiry.isExpired, isFalse);
  });

  test('une expiration ne se signale qu\'une fois', () {
    final SessionExpiry expiry = SessionExpiry();
    var notified = 0;
    expiry.addListener(() => notified++);

    expiry
      ..expire()
      ..expire();

    expect(notified, 1);
  });
}
