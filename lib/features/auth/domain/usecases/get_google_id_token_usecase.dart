// lib/features/auth/domain/usecases/get_google_id_token_usecase.dart
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';

/// Outcome of asking Google for an identity token.
///
/// Modelled as its own type rather than a bare `Either` so callers can tell
/// "the user backed out" from "Google refused" without matching on a Failure
/// subclass, and so the token is the only thing a successful result exposes.
class GoogleIdTokenResult {
  const GoogleIdTokenResult._(this.idToken, this.failure);

  /// The SDK returned a usable ID token.
  const GoogleIdTokenResult.success(String idToken) : this._(idToken, null);

  /// The user dismissed the chooser, or the flow was interrupted.
  const GoogleIdTokenResult.cancelled() : this._(null, null);

  /// The SDK — or its configuration — failed.
  const GoogleIdTokenResult.failure(Failure failure) : this._(null, failure);

  /// Non-null only when the SDK produced a token.
  final String? idToken;

  /// Non-null only when the attempt failed.
  final Failure? failure;

  /// Whether the user simply declined to sign in.
  bool get isCancelled => idToken == null && failure == null;
}

/// Runs the Google SDK once and hands back only the ID token.
///
/// Split out of the authentication use case so a single interactive attempt can
/// be composed as "get a token, collect the vehicle, then call the backend".
/// The SDK is the only part of that sequence that must not be repeated, and this
/// is the only piece that touches it — the token travels from here to the
/// bloc/cubit and straight into the request body, never being stored, logged or
/// passed through a route.
class GetGoogleIdTokenUseCase {
  const GetGoogleIdTokenUseCase({required this.service});

  /// The domain boundary around the native `google_sign_in` SDK.
  final GoogleSignInService service;

  /// Performs the interactive chooser and reports the outcome.
  Future<GoogleIdTokenResult> call() async {
    final result = await service.signIn();

    final failure = result.failure;
    if (failure != null) return GoogleIdTokenResult.failure(failure);

    final token = result.idToken;
    if (token == null || token.isEmpty) {
      return const GoogleIdTokenResult.cancelled();
    }

    return GoogleIdTokenResult.success(token);
  }
}
