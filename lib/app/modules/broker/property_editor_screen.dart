import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_photo_picker.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Ce que le serveur accepte réellement par bien.
///
/// L'API refuse la quatrième photo avec un 400. Offrir plus, c'est faire
/// choisir des photos pour rien puis échouer à la publication : l'éditeur
/// s'aligne donc toujours sur la valeur la plus stricte, quelle que soit la
/// limite annoncée par le service de photos qu'on lui injecte.
const int kServerPhotoLimit = 3;

/// Ramène n'importe quel [PhotoService] à la limite du serveur.
///
/// Décore plutôt que de modifier le service : la sélection et la compression
/// restent celles de la plateforme, seule la limite annoncée change — et
/// `WkPhotoPicker` la lit pour son compteur, son bouton et son motif de
/// désactivation.
class _ServerCappedPhotoService implements PhotoService {
  const _ServerCappedPhotoService(this._inner);

  final PhotoService _inner;

  @override
  int get maxPerProperty => _inner.maxPerProperty < kServerPhotoLimit
      ? _inner.maxPerProperty
      : kServerPhotoLimit;

  @override
  Future<String?> pick(PhotoSource source) => _inner.pick(source);
}

/// B03 — Ajouter ou modifier un bien.
class PropertyEditorScreen extends StatefulWidget {
  const PropertyEditorScreen({
    required this.onBack,
    required this.onSaved,
    required this.photos,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(String propertyId) onSaved;

  /// Sélection et compression des photos.
  final PhotoService photos;

  @override
  State<PropertyEditorScreen> createState() => _PropertyEditorScreenState();
}

class _PropertyEditorScreenState extends State<PropertyEditorScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _neighbourhood = TextEditingController();
  final TextEditingController _surface = TextEditingController();
  final TextEditingController _rooms = TextEditingController();
  final TextEditingController _description = TextEditingController();
  int _step = 0;
  bool _submitted = false;

  /// Incrémenté à chaque soumission : c'est ce qui fait rejouer la validation
  /// de tous les champs d'un coup.
  int _revalidateTick = 0;

  @override
  void initState() {
    super.initState();
    final Property? existing = context.read<PropertyEditorViewModel>().existing;
    if (existing != null) {
      _title.text = existing.title;
      _price.text = existing.price.toString();
      _neighbourhood.text = existing.neighbourhood;
      _surface.text = existing.surface?.toString() ?? '';
      _rooms.text = existing.rooms?.toString() ?? '';
      _description.text = existing.description;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _neighbourhood.dispose();
    _surface.dispose();
    _rooms.dispose();
    _description.dispose();
    super.dispose();
  }

  /// N'évalue rien avant la soumission : un titre libre ne peut jamais
  /// « devenir valide » tout seul.
  String? _requiredValidator(String value) {
    if (!_submitted) {
      return null;
    }
    return value.trim().isEmpty ? context.l10n.validationRequired : null;
  }

  String? _priceValidator(String value) {
    if (!_submitted) {
      return null;
    }
    final int? parsed = int.tryParse(value.replaceAll(RegExp(r'\D'), ''));
    if (parsed == null || parsed <= 0) {
      return context.l10n.validationPositiveNumber;
    }
    return null;
  }

  String _stepTitle(BuildContext context) => switch (_step) {
    0 => context.l10n.propertyEditorStepBasics,
    1 => context.l10n.propertyEditorStepDetails,
    2 => context.l10n.propertyEditorStepLocation,
    _ => context.l10n.propertyEditorStepMedia,
  };

  @override
  Widget build(BuildContext context) {
    final PropertyEditorViewModel model = context
        .watch<PropertyEditorViewModel>();

    return WkScaffold(
      topBar: WkTopBar(
        title: model.isEditing
            ? context.l10n.propertyEditorEdit
            : context.l10n.propertyEditorNew,
        onBack: _step == 0 ? widget.onBack : _previous,
      ),
      bottomAction: WkButton(
        label: _step == 3
            ? context.l10n.propertySave
            : context.l10n.propertyEditorNext,
        loading: model.submission.isSubmitting,
        onPressed: () => _step == 3 ? _save(context, model) : _next(),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: WkSpacing.lg),
        children: <Widget>[
          _StepHeader(current: _step + 1, total: 4, title: _stepTitle(context)),
          const SizedBox(height: WkSpacing.lg),
          if (model.prefilledFromPrevious)
            Padding(
              padding: const EdgeInsets.only(bottom: WkSpacing.md),
              child: Text(
                context.l10n.propertyAddAnother,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ...switch (_step) {
            0 => _buildBasics(context, model),
            1 => _buildDetails(context),
            2 => _buildLocation(context),
            _ => _buildMedia(context, model),
          },
        ],
      ),
    );
  }

  List<Widget> _buildBasics(
    BuildContext context,
    PropertyEditorViewModel model,
  ) => <Widget>[
    WkSelectField<TransactionKind>(
      label: context.l10n.fieldTransaction,
      value: model.transaction,
      onChanged: model.setTransaction,
      options: <WkOption<TransactionKind>>[
        WkOption<TransactionKind>(
          value: TransactionKind.rent,
          label: context.l10n.transactionRent,
          icon: Icons.vpn_key_outlined,
        ),
        WkOption<TransactionKind>(
          value: TransactionKind.sale,
          label: context.l10n.transactionSale,
          icon: Icons.sell_outlined,
        ),
      ],
    ),
    const SizedBox(height: WkSpacing.md),
    WkSelectField<PropertyKind>(
      label: context.l10n.fieldKind,
      value: model.kind,
      onChanged: model.setKind,
      options: <WkOption<PropertyKind>>[
        for (final PropertyKind kind in PropertyKind.values)
          WkOption<PropertyKind>(
            value: kind,
            label: WkFormat.propertyKind(context.l10n, kind),
            icon: WkFormat.propertyKindIcon(kind),
          ),
      ],
    ),
  ];

  List<Widget> _buildDetails(BuildContext context) => <Widget>[
    WkTextField(
      label: context.l10n.fieldTitle,
      hint: context.l10n.fieldTitleHint,
      controller: _title,
      validator: _requiredValidator,
      revalidateTick: _revalidateTick,
    ),
    WkTextField(
      label: context.l10n.fieldPrice,
      controller: _price,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: _priceValidator,
      revalidateTick: _revalidateTick,
    ),
    WkTextField(
      label: context.l10n.fieldSurface,
      controller: _surface,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    ),
    WkTextField(
      label: context.l10n.fieldRooms,
      controller: _rooms,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    ),
    WkTextField(label: context.l10n.fieldDescription, controller: _description),
  ];

  List<Widget> _buildLocation(BuildContext context) => <Widget>[
    WkTextField(
      label: context.l10n.fieldNeighbourhood,
      controller: _neighbourhood,
      validator: _requiredValidator,
      revalidateTick: _revalidateTick,
    ),
  ];

  List<Widget> _buildMedia(
    BuildContext context,
    PropertyEditorViewModel model,
  ) => <Widget>[
    WkPhotoPicker(
      paths: model.photos,
      service: _ServerCappedPhotoService(widget.photos),
      onChanged: model.setPhotos,
    ),
    const SizedBox(height: WkSpacing.xs),
    // Dit avant de choisir, pas après un refus du serveur.
    Text(
      context.l10n.photosServerLimit(kServerPhotoLimit),
      style: context.text.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    ),
    const SizedBox(height: WkSpacing.md),
    WkSelectField<PropertyStatus>(
      label: context.l10n.fieldStatus,
      value: model.status,
      onChanged: model.setStatus,
      options: <WkOption<PropertyStatus>>[
        for (final PropertyStatus status in PropertyStatus.values)
          WkOption<PropertyStatus>(
            value: status,
            label: WkFormat.propertyStatus(context.l10n, status),
            icon: switch (status) {
              PropertyStatus.available => Icons.check_circle_outline,
              PropertyStatus.reserved => Icons.schedule,
              PropertyStatus.closed => Icons.do_not_disturb_on_outlined,
            },
          ),
      ],
    ),
    const SizedBox(height: WkSpacing.sm),
    Text(
      model.status == PropertyStatus.closed
          ? context.l10n.propertyStatusImpactClosed
          : context.l10n.propertyStatusImpactVisible,
      style: context.text.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    ),
  ];

  void _next() {
    setState(() {
      _step++;
    });
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.stepValid,
      eventId: 'B03:step:$_step',
    );
  }

  void _previous() {
    setState(() {
      _step--;
    });
  }

  Future<void> _save(
    BuildContext context,
    PropertyEditorViewModel model,
  ) async {
    // La soumission révèle ce qui manque. Le bouton n'était pas grisé : c'est
    // en appuyant qu'on apprend, pas en devinant.
    setState(() {
      _submitted = true;
      _revalidateTick++;
    });

    final String? id = await model.save(
      title: _title.text,
      priceText: _price.text,
      neighbourhood: _neighbourhood.text,
      description: _description.text,
      surfaceText: _surface.text,
      roomsText: _rooms.text,
    );

    if (!context.mounted) {
      return;
    }

    if (id == null) {
      final InteractionFeedbackService? feedback = context
          .read<InteractionFeedbackService?>();
      final MutationState submission = model.submission;

      if (submission is MutationFailure) {
        // Le formulaire est bon : c'est l'enregistrement qui a échoué. Le
        // renvoyer à l'étape 2 en annonçant « corrigez d'abord » lui faisait
        // relire un formulaire sans faute pendant que la vraie cause — le
        // réseau — restait tue.
        feedback?.emit(FeedbackIntent.error);
        final String message = failureMessage(context.l10n, submission.failure);
        feedback?.announce(message);
        WkToast.show(context, message: message);
        return;
      }

      setState(() {
        _step = _detailsInvalid() ? 1 : 2;
      });
      // Une erreur pour la soumission entière, pas une par champ vide.
      feedback?.emit(FeedbackIntent.error);
      feedback?.announce(context.l10n.validationFixFirst);
      return;
    }

    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B03:success:$id',
    );
    WkToast.show(context, message: context.l10n.propertySaved);
    widget.onSaved(id);
  }

  bool _detailsInvalid() {
    final int? price = int.tryParse(_price.text.replaceAll(RegExp(r'\D'), ''));
    return _title.text.trim().isEmpty || price == null || price <= 0;
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.current,
    required this.total,
    required this.title,
  });

  final int current;
  final int total;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(WkRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(WkSpacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: WkTouch.min,
                height: WkTouch.min,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(WkRadius.full),
                ),
                child: Text(
                  '$current/$total',
                  style: context.text.titleMedium?.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: WkSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.propertyEditorStep(current, total),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      title,
                      style: context.text.titleMedium?.copyWith(
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
