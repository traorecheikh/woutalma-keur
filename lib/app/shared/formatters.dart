import 'package:flutter/material.dart';
import 'package:forui/forui.dart' show FIcons;
import 'package:intl/intl.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/l10n/generated/app_l10n.dart';

/// Mise en forme des données affichées.
///
/// Toutes les unités — mètre, kilomètre, franc, mètre carré — viennent de
/// l'ARB : une unité écrite en dur oblige à rouvrir chaque écran le jour où
/// une seconde monnaie ou une seconde langue arrive.
abstract final class WkFormat {
  static final NumberFormat _money = NumberFormat('#,##0', 'fr');

  /// Distance lisible d'un coup d'œil : mètres tant qu'on peut y aller à pied,
  /// kilomètres ensuite. Jamais « 1 234 m ».
  static String distance(AppL10n l10n, double meters) {
    if (meters < 1000) {
      // Arrondi à 50 m : une précision au mètre serait fausse et illisible.
      final int rounded = (meters / 50).round() * 50;
      return l10n.distanceMeters(rounded < 50 ? 50 : rounded);
    }
    final double km = meters / 1000;
    return l10n.distanceKilometers(NumberFormat('#,##0.#', 'fr').format(km));
  }

  /// Prix avec son unité, adaptée à la nature de la transaction.
  static String price(AppL10n l10n, int amount, TransactionKind transaction) =>
      priceAmount(l10n, amount, monthly: transaction == TransactionKind.rent);

  /// Forme écrite unique : « 250 000 F » ou « 250 000 F / mois ».
  static String priceAmount(AppL10n l10n, int amount, {bool monthly = false}) {
    final String formatted = _money.format(amount);
    return monthly ? l10n.priceRent(formatted) : l10n.priceSale(formatted);
  }

  /// Forme parlée : « F » ne se prononce pas.
  static String priceSpoken(AppL10n l10n, int amount, {bool monthly = false}) {
    final String formatted = _money.format(amount);
    return monthly
        ? l10n.priceRentSpoken(formatted)
        : l10n.priceSpoken(formatted);
  }

  /// « Répond à 8 personnes sur 10 » : un pourcentage ne se lit pas, une
  /// proportion sur dix se compte sur les doigts.
  static String responseRate(AppL10n l10n, double rate) =>
      l10n.brokerRespondsOutOfTen((rate * 10).round().clamp(0, 10));

  static String transaction(AppL10n l10n, TransactionKind value) {
    return switch (value) {
      TransactionKind.rent => l10n.transactionRent,
      TransactionKind.sale => l10n.transactionSale,
    };
  }

  static String propertyKind(AppL10n l10n, PropertyKind value) {
    return switch (value) {
      PropertyKind.apartment => l10n.kindApartment,
      PropertyKind.house => l10n.kindHouse,
      PropertyKind.land => l10n.kindLand,
      PropertyKind.studio => l10n.kindStudio,
      PropertyKind.room => l10n.kindRoom,
    };
  }

  /// Pictogramme d'un type de bien.
  ///
  /// « Studio » et « Chambre » sont deux mots que la cible ne lit pas toujours ;
  /// sans image, la liste des types est un mur de texte où l'on choisit au
  /// hasard. Le picto n'est jamais seul : il accompagne le mot.
  static IconData propertyKindIcon(PropertyKind value) {
    return switch (value) {
      PropertyKind.apartment => FIcons.building2,
      PropertyKind.house => FIcons.house,
      PropertyKind.land => FIcons.landPlot,
      PropertyKind.studio => FIcons.bedSingle,
      PropertyKind.room => FIcons.bedDouble,
    };
  }

  static String propertyStatus(AppL10n l10n, PropertyStatus value) {
    return switch (value) {
      PropertyStatus.available => l10n.statusAvailable,
      PropertyStatus.reserved => l10n.statusReserved,
      PropertyStatus.closed => l10n.statusClosed,
    };
  }

  /// Note à une décimale, virgule française. Toujours accompagnée du volume
  /// d'avis : un 5,0 sur un seul avis ne vaut pas un 4,5 sur cinquante.
  static String rating(double value) => NumberFormat('0.0', 'fr').format(value);

  /// « Appartement · 3 pièces · 80 m² · Mermoz · 1,2 km » sur une ligne.
  static String propertyMeta(
    AppL10n l10n,
    Property property,
    double distanceMeters,
  ) {
    return <String>[
      transaction(l10n, property.transaction),
      propertyKind(l10n, property.kind),
      if (property.rooms != null) l10n.roomCount(property.rooms!),
      if (property.surface != null) l10n.surfaceValue(property.surface!),
      property.neighbourhood,
      distance(l10n, distanceMeters),
    ].join(' · ');
  }
}
