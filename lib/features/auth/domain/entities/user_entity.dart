// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Authenticated user identity. Pure domain entity — no JSON/UI deps.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;

  /// Whether the account has completed OTP verification.
  final bool isActive;

  /// Single display string, derived on demand so the discrete name parts are
  /// never lost.
  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName, email, role, isActive];
}
