// lib/features/auth/data/models/auth_response_model.dart
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:routex_mobile/core/errors/exceptions.dart';
import 'package:routex_mobile/core/network/jwt_payload.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';

import 'user_model.dart';

/// Parsed success response for the auth endpoints that return a session
/// (`/auth/login`, `/auth/verify-otp`, `/auth/google`, `/auth/refresh`):
///
/// ```json
/// { "success": true,
///   "data": { "message": "...",
///             "user": { "id": "...", "firstName": "...", ... },
///             "tokens": { "accessToken": "...", "refreshToken": "..." } },
///   "timestamp": "..." }
/// ```
///
/// `user` and the token pair are both part of the contract. Every consumer
/// needs the user to identify the account and to persist the session (`userId`
/// + `role`), so a response missing either one is a contract violation, not a
/// variant to tolerate silently.
///
/// `POST /auth/verify-otp` is the exception to the *placement* of the tokens,
/// not to their presence: it answers with them flat in `data`, beside `user`
/// and a `resetToken`:
///
/// ```json
/// { "success": true,
///   "data": { "message": "Account activated successfully.",
///             "user": { "id": "...", ... },
///             "resetToken": "...",
///             "accessToken": "...", "refreshToken": "..." },
///   "timestamp": "..." }
/// ```
///
/// [_parse] accepts either placement, so every endpoint above is handled by the
/// same code.
///
/// The other documented exception is [fromLoginJson], for `POST /auth/login`,
/// which is verified against the live backend to return *only* `message` and
/// `tokens` — no `user` at all. See that constructor for how the identity is
/// recovered there.
///
/// Both constructors expect the *unwrapped* `data` object (see `ApiEnvelope`).
class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserModel user;
  final String accessToken;
  final String refreshToken;

  /// Parses the `data` object of an auth response that includes a `user`.
  ///
  /// Used by `/auth/verify-otp`, `/auth/google` and `/auth/refresh`. A missing
  /// piece throws [IncompleteAuthResponseException] (a [FormatException]) rather
  /// than producing a half-built model, so a contract change fails loudly
  /// instead of yielding an empty session. The exception keeps the offending
  /// payload for the developer logs; the user only ever sees the safe message
  /// `ExceptionMapper` derives from it.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _parse(json, allowIdentityFromToken: false);

  /// Parses the `data` object of a `POST /auth/login` response.
  ///
  /// `/auth/login` is the one endpoint whose success payload has been confirmed
  /// against the live backend to carry no `user`:
  ///
  /// ```json
  /// { "message": "Login successful.",
  ///   "tokens": { "accessToken": "<jwt>", "refreshToken": "<jwt>" } }
  /// ```
  ///
  /// The identity is therefore read from the access token's claims, which carry
  /// the same account id and role:
  ///
  /// ```json
  /// { "sub": "5b84abbf-...", "email": "anas.sh.alhilo@gmail.com",
  ///   "role": "DRIVER", "iat": 1767225600, "exp": 1767229200 }
  /// ```
  ///
  /// A `user` object, if one ever does appear, still wins — this is a fallback,
  /// not a replacement.
  ///
  /// `firstName`/`lastName` are not in the token and have no other source at
  /// login time, so they stay empty; `isActive` is `true` because the backend
  /// only issues a successful login for an active, verified account. A profile
  /// fetch is what fills the names in later.
  ///
  /// If the token cannot be decoded, or carries no `sub`, the response is
  /// genuinely broken: it throws a plain [FormatException], which
  /// `ExceptionMapper` reports through the generic-error path rather than
  /// signing in an unidentified account.
  factory AuthResponseModel.fromLoginJson(Map<String, dynamic> json) =>
      _parse(json, allowIdentityFromToken: true);

  /// Tolerant parser for `POST /auth/verify-otp`, whose *acceptance* is the
  /// only thing that matters.
  ///
  /// A 2xx from this endpoint means "the code was correct and the account is
  /// now active". The real body does also carry the session — flat
  /// `data.accessToken` / `data.refreshToken` next to `data.user`, which
  /// [_parse] reads — so a correct code yields a usable, persistable session.
  ///
  /// What remains tolerant is *presence*: should the backend ever answer 2xx
  /// with no tokens at all, that is still an accepted code. A missing `user`
  /// never throws here (identity is irrelevant to verification) and
  /// [hasSession] reports whether tokens were present, so the caller skips
  /// persisting anything rather than writing empty credentials that would later
  /// look like a signed-in session — see [AuthRepositoryImpl.verifyOtp].
  factory AuthResponseModel.fromVerifyOtpJson(Map<String, dynamic> json) {
    _logShape(json);
    try {
      return _parse(json, allowIdentityFromToken: true);
    } on IncompleteAuthResponseException {
      // No tokens in the body. The account is verified either way; the caller
      // decides what to do with a session-less success, and this placeholder
      // identity is never persisted because [hasSession] is false.
      return const AuthResponseModel(
        user: UserModel(
          id: '',
          firstName: '',
          lastName: '',
          email: '',
          role: UserRole.driver,
          isActive: true,
        ),
        accessToken: '',
        refreshToken: '',
      );
    }
  }

  /// Shared parser. [allowIdentityFromToken] selects [fromLoginJson]'s
  /// token-derived identity fallback; when false, a missing `user` throws.
  static AuthResponseModel _parse(
    Map<String, dynamic> json, {
    required bool allowIdentityFromToken,
  }) {
    // Two documented shapes for the very same field pair:
    //   `/auth/login`, `/auth/google`, `/auth/refresh`
    //     -> `data.tokens.{accessToken,refreshToken}`
    //   `/auth/verify-otp`
    //     -> `data.accessToken` / `data.refreshToken`, flat next to `user`
    // Reading only one of them is what made a correct OTP code end in
    // "Invalid or expired verification code": the verify-otp body was parsed
    // with the nested-only rule, the missing nested object threw, and the
    // resulting placeholder was treated as a token-less success. Each field is
    // therefore resolved independently, nested first, so either shape works.
    final nestedTokens = json['tokens'];
    final accessToken =
        _readToken(nestedTokens, 'accessToken') ??
        _readToken(json, 'accessToken');
    if (accessToken == null) {
      throw IncompleteAuthResponseException(
        'Missing tokens (expected `tokens.accessToken` or a flat '
        '`accessToken`) in the auth response: ${_describeShape(json)}',
      );
    }

    final refreshToken =
        _readToken(nestedTokens, 'refreshToken') ??
        _readToken(json, 'refreshToken');

    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      return AuthResponseModel(
        user: UserModel.fromJson(userJson),
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );
    }

    if (allowIdentityFromToken) {
      final user = _userFromAccessToken(accessToken);
      if (user != null) {
        return AuthResponseModel(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
        );
      }
      throw FormatException(
        'Could not derive the user from the auth response access token: '
        '${_describeShape(json)}',
      );
    }

    throw IncompleteAuthResponseException(
      'Missing `user` in the auth response: ${_describeShape(json)}',
    );
  }

  /// Describes [json] by its field names and types only, for error messages.
  ///
  /// These exceptions travel through [ExceptionMapper], which puts their message
  /// in front of the user, so interpolating the body would print the very tokens
  /// this parser is guarding. Only keys and whether a value was present are
  /// reported.
  static String _describeShape(Map<String, dynamic> json) {
    final fields = json.entries
        .map((entry) => '${entry.key}: ${entry.value.runtimeType}')
        .join(', ');
    return fields.isEmpty ? '<empty object>' : '{$fields}';
  }

  /// Reads [key] from [source] as a non-empty token, or `null` when it is
  /// absent, of the wrong type, or blank.
  ///
  /// Used for both token shapes (nested and flat); a blank string is treated as
  /// absent so an empty field never counts as a usable session.
  static String? _readToken(Object? source, String key) {
    if (source is! Map) return null;
    final value = source[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Debug-only breadcrumb for the shape of a `/auth/verify-otp` success body.
  ///
  /// Prints the *keys* of the unwrapped `data` object and whether the fields
  /// this parser depends on are present. Values are never logged, so an access
  /// or refresh token cannot end up in the device logs; the line exists so a
  /// correct code that still reached the UI as an error can be traced back to
  /// the actual response shape.
  static void _logShape(Map<String, dynamic> json) {
    if (!kDebugMode) return;
    developer.log(
      'verify-otp data keys: ${json.keys.join(', ')} '
      '(hasUser: ${json['user'] != null}, '
      'hasNestedTokens: ${json['tokens'] != null}, '
      'hasFlatAccessToken: ${_readToken(json, 'accessToken') != null})',
      name: 'AuthResponseModel.verifyOtp',
    );
  }

  /// Builds the [UserModel] carried by the access token's claims, or `null` when
  /// the token is not a decodable JWT or has no usable `sub`.
  static UserModel? _userFromAccessToken(String accessToken) {
    final claims = const JwtPayloadDecoder().decode(accessToken);
    if (claims == null) return null;

    final subject = claims['sub'];
    if (subject is! String || subject.isEmpty) return null;

    return UserModel(
      id: subject,
      firstName: '',
      lastName: '',
      email: claims['email'] is String ? claims['email'] as String : '',
      role: UserRole.fromWire(claims['role'] as String?),
      isActive: true,
    );
  }

  /// Whether this response carries a usable session.
  ///
  /// False for a verified-but-token-less body (see [fromVerifyOtpJson]); the
  /// caller must then skip persisting anything rather than writing empty
  /// credentials that would look like a signed-in session later.
  bool get hasSession => accessToken.isNotEmpty;

  /// Bundles the parsed user and tokens into the domain [AuthSessionEntity].
  AuthSessionEntity toEntity() => AuthSessionEntity(
    user: user.toEntity(),
    tokens: AuthTokensEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
    ),
  );
}
