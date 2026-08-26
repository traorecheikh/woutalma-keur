import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
  ContactLog? _pendingOutcome;
  ScreenState<PropertyDetail> get state => _state;
  MutationState get contactState => _contactState;

  ContactLog? takePendingOutcome() {
    final pending = _pendingOutcome;
    _pendingOutcome = null;
    return pending;
  }

  Future<void> load() async {
    _state = const ScreenState<PropertyDetail>.loading();
    notifyListeners();
    final Property? property;
    final Broker? broker;
    try {
      property = await _properties.byId(_propertyId);
      if (property == null) {
        _state = const ScreenState<PropertyDetail>.error(WkFailure.notFound);
        notifyListeners();
        return;
      }
      broker = await _brokers.byId(property.brokerId);
    } on DioException catch (e) {
      // Sans cette garde, une coupure laissait le squelette tourner sans fin.
      _state = ScreenState<PropertyDetail>.error(
        e.response == null ? WkFailure.network : WkFailure.unknown,
      );
      notifyListeners();
      return;
    } on Object {
      _state = const ScreenState<PropertyDetail>.error(WkFailure.unknown);
      notifyListeners();
      return;
    }
    _state = ScreenState<PropertyDetail>.data(
      PropertyDetail(
        property: property,
        broker: broker,
        distanceMeters: distanceMeters(_from, property.position),
      ),
    );
    notifyListeners();
  }

  Future<ContactAttempt> contactVia(ContactChannel channel) async {
    final detail = _state.valueOrNull;
    final broker = detail?.broker;
    if (detail == null || broker == null || _contactState.isSubmitting) {
      return const ContactAttempt(log: null, opened: false);
    }
    _contactState = const MutationState.submitting();
    notifyListeners();
    final attempt = await _contact.contact(
      broker: broker,
      channel: channel,
      propertyId: detail.property.id,
    );
    _pendingOutcome = attempt.log;
    _contactState = attempt.opened
        ? const MutationState.success()
        : const MutationState.failure(WkFailure.unknown);
    notifyListeners();
    return attempt;
  }

  Future<bool> callWithoutAccount() async {
    final broker = _state.valueOrNull?.broker;
    if (broker == null) return false;
    return _contact.open(ContactChannel.call, broker);
  }

  Future<void> recordOutcome(ContactLog log, ContactOutcome outcome) async {
    try {
      await _contact.recordOutcome(log, outcome);
    } on Object {
      // Le résultat n'est pas l'action principale : son échec ne remplace pas
      // la fiche par une erreur.
    }
  }
}

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({
    super.key,
    required this.onBack,
    required this.onOpenBroker,
    this.onSignIn,
    this.autoContact = false,
    this.publicPreview = false,
  });
  final VoidCallback onBack;
  final void Function(String brokerId) onOpenBroker;
  final VoidCallback? onSignIn;
  final bool autoContact;
  final bool publicPreview;

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  bool _autoContactDone = false;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PropertyViewModel>();
    final detail = model.state.valueOrNull;
    final l = context.l10n;
    final broker = detail?.broker;

    if (widget.autoContact &&
        !_autoContactDone &&
        broker != null &&
        !widget.publicPreview) {
      _autoContactDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _contact(context, model, broker);
      });
    }

    return ContactOutcomeOnResume(
      take: model.takePendingOutcome,
      onOutcome: model.recordOutcome,
      child: AppScaffold(
        onBack: widget.onBack,
        headerTitle: widget.publicPreview ? l.propertyPreviewTitle : null,
        // Le bouton reste, désactivé et motivé : le retirer laissait la fiche
        // sans aucune explication de ce qu'on ne peut plus y faire.
        bottom: detail == null
            ? null
            : _ContactBar(
                disabledReason: widget.publicPreview
                    ? l.propertyPreviewContactDisabled
                    : broker == null
                    ? l.propertyBrokerMissing
                    : null,
                loading: model.contactState.isSubmitting,
                onPressed: widget.publicPreview || broker == null
                    ? null
                    : () => _contact(context, model, broker),
              ),
        body: model.state.map(
          initial: () => const SizedBox.shrink(),
          loading: () => const AppSkeleton(rows: 3, height: 140),
          empty: () =>
              AppState(kind: AppStateKind.empty, title: l.stateEmptyTitle),
          error: (f) => failureState(context, f, onRetry: model.load),
          data: (d) => _Body(
            detail: d,
            publicPreview: widget.publicPreview,
            onOpenBroker: widget.onOpenBroker,
          ),
        ),
      ),
    );
  }

  Future<void> _contact(
    BuildContext context,
    PropertyViewModel model,
    Broker broker,
  ) => runContactFlow(
    context,
    broker: broker,
    contact: model.contactVia,
    callWithoutAccount: model.callWithoutAccount,
    onSignIn: widget.onSignIn ?? () {},
  );
}

class _ContactBar extends StatelessWidget {
  const _ContactBar({
    required this.disabledReason,
    required this.loading,
    required this.onPressed,
  });
  final String? disabledReason;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = AppButton(
      context.l10n.contactAction,
      icon: FIcons.phone,
      variant: AppButtonVariant.call,
      loading: loading,
      onPressed: onPressed,
    );
    if (disabledReason == null) {
      return button;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(hint: disabledReason, child: button),
        const SizedBox(height: Insets.sm),
        Text(
          disabledReason!,
          style: context.text.bodySmall!.copyWith(
            color: context.tones.inkSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
              if (b != null) ...[
                const SizedBox(height: Insets.xl),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppButton(
                    l.propertyShare,
                    icon: FIcons.share2,
                    variant: AppButtonVariant.ghost,
                    size: 44,
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(
                        text: l.propertyShareText(
                          p.title,
                          WkFormat.price(l, p.price, p.transaction),
                          p.neighbourhood,
                          formatPhone(b.phone),
                        ),
                      ),
                    ),
                  ),
                ),
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
