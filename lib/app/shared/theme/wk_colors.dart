import 'package:flutter/material.dart';

/// Jetons de couleur de `docs/DESIGN.md`.
///
/// Exposés en `ThemeExtension` plutôt qu'en constantes globales : un écran lit
/// `context.colors`, ce qui rend le mode sombre automatique et rend impossible
/// l'usage d'une couleur qui n'existe pas dans le système.
@immutable
class WkColors extends ThemeExtension<WkColors> {
  const WkColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.call,
    required this.onCall,
    required this.whatsapp,
    required this.onWhatsapp,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.statusAvailable,
    required this.statusAvailableContainer,
    required this.statusReserved,
    required this.statusClosed,
  });

  /// Seule couleur d'action. Au-delà de 10 % de l'écran, le bouton primaire
  /// cesse d'être lu comme *le* bouton.
  final Color primary;
  final Color onPrimary;

  /// Seule surface où la marque a droit de cité : chip sélectionné, badge.
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;

  /// Sémantiques de contact. Jamais décoratives : le vert et le rouge
  /// appartiennent aux boutons Appeler et WhatsApp.
  final Color call;
  final Color onCall;
  final Color whatsapp;
  final Color onWhatsapp;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  final Color statusAvailable;
  final Color statusAvailableContainer;
  final Color statusReserved;
  final Color statusClosed;

  static const WkColors light = WkColors(
    primary: Color(0xFF0B3B66),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE7F2),
    onPrimaryContainer: Color(0xFF06253F),
    background: Color(0xFFF3F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE9EDF2),
    onSurface: Color(0xFF0F1419),
    onSurfaceVariant: Color(0xFF59616B),
    outline: Color(0xFFC4CBD4),
    outlineVariant: Color(0xFFDCE1E8),
    call: Color(0xFF0F7B3F),
    onCall: Color(0xFFFFFFFF),
    whatsapp: Color(0xFF25D366),
    onWhatsapp: Color(0xFF0F1419),
    error: Color(0xFFC42B1C),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBE1DE),
    onErrorContainer: Color(0xFF480B04),
    statusAvailable: Color(0xFF0F7B3F),
    statusAvailableContainer: Color(0xFFE1F2E8),
    statusReserved: Color(0xFF0B3B66),
    statusClosed: Color(0xFF59616B),
  );

  /// Le sombre n'est pas l'inverse du clair. Les surfaces descendent par
  /// paliers, le primaire change de valeur, les sémantiques ne bougent pas.
  static const WkColors dark = WkColors(
    primary: Color(0xFF7FB3E0),
    onPrimary: Color(0xFF0B0F14),
    primaryContainer: Color(0xFF1E3450),
    onPrimaryContainer: Color(0xFFDCE7F2),
    background: Color(0xFF0B0F14),
    surface: Color(0xFF141A21),
    surfaceVariant: Color(0xFF1E262F),
    onSurface: Color(0xFFE6EAEF),
    onSurfaceVariant: Color(0xFF98A1AC),
    outline: Color(0xFF333C47),
    outlineVariant: Color(0xFF232B34),
    call: Color(0xFF0F7B3F),
    onCall: Color(0xFFFFFFFF),
    whatsapp: Color(0xFF25D366),
    onWhatsapp: Color(0xFF0F1419),
    error: Color(0xFFC42B1C),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFF4A1712),
    onErrorContainer: Color(0xFFFBE1DE),
    statusAvailable: Color(0xFF4FBF80),
    statusAvailableContainer: Color(0xFF163427),
    statusReserved: Color(0xFF7FB3E0),
    statusClosed: Color(0xFF98A1AC),
  );

  @override
  WkColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? call,
    Color? onCall,
    Color? whatsapp,
    Color? onWhatsapp,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? statusAvailable,
    Color? statusAvailableContainer,
    Color? statusReserved,
    Color? statusClosed,
  }) {
    return WkColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      call: call ?? this.call,
      onCall: onCall ?? this.onCall,
      whatsapp: whatsapp ?? this.whatsapp,
      onWhatsapp: onWhatsapp ?? this.onWhatsapp,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      statusAvailable: statusAvailable ?? this.statusAvailable,
      statusAvailableContainer:
          statusAvailableContainer ?? this.statusAvailableContainer,
      statusReserved: statusReserved ?? this.statusReserved,
      statusClosed: statusClosed ?? this.statusClosed,
    );
  }

  @override
  WkColors lerp(ThemeExtension<WkColors>? other, double t) {
    if (other is! WkColors) {
      return this;
    }
    return WkColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      call: Color.lerp(call, other.call, t)!,
      onCall: Color.lerp(onCall, other.onCall, t)!,
      whatsapp: Color.lerp(whatsapp, other.whatsapp, t)!,
      onWhatsapp: Color.lerp(onWhatsapp, other.onWhatsapp, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      statusAvailable: Color.lerp(statusAvailable, other.statusAvailable, t)!,
      statusAvailableContainer: Color.lerp(
        statusAvailableContainer,
        other.statusAvailableContainer,
        t,
      )!,
      statusReserved: Color.lerp(statusReserved, other.statusReserved, t)!,
      statusClosed: Color.lerp(statusClosed, other.statusClosed, t)!,
    );
  }
}
