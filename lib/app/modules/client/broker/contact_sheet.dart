import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_badge.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

/// M04 — feuille de mise en relation.
///
/// Un canal par bouton, chacun avec son verbe. Un canal que le courtier n'a
/// pas **n'apparaît pas** : un bouton mort coûte plus cher qu'un bouton
/// absent, surtout à quelqu'un qui essaie déjà de se débrouiller.
class ContactSheet extends StatelessWidget {
  const ContactSheet({required this.broker, super.key});

  final Broker broker;

  static Future<ContactChannel?> show(
    BuildContext context, {
    required Broker broker,
  }) {
    return showModalBottomSheet<ContactChannel>(
      context: context,
      // Racine, pas la branche : une feuille ouverte dans le Navigator
      // d'un onglet laisserait la barre d'onglets cliquable au-dessus de
      // sa propre barrière modale.
      useRootNavigator: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) => ContactSheet(broker: broker),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.l10n.contactSheetTitle,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: WkSpacing.xs),
            _BrokerContactHeader(broker: broker),
            const SizedBox(height: WkSpacing.lg),
            WkButton(
              label: context.l10n.contactCall,
              icon: Icons.call,
              variant: WkButtonVariant.call,
              onPressed: () => Navigator.of(context).pop(ContactChannel.call),
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            if (broker.whatsapp != null) ...<Widget>[
              WkButton(
                label: context.l10n.contactWhatsapp,
                icon: Icons.chat,
                variant: WkButtonVariant.whatsapp,
                onPressed: () =>
                    Navigator.of(context).pop(ContactChannel.whatsapp),
              ),
              const SizedBox(height: WkSpacing.betweenTargets),
            ],
            WkButton(
              label: context.l10n.contactSms,
              icon: Icons.sms_outlined,
              variant: WkButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(ContactChannel.sms),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrokerContactHeader extends StatelessWidget {
  const _BrokerContactHeader({required this.broker});

  final Broker broker;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(WkSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(WkRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(WkRadius.full),
            ),
            child: Icon(
              Icons.support_agent_outlined,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: WkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  broker.name,
                  style: context.text.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: WkSpacing.sm),
                _MetaLine(
                  icon: Icons.bolt_outlined,
                  label: context.l10n.brokerResponseRate(
                    (broker.responseRate * 100).round(),
                  ),
                ),
                const SizedBox(height: WkSpacing.sm),
                Wrap(
                  spacing: WkSpacing.xs,
                  runSpacing: WkSpacing.xs,
                  children: <Widget>[
                    if (broker.isVerified)
                      WkBadge(
                        label: context.l10n.badgeVerified,
                        icon: Icons.verified_user,
                        tone: WkBadgeTone.positive,
                      ),
                    if (broker.coverage.isNotEmpty)
                      WkBadge(
                        label: broker.coverage.first,
                        icon: Icons.place_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
        const SizedBox(width: WkSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// M05 — résultat du contact, posé au retour de l'application externe.
///
/// « Pas de réponse » n'est pas un échec de l'application : il ne produit
/// aucun retour d'erreur, seulement une trace honnête.
class ContactOutcomeSheet extends StatelessWidget {
  const ContactOutcomeSheet({super.key});

  static Future<ContactOutcome?> show(BuildContext context) {
    return showModalBottomSheet<ContactOutcome>(
      context: context,
      // Racine, pas la branche : une feuille ouverte dans le Navigator
      // d'un onglet laisserait la barre d'onglets cliquable au-dessus de
      // sa propre barrière modale.
      useRootNavigator: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(WkRadius.xxl)),
      ),
      builder: (_) => const ContactOutcomeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(WkSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.l10n.outcomeTitle,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: WkSpacing.lg),
            WkButton(
              label: context.l10n.outcomeReached,
              icon: Icons.check_circle_outline,
              onPressed: () =>
                  Navigator.of(context).pop(ContactOutcome.reached),
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            WkButton(
              label: context.l10n.outcomeNoAnswer,
              variant: WkButtonVariant.secondary,
              onPressed: () =>
                  Navigator.of(context).pop(ContactOutcome.noAnswer),
            ),
            const SizedBox(height: WkSpacing.betweenTargets),
            WkButton(
              label: context.l10n.outcomeLater,
              variant: WkButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
