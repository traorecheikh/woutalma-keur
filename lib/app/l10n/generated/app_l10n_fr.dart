// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Woutalma Keur';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonUndo => 'Annuler';

  @override
  String get commonChoose => 'Choisir';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonUnspecified => 'Non précisé';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonListen => 'Écouter';

  @override
  String get stateLoading => 'Un instant…';

  @override
  String get stateEmptyTitle => 'Rien à afficher';

  @override
  String get stateEmptyBody => 'Il n\'y a encore rien ici.';

  @override
  String get stateErrorTitle => 'Ça n\'a pas marché';

  @override
  String get stateErrorBody => 'Réessayez dans un instant.';

  @override
  String get failureLocalStorage =>
      'Les données de l\'application ne s\'ouvrent pas.';

  @override
  String get failureSeed =>
      'Les données de démonstration sont incomplètes. Réinitialisez le mode démo.';

  @override
  String get failurePermission =>
      'Il manque une autorisation. Ouvrez les réglages du téléphone.';

  @override
  String get failureNotFound => 'Cette fiche n\'existe plus.';

  @override
  String get failureNetwork =>
      'Pas de connexion. Réessayez quand le réseau revient.';

  @override
  String get failureUnknown => 'Ça n\'a pas marché.';

  @override
  String offlineCached(String when) {
    return 'Hors ligne. Informations enregistrées $when.';
  }

  @override
  String get offlineJustNow => 'à l\'instant';

  @override
  String get offlineUnknownDate => 'à une date inconnue';

  @override
  String get offlineCacheUnavailable =>
      'Pas de copie hors ligne sur ce téléphone : il faut du réseau.';

  @override
  String get sessionExpired => 'Session terminée, reconnectez-vous.';

  @override
  String offlineMinutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String offlineHoursAgo(int count) {
    return 'il y a $count h';
  }

  @override
  String offlineDaysAgo(int count) {
    return 'il y a $count j';
  }

  @override
  String get authFailed =>
      'Connexion impossible. Vérifiez le réseau et réessayez.';

  @override
  String get settingsSignOut => 'Me déconnecter';

  @override
  String get settingsSignOutTitle => 'Fermer la session ?';

  @override
  String get settingsSignOutBody =>
      'Vos contacts et vos avis restent enregistrés. Il faudra vous identifier à nouveau pour contacter un courtier.';

  @override
  String get authSmsUnavailable =>
      'Le code par SMS n\'est pas disponible dans cette version.';

  @override
  String get authGoogleUnavailable =>
      'La connexion Google n\'est pas configurée sur ce serveur.';

  @override
  String get authStagingClosed =>
      'Ce serveur n\'accepte pas la connexion de recette.';

  @override
  String get authStagingAsBroker => 'Ouvrir un espace courtier';

  @override
  String get authStagingAsBrokerHelp =>
      'Recette uniquement. Crée un profil courtier vide rattaché à ce numéro.';

  @override
  String get backendWakingUp => 'Le service se réveille, quelques secondes…';

  @override
  String get brokerSignInRequiredTitle => 'Espace courtier';

  @override
  String get brokerSignInRequiredHeading => 'Connexion nécessaire';

  @override
  String get brokerSignInRequiredBody =>
      'Connectez-vous avec le compte de votre profil courtier pour gérer vos biens.';

  @override
  String get brokerSignInRequiredAction => 'Se connecter';

  @override
  String get voiceSearch => 'Chercher en parlant';

  @override
  String get exploreSearchHint => 'Quartier, courtier ou bien';

  @override
  String get tabExplore => 'Explorer';

  @override
  String get tabContacts => 'Contacts';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabBrokerProperties => 'Biens';

  @override
  String get exploreSearchTitle => 'Rechercher';

  @override
  String get exploreSearchOpen =>
      'Rechercher un quartier, un courtier ou un bien';

  @override
  String exploreSearchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String get exploreSearchNoMatch =>
      'Aucun courtier ni bien ne correspond. Essayez un autre mot, ou l\'une des propositions.';

  @override
  String exploreSearchSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voir les $count résultats',
      one: 'Voir 1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get exploreSegmentBrokers => 'Courtiers';

  @override
  String get exploreSegmentProperties => 'Biens';

  @override
  String get exploreFilters => 'Filtres';

  @override
  String exploreResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get exploreEmptyTitle => 'Personne dans cette zone';

  @override
  String get exploreEmptyBody => 'Élargissez la zone ou enlevez un filtre.';

  @override
  String get exploreClearFilters => 'Enlever les filtres';

  @override
  String get exploreNearYou => 'Près de vous';

  @override
  String get badgeVerified => 'Vérifié';

  @override
  String get badgePinned => 'Mis en avant';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusReserved => 'Réservé';

  @override
  String get statusClosed => 'Vendu ou loué';

  @override
  String distanceMeters(int meters) {
    return '$meters m';
  }

  @override
  String distanceKilometers(String km) {
    return '$km km';
  }

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '1 avis',
      zero: 'Aucun avis',
    );
    return '$_temp0';
  }

  @override
  String propertyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count biens',
      one: '1 bien',
      zero: 'Aucun bien',
    );
    return '$_temp0';
  }

  @override
  String get ratingNone => 'Pas encore noté';

  @override
  String get transactionRent => 'À louer';

  @override
  String get transactionSale => 'À vendre';

  @override
  String get kindApartment => 'Appartement';

  @override
  String get kindHouse => 'Maison';

  @override
  String get kindLand => 'Terrain';

  @override
  String get kindStudio => 'Studio';

  @override
  String get kindRoom => 'Chambre';

  @override
  String priceRent(String price) {
    return '$price F/mois';
  }

  @override
  String priceSale(String price) {
    return '$price F';
  }

  @override
  String surfaceValue(int surface) {
    return '$surface m²';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces',
      one: '1 pièce',
    );
    return '$_temp0';
  }

  @override
  String get brokerCoverage => 'Zone couverte';

  @override
  String get brokerProperties => 'Biens proposés';

  @override
  String get brokerReviews => 'Avis récents';

  @override
  String get brokerNoReviews => 'Personne n\'a encore laissé d\'avis.';

  @override
  String get brokerNoProperties => 'Aucun bien proposé pour le moment.';

  @override
  String brokerResponseRate(int percent) {
    return 'Répond à $percent % des demandes';
  }

  @override
  String get brokerProfileEditorTitle => 'Modifier mon profil';

  @override
  String get brokerProfileEditorSave => 'Enregistrer';

  @override
  String get brokerProfileEditorSaved => 'Profil enregistré';

  @override
  String get brokerProfileEditorNotEditable =>
      'Le statut de vérification et la mise en avant ne se modifient pas ici.';

  @override
  String get brokerProfileEditorLeaveTitle => 'Quitter sans enregistrer ?';

  @override
  String get brokerProfileEditorLeaveBody =>
      'Vos modifications de profil seront perdues.';

  @override
  String get brokerProfileEditorLeaveConfirm => 'Quitter';

  @override
  String get brokerProfileTitle => 'Profil';

  @override
  String get brokerReply => 'Réponse du courtier';

  @override
  String get contactAction => 'Contacter';

  @override
  String get contactSheetTitle => 'Comment le joindre ?';

  @override
  String get contactCall => 'Appeler';

  @override
  String get contactSms => 'Envoyer un SMS';

  @override
  String get contactWhatsapp => 'Écrire sur WhatsApp';

  @override
  String get contactLogged => 'Contact enregistré';

  @override
  String get contactNotLogged => 'Appel lancé, non enregistré';

  @override
  String get contactWhatsappMissing =>
      'WhatsApp n\'est pas installé. Appelez plutôt.';

  @override
  String get contactSmsMissing => 'Aucune application de SMS. Appelez plutôt.';

  @override
  String get contactCallMissing => 'Impossible d\'ouvrir le téléphone.';

  @override
  String get contactPhoneCopyHint => 'Appuyez longuement pour copier le numéro';

  @override
  String get contactPhoneCopied => 'Numéro copié';

  @override
  String get contactGateTitle => 'Pour contacter, entrez votre numéro';

  @override
  String get contactGateBody =>
      'Votre numéro sert à retrouver vos contacts et à laisser un avis.';

  @override
  String get contactGateSignIn => 'Entrer mon numéro';

  @override
  String get contactGateCallAnyway => 'Appeler sans compte';

  @override
  String get outcomeTitle => 'Avez-vous pu lui parler ?';

  @override
  String get outcomeReached => 'Oui, on a échangé';

  @override
  String get outcomeNoAnswer => 'Pas de réponse';

  @override
  String get outcomeLater => 'Plus tard';

  @override
  String get historyTitle => 'Mes contacts';

  @override
  String get historyEmptyTitle => 'Aucun contact';

  @override
  String get historyEmptyBody =>
      'Les courtiers que vous joignez apparaîtront ici.';

  @override
  String get historySearch => 'Chercher un courtier';

  @override
  String get historyChannelCall => 'Appel';

  @override
  String get historyChannelSms => 'SMS';

  @override
  String get historyChannelWhatsapp => 'WhatsApp';

  @override
  String get historyChannelVoice => 'Message vocal';

  @override
  String historyChannelWhen(String channel, String date) {
    return '$channel · $date';
  }

  @override
  String get historyReviewCta => 'Donner un avis';

  @override
  String get historyReviewDone => 'Avis envoyé';

  @override
  String get historyCallAgain => 'Rappeler';

  @override
  String get historySignedOutTitle => 'Identifiez-vous pour voir vos contacts';

  @override
  String get historySignedOutAction => 'Entrer mon numéro';

  @override
  String get reviewTitle => 'Votre avis';

  @override
  String get reviewRatingQuestion => 'Comment s\'est passé l\'échange ?';

  @override
  String get reviewCriteriaResponsiveness => 'Réactivité';

  @override
  String get reviewCriteriaAccuracy => 'Informations exactes';

  @override
  String get reviewCriteriaCourtesy => 'Courtoisie';

  @override
  String get reviewCommentLabel => 'Commentaire';

  @override
  String get reviewCommentHint => 'Facultatif';

  @override
  String get reviewSubmit => 'Envoyer l\'avis';

  @override
  String get reviewMissingRating => 'Choisissez d\'abord une note';

  @override
  String get reviewSent => 'Avis envoyé, en attente de modération';

  @override
  String reviewStarLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionData => 'Données';

  @override
  String get settingsSectionFeedback => 'Retours';

  @override
  String get settingsSectionDeveloper => 'Développement';

  @override
  String get settingsDemoMode => 'Mode démonstration';

  @override
  String get settingsDemoModeOn => 'Données d\'exemple chargées';

  @override
  String get settingsDemoModeOff => 'Base vide, parcours réel';

  @override
  String get settingsDemoEnableTitle => 'Charger les données d\'exemple ?';

  @override
  String get settingsDemoDisableTitle => 'Repartir d\'une base vide ?';

  @override
  String settingsDemoImpact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments seront supprimés.',
      one: '1 élément sera supprimé.',
      zero: 'Rien ne sera supprimé.',
    );
    return '$_temp0';
  }

  @override
  String get settingsDemoConfirm => 'Remplacer les données';

  @override
  String get settingsDemoDone => 'Données remplacées';

  @override
  String get settingsSounds => 'Sons';

  @override
  String get settingsHaptics => 'Vibrations';

  @override
  String get settingsGuidedVoice => 'Guidage vocal';

  @override
  String get settingsGuidedVoiceSuppressed =>
      'Désactivé pendant qu\'un lecteur d\'écran est actif';

  @override
  String get settingsCatalog => 'Catalogue des composants';

  @override
  String get settingsSectionRole => 'Rôle';

  @override
  String get roleClient => 'Je cherche un logement';

  @override
  String get roleBroker => 'Je propose des biens';

  @override
  String get brokerPropertiesTitle => 'Mes biens';

  @override
  String get brokerPropertiesEmptyTitle => 'Aucun bien publié';

  @override
  String get brokerPropertiesEmptyBody =>
      'Ajoutez un bien pour apparaître dans les recherches.';

  @override
  String get propertyAdd => 'Ajouter un bien';

  @override
  String get propertyAddAnother => 'Ajouter un autre bien';

  @override
  String get propertyEditorNew => 'Nouveau bien';

  @override
  String get propertyEditorEdit => 'Modifier le bien';

  @override
  String propertyEditorStep(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get propertyEditorStepKind => 'Le bien et son quartier';

  @override
  String get propertyEditorStepDetails => 'Infos essentielles';

  @override
  String get propertyEditorStepMedia => 'Photos et publication';

  @override
  String get propertyTextSuggested =>
      'Écrit d\'après vos réponses. Corrigez-le si besoin.';

  @override
  String propertyTitleFromKind(String kind, String area) {
    return '$kind à $area';
  }

  @override
  String propertyTitleFromRooms(String kind, String rooms, String area) {
    return '$kind $rooms à $area';
  }

  @override
  String get propertyEditorNext => 'Suivant';

  @override
  String get propertySave => 'Publier le bien';

  @override
  String get propertySaved => 'Bien publié';

  @override
  String get propertyDelete => 'Supprimer ce bien';

  @override
  String propertyDeleteTitle(String title) {
    return 'Supprimer « $title » ?';
  }

  @override
  String get propertyDeleteBody =>
      'Ce bien ne sera plus proposé aux clients. Il restera dans votre liste, marqué « Vendu ou loué ».';

  @override
  String get propertyDeleted => 'Bien retiré des recherches';

  @override
  String get propertyStatusChange => 'Changer le statut';

  @override
  String get propertyStatusImpactClosed =>
      'Ce bien disparaîtra des recherches côté client.';

  @override
  String get propertyStatusImpactVisible =>
      'Ce bien restera visible dans les recherches.';

  @override
  String get fieldTitle => 'Titre';

  @override
  String get fieldPrice => 'Prix';

  @override
  String get fieldSurface => 'Surface en m²';

  @override
  String get fieldSurfaceChoice => 'Surface';

  @override
  String get fieldRooms => 'Nombre de pièces';

  @override
  String get fieldNeighbourhood => 'Quartier';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldKind => 'Type de bien';

  @override
  String get fieldTransaction => 'Louer ou vendre';

  @override
  String get fieldStatus => 'Statut';

  @override
  String get fieldBrokerKind => 'Type de profil';

  @override
  String get brokerKindIndividual => 'Courtier indépendant';

  @override
  String get brokerKindAgency => 'Agence';

  @override
  String get fieldBrokerName => 'Nom affiché';

  @override
  String get fieldBrokerNameHint => 'Moussa Diop';

  @override
  String get fieldBrokerPhone => 'Téléphone';

  @override
  String get fieldBrokerWhatsapp => 'WhatsApp';

  @override
  String get fieldBrokerWhatsappHelper =>
      'Laissez vide si vous n\'avez pas WhatsApp.';

  @override
  String get fieldBrokerCoverage => 'Zone couverte';

  @override
  String get fieldBrokerCoverageHint => 'Yoff, Ngor';

  @override
  String get fieldBrokerCoverageHelper =>
      'Séparez les quartiers par une virgule.';

  @override
  String get validationRequired => 'Ce champ est nécessaire';

  @override
  String get validationPositiveNumber =>
      'Indiquez un nombre plus grand que zéro';

  @override
  String get validationFixFirst => 'Corrigez le premier champ signalé';

  @override
  String get filtersTitle => 'Filtres';

  @override
  String get filtersTransaction => 'Louer ou acheter';

  @override
  String get filtersKind => 'Type de bien';

  @override
  String get filtersMaxPrice => 'Prix maximum';

  @override
  String get filtersRadius => 'Distance';

  @override
  String get filtersAny => 'Peu importe';

  @override
  String filtersApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voir $count résultats',
      one: 'Voir 1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get filtersApplyUnknown => 'Appliquer les filtres';

  @override
  String get filtersCountUnavailable =>
      'Le nombre de résultats n\'a pas pu être compté.';

  @override
  String get filtersReset => 'Tout enlever';

  @override
  String filtersRadiusValue(int km) {
    return '$km km autour de moi';
  }

  @override
  String filtersPriceValue(String price) {
    return 'Jusqu\'à $price F';
  }

  @override
  String filtersActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtres',
      one: '1 filtre',
      zero: 'Filtres',
    );
    return '$_temp0';
  }

  @override
  String get voiceListening => 'Parlez maintenant';

  @override
  String get voiceProcessing => 'Un instant, je comprends…';

  @override
  String get voiceHeard => 'J\'ai compris :';

  @override
  String get voiceApply => 'Chercher ça';

  @override
  String get voiceRetry => 'Réessayer';

  @override
  String get voiceNotUnderstood => 'Je n\'ai pas compris';

  @override
  String get voiceNotUnderstoodHelp =>
      'Dites par exemple : maison à louer près d\'ici.';

  @override
  String get voiceSimulated =>
      'Reconnaissance simulée : le moteur réel arrive plus tard.';

  @override
  String get brokerHomeTitle => 'Mon activité';

  @override
  String get brokerHomeTab => 'Accueil';

  @override
  String get brokerHomeNext => 'À traiter maintenant';

  @override
  String get brokerHomeNothing => 'Rien à traiter pour le moment.';

  @override
  String get brokerHomeContactsLabel => 'Contacts reçus';

  @override
  String get brokerHomeOverview => 'Résumé';

  @override
  String brokerStatVisible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count biens visibles',
      one: '1 bien visible',
      zero: 'Aucun bien visible',
    );
    return '$_temp0';
  }

  @override
  String brokerStatHidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count biens clos',
      one: '1 bien clos',
      zero: 'Aucun bien clos',
    );
    return '$_temp0';
  }

  @override
  String brokerStatContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts reçus',
      one: '1 contact reçu',
      zero: 'Aucun contact reçu',
    );
    return '$_temp0';
  }

  @override
  String brokerStatReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis publiés',
      one: '1 avis publié',
      zero: 'Aucun avis',
    );
    return '$_temp0';
  }

  @override
  String brokerPendingReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis en modération',
      one: '1 avis en modération',
    );
    return '$_temp0';
  }

  @override
  String get brokerVerificationPending => 'Vérification en attente';

  @override
  String get brokerVerificationMissing => 'Profil non vérifié';

  @override
  String get brokerReviewsTitle => 'Avis reçus';

  @override
  String get brokerReviewsEmptyTitle => 'Aucun avis pour le moment';

  @override
  String get brokerReviewsEmptyBody =>
      'Les clients qui vous ont joint pourront vous noter.';

  @override
  String get reviewModerationPending => 'En modération';

  @override
  String get reviewModerationPublished => 'Publié';

  @override
  String get reviewModerationRejected => 'Refusé';

  @override
  String get reviewReplyAction => 'Répondre';

  @override
  String get reviewReplyLabel => 'Votre réponse';

  @override
  String get reviewReplyHint => 'Visible par tous';

  @override
  String get reviewReplySend => 'Publier la réponse';

  @override
  String get reviewReplySent => 'Réponse publiée';

  @override
  String get reviewReportAction => 'Signaler';

  @override
  String get reviewReportTitle => 'Signaler cet avis ?';

  @override
  String get reviewReportBody =>
      'Un modérateur le relira. L\'avis reste visible en attendant.';

  @override
  String get reviewReported => 'Avis signalé';

  @override
  String get reviewCannotEdit => 'Vous ne pouvez pas modifier un avis reçu.';

  @override
  String get propertyPreviewTitle => 'Aperçu du bien';

  @override
  String get propertyPreviewNotice => 'Voici ce que voient les clients.';

  @override
  String get propertyPreviewContactDisabled =>
      'Aperçu : le bouton est celui des clients, il ne fait rien ici.';

  @override
  String get propertyBrokerLabel => 'Proposé par';

  @override
  String get propertyBrokerMissing => 'Ce courtier n\'est plus joignable.';

  @override
  String get propertyShare => 'Envoyer à un proche';

  @override
  String propertyShareText(
    String title,
    String price,
    String neighbourhood,
    String phone,
  ) {
    return '$title — $price à $neighbourhood. Courtier : $phone';
  }

  @override
  String get propertyStatusTitle => 'Statut du bien';

  @override
  String get propertyStatusChanged => 'Statut mis à jour';

  @override
  String get authPhoneTitle => 'Votre numéro';

  @override
  String get authPhoneReasonContact => 'Pour garder la trace de vos contacts.';

  @override
  String get authPhoneReasonBroker =>
      'Pour retrouver vos biens sur n\'importe quel téléphone.';

  @override
  String get authPhoneLabel => 'Numéro de téléphone';

  @override
  String get authPhoneContinue => 'Recevoir le code';

  @override
  String get authPhoneInvalid => 'Ce numéro n\'est pas complet';

  @override
  String get authPhoneCountrySenegal => 'Sénégal +221';

  @override
  String get authGoogleContinue => 'Continuer avec Google';

  @override
  String get authPhoneFallback => 'Ou recevez un code par SMS';

  @override
  String get authOtpTitle => 'Code reçu par SMS';

  @override
  String authOtpSentTo(String phone) {
    return 'Envoyé au $phone';
  }

  @override
  String get authOtpWrong => 'Code incorrect, réessayez';

  @override
  String get authOtpCodeLabel => 'Code SMS';

  @override
  String get authOtpCodeHint => '6 chiffres';

  @override
  String get authOtpChecking => 'Vérification du code';

  @override
  String get authOtpResend => 'Renvoyer le code';

  @override
  String authOtpResendIn(int seconds) {
    return 'Renvoyer dans $seconds s';
  }

  @override
  String get authOtpChangeNumber => 'Modifier le numéro';

  @override
  String authOtpSimulated(String code) {
    return 'Code de démonstration : $code';
  }

  @override
  String get authSignedIn => 'Vous êtes identifié';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsSignIn => 'M\'identifier';

  @override
  String settingsSignedInAs(String phone) {
    return 'Identifié avec le $phone';
  }

  @override
  String get brokerActivityTitle => 'Consultations et contacts';

  @override
  String get brokerActivityTab => 'Activité';

  @override
  String get brokerActivityEmptyTitle => 'Aucune activité';

  @override
  String get brokerActivityEmptyBody => 'Les contacts reçus apparaîtront ici.';

  @override
  String brokerActivityAbout(String title) {
    return 'À propos de : $title';
  }

  @override
  String get brokerActivityOutcomeReached => 'Échange confirmé';

  @override
  String get brokerActivityOutcomeAttempted => 'Sans suite déclarée';

  @override
  String get brokerActivityOutcomeNoAnswer => 'Pas de réponse';

  @override
  String get brokerVerificationTitle => 'Vérification';

  @override
  String get brokerVerificationExplain =>
      'Un profil vérifié inspire confiance et remonte dans les résultats.';

  @override
  String get brokerVerificationSubmit => 'Demander la vérification';

  @override
  String get brokerVerificationSent => 'Demande envoyée';

  @override
  String get brokerVerificationNotSent =>
      'La demande n\'a pas été enregistrée. Réessayez.';

  @override
  String get brokerVerificationWaiting =>
      'Un modérateur examine votre demande.';

  @override
  String get authPhoneHint => '77 123 45 67';

  @override
  String get brokerVerificationHowTo =>
      'Envoyez votre demande : un modérateur vérifie votre profil, puis le badge apparaît sur votre fiche.';

  @override
  String get brokerVerificationDone => 'Votre profil est vérifié.';

  @override
  String get brokerVerificationRejected =>
      'Demande refusée. Vous pouvez recommencer.';

  @override
  String get brokerVerificationTagRejected => 'Demande refusée';

  @override
  String get brokerRankingTitle => 'Mon classement';

  @override
  String get brokerRankingExplain =>
      'Voici ce qui fait votre position dans les recherches.';

  @override
  String get brokerRankingRating => 'Note et confiance';

  @override
  String get brokerRankingProximity => 'Proximité du client';

  @override
  String get brokerRankingVolume => 'Nombre d\'avis';

  @override
  String get brokerRankingResponse => 'Taux de réponse';

  @override
  String get brokerRankingVaries =>
      'La proximité change d\'un client à l\'autre : votre position n\'est pas la même pour tout le monde.';

  @override
  String brokerRankingPercent(int percent) {
    return '$percent %';
  }

  @override
  String get locationTitle => 'Où cherchez-vous ?';

  @override
  String get locationShort => 'Quartier';

  @override
  String get locationUseGps => 'Utiliser ma position';

  @override
  String get locationSearchHint => 'Nom du quartier';

  @override
  String get locationRecent => 'Récents';

  @override
  String get locationAll => 'Tous les quartiers';

  @override
  String get locationNone => 'Aucun quartier ne correspond';

  @override
  String get locationDenied =>
      'Position refusée. Choisissez un quartier à la main.';

  @override
  String get locationUnavailable =>
      'Position indisponible. Choisissez un quartier à la main.';

  @override
  String get permissionLocationTitle => 'Trouver ce qui est près de vous';

  @override
  String get permissionLocationBody =>
      'Votre position sert à trier les courtiers du plus proche au plus loin. Elle ne quitte pas le téléphone.';

  @override
  String get permissionContinue => 'Continuer';

  @override
  String get permissionNotNow => 'Pas maintenant';

  @override
  String get permissionOpenSettings => 'Ouvrir les réglages';

  @override
  String get photosLabel => 'Photos';

  @override
  String get photosAdd => 'Ajouter une photo';

  @override
  String get photosSourceTitle => 'D\'où vient la photo ?';

  @override
  String get photosCamera => 'Prendre une photo';

  @override
  String get photosGallery => 'Choisir dans mes images';

  @override
  String get photosRemove => 'Retirer cette photo';

  @override
  String photosLimit(int count) {
    return '$count photos maximum';
  }

  @override
  String photosCount(int used, int max) {
    return '$used sur $max';
  }

  @override
  String photoCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String photosServerLimit(int count) {
    return '$count photos maximum par bien pour l\'instant.';
  }

  @override
  String get photosCompressed =>
      'Les photos sont allégées pour économiser vos données.';

  @override
  String get photosFailed => 'Cette photo n\'a pas pu être ajoutée.';

  @override
  String get viewList => 'Liste';

  @override
  String get viewMap => 'Carte';

  @override
  String get exploreShowMap => 'Carte';

  @override
  String get exploreShowList => 'Liste';

  @override
  String get historyOutcomeQuestion => 'Avez-vous eu cette personne ?';

  @override
  String get historyOutcomeReached => 'Oui, on s\'est parlé';

  @override
  String get historyOutcomeNoAnswer => 'Non, pas de réponse';

  @override
  String get historyNoAnswerNote =>
      'Pas de réponse : on ne note que quelqu\'un à qui on a parlé.';

  @override
  String get mapTilesUnavailable =>
      'Les images de la carte n\'arrivent pas. Les repères et la liste fonctionnent toujours.';

  @override
  String get mapDataWarning =>
      'La carte télécharge des images. En mode léger, restez sur la liste.';

  @override
  String get mapAttribution => '© OpenStreetMap';

  @override
  String get mapBackToList => 'Revenir à la liste';

  @override
  String get catalogTitle => 'Catalogue';

  @override
  String get catalogSubtitle => 'Les composants partagés et tous leurs états.';

  @override
  String get catalogSectionColors => 'Couleurs';

  @override
  String get catalogSectionTypography => 'Typographie';

  @override
  String get catalogSectionSpacing => 'Espacement';

  @override
  String get catalogSectionTouch => 'Cibles tactiles';

  @override
  String get catalogSectionMotion => 'Mouvement';

  @override
  String get catalogMotionReduced =>
      'Mouvement réduit actif : les durées passent à zéro.';

  @override
  String get catalogSectionButtons => 'Boutons';

  @override
  String get catalogSectionInputs => 'Saisie';

  @override
  String get catalogSectionContent => 'Contenu';

  @override
  String get catalogSectionStates => 'États d\'écran';

  @override
  String get catalogSectionOverlays => 'Feuilles et messages';

  @override
  String get catalogStateDisabled => 'Désactivé';

  @override
  String get catalogStateLoading => 'En cours';

  @override
  String get exploreDefaultArea => 'Dakar';

  @override
  String get exploreUnknownPosition => 'Dakar · position inconnue';

  @override
  String get exploreNearbyProperties => 'Près de chez vous';

  @override
  String get exploreTrustedBrokers => 'Courtiers de confiance';

  @override
  String get exploreNewListings => 'Nouveautés';

  @override
  String get exploreSeeAll => 'Voir tout';

  @override
  String get exploreCategoryAll => 'Tout';

  @override
  String get exploreEnableLocationTitle => 'Activer ma position';

  @override
  String get exploreEnableLocationBody =>
      'Pour trier les biens et les courtiers du plus proche au plus loin.';

  @override
  String get exploreChooseArea => 'Choisir un quartier';

  @override
  String get exploreSearchAll => 'Tous les résultats';

  @override
  String get filtersPriceAny => 'Sans limite';

  @override
  String get filtersRadiusAny => 'Toute la ville';

  @override
  String get voiceNoteLabel => 'Message vocal';

  @override
  String get voiceNoteHint =>
      'Décrivez le bien avec vos mots. 45 secondes au plus.';

  @override
  String get voiceNoteRecord => 'Enregistrer un message vocal';

  @override
  String get voiceNoteStop => 'Arrêter';

  @override
  String voiceNoteRecording(int seconds) {
    return 'Enregistrement… $seconds s';
  }

  @override
  String get voiceNoteDelete => 'Supprimer le vocal';

  @override
  String get voiceNoteRedo => 'Réenregistrer';

  @override
  String get voiceNotePlay => 'Écouter';

  @override
  String get voiceNotePause => 'Pause';

  @override
  String get voiceNoteFromBroker => 'Le courtier vous en parle';

  @override
  String get voiceNoteBadge => 'Vocal';

  @override
  String get voiceNotePermissionDenied =>
      'Micro refusé. Autorisez-le dans les réglages du téléphone pour enregistrer.';

  @override
  String get voiceNoteFailed => 'Le message vocal n\'a pas pu être enregistré.';

  @override
  String get voiceNoteUnavailable => 'Le message vocal n\'a pas pu être lu.';

  @override
  String get voiceNoteTooLarge =>
      'Le message vocal est trop lourd pour être envoyé.';

  @override
  String get voiceNoteReady => 'Message vocal prêt';

  @override
  String get profileVisitor => 'Visiteur';

  @override
  String get profileSignInHint =>
      'Identifiez-vous pour contacter un courtier et retrouver vos contacts.';

  @override
  String get profileRoleClient => 'Client';

  @override
  String get profileRoleBroker => 'Courtier';

  @override
  String get contactSheetHint =>
      'Le contact est noté dans vos contacts pour pouvoir laisser un avis.';

  @override
  String get contactCallHint => 'Appel direct';

  @override
  String get contactWhatsappHint => 'Message ou vocal';

  @override
  String get contactSmsHint => 'Sans internet';

  @override
  String get exploreBrowseAreas => 'Parcourir par quartier';
}
