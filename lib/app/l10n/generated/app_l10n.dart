import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// Nom de l'application. Ne se traduit pas.
  ///
  /// In fr, this message translates to:
  /// **'Woutalma Keur'**
  String get appTitle;

  /// Action de revenir à l'écran précédent.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// Action de fermer une feuille ou un overlay.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// Action de relancer une opération qui a échoué.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// Abandonne l'action en cours sans rien modifier.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// Revient sur une action déjà effectuée, depuis un message transitoire.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonUndo;

  /// Invite d'un champ de sélection encore vide.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get commonChoose;

  /// Action de passer à l'étape suivante.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get commonNext;

  /// Option d'un sélecteur facultatif laissé sans réponse.
  ///
  /// In fr, this message translates to:
  /// **'Non précisé'**
  String get commonUnspecified;

  /// Action destructive courte, dans une ligne de liste.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// Action de modification courte, sur un geste de balayage.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// Action de faire lire l'écran à voix haute.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get commonListen;

  /// Message pendant un chargement de plus de 300 ms.
  ///
  /// In fr, this message translates to:
  /// **'Un instant…'**
  String get stateLoading;

  /// Titre d'un écran sans aucun résultat.
  ///
  /// In fr, this message translates to:
  /// **'Rien à afficher'**
  String get stateEmptyTitle;

  /// Explication courte accompagnant un état vide.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'y a encore rien ici.'**
  String get stateEmptyBody;

  /// Titre d'un état d'erreur récupérable.
  ///
  /// In fr, this message translates to:
  /// **'Ça n\'a pas marché'**
  String get stateErrorTitle;

  /// Explication courte accompagnant un état d'erreur.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez dans un instant.'**
  String get stateErrorBody;

  /// Cause d'erreur : la base locale est indisponible ou corrompue. Dit ce qui se passe, pas un code technique.
  ///
  /// In fr, this message translates to:
  /// **'Les données de l\'application ne s\'ouvrent pas.'**
  String get failureLocalStorage;

  /// Cause d'erreur : le jeu de données de démonstration est invalide.
  ///
  /// In fr, this message translates to:
  /// **'Les données de démonstration sont incomplètes. Réinitialisez le mode démo.'**
  String get failureSeed;

  /// Cause d'erreur : une permission système a été refusée.
  ///
  /// In fr, this message translates to:
  /// **'Il manque une autorisation. Ouvrez les réglages du téléphone.'**
  String get failurePermission;

  /// Cause d'erreur : la donnée demandée par un lien a disparu.
  ///
  /// In fr, this message translates to:
  /// **'Cette fiche n\'existe plus.'**
  String get failureNotFound;

  /// Cause d'erreur : le serveur est injoignable et rien n'est enregistré hors ligne.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Réessayez quand le réseau revient.'**
  String get failureNetwork;

  /// Cause d'erreur non identifiée. Dernier recours.
  ///
  /// In fr, this message translates to:
  /// **'Ça n\'a pas marché.'**
  String get failureUnknown;

  /// Bandeau : le contenu affiché vient de la dernière copie reçue du serveur.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne. Informations enregistrées {when}.'**
  String offlineCached(String when);

  /// Ancienneté d'une copie hors ligne datant de moins d'une minute.
  ///
  /// In fr, this message translates to:
  /// **'à l\'instant'**
  String get offlineJustNow;

  /// Ancienneté d'une copie hors ligne dont la date n'a pas été retrouvée.
  ///
  /// In fr, this message translates to:
  /// **'à une date inconnue'**
  String get offlineUnknownDate;

  /// Bandeau : la base locale n'a pas pu s'ouvrir (disque plein, base abîmée).
  ///
  /// In fr, this message translates to:
  /// **'Pas de copie hors ligne sur ce téléphone : il faut du réseau.'**
  String get offlineCacheUnavailable;

  /// Message après l'expiration d'une session qui n'a pas pu être renouvelée.
  ///
  /// In fr, this message translates to:
  /// **'Session terminée, reconnectez-vous.'**
  String get sessionExpired;

  /// Ancienneté d'une copie hors ligne, en minutes.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} min'**
  String offlineMinutesAgo(int count);

  /// Ancienneté d'une copie hors ligne, en heures.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} h'**
  String offlineHoursAgo(int count);

  /// Ancienneté d'une copie hors ligne, en jours.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} j'**
  String offlineDaysAgo(int count);

  /// Échec d'une tentative de connexion, quel que soit le moyen.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Vérifiez le réseau et réessayez.'**
  String get authFailed;

  /// Oublie l'identité locale. Les données restent.
  ///
  /// In fr, this message translates to:
  /// **'Me déconnecter'**
  String get settingsSignOut;

  /// Titre de la confirmation de déconnexion.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la session ?'**
  String get settingsSignOutTitle;

  /// Conséquence exacte d'une déconnexion, dite avant de la confirmer.
  ///
  /// In fr, this message translates to:
  /// **'Vos contacts et vos avis restent enregistrés. Il faudra vous identifier à nouveau pour contacter un courtier.'**
  String get settingsSignOutBody;

  /// Échec d'identification : le fournisseur OTP n'est pas branché dans ce build.
  ///
  /// In fr, this message translates to:
  /// **'Le code par SMS n\'est pas disponible dans cette version.'**
  String get authSmsUnavailable;

  /// Échec d'identification : le serveur répond 503 faute de client OAuth.
  ///
  /// In fr, this message translates to:
  /// **'La connexion Google n\'est pas configurée sur ce serveur.'**
  String get authGoogleUnavailable;

  /// Échec d'identification : secret de recette absent ou refusé (401/404).
  ///
  /// In fr, this message translates to:
  /// **'Ce serveur n\'accepte pas la connexion de recette.'**
  String get authStagingClosed;

  /// Recette : crée un profil courtier à la connexion.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir un espace courtier'**
  String get authStagingAsBroker;

  /// Précision sous l'interrupteur courtier de recette.
  ///
  /// In fr, this message translates to:
  /// **'Recette uniquement. Crée un profil courtier vide rattaché à ce numéro.'**
  String get authStagingAsBrokerHelp;

  /// Attente longue annoncée pendant le démarrage à froid du serveur.
  ///
  /// In fr, this message translates to:
  /// **'Le service se réveille, quelques secondes…'**
  String get backendWakingUp;

  /// Titre affiché quand on ouvre un écran courtier sans profil courtier.
  ///
  /// In fr, this message translates to:
  /// **'Espace courtier'**
  String get brokerSignInRequiredTitle;

  /// Titre du corps de l'écran courtier verrouillé. La barre du haut nomme déjà l'espace : répéter « Espace courtier » juste en dessous n'apprenait rien.
  ///
  /// In fr, this message translates to:
  /// **'Connexion nécessaire'**
  String get brokerSignInRequiredHeading;

  /// Explication affichée quand aucun profil courtier n'est rattaché au compte.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous avec le compte de votre profil courtier pour gérer vos biens.'**
  String get brokerSignInRequiredBody;

  /// Action menant à l'identification depuis un écran courtier verrouillé.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get brokerSignInRequiredAction;

  /// Bouton micro. Décrit le geste, pas la technologie.
  ///
  /// In fr, this message translates to:
  /// **'Chercher en parlant'**
  String get voiceSearch;

  /// Invite du champ de recherche de C01. Nomme ce qu'on peut chercher.
  ///
  /// In fr, this message translates to:
  /// **'Quartier, courtier ou bien'**
  String get exploreSearchHint;

  /// Onglet client vers C01. Court : un libellé d'onglet partage la largeur avec ses voisins, et doit tenir à ×1.3 sur 320 dp.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get tabExplore;

  /// Onglet client vers C04. Le titre de l'écran, lui, reste « Mes contacts ».
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get tabContacts;

  /// Onglet vers le profil. Le titre de l'écran reste « Réglages ».
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// Onglet courtier vers B02. Le titre de l'écran reste « Mes biens ».
  ///
  /// In fr, this message translates to:
  /// **'Biens'**
  String get tabBrokerProperties;

  /// Titre de l'écran de recherche plein écran ouvert depuis C01.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get exploreSearchTitle;

  /// Étiquette lue par le lecteur d'écran sur la barre de recherche de C01, qui ouvre l'écran de recherche.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un quartier, un courtier ou un bien'**
  String get exploreSearchOpen;

  /// Intertitre entre les complétions et les résultats, dans l'écran de recherche.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 résultat} other{{count} résultats}}'**
  String exploreSearchCount(int count);

  /// Écran de recherche : la requête ne donne rien, on propose de reformuler.
  ///
  /// In fr, this message translates to:
  /// **'Aucun courtier ni bien ne correspond. Essayez un autre mot, ou l\'une des propositions.'**
  String get exploreSearchNoMatch;

  /// Action qui ferme l'écran de recherche et revient aux résultats.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{Voir 1 résultat} other{Voir les {count} résultats}}'**
  String exploreSearchSubmit(int count);

  /// Segment de C01 affichant les courtiers.
  ///
  /// In fr, this message translates to:
  /// **'Courtiers'**
  String get exploreSegmentBrokers;

  /// Segment de C01 affichant les biens.
  ///
  /// In fr, this message translates to:
  /// **'Biens'**
  String get exploreSegmentProperties;

  /// Ouvre la feuille de filtres M01.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get exploreFilters;

  /// Nombre de résultats, annoncé à voix haute après une recherche.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{1 résultat} other{{count} résultats}}'**
  String exploreResults(int count);

  /// Titre de l'état vide de C01.
  ///
  /// In fr, this message translates to:
  /// **'Personne dans cette zone'**
  String get exploreEmptyTitle;

  /// Explication de l'état vide de C01 : dit quoi faire.
  ///
  /// In fr, this message translates to:
  /// **'Élargissez la zone ou enlevez un filtre.'**
  String get exploreEmptyBody;

  /// Action de sortie de l'état vide de C01.
  ///
  /// In fr, this message translates to:
  /// **'Enlever les filtres'**
  String get exploreClearFilters;

  /// Titre de C01 quand la position exacte n'est pas nommée.
  ///
  /// In fr, this message translates to:
  /// **'Près de vous'**
  String get exploreNearYou;

  /// Le profil du courtier a été contrôlé.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get badgeVerified;

  /// Profil sponsorisé. Doit être distinguable d'un bon classement.
  ///
  /// In fr, this message translates to:
  /// **'Mis en avant'**
  String get badgePinned;

  /// Statut d'un bien encore proposé.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get statusAvailable;

  /// Statut d'un bien en cours de réservation.
  ///
  /// In fr, this message translates to:
  /// **'Réservé'**
  String get statusReserved;

  /// Statut d'un bien qui n'est plus proposé.
  ///
  /// In fr, this message translates to:
  /// **'Vendu ou loué'**
  String get statusClosed;

  /// Distance courte, en mètres.
  ///
  /// In fr, this message translates to:
  /// **'{meters} m'**
  String distanceMeters(int meters);

  /// Distance longue, en kilomètres avec une décimale.
  ///
  /// In fr, this message translates to:
  /// **'{km} km'**
  String distanceKilometers(String km);

  /// Volume d'avis affiché à côté de la note.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun avis} =1{1 avis} other{{count} avis}}'**
  String reviewCount(int count);

  /// Nombre de biens proposés par un courtier.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun bien} =1{1 bien} other{{count} biens}}'**
  String propertyCount(int count);

  /// Remplace la note quand aucun avis public n'existe.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore noté'**
  String get ratingNone;

  /// Nature de transaction : location.
  ///
  /// In fr, this message translates to:
  /// **'À louer'**
  String get transactionRent;

  /// Nature de transaction : vente.
  ///
  /// In fr, this message translates to:
  /// **'À vendre'**
  String get transactionSale;

  /// Type de bien.
  ///
  /// In fr, this message translates to:
  /// **'Appartement'**
  String get kindApartment;

  /// Type de bien.
  ///
  /// In fr, this message translates to:
  /// **'Maison'**
  String get kindHouse;

  /// Type de bien.
  ///
  /// In fr, this message translates to:
  /// **'Terrain'**
  String get kindLand;

  /// Type de bien.
  ///
  /// In fr, this message translates to:
  /// **'Studio'**
  String get kindStudio;

  /// Type de bien.
  ///
  /// In fr, this message translates to:
  /// **'Chambre'**
  String get kindRoom;

  /// Loyer mensuel. L'unité est ici parce qu'elle change avec le pays.
  ///
  /// In fr, this message translates to:
  /// **'{price} F/mois'**
  String priceRent(String price);

  /// Prix de vente.
  ///
  /// In fr, this message translates to:
  /// **'{price} F'**
  String priceSale(String price);

  /// Surface d'un bien.
  ///
  /// In fr, this message translates to:
  /// **'{surface} m²'**
  String surfaceValue(int surface);

  /// Nombre de pièces d'un bien.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 pièce} other{{count} pièces}}'**
  String roomCount(int count);

  /// En-tête listant les quartiers où le courtier travaille.
  ///
  /// In fr, this message translates to:
  /// **'Zone couverte'**
  String get brokerCoverage;

  /// Section de C02 listant les biens disponibles du courtier.
  ///
  /// In fr, this message translates to:
  /// **'Biens proposés'**
  String get brokerProperties;

  /// Section de C02 listant les avis publiés.
  ///
  /// In fr, this message translates to:
  /// **'Avis récents'**
  String get brokerReviews;

  /// Remplace la liste d'avis quand elle est vide.
  ///
  /// In fr, this message translates to:
  /// **'Personne n\'a encore laissé d\'avis.'**
  String get brokerNoReviews;

  /// Remplace la liste de biens quand elle est vide.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bien proposé pour le moment.'**
  String get brokerNoProperties;

  /// Taux de réponse du courtier, en clair.
  ///
  /// In fr, this message translates to:
  /// **'Répond à {percent} % des demandes'**
  String brokerResponseRate(int percent);

  /// Titre de B08 et libellé du bouton qui l'ouvre depuis B07.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon profil'**
  String get brokerProfileEditorTitle;

  /// Action principale de B08.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get brokerProfileEditorSave;

  /// Confirmation après enregistrement du profil.
  ///
  /// In fr, this message translates to:
  /// **'Profil enregistré'**
  String get brokerProfileEditorSaved;

  /// Dit ce que l'écran ne change pas, pour ne pas le chercher.
  ///
  /// In fr, this message translates to:
  /// **'Le statut de vérification et la mise en avant ne se modifient pas ici.'**
  String get brokerProfileEditorNotEditable;

  /// Titre de M09 au retour depuis B08 modifié.
  ///
  /// In fr, this message translates to:
  /// **'Quitter sans enregistrer ?'**
  String get brokerProfileEditorLeaveTitle;

  /// Conséquence de quitter B08 sans enregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Vos modifications de profil seront perdues.'**
  String get brokerProfileEditorLeaveBody;

  /// Confirme la sortie de B08 sans enregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get brokerProfileEditorLeaveConfirm;

  /// Titre de B07, profil public du courtier.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get brokerProfileTitle;

  /// Introduit la réponse publique d'un courtier à un avis.
  ///
  /// In fr, this message translates to:
  /// **'Réponse du courtier'**
  String get brokerReply;

  /// Action principale de C02 et C03. Ouvre la feuille M04.
  ///
  /// In fr, this message translates to:
  /// **'Contacter'**
  String get contactAction;

  /// Titre de la feuille de contact M04.
  ///
  /// In fr, this message translates to:
  /// **'Comment le joindre ?'**
  String get contactSheetTitle;

  /// Ouvre le téléphone. Verbe concret, pas « Contacter ».
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get contactCall;

  /// Ouvre la messagerie du téléphone.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un SMS'**
  String get contactSms;

  /// Ouvre WhatsApp. Absent si le courtier n'en a pas.
  ///
  /// In fr, this message translates to:
  /// **'Écrire sur WhatsApp'**
  String get contactWhatsapp;

  /// Confirme que la mise en relation est tracée avant l'ouverture du canal externe.
  ///
  /// In fr, this message translates to:
  /// **'Contact enregistré'**
  String get contactLogged;

  /// Titre de M05, posé au retour d'une application externe.
  ///
  /// In fr, this message translates to:
  /// **'Avez-vous pu lui parler ?'**
  String get outcomeTitle;

  /// Confirme l'échange. C'est la seule porte vers un avis.
  ///
  /// In fr, this message translates to:
  /// **'Oui, on a échangé'**
  String get outcomeReached;

  /// Aucune réponse. Ne produit aucun retour d'échec.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réponse'**
  String get outcomeNoAnswer;

  /// Ferme M05 sans rien décider.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get outcomeLater;

  /// Titre de C04, le journal des mises en relation.
  ///
  /// In fr, this message translates to:
  /// **'Mes contacts'**
  String get historyTitle;

  /// Titre de l'état vide de C04.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact'**
  String get historyEmptyTitle;

  /// Explication de l'état vide de C04.
  ///
  /// In fr, this message translates to:
  /// **'Les courtiers que vous joignez apparaîtront ici.'**
  String get historyEmptyBody;

  /// Action de sortie de l'état vide de C04, vers C01.
  ///
  /// In fr, this message translates to:
  /// **'Chercher un courtier'**
  String get historySearch;

  /// Canal utilisé : téléphone.
  ///
  /// In fr, this message translates to:
  /// **'Appel'**
  String get historyChannelCall;

  /// Canal utilisé : message texte.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get historyChannelSms;

  /// Canal utilisé : WhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get historyChannelWhatsapp;

  /// Canal utilisé : message vocal.
  ///
  /// In fr, this message translates to:
  /// **'Message vocal'**
  String get historyChannelVoice;

  /// Canal de contact suivi de sa date.
  ///
  /// In fr, this message translates to:
  /// **'{channel} · {date}'**
  String historyChannelWhen(String channel, String date);

  /// Ouvre C05 depuis une ligne d'historique éligible.
  ///
  /// In fr, this message translates to:
  /// **'Donner un avis'**
  String get historyReviewCta;

  /// État d'une ligne dont l'avis a déjà été donné.
  ///
  /// In fr, this message translates to:
  /// **'Avis envoyé'**
  String get historyReviewDone;

  /// Recontacte directement depuis l'historique, sans rouvrir la fiche.
  ///
  /// In fr, this message translates to:
  /// **'Rappeler'**
  String get historyCallAgain;

  /// Titre de C05.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis'**
  String get reviewTitle;

  /// Question de la note globale, en langage parlé.
  ///
  /// In fr, this message translates to:
  /// **'Comment s\'est passé l\'échange ?'**
  String get reviewRatingQuestion;

  /// Critère secondaire.
  ///
  /// In fr, this message translates to:
  /// **'Réactivité'**
  String get reviewCriteriaResponsiveness;

  /// Critère secondaire.
  ///
  /// In fr, this message translates to:
  /// **'Informations exactes'**
  String get reviewCriteriaAccuracy;

  /// Critère secondaire.
  ///
  /// In fr, this message translates to:
  /// **'Courtoisie'**
  String get reviewCriteriaCourtesy;

  /// Champ de commentaire facultatif.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get reviewCommentLabel;

  /// Indique que le commentaire n'est pas obligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif'**
  String get reviewCommentHint;

  /// Action principale de C05.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer l\'avis'**
  String get reviewSubmit;

  /// Motif d'indisponibilité de l'envoi. Dit quoi faire.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord une note'**
  String get reviewMissingRating;

  /// Confirmation après envoi. Dit ce qui va se passer ensuite.
  ///
  /// In fr, this message translates to:
  /// **'Avis envoyé, en attente de modération'**
  String get reviewSent;

  /// Libellé sémantique de chaque étoile en saisie.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 étoile} other{{count} étoiles}}'**
  String reviewStarLabel(int count);

  /// Titre de S01.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// Section regroupant mode démo et remise à zéro.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsSectionData;

  /// Section regroupant sons, vibrations et guidage vocal.
  ///
  /// In fr, this message translates to:
  /// **'Retours'**
  String get settingsSectionFeedback;

  /// Section visible en debug ou en mode démo.
  ///
  /// In fr, this message translates to:
  /// **'Développement'**
  String get settingsSectionDeveloper;

  /// Bascule entre données d'exemple et base vide.
  ///
  /// In fr, this message translates to:
  /// **'Mode démonstration'**
  String get settingsDemoMode;

  /// État actuel : le jeu de démonstration est en place.
  ///
  /// In fr, this message translates to:
  /// **'Données d\'exemple chargées'**
  String get settingsDemoModeOn;

  /// État actuel : aucune donnée d'exemple.
  ///
  /// In fr, this message translates to:
  /// **'Base vide, parcours réel'**
  String get settingsDemoModeOff;

  /// Titre de la confirmation M10 avant activation du mode démo.
  ///
  /// In fr, this message translates to:
  /// **'Charger les données d\'exemple ?'**
  String get settingsDemoEnableTitle;

  /// Titre de la confirmation M10 avant désactivation.
  ///
  /// In fr, this message translates to:
  /// **'Repartir d\'une base vide ?'**
  String get settingsDemoDisableTitle;

  /// Conséquence chiffrée de la bascule. Dit exactement ce qui disparaît.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Rien ne sera supprimé.} =1{1 élément sera supprimé.} other{{count} éléments seront supprimés.}}'**
  String settingsDemoImpact(int count);

  /// Action destructive de M10. Nomme ce qu'elle fait.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer les données'**
  String get settingsDemoConfirm;

  /// Confirmation après la bascule de mode.
  ///
  /// In fr, this message translates to:
  /// **'Données remplacées'**
  String get settingsDemoDone;

  /// Active les signaux sonores.
  ///
  /// In fr, this message translates to:
  /// **'Sons'**
  String get settingsSounds;

  /// Active les retours haptiques.
  ///
  /// In fr, this message translates to:
  /// **'Vibrations'**
  String get settingsHaptics;

  /// Fait énoncer les résultats à voix haute.
  ///
  /// In fr, this message translates to:
  /// **'Guidage vocal'**
  String get settingsGuidedVoice;

  /// Explique pourquoi le guidage vocal ne parle pas, plutôt que de le laisser muet sans raison.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé pendant qu\'un lecteur d\'écran est actif'**
  String get settingsGuidedVoiceSuppressed;

  /// Ouvre S02, l'écran de vérification visuelle.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue des composants'**
  String get settingsCatalog;

  /// Section permettant de basculer entre client et courtier.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get settingsSectionRole;

  /// Rôle client, dit à la première personne.
  ///
  /// In fr, this message translates to:
  /// **'Je cherche un logement'**
  String get roleClient;

  /// Rôle courtier ou agence, dit à la première personne.
  ///
  /// In fr, this message translates to:
  /// **'Je propose des biens'**
  String get roleBroker;

  /// Titre de B02.
  ///
  /// In fr, this message translates to:
  /// **'Mes biens'**
  String get brokerPropertiesTitle;

  /// Titre de l'état vide de B02.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bien publié'**
  String get brokerPropertiesEmptyTitle;

  /// Explication de l'état vide de B02 : dit ce que ça change.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un bien pour apparaître dans les recherches.'**
  String get brokerPropertiesEmptyBody;

  /// Action principale de B02.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un bien'**
  String get propertyAdd;

  /// Après publication : repart d'un formulaire pré-rempli des valeurs communes.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un autre bien'**
  String get propertyAddAnother;

  /// Titre de B03 en création.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau bien'**
  String get propertyEditorNew;

  /// Titre de B03 en modification.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le bien'**
  String get propertyEditorEdit;

  /// Annonce de progression dans B03.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} sur {total}'**
  String propertyEditorStep(int current, int total);

  /// Titre de l'étape 1 de B03 : opération, type et quartier, tous au choix.
  ///
  /// In fr, this message translates to:
  /// **'Le bien et son quartier'**
  String get propertyEditorStepKind;

  /// Titre de l'étape 2 de B03.
  ///
  /// In fr, this message translates to:
  /// **'Infos essentielles'**
  String get propertyEditorStepDetails;

  /// Titre de l'étape 3 de B03.
  ///
  /// In fr, this message translates to:
  /// **'Photos et publication'**
  String get propertyEditorStepMedia;

  /// Signale un titre ou une description proposés par l'écran, encore modifiables.
  ///
  /// In fr, this message translates to:
  /// **'Écrit d\'après vos réponses. Corrigez-le si besoin.'**
  String get propertyTextSuggested;

  /// Titre proposé sans nombre de pièces, par exemple « Terrain à Yoff ».
  ///
  /// In fr, this message translates to:
  /// **'{kind} à {area}'**
  String propertyTitleFromKind(String kind, String area);

  /// Titre proposé avec le nombre de pièces, par exemple « Appartement 3 pièces à Mermoz ».
  ///
  /// In fr, this message translates to:
  /// **'{kind} {rooms} à {area}'**
  String propertyTitleFromRooms(String kind, String rooms, String area);

  /// Action principale des étapes 1 à 3 de B03.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get propertyEditorNext;

  /// Action principale de B03.
  ///
  /// In fr, this message translates to:
  /// **'Publier le bien'**
  String get propertySave;

  /// Confirmation après publication.
  ///
  /// In fr, this message translates to:
  /// **'Bien publié'**
  String get propertySaved;

  /// Action destructive de B04.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce bien'**
  String get propertyDelete;

  /// Confirmation M09 : nomme le bien concerné.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {title} » ?'**
  String propertyDeleteTitle(String title);

  /// Conséquence réelle du retrait. Le serveur ferme le bien (statut CLOSED) au lieu de l'effacer, parce que les mises en relation déjà enregistrées le référencent. Le texte promettait une disparition définitive et le bien restait dans la liste : l'écran démentait la phrase juste avant.
  ///
  /// In fr, this message translates to:
  /// **'Ce bien ne sera plus proposé aux clients. Il restera dans votre liste, marqué « Vendu ou loué ».'**
  String get propertyDeleteBody;

  /// Confirmation après retrait. Ne dit pas « supprimé » : le bien est toujours là, fermé.
  ///
  /// In fr, this message translates to:
  /// **'Bien retiré des recherches'**
  String get propertyDeleted;

  /// Ouvre la feuille M08.
  ///
  /// In fr, this message translates to:
  /// **'Changer le statut'**
  String get propertyStatusChange;

  /// Conséquence publique du statut vendu ou loué, dite avant de valider.
  ///
  /// In fr, this message translates to:
  /// **'Ce bien disparaîtra des recherches côté client.'**
  String get propertyStatusImpactClosed;

  /// Conséquence publique des statuts disponible et réservé.
  ///
  /// In fr, this message translates to:
  /// **'Ce bien restera visible dans les recherches.'**
  String get propertyStatusImpactVisible;

  /// Champ titre d'un bien.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get fieldTitle;

  /// Champ prix d'un bien, en francs.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get fieldPrice;

  /// Champ surface d'un bien.
  ///
  /// In fr, this message translates to:
  /// **'Surface en m²'**
  String get fieldSurface;

  /// Sélecteur de surface : l'unité est déjà dans chaque option.
  ///
  /// In fr, this message translates to:
  /// **'Surface'**
  String get fieldSurfaceChoice;

  /// Champ nombre de pièces.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pièces'**
  String get fieldRooms;

  /// Champ quartier d'un bien.
  ///
  /// In fr, this message translates to:
  /// **'Quartier'**
  String get fieldNeighbourhood;

  /// Champ description courte.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// Sélecteur de type de bien.
  ///
  /// In fr, this message translates to:
  /// **'Type de bien'**
  String get fieldKind;

  /// Sélecteur de nature de transaction.
  ///
  /// In fr, this message translates to:
  /// **'Louer ou vendre'**
  String get fieldTransaction;

  /// Sélecteur de disponibilité du bien.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get fieldStatus;

  /// Sélecteur individuel/agence dans B08.
  ///
  /// In fr, this message translates to:
  /// **'Type de profil'**
  String get fieldBrokerKind;

  /// Profil d'une personne seule.
  ///
  /// In fr, this message translates to:
  /// **'Courtier indépendant'**
  String get brokerKindIndividual;

  /// Profil d'une agence immobilière.
  ///
  /// In fr, this message translates to:
  /// **'Agence'**
  String get brokerKindAgency;

  /// Nom que les clients voient dans les résultats.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché'**
  String get fieldBrokerName;

  /// Exemple de nom affiché.
  ///
  /// In fr, this message translates to:
  /// **'Moussa Diop'**
  String get fieldBrokerNameHint;

  /// Numéro sur lequel les clients appellent le courtier.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get fieldBrokerPhone;

  /// Numéro WhatsApp du courtier, facultatif.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get fieldBrokerWhatsapp;

  /// Dit qu'un champ vide est une réponse valable.
  ///
  /// In fr, this message translates to:
  /// **'Laissez vide si vous n\'avez pas WhatsApp.'**
  String get fieldBrokerWhatsappHelper;

  /// Quartiers dans lesquels le courtier travaille.
  ///
  /// In fr, this message translates to:
  /// **'Zone couverte'**
  String get fieldBrokerCoverage;

  /// Exemple de zone couverte.
  ///
  /// In fr, this message translates to:
  /// **'Yoff, Ngor'**
  String get fieldBrokerCoverageHint;

  /// Explique comment saisir plusieurs quartiers.
  ///
  /// In fr, this message translates to:
  /// **'Séparez les quartiers par une virgule.'**
  String get fieldBrokerCoverageHelper;

  /// Champ obligatoire vide. Dit ce qui manque, pas « invalide ».
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est nécessaire'**
  String get validationRequired;

  /// Valeur numérique nulle ou négative. Dit quoi faire.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un nombre plus grand que zéro'**
  String get validationPositiveNumber;

  /// Résumé annoncé à la soumission d'un formulaire incomplet.
  ///
  /// In fr, this message translates to:
  /// **'Corrigez le premier champ signalé'**
  String get validationFixFirst;

  /// Titre de la feuille M01.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtersTitle;

  /// Filtre sur la nature de la transaction.
  ///
  /// In fr, this message translates to:
  /// **'Louer ou acheter'**
  String get filtersTransaction;

  /// Filtre sur le type de bien.
  ///
  /// In fr, this message translates to:
  /// **'Type de bien'**
  String get filtersKind;

  /// Filtre sur le prix.
  ///
  /// In fr, this message translates to:
  /// **'Prix maximum'**
  String get filtersMaxPrice;

  /// Filtre sur le rayon de recherche.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get filtersRadius;

  /// Option qui retire un filtre. Dite comme on la pense.
  ///
  /// In fr, this message translates to:
  /// **'Peu importe'**
  String get filtersAny;

  /// Bouton d'application, portant le nombre de résultats en direct.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{Voir 1 résultat} other{Voir {count} résultats}}'**
  String filtersApply(int count);

  /// Bouton d'application quand le nombre de résultats n'a pas pu être compté. Appliquer reste possible.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer les filtres'**
  String get filtersApplyUnknown;

  /// Message affiché dans M01 quand l'aperçu du compteur échoue, à la place d'un chargement sans fin.
  ///
  /// In fr, this message translates to:
  /// **'Le nombre de résultats n\'a pas pu être compté.'**
  String get filtersCountUnavailable;

  /// Retire tous les filtres. Demande un appui explicite.
  ///
  /// In fr, this message translates to:
  /// **'Tout enlever'**
  String get filtersReset;

  /// Option de rayon de recherche.
  ///
  /// In fr, this message translates to:
  /// **'{km} km autour de moi'**
  String filtersRadiusValue(int km);

  /// Option de prix maximum.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'à {price} F'**
  String filtersPriceValue(String price);

  /// Bouton d'ouverture de M01, portant le nombre de filtres actifs.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Filtres} =1{1 filtre} other{{count} filtres}}'**
  String filtersActive(int count);

  /// État d'écoute du micro. Impératif court, énonçable.
  ///
  /// In fr, this message translates to:
  /// **'Parlez maintenant'**
  String get voiceListening;

  /// État de traitement de la commande vocale.
  ///
  /// In fr, this message translates to:
  /// **'Un instant, je comprends…'**
  String get voiceProcessing;

  /// Introduit la commande comprise, relue avant application.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai compris :'**
  String get voiceHeard;

  /// Applique la commande comprise. Verbe concret.
  ///
  /// In fr, this message translates to:
  /// **'Chercher ça'**
  String get voiceApply;

  /// Relance l'écoute.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get voiceRetry;

  /// Aucune commande reconnue. Ne blâme pas l'utilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Je n\'ai pas compris'**
  String get voiceNotUnderstood;

  /// Exemple concret de commande, plutôt qu'une consigne abstraite.
  ///
  /// In fr, this message translates to:
  /// **'Dites par exemple : maison à louer près d\'ici.'**
  String get voiceNotUnderstoodHelp;

  /// Dit honnêtement que la reconnaissance est jouée, pour ne pas faire croire à une capacité inexistante.
  ///
  /// In fr, this message translates to:
  /// **'Reconnaissance simulée : le moteur réel arrive plus tard.'**
  String get voiceSimulated;

  /// Titre de B01, l'accueil du rôle courtier.
  ///
  /// In fr, this message translates to:
  /// **'Mon activité'**
  String get brokerHomeTitle;

  /// Libellé court de l'onglet B01.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get brokerHomeTab;

  /// Section de B01 listant le prochain geste utile.
  ///
  /// In fr, this message translates to:
  /// **'À traiter maintenant'**
  String get brokerHomeNext;

  /// Aucune action en attente côté courtier.
  ///
  /// In fr, this message translates to:
  /// **'Rien à traiter pour le moment.'**
  String get brokerHomeNothing;

  /// Libellé du chiffre mis en avant en tête de B01.
  ///
  /// In fr, this message translates to:
  /// **'Contacts reçus'**
  String get brokerHomeContactsLabel;

  /// Section de B01 résumant les chiffres utiles.
  ///
  /// In fr, this message translates to:
  /// **'Résumé'**
  String get brokerHomeOverview;

  /// Nombre de biens apparaissant dans les recherches clients.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun bien visible} =1{1 bien visible} other{{count} biens visibles}}'**
  String brokerStatVisible(int count);

  /// Nombre de biens vendus ou loués, retirés des recherches.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun bien clos} =1{1 bien clos} other{{count} biens clos}}'**
  String brokerStatHidden(int count);

  /// Nombre de mises en relation reçues.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun contact reçu} =1{1 contact reçu} other{{count} contacts reçus}}'**
  String brokerStatContacts(int count);

  /// Nombre d'avis publiés sur le profil.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun avis} =1{1 avis publié} other{{count} avis publiés}}'**
  String brokerStatReviews(int count);

  /// Avis pas encore publiés, visibles seulement du courtier.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 avis en modération} other{{count} avis en modération}}'**
  String brokerPendingReviews(int count);

  /// Statut de vérification du profil courtier.
  ///
  /// In fr, this message translates to:
  /// **'Vérification en attente'**
  String get brokerVerificationPending;

  /// Le profil n'a jamais été soumis à vérification.
  ///
  /// In fr, this message translates to:
  /// **'Profil non vérifié'**
  String get brokerVerificationMissing;

  /// Titre de B06.
  ///
  /// In fr, this message translates to:
  /// **'Avis reçus'**
  String get brokerReviewsTitle;

  /// Titre de l'état vide de B06.
  ///
  /// In fr, this message translates to:
  /// **'Aucun avis pour le moment'**
  String get brokerReviewsEmptyTitle;

  /// Explication de l'état vide de B06 : rappelle la règle.
  ///
  /// In fr, this message translates to:
  /// **'Les clients qui vous ont joint pourront vous noter.'**
  String get brokerReviewsEmptyBody;

  /// Statut d'un avis pas encore publié. Invisible du client.
  ///
  /// In fr, this message translates to:
  /// **'En modération'**
  String get reviewModerationPending;

  /// Statut d'un avis visible des clients.
  ///
  /// In fr, this message translates to:
  /// **'Publié'**
  String get reviewModerationPublished;

  /// Statut d'un avis écarté par la modération.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get reviewModerationRejected;

  /// Ouvre la rédaction d'une réponse publique à un avis.
  ///
  /// In fr, this message translates to:
  /// **'Répondre'**
  String get reviewReplyAction;

  /// Champ de réponse publique.
  ///
  /// In fr, this message translates to:
  /// **'Votre réponse'**
  String get reviewReplyLabel;

  /// Rappelle que la réponse est publique avant de l'écrire.
  ///
  /// In fr, this message translates to:
  /// **'Visible par tous'**
  String get reviewReplyHint;

  /// Envoie la réponse publique.
  ///
  /// In fr, this message translates to:
  /// **'Publier la réponse'**
  String get reviewReplySend;

  /// Confirmation après réponse.
  ///
  /// In fr, this message translates to:
  /// **'Réponse publiée'**
  String get reviewReplySent;

  /// Signale un avis abusif à la modération.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get reviewReportAction;

  /// Confirmation avant signalement.
  ///
  /// In fr, this message translates to:
  /// **'Signaler cet avis ?'**
  String get reviewReportTitle;

  /// Dit ce qui se passe réellement : le signalement ne masque rien tout de suite.
  ///
  /// In fr, this message translates to:
  /// **'Un modérateur le relira. L\'avis reste visible en attendant.'**
  String get reviewReportBody;

  /// Confirmation après signalement.
  ///
  /// In fr, this message translates to:
  /// **'Avis signalé'**
  String get reviewReported;

  /// Rappelle que le courtier ne peut ni changer ni supprimer un avis.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas modifier un avis reçu.'**
  String get reviewCannotEdit;

  /// Titre de B04 : ce que le client verra.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du bien'**
  String get propertyPreviewTitle;

  /// Rappelle que l'écran montre la vue publique, pas la gestion.
  ///
  /// In fr, this message translates to:
  /// **'Voici ce que voient les clients.'**
  String get propertyPreviewNotice;

  /// Motif d'indisponibilité du bouton de contact dans l'aperçu courtier. Lu par le lecteur d'écran.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu : le bouton est celui des clients, il ne fait rien ici.'**
  String get propertyPreviewContactDisabled;

  /// Introduit le nom du courtier sur la fiche d'un bien.
  ///
  /// In fr, this message translates to:
  /// **'Proposé par'**
  String get propertyBrokerLabel;

  /// Titre de la feuille M08.
  ///
  /// In fr, this message translates to:
  /// **'Statut du bien'**
  String get propertyStatusTitle;

  /// Confirmation après changement de statut.
  ///
  /// In fr, this message translates to:
  /// **'Statut mis à jour'**
  String get propertyStatusChanged;

  /// Titre de G03.
  ///
  /// In fr, this message translates to:
  /// **'Votre numéro'**
  String get authPhoneTitle;

  /// Dit pourquoi le numéro est demandé, juste avant un contact.
  ///
  /// In fr, this message translates to:
  /// **'Pour garder la trace de vos contacts.'**
  String get authPhoneReasonContact;

  /// Dit pourquoi le numéro est demandé au courtier.
  ///
  /// In fr, this message translates to:
  /// **'Pour retrouver vos biens sur n\'importe quel téléphone.'**
  String get authPhoneReasonBroker;

  /// Champ de saisie du numéro.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get authPhoneLabel;

  /// Action de G03. Dit ce qui va arriver.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code'**
  String get authPhoneContinue;

  /// Numéro incomplet. Dit quoi corriger, pas « invalide ».
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro n\'est pas complet'**
  String get authPhoneInvalid;

  /// Aide courte sous le champ téléphone : l'indicatif est fixe pour le MVP Sénégal.
  ///
  /// In fr, this message translates to:
  /// **'Sénégal +221'**
  String get authPhoneCountrySenegal;

  /// Bouton d'identification Google. Le libellé doit clairement nommer l'action complète.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get authGoogleContinue;

  /// Sépare les options Google/email du chemin téléphone existant.
  ///
  /// In fr, this message translates to:
  /// **'Ou recevez un code par SMS'**
  String get authPhoneFallback;

  /// Titre de G04.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu par SMS'**
  String get authOtpTitle;

  /// Rappelle à quel numéro le code est parti.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé au {phone}'**
  String authOtpSentTo(String phone);

  /// Code OTP erroné.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect, réessayez'**
  String get authOtpWrong;

  /// Libellé du champ de saisie du code reçu.
  ///
  /// In fr, this message translates to:
  /// **'Code SMS'**
  String get authOtpCodeLabel;

  /// Exemple court pour le champ OTP.
  ///
  /// In fr, this message translates to:
  /// **'6 chiffres'**
  String get authOtpCodeHint;

  /// Message affiché pendant la vérification automatique du code OTP.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du code'**
  String get authOtpChecking;

  /// Relance l'envoi du code.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get authOtpResend;

  /// Compte à rebours avant de pouvoir renvoyer.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {seconds} s'**
  String authOtpResendIn(int seconds);

  /// Revient à G03 sans perdre la démarche en cours.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le numéro'**
  String get authOtpChangeNumber;

  /// Affiche le code en clair tant qu'aucun SMS réel n'est envoyé. Honnête plutôt que bloquant.
  ///
  /// In fr, this message translates to:
  /// **'Code de démonstration : {code}'**
  String authOtpSimulated(String code);

  /// Confirmation après identification.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes identifié'**
  String get authSignedIn;

  /// Section de S01 regroupant identification et déconnexion.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsSectionAccount;

  /// Ouvre G03. Nécessaire avant de contacter ou de publier.
  ///
  /// In fr, this message translates to:
  /// **'M\'identifier'**
  String get settingsSignIn;

  /// Rappelle quel numéro est identifié.
  ///
  /// In fr, this message translates to:
  /// **'Identifié avec le {phone}'**
  String settingsSignedInAs(String phone);

  /// Titre de B05.
  ///
  /// In fr, this message translates to:
  /// **'Consultations et contacts'**
  String get brokerActivityTitle;

  /// Libellé court de l'onglet B05.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get brokerActivityTab;

  /// Titre de l'état vide de B05.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité'**
  String get brokerActivityEmptyTitle;

  /// Explication de l'état vide de B05.
  ///
  /// In fr, this message translates to:
  /// **'Les contacts reçus apparaîtront ici.'**
  String get brokerActivityEmptyBody;

  /// Bien concerné par un contact reçu.
  ///
  /// In fr, this message translates to:
  /// **'À propos de : {title}'**
  String brokerActivityAbout(String title);

  /// Le client a déclaré avoir échangé.
  ///
  /// In fr, this message translates to:
  /// **'Échange confirmé'**
  String get brokerActivityOutcomeReached;

  /// Le client n'a pas dit ce qui s'est passé.
  ///
  /// In fr, this message translates to:
  /// **'Sans suite déclarée'**
  String get brokerActivityOutcomeAttempted;

  /// Le client a déclaré ne pas vous avoir joint.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réponse'**
  String get brokerActivityOutcomeNoAnswer;

  /// Titre de B09.
  ///
  /// In fr, this message translates to:
  /// **'Vérification'**
  String get brokerVerificationTitle;

  /// Dit à quoi sert la vérification, en termes concrets.
  ///
  /// In fr, this message translates to:
  /// **'Un profil vérifié inspire confiance et remonte dans les résultats.'**
  String get brokerVerificationExplain;

  /// Action principale de B09.
  ///
  /// In fr, this message translates to:
  /// **'Demander la vérification'**
  String get brokerVerificationSubmit;

  /// Confirmation après soumission de la vérification.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get brokerVerificationSent;

  /// La vérification n'est pas passée en attente : ne pas féliciter dans le vide.
  ///
  /// In fr, this message translates to:
  /// **'La demande n\'a pas été enregistrée. Réessayez.'**
  String get brokerVerificationNotSent;

  /// État en attente : dit ce qui se passe, pas juste « en cours ».
  ///
  /// In fr, this message translates to:
  /// **'Un modérateur examine votre demande.'**
  String get brokerVerificationWaiting;

  /// Exemple de numéro sénégalais, affiché dans le champ vide. Montre la forme attendue plutôt que de répéter le libellé.
  ///
  /// In fr, this message translates to:
  /// **'77 123 45 67'**
  String get authPhoneHint;

  /// Explique la marche à suivre à un courtier pas encore vérifié.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez votre demande : un modérateur vérifie votre profil, puis le badge apparaît sur votre fiche.'**
  String get brokerVerificationHowTo;

  /// État vérifié.
  ///
  /// In fr, this message translates to:
  /// **'Votre profil est vérifié.'**
  String get brokerVerificationDone;

  /// État refusé, avec la sortie possible.
  ///
  /// In fr, this message translates to:
  /// **'Demande refusée. Vous pouvez recommencer.'**
  String get brokerVerificationRejected;

  /// Même état, en pastille : la phrase complète n'y tient pas.
  ///
  /// In fr, this message translates to:
  /// **'Demande refusée'**
  String get brokerVerificationTagRejected;

  /// Titre de B10.
  ///
  /// In fr, this message translates to:
  /// **'Mon classement'**
  String get brokerRankingTitle;

  /// Introduit la décomposition du score, en clair.
  ///
  /// In fr, this message translates to:
  /// **'Voici ce qui fait votre position dans les recherches.'**
  String get brokerRankingExplain;

  /// Facteur de classement : la note, pondérée par le volume d'avis.
  ///
  /// In fr, this message translates to:
  /// **'Note et confiance'**
  String get brokerRankingRating;

  /// Facteur de classement : la distance, qui change selon le client.
  ///
  /// In fr, this message translates to:
  /// **'Proximité du client'**
  String get brokerRankingProximity;

  /// Facteur de classement.
  ///
  /// In fr, this message translates to:
  /// **'Nombre d\'avis'**
  String get brokerRankingVolume;

  /// Facteur de classement.
  ///
  /// In fr, this message translates to:
  /// **'Taux de réponse'**
  String get brokerRankingResponse;

  /// Évite de laisser croire à un classement unique et absolu.
  ///
  /// In fr, this message translates to:
  /// **'La proximité change d\'un client à l\'autre : votre position n\'est pas la même pour tout le monde.'**
  String get brokerRankingVaries;

  /// Contribution d'un facteur, en pourcentage.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String brokerRankingPercent(int percent);

  /// Titre de la feuille M02.
  ///
  /// In fr, this message translates to:
  /// **'Où cherchez-vous ?'**
  String get locationTitle;

  /// Libellé court du bouton de choix de quartier.
  ///
  /// In fr, this message translates to:
  /// **'Quartier'**
  String get locationShort;

  /// Demande la position du téléphone. Chemin secondaire : la saisie manuelle reste première.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ma position'**
  String get locationUseGps;

  /// Invite du champ de recherche de quartier.
  ///
  /// In fr, this message translates to:
  /// **'Nom du quartier'**
  String get locationSearchHint;

  /// Quartiers choisis récemment, remontés en tête.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get locationRecent;

  /// Liste complète des quartiers connus.
  ///
  /// In fr, this message translates to:
  /// **'Tous les quartiers'**
  String get locationAll;

  /// Aucun résultat pour la recherche de quartier.
  ///
  /// In fr, this message translates to:
  /// **'Aucun quartier ne correspond'**
  String get locationNone;

  /// Refus de permission : dit la sortie, ne culpabilise pas.
  ///
  /// In fr, this message translates to:
  /// **'Position refusée. Choisissez un quartier à la main.'**
  String get locationDenied;

  /// GPS injoignable : même sortie que le refus.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible. Choisissez un quartier à la main.'**
  String get locationUnavailable;

  /// Titre de M06 pour la position. Dit le bénéfice, pas la permission.
  ///
  /// In fr, this message translates to:
  /// **'Trouver ce qui est près de vous'**
  String get permissionLocationTitle;

  /// Explique l'usage et la limite avant de demander l'autorisation système.
  ///
  /// In fr, this message translates to:
  /// **'Votre position sert à trier les courtiers du plus proche au plus loin. Elle ne quitte pas le téléphone.'**
  String get permissionLocationBody;

  /// Déclenche la demande d'autorisation du système.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get permissionContinue;

  /// Refuse sans blocage. Le parcours manuel reste entier.
  ///
  /// In fr, this message translates to:
  /// **'Pas maintenant'**
  String get permissionNotNow;

  /// Proposé seulement après un refus définitif.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get permissionOpenSettings;

  /// Section photos de l'éditeur de bien.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get photosLabel;

  /// Ouvre le choix de la source.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get photosAdd;

  /// Titre de la feuille M11.
  ///
  /// In fr, this message translates to:
  /// **'D\'où vient la photo ?'**
  String get photosSourceTitle;

  /// Source appareil photo.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get photosCamera;

  /// Source galerie.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans mes images'**
  String get photosGallery;

  /// Supprime une photo déjà ajoutée.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cette photo'**
  String get photosRemove;

  /// Limite du nombre de photos, dite avant de bloquer.
  ///
  /// In fr, this message translates to:
  /// **'{count} photos maximum'**
  String photosLimit(int count);

  /// Photos déjà ajoutées sur le maximum autorisé.
  ///
  /// In fr, this message translates to:
  /// **'{used} sur {max}'**
  String photosCount(int used, int max);

  /// Nombre de photos d'un bien, sur sa vignette. La carte montre une seule photo et ne se feuillette pas : « 1/3 » promettait un geste qui n'existe pas.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String photoCountBadge(int count);

  /// Limite réellement acceptée par le serveur, dite avant la sélection.
  ///
  /// In fr, this message translates to:
  /// **'{count} photos maximum par bien pour l\'instant.'**
  String photosServerLimit(int count);

  /// Dit pourquoi les photos sont compressées : la data coûte cher à la cible.
  ///
  /// In fr, this message translates to:
  /// **'Les photos sont allégées pour économiser vos données.'**
  String get photosCompressed;

  /// Échec sur une photo précise, sans perdre les autres.
  ///
  /// In fr, this message translates to:
  /// **'Cette photo n\'a pas pu être ajoutée.'**
  String get photosFailed;

  /// Présentation des résultats en liste.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get viewList;

  /// Présentation des résultats sur une carte.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get viewMap;

  /// Bascule C01 de la liste vers la carte. Nomme la destination, pas le mode.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get exploreShowMap;

  /// Bascule C01 de la carte vers la liste.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get exploreShowList;

  /// Demandé sur un contact dont l'issue n'est pas encore connue. C'est la réponse qui ouvre le droit de noter.
  ///
  /// In fr, this message translates to:
  /// **'Avez-vous eu cette personne ?'**
  String get historyOutcomeQuestion;

  /// Confirme l'échange et ouvre le droit de noter.
  ///
  /// In fr, this message translates to:
  /// **'Oui, on s\'est parlé'**
  String get historyOutcomeReached;

  /// Déclare l'absence de réponse. Le contact reste au journal.
  ///
  /// In fr, this message translates to:
  /// **'Non, pas de réponse'**
  String get historyOutcomeNoAnswer;

  /// Explique pourquoi aucun bouton d'avis n'apparaît sur ce contact.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réponse : on ne note que quelqu\'un à qui on a parlé.'**
  String get historyNoAnswerNote;

  /// Affiché quand les tuiles de la carte échouent à se charger, ce qui arrive souvent sur un réseau faible.
  ///
  /// In fr, this message translates to:
  /// **'Les images de la carte n\'arrivent pas. Les repères et la liste fonctionnent toujours.'**
  String get mapTilesUnavailable;

  /// Prévient du coût en données avant d'afficher la carte.
  ///
  /// In fr, this message translates to:
  /// **'La carte télécharge des images. En mode léger, restez sur la liste.'**
  String get mapDataWarning;

  /// Attribution obligatoire des tuiles OpenStreetMap.
  ///
  /// In fr, this message translates to:
  /// **'© OpenStreetMap'**
  String get mapAttribution;

  /// Sortie immédiate de la carte, toujours disponible.
  ///
  /// In fr, this message translates to:
  /// **'Revenir à la liste'**
  String get mapBackToList;

  /// Titre de l'écran S02 qui montre tous les composants.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue'**
  String get catalogTitle;

  /// Sous-titre de l'écran Catalogue.
  ///
  /// In fr, this message translates to:
  /// **'Les composants partagés et tous leurs états.'**
  String get catalogSubtitle;

  /// Section du catalogue montrant les jetons de couleur.
  ///
  /// In fr, this message translates to:
  /// **'Couleurs'**
  String get catalogSectionColors;

  /// Section du catalogue montrant l'échelle typographique.
  ///
  /// In fr, this message translates to:
  /// **'Typographie'**
  String get catalogSectionTypography;

  /// Section du catalogue montrant l'échelle d'espacement.
  ///
  /// In fr, this message translates to:
  /// **'Espacement'**
  String get catalogSectionSpacing;

  /// Section du catalogue montrant les hauteurs minimales de cible.
  ///
  /// In fr, this message translates to:
  /// **'Cibles tactiles'**
  String get catalogSectionTouch;

  /// Section du catalogue montrant les durées d'animation.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement'**
  String get catalogSectionMotion;

  /// Note affichée quand le système demande des animations réduites.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement réduit actif : les durées passent à zéro.'**
  String get catalogMotionReduced;

  /// Section du catalogue montrant chaque variante de bouton.
  ///
  /// In fr, this message translates to:
  /// **'Boutons'**
  String get catalogSectionButtons;

  /// Section du catalogue montrant les champs et les sélecteurs.
  ///
  /// In fr, this message translates to:
  /// **'Saisie'**
  String get catalogSectionInputs;

  /// Section du catalogue montrant les cartes, badges et notes.
  ///
  /// In fr, this message translates to:
  /// **'Contenu'**
  String get catalogSectionContent;

  /// Section du catalogue montrant chargement, vide et erreur.
  ///
  /// In fr, this message translates to:
  /// **'États d\'écran'**
  String get catalogSectionStates;

  /// Section du catalogue permettant d'ouvrir chaque type de feuille.
  ///
  /// In fr, this message translates to:
  /// **'Feuilles et messages'**
  String get catalogSectionOverlays;

  /// Étiquette d'un exemple de bouton désactivé dans le catalogue.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get catalogStateDisabled;

  /// Étiquette d'un exemple de bouton en chargement dans le catalogue.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get catalogStateLoading;

  /// Titre de C01 quand le GPS répond hors de la zone couverte.
  ///
  /// In fr, this message translates to:
  /// **'Dakar'**
  String get exploreDefaultArea;

  /// Titre de C01 quand le GPS n'a rien rendu : les résultats partent du centre de Dakar.
  ///
  /// In fr, this message translates to:
  /// **'Dakar · position inconnue'**
  String get exploreUnknownPosition;

  /// Section de l'accueil : biens triés par distance.
  ///
  /// In fr, this message translates to:
  /// **'Près de chez vous'**
  String get exploreNearbyProperties;

  /// Section de l'accueil : courtiers les mieux classés.
  ///
  /// In fr, this message translates to:
  /// **'Courtiers de confiance'**
  String get exploreTrustedBrokers;

  /// Section de l'accueil : derniers biens publiés.
  ///
  /// In fr, this message translates to:
  /// **'Nouveautés'**
  String get exploreNewListings;

  /// Ouvre la liste complète d'une section de l'accueil.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get exploreSeeAll;

  /// Catégorie d'accueil sans filtre.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get exploreCategoryAll;

  /// Carte d'accueil quand le GPS n'est pas actif.
  ///
  /// In fr, this message translates to:
  /// **'Activer ma position'**
  String get exploreEnableLocationTitle;

  /// Explication sous « Activer ma position ».
  ///
  /// In fr, this message translates to:
  /// **'Pour trier les biens et les courtiers du plus proche au plus loin.'**
  String get exploreEnableLocationBody;

  /// Ouvre M02 depuis l'accueil.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un quartier'**
  String get exploreChooseArea;

  /// Titre de l'écran de résultats quand rien n'est tapé.
  ///
  /// In fr, this message translates to:
  /// **'Tous les résultats'**
  String get exploreSearchAll;

  /// Curseur de prix au maximum.
  ///
  /// In fr, this message translates to:
  /// **'Sans limite'**
  String get filtersPriceAny;

  /// Curseur de distance au maximum.
  ///
  /// In fr, this message translates to:
  /// **'Toute la ville'**
  String get filtersRadiusAny;

  /// Section vocal de l'éditeur de bien.
  ///
  /// In fr, this message translates to:
  /// **'Message vocal'**
  String get voiceNoteLabel;

  /// Aide sous le bouton d'enregistrement.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez le bien avec vos mots. 45 secondes au plus.'**
  String get voiceNoteHint;

  /// Démarre l'enregistrement.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un message vocal'**
  String get voiceNoteRecord;

  /// Termine l'enregistrement.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get voiceNoteStop;

  /// Compteur pendant l'enregistrement.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement… {seconds} s'**
  String voiceNoteRecording(int seconds);

  /// Retire le vocal enregistré.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le vocal'**
  String get voiceNoteDelete;

  /// Remplace le vocal par un nouveau.
  ///
  /// In fr, this message translates to:
  /// **'Réenregistrer'**
  String get voiceNoteRedo;

  /// Lance la lecture du vocal.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get voiceNotePlay;

  /// Met la lecture en pause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get voiceNotePause;

  /// Titre du lecteur vocal sur C03.
  ///
  /// In fr, this message translates to:
  /// **'Le courtier vous en parle'**
  String get voiceNoteFromBroker;

  /// Repère sur une carte de bien qui porte un vocal.
  ///
  /// In fr, this message translates to:
  /// **'Vocal'**
  String get voiceNoteBadge;

  /// Le système a refusé le micro.
  ///
  /// In fr, this message translates to:
  /// **'Micro refusé. Autorisez-le dans les réglages du téléphone pour enregistrer.'**
  String get voiceNotePermissionDenied;

  /// L'enregistreur a échoué.
  ///
  /// In fr, this message translates to:
  /// **'Le message vocal n\'a pas pu être enregistré.'**
  String get voiceNoteFailed;

  /// Le lecteur a échoué.
  ///
  /// In fr, this message translates to:
  /// **'Le message vocal n\'a pas pu être lu.'**
  String get voiceNoteUnavailable;

  /// Refus avant envoi : fichier au-dessus de la limite serveur.
  ///
  /// In fr, this message translates to:
  /// **'Le message vocal est trop lourd pour être envoyé.'**
  String get voiceNoteTooLarge;

  /// État après enregistrement, avant publication.
  ///
  /// In fr, this message translates to:
  /// **'Message vocal prêt'**
  String get voiceNoteReady;

  /// En-tête du profil sans session.
  ///
  /// In fr, this message translates to:
  /// **'Visiteur'**
  String get profileVisitor;

  /// Sous l'en-tête du profil sans session.
  ///
  /// In fr, this message translates to:
  /// **'Identifiez-vous pour contacter un courtier et retrouver vos contacts.'**
  String get profileSignInHint;

  /// Rôle affiché dans l'en-tête du profil.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get profileRoleClient;

  /// Rôle affiché dans l'en-tête du profil.
  ///
  /// In fr, this message translates to:
  /// **'Courtier'**
  String get profileRoleBroker;

  /// Phrase sous les canaux de M04.
  ///
  /// In fr, this message translates to:
  /// **'Le contact est noté dans vos contacts pour pouvoir laisser un avis.'**
  String get contactSheetHint;

  /// Sous-titre du canal Appeler.
  ///
  /// In fr, this message translates to:
  /// **'Appel direct'**
  String get contactCallHint;

  /// Sous-titre du canal WhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Message ou vocal'**
  String get contactWhatsappHint;

  /// Sous-titre du canal SMS.
  ///
  /// In fr, this message translates to:
  /// **'Sans internet'**
  String get contactSmsHint;

  /// Titre de l'état vide de la recherche.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir par quartier'**
  String get exploreBrowseAreas;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppL10nFr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
