import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart' show FDeterminateProgress;
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/domain/property_description.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/modules/broker/broker_properties_screen.dart'
    show statusIcon;
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/photo_picker.dart';
import 'package:woutalma_keur/app/ui/ui.dart';
import 'package:woutalma_keur/app/ui/voice_note.dart';

/// L'API refuse la quatrième photo : l'éditeur s'aligne sur cette limite.
const int kServerPhotoLimit = 3;
const int _kStepCount = 3;

class PropertyEditorScreen extends StatefulWidget {
  const PropertyEditorScreen({
    required this.onBack,
    required this.onSaved,
    required this.photos,
    required this.voiceNotes,
    this.recoverLostPhoto,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(String propertyId) onSaved;
  final PhotoService photos;
  final VoiceNoteRecorder voiceNotes;

  /// Photo restée chez le système parce qu'Android a tué l'application
  /// pendant la prise de vue. Fournie par la route, qui connaît
  /// l'implémentation réelle du sélecteur.
  final Future<String?> Function()? recoverLostPhoto;

  @override
  State<PropertyEditorScreen> createState() => _PropertyEditorScreenState();
}

class _PropertyEditorScreenState extends State<PropertyEditorScreen> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  int _step = 0;
  bool _submitted = false;
  String? _suggestedTitle;
  String? _composedDescription;

  @override
  void initState() {
    super.initState();
    final existing = context.read<PropertyEditorViewModel>().existing;
    if (existing != null) {
      _title.text = existing.title;
      _price.text = existing.price.toString();
      _description.text = existing.description;
      if (PropertyDescriptionComposer.isComposedFor(existing)) {
        _composedDescription = existing.description;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _resume());
  }

  /// Ce que l'écran a perdu au dernier passage : la saisie non publiée, et la
  /// photo prise juste avant qu'Android ne ferme l'application.
  Future<void> _resume() async {
    final model = context.read<PropertyEditorViewModel>();
    final draft = await model.pendingDraft();
    if (draft != null && mounted) {
      final resumed = await confirm(
        context,
        title: context.l10n.propertyDraftTitle,
        message: context.l10n.propertyDraftBody,
        action: context.l10n.propertyDraftResume,
      );
      if (!mounted) return;
      if (resumed) {
        model.restore(draft);
        _title.text = draft.title;
        _price.text = draft.priceText;
        _description.text = draft.description;
      } else {
        await model.discardDraft();
      }
      if (!mounted) return;
      setState(() {});
    }

    final lost = await widget.recoverLostPhoto?.call();
    if (lost == null || !mounted) return;
    if (model.photos.length < kServerPhotoLimit &&
        !model.photos.contains(lost)) {
      model.setPhotos(<String>[...model.photos, lost]);
    }
  }

  void _remember() {
    context.read<PropertyEditorViewModel>().rememberDraft(
      title: _title.text,
      priceText: _price.text,
      description: _description.text,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _isLastStep => _step == _kStepCount - 1;

  int? get _priceValue =>
      int.tryParse(_price.text.replaceAll(RegExp(r'\D'), ''));

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PropertyEditorViewModel>();
    final l = context.l10n;
    return PopScope(
      // Le retour système quittait l'éditeur depuis l'étape 3 : trois écrans
      // remplis disparaissaient d'un geste qui ne voulait dire que « revenir
      // en arrière ».
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: _form(context, model, l),
    );
  }

  Widget _form(BuildContext context, PropertyEditorViewModel model, AppL10n l) {
    return AppScaffold(
      headerTitle: model.isEditing ? l.propertyEditorEdit : l.propertyEditorNew,
      onBack: _step == 0 ? widget.onBack : () => setState(() => _step--),
      bottom: AppButton(
        _isLastStep ? l.propertySave : l.propertyEditorNext,
        icon: _isLastStep ? FIcons.check : FIcons.arrowRight,
        loading: model.submission.isSubmitting,
        onPressed: () => _isLastStep ? _save(context, model) : _next(model),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.sm,
              Insets.page,
              0,
            ),
            child: FDeterminateProgress(
              value: (_step + 1) / _kStepCount,
              semanticsLabel: l.propertyEditorStep(_step + 1, _kStepCount),
            ),
          ),
          AppTitle(switch (_step) {
            0 => l.propertyEditorStepKind,
            1 => l.propertyEditorStepDetails,
            _ => l.propertyEditorStepMedia,
          }),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Insets.page,
                0,
                Insets.page,
                Insets.xxl,
              ),
              children: [
                if (model.prefilledFromPrevious)
                  _Hint(l.propertyAddAnother, bottom: Insets.lg),
                ...switch (_step) {
                  0 => _basics(context, model),
                  1 => _details(context, model),
                  _ => _media(context, model),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _basics(BuildContext context, PropertyEditorViewModel model) {
    final l = context.l10n;
    return [
      _Label(l.fieldTransaction),
      AppChoice<TransactionKind>(
        options: TransactionKind.values,
        selected: model.transaction,
        onChanged: (value) => _answer(model, model.setTransaction, value),
        label: (value) => WkFormat.transaction(l, value),
        icon: (value) =>
            value == TransactionKind.rent ? FIcons.keyRound : FIcons.tag,
      ),
      const SizedBox(height: Insets.xl),
      _Label(l.fieldKind),
      AppChoice<PropertyKind>(
        options: PropertyKind.values,
        selected: model.kind,
        onChanged: (value) => _answer(model, model.setKind, value),
        label: (value) => WkFormat.propertyKind(l, value),
        icon: WkFormat.propertyKindIcon,
      ),
      const SizedBox(height: Insets.xl),
      _Label(l.fieldNeighbourhood),
      AppCard.rows([
        AppRow(
          title: model.neighbourhood?.name ?? l.commonChoose,
          leading: const Icon(FIcons.mapPin),
          onTap: () => _pickNeighbourhood(context, model),
        ),
      ]),
      if (_submitted && model.neighbourhood == null)
        _Error(l.validationRequired),
    ];
  }

  List<Widget> _details(BuildContext context, PropertyEditorViewModel model) {
    final l = context.l10n;
    final price = _priceValue;
    return [
      AppField(
        label: l.fieldTitle,
        controller: _title,
        maxLength: 120,
        error: _submitted && _title.text.trim().isEmpty
            ? l.validationRequired
            : null,
        onChanged: (_) => setState(_remember),
      ),
      _Suggested(source: _title, written: _suggestedTitle),
      const SizedBox(height: Insets.lg),
      AppField(
        // Le libellé porte l'unité et la périodicité : « Prix » seul laissait
        // saisir un loyer annuel dans un champ affiché « par mois ».
        label: model.transaction == TransactionKind.rent
            ? l.fieldPriceRent
            : l.fieldPriceSale,
        controller: _price,
        keyboardType: TextInputType.number,
        maxLength: 11,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        error: !_submitted
            ? null
            : price == null || price <= 0
            ? l.validationPositiveNumber
            : model.isPriceTooHigh(price)
            ? l.validationPriceTooHigh(PropertyEditorViewModel.maxPriceCfa)
            : null,
        onChanged: (_) => setState(() {
          _composeDescription(model);
          _remember();
        }),
      ),
      const SizedBox(height: Insets.xl),
      _Label(l.fieldSurfaceChoice),
      AppChoice<int?>(
        options: [null, ...model.surfaceOptions],
        selected: model.surface,
        onChanged: (value) => _answer(model, model.setSurface, value),
        label: (value) =>
            value == null ? l.commonUnspecified : l.surfaceValue(value),
      ),
      if (model.asksRooms) ...[
        const SizedBox(height: Insets.xl),
        _Label(l.fieldRooms),
        AppChoice<int?>(
          options: [null, ...model.roomOptions],
          selected: model.rooms,
          onChanged: (value) => _answer(model, model.setRooms, value),
          label: (value) =>
              value == null ? l.commonUnspecified : l.roomCount(value),
        ),
      ],
      const SizedBox(height: Insets.xl),
      AppField(
        label: l.fieldDescription,
        controller: _description,
        maxLines: 4,
        onChanged: (_) => setState(_remember),
      ),
      _Suggested(source: _description, written: _composedDescription),
    ];
  }

  List<Widget> _media(BuildContext context, PropertyEditorViewModel model) {
    final l = context.l10n;
    return [
      AppPhotoPicker(
        paths: model.photos,
        service: widget.photos,
        onChanged: (paths) {
          model.setPhotos(paths);
          _remember();
        },
        max: kServerPhotoLimit,
      ),
      _Hint(l.photosServerLimit(kServerPhotoLimit), bottom: Insets.xl),
      AppVoiceNoteRecorder(
        asset: model.voiceNote,
        recorder: widget.voiceNotes,
        onChanged: (asset) {
          model.setVoiceNote(asset);
          _remember();
        },
      ),
      const SizedBox(height: Insets.xl),
      if (model.isEditing) ...[
        _Label(l.fieldStatus),
        AppChoice<PropertyStatus>(
          options: PropertyStatus.values,
          selected: model.status,
          onChanged: model.setStatus,
          label: (value) => WkFormat.propertyStatus(l, value),
          icon: statusIcon,
        ),
        const SizedBox(height: Insets.md),
      ],
      _Hint(
        model.status == PropertyStatus.closed
            ? l.propertyStatusImpactClosed
            : l.propertyStatusImpactVisible,
      ),
    ];
  }

  Future<void> _pickNeighbourhood(
    BuildContext context,
    PropertyEditorViewModel model,
  ) async {
    final chosen = await pick<Neighbourhood>(
      context,
      title: context.l10n.fieldNeighbourhood,
      options: model.neighbourhoodOptions,
      selected: model.neighbourhood,
      label: (value) => value.name,
      icon: (_) => FIcons.mapPin,
    );
    if (chosen == null || !mounted) return;
    _answer(model, model.setNeighbourhood, chosen);
  }

  void _next(PropertyEditorViewModel model) {
    setState(() {
      _step++;
      if (_step == 1) _suggestTitle(model);
      _composeDescription(model);
    });
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.stepValid,
      eventId: 'B03:step:$_step',
    );
  }

  void _answer<T>(
    PropertyEditorViewModel model,
    void Function(T value) apply,
    T value,
  ) {
    apply(value);
    setState(() {
      _suggestTitle(model);
      _composeDescription(model);
      _remember();
    });
  }

  void _suggestTitle(PropertyEditorViewModel model) {
    final area = model.neighbourhood;
    final current = _title.text.trim();
    if (area == null ||
        (current.isNotEmpty && current != _suggestedTitle?.trim())) {
      return;
    }
    final l = context.l10n;
    final kind = WkFormat.propertyKind(l, model.kind);
    final rooms = model.asksRooms ? model.rooms : null;
    final suggestion = rooms == null
        ? l.propertyTitleFromKind(kind, area.name)
        : l.propertyTitleFromRooms(kind, l.roomCount(rooms), area.name);
    _title.text = suggestion;
    _suggestedTitle = suggestion;
  }

  void _composeDescription(PropertyEditorViewModel model) {
    final current = _description.text.trim();
    if (current.isNotEmpty && current != _composedDescription?.trim()) return;
    final composed = PropertyDescriptionComposer.compose(
      PropertyDescriptionDraft(
        kind: model.kind,
        transaction: model.transaction,
        price: _priceValue ?? 0,
        surface: model.surface,
        rooms: model.asksRooms ? model.rooms : null,
        neighbourhood: model.neighbourhood?.name ?? '',
      ),
    );
    _description.text = composed;
    _composedDescription = composed;
  }

  Future<void> _save(
    BuildContext context,
    PropertyEditorViewModel model,
  ) async {
    setState(() => _submitted = true);

    final id = await model.save(
      title: _title.text,
      priceText: _price.text,
      description: _description.text,
    );
    if (!context.mounted) return;

    final feedback = context.read<InteractionFeedbackService?>();
    if (id == null) {
      final submission = model.submission;
      if (submission is MutationFailure) {
        final message = brokerFailureText(context.l10n, model.writeFailure);
        feedback?.emit(FeedbackIntent.error);
        feedback?.announce(message);
        toast(context, message);
        return;
      }
      final price = _priceValue;
      final priceRefused =
          price == null || price <= 0 || model.isPriceTooHigh(price);
      setState(() {
        _step = model.neighbourhood == null
            ? 0
            : _title.text.trim().isEmpty || priceRefused
            ? 1
            : _kStepCount - 1;
      });
      feedback?.emit(FeedbackIntent.error);
      feedback?.announce(
        model.isPriceTooHigh(price)
            ? context.l10n.validationPriceTooHigh(
                PropertyEditorViewModel.maxPriceCfa,
              )
            : context.l10n.validationFixFirst,
      );
      return;
    }

    feedback?.emit(FeedbackIntent.success, eventId: 'B03:success:$id');
    toast(context, context.l10n.propertySaved);
    widget.onSaved(id);
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

class _Hint extends StatelessWidget {
  const _Hint(this.text, {this.bottom = 0});
  final String text;
  final double bottom;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: Insets.sm, bottom: bottom),
    child: Text(
      text,
      style: context.text.bodySmall!.copyWith(
        color: context.tones.inkSecondary,
      ),
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.only(top: Insets.sm),
      child: Row(
        spacing: Insets.xs,
        children: [
          Icon(FIcons.circleAlert, size: 16, color: context.tones.danger),
          Expanded(
            child: Text(
              message,
              style: context.text.bodySmall!.copyWith(
                color: context.tones.danger,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Suggested extends StatelessWidget {
  const _Suggested({required this.source, required this.written});
  final TextEditingController source;
  final String? written;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: source,
    builder: (context, value, _) => written == null || value.text != written
        ? const SizedBox.shrink()
        : _Hint(context.l10n.propertyTextSuggested),
  );
}
