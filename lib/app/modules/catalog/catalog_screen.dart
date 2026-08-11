import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/theme/wk_colors.dart';
import 'package:woutalma_keur/app/shared/theme/wk_motion.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/theme/wk_typography.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/formatters.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_broker_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_confirm_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_icon_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_rating.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_scaffold.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_search_bar.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_segmented_control.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_states.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_text_field.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_toast.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_top_bar.dart';

/// S02 — catalogue des jetons et des composants.
///
/// Outil de développement, visible en debug ou en mode démo. C'est la fixture
/// visuelle qui permet de valider une fondation avant qu'un écran métier ne
/// s'en serve.
///
/// **Exemption assumée à « aucune chaîne en dur ».** Les noms de jetons
/// (`primary`, `body-lg`, `#0B3B66`) sont des identifiants techniques, pas de
/// la copie produit : les traduire les rendrait faux. Les titres de section,
/// eux, passent par `context.l10n` comme partout ailleurs. Le garde-fou
/// `no_hardcoded_text_test` exclut ce seul fichier, et aucun autre.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WkScaffold(
      topBar: WkTopBar(title: context.l10n.catalogTitle),
      body: ListView(
        padding: const EdgeInsets.only(bottom: WkSpacing.xxl),
        children: <Widget>[
          Text(
            context.l10n.catalogSubtitle,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: WkSpacing.xl),
          _Section(
            title: context.l10n.catalogSectionColors,
            child: const _ColorTokens(),
          ),
          _Section(
            title: context.l10n.catalogSectionTypography,
            child: const _TypographyTokens(),
          ),
          _Section(
            title: context.l10n.catalogSectionSpacing,
            child: const _SpacingTokens(),
          ),
          _Section(
            title: context.l10n.catalogSectionTouch,
            child: const _TouchTokens(),
          ),
          _Section(
            title: context.l10n.catalogSectionMotion,
            child: const _MotionTokens(),
          ),
          _Section(
            title: context.l10n.catalogSectionButtons,
            child: const _ButtonGallery(),
          ),
          _Section(
            title: context.l10n.catalogSectionInputs,
            child: const _InputGallery(),
          ),
          _Section(
            title: context.l10n.catalogSectionContent,
            child: const _ContentGallery(),
          ),
          _Section(
            title: context.l10n.catalogSectionStates,
            child: const _StateGallery(),
          ),
          _Section(
            title: context.l10n.catalogSectionOverlays,
            child: const _OverlayGallery(),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WkSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(title, style: context.text.headlineLarge),
          ),
          const SizedBox(height: WkSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ColorTokens extends StatelessWidget {
  const _ColorTokens();

  @override
  Widget build(BuildContext context) {
    final WkColors c = context.colors;
    final List<(String, Color, Color)> swatches = <(String, Color, Color)>[
      ('primary', c.primary, c.onPrimary),
      ('primary-container', c.primaryContainer, c.onPrimaryContainer),
      ('surface', c.surface, c.onSurface),
      ('surface-variant', c.surfaceVariant, c.onSurfaceVariant),
      ('call', c.call, c.onCall),
      ('whatsapp', c.whatsapp, c.onWhatsapp),
      ('error', c.error, c.onError),
      ('status-available', c.statusAvailable, c.onPrimary),
    ];

    return Column(
      children: <Widget>[
        for (final (String name, Color bg, Color fg) in swatches)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: WkSpacing.sm),
            padding: const EdgeInsets.all(WkSpacing.md),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(WkRadius.md),
              border: Border.all(color: c.outlineVariant),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelMedium?.copyWith(color: fg),
                  ),
                ),
                const SizedBox(width: WkSpacing.sm),
                Text(
                  _hex(bg),
                  style: context.text.labelSmall?.copyWith(color: fg),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _hex(Color color) {
    final int argb = color.toARGB32();
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class _TypographyTokens extends StatelessWidget {
  const _TypographyTokens();

  @override
  Widget build(BuildContext context) {
    final TextTheme t = context.text;
    final List<(String, TextStyle?)> slots = <(String, TextStyle?)>[
      ('display-lg', t.displayLarge),
      ('display-md', t.displayMedium),
      ('headline-lg', t.headlineLarge),
      ('headline-md', t.headlineMedium),
      ('body-lg', t.bodyLarge),
      ('body-md', t.bodyMedium),
      ('body-sm', t.bodySmall),
      ('label-lg', t.labelLarge),
      ('label-md', t.labelMedium),
      ('label-sm', t.labelSmall),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (String name, TextStyle? style) in slots)
          Padding(
            padding: const EdgeInsets.only(bottom: WkSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$name — ${style?.fontSize?.toStringAsFixed(0)}',
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                Text('Woutalma Keur', style: style),
              ],
            ),
          ),
        const SizedBox(height: WkSpacing.sm),
        Text(
          'plancher ${WkTypography.floorSize.toStringAsFixed(0)} · '
          'corps ${WkTypography.bodyDefaultSize.toStringAsFixed(0)}',
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SpacingTokens extends StatelessWidget {
  const _SpacingTokens();

  @override
  Widget build(BuildContext context) {
    const List<(String, double)> steps = <(String, double)>[
      ('xs', WkSpacing.xs),
      ('sm', WkSpacing.sm),
      ('md', WkSpacing.md),
      ('lg', WkSpacing.lg),
      ('xl', WkSpacing.xl),
      ('2xl', WkSpacing.xxl),
      ('3xl', WkSpacing.xxxl),
      ('page', WkSpacing.page),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (String name, double value) in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: WkSpacing.xs),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 56,
                  child: Text(name, style: context.text.labelSmall),
                ),
                Container(
                  width: value,
                  height: WkSpacing.md,
                  color: context.colors.primary,
                ),
                const SizedBox(width: WkSpacing.sm),
                Text(
                  value.toStringAsFixed(0),
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TouchTokens extends StatelessWidget {
  const _TouchTokens();

  @override
  Widget build(BuildContext context) {
    const List<(String, double)> targets = <(String, double)>[
      ('min', WkTouch.min),
      ('comfy', WkTouch.comfy),
      ('voice', WkTouch.voice),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (String name, double size) in targets)
          Padding(
            padding: const EdgeInsets.only(bottom: WkSpacing.sm),
            child: Row(
              children: <Widget>[
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(WkRadius.md),
                  ),
                ),
                const SizedBox(width: WkSpacing.md),
                Text(
                  '$name · ${size.toStringAsFixed(0)}',
                  style: context.text.labelMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MotionTokens extends StatelessWidget {
  const _MotionTokens();

  @override
  Widget build(BuildContext context) {
    final WkMotion m = context.motion;
    final List<(String, Duration)> durations = <(String, Duration)>[
      ('instant', m.instant),
      ('fast', m.fast),
      ('standard', m.standard),
      ('slow', m.slow),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (String name, Duration value) in durations)
          Padding(
            padding: const EdgeInsets.only(bottom: WkSpacing.xs),
            child: Text(
              '$name · ${value.inMilliseconds} ms',
              style: context.text.bodyMedium,
            ),
          ),
        if (m.reduced) ...<Widget>[
          const SizedBox(height: WkSpacing.sm),
          Text(
            context.l10n.catalogMotionReduced,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Étiquette technique d'un exemple. Comme les noms de jetons, elle n'est pas
/// de la copie produit et ne passe donc pas par l'ARB.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WkSpacing.xs, top: WkSpacing.sm),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Chaque variante de bouton, dans chacun de ses états.
///
/// C'est ici qu'on voit d'un coup qu'un bouton désactivé reste lisible, qu'un
/// bouton en cours garde sa hauteur, et que `call` et `whatsapp` ne se
/// confondent pas l'un avec l'autre.
class _ButtonGallery extends StatelessWidget {
  const _ButtonGallery();

  @override
  Widget build(BuildContext context) {
    const List<(WkButtonVariant, String)> variants =
        <(WkButtonVariant, String)>[
          (WkButtonVariant.primary, 'primary'),
          (WkButtonVariant.secondary, 'secondary'),
          (WkButtonVariant.ghost, 'ghost'),
          (WkButtonVariant.danger, 'danger'),
          (WkButtonVariant.dangerGhost, 'danger-ghost'),
          (WkButtonVariant.call, 'call'),
          (WkButtonVariant.whatsapp, 'whatsapp'),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final (WkButtonVariant variant, String name)
            in variants) ...<Widget>[
          _Label(name),
          WkButton(
            label: name,
            icon: Icons.check,
            variant: variant,
            onPressed: () {},
          ),
        ],
        _Label(context.l10n.catalogStateDisabled),
        WkButton(
          label: context.l10n.catalogStateDisabled,
          onPressed: null,
          disabledReason: context.l10n.catalogStateDisabled,
        ),
        _Label(context.l10n.catalogStateLoading),
        WkButton(
          label: context.l10n.catalogStateLoading,
          loading: true,
          onPressed: () {},
        ),
        const _Label('icon-button'),
        Row(
          children: <Widget>[
            WkIconButton(icon: Icons.mic, label: 'mic', onPressed: () {}),
            const SizedBox(width: WkSpacing.sm),
            WkIconButton(icon: Icons.close, label: 'close', onPressed: () {}),
            const SizedBox(width: WkSpacing.sm),
            const WkIconButton(
              icon: Icons.share,
              label: 'share',
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Champs de saisie et sélecteurs, valides comme fautifs.
class _InputGallery extends StatefulWidget {
  const _InputGallery();

  @override
  State<_InputGallery> createState() => _InputGalleryState();
}

class _InputGalleryState extends State<_InputGallery> {
  final TextEditingController _empty = TextEditingController();
  final TextEditingController _filled = TextEditingController(text: 'Mermoz');
  final TextEditingController _wrong = TextEditingController(text: '12');
  final TextEditingController _search = TextEditingController();
  PropertyKind? _kind;
  bool _properties = false;

  /// Un champ ne crie pas avant qu'on ait tapé : il n'affiche son erreur qu'à
  /// la soumission. Le catalogue en joue une, sinon l'état fautif ne se
  /// montrerait jamais ici.
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _tick = 1);
      }
    });
  }

  @override
  void dispose() {
    _empty.dispose();
    _filled.dispose();
    _wrong.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Label('text-field · vide'),
        WkTextField(label: 'Quartier', controller: _empty, hint: 'Mermoz'),
        const _Label('text-field · rempli'),
        WkTextField(label: 'Quartier', controller: _filled),
        const _Label('text-field · fautif'),
        WkTextField(
          label: 'Téléphone',
          controller: _wrong,
          validator: (String value) =>
              value.length < 9 ? context.l10n.authPhoneInvalid : null,
          revalidateTick: _tick,
        ),
        const _Label('select-field'),
        WkSelectField<PropertyKind?>(
          label: context.l10n.filtersKind,
          value: _kind,
          onChanged: (PropertyKind? value) => setState(() => _kind = value),
          options: <WkOption<PropertyKind?>>[
            WkOption<PropertyKind?>(
              value: null,
              label: context.l10n.filtersAny,
              icon: Icons.all_inclusive,
            ),
            for (final PropertyKind kind in PropertyKind.values)
              WkOption<PropertyKind?>(
                value: kind,
                label: WkFormat.propertyKind(context.l10n, kind),
                icon: WkFormat.propertyKindIcon(kind),
              ),
          ],
        ),
        const _Label('search-bar'),
        WkSearchBar(controller: _search, onChanged: (_) {}, onVoice: () {}),
        const _Label('segmented-control'),
        WkSegmentedControl<bool>(
          segments: <(bool, String)>[
            (false, context.l10n.exploreSegmentBrokers),
            (true, context.l10n.exploreSegmentProperties),
          ],
          value: _properties,
          onChanged: (bool value) => setState(() => _properties = value),
        ),
      ],
    );
  }
}

/// Cartes, badges et notes, sur les entités réelles du jeu de démonstration.
class _ContentGallery extends StatelessWidget {
  const _ContentGallery();

  @override
  Widget build(BuildContext context) {
    const DemoSeed seed = DemoSeed();
    final Broker broker = seed.brokers().first;
    final Property property = seed.properties().first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Label('badge'),
        Wrap(
          spacing: WkSpacing.sm,
          runSpacing: WkSpacing.sm,
          children: <Widget>[
            WkBadge(
              label: context.l10n.badgeVerified,
              icon: Icons.verified_outlined,
              tone: WkBadgeTone.positive,
            ),
            WkBadge(
              label: context.l10n.badgePinned,
              icon: Icons.push_pin_outlined,
              tone: WkBadgeTone.brand,
            ),
            WkBadge(
              label: context.l10n.statusReserved,
              icon: Icons.schedule,
              tone: WkBadgeTone.brand,
            ),
            WkBadge(
              label: context.l10n.statusClosed,
              icon: Icons.lock_outline,
              tone: WkBadgeTone.neutral,
            ),
          ],
        ),
        const _Label('rating'),
        const WkRating(value: 4.7, reviewCount: 12),
        const SizedBox(height: WkSpacing.sm),
        const WkRating(value: 0, reviewCount: 0),
        const SizedBox(height: WkSpacing.sm),
        const WkRating(value: 3.5, reviewCount: 2, compact: true),
        const _Label('broker-card'),
        WkBrokerCard(
          listing: BrokerListing(
            broker: broker,
            distanceMeters: 320,
            averageRating: 4.7,
            reviewCount: 3,
            availableProperties: 2,
            score: 0.9,
          ),
          onOpen: () {},
        ),
        const _Label('property-card'),
        WkPropertyCard(property: property, distanceMeters: 1600, onOpen: () {}),
      ],
    );
  }
}

/// Les trois états qu'un écran doit savoir montrer avant d'avoir des données.
class _StateGallery extends StatelessWidget {
  const _StateGallery();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Label('loading'),
        const SizedBox(height: 160, child: WkLoadingState()),
        const _Label('empty'),
        SizedBox(
          height: 260,
          child: WkEmptyState(
            title: context.l10n.stateEmptyTitle,
            body: context.l10n.exploreEmptyBody,
            actionLabel: context.l10n.filtersReset,
            onAction: () {},
          ),
        ),
        const _Label('error'),
        SizedBox(
          height: 260,
          child: WkErrorState(failure: WkFailure.localStorage, onRetry: () {}),
        ),
      ],
    );
  }
}

/// Les surfaces transitoires. Elles ne se photographient pas au repos : on les
/// ouvre depuis ici.
class _OverlayGallery extends StatelessWidget {
  const _OverlayGallery();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Label('toast'),
        WkButton(
          label: 'toast',
          variant: WkButtonVariant.secondary,
          onPressed: () => WkToast.show(
            context,
            message: context.l10n.catalogSubtitle,
            undoLabel: context.l10n.commonCancel,
            onUndo: () {},
          ),
        ),
        const _Label('confirm-sheet'),
        WkButton(
          label: 'confirm-sheet',
          variant: WkButtonVariant.secondary,
          onPressed: () => WkConfirmSheet.show(
            context,
            title: context.l10n.stateEmptyTitle,
            body: context.l10n.catalogSubtitle,
            confirmLabel: context.l10n.commonRetry,
            cancelLabel: context.l10n.commonCancel,
            destructive: true,
          ),
        ),
        const _Label('option-sheet'),
        WkButton(
          label: 'option-sheet',
          variant: WkButtonVariant.secondary,
          onPressed: () => WkOptionSheet.show<PropertyKind>(
            context,
            title: context.l10n.filtersKind,
            options: <WkOption<PropertyKind>>[
              for (final PropertyKind kind in PropertyKind.values)
                WkOption<PropertyKind>(
                  value: kind,
                  label: WkFormat.propertyKind(context.l10n, kind),
                  icon: WkFormat.propertyKindIcon(kind),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
