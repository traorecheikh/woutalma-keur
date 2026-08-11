import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_icon_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Résumé d'activité du courtier.
@immutable
class BrokerActivity {
  const BrokerActivity({
    required this.broker,
    required this.visibleProperties,
    required this.closedProperties,
    required this.contactsReceived,
    required this.publishedReviews,
    required this.pendingReviews,
    required this.averageRating,
  });

  final Broker? broker;
  final int visibleProperties;
  final int closedProperties;
  final int contactsReceived;
  final int publishedReviews;

  /// Avis en modération : visibles du courtier seul, jamais du client.
  final int pendingReviews;
  final double averageRating;

  /// Le prochain geste utile, ou `null` s'il n'y a rien à traiter.
  ///
  /// Un tableau de bord qui affiche des chiffres sans dire quoi en faire
  /// oblige à réfléchir à chaque ouverture.
  String? nextActionKey() {
    if (broker != null && !broker!.isVerified) {
      return 'verify';
    }
    if (visibleProperties == 0) {
      return 'publish';
    }
    return null;
  }
}

/// Coordonne B01.
class BrokerHomeViewModel extends ChangeNotifier {
  BrokerHomeViewModel({
    required BrokerRepository brokers,
    required PropertyRepository properties,
    required ReviewRepository reviews,
    required ContactRepository contacts,
    required String brokerId,
  }) : _brokers = brokers,
       _properties = properties,
       _reviews = reviews,
       _contacts = contacts,
       _brokerId = brokerId;

  final BrokerRepository _brokers;
  final PropertyRepository _properties;
  final ReviewRepository _reviews;
  final ContactRepository _contacts;
  final String _brokerId;

  ScreenState<BrokerActivity> _state =
      const ScreenState<BrokerActivity>.initial();

  ScreenState<BrokerActivity> get state => _state;

  Future<void> load() async {
    _state = const ScreenState<BrokerActivity>.loading();
    notifyListeners();

    final List<Property> owned = await _properties.byBroker(_brokerId);
    final List<Review> all = await _reviews.byBroker(
      _brokerId,
      onlyPublic: false,
    );
    final List<Review> published = all.where((Review r) => r.isPublic).toList();
    final List<ContactLog> contacts = await _contacts.all();

    _state = ScreenState<BrokerActivity>.data(
      BrokerActivity(
        broker: await _brokers.byId(_brokerId),
        visibleProperties: owned.where((Property p) => p.isDiscoverable).length,
        closedProperties: owned.where((Property p) => !p.isDiscoverable).length,
        contactsReceived: contacts
            .where((ContactLog c) => c.brokerId == _brokerId)
            .length,
        publishedReviews: published.length,
        pendingReviews: all.length - published.length,
        averageRating: published.isEmpty
            ? 0
            : published
                      .map((Review r) => r.rating)
                      .reduce((int a, int b) => a + b) /
                  published.length,
      ),
    );
    notifyListeners();
  }
}

/// B01 — Mon activité.
class BrokerHomeScreen extends StatelessWidget {
  const BrokerHomeScreen({
    required this.onAddProperty,
    required this.onOpenSettings,
    required this.onOpenReviews,
    required this.onOpenActivity,
    required this.onOpenVerification,
    required this.onOpenRanking,
    super.key,
  });

  final VoidCallback onAddProperty;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenReviews;
  final VoidCallback onOpenActivity;
  final VoidCallback onOpenVerification;
  final VoidCallback onOpenRanking;

  @override
  Widget build(BuildContext context) {
    final BrokerHomeViewModel model = context.watch<BrokerHomeViewModel>();

    return WkScaffold(
      extendBody: true,
      topBar: WkTopBar(
        title: context.l10n.brokerHomeTitle,
        action: WkIconButton(
          icon: Icons.settings_outlined,
          label: context.l10n.settingsTitle,
          onPressed: onOpenSettings,
        ),
      ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => const WkEmptyState(),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (BrokerActivity activity) => _Content(
          activity: activity,
          onAddProperty: onAddProperty,
          onOpenReviews: onOpenReviews,
          onOpenActivity: onOpenActivity,
          onOpenVerification: onOpenVerification,
          onOpenRanking: onOpenRanking,
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.activity,
    required this.onAddProperty,
    required this.onOpenReviews,
    required this.onOpenActivity,
    required this.onOpenVerification,
    required this.onOpenRanking,
  });

  final BrokerActivity activity;
  final VoidCallback onAddProperty;
  final VoidCallback onOpenReviews;
  final VoidCallback onOpenActivity;
  final VoidCallback onOpenVerification;
  final VoidCallback onOpenRanking;

  @override
  Widget build(BuildContext context) {
    final String? next = activity.nextActionKey();

    return ListView(
      padding: EdgeInsets.only(
        bottom: WkScaffold.bottomInset(context) + WkSpacing.md,
      ),
      children: <Widget>[
        _NextActionCard(
          activity: activity,
          next: next,
          onAddProperty: onAddProperty,
          onOpenVerification: onOpenVerification,
        ),
        const SizedBox(height: WkSpacing.lg),
        _SectionTitle(context.l10n.brokerHomeOverview),
        const SizedBox(height: WkSpacing.sm),
        _MetricGrid(activity: activity),
        const SizedBox(height: WkSpacing.lg),
        _LinkRow(
          label: context.l10n.brokerActivityTitle,
          icon: Icons.phone_in_talk_outlined,
          onTap: onOpenActivity,
        ),
        const SizedBox(height: WkSpacing.sm),
        _LinkRow(
          label: context.l10n.brokerReviewsTitle,
          icon: Icons.star_outline,
          onTap: onOpenReviews,
        ),
        const SizedBox(height: WkSpacing.sm),
        _LinkRow(
          label: context.l10n.brokerRankingTitle,
          icon: Icons.insights_outlined,
          onTap: onOpenRanking,
        ),
      ],
    );
  }
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({
    required this.activity,
    required this.next,
    required this.onAddProperty,
    required this.onOpenVerification,
  });

  final BrokerActivity activity;
  final String? next;
  final VoidCallback onAddProperty;
  final VoidCallback onOpenVerification;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(WkRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionTitle(
              context.l10n.brokerHomeNext,
              color: context.colors.onPrimaryContainer,
            ),
            const SizedBox(height: WkSpacing.sm),
            if (activity.publishedReviews > 0) ...<Widget>[
              WkRating(
                value: activity.averageRating,
                reviewCount: activity.publishedReviews,
                compact: true,
              ),
              const SizedBox(height: WkSpacing.md),
            ],
            if (next == null)
              Text(
                context.l10n.brokerHomeNothing,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onPrimaryContainer,
                ),
              )
            else if (next == 'publish')
              WkButton(
                label: context.l10n.propertyAdd,
                icon: Icons.add,
                onPressed: onAddProperty,
              )
            else
              WkButton(
                label: context.l10n.brokerVerificationSubmit,
                icon: Icons.verified_user_outlined,
                onPressed: onOpenVerification,
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.activity});

  final BrokerActivity activity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _MetricTile(
          value: activity.visibleProperties,
          label: context.l10n.brokerStatVisible(activity.visibleProperties),
          icon: Icons.visibility_outlined,
        ),
        const SizedBox(height: WkSpacing.sm),
        _MetricTile(
          value: activity.contactsReceived,
          label: context.l10n.brokerStatContacts(activity.contactsReceived),
          icon: Icons.phone_in_talk_outlined,
        ),
        const SizedBox(height: WkSpacing.sm),
        _MetricTile(
          value: activity.publishedReviews,
          label: context.l10n.brokerStatReviews(activity.publishedReviews),
          icon: Icons.star_outline,
        ),
        const SizedBox(height: WkSpacing.sm),
        _MetricTile(
          value: activity.pendingReviews > 0
              ? activity.pendingReviews
              : activity.closedProperties,
          label: activity.pendingReviews > 0
              ? context.l10n.brokerPendingReviews(activity.pendingReviews)
              : context.l10n.brokerStatHidden(activity.closedProperties),
          icon: activity.pendingReviews > 0
              ? Icons.hourglass_empty
              : Icons.visibility_off_outlined,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(WkRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: context.colors.primary),
            const SizedBox(width: WkSpacing.md),
            Text(
              '$value',
              style: context.text.headlineLarge?.copyWith(
                color: context.colors.primary,
              ),
            ),
            const SizedBox(width: WkSpacing.md),
            Expanded(child: Text(label, style: context.text.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: WkTouch.comfy),
          padding: const EdgeInsets.symmetric(horizontal: WkSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(WkRadius.lg),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: context.colors.primary),
              const SizedBox(width: WkSpacing.md),
              Expanded(child: Text(label, style: context.text.bodyLarge)),
              Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, {this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: context.text.headlineMedium?.copyWith(color: color),
      ),
    );
  }
}
