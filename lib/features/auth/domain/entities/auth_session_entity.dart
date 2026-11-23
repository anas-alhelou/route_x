// lib/features/auth/domain/entities/auth_session_entity.dart
import 'package:equatable/equatable.dart';

import 'auth_tokens_entity.dart';
import 'user_entity.dart';

/// The full authenticated session returned by login / OTP-verify / google.
class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({required this.user, required this.tokens});

  final UserEntity user;
  final AuthTokensEntity tokens;

  @override
  List<Object?> get props => [user, tokens];
}
