/// Holds the session access token for `real` mode, in memory only.
///
/// No persistence in Phase 1: the app requires normal connectivity anyway
/// (docs/PRODUCT.md §5), so re-authenticating after a process restart is an
/// acceptable simplification — the same trade-off SimulatedAuthService
/// already makes for demo mode. A later phase can back this with secure
/// storage without changing DioAuthInterceptor's contract.
class TokenStore {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void set(String accessToken) => _accessToken = accessToken;

  void clear() => _accessToken = null;
}
