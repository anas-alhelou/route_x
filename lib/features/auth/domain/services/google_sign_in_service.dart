// lib/features/auth/domain/services/google_sign_in_service.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/core/errors/failures.dart';

/// Outcome of a Google Sign-In attempt.
///
/// A cancelled attempt is modelled as its own state rather than a [Failure]:
/// dismissing the account chooser is a decision, not an error, and the UI must
/// return to idle without showing a message.
class GoogleAuthResult extends Equatable {
  const GoogleAuthResult._(
    this.idToken,
    this.failure, {
    this.displayName,
    this.email,
  });

  /// The SDK returned a usable ID token.
  const GoogleAuthResult.success(
    String token, {
    String? displayName,
    String? email,
  }) : this._(token, null, displayName: displayName, email: email);

  /// The user dismissed the chooser, or the flow was interrupted.
  const GoogleAuthResult.cancelled() : this._(null, null);

  /// The SDK (or its configuration) failed.
  const GoogleAuthResult.failure(Failure error) : this._(null, error);

  /// Non-null only when the sign-in succeeded.
  final String? idToken;

  /// Non-null only when the sign-in failed.
  final Failure? failure;

  /// Display name from the Google account, when available.
  final String? displayName;

  /// Email from the Google account, when available.
  final String? email;

  /// Whether the user simply declined to sign in.
  bool get isCancelled => idToken == null && failure == null;

  @override
  List<Object?> get props => [idToken, failure, displayName, email];
}

/// Boundary around the native Google Sign-In SDK.
///
/// Declared in the domain layer so no `google_sign_in` type ever reaches the
/// presentation layer: the UI only ever sees [GoogleAuthResult].
abstract class GoogleSignInService {
  /// Runs the interactive sign-in flow and reports the outcome.
  Future<GoogleAuthResult> signIn();

  /// Disconnects the signed-in Google account from this device.
  Future<void> signOut();
}
