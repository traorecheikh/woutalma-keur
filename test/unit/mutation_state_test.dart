import 'package:flutter_test/flutter_test.dart';
import 'package:woutalma_keur/app/core/state/mutation_state.dart';
import 'package:woutalma_keur/app/core/state/screen_state.dart';

void main() {
  group('MutationState', () {
    test('une soumission en cours refuse tout nouvel appui', () {
      const MutationState submitting = MutationState.submitting();

      expect(submitting.isSubmitting, isTrue);
      expect(submitting.acceptsInput, isFalse);
    });

    test('un échec reste réessayable', () {
      const MutationState failure = MutationState.failure(
        WkFailure.localStorage,
      );

      expect(failure.acceptsInput, isTrue);
    });

    test('idle et succès acceptent un appui', () {
      expect(const MutationState.idle().acceptsInput, isTrue);
      expect(const MutationState.success().acceptsInput, isTrue);
    });

    test('map couvre les quatre états', () {
      const List<MutationState> states = <MutationState>[
        MutationState.idle(),
        MutationState.submitting(),
        MutationState.success(),
        MutationState.failure(WkFailure.seed),
      ];

      final List<String> labels = states
          .map(
            (MutationState s) => s.map(
              idle: () => 'idle',
              submitting: () => 'submitting',
              success: () => 'success',
              failure: (WkFailure f) => 'failure:${f.name}',
            ),
          )
          .toList();

      expect(labels, <String>['idle', 'submitting', 'success', 'failure:seed']);
    });
  });
}
