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
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// Contenu résolu de C03.
@immutable
class PropertyDetail {
  const PropertyDetail({
    required this.property,
    required this.broker,
    required this.distanceMeters,
  });

  final Property property;

  /// Absent si le courtier a disparu : la fiche reste lisible, seul le bouton
  /// de contact s'efface.
  final Broker? broker;
  final double distanceMeters;
}

/// Coordonne C03.
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

    final Property? property = await _properties.byId(_propertyId);
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
    final PropertyDetail? detail = _state.valueOrNull;
    final Broker? broker = detail?.broker;
    if (detail == null || broker == null || _contactState.isSubmitting) {
      return false;
    }

    _contactState = const MutationState.submitting();
    notifyListeners();

    // Même garde que sur C02 : le journal exige une session, et un 401 non
    // rattrapé fige le bouton Contacter pour de bon.
    late final ContactAttempt attempt;
    try {
      attempt = await _contact.contact(
        broker: broker,
        channel: channel,
        propertyId: detail.property.id,
      );
    } on DioException catch (error) {
      _contactState = MutationState.failure(
        error.response?.statusCode == 401
            ? WkFailure.permission
            : error.response == null
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

/// C03 — Fiche bien.
///
/// La question : « ce bien me correspond-il ? ». Le prix et le statut viennent
/// avant la description : un bien réservé qu'on découvre après avoir lu trois
/// paragraphes est une perte de temps.
class PropertyScreen extends StatelessWidget {
  const PropertyScreen({
    required this.onBack,
    required this.onOpenBroker,
    this.publicPreview = false,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(String brokerId) onOpenBroker;

  /// Vrai quand le courtier regarde son propre bien : même rendu, mais sans
  /// l'action de contact — s'appeler soi-même n'a pas de sens.
  final bool publicPreview;

  @override
  Widget build(BuildContext context) {
    final PropertyViewModel model = context.watch<PropertyViewModel>();
    final PropertyDetail? detail = model.state.valueOrNull;

    return WkScaffold(
      topBar: WkTopBar(
        title: publicPreview
            ? context.l10n.propertyPreviewTitle
            : detail?.property.title ?? context.l10n.exploreSegmentProperties,
        onBack: onBack,
      ),
      bottomAction: detail?.broker == null
          ? null
          : WkButton(
              label: context.l10n.contactAction,
              icon: Icons.phone_in_talk_outlined,
              loading: model.contactState.isSubmitting,
              // En aperçu, la barre reste là mais inerte : la masquer
              // donnait un écran plus court que celui des clients, alors que
              // la page annonce montrer exactement ce qu'ils voient.
              onPressed: publicPreview
                  ? null
                  : () => _startContact(context, model, detail!.broker!),
              disabledReason: publicPreview
                  ? context.l10n.propertyPreviewContactDisabled
                  : null,
            ),
      body: model.state.map(
        initial: () => const SizedBox.shrink(),
        loading: () => const WkLoadingState(),
        empty: () => const WkEmptyState(),
        error: (WkFailure failure) =>
            WkErrorState(failure: failure, onRetry: model.load),
        data: (PropertyDetail value) =>
            _Content(detail: value, publicPreview: publicPreview),
      ),
    );
  }

  Future<void> _startContact(
    BuildContext context,
    PropertyViewModel model,
    Broker broker,
  ) async {
    final ContactChannel? channel = await ContactSheet.show(
      context,
      broker: broker,
    );
    if (channel == null || !context.mounted) {
      return;
    }

    final bool opened = await model.contactVia(channel);
    if (!context.mounted) {
      return;
    }
    WkToast.show(
      context,
      message: opened
          ? context.l10n.contactLogged
          : context.l10n.failureUnknown,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail, required this.publicPreview});

  final PropertyDetail detail;
  final bool publicPreview;

  @override
  Widget build(BuildContext context) {
    final Property property = detail.property;

    return ListView(
      padding: const EdgeInsets.only(bottom: WkSpacing.lg),
      children: <Widget>[
        if (publicPreview) ...<Widget>[
          Text(
            context.l10n.propertyPreviewNotice,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: WkSpacing.md),
        ],
        _PhotoGallery(property: property),
        const SizedBox(height: WkSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                WkFormat.price(
                  context.l10n,
                  property.price,
                  property.transaction,
                ),
                style: context.text.headlineLarge,
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
        const SizedBox(height: WkSpacing.sm),
        Text(property.title, style: context.text.headlineMedium),
        const SizedBox(height: WkSpacing.md),
        Wrap(
          spacing: WkSpacing.xs,
          runSpacing: WkSpacing.xs,
          children: <Widget>[
            WkBadge(
              label: WkFormat.transaction(context.l10n, property.transaction),
              icon: Icons.swap_horiz,
            ),
            WkBadge(
              label: WkFormat.propertyKind(context.l10n, property.kind),
              icon: Icons.category_outlined,
            ),
            if (property.surface != null)
              WkBadge(
                label: context.l10n.surfaceValue(property.surface!),
                icon: Icons.straighten,
              ),
            if (property.rooms != null)
              WkBadge(
                label: context.l10n.roomCount(property.rooms!),
                icon: Icons.meeting_room_outlined,
              ),
            WkBadge(label: property.neighbourhood, icon: Icons.place_outlined),
            WkBadge(
              label: WkFormat.distance(context.l10n, detail.distanceMeters),
              icon: Icons.near_me_outlined,
            ),
          ],
        ),
        if (property.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: WkSpacing.lg),
          Text(property.description, style: context.text.bodyLarge),
        ],
        if (detail.broker != null) ...<Widget>[
          const SizedBox(height: WkSpacing.lg),
          Text(
            context.l10n.propertyBrokerLabel,
            style: context.text.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: WkSpacing.xs),
          Text(detail.broker!.name, style: context.text.headlineMedium),
        ],
      ],
    );
  }
}

class _PhotoGallery extends StatefulWidget {
  const _PhotoGallery({required this.property});

  final Property property;

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  late final PageController _controller = PageController(
    viewportFraction: widget.property.photoAssets.length > 1 ? 0.92 : 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> photos = widget.property.photoAssets;
    if (photos.isEmpty) {
      // Sans photo, la fiche garde un bloc de la hauteur d'une galerie : la
      // rabattre ferait commencer l'écran par un prix flottant, et le même
      // bien paraîtrait plus pauvre qu'il ne l'est.
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(WkRadius.lg),
          child: const WkPropertyPhotoFallback(icon: Icons.home_work_outlined),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _controller,
        clipBehavior: Clip.none,
        padEnds: false,
        itemCount: photos.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == photos.length - 1 ? 0 : WkSpacing.sm,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(WkRadius.lg),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  WkPropertyPhoto(
                    path: photos[index],
                    fallbackIcon: Icons.home_work_outlined,
                  ),
                  PositionedDirectional(
                    end: WkSpacing.sm,
                    bottom: WkSpacing.sm,
                    child: WkBadge(
                      label: context.l10n.photosCount(index + 1, photos.length),
                      icon: Icons.photo_library_outlined,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
