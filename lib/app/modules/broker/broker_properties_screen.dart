import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class BrokerPropertiesViewModel extends ChangeNotifier {
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
      _state = ScreenState<List<Property>>.error(brokerFailure(error));
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
      _mutation = MutationState.failure(brokerFailure(error));
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
      await _properties.save(
        Property(
          id: property.id,
          brokerId: property.brokerId,
          kind: property.kind,
          transaction: property.transaction,
          title: property.title,
          description: property.description,
          price: property.price,
          surface: property.surface,
          rooms: property.rooms,
          position: property.position,
          neighbourhood: property.neighbourhood,
          photoAssets: property.photoAssets,
          status: status,
          createdAt: property.createdAt,
        ),
      );
      _mutation = const MutationState.success();
    } on Object catch (error) {
      _mutation = MutationState.failure(brokerFailure(error));
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
        error: (failure) => failureState(context, failure, onRetry: model.load),
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
        if (model.mutation case final MutationFailure failed)
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
                title: Text(failureText(l, failed.failure)),
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

    if (target == PropertyStatus.closed) {
      final confirmed = await confirm(
        context,
        title: WkFormat.propertyStatus(l, target),
        message: l.propertyStatusImpactClosed,
        action: l.propertyStatusChange,
      );
      if (!confirmed || !context.mounted) return;
    }

    await model.changeStatus(property, target);
    if (!context.mounted || _announceFailure(context, model)) return;
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B02:success:status-${property.id}-${target.name}',
    );
    toast(context, l.propertyStatusChanged);
  }

  Future<void> _delete(
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
    if (!confirmed || !context.mounted) return;

    await model.delete(property.id);
    if (!context.mounted || _announceFailure(context, model)) return;
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B02:success:delete-${property.id}',
    );
    toast(context, l.propertyDeleted);
  }

  bool _announceFailure(BuildContext context, BrokerPropertiesViewModel model) {
    final mutation = model.mutation;
    if (mutation is! MutationFailure) return false;
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
    toast(context, failureText(context.l10n, mutation.failure));
    return true;
  }
}

IconData statusIcon(PropertyStatus status) => switch (status) {
  PropertyStatus.available => FIcons.circleCheck,
  PropertyStatus.reserved => FIcons.clock,
  PropertyStatus.closed => FIcons.ban,
};

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
