import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/data/services/property_photo_uploader.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

/// Pourquoi une action courtier n'a pas abouti.
///
/// Plus fin que [WkFailure], qui ne connaît que six causes et rangeait tout le
/// reste dans « Cause non identifiée » — y compris la photo trop lourde, le
/// vocal refusé et la session expirée, c'est-à-dire les trois échecs qu'un
/// courtier peut effectivement corriger.
///
/// Vit ici parce que les six modèles courtier en ont besoin ; ce n'est pas une
/// primitive de design système, elle ne remonte donc pas dans `shared/`.
enum BrokerFailure {
  network,
  sessionExpired,
  rejected,
  notFound,
  photoTooMany,
  photoTooLarge,
  photoUnsupported,
  photoUnreadable,
  voiceTooLarge,
  voiceUnsupported,
  voiceUnreadable,
  unknown;

  /// Ce que `ScreenState`/`MutationState` savent porter. Les causes précises
  /// n'y entrent pas : elles voyagent à côté, via [BrokerFailures].
  WkFailure get screen => switch (this) {
    BrokerFailure.network => WkFailure.network,
    BrokerFailure.notFound => WkFailure.notFound,
    _ => WkFailure.unknown,
  };
}

BrokerFailure brokerFailure(Object error) {
  if (error is PhotoUploadFailed) {
    return switch (error.refusal) {
      PhotoUploadRefusal.tooMany => BrokerFailure.photoTooMany,
      PhotoUploadRefusal.tooLarge => BrokerFailure.photoTooLarge,
      PhotoUploadRefusal.unsupportedType => BrokerFailure.photoUnsupported,
      PhotoUploadRefusal.unreadable => BrokerFailure.photoUnreadable,
    };
  }
  if (error is VoiceNoteUploadFailed) {
    return switch (error.refusal) {
      VoiceNoteUploadRefusal.tooLarge => BrokerFailure.voiceTooLarge,
      VoiceNoteUploadRefusal.unsupportedType => BrokerFailure.voiceUnsupported,
      VoiceNoteUploadRefusal.unreadable => BrokerFailure.voiceUnreadable,
    };
  }
  if (error is! DioException) {
    return BrokerFailure.unknown;
  }
  // Une requête qui n'a jamais obtenu de réponse est un problème de réseau —
  // le seul message juste pour quelqu'un dans un tunnel.
  final int? status = error.response?.statusCode;
  if (status == null) {
    return BrokerFailure.network;
  }
  return switch (status) {
    400 || 422 => BrokerFailure.rejected,
    401 || 403 => BrokerFailure.sessionExpired,
    404 => BrokerFailure.notFound,
    413 => BrokerFailure.photoTooLarge,
    _ => BrokerFailure.unknown,
  };
}

String brokerFailureText(AppL10n l, BrokerFailure failure) => switch (failure) {
  BrokerFailure.network => l.failureNetwork,
  BrokerFailure.sessionExpired => l.failureSessionExpired,
  BrokerFailure.rejected => l.failureRejected,
  BrokerFailure.notFound => l.failureNotFound,
  BrokerFailure.photoTooMany => l.photosServerLimit(
    const PhotoConstraints().maxPerProperty,
  ),
  BrokerFailure.photoTooLarge => l.photoTooLarge,
  BrokerFailure.photoUnsupported => l.photoUnsupported,
  BrokerFailure.photoUnreadable => l.photosFailed,
  BrokerFailure.voiceTooLarge => l.voiceNoteTooLarge,
  BrokerFailure.voiceUnsupported => l.voiceNoteUnsupported,
  BrokerFailure.voiceUnreadable => l.voiceNoteFailed,
  BrokerFailure.unknown => l.failureUnknown,
};

AppState brokerFailureState(
  BuildContext context,
  BrokerFailure failure, {
  VoidCallback? onRetry,
}) => AppState(
  kind: failure == BrokerFailure.network
      ? AppStateKind.offline
      : AppStateKind.error,
  title: context.l10n.stateErrorTitle,
  message: brokerFailureText(context.l10n, failure),
  actionLabel: onRetry == null ? null : context.l10n.commonRetry,
  onAction: onRetry,
);

/// Retient la cause précise à côté de l'état.
///
/// `ScreenState`/`MutationState` ne portent qu'un [WkFailure] ; les deux
/// champs sont séparés parce qu'une lecture qui échoue et une écriture qui
/// échoue s'affichent à deux endroits différents et ne doivent pas se
/// remplacer l'une l'autre.
mixin BrokerFailures on ChangeNotifier {
  BrokerFailure _loadFailure = BrokerFailure.unknown;
  BrokerFailure _writeFailure = BrokerFailure.unknown;

  BrokerFailure get loadFailure => _loadFailure;
  BrokerFailure get writeFailure => _writeFailure;

  WkFailure onLoadError(Object error) =>
      (_loadFailure = brokerFailure(error)).screen;

  WkFailure onWriteError(Object error) =>
      (_writeFailure = brokerFailure(error)).screen;
}
