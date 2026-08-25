import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';

/// Titre de section d'une page qui défile, avec son « Voir tout ».
class WkSectionHeader extends StatelessWidget {
  const WkSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WkSpacing.page),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: context.text.headlineMedium),
            ),
          ),
          if (actionLabel != null && onAction != null)
            WkButton(
              label: actionLabel!,
              icon: Icons.arrow_forward,
              variant: WkButtonVariant.ghost,
              expand: false,
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}
