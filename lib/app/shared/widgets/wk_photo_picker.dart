import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/feedback/interaction_feedback.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/shared/theme/wk_spacing.dart';
import 'package:woutalma_keur/app/shared/theme/wk_theme.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_button.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_option_sheet.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';

/// Photos d'un bien.
///
/// La compression est annoncée à l'écran : le courtier paie sa data, il a le
/// droit de savoir qu'on l'économise pour lui.
class WkPhotoPicker extends StatelessWidget {
  const WkPhotoPicker({
    required this.paths,
    required this.service,
    required this.onChanged,
    super.key,
  });

  /// Chemins des photos déjà ajoutées.
  final List<String> paths;
  final PhotoService service;
  final ValueChanged<List<String>> onChanged;

  bool get _isFull => paths.length >= service.maxPerProperty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                context.l10n.photosLabel,
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              context.l10n.photosCount(paths.length, service.maxPerProperty),
              style: context.text.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: WkSpacing.sm),
        if (paths.isEmpty)
          _EmptyPhotoCard(onTap: _isFull ? null : () => _add(context))
        else
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: paths.length,
              separatorBuilder: (_, _) => const SizedBox(width: WkSpacing.sm),
              itemBuilder: (BuildContext context, int index) => _Thumbnail(
                path: paths[index],
                onRemove: () => _remove(context, index),
              ),
            ),
          ),
        if (paths.isNotEmpty) ...<Widget>[
          const SizedBox(height: WkSpacing.sm),
          WkButton(
            label: context.l10n.photosAdd,
            icon: Icons.add_a_photo_outlined,
            variant: WkButtonVariant.secondary,
            expand: false,
            onPressed: _isFull ? null : () => _add(context),
            disabledReason: context.l10n.photosLimit(service.maxPerProperty),
          ),
          const SizedBox(height: WkSpacing.xs),
          Text(
            context.l10n.photosCompressed,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _add(BuildContext context) async {
    final List<PhotoSource>? source = await WkOptionSheet.show<PhotoSource>(
      context,
      title: context.l10n.photosSourceTitle,
      options: <WkOption<PhotoSource>>[
        WkOption<PhotoSource>(
          value: PhotoSource.camera,
          label: context.l10n.photosCamera,
          icon: Icons.photo_camera_outlined,
        ),
        WkOption<PhotoSource>(
          value: PhotoSource.gallery,
          label: context.l10n.photosGallery,
          icon: Icons.photo_library_outlined,
        ),
      ],
    );
    if (source == null || !context.mounted) {
      return;
    }

    final String? path = await service.pick(source.first);
    if (!context.mounted) {
      return;
    }
    if (path == null) {
      // Échec sur cette photo seulement : les autres restent en place.
      context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.error);
      return;
    }
    onChanged(<String>[...paths, path]);
  }

  void _remove(BuildContext context, int index) {
    context.read<InteractionFeedbackService?>()?.emit(FeedbackIntent.selection);
    final List<String> next = <String>[...paths]..removeAt(index);
    onChanged(next);
  }
}

class _EmptyPhotoCard extends StatelessWidget {
  const _EmptyPhotoCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WkRadius.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(WkRadius.lg),
            border: Border.all(color: context.colors.outlineVariant),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 40,
                  color: context.colors.onPrimaryContainer,
                ),
                const SizedBox(height: WkSpacing.sm),
                Text(
                  context.l10n.photosAdd,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: WkSpacing.xs),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WkSpacing.md),
                  child: Text(
                    context.l10n.photosCompressed,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(WkRadius.sm),
          // Passe par `WkPropertyPhoto` : à la modification d'un bien déjà
          // publié, les vignettes sont des clés `api:<id>` et non des chemins
          // locaux. `Image.file` en faisait des images cassées.
          child: SizedBox(
            width: 96,
            height: 96,
            child: WkPropertyPhoto(
              path: path,
              fallbackIcon: Icons.broken_image_outlined,
              cacheWidth: 192,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Semantics(
            button: true,
            label: context.l10n.photosRemove,
            child: InkResponse(
              onTap: onRemove,
              // La pastille reste petite pour ne pas manger la vignette, mais
              // la cible fait le plancher : elle s'étend vers l'intérieur de
              // l'image. Une croix de 32 dp se rate au doigt, et se rater ici
              // veut dire supprimer la mauvaise photo au deuxième essai.
              child: SizedBox(
                width: WkTouch.min,
                height: WkTouch.min,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.onSurface.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: context.colors.surface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
