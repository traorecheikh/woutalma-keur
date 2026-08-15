import 'package:dio/dio.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';

/// Traduit une exception de dépôt en cause d'échec affichable.
///
/// Même règle que `HistoryViewModel` côté client : une requête qui n'a jamais
/// obtenu de réponse est un problème de réseau — le seul message juste pour
/// quelqu'un dans un tunnel — et tout le reste reste [WkFailure.unknown]
/// plutôt que de mentir sur la cause.
///
/// Vit ici parce que les six modèles courtier en ont besoin ; ce n'est pas une
/// primitive de design système, elle ne remonte donc pas dans `shared/`.
WkFailure brokerFailure(Object error) {
  if (error is DioException) {
    return error.response == null ? WkFailure.network : WkFailure.unknown;
  }
  return WkFailure.unknown;
}
