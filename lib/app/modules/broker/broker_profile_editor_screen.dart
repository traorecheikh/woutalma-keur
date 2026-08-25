import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

const String _dialCode = '+221';
const int _localDigits = 9;

String localPhoneDigits(String value) {
  final String digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.startsWith('221') ? digits.substring(3) : digits;
}

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

  bool isValid({required String name, required String phone}) =>
      name.trim().isNotEmpty && localPhoneDigits(phone).length == _localDigits;

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
          whatsapp: whatsappDigits.length == _localDigits
              ? '$_dialCode$whatsappDigits'
              : null,
          position: current.position,
          coverage: parseCoverage(coverage),
          logoAsset: current.logoAsset,
          // Vérification et mise en avant appartiennent à la modération.
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
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  List<String> _coverage = <String>[];
  bool _submitted = false;
  Broker? _loaded;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  void _syncFrom(Broker broker) {
    if (identical(_loaded, broker)) return;
    _loaded = broker;
    _name.text = broker.name;
    _phone.text = localPhoneDigits(broker.phone);
    _whatsapp.text = localPhoneDigits(broker.whatsapp ?? '');
    _coverage = List<String>.of(broker.coverage);
  }

  bool get _dirty {
    final loaded = _loaded;
    if (loaded == null) return false;
    final model = context.read<BrokerProfileEditorViewModel>();
    return _name.text != loaded.name ||
        _phone.text != localPhoneDigits(loaded.phone) ||
        _whatsapp.text != localPhoneDigits(loaded.whatsapp ?? '') ||
        _coverage.join(', ') != loaded.coverage.join(', ') ||
        model.kind != loaded.kind;
  }

  List<String> get _zones {
    final known = dakarNeighbourhoods.map((n) => n.name).toList();
    return [...known, ..._coverage.where((z) => !known.contains(z))];
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerProfileEditorViewModel>();
    final l = context.l10n;
    final broker = model.broker;
    if (broker != null) _syncFrom(broker);

    return AppScaffold(
      headerTitle: l.brokerProfileEditorTitle,
      onBack: () => _leave(context),
      bottom: broker == null
          ? null
          : AppButton(
              l.brokerProfileEditorSave,
              icon: FIcons.check,
              loading: model.submission.isSubmitting,
              onPressed: () => _save(context, model),
            ),
      body: model.state.map(
        initial: () => const AppSkeleton(),
        loading: () => const AppSkeleton(),
        empty: () =>
            AppState(kind: AppStateKind.empty, title: l.stateEmptyTitle),
        error: (failure) => failureState(context, failure, onRetry: model.load),
        data: (_) => _form(context, model),
      ),
    );
  }

  Widget _form(BuildContext context, BrokerProfileEditorViewModel model) {
    final l = context.l10n;
    final phoneDigits = localPhoneDigits(_phone.text);
    final whatsappDigits = localPhoneDigits(_whatsapp.text);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Insets.page,
        Insets.sm,
        Insets.page,
        Insets.xxl,
      ),
      children: [
        _Label(l.fieldBrokerKind),
        AppChoice<BrokerKind>(
          options: BrokerKind.values,
          selected: model.kind,
          onChanged: model.setKind,
          label: (value) => value == BrokerKind.individual
              ? l.brokerKindIndividual
              : l.brokerKindAgency,
          icon: (value) =>
              value == BrokerKind.individual ? FIcons.user : FIcons.store,
        ),
        const SizedBox(height: Insets.xl),
        AppField(
          label: l.fieldBrokerName,
          hint: l.fieldBrokerNameHint,
          controller: _name,
          onChanged: (_) => setState(() {}),
          error: _submitted && _name.text.trim().isEmpty
              ? l.validationRequired
              : null,
        ),
        const SizedBox(height: Insets.lg),
        AppField(
          label: l.fieldBrokerPhone,
          hint: l.authPhoneCountrySenegal,
          controller: _phone,
          keyboardType: TextInputType.phone,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          error: _submitted && phoneDigits.length != _localDigits
              ? l.authPhoneInvalid
              : null,
        ),
        const SizedBox(height: Insets.lg),
        AppField(
          label: l.fieldBrokerWhatsapp,
          hint: l.fieldBrokerWhatsappHelper,
          controller: _whatsapp,
          keyboardType: TextInputType.phone,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          error:
              _submitted &&
                  whatsappDigits.isNotEmpty &&
                  whatsappDigits.length != _localDigits
              ? l.authPhoneInvalid
              : null,
        ),
        const SizedBox(height: Insets.xl),
        _Label(l.fieldBrokerCoverage),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          children: [
            for (final zone in _zones)
              AppPill(
                zone,
                selected: _coverage.contains(zone),
                icon: FIcons.mapPin,
                onTap: () => setState(
                  () => _coverage.contains(zone)
                      ? _coverage.remove(zone)
                      : _coverage.add(zone),
                ),
              ),
          ],
        ),
        const SizedBox(height: Insets.lg),
        Text(
          l.brokerProfileEditorNotEditable,
          style: context.text.bodySmall!.copyWith(
            color: context.tones.inkSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _leave(BuildContext context) async {
    if (!_dirty) {
      widget.onBack();
      return;
    }
    final l = context.l10n;
    final confirmed = await confirm(
      context,
      title: l.brokerProfileEditorLeaveTitle,
      message: l.brokerProfileEditorLeaveBody,
      action: l.brokerProfileEditorLeaveConfirm,
      danger: true,
    );
    if (confirmed) widget.onBack();
  }

  Future<void> _save(
    BuildContext context,
    BrokerProfileEditorViewModel model,
  ) async {
    setState(() => _submitted = true);

    final saved = await model.save(
      name: _name.text,
      phone: _phone.text,
      whatsapp: _whatsapp.text,
      coverage: _coverage.join(', '),
    );
    if (!context.mounted) return;

    final feedback = context.read<InteractionFeedbackService?>();
    if (!saved) {
      final submission = model.submission;
      final message = submission is MutationFailure
          ? failureText(context.l10n, submission.failure)
          : context.l10n.validationFixFirst;
      feedback?.emit(FeedbackIntent.error);
      feedback?.announce(message);
      if (submission is MutationFailure) toast(context, message);
      return;
    }

    feedback?.emit(
      FeedbackIntent.success,
      eventId: 'B08:success:${model.broker?.id}',
    );
    toast(context, context.l10n.brokerProfileEditorSaved);
    widget.onSaved();
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Insets.sm),
    child: Text(
      text,
      style: context.text.labelLarge!.copyWith(
        color: context.tones.inkSecondary,
      ),
    ),
  );
}
