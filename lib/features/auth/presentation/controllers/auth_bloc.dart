import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/services/local/usecases/clear_user_preferences_usecase.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/auth/domain/entities/login_credentials.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Owns the app-wide authentication state (login / logout).
///
/// It works on the [AuthRepository] contract only; any local side effect of
/// logging out (session-level preferences) is delegated to a use case so the
/// bloc never touches [SharedPreferences] or the preferences service directly.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates the bloc with the repository and the logout clean-up use case.
  AuthBloc({
    required this.repository,
    required this.clearUserPreferencesUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Authenticates and persists the session.
  final AuthRepository repository;

  /// Clears SESSION-LEVEL preferences (the "remember me" flag) on logout.
  final ClearUserPreferencesUseCase clearUserPreferencesUseCase;

  /// Authenticates the submitted credentials and exposes the outcome.
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await repository.login(
      LoginCredentials(
        email: event.identifier.trim(),
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(
        AuthAuthenticated(
          userId: session.user.id,
          role: session.user.role.wireValue,
        ),
      ),
    );
  }

  /// Logs the user out: wipes the tokens, then wipes the session preferences.
  ///
  /// Both steps are required. Clearing only the tokens would leave the
  /// "remember me" flag behind, and the next cold start would try to restore a
  /// session that no longer exists. App-level preferences (language, theme)
  /// are intentionally preserved.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();
    await clearUserPreferencesUseCase(const NoParams());
    emit(AuthUnauthenticated());
  }
}
