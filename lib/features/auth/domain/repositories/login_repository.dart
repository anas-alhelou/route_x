// lib/features/auth/domain/repositories/login_repository.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/login_credentials.dart';

/// Contract for the login operation.
///
/// Kept as a small, single-purpose interface (Interface Segregation
/// Principle): consumers that only authenticate depend on this â€” not on
/// the wider [AuthRepository] surface.
abstract class LoginRepository {
  /// Authenticates [credentials] and returns a session on success.
  Future<Either<Failure, AuthSessionEntity>> login(
    LoginCredentials credentials,
  );

  /// Authenticates with a Google ID token obtained earlier in the flow.
  ///
  /// [GoogleAuthParams] always carries the vehicle details, so this call can
  /// only ever create or complete an account — there is no "sign in first, ask
  /// about the vehicle later" variant.
  Future<Either<Failure, AuthSessionEntity>> googleSignIn(
    GoogleAuthParams params,
  );
}
