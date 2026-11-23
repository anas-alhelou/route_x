// lib/features/auth/domain/usecases/google_sign_in_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/repositories/login_repository.dart';

/// Exchanges an already-obtained Google ID token plus the vehicle details for
/// a session (`POST /auth/google`).
///
/// The token is not requested here: the interactive part of the flow belongs to
/// [GetGoogleIdTokenUseCase], which runs exactly once per attempt. Keeping the
/// two apart is what allows the vehicle step to sit between them without the
/// user being asked to pick a Google account twice.
class GoogleSignInUseCase {
  const GoogleSignInUseCase({required this.repository});

  final LoginRepository repository;

  /// Performs the backend call and returns the persisted session.
  Future<Either<Failure, AuthSessionEntity>> call(GoogleAuthParams params) =>
      repository.googleSignIn(params);
}
