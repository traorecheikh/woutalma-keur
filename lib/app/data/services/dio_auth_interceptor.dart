import 'package:dio/dio.dart';
import 'package:woutalma_keur/app/data/services/token_store.dart';

/// Attaches the session token to every outgoing request. Kept as a plain
/// custom interceptor rather than the generated client's built-in
/// `BearerAuthInterceptor`/`setBearerAuth` so the token source (TokenStore)
/// stays a single, obvious place, not tied to the OpenAPI security-scheme
/// name the generator happened to pick.
class DioAuthInterceptor extends Interceptor {
  DioAuthInterceptor(this._tokens);

  final TokenStore _tokens;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _tokens.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
