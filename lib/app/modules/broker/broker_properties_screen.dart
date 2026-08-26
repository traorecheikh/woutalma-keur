import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/modules/client/property/property_screen.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class BrokerPropertiesViewModel extends ChangeNotifier with BrokerFailures {
  BrokerPropertiesViewModel({
    required PropertyRepository properties,
    required String brokerId,
  }) : _properties = properties,
       _brokerId = brokerId;

  final PropertyRepository _properties;
  final String _brokerId;

  ScreenState<List<Property>> _state =
      const ScreenState<List<Property>>.initial();

  ScreenState<List<Property>> get state => _state;

  Property? get mostRecent {
    final List<Property>? all = _state.valueOrNull;
    if (all == null || all.isEmpty) {
      return null;
    }
    return all.first;
  }

  MutationState _mutation = const MutationState.idle();

  MutationState get mutation => _mutation;

  Future<void>? _loading;

  Future<void> load() {
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    _state = const ScreenState<List<Property>>.loading();
    notifyListeners();

    try {
      final List<Property> owned = await _properties.byBroker(_brokerId);
      owned.sort(
        (Property a, Property b) => b.createdAt.compareTo(a.createdAt),
      );

      _state = owned.isEmpty
          ? const ScreenState<List<Property>>.empty()
          : ScreenState<List<Property>>.data(owned);
    } on Object catch (error) {
      _state = ScreenState<List<Property>>.error(onLoadError(error));
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _mutation = const MutationState.submitting();
    notifyListeners();
    try {
      await _properties.delete(id);
      _mutation = const MutationState.success();
    } on Object catch (error) {
      _mutation = MutationState.failure(onWriteError(error));
      notifyListeners();
      return;
    }
    await load();
  }

  Future<void> changeStatus(Property property, PropertyStatus status) async {
    if (property.status == status) {
      _mutation = const MutationState.idle();
      notifyListeners();
      return;
    }
    _mutation = const MutationState.submitting();
    notifyListeners();
    try {
      // `copyWith` et non un `Property(...)` recomposé : l'ancienne version
      // oubliait `voiceAsset`, et le dépôt distant lisait cet oubli comme un
      // retrait — le message vocal disparaissait à chaque « Marquer loué ».
      await _properties.save(property.copyWith(status: status));
      _mutation = const MutationState.success();
    } on Object catch (error) {
      _mutation = MutationState.failure(onWriteError(error));
      notifyListeners();
      return;
    }
    await load();
  }
}

class BrokerPropertiesScreen extends StatefulWidget {
  const BrokerPropertiesScreen({
    required this.onAdd,
    required this.onEdit,
    required this.onPreview,
    super.key,
  });

  final VoidCallback onAdd;
  final void Function(Property property) onEdit;
  final void Function(Property property) onPreview;

  @override
  State<BrokerPropertiesScreen> createState() => _BrokerPropertiesScreenState();
}

class _BrokerPropertiesScreenState extends State<BrokerPropertiesScreen> {
  PropertyStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BrokerPropertiesViewModel>();
    final l = context.l10n;
    return AppScaffold(
      title: l.brokerPropertiesTitle,
      showBack: false,
      onRefresh: model.load,
      actions: [
        AppIconButton(
          icon: FIcons.plus,
          label: l.propertyAdd,
          onTap: widget.onAdd,
        ),
      ],
      body: model.state.map(
        initial: () => const AppSkeleton(height: 200),
        loading: () => const AppSkeleton(height: 200),
        empty: () => AppState(
          kind: AppStateKind.empty,
          icon: FIcons.house,
          title: l.brokerPropertiesEmptyTitle,
          message: l.brokerPropertiesEmptyBody,
          actionLabel: l.propertyAdd,
          onAction: widget.onAdd,
        ),
        error: (_) =>
            brokerFailureState(context, model.loadFailure, onRetry: model.load),
        data: (owned) => _list(context, model, owned),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    BrokerPropertiesViewModel model,
    List<Property> owned,
  ) {
    final l = context.l10n;
    final shown = _filter == null
        ? owned
        : owned.where((p) => p.status == _filter).toList();
    return Column(
      children: [
        AppChoice<PropertyStatus?>(
          scroll: true,
          options: const [null, ...PropertyStatus.values],
          selected: _filter,
          onChanged: (value) => setState(() => _filter = value),
          label: (value) => value == null
              ? l.exploreCategoryAll
              : WkFormat.propertyStatus(l, value),
          icon: (value) => value == null ? null : statusIcon(value),
        ),
        if (model.mutation is MutationFailure)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              Insets.sm,
              Insets.page,
              0,
            ),
            child: Semantics(
              liveRegion: true,
              child: FAlert(
                variant: .destructive,
                title: Text(brokerFailureText(l, model.writeFailure)),
              ),
            ),
          ),
        Expanded(
          child: shown.isEmpty
              ? AppState(
                  kind: AppStateKind.empty,
                  title: l.stateEmptyTitle,
                  message: l.stateEmptyBody,
                  actionLabel: l.exploreClearFilters,
                  onAction: () => setState(() => _filter = null),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    Insets.page,
                    Insets.sm,
                    Insets.page,
                    Insets.xxl,
                  ),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Insets.lg),
                  itemBuilder: (_, i) => _Listing(
                    property: shown[i],
                    onPreview: () => widget.onPreview(shown[i]),
                    onEdit: () => widget.onEdit(shown[i]),
                    onStatus: () => _status(context, model, shown[i]),
                    onDelete: () => _delete(context, model, shown[i]),
                    onMore: () => _more(context, model, shown[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _more(
    BuildContext context,
    BrokerPropertiesViewModel model,
    Property property,
  ) async {
    final l = context.l10n;
    final toggle = property.status == PropertyStatus.closed
        ? PropertyStatus.available
        : PropertyStatus.closed;
    await showAppSheet<void>(
      context,
      title: property.title,
      child: AppCard.rows([
        AppRow(
          title: l.propertyPreviewTitle,
          leading: const Icon(FIcons.eye),
          onTap: () {
            popSheet(context);
            widget.onPreview(property);
          },
        ),
        AppRow(
          title: l.propertyEditorEdit,
          leading: const Icon(FIcons.pencil),
          onTap: () {
            popSheet(context);
            widget.onEdit(property);
          },
        ),
        // Le changement le plus fréquent en un appui : passer par la liste des
        // trois statuts pour dire « c'est loué » demandait trois écrans.
        AppRow(
          title: toggle == PropertyStatus.closed
              ? l.propertyMarkClosed
              : l.propertyMarkAvailable,
          leading: Icon(statusIcon(toggle)),
          onTap: () {
            popSheet(context);
            _applyStatus(context, model, property, toggle);
          },
        ),
        AppRow(
          title: l.propertyStatusChange,
          leading: const Icon(FIcons.refreshCw),
          onTap: () {
            popSheet(context);
            _status(context, model, property);
          },
        ),
        AppRow(
          title: l.commonDelete,
          leading: const Icon(FIcons.trash2),
          danger: true,
          onTap: () {
            popSheet(context);
            _delete(context, model, property);
          },
        ),
      ]),
    );
  }

  Future<void> _status(
    BuildContext context,
    BrokerPropertiesViewModel model,
    Property property,
  ) async {
    final l = context.l10n;
    final target = await pick<PropertyStatus>(
      context,
      title: l.propertyStatusTitle,
      options: PropertyStatus.values,
      selected: property.status,
      label: (value) => WkFormat.propertyStatus(l, value),
      icon: statusIcon,
    );
    if (target == null || !context.mounted) return;
    await _applyStatus(context, model, property, target);
  }

  Future<void> _applyStatus(
    BuildContext context,
    BrokerPropertiesViewModel model,
    Property property,
    PropertyStatus target,
  ) => applyPropertyStatus(context, model, property, target);

  Future<void> _delete(
    BuildContext context,
    BrokerPropertiesViewModel model,
    Property property,
  ) => deleteProperty(context, model, property);
}

/// Change le statut, en disant d'abord ce que ça retire aux clients.
///
/// Partagée avec B04 : l'aperçu public et la liste doivent poser la même
/// question et écrire la même chose. Rend vrai quand l'écriture a eu lieu —
/// `mutation` ne le dit pas, elle garde le résultat de l'action précédente
/// quand celle-ci est annulée.
Future<bool> applyPropertyStatus(
  BuildContext context,
  BrokerPropertiesViewModel model,
  Property property,
  PropertyStatus target,
) async {
  final l = context.l10n;
  if (target == PropertyStatus.closed) {
    final confirmed = await confirm(
      context,
      title: WkFormat.propertyStatus(l, target),
      message: l.propertyStatusImpactClosed,
      action: l.propertyStatusChange,
    );
    if (!confirmed || !context.mounted) return false;
  }

  await model.changeStatus(property, target);
  if (!context.mounted) return false;
  if (_announceFailure(context, model)) return false;
  context.read<InteractionFeedbackService?>()?.emit(
    FeedbackIntent.success,
    eventId: 'B02:success:status-${property.id}-${target.name}',
  );
  toast(context, l.propertyStatusChanged);
  return true;
}

Future<bool> deleteProperty(
  BuildContext context,
  BrokerPropertiesViewModel model,
  Property property,
) async {
  final l = context.l10n;
  final confirmed = await confirm(
    context,
    title: l.propertyDeleteTitle(property.title),
    message: l.propertyDeleteBody,
    action: l.propertyDelete,
    danger: true,
  );
  if (!confirmed || !context.mounted) return false;

  await model.delete(property.id);
  if (!context.mounted) return false;
  if (_announceFailure(context, model)) return false;
  context.read<InteractionFeedbackService?>()?.emit(
    FeedbackIntent.success,
    eventId: 'B02:success:delete-${property.id}',
  );
  toast(context, l.propertyDeleted);
  return true;
}

bool _announceFailure(BuildContext context, BrokerPropertiesViewModel model) {
  if (model.mutation is! MutationFailure) return false;
  context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
  toast(context, brokerFailureText(context.l10n, model.writeFailure));
  return true;
}

IconData statusIcon(PropertyStatus status) => switch (status) {
  PropertyStatus.available => FIcons.circleCheck,
  PropertyStatus.reserved => FIcons.clock,
  PropertyStatus.closed => FIcons.ban,
};

/// B04 — l'aperçu public, plus ce que le courtier peut en faire.
///
/// L'aperçu ne montrait aucune action : constater qu'un bien est mal
/// renseigné ou déjà loué obligeait à revenir à B02 pour agir dessus.
class BrokerPropertyPreviewScreen extends StatelessWidget {
  const BrokerPropertyPreviewScreen({
    required this.onBack,
    required this.onEdit,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(Property property) onEdit;

  @override
  Widget build(BuildContext context) {
    final preview = context.watch<PropertyViewModel>();
    final property = preview.state.valueOrNull?.property;
    return Column(
      children: [
        Expanded(
          child: PropertyScreen(
            onBack: onBack,
            // Le bouton de contact n'a pas de sens pour le courtier qui
            // regarde son propre bien.
            onOpenBroker: (String _) {},
            publicPreview: true,
          ),
        ),
        if (property != null)
          BrokerPropertyActions(
            property: property,
            onEdit: () => onEdit(property),
            onChanged: preview.load,
            onDeleted: onBack,
          ),
      ],
    );
  }
}

class BrokerPropertyActions extends StatelessWidget {
  const BrokerPropertyActions({
    required this.property,
    required this.onEdit,
    required this.onChanged,
    required this.onDeleted,
    super.key,
  });

  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onChanged;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final model = context.watch<BrokerPropertiesViewModel>();
    final toggle = property.status == PropertyStatus.closed
        ? PropertyStatus.available
        : PropertyStatus.closed;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.page,
          Insets.sm,
          Insets.page,
          Insets.sm,
        ),
        child: Row(
          spacing: Insets.sm,
          children: [
            Expanded(
              child: AppButton(
                l.commonEdit,
                icon: FIcons.pencil,
                variant: AppButtonVariant.secondary,
                onPressed: onEdit,
              ),
            ),
            Expanded(
              child: AppButton(
                toggle == PropertyStatus.closed
                    ? l.propertyMarkClosed
                    : l.propertyMarkAvailable,
                icon: statusIcon(toggle),
                variant: AppButtonVariant.secondary,
                loading: model.mutation.isSubmitting,
                onPressed: () async {
                  if (await applyPropertyStatus(
                    context,
                    model,
                    property,
                    toggle,
                  )) {
                    onChanged();
                  }
                },
              ),
            ),
            AppIconButton(
              icon: FIcons.trash2,
              label: l.propertyDelete,
              color: context.tones.danger,
              onTap: () async {
                if (await deleteProperty(context, model, property)) {
                  onDeleted();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

AppTag statusTag(BuildContext context, PropertyStatus status) => AppTag(
  WkFormat.propertyStatus(context.l10n, status),
  icon: statusIcon(status),
  tone: switch (status) {
    PropertyStatus.available => AppTone.success,
    PropertyStatus.reserved => AppTone.warning,
    PropertyStatus.closed => AppTone.neutral,
  },
);

class _Listing extends StatelessWidget {
  const _Listing({
    required this.property,
    required this.onPreview,
    required this.onEdit,
    required this.onStatus,
    required this.onDelete,
    required this.onMore,
  });

  final Property property;
  final VoidCallback onPreview, onEdit, onStatus, onDelete, onMore;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Slidable(
      key: ValueKey(property.id),
      groupTag: 'broker-properties',
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: .5,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            icon: FIcons.pencil,
            label: l.commonEdit,
            backgroundColor: context.tones.sunken,
            foregroundColor: context.colors.onSurface,
            borderRadius: Radii.card,
          ),
          SlidableAction(
            onPressed: (_) => onStatus(),
            icon: FIcons.refreshCw,
            label: l.fieldStatus,
            backgroundColor: context.tones.sunken,
            foregroundColor: context.colors.onSurface,
            borderRadius: Radii.card,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: .3,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            icon: FIcons.trash2,
            label: l.commonDelete,
            backgroundColor: context.tones.danger,
            foregroundColor: context.colors.onPrimary,
            borderRadius: Radii.card,
          ),
        ],
      ),
      child: AppCard(
        onTap: onPreview,
        onLongPress: onMore,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AppPhoto(
                  property.photoAssets.firstOrNull,
                  aspectRatio: 16 / 10,
                  radius: BorderRadius.zero,
                ),
                if (property.hasVoiceNote)
                  Positioned(
                    top: Insets.md,
                    left: Insets.md,
                    child: AppOverlayChip(
                      context.l10n.voiceNoteBadge,
                      icon: FIcons.mic,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(Insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          WkFormat.price(
                            l,
                            property.price,
                            property.transaction,
                          ),
                          style: AppText.moneyLg,
                        ),
                      ),
                      statusTag(context, property.status),
                      // Glisser et appuyer longuement ne s'annoncent nulle
                      // part : sans ce bouton, modifier ou retirer un bien
                      // n'avait aucune porte visible.
                      AppIconButton(
                        icon: FIcons.ellipsis,
                        label: l.propertyMoreActions,
                        onTap: onMore,
                      ),
                    ],
                  ),
                  const SizedBox(height: Insets.xs),
                  Text(
                    property.title,
                    style: context.text.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Insets.xs),
                  Text(
                    '${WkFormat.propertyKind(l, property.kind)} · ${property.neighbourhood}',
                    style: context.text.bodySmall!.copyWith(
                      color: context.tones.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
