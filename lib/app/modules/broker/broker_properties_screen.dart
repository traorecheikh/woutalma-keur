import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_confirm_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Coordonne B02.
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

  /// Le dernier bien publié, pour pré-remplir le suivant.
  Property? get mostRecent {
    final List<Property>? all = _state.valueOrNull;
    if (all == null || all.isEmpty) {
      return null;
    }
    return all.first;
  }

  Future<void> load() async {
    _state = const ScreenState<List<Property>>.loading();
    notifyListeners();

    // Tous les biens, y compris les clos : la gestion voit ce que la
    // découverte cache.
    final List<Property> owned = await _properties.byBroker(_brokerId);
    owned.sort((Property a, Property b) => b.createdAt.compareTo(a.createdAt));

    _state = owned.isEmpty
        ? const ScreenState<List<Property>>.empty()
        : ScreenState<List<Property>>.data(owned);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _properties.delete(id);
    await load();
  }

  /// Change la disponibilité d'un bien.
  ///
  /// C'est le geste le plus lourd de conséquence côté client : passer en
  /// vendu ou loué retire immédiatement le bien des recherches. L'écran
  /// l'annonce avant de valider.
  Future<void> changeStatus(Property property, PropertyStatus status) async {
    if (property.status == status) {
      return;
    }
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
    await load();
  }
}

/// B02 — Mes biens.
class BrokerPropertiesScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final BrokerPropertiesViewModel model = context
        .watch<BrokerPropertiesViewModel>();

    return WkScaffold(
      extendBody: true,
      topBar: WkTopBar(title: context.l10n.brokerPropertiesTitle),
      bottomAction: WkButton(
        label: context.l10n.propertyAdd,
        icon: Icons.add,
        onPressed: onAdd,
      ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => WkEmptyState(
          icon: Icons.home_work_outlined,
          title: context.l10n.brokerPropertiesEmptyTitle,
          body: context.l10n.brokerPropertiesEmptyBody,
          actionLabel: context.l10n.propertyAdd,
          onAction: onAdd,
        ),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (List<Property> owned) => ListView.separated(
          padding: EdgeInsets.only(
            bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
          ),
          itemCount: owned.length,
          separatorBuilder: (_, _) => const SizedBox(height: WkSpacing.sm),
          itemBuilder: (BuildContext context, int index) => _OwnedTile(
            property: owned[index],
            onEdit: () => onEdit(owned[index]),
            onPreview: () => onPreview(owned[index]),
            onStatus: () => _changeStatus(context, model, owned[index]),
            onDelete: () => _confirmDelete(context, model, owned[index]),
          ),
        ),
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    BrokerPropertiesViewModel model,
    Property property,
  ) async {
    final List<PropertyStatus>? picked =
        await WkOptionSheet.show<PropertyStatus>(
          context,
          title: context.l10n.propertyStatusTitle,
          selected: property.status,
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
        );
    if (picked == null || !context.mounted) {
      return;
    }

    final PropertyStatus target = picked.first;
    if (target == PropertyStatus.closed) {
      // La conséquence publique est dite **avant** de valider : le bien
      // disparaît des recherches, ce n'est pas un détail de gestion.
      final bool? confirmed = await WkConfirmSheet.show(
        context,
        title: WkFormat.propertyStatus(context.l10n, target),
        body: context.l10n.propertyStatusImpactClosed,
        confirmLabel: context.l10n.propertyStatusChange,
        cancelLabel: context.l10n.commonCancel,
      );
      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    await model.changeStatus(property, target);
    if (!context.mounted) {
      return;
    }
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B02:success:status-${property.id}-${target.name}',
    );
    WkToast.show(context, message: context.l10n.propertyStatusChanged);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BrokerPropertiesViewModel model,
    Property property,
  ) async {
    final bool? confirmed = await WkConfirmSheet.show(
      context,
      // Le bien est nommé : « Êtes-vous sûr ? » n'informe personne.
      title: context.l10n.propertyDeleteTitle(property.title),
      body: context.l10n.propertyDeleteBody,
      confirmLabel: context.l10n.propertyDelete,
      cancelLabel: context.l10n.commonCancel,
      destructive: true,
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    await model.delete(property.id);
    if (!context.mounted) {
      return;
    }
    context.read<InteractionFeedbackService?>()?.emit(
      FeedbackIntent.success,
      eventId: 'B02:success:delete-${property.id}',
    );
    WkToast.show(context, message: context.l10n.propertyDeleted);
  }
}

class _OwnedTile extends StatelessWidget {
  const _OwnedTile({
    required this.property,
    required this.onEdit,
    required this.onPreview,
    required this.onStatus,
    required this.onDelete,
  });

  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onPreview;
  final VoidCallback onStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WkSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  WkFormat.price(
                    context.l10n,
                    property.price,
                    property.transaction,
                  ),
                  style: context.text.headlineMedium,
                ),
              ),
              WkBadge(
                label: WkFormat.propertyStatus(context.l10n, property.status),
                icon: switch (property.status) {
                  PropertyStatus.available => Icons.check_circle_outline,
                  PropertyStatus.reserved => Icons.schedule,
                  PropertyStatus.closed => Icons.do_not_disturb_on_outlined,
                },
                tone: switch (property.status) {
                  PropertyStatus.available => WkBadgeTone.positive,
                  PropertyStatus.reserved => WkBadgeTone.brand,
                  PropertyStatus.closed => WkBadgeTone.neutral,
                },
              ),
            ],
          ),
          const SizedBox(height: WkSpacing.xs),
          Text(
            property.title,
            style: context.text.bodyLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: WkSpacing.md),
          // Une action par ligne. En deux colonnes, « Changer le statut »,
          // « Aperçu client » et « Modifier le bien » s'affichaient
          // « Change… », « Aperçu … », « Modifie… » : trois libellés coupés
          // sur quatre, illisibles pour qui déchiffre déjà difficilement.
          WkButton(
            label: context.l10n.propertyStatusChange,
            icon: Icons.swap_horiz,
            variant: WkButtonVariant.secondary,
            onPressed: onStatus,
          ),
          const SizedBox(height: WkSpacing.sm),
          WkButton(
            label: context.l10n.propertyPreviewTitle,
            icon: Icons.visibility_outlined,
            variant: WkButtonVariant.secondary,
            onPressed: onPreview,
          ),
          const SizedBox(height: WkSpacing.sm),
          WkButton(
            label: context.l10n.propertyEditorEdit,
            icon: Icons.edit_outlined,
            variant: WkButtonVariant.secondary,
            onPressed: onEdit,
          ),
          // Éloignée de Modifier : deux actions dont une destructive ne sont
          // jamais collées.
          const SizedBox(height: WkSpacing.betweenTargets),
          WkButton(
            label: context.l10n.commonDelete,
            icon: Icons.delete_outline,
            variant: WkButtonVariant.dangerGhost,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
