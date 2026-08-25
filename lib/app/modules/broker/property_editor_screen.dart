import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/location_service.dart';
import 'package:woutalma_keur/app/domain/property_description.dart';
import 'package:woutalma_keur/app/modules/broker/property_editor_view_model.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/domain/voice_note_service.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_photo_picker.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_voice_note.dart';
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
    required this.voiceNotes,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(String propertyId) onSaved;

  /// Sélection et compression des photos.
  final PhotoService photos;
  final VoiceNoteRecorder voiceNotes;

  @override
  State<PropertyEditorScreen> createState() => _PropertyEditorScreenState();
}

/// Nombre d'étapes du formulaire.
///
/// Trois, et non quatre : le quartier est devenu un choix qui porte son propre
/// point, donc l'ancienne étape « quartier et point carte » n'avait plus qu'un
/// champ à montrer. Elle rejoint le type et l'opération, qui sont eux aussi
/// des choix — la première étape se traverse maintenant sans clavier.
const int _kStepCount = 3;

class _PropertyEditorScreenState extends State<PropertyEditorScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _description = TextEditingController();
  int _step = 0;
  bool _submitted = false;

  /// Titre proposé par l'écran, tant que personne ne l'a corrigé.
  ///
  /// Gardé pour pouvoir dire « c'est nous qui l'avons écrit » : une valeur
  /// devinée qu'on ne remarque pas devient une annonce fausse publiée sous
  /// son nom.
  String? _suggestedTitle;

  /// Dernière description écrite par l'écran.
  ///
  /// Sert de droit de réécriture : tant que le champ contient mot pour mot ce
  /// que l'écran y a mis, une nouvelle réponse — le prix, la surface — le
  /// remet à jour. Dès la première frappe du courtier, la phrase est la
  /// sienne et n'est plus jamais touchée.
  String? _composedDescription;

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
      _description.text = existing.description;
      // Une description déjà composée reste réécrivable ; une phrase écrite
      // par le courtier ne l'est pas. Le composeur le sait sans qu'on ait à
      // poser un drapeau sur l'entité.
      if (PropertyDescriptionComposer.isComposedFor(existing)) {
        _composedDescription = existing.description;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
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
    0 => context.l10n.propertyEditorStepKind,
    1 => context.l10n.propertyEditorStepDetails,
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
        label: _isLastStep
            ? context.l10n.propertySave
            : context.l10n.propertyEditorNext,
        loading: model.submission.isSubmitting,
        onPressed: () => _isLastStep ? _save(context, model) : _next(model),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: WkSpacing.lg),
        children: <Widget>[
          _StepHeader(
            current: _step + 1,
            total: _kStepCount,
            title: _stepTitle(context),
          ),
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
            1 => _buildDetails(context, model),
            _ => _buildMedia(context, model),
          },
        ],
      ),
    );
  }

  bool get _isLastStep => _step == _kStepCount - 1;

  List<Widget> _buildBasics(
    BuildContext context,
    PropertyEditorViewModel model,
  ) => <Widget>[
    WkSelectField<TransactionKind>(
      label: context.l10n.fieldTransaction,
      value: model.transaction,
      onChanged: (TransactionKind value) =>
          _answer(model, model.setTransaction, value),
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
      onChanged: (PropertyKind value) => _answer(model, model.setKind, value),
      options: <WkOption<PropertyKind>>[
        for (final PropertyKind kind in PropertyKind.values)
          WkOption<PropertyKind>(
            value: kind,
            label: WkFormat.propertyKind(context.l10n, kind),
            icon: WkFormat.propertyKindIcon(kind),
          ),
      ],
    ),
    const SizedBox(height: WkSpacing.md),
    // Le quartier était le champ libre le plus coûteux du formulaire : dix à
    // vingt frappes au clavier, une orthographe par courtier — « Medina »,
    // « Médina », « médina » — et une recherche client qui ne les rapproche
    // pas. La liste est celle du produit, et chaque entrée porte son point.
    WkSelectField<Neighbourhood>(
      label: context.l10n.fieldNeighbourhood,
      value: model.neighbourhood,
      onChanged: (Neighbourhood value) =>
          _answer(model, model.setNeighbourhood, value),
      options: <WkOption<Neighbourhood>>[
        for (final Neighbourhood area in model.neighbourhoodOptions)
          WkOption<Neighbourhood>(
            value: area,
            label: area.name,
            icon: Icons.place_outlined,
          ),
      ],
    ),
    if (_submitted && model.neighbourhood == null)
      _FieldError(message: context.l10n.validationRequired),
  ];

  List<Widget> _buildDetails(
    BuildContext context,
    PropertyEditorViewModel model,
  ) => <Widget>[
    WkTextField(
      label: context.l10n.fieldTitle,
      // Aucun exemple gris : dès qu'un quartier est choisi, le champ arrive
      // déjà rempli d'un vrai titre, qui montre mieux qu'un placeholder ce
      // qu'on attend — et un exemple complet ne tient pas sur une ligne à
      // ×1.3.
      controller: _title,
      // Le serveur refuse au-delà de 120 caractères : couper à la frappe vaut
      // mieux qu'un 400 après avoir choisi ses photos.
      maxLength: 120,
      validator: _requiredValidator,
      revalidateTick: _revalidateTick,
    ),
    _SuggestedNote(source: _title, written: _suggestedTitle),
    WkTextField(
      label: context.l10n.fieldPrice,
      controller: _price,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      // Onze chiffres : le plafond du serveur est de dix milliards.
      maxLength: 11,
      validator: _priceValidator,
      // Le prix est la dernière donnée de la phrase composée : la description
      // le suit pendant qu'on le tape.
      onChanged: (_) => setState(() => _composeDescription(model)),
      revalidateTick: _revalidateTick,
    ),
    // Surface et pièces restent facultatives — un terrain et une chambre ne
    // s'annoncent pas avec la même exigence — mais elles se répondent
    // désormais d'un geste, jamais au clavier.
    WkSelectField<int?>(
      label: context.l10n.fieldSurfaceChoice,
      value: model.surface,
      onChanged: (int? value) => _answer(model, model.setSurface, value),
      options: <WkOption<int?>>[
        WkOption<int?>(value: null, label: context.l10n.commonUnspecified),
        for (final int step in model.surfaceOptions)
          WkOption<int?>(value: step, label: context.l10n.surfaceValue(step)),
      ],
    ),
    if (model.asksRooms) ...<Widget>[
      const SizedBox(height: WkSpacing.md),
      // Gardé malgré la remarque « c'est déjà dans le titre » : la recherche
      // client indexe `rooms` (docs → `discovery.dart`, champ « N pieces »)
      // et la fiche l'affiche en pastille. Le supprimer retirerait
      // « 3 pièces » des résultats. Il sert d'ailleurs à écrire le titre.
      WkSelectField<int?>(
        label: context.l10n.fieldRooms,
        value: model.rooms,
        onChanged: (int? value) => _answer(model, model.setRooms, value),
        options: <WkOption<int?>>[
          WkOption<int?>(value: null, label: context.l10n.commonUnspecified),
          for (final int step in model.roomOptions)
            WkOption<int?>(value: step, label: context.l10n.roomCount(step)),
        ],
      ),
    ],
    const SizedBox(height: WkSpacing.md),
    WkTextField(label: context.l10n.fieldDescription, controller: _description),
    _SuggestedNote(source: _description, written: _composedDescription),
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
    const SizedBox(height: WkSpacing.lg),
    WkVoiceNoteRecorder(
      asset: model.voiceNote,
      recorder: widget.voiceNotes,
      onChanged: model.setVoiceNote,
    ),
    const SizedBox(height: WkSpacing.md),
    // Publier, c'est rendre disponible. Demander le statut à la création
    // faisait choisir « Disponible » à chaque annonce, et offrait « Vendu »
    // à un bien qui n'existait pas encore. B02 porte déjà « Changer le
    // statut », avec sa confirmation. Ici, le champ n'apparaît qu'en
    // modification, là où il répond à une vraie question.
    if (model.isEditing) ...<Widget>[
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
    ],
    Text(
      model.status == PropertyStatus.closed
          ? context.l10n.propertyStatusImpactClosed
          : context.l10n.propertyStatusImpactVisible,
      style: context.text.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    ),
  ];

  void _next(PropertyEditorViewModel model) {
    setState(() {
      _step++;
      if (_step == 1) {
        _suggestTitle(model);
      }
      // À chaque passage d'étape : la description gagne ce qui vient d'être
      // répondu — le quartier en arrivant à l'étape 2, le prix et la surface
      // en la quittant.
      _composeDescription(model);
    });
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.stepValid,
      eventId: 'B03:step:$_step',
    );
  }

  /// Écrit un titre à partir de ce qui vient d'être choisi.
  ///
  /// « Appartement 3 pièces à Mermoz » : c'est exactement la phrase que le
  /// courtier tapait au clavier après avoir déjà répondu aux trois questions
  /// qui la composent. L'écran la propose, elle reste corrigeable, et le
  /// signalement disparaît dès la première frappe.
  ///
  /// Réécrit tant que le champ contient encore sa propre phrase : le nombre de
  /// pièces se choisit à l'étape 2, après la première écriture, et un titre
  /// figé à « Appartement à Mermoz » aurait perdu ce que le courtier venait de
  /// répondre. Sans quartier choisi, ou sur un titre saisi à la main, l'écran
  /// n'écrit rien.
  void _suggestTitle(PropertyEditorViewModel model) {
    final Neighbourhood? area = model.neighbourhood;
    final String current = _title.text.trim();
    if (area == null ||
        (current.isNotEmpty && current != _suggestedTitle?.trim())) {
      return;
    }
    final String kind = WkFormat.propertyKind(context.l10n, model.kind);
    final int? rooms = model.asksRooms ? model.rooms : null;
    final String suggestion = rooms == null
        ? context.l10n.propertyTitleFromKind(kind, area.name)
        : context.l10n.propertyTitleFromRooms(
            kind,
            context.l10n.roomCount(rooms),
            area.name,
          );
    _title.text = suggestion;
    _suggestedTitle = suggestion;
  }

  /// Enregistre une réponse, puis remet la description à jour.
  ///
  /// Chaque choix change ce que la phrase devrait dire. La réécrire au
  /// changement, et pas seulement au passage d'étape, évite de publier une
  /// description qui décrit l'avant-dernière version du bien.
  void _answer<T>(
    PropertyEditorViewModel model,
    void Function(T value) apply,
    T value,
  ) {
    apply(value);
    setState(() {
      _suggestTitle(model);
      _composeDescription(model);
    });
  }

  /// Écrit la description à partir des mêmes réponses.
  ///
  /// La phrase vient de `lib/app/domain/property_description.dart` : rien
  /// qui ne soit dans les données, aucun agrément inventé au nom du courtier.
  /// N'écrit que sur un champ vide ou sur sa propre phrase précédente.
  void _composeDescription(PropertyEditorViewModel model) {
    final String current = _description.text.trim();
    if (current.isNotEmpty && current != _composedDescription?.trim()) {
      return;
    }
    final String composed = PropertyDescriptionComposer.compose(
      PropertyDescriptionDraft(
        kind: model.kind,
        transaction: model.transaction,
        price: int.tryParse(_price.text.replaceAll(RegExp(r'\D'), '')) ?? 0,
        surface: model.surface,
        rooms: model.asksRooms ? model.rooms : null,
        neighbourhood: model.neighbourhood?.name ?? '',
      ),
    );
    _description.text = composed;
    _composedDescription = composed;
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
      description: _description.text,
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
        // La **première** étape fautive, dans l'ordre où on l'a traversée :
        // renvoyer au titre quelqu'un à qui il manque le quartier lui fait
        // relire un champ correct.
        _step = model.neighbourhood == null
            ? 0
            : _detailsInvalid()
            ? 1
            : _kStepCount - 1;
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

/// Dit qu'un texte a été écrit par l'écran, tant qu'il l'est encore.
///
/// Une valeur devinée qu'on ne remarque pas devient une annonce fausse publiée
/// sous son nom. La mention disparaît à la première frappe : à ce moment-là,
/// la phrase est bien celle du courtier.
class _SuggestedNote extends StatelessWidget {
  const _SuggestedNote({required this.source, required this.written});

  final TextEditingController source;

  /// Ce que l'écran a écrit, ou `null` s'il n'a rien écrit.
  final String? written;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: source,
      builder: (BuildContext context, TextEditingValue value, _) {
        if (written == null || value.text != written) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: WkSpacing.sm),
          child: Text(
            context.l10n.propertyTextSuggested,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

/// Message d'erreur d'un champ qui n'est pas un [WkTextField].
///
/// Un sélecteur n'a pas de ligne d'aide : sans ce complément, un quartier
/// manquant renvoyait à l'étape 1 sans rien y montrer.
class _FieldError extends StatelessWidget {
  const _FieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: WkSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: WkIconSize.md,
              color: context.colors.error,
            ),
            const SizedBox(width: WkSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
