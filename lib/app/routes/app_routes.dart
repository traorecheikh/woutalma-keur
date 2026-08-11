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

  /// B04 — Aperçu public d'un bien.
  static const String propertyPreview = '/broker/properties/preview';

  /// B05 — Consultations et contacts.
  static const String brokerActivity = '/broker/activity';

  /// B07 — Profil public / réglages courtier.
  static const String brokerProfile = '/broker/profile';

  /// B09 — Vérification.
  static const String brokerVerification = '/broker/verification';

  /// B10 — Mon classement.
  static const String brokerRanking = '/broker/ranking';

  /// B06 — Avis reçus.
  static const String brokerReviews = '/broker/reviews';

  /// B03 — Éditeur de bien.
  static const String propertyEditor = '/broker/properties/edit';

  /// G03 — Téléphone.
  static const String authPhone = '/auth/phone';

  /// G04 — Code reçu par SMS.
  static const String authOtp = '/auth/otp';

  /// S01 — Réglages.
  static const String settings = '/settings';

  /// S02 — catalogue des composants, visible en debug ou en mode démo.
  static const String catalog = '/settings/catalog';

  /// C02 — Fiche courtier, poussée depuis Explorer.
  static String brokerPath(String id) => '$explore/brokers/$id';

  /// C03 — Fiche bien, poussée depuis Explorer ou une fiche courtier.
  static String propertyPath(String id) => '$explore/properties/$id';

  /// C05 — Avis, poussé depuis l'historique.
  static String reviewPath(String contactId) => '$contacts/$contactId/review';
}
