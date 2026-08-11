import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';

/// Vignette d'identité d'un courtier ou d'une agence.
///
/// Tant qu'un courtier n'a pas déposé sa photo, on affiche ses initiales, pas
/// une silhouette dessinée : un pictogramme générique donne la même image à
/// six courtiers différents, alors que « MN » distingue Moussa Ndiaye dans une
/// liste qu'on parcourt au pouce.
///
/// La forme, pas la couleur, porte le type : disque pour une personne, carré
/// arrondi pour une agence. Un daltonien lit la différence, un écran de mauvaise
/// qualité aussi.
class WkAvatar extends StatelessWidget {
  const WkAvatar({
    required this.name,
    required this.kind,
    this.imagePath,
    this.size = 60,
    super.key,
  });

  final String name;
  final BrokerKind kind;

  /// Photo ou logo déposé. Un asset, ou un fichier local venu de l'appareil.
  final String? imagePath;

  final double size;

  /// Une ou deux lettres, jamais plus : au-delà on ne lit plus rien à 60 dp.
  ///
  /// Les deux **premiers** mots, pas le premier et le dernier : « Agence
  /// Teranga Immo » donne AT, la façon dont l'agence est nommée à l'oral, là
  /// où premier+dernier donnerait AI.
  static String initials(String name) {
    final List<String> words = name
        .split(RegExp(r'[\s-]+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '?';
    }
    return words
        .take(2)
        .map((String w) => w.substring(0, 1).toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final bool agency = kind == BrokerKind.agency;
    final BorderRadius radius = BorderRadius.circular(
      agency ? WkRadius.lg : WkRadius.full,
    );
    // L'agence prend la surface de marque pleine, la personne sa déclinaison
    // claire : deux niveaux du même jeton, aucune couleur inventée.
    final Color background = agency
        ? context.colors.primary
        : context.colors.primaryContainer;
    final Color foreground = agency
        ? context.colors.onPrimary
        : context.colors.onPrimaryContainer;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: imagePath == null
            ? ColoredBox(
                color: background,
                child: Center(
                  child: Text(
                    initials(name),
                    style: context.text.headlineMedium?.copyWith(
                      color: foreground,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : WkPropertyPhoto(
                path: imagePath!,
                fallbackIcon: agency
                    ? Icons.storefront_outlined
                    : Icons.person_outline,
                cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                    .round(),
              ),
      ),
    );
  }
}
