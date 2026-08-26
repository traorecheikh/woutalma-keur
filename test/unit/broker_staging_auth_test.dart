import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_api_client/woutalma_api_client.dart' as api;
import 'package:woutalma_keur/app/data/services/staging_auth_service.dart';
import 'package:woutalma_keur/app/data/services/token_store.dart';
import 'package:woutalma_keur/app/domain/auth_service.dart';

class _Fixed implements HttpClientAdapter {
  _Fixed(this.status);

  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (status == 0) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'no route to host',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(const <String, Object?>{}),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

StagingAuthService _auth(HttpClientAdapter adapter, TokenStore tokens) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.httpClientAdapter = adapter;
  return StagingAuthService(
    authApi: api.AuthApi(dio, api.standardSerializers),
    tokens: tokens,
    secret: 'recette',
  );
}

void main() {
  late TokenStore tokens;

  setUp(() {
    tokens = TokenStore(InMemoryTokenStorage());
  });

  test('seul le serveur peut dire que le code est faux', () async {
    final StagingAuthService auth = _auth(_Fixed(401), tokens);
    addTearDown(auth.dispose);

    expect(await auth.verify('+221771112233', '000000'), OtpResult.wrongCode);
  });

  test('trop d\'essais ne se dit pas « code incorrect »', () async {
    final StagingAuthService auth = _auth(_Fixed(429), tokens);
    addTearDown(auth.dispose);

    expect(
      await auth.verify('+221771112233', '123456'),
      OtpResult.tooManyAttempts,
    );
  });

  test('un réseau coupé remonte, il ne se déguise pas en mauvais code', () {
    // « Code incorrect » faisait retaper le bon code, indéfiniment, à
    // quelqu'un qui avait simplement perdu le réseau.
    final StagingAuthService auth = _auth(_Fixed(0), tokens);
    addTearDown(auth.dispose);

    expect(
      () => auth.verify('+221771112233', '123456'),
      throwsA(isA<DioException>()),
    );
  });

  test('une panne serveur remonte aussi', () {
    final StagingAuthService auth = _auth(_Fixed(500), tokens);
    addTearDown(auth.dispose);

    expect(
      () => auth.verify('+221771112233', '123456'),
      throwsA(isA<DioException>()),
    );
  });

  test('fermer la session efface les jetons avant de l\'annoncer', () async {
    await tokens.save(accessToken: 'a', refreshToken: 'r', identity: '+221');
    final StagingAuthService auth = _auth(_Fixed(500), tokens);
    addTearDown(auth.dispose);

    String? tokenWhenNotified;
    auth.addListener(() => tokenWhenNotified = tokens.accessToken);

    await auth.signOut();

    // En `unawaited`, l'écran suivant se reconstruisait pendant que le jeton
    // était encore lisible.
    expect(tokenWhenNotified, isNull);
    expect(tokens.refreshToken, isNull);
    expect(auth.current, isNull);
  });
}
