// lib/features/settings/domain/entities/profile_update_exception.dart

/// Profile fields the backend can reject individually.
enum ProfileField { firstName, lastName, email, phone }

/// Thrown when a profile update is refused.
///
/// [fieldErrors] maps each rejected field to an l10n **key** (e.g.
/// `errEmailTaken`), so the edit screen can mark that field and summarize the
/// problem. [message] carries anything that is not tied to a single field.
class ProfileUpdateException implements Exception {
  const ProfileUpdateException({this.fieldErrors = const {}, this.message});

  final Map<ProfileField, String> fieldErrors;
  final String? message;

  @override
  String toString() => 'ProfileUpdateException($fieldErrors, $message)';
}
