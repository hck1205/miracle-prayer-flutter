import "auth_models.dart";

class AuthState {
  const AuthState({
    required this.session,
    required this.isBusy,
    required this.errorMessage,
  });

  const AuthState.initial()
    : session = null,
      isBusy = true,
      errorMessage = null;

  final AuthSession? session;
  final bool isBusy;
  final String? errorMessage;

  bool get isAuthenticated => session != null;

  AuthState withBusy(bool nextBusy) {
    return AuthState(
      session: session,
      isBusy: nextBusy,
      errorMessage: errorMessage,
    );
  }

  AuthState withError(String? nextError) {
    return AuthState(
      session: session,
      isBusy: isBusy,
      errorMessage: nextError,
    );
  }

  AuthState withSession(AuthSession? nextSession) {
    return AuthState(
      session: nextSession,
      isBusy: isBusy,
      errorMessage: errorMessage,
    );
  }

  AuthState clearError() => withError(null);
}
