import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';

void main() {
  group('ScreenState', () {
    test('un état vide est résolu, pas en chargement', () {
      const ScreenState<List<int>> state = ScreenState<List<int>>.empty();

      expect(state.isLoading, isFalse);
      expect(state.isResolved, isTrue);
      expect(state.valueOrNull, isNull);
    });

    test('data expose sa valeur, les autres états non', () {
      const ScreenState<int> data = ScreenState<int>.data(3);
      const ScreenState<int> loading = ScreenState<int>.loading();

      expect(data.valueOrNull, 3);
      expect(loading.valueOrNull, isNull);
    });

    test('initial n\'est pas résolu — un écran ne peut pas le confondre '
        'avec un résultat vide', () {
      const ScreenState<int> state = ScreenState<int>.initial();

      expect(state.isResolved, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('une liste vide reste un état data si le producteur le décide', () {
      // Le type n'impose pas la sémantique : c'est au view model de choisir
      // entre data([]) et empty(). Ce test fige le fait que les deux existent
      // et ne sont pas égaux.
      const ScreenState<List<int>> data = ScreenState<List<int>>.data(<int>[]);
      const ScreenState<List<int>> empty = ScreenState<List<int>>.empty();

      expect(data, isNot(equals(empty)));
    });

    test('map couvre les cinq états', () {
      const List<ScreenState<int>> states = <ScreenState<int>>[
        ScreenState<int>.initial(),
        ScreenState<int>.loading(),
        ScreenState<int>.data(1),
        ScreenState<int>.empty(),
        ScreenState<int>.error(WkFailure.localStorage),
      ];

      final List<String> labels = states
          .map(
            (ScreenState<int> s) => s.map(
              initial: () => 'initial',
              loading: () => 'loading',
              data: (int v) => 'data:$v',
              empty: () => 'empty',
              error: (WkFailure f) => 'error:${f.name}',
            ),
          )
          .toList();

      expect(labels, <String>[
        'initial',
        'loading',
        'data:1',
        'empty',
        'error:localStorage',
      ]);
    });

    test('deux erreurs de même cause sont égales', () {
      const ScreenState<int> a = ScreenState<int>.error(WkFailure.seed);
      const ScreenState<int> b = ScreenState<int>.error(WkFailure.seed);
      const ScreenState<int> c = ScreenState<int>.error(WkFailure.permission);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
