// lib/features/auth/domain/usecases/check_remembered_session_usecase.dart
import 'package:dartz/dartz.dart';

import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/services/local/usecases/get_remember_me_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/set_remember_me_usecase.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Decides, on a cold start, whether a previously remembered session can be
/// resumed without showing the login screen.
///
/// The decision combines two independent pieces of local state:
///
///   1. the SESSION-LEVEL "remember me" flag
///      ([GetRememberMeUseCase] / [PreferenceKeys.rememberMe]) — the user's
///      explicit intent, written only after a successful login;
///   2. the tokens actually present in secure storage
///      ([AuthRepository.hasStoredSession]) — proof that the session is still
///      usable.
///
/// Both must be true for the session to be restored. A flag without tokens is
/// stale (the tokens were wiped by a logout, an OS cleanup or a failed
/// refresh), so this use case resets the flag and reports "no session", which
/// makes the app fall back to the login screen on every following launch
/// instead of bouncing between screens.
///
/// No network call is made here: token refresh stays with the existing Dio
/// auth interceptor, which swaps the access token on the first request.
class CheckRememberedSessionUseCase implements UseCase<bool, NoParams> {
  const CheckRememberedSessionUseCase({
    required this.getRememberMeUseCase,
    required this.setRememberMeUseCase,
    required this.repository,
  });

  /// Reads the persisted "remember me" flag.
  final GetRememberMeUseCase getRememberMeUseCase;

  /// Resets the persisted "remember me" flag when it turns out to be stale.
  final SetRememberMeUseCase setRememberMeUseCase;

  /// Verifies that secure storage still holds the session tokens.
  final AuthRepository repository;

  /// Returns `true` only when the flag is set AND the tokens are still on the
  /// device; `false` in every other case, with the flag left in a consistent
  /// state (either untouched or explicitly reset to `false`).
  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    // 1. No intent, no session. This is the default for a fresh install and
    //    after a logout, so the login screen is shown.
    final rememberMe = await getRememberMeUseCase(const NoParams());
    if (!rememberMe.getOrElse(() => false)) {
      return const Right(false);
    }

    // 2. Intent confirmed — the tokens must still be there to honour it.
    final hasTokens = await repository.hasStoredSession();
    if (hasTokens.getOrElse(() => false)) {
      return const Right(true);
    }

    // 3. Stale flag (e.g. tokens deleted by the OS keychain or a failed
    //    refresh). Clear it so the next cold start takes the same path.
    await setRememberMeUseCase(const SetRememberMeParams(value: false));
    return const Right(false);
  }
}
