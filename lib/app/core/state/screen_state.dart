/// Cause d'un échec, indépendante de toute langue.
///
/// Un état d'erreur ne transporte **jamais** de message : il transporte un
/// code, et l'écran le traduit via `context.l10n`. Sinon la règle « aucune
/// chaîne visible en dur » se contourne en écrivant le texte dans la couche
/// métier.
enum WkFailure {
  /// La base locale est indisponible ou corrompue.
  localStorage,

  /// Le jeu de données de démonstration est invalide.
  seed,

  /// Une permission nécessaire a été refusée.
  permission,

  /// Une donnée demandée par un lien profond n'existe pas.
  notFound,

  /// Cause non identifiée. À n'utiliser que faute de mieux.
  unknown,
}

/// État d'un écran asynchrone.
///
/// `docs/UX-FLOWS.md` §11 : tout écran asynchrone expose exactement ces cinq
/// états. Un écran ne déduit jamais un chargement d'un `data == null`, ce que
/// ce type rend structurellement impossible.
sealed class ScreenState<T> {
  const ScreenState();

  const factory ScreenState.initial() = ScreenInitial<T>;
  const factory ScreenState.loading() = ScreenLoading<T>;
  const factory ScreenState.data(T value) = ScreenData<T>;
  const factory ScreenState.empty() = ScreenEmpty<T>;
  const factory ScreenState.error(WkFailure failure) = ScreenError<T>;

  /// Valeur portée, ou `null` hors de l'état `data`.
  T? get valueOrNull => switch (this) {
    ScreenData<T>(:final T value) => value,
    _ => null,
  };

  bool get isLoading => this is ScreenLoading<T>;

  /// Vrai dès qu'un résultat définitif est connu, vide compris.
  bool get isResolved => switch (this) {
    ScreenData<T>() || ScreenEmpty<T>() || ScreenError<T>() => true,
    _ => false,
  };

  R map<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T value) data,
    required R Function() empty,
    required R Function(WkFailure failure) error,
  }) {
    return switch (this) {
      ScreenInitial<T>() => initial(),
      ScreenLoading<T>() => loading(),
      ScreenData<T>(value: final T v) => data(v),
      ScreenEmpty<T>() => empty(),
      ScreenError<T>(failure: final WkFailure f) => error(f),
    };
  }
}

final class ScreenInitial<T> extends ScreenState<T> {
  const ScreenInitial();

  @override
  bool operator ==(Object other) => other is ScreenInitial<T>;

  @override
  int get hashCode => (ScreenInitial<T>).hashCode;
}

final class ScreenLoading<T> extends ScreenState<T> {
  const ScreenLoading();

  @override
  bool operator ==(Object other) => other is ScreenLoading<T>;

  @override
  int get hashCode => (ScreenLoading<T>).hashCode;
}

final class ScreenData<T> extends ScreenState<T> {
  const ScreenData(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is ScreenData<T> && other.value == value;

  @override
  int get hashCode => Object.hash(ScreenData<T>, value);
}

final class ScreenEmpty<T> extends ScreenState<T> {
  const ScreenEmpty();

  @override
  bool operator ==(Object other) => other is ScreenEmpty<T>;

  @override
  int get hashCode => (ScreenEmpty<T>).hashCode;
}

final class ScreenError<T> extends ScreenState<T> {
  const ScreenError(this.failure);

  final WkFailure failure;

  @override
  bool operator ==(Object other) =>
      other is ScreenError<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(ScreenError<T>, failure);
}
