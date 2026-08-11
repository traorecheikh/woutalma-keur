import 'package:woutalma_keur/app/core/state/screen_state.dart';

/// État d'une action qui écrit.
///
/// `docs/UX-FLOWS.md` §11 : les mutations exposent exactement
/// `idle/submitting/success/failure`.
///
/// [MutationSubmitting] est ce qui rend une double soumission impossible :
/// le contrôle refuse les appuis suivants tant qu'il est dans cet état, sans
/// changer de largeur.
sealed class MutationState {
  const MutationState();

  const factory MutationState.idle() = MutationIdle;
  const factory MutationState.submitting() = MutationSubmitting;
  const factory MutationState.success() = MutationSuccess;
  const factory MutationState.failure(WkFailure failure) = MutationFailure;

  bool get isSubmitting => this is MutationSubmitting;

  /// Un contrôle n'accepte un appui que dans ces états. Un échec est
  /// réessayable ; une soumission en cours ne l'est pas.
  bool get acceptsInput => !isSubmitting;

  R map<R>({
    required R Function() idle,
    required R Function() submitting,
    required R Function() success,
    required R Function(WkFailure failure) failure,
  }) {
    return switch (this) {
      MutationIdle() => idle(),
      MutationSubmitting() => submitting(),
      MutationSuccess() => success(),
      MutationFailure(failure: final WkFailure f) => failure(f),
    };
  }
}

final class MutationIdle extends MutationState {
  const MutationIdle();

  @override
  bool operator ==(Object other) => other is MutationIdle;

  @override
  int get hashCode => (MutationIdle).hashCode;
}

final class MutationSubmitting extends MutationState {
  const MutationSubmitting();

  @override
  bool operator ==(Object other) => other is MutationSubmitting;

  @override
  int get hashCode => (MutationSubmitting).hashCode;
}

final class MutationSuccess extends MutationState {
  const MutationSuccess();

  @override
  bool operator ==(Object other) => other is MutationSuccess;

  @override
  int get hashCode => (MutationSuccess).hashCode;
}

final class MutationFailure extends MutationState {
  const MutationFailure(this.failure);

  final WkFailure failure;

  @override
  bool operator ==(Object other) =>
      other is MutationFailure && other.failure == failure;

  @override
  int get hashCode => Object.hash(MutationFailure, failure);
}
