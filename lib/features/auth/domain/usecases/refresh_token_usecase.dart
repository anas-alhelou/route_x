// lib/features/auth/domain/usecases/refresh_token_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Exchanges a refresh token for a fresh access token and persists the new
/// pair (Single Responsibility Principle).
///
/// The HTTP interceptor performs its own lower-level refresh for seamless
/// request retries; this usecase exists for app-level flows that need the new
/// access token explicitly (e.g. token injection on first launch).
class RefreshTokenUseCase {
  const RefreshTokenUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, String>> call(String refreshToken) {
    if (refreshToken.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('errRefreshTokenRequired')),
      );
    }
    return repository.refreshAccessToken(refreshToken.trim());
  }
}
