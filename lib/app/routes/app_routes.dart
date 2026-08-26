/// Chemins de `docs/UX-FLOWS.md` §10.
///
/// Seuls les chemins réellement implémentés figurent ici. Un chemin déclaré
/// mais sans écran est un mensonge que les liens profonds révèlent au pire
/// moment.
abstract final class AppRoutes {
  /// C01 — Explorer.
  static const String explore = '/client/explorer';

  /// C04 — Mes contacts.
  static const String contacts = '/client/contacts';

  /// C06 — Profil client.
  static const String clientProfile = '/client/profile';

  /// B01 — Mon activité, racine du rôle courtier.
  static const String brokerHome = '/broker/home';

  /// B02 — Mes biens.
  static const String brokerProperties = '/broker/properties';

  /// B03 — Éditeur de bien, en création.
  static const String propertyEditorNew = '/broker/properties/new';

  /// B05 — Consultations et contacts.
  static const String brokerActivity = '/broker/activity';

  /// B07 — Profil public / réglages courtier.
  static const String brokerProfile = '/broker/profile';

  /// B08 — Modifier le profil courtier.
  static const String brokerProfileEdit = '/broker/profile/edit';

  /// B09 — Vérification.
  static const String brokerVerification = '/broker/verification';

  /// B10 — Mon classement.
  static const String brokerRanking = '/broker/ranking';

  /// B06 — Avis reçus.
  static const String brokerReviews = '/broker/reviews';

  /// B04 — Aperçu d'un bien du courtier. Porte l'identifiant : `extra` ne
  /// survit ni à un lien profond ni à la reconstruction d'un état sauvegardé.
  static String propertyPreviewPath(String id) => '$brokerProperties/$id';

  /// B03 — Éditeur de bien, en modification.
  static String propertyEditPath(String id) => '$brokerProperties/$id/edit';

  /// G03 — Téléphone.
  static const String authPhone = '/auth/phone';

  /// G04 — Code reçu par SMS.
  static const String authOtp = '/auth/otp';

  /// S01 — Réglages.
  static const String settings = '/settings';

  /// C02 — Fiche courtier, poussée depuis Explorer.
  static String brokerPath(String id) => '$explore/brokers/$id';

  /// C03 — Fiche bien, poussée depuis Explorer ou une fiche courtier.
  static String propertyPath(String id) => '$explore/properties/$id';

  /// C05 — Avis, poussé depuis l'historique.
  static String reviewPath(String contactId) => '$contacts/$contactId/review';
}
