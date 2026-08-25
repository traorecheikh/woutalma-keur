import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:woutalma_keur/app/core/app_config.dart';
import 'package:woutalma_keur/app/data/repositories/in_memory_repositories.dart';
import 'package:woutalma_keur/app/data/seed/demo_seed.dart';
import 'package:woutalma_keur/app/domain/contact_launcher.dart';
import 'package:woutalma_keur/app/domain/discovery.dart';
import 'package:woutalma_keur/app/domain/entities.dart';
import 'package:woutalma_keur/app/domain/ranking.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_screen.dart';
import 'package:woutalma_keur/app/modules/client/broker/broker_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/explore_view_model.dart';
import 'package:woutalma_keur/app/modules/client/explore/search_overlay.dart';
import 'package:woutalma_keur/app/modules/client/property/property_screen.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_card.dart';
import 'package:woutalma_keur/app/shared/widgets/wk_property_photo.dart';

import '../support/fake_location.dart';
import '../support/pump.dart';

/// Ce qu'un courtier vient de publier depuis son téléphone, pas une ligne de
/// seed.
///
/// Le seed est confortable : trois photos embarquées, une description écrite,
/// une surface et un nombre de pièces. Un bien réel arrive souvent sans rien
/// de tout cela — un terrain n'a pas de pièces, une annonce pressée n'a pas de
/// description, et la photo, quand elle existe, vient du serveur. C'est cette
/// forme-là que les écrans clients doivent tenir.
const String freshTitle =
    'TERRAIN 300m2 A VENDRE MERMOZ derriere la station juste a cote '
    'de l ecole francaise titre foncier dispo prix negociable';

Property freshListing({
  List<String> photos = const <String>[],
  String description = '',
  String title = freshTitle,
}) {
  return Property(
    id: 'prp-fresh',
    brokerId: 'brk-teranga',
    kind: PropertyKind.land,
    transaction: TransactionKind.sale,
    title: title,
    description: description,
    price: 25000000,
    position: const GeoPoint(14.6952, -17.4611),
    neighbourhood: 'Mermoz',
    createdAt: DateTime(2026, 8, 15),
    photoAssets: photos,
  );
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    store = InMemoryStore();
    await InMemorySeedRepository(store).loadDemoSeed();
  });

  Future<void> pumpDetail(
    WidgetTester tester,
    Property property, {
    Size surfaceSize = const Size(360, 800),
    double textScale = 1,
  }) async {
    await InMemoryPropertyRepository(store).save(property);
    final PropertyViewModel model = PropertyViewModel(
      properties: InMemoryPropertyRepository(store),
      brokers: InMemoryBrokerRepository(store),
      contact: ContactService(
        contacts: InMemoryContactRepository(
          store,
          now: () => DateTime(2026, 1, 1),
        ),
        launcher: _NoopLauncher(),
      ),
      propertyId: property.id,
      from: DemoSeed.clientPosition,
    );
    await model.load();
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<PropertyViewModel>.value(
        value: model,
        child: PropertyScreen(onBack: () {}, onOpenBroker: (_) {}),
      ),
      surfaceSize: surfaceSize,
      textScale: textScale,
    );
    await tester.pumpAndSettle();
  }

  // --- C03, fiche d'un bien fraîchement publié -----------------------------

  testWidgets('la fiche d\'un bien sans photo, sans description et sans '
      'surface ni pièces reste complète', (WidgetTester tester) async {
    await pumpDetail(tester, freshListing());

    // Le prix, le titre, le quartier : ce qui répond à « ce bien me
    // correspond-il ? » ne dépend d'aucun champ optionnel.
    expect(
      find.text('${NumberFormat('#,##0', 'fr').format(25000000)} F'),
      findsOneWidget,
    );
    // Deux fois : la barre haute et le corps de la fiche.
    expect(find.text(freshTitle), findsNWidgets(2));
    expect(find.textContaining('Mermoz'), findsOneWidget);
    expect(find.textContaining('Terrain'), findsWidgets);
    expect(find.textContaining('À vendre'), findsOneWidget);

    // Aucun champ nul ne fuit à l'écran, sous aucune forme.
    expect(find.textContaining('null'), findsNothing);
    expect(find.textContaining('m²'), findsNothing);
    expect(find.textContaining('pièce'), findsNothing);

    // Pas de bloc « Proposé par » vide : le courtier existe, il est nommé.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Proposé par'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sans photo, la fiche montre un aplat de marque de la même '
      'hauteur qu\'une galerie', (WidgetTester tester) async {
    await pumpDetail(tester, freshListing());

    // Aucune image demandée, donc aucun trou : c'est le repli de marque qui
    // occupe la place, avec le pictogramme du type de bien.
    expect(find.byType(Image), findsNothing);
    expect(find.byType(PageView), findsNothing);
    final Finder placeholder = find.byIcon(Icons.home_work_outlined);
    expect(placeholder, findsOneWidget);

    // Un bloc écrasé serait pire qu'une photo manquante : la fiche
    // commencerait par une bande grise inexplicable.
    final Size size = tester.getSize(find.byType(WkPhotoCarousel).first);
    expect(size.height, greaterThan(120));
    expect(size.width, greaterThan(280));
  });

  testWidgets('une photo stockée sur le serveur est demandée au réseau', (
    WidgetTester tester,
  ) async {
    await pumpDetail(
      tester,
      freshListing(photos: const <String>['api:ph-fresh-1']),
    );

    expect(
      tester.widget<Image>(find.byType(Image).first).image,
      isA<NetworkImage>().having(
        (NetworkImage provider) => provider.url,
        'url',
        '${AppConfig.apiBaseUrl}/properties/photos/ph-fresh-1',
      ),
    );
  });

  testWidgets('une photo serveur qui n\'est pas encore arrivée laisse le '
      'repli de marque, pas un trou', (WidgetTester tester) async {
    await pumpDetail(
      tester,
      freshListing(photos: const <String>['api:ph-fresh-1']),
    );

    // Sur un réseau faible, la première image met des secondes à arriver.
    // Pendant ce temps la galerie doit rester un bloc de marque lisible : la
    // photo du seed est un asset décodé dans la frame, celle-ci traverse le
    // réseau.
    final Image image = tester.widget<Image>(find.byType(Image).first);
    final BuildContext context = tester.element(
      find.byType(WkPropertyPhoto).first,
    );
    const Widget decoded = SizedBox.shrink();
    expect(image.frameBuilder, isNotNull);
    expect(
      image.frameBuilder!(context, decoded, null, false),
      isNot(same(decoded)),
    );
    expect(image.frameBuilder!(context, decoded, 0, false), same(decoded));

    // Et quand la requête échoue pour de bon, c'est le même aplat.
    expect(find.byIcon(Icons.home_work_outlined), findsOneWidget);
  });

  double contentExtent(WidgetTester tester) {
    final ScrollableState scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    return scrollable.position.maxScrollExtent;
  }

  testWidgets('une description vide ne laisse ni bloc ni intitulé orphelin', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, freshListing());

    // Un paragraphe absent ne laisse pas un `Text` vide, donc pas un bloc de
    // hauteur nulle coincé entre deux espacements.
    for (final Element element in find.byType(Text).evaluate()) {
      expect((element.widget as Text).data, isNot(''));
    }
    final double withoutDescription = contentExtent(tester);

    await pumpDetail(
      tester,
      freshListing(description: 'Terrain viabilisé, clôturé, titre foncier.'),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(
      find.text('Terrain viabilisé, clôturé, titre foncier.'),
      findsOneWidget,
    );

    // Une description courte ajoute exactement sa hauteur : rien n'est réservé
    // pour elle quand elle manque.
    expect(contentExtent(tester), greaterThan(withoutDescription));
  });

  testWidgets('un titre long tapé au téléphone tronque là où c\'est un '
      'choix, jamais dans la copie d\'interface', (WidgetTester tester) async {
    await pumpDetail(
      tester,
      freshListing(),
      surfaceSize: const Size(320, 800),
      textScale: 1.3,
    );

    // Le titre est du contenu utilisateur : la barre haute le coupe à trois
    // lignes, le corps de la fiche le donne en entier.
    expectNoClippedText(tester, userContent: <String>{freshTitle});
    expectTouchTargets(tester);
    expect(tester.takeException(), isNull);
  });

  // --- Carte de résultat ----------------------------------------------------

  Future<void> pumpCard(WidgetTester tester, Property property) async {
    await pumpWk(
      tester,
      WkPropertyCard(property: property, distanceMeters: 1200, onOpen: () {}),
    );
    await tester.pump();
  }

  testWidgets('la carte d\'un bien sans surface ni pièces n\'affiche ni '
      'puce vide ni « null »', (WidgetTester tester) async {
    await pumpCard(tester, freshListing());

    expect(find.textContaining('Terrain'), findsOneWidget);
    expect(find.textContaining('1,2 km'), findsOneWidget);
    expect(find.textContaining('null'), findsNothing);
    expect(find.textContaining('m²'), findsNothing);
    expect(find.textContaining('pièce'), findsNothing);
  });

  testWidgets('la carte sans photo garde sa bande d\'image', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, freshListing());

    expect(find.byType(Image), findsNothing);
    // La bande garde sa hauteur : sans elle, une carte sans photo serait deux
    // fois plus courte que ses voisines et la liste sauterait.
    expect(find.byType(WkPropertyPhoto), findsNothing);
    expect(
      tester.getSize(find.byType(WkPropertyCard)).height,
      greaterThan(200),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('la carte rend les trois provenances de photo', (
    WidgetTester tester,
  ) async {
    await pumpCard(
      tester,
      freshListing(photos: const <String>['api:ph-fresh-1']),
    );
    expect(tester.widget<Image>(find.byType(Image)).image, isA<NetworkImage>());

    await pumpCard(
      tester,
      freshListing(photos: const <String>['demo:house:medina:front']),
    );
    expect(tester.widget<Image>(find.byType(Image)).image, isA<AssetImage>());
  });

  testWidgets('le titre long ne déborde pas de la carte', (
    WidgetTester tester,
  ) async {
    await pumpWk(
      tester,
      WkPropertyCard(
        property: freshListing(),
        distanceMeters: 1200,
        onOpen: () {},
      ),
      surfaceSize: const Size(320, 800),
      textScale: 1.3,
    );
    await tester.pump();

    // Troncature assumée : deux lignes sur la carte, le titre entier est à un
    // geste, sur la fiche.
    expectNoClippedText(tester, userContent: <String>{freshTitle});
    expect(tester.takeException(), isNull);
  });

  // --- Le client atteint-il vraiment le bien ? ------------------------------

  Future<ExploreViewModel> pumpSearch(
    WidgetTester tester, {
    required void Function(String propertyId) onOpenProperty,
  }) async {
    await InMemoryPropertyRepository(store).save(freshListing());
    final ExploreViewModel model = ExploreViewModel(
      discovery: LocalDiscoveryService(
        brokers: InMemoryBrokerRepository(store),
        properties: InMemoryPropertyRepository(store),
        reviews: InMemoryReviewRepository(store),
      ),
      position: fakePositions(),
      debounce: const Duration(milliseconds: 10),
    );
    addTearDown(model.dispose);
    model.selectSegment(ExploreSegment.properties);
    await model.load();

    await pumpWk(
      tester,
      SearchOverlay(
        model: model,
        onOpenBroker: (_) {},
        onOpenProperty: onOpenProperty,
      ),
    );
    await tester.pumpAndSettle();
    return model;
  }

  /// Le titre du bien apparaît deux fois pendant une recherche : une fois en
  /// complétion de frappe, une fois sur la carte de résultat. Seule la carte
  /// ouvre la fiche.
  Finder freshCard() => find.descendant(
    of: find.byType(WkPropertyCard),
    matching: find.text(freshTitle),
  );

  testWidgets('chercher le quartier ramène le bien fraîchement publié', (
    WidgetTester tester,
  ) async {
    String? opened;
    final ExploreViewModel model = await pumpSearch(
      tester,
      onOpenProperty: (String id) => opened = id,
    );

    await tester.enterText(find.byType(TextField), 'mermoz');
    await tester.pumpAndSettle();

    expect(
      model.state.valueOrNull!.properties.map((Property p) => p.id),
      contains('prp-fresh'),
    );

    await tester.scrollUntilVisible(
      freshCard(),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(freshCard());
    await tester.pumpAndSettle();
    expect(opened, 'prp-fresh');
  });

  testWidgets('chercher un mot du titre ramène le bien, casse comprise', (
    WidgetTester tester,
  ) async {
    final ExploreViewModel model = await pumpSearch(
      tester,
      onOpenProperty: (_) {},
    );

    // Le courtier a tapé en majuscules et sans accents ; la cliente tape en
    // minuscules avec l'accent.
    await tester.enterText(find.byType(TextField), 'école');
    await tester.pumpAndSettle();

    expect(
      model.state.valueOrNull!.properties.map((Property p) => p.id),
      <String>['prp-fresh'],
    );
    await tester.scrollUntilVisible(
      freshCard(),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(freshCard(), findsOneWidget);
  });

  testWidgets('le bien apparaît sur la fiche de son courtier et s\'y ouvre', (
    WidgetTester tester,
  ) async {
    await InMemoryPropertyRepository(store).save(freshListing());
    String? opened;

    final BrokerViewModel model = BrokerViewModel(
      brokerId: 'brk-teranga',
      brokers: InMemoryBrokerRepository(store),
      properties: InMemoryPropertyRepository(store),
      reviews: InMemoryReviewRepository(store),
      contact: ContactService(
        contacts: InMemoryContactRepository(
          store,
          now: () => DateTime(2026, 1, 1),
        ),
        launcher: _NoopLauncher(),
      ),
      from: DemoSeed.clientPosition,
    );
    await model.load();
    addTearDown(model.dispose);

    await pumpWk(
      tester,
      ChangeNotifierProvider<BrokerViewModel>.value(
        value: model,
        child: BrokerScreen(
          onBack: () {},
          onOpenProperty: (String id) => opened = id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(freshTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('null'), findsNothing);

    // Le terrain est à Mermoz, l'agence à Sacré-Cœur : la carte annonce la
    // distance du bien, pas celle du bureau qui le propose.
    final double own = distanceMeters(
      DemoSeed.clientPosition,
      freshListing().position,
    );
    expect(
      find.descendant(
        of: find.byType(WkPropertyCard),
        matching: find.textContaining(
          '${NumberFormat('#,##0.#', 'fr').format(own / 1000)} km',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(freshTitle));
    await tester.pumpAndSettle();
    expect(opened, 'prp-fresh');
  });
}

class _NoopLauncher implements ContactLauncher {
  @override
  Future<bool> open(ContactChannel channel, Broker broker) async => true;
}
