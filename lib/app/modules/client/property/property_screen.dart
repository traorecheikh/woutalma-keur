import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/domain/repositories.dart';
import 'package:woutalma_keur/app/modules/client/broker/contact_sheet.dart';
import 'package:woutalma_keur/app/modules/client/explore/cards.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/ui/ui.dart';
import 'package:woutalma_keur/app/ui/voice_note.dart';

@immutable
class PropertyDetail {
  const PropertyDetail({
    required this.property,
    required this.broker,
    required this.distanceMeters,
  });
  final Property property;
  final Broker? broker;
  final double distanceMeters;
}

class PropertyViewModel extends ChangeNotifier {
  PropertyViewModel({
    required String propertyId,
    required PropertyRepository properties,
    required BrokerRepository brokers,
    required ContactService contact,
    required GeoPoint from,
  }) : _propertyId = propertyId,
       _properties = properties,
       _brokers = brokers,
       _contact = contact,
       _from = from;

  final String _propertyId;
  final PropertyRepository _properties;
  final BrokerRepository _brokers;
  final ContactService _contact;
  final GeoPoint _from;

  ScreenState<PropertyDetail> _state =
      const ScreenState<PropertyDetail>.initial();
  MutationState _contactState = const MutationState.idle();
  ScreenState<PropertyDetail> get state => _state;
  MutationState get contactState => _contactState;

  Future<void> load() async {
    _state = const ScreenState<PropertyDetail>.loading();
    notifyListeners();
    final property = await _properties.byId(_propertyId);
    if (property == null) {
      _state = const ScreenState<PropertyDetail>.error(WkFailure.notFound);
      notifyListeners();
      return;
    }
    _state = ScreenState<PropertyDetail>.data(
      PropertyDetail(
        property: property,
        broker: await _brokers.byId(property.brokerId),
        distanceMeters: distanceMeters(_from, property.position),
      ),
    );
    notifyListeners();
  }

  Future<bool> contactVia(ContactChannel channel) async {
    final detail = _state.valueOrNull;
    final broker = detail?.broker;
    if (detail == null || broker == null || _contactState.isSubmitting)
      return false;
    _contactState = const MutationState.submitting();
    notifyListeners();
    late final ContactAttempt attempt;
    try {
      attempt = await _contact.contact(
        broker: broker,
        channel: channel,
        propertyId: detail.property.id,
      );
    } on DioException catch (e) {
      _contactState = MutationState.failure(
        e.response?.statusCode == 401
            ? WkFailure.permission
            : e.response == null
            ? WkFailure.network
            : WkFailure.unknown,
      );
      notifyListeners();
      return false;
    } on Object {
      _contactState = const MutationState.failure(WkFailure.unknown);
      notifyListeners();
      return false;
    }
    _contactState = attempt.opened
        ? const MutationState.success()
        : const MutationState.failure(WkFailure.unknown);
    notifyListeners();
    return attempt.opened;
  }
}

class PropertyScreen extends StatelessWidget {
  const PropertyScreen({
    super.key,
    required this.onBack,
    required this.onOpenBroker,
    this.publicPreview = false,
  });
  final VoidCallback onBack;
  final void Function(String brokerId) onOpenBroker;
  final bool publicPreview;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PropertyViewModel>();
    final detail = model.state.valueOrNull;
    final l = context.l10n;
    return AppScaffold(
      onBack: onBack,
      headerTitle: publicPreview ? l.propertyPreviewTitle : null,
      bottom: detail?.broker == null
          ? null
          : AppButton(
              l.contactAction,
              icon: FIcons.phone,
              variant: AppButtonVariant.call,
              loading: model.contactState.isSubmitting,
              onPressed: publicPreview
                  ? null
                  : () => _contact(context, model, detail!.broker!),
            ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const AppSkeleton(rows: 3, height: 140),
        empty: () =>
            AppState(kind: AppStateKind.empty, title: l.stateEmptyTitle),
        error: (f) => failureState(context, f, onRetry: model.load),
        data: (d) => _Body(
          detail: d,
          publicPreview: publicPreview,
          onOpenBroker: onOpenBroker,
        ),
      ),
    );
  }

  Future<void> _contact(
    BuildContext context,
    PropertyViewModel model,
    Broker broker,
  ) async {
    final channel = await ContactSheet.show(context, broker: broker);
    if (channel == null || !context.mounted) return;
    final opened = await model.contactVia(channel);
    if (!context.mounted) return;
    toast(
      context,
      opened
          ? context.l10n.contactLogged
          : failureText(
              context.l10n,
              model.contactState is MutationFailure
                  ? (model.contactState as MutationFailure).failure
                  : WkFailure.unknown,
            ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.detail,
    required this.publicPreview,
    required this.onOpenBroker,
  });
  final PropertyDetail detail;
  final bool publicPreview;
  final void Function(String) onOpenBroker;

  @override
  Widget build(BuildContext context) {
    final p = detail.property;
    final b = detail.broker;
    final l = context.l10n;
    final dim = context.text.bodyMedium!.copyWith(
      color: context.tones.inkSecondary,
    );
    return ListView(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      children: [
        if (publicPreview)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.page,
              0,
              Insets.page,
              Insets.md,
            ),
            child: FAlert(
              icon: const Icon(FIcons.eye),
              title: Text(l.propertyPreviewNotice),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.page),
          child: PhotoCarousel(
            property: p,
            aspectRatio: 4 / 3,
            radius: Radii.card,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.page,
            Insets.xl,
            Insets.page,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WkFormat.price(l, p.price, p.transaction),
                style: AppText.moneyXl,
              ),
              const SizedBox(height: Insets.sm),
              Text(p.title, style: context.text.headlineMedium),
              const SizedBox(height: Insets.sm),
              Text(
                WkFormat.propertyMeta(l, p, detail.distanceMeters),
                style: dim,
              ),
              const SizedBox(height: Insets.lg),
              Wrap(
                spacing: Insets.sm,
                runSpacing: Insets.sm,
                children: [
                  AppTag(
                    WkFormat.propertyStatus(l, p.status),
                    icon: p.status == PropertyStatus.available
                        ? FIcons.circleCheck
                        : p.status == PropertyStatus.reserved
                        ? FIcons.clock
                        : FIcons.ban,
                    tone: p.status == PropertyStatus.available
                        ? AppTone.success
                        : p.status == PropertyStatus.reserved
                        ? AppTone.accent
                        : AppTone.neutral,
                  ),
                  AppTag(
                    WkFormat.transaction(l, p.transaction),
                    icon: p.transaction == TransactionKind.rent
                        ? FIcons.key
                        : FIcons.tag,
                  ),
                  AppTag(p.neighbourhood, icon: FIcons.mapPin),
                ],
              ),
              if (p.hasVoiceNote) ...[
                const SizedBox(height: Insets.xl),
                AppVoiceNotePlayer(
                  asset: p.voiceAsset!,
                  title: l.voiceNoteFromBroker,
                ),
              ],
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: Insets.xl),
                Text(p.description, style: context.text.bodyLarge),
              ],
            ],
          ),
        ),
        if (b != null) ...[
          AppSection(l.propertyBrokerLabel),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.page),
            child: AppCard.rows([
              AppRow(
                leading: AppAvatar(name: b.name, imagePath: b.logoAsset),
                title: b.name,
                subtitle: l.brokerResponseRate((b.responseRate * 100).round()),
                trailing: b.isVerified
                    ? AppTag(
                        l.badgeVerified,
                        tone: AppTone.success,
                        icon: FIcons.badgeCheck,
                      )
                    : null,
                onTap: publicPreview ? null : () => onOpenBroker(b.id),
              ),
            ]),
          ),
        ],
      ],
    );
  }
}
