// lib/features/auth/data/models/user_model.dart
import 'package:routex_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';

/// Data-layer representation of the authenticated user returned by the API.
///
/// The backend sends the name as two discrete fields (`firstName`,
/// `lastName`), so they are kept separate here rather than collapsed into a
/// single string; [fullName] is derived for the few UI surfaces that only need
/// one display value.
class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;

  /// `false` until the account completes OTP verification; `/auth/register`
  /// always returns an inactive user.
  final bool isActive;

  /// Single display string (e.g. for a profile header or initials).
  String get fullName => '$firstName $lastName'.trim();

  /// Parses a user object exactly as the API sends it:
  /// `{ id, firstName, lastName, email, role, isActive }`.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromWire(json['role'] as String?),
      isActive: json['isActive'] == true,
    );
  }

  /// Converts into the domain [UserEntity].
  UserEntity toEntity() => UserEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    role: role,
    isActive: isActive,
  );
}
