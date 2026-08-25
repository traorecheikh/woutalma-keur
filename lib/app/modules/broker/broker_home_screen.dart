import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/broker/broker_failures.dart';
import 'package:woutalma_keur/app/modules/broker/broker_trust_screens.dart'
    show verificationTag;
import 'package:woutalma_keur/app/ui/ui.dart';

const _pad = EdgeInsets.symmetric(horizontal: Insets.page);

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
  final int pendingReviews;
  final double averageRating;

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

    try {
      final List<Property> owned = await _properties.byBroker(_brokerId);
      final List<Review> all = await _reviews.byBroker(
        _brokerId,
        onlyPublic: false,
      );
      final List<Review> published = all
          .where((Review r) => r.isPublic)
          .toList();
      final List<ContactLog> contacts = await _contacts.all();

      _state = ScreenState<BrokerActivity>.data(
        BrokerActivity(
          broker: await _brokers.byId(_brokerId),
          visibleProperties: owned
              .where((Property p) => p.isDiscoverable)
              .length,
          closedProperties: owned
              .where((Property p) => !p.isDiscoverable)
              .length,
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
    } on Object catch (error) {
      _state = ScreenState<BrokerActivity>.error(brokerFailure(error));
    }
    notifyListeners();
  }
}

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
    final model = context.watch<BrokerHomeViewModel>();
    final l = context.l10n;
    return AppScaffold(
      title: l.brokerHomeTitle,
      showBack: false,
      onRefresh: model.load,
      actions: [
        AppIconButton(
          icon: FIcons.plus,
          label: l.propertyAdd,
          onTap: onAddProperty,
        ),
        AppIconButton(
          icon: FIcons.settings,
          label: l.settingsTitle,
          onTap: onOpenSettings,
        ),
      ],
      body: model.state.map(
        initial: () => const AppSkeleton(rows: 4, height: 96),
        loading: () => const AppSkeleton(rows: 4, height: 96),
        empty: () => AppState(
          kind: AppStateKind.empty,
          title: l.stateEmptyTitle,
          actionLabel: l.commonRetry,
          onAction: model.load,
        ),
        error: (failure) => failureState(context, failure, onRetry: model.load),
        data: (activity) => _Content(
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
    final l = context.l10n;
    final next = activity.nextActionKey();
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      children: [
        Padding(
          padding: _pad,
          child: AppKeyTile(
            label: l.brokerHomeContactsLabel,
            value: Text('${activity.contactsReceived}'),
            onTap: onOpenActivity,
          ),
        ),
        if (next != null) ...[
          const SizedBox(height: Insets.md),
          Padding(
            padding: _pad,
            child: AppCard(
              padding: const EdgeInsets.all(Insets.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.brokerHomeNext, style: context.text.titleLarge),
                  const SizedBox(height: Insets.md),
                  if (next == 'publish')
                    AppButton(
                      l.propertyAdd,
                      icon: FIcons.plus,
                      onPressed: onAddProperty,
                    )
                  else
                    AppButton(
                      l.brokerVerificationSubmit,
                      icon: FIcons.badgeCheck,
                      onPressed: onOpenVerification,
                    ),
                ],
              ),
            ),
          ),
        ],
        AppSection(l.brokerHomeOverview),
        Padding(
          padding: _pad,
          child: AppCard.rows([
            AppRow(
              title: l.brokerStatVisible(activity.visibleProperties),
              leading: const Icon(FIcons.eye),
            ),
            AppRow(
              title: l.brokerStatHidden(activity.closedProperties),
              leading: const Icon(FIcons.eyeOff),
            ),
            AppRow(
              title: l.brokerStatReviews(activity.publishedReviews),
              leading: const Icon(FIcons.star),
              trailing: activity.publishedReviews == 0
                  ? null
                  : AppStars(activity.averageRating),
              onTap: onOpenReviews,
            ),
            if (activity.pendingReviews > 0)
              AppRow(
                title: l.brokerPendingReviews(activity.pendingReviews),
                leading: const Icon(FIcons.hourglass),
                onTap: onOpenReviews,
              ),
          ]),
        ),
        const SizedBox(height: Insets.xl),
        Padding(
          padding: _pad,
          child: AppCard.rows([
            AppRow(
              title: l.brokerActivityTitle,
              leading: const Icon(FIcons.phoneIncoming),
              onTap: onOpenActivity,
            ),
            AppRow(
              title: l.brokerReviewsTitle,
              leading: const Icon(FIcons.star),
              onTap: onOpenReviews,
            ),
            AppRow(
              title: l.brokerVerificationTitle,
              leading: const Icon(FIcons.badgeCheck),
              trailing: verificationTag(context, activity.broker?.verification),
              onTap: onOpenVerification,
            ),
            AppRow(
              title: l.brokerRankingTitle,
              leading: const Icon(FIcons.chartColumn),
              onTap: onOpenRanking,
            ),
          ]),
        ),
      ],
    );
  }
}
