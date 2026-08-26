import 'package:flutter/material.dart';
import 'package:woutalma_keur/app/domain/photo_service.dart';
import 'package:woutalma_keur/app/ui/ui.dart';

class AppPhotoPicker extends StatelessWidget {
  const AppPhotoPicker({
    super.key,
    required this.paths,
    required this.service,
    required this.onChanged,
    this.max = 3,
  });
  final List<String> paths;
  final PhotoService service;
  final ValueChanged<List<String>> onChanged;
  final int max;

  bool get _full => paths.length >= max;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.photosLabel,
                style: context.text.labelLarge!.copyWith(
                  color: context.tones.inkSecondary,
                ),
              ),
            ),
            Text(
              l.photosCount(paths.length, max),
              style: context.text.bodySmall!.copyWith(
                color: context.tones.inkSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.sm),
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final (i, p) in paths.indexed)
                Padding(
                  padding: const EdgeInsets.only(right: Insets.sm),
                  child: _Thumb(
                    path: p,
                    onRemove: () => onChanged([...paths]..removeAt(i)),
                  ),
                ),
              if (!_full)
                FTappable(
                  onPress: () => _add(context),
                  semanticsLabel: l.photosAdd,
                  behavior: HitTestBehavior.opaque,
                  child: ExcludeSemantics(
                    child: Container(
                      width: 104,
                      height: 104,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.tones.sunken,
                        borderRadius: Radii.container,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Insets.xs,
                        children: [
                          Icon(FIcons.camera, color: context.colors.onSurface),
                          Text(l.photosAdd, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Insets.sm),
        Text(
          l.photosCompressed,
          style: context.text.bodySmall!.copyWith(
            color: context.tones.inkSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context) async {
    final l = context.l10n;
    final source = await pick<PhotoSource>(
      context,
      title: l.photosSourceTitle,
      options: PhotoSource.values,
      label: (s) => s == PhotoSource.camera ? l.photosCamera : l.photosGallery,
      icon: (s) => s == PhotoSource.camera ? FIcons.camera : FIcons.image,
    );
    if (source == null || !context.mounted) return;
    final String? path;
    try {
      path = await service.pick(source);
    } on Object {
      if (context.mounted) toast(context, l.photosFailed);
      return;
    }
    if (!context.mounted || path == null) return;
    onChanged([...paths, path]);
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      SizedBox(
        width: 104,
        height: 104,
        child: AppPhoto(path, radius: Radii.container),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: FTappable(
          onPress: onRemove,
          semanticsLabel: context.l10n.photosRemove,
          behavior: HitTestBehavior.opaque,
          // La cible fait 48 ; la pastille visible reste petite pour ne pas
          // manger la photo.
          child: SizedBox(
            width: Touch.compact,
            height: Touch.compact,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.onSurface.withValues(alpha: .75),
                  shape: BoxShape.circle,
                ),
                child: Icon(FIcons.x, size: 18, color: context.colors.surface),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
