import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/data/services/property_photo_uploader.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(path: '/properties'),
  response: Response<Object?>(
    requestOptions: RequestOptions(path: '/properties'),
    statusCode: code,
  ),
);

void main() {
  test('une requête sans réponse est un problème de réseau', () {
    final DioException offline = DioException(
      requestOptions: RequestOptions(path: '/properties'),
      type: DioExceptionType.connectionError,
    );

    expect(brokerFailure(offline), BrokerFailure.network);
    expect(brokerFailure(offline).screen, WkFailure.network);
  });

  test('les refus du serveur ne se ressemblent pas', () {
    // « Cause non identifiée » était exactement le mauvais message pour les
    // trois seuls échecs qu'un courtier peut corriger lui-même.
    expect(brokerFailure(_status(400)), BrokerFailure.rejected);
    expect(brokerFailure(_status(401)), BrokerFailure.sessionExpired);
    expect(brokerFailure(_status(403)), BrokerFailure.sessionExpired);
    expect(brokerFailure(_status(404)), BrokerFailure.notFound);
    expect(brokerFailure(_status(413)), BrokerFailure.photoTooLarge);
    expect(brokerFailure(_status(500)), BrokerFailure.unknown);
  });

  test('un refus décidé avant l\'envoi garde sa cause', () {
    expect(
      brokerFailure(const PhotoUploadFailed(PhotoUploadRefusal.tooLarge)),
      BrokerFailure.photoTooLarge,
    );
    expect(
      brokerFailure(const PhotoUploadFailed(PhotoUploadRefusal.tooMany)),
      BrokerFailure.photoTooMany,
    );
    expect(
      brokerFailure(
        const VoiceNoteUploadFailed(VoiceNoteUploadRefusal.tooLarge),
      ),
      BrokerFailure.voiceTooLarge,
    );
    expect(
      brokerFailure(
        const VoiceNoteUploadFailed(VoiceNoteUploadRefusal.unsupportedType),
      ),
      BrokerFailure.voiceUnsupported,
    );
  });

  test('les états ne connaissent que les causes qu\'ils savent porter', () {
    expect(BrokerFailure.notFound.screen, WkFailure.notFound);
    // Les causes fines n'ont pas d'équivalent dans WkFailure : elles voyagent
    // à côté, sinon l'écran les afficherait comme « Cause non identifiée ».
    expect(BrokerFailure.photoTooLarge.screen, WkFailure.unknown);
    expect(BrokerFailure.sessionExpired.screen, WkFailure.unknown);
  });
}
