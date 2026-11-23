// lib/features/auth/domain/entities/login_credentials.dart
import 'package:equatable/equatable.dart';

/// Immutable credentials submitted by the user on the login screen.
///
/// Pure Dart entity — no serialization, no UI concerns.
class LoginCredentials extends Equatable {
  const LoginCredentials({required this.email, required this.password});

  /// Email address used to sign in.
  final String email;

  /// Plain-text password submitted by the user.
  final String password;

  @override
  List<Object?> get props => [email, password];
}
