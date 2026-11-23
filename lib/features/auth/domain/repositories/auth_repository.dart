// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/login_credentials.dart';
import 'package:routex_mobile/features/auth/domain/entities/register_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/signup_credentials.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';

/// Abstract definition of Auth data operations, to be implemented by the Data
/// layer.
///
/// Only the two credential-cache methods touch local state; everything else is
/// a real backend call. The interface is kept narrow (Interface Segregation)
/// and is satisfied by a single data-layer implementation that also satisfies
/// [LoginRepository] (Liskov Substitution).
abstract class AuthRepository {
  /// Caches the current state of registration credentials in-memory
  /// before the final submission.
  Future<Either<Failure, void>> cacheSignupCredentials(
    SignupCredentials credentials,
  );

  /// Retrieves the currently cached registration credentials, if any.
  Future<Either<Failure, SignupCredentials>> getCachedSignupCredentials();

  /// Local check — reports whether this device still holds a usable session.
  ///
  /// Reads the secure storage only (no network call) so the cold-start flow can
  /// decide whether a remembered session can be restored without showing the
  /// login screen. An access token is deliberately not required: it expires
  /// within minutes, while a non-empty refresh token is exactly what the Dio
  /// interceptor needs to mint a fresh access token on the first request.
  Future<Either<Failure, bool>> hasStoredSession();

  // â”€â”€ Backend-backed operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// POST /auth/register â€” creates the account. No tokens are issued here;
  /// the account becomes active once the OTP is verified.
  Future<Either<Failure, void>> register(RegisterParams params);

  /// POST /auth/verify-otp — activates the account.
  ///
  /// Success is the HTTP status, not the payload: a 2xx means the code was
  /// correct, and the returned session may legitimately be empty because the
  /// backend did not issue tokens in that response. Consumers must therefore
  /// treat a right-hand result as "account verified" and not assume a usable
  /// session was persisted.
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String email,
    required String otp,
  });

  /// POST /auth/verify-otp for forgot-password; returns only the reset token.
  Future<Either<Failure, String>> verifyResetOtp({
    required String email,
    required String otp,
  });

  /// POST /auth/login â€” exchanges credentials for a session.
  Future<Either<Failure, AuthSessionEntity>> login(
    LoginCredentials credentials,
  );

  /// POST /auth/google â€” authenticates with an already-obtained Google ID
  /// token plus the vehicle details collected in the UI beforehand.
  Future<Either<Failure, AuthSessionEntity>> googleSignIn(
    GoogleAuthParams params,
  );

  /// POST /auth/forgot-password â€” requests a reset code/token for [email].
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// POST /auth/reset-password â€” sets [newPassword] using the reset token.
  Future<Either<Failure, void>> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// POST /auth/refresh â€” exchanges a refresh token for a new access token
  /// and persists the new pair. Returns the fresh access token.
  Future<Either<Failure, String>> refreshAccessToken(String refreshToken);

  /// Local logout â€” wipes the persisted session. (A server-side revoke
  /// endpoint hasn't been confirmed yet; logout is purely local for now.)
  Future<Either<Failure, void>> logout();
}
