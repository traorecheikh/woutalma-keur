import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Trace des appels réseau, en debug seulement.
///
/// Il n'y en avait aucune : une connexion qui échouait ne laissait rien dans
/// la console, et la seule façon de savoir pourquoi était de rejouer la
/// requête à la main avec curl. Un écran qui dit « Connexion impossible » sans
/// qu'on puisse lire la cause coûte une demi-heure à chaque fois.
///
/// Une ligne par requête, une par réponse, et le corps de l'erreur quand il y
/// en a un — c'est là que le serveur explique son refus. Jamais activé en
/// release : les URL et les entêtes n'ont rien à faire dans les journaux d'un
/// téléphone.
class DioLogInterceptor extends Interceptor {
  const DioLogInterceptor();

  static const String _tag = '[wk-http]';

  /// Entêtes dont la valeur ne doit jamais être imprimée, même en debug : un
  /// journal se colle dans un ticket, et un jeton copié là reste valable.
  static const Set<String> _secretHeaders = <String>{
    'authorization',
    'x-dev-auth-secret',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('$_tag → ${options.method} ${options.uri}');
      final Iterable<String> sent = options.headers.keys
          .map((String key) => key.toLowerCase())
          .where(_secretHeaders.contains);
      if (sent.isNotEmpty) {
        debugPrint('$_tag   auth: ${sent.join(', ')} présent(s)');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '$_tag ← ${response.statusCode} '
        '${response.requestOptions.method} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final int? status = err.response?.statusCode;
      debugPrint(
        '$_tag ✗ ${status ?? err.type.name} '
        '${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      final Object? body = err.response?.data;
      if (body != null) {
        // Le corps d'une erreur porte la raison : « notOwner »,
        // « Invalid dev auth secret », la liste des champs refusés…
        debugPrint('$_tag   $body');
      } else if (err.error != null) {
        debugPrint('$_tag   ${err.error}');
      }
    }
    handler.next(err);
  }
}
