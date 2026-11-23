// lib/features/auth/domain/entities/auth_tokens_entity.dart
import 'package:equatable/equatable.dart';

/// Access + refresh token pair issued by the backend.
class AuthTokensEntity extends Equatable {
  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
