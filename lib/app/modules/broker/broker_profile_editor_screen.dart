import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_confirm_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Indicatif du pays servi. Les numéros sont stockés au format international
/// comme partout ailleurs dans l'application ; la saisie, elle, reste locale.
const String _dialCode = '+221';
const int _localDigits = 9;

/// Ramène un numéro saisi ou stocké à ses neuf chiffres locaux.
String localPhoneDigits(String value) {
  final String digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.startsWith('221') ? digits.substring(3) : digits;
}

/// Coordonne B08, la modification du profil courtier.
///
/// C'est le seul chemin vers `BrokerRepository.save` pour le profil : sans
/// lui, un courtier qui change de numéro n'a aucun moyen de le dire, et ses
/// clients appellent dans le vide.
class BrokerProfileEditorViewModel extends ChangeNotifier {
  BrokerProfileEditorViewModel({
    required BrokerRepository brokers,
    required String brokerId,
  }) : _brokers = brokers,
       _brokerId = brokerId;

  final BrokerRepository _brokers;
  final String _brokerId;

  ScreenState<Broker> _state = const ScreenState<Broker>.initial();
  ScreenState<Broker> get state => _state;

  MutationState _submission = const MutationState.idle();
  MutationState get submission => _submission;

  Broker? get broker => _state.valueOrNull;

  /// Individuel ou agence. Vit dans le modèle parce que c'est un choix, pas
  /// un champ de texte.
  BrokerKind kind = BrokerKind.individual;

  Future<void> load() async {
    _state = const ScreenState<Broker>.loading();
    notifyListeners();

    try {
      final Broker? current = await _brokers.byId(_brokerId);
      if (current == null) {
        _state = const ScreenState<Broker>.error(WkFailure.notFound);
      } else {
        kind = current.kind;
        _state = ScreenState<Broker>.data(current);
      }
    } on Object catch (error) {
      _state = ScreenState<Broker>.error(brokerFailure(error));
    }
    notifyListeners();
  }

  /// Vrai quand la saisie est publiable.
  ///
  /// La zone couverte peut être vide : mieux vaut un profil sans quartier
  /// qu'un courtier bloqué parce qu'il ne sait pas quoi écrire là.
  bool isValid({required String name, required String phone}) =>
      name.trim().isNotEmpty && localPhoneDigits(phone).length == _localDigits;

  /// Enregistre le profil. Renvoie vrai si l'écriture a réussi.
  ///
  /// Une saisie refusée laisse [submission] à `idle` ; un échec d'écriture
  /// porte la cause, que l'écran affiche telle quelle.
  Future<bool> save({
    required String name,
    required String phone,
    required String whatsapp,
    required String coverage,
  }) async {
    final Broker? current = broker;
    if (current == null || !isValid(name: name, phone: phone)) {
      _submission = const MutationState.idle();
      notifyListeners();
      return false;
    }

    _submission = const MutationState.submitting();
    notifyListeners();

    final String whatsappDigits = localPhoneDigits(whatsapp);

    try {
      await _brokers.save(
        Broker(
          id: current.id,
          kind: kind,
          name: name.trim(),
          phone: '$_dialCode${localPhoneDigits(phone)}',
          // Vide veut dire « pas de WhatsApp » : le bouton disparaît alors
          // côté client au lieu de composer un numéro qui n'existe pas.
          whatsapp: whatsappDigits.length == _localDigits
              ? '$_dialCode$whatsappDigits'
              : null,
          position: current.position,
          coverage: parseCoverage(coverage),
          logoAsset: current.logoAsset,
          // Ni le statut de vérification ni la mise en avant ne se modifient
          // ici : ils appartiennent à la modération, pas à celui qu'ils
          // qualifient.
          verification: current.verification,
          responseRate: current.responseRate,
          pinned: current.pinned,
        ),
      );
      _submission = const MutationState.success();
    } on Object catch (error) {
      _submission = MutationState.failure(brokerFailure(error));
      notifyListeners();
      return false;
    }

    await load();
    notifyListeners();
    return true;
  }

  void setKind(BrokerKind value) {
    kind = value;
    notifyListeners();
  }
}

/// Découpe la zone couverte saisie en une liste de quartiers.
///
/// Une virgule ou un retour à la ligne sépare ; les doublons et les blancs
/// disparaissent. Un composant à jetons viendra plus tard : d'ici là, écrire
/// « Yoff, Ngor » reste plus rapide que ne rien pouvoir écrire.
List<String> parseCoverage(String value) {
  final List<String> zones = <String>[];
  for (final String part in value.split(RegExp(r'[,\n]'))) {
    final String zone = part.trim();
    if (zone.isNotEmpty && !zones.contains(zone)) {
      zones.add(zone);
    }
  }
  return zones;
}

/// B08 — Modifier le profil.
class BrokerProfileEditorScreen extends StatefulWidget {
  const BrokerProfileEditorScreen({
    required this.onBack,
    required this.onSaved,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSaved;

  @override
  State<BrokerProfileEditorScreen> createState() =>
      _BrokerProfileEditorScreenState();
}

class _BrokerProfileEditorScreenState extends State<BrokerProfileEditorScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _whatsapp = TextEditingController();
  final TextEditingController _coverage = TextEditingController();

  /// Vrai dès la première tentative : rien n'est déclaré faux avant.
  bool _submitted = false;
  int _revalidateTick = 0;

  /// Ce qui a été chargé, pour savoir si quelque chose a changé.
  Broker? _loaded;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _coverage.dispose();
    super.dispose();
  }

  /// Recopie le profil dans les champs, une seule fois par chargement.
  void _syncFrom(Broker broker) {
    if (identical(_loaded, broker)) {
      return;
    }
    _loaded = broker;
    _name.text = broker.name;
    _phone.text = localPhoneDigits(broker.phone);
    _whatsapp.text = localPhoneDigits(broker.whatsapp ?? '');
    _coverage.text = broker.coverage.join(', ');
  }

  bool get _dirty {
    final Broker? loaded = _loaded;
    if (loaded == null) {
      return false;
    }
    final BrokerProfileEditorViewModel model = context
        .read<BrokerProfileEditorViewModel>();
    return _name.text != loaded.name ||
        _phone.text != localPhoneDigits(loaded.phone) ||
        _whatsapp.text != localPhoneDigits(loaded.whatsapp ?? '') ||
        _coverage.text != loaded.coverage.join(', ') ||
        model.kind != loaded.kind;
  }

  @override
  Widget build(BuildContext context) {
    final BrokerProfileEditorViewModel model = context
        .watch<BrokerProfileEditorViewModel>();
    final Broker? broker = model.broker;
    if (broker != null) {
      _syncFrom(broker);
    }

    return WkScaffold(
      topBar: WkTopBar(
        title: context.l10n.brokerProfileEditorTitle,
        onBack: () => _leave(context),
      ),
      bottomAction: broker == null
          ? null
          : WkButton(
              label: context.l10n.brokerProfileEditorSave,
              icon: Icons.check,
              loading: model.submission.isSubmitting,
              onPressed: () => _save(context, model),
            ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => const WkEmptyState(),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (Broker _) => _Form(
          model: model,
          name: _name,
          phone: _phone,
          whatsapp: _whatsapp,
          coverage: _coverage,
          submitted: _submitted,
          revalidateTick: _revalidateTick,
        ),
      ),
    );
  }

  /// Retour : M09 si quelque chose a changé, sinon on sort.
  Future<void> _leave(BuildContext context) async {
    if (!_dirty) {
      widget.onBack();
      return;
    }
    final bool? confirmed = await WkConfirmSheet.show(
      context,
      title: context.l10n.brokerProfileEditorLeaveTitle,
      body: context.l10n.brokerProfileEditorLeaveBody,
      confirmLabel: context.l10n.brokerProfileEditorLeaveConfirm,
      cancelLabel: context.l10n.commonCancel,
      destructive: true,
    );
    if (confirmed == true) {
      widget.onBack();
    }
  }

  Future<void> _save(
    BuildContext context,
    BrokerProfileEditorViewModel model,
  ) async {
    // Le bouton n'est jamais grisé : c'est en appuyant qu'on apprend ce qui
    // manque, comme dans l'éditeur de bien.
    setState(() {
      _submitted = true;
      _revalidateTick++;
    });

    final bool saved = await model.save(
      name: _name.text,
      phone: _phone.text,
      whatsapp: _whatsapp.text,
      coverage: _coverage.text,
    );
    if (!context.mounted) {
      return;
    }

    if (!saved) {
      final InteractionFeedbackService? feedback = context
          .read<InteractionFeedbackService?>();
      feedback?.emit(FeedbackIntent.error);
      final MutationState submission = model.submission;
      final String message = submission is MutationFailure
          ? failureMessage(context.l10n, submission.failure)
          : context.l10n.validationFixFirst;
      feedback?.announce(message);
      if (submission is MutationFailure) {
        WkToast.show(context, message: message);
      }
      return;
    }

    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B08:success:${model.broker?.id}',
    );
    WkToast.show(context, message: context.l10n.brokerProfileEditorSaved);
    widget.onSaved();
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.model,
    required this.name,
    required this.phone,
    required this.whatsapp,
    required this.coverage,
    required this.submitted,
    required this.revalidateTick,
  });

  final BrokerProfileEditorViewModel model;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController whatsapp;
  final TextEditingController coverage;
  final bool submitted;
  final int revalidateTick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
      ),
      children: <Widget>[
        WkSelectField<BrokerKind>(
          label: context.l10n.fieldBrokerKind,
          value: model.kind,
          onChanged: model.setKind,
          options: <WkOption<BrokerKind>>[
            WkOption<BrokerKind>(
              value: BrokerKind.individual,
              label: context.l10n.brokerKindIndividual,
              icon: Icons.person_outline,
            ),
            WkOption<BrokerKind>(
              value: BrokerKind.agency,
              label: context.l10n.brokerKindAgency,
              icon: Icons.storefront_outlined,
            ),
          ],
        ),
        const SizedBox(height: WkSpacing.md),
        WkTextField(
          label: context.l10n.fieldBrokerName,
          hint: context.l10n.fieldBrokerNameHint,
          controller: name,
          revalidateTick: revalidateTick,
          validator: (String value) => !submitted || value.trim().isNotEmpty
              ? null
              : context.l10n.validationRequired,
        ),
        WkTextField(
          label: context.l10n.fieldBrokerPhone,
          helper: context.l10n.authPhoneCountrySenegal,
          controller: phone,
          keyboardType: TextInputType.phone,
          maxLength: 12,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          revalidateTick: revalidateTick,
          readyToEvaluate: (String value) =>
              localPhoneDigits(value).length >= _localDigits,
          validator: (String value) =>
              localPhoneDigits(value).length == _localDigits
              ? null
              : context.l10n.authPhoneInvalid,
        ),
        WkTextField(
          label: context.l10n.fieldBrokerWhatsapp,
          helper: context.l10n.fieldBrokerWhatsappHelper,
          controller: whatsapp,
          keyboardType: TextInputType.phone,
          maxLength: 12,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          revalidateTick: revalidateTick,
          readyToEvaluate: (String value) =>
              localPhoneDigits(value).length >= _localDigits,
          // Vide est une réponse valable : tout le monde n'a pas WhatsApp.
          validator: (String value) {
            final String digits = localPhoneDigits(value);
            return digits.isEmpty || digits.length == _localDigits
                ? null
                : context.l10n.authPhoneInvalid;
          },
        ),
        WkTextField(
          label: context.l10n.fieldBrokerCoverage,
          hint: context.l10n.fieldBrokerCoverageHint,
          helper: context.l10n.fieldBrokerCoverageHelper,
          controller: coverage,
        ),
        const SizedBox(height: WkSpacing.sm),
        Text(
          context.l10n.brokerProfileEditorNotEditable,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
