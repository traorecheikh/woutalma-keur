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
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_voice_note.dart';
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
        ClipRRect(
          borderRadius: BorderRadius.circular(WkRadius.xl),
          child: WkPhotoCarousel(
            property: property,
            height: 240,
            showVoiceBadge: false,
          ),
        ),
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
            WkStatusBadge(status: property.status),
          ],
        ),
        const SizedBox(height: WkSpacing.sm),
        Text(property.title, style: context.text.headlineMedium),
        const SizedBox(height: WkSpacing.sm),
        Text(
          WkFormat.propertyMeta(context.l10n, property, detail.distanceMeters),
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        if (property.hasVoiceNote) ...<Widget>[
          const SizedBox(height: WkSpacing.lg),
          WkVoiceNotePlayer(
            asset: property.voiceAsset!,
            title: context.l10n.voiceNoteFromBroker,
          ),
        ],
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
