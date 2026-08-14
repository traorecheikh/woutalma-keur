import 'dart:async';

import 'package:dio/dio.dart';
import 'package:woutalma_keur/app/data/services/token_store.dart';

/// Porte le jeton de session, et le renouvelle une fois quand il a expiré.
///
/// Écrit à la main plutôt que via le `BearerAuthInterceptor` du client généré :
/// la source du jeton reste un endroit unique et évident, indépendant du nom
/// que le générateur a donné au schéma de sécurité OpenAPI.
class DioAuthInterceptor extends Interceptor {
  DioAuthInterceptor({
    required TokenStore tokens,
    required String baseUrl,
    required BaseOptions options,
    required void Function() onSessionExpired,
    Dio? refreshClient,
  }) : _tokens = tokens,
       _onSessionExpired = onSessionExpired,
       // Client séparé, volontairement **sans** cet intercepteur : un
       // rafraîchissement passé par la même pile retomberait sur son propre
       // 401 et se rappellerait indéfiniment.
       _refresh = refreshClient ?? Dio(options.copyWith(baseUrl: baseUrl));

  static const String _retriedFlag = 'wk.retriedAfterRefresh';

  final TokenStore _tokens;
  final Dio _refresh;
  final void Function() _onSessionExpired;

  /// Garde de vol unique : dix requêtes qui prennent 401 en même temps ne
  /// doivent produire qu'un seul appel à `/auth/refresh`.
  Future<bool>? _inFlight;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _tokens.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    final bool alreadyRetried = request.extra[_retriedFlag] == true;

    if (err.response?.statusCode != 401 ||
        alreadyRetried ||
        _tokens.refreshToken == null) {
      if (err.response?.statusCode == 401 && !alreadyRetried) {
        // Rien à renouveler : la session est finie.
        await _tokens.clear();
        _onSessionExpired();
      }
      handler.next(err);
      return;
    }

    final bool renewed = await (_inFlight ??= _renew().whenComplete(() {
      _inFlight = null;
    }));

    if (!renewed) {
      handler.next(err);
      return;
    }

    try {
      // Une seule reprise par requête. Une reprise non bornée contre un
      // serveur qui répond 401 est une boucle infinie.
      request.extra[_retriedFlag] = true;
      request.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
      final Response<dynamic> response = await _refresh.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _renew() async {
    try {
      final Response<dynamic> response = await _refresh.post<dynamic>(
        '/auth/refresh',
        data: <String, String>{'refreshToken': _tokens.refreshToken!},
      );
      final Object? body = response.data;
      if (body is! Map || body['accessToken'] is! String) {
        throw StateError('Réponse de rafraîchissement inattendue');
      }
      await _tokens.save(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String?,
      );
      return true;
    } catch (_) {
      await _tokens.clear();
      _onSessionExpired();
      return false;
    }
  }
}
