// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:routex_mobile/core/config/constants/api_endpoints.dart';
import 'package:routex_mobile/core/network/api_envelope.dart';
import 'package:routex_mobile/core/network/dio_client.dart';
import 'package:routex_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:routex_mobile/features/auth/data/models/forgot_password_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/login_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/refresh_token_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/register_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/register_response_model.dart';
import 'package:routex_mobile/features/auth/data/models/reset_password_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/verify_otp_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/verify_reset_otp_response_model.dart';

/// Contract for the auth endpoints (single responsibility: call the endpoint
/// and parse its JSON).
///
/// All HTTP errors propagate outward as [DioException]s — the repository layer
/// maps them to [Failure]s, so implementations stay free of domain concerns.
///
/// TODO(auth): `/auth/me` (current user) and [ApiEndpoints.orders] are not
/// implemented yet — there is no data source method, model, repository or route
/// for either, and nothing is partially wired to them. When they are needed
/// they must go through [_post] so the response envelope is unwrapped the same
/// way (see [ApiEnvelope]); a `me()` returning a bare user and an orders data
/// source returning a paged list are the natural shapes.
abstract class AuthRemoteDataSource {
  /// Registers a new account via `POST /auth/register`.
  ///
  /// Returns a [RegisterResponseModel] (message + inactive user, no tokens).
  Future<RegisterResponseModel> register(RegisterRequestModel request);

  /// Verifies an emailed OTP via `POST /auth/verify-otp`.
  ///
  /// Parsed with [AuthResponseModel.fromVerifyOtpJson]: a 2xx here only means
  /// "the code was correct", so neither a `user` object nor tokens are required
  /// for the call to be treated as a success.
  Future<AuthResponseModel> verifyOtp(VerifyOtpRequestModel request);

  /// Verifies a forgot-password OTP and returns its reset-token response.
  Future<VerifyResetOtpResponseModel> verifyResetOtp(
    VerifyOtpRequestModel request,
  );

  /// Authenticates with email + password via `POST /auth/login`.
  ///
  /// The only endpoint confirmed to answer without a `user`, so it is the only
  /// one parsed with [AuthResponseModel.fromLoginJson].
  Future<AuthResponseModel> login(LoginRequestModel request);

  /// Authenticates / registers through Google via `POST /auth/google`.
  ///
  /// Requires a `user` like [verifyOtp] — Google sign-in is where a brand-new
  /// account is created, so the name the user typed must come from the response.
  Future<AuthResponseModel> googleAuth(GoogleAuthRequestModel request);

  /// Requests a password-reset token via `POST /auth/forgot-password`.
  Future<void> forgotPassword(ForgotPasswordRequestModel request);

  /// Applies a new password via `POST /auth/reset-password`.
  Future<void> resetPassword(ResetPasswordRequestModel request);

  /// Exchanges a refresh token for a new token pair via `POST /auth/refresh`.
  ///
  /// Parsed with [AuthResponseModel.fromJson]; see [login] for the reasoning
  /// behind not deriving identity from the token.
  Future<AuthResponseModel> refresh(RefreshTokenRequestModel request);
}

/// Dio-backed implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio, {Future<String?> Function()? fcmToken})
    : _fcmToken = fcmToken;

  /// Supplies the push token sent with a login. Optional: without it (or when
  /// Firebase is unavailable) the login is sent without `fcmToken`.
  final Future<String?> Function()? _fcmToken;

  final Dio _dio;

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) => _post(
    ApiEndpoints.register,
    request.toJson(),
    RegisterResponseModel.fromJson,
  );

  @override
  Future<AuthResponseModel> verifyOtp(VerifyOtpRequestModel request) => _post(
    ApiEndpoints.verifyOtp,
    request.toJson(),
    AuthResponseModel.fromVerifyOtpJson,
  );

  @override
  Future<VerifyResetOtpResponseModel> verifyResetOtp(
    VerifyOtpRequestModel request,
  ) => _post(
    ApiEndpoints.verifyResetOtp,
    request.toJson(),
    VerifyResetOtpResponseModel.fromJson,
    options: Options(extra: {DioClient.skipAuthFlag: true}),
  );

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) {
    // Credential-exchange endpoint: must never carry a bearer token from a
    // previous session, and must never trigger a /auth/refresh cycle on a 401
    // (which would wipe the existing valid session as a side-effect).
    final opts = Options(extra: {DioClient.skipAuthFlag: true});
    if (kDebugMode) {
      developer.log(
        'POST ${ApiEndpoints.login}: skipAuth=true, '
        'fields: ${request.toJson().keys.where((k) => k != 'password').join(', ')}',
        name: 'AuthDataSource',
      );
    }
    return _loginWithToken(request, opts);
  }

  Future<AuthResponseModel> _loginWithToken(
    LoginRequestModel request,
    Options opts,
  ) async {
    String? token;
    try {
      token = await _fcmToken?.call().timeout(const Duration(seconds: 3));
    } catch (_) {
      token = null;
    }
    final body = <String, dynamic>{
      ...request.toJson(),
      if (token != null && token.isNotEmpty) 'fcmToken': token,
    };
    return _post(ApiEndpoints.login, body, AuthResponseModel.fromLoginJson, options: opts);
  }

  @override
  Future<AuthResponseModel> googleAuth(GoogleAuthRequestModel request) {
    // Same reasoning as login: this is a credential-exchange endpoint. A stale
    // bearer token from a previous Google session would cause the backend to
    // reject the request (401/500), the interceptor would then try to refresh
    // and — if that fails — wipe storage, destroying the existing session.
    final opts = Options(extra: {DioClient.skipAuthFlag: true});
    final sentFields = request.toJson().keys.where((k) => k != 'idToken').toList();
    if (kDebugMode) {
      developer.log(
        'POST ${ApiEndpoints.googleAuth}: skipAuth=true, '
        'hasIdToken=true, otherFields: ${sentFields.join(', ')}',
        name: 'AuthDataSource',
      );
    }
    return _post(ApiEndpoints.googleAuth, request.toJson(), AuthResponseModel.fromJson, options: opts);
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequestModel request) => _postVoid(
    ApiEndpoints.forgotPassword,
    request.toJson(),
    options: Options(extra: {DioClient.skipAuthFlag: true}),
  );

  @override
  Future<void> resetPassword(ResetPasswordRequestModel request) => _postVoid(
    ApiEndpoints.resetPassword,
    request.toJson(),
    options: Options(extra: {DioClient.skipAuthFlag: true}),
  );

  @override
  Future<AuthResponseModel> refresh(RefreshTokenRequestModel request) => _post(
    ApiEndpoints.refreshToken,
    request.toJson(),
    AuthResponseModel.fromJson,
  );

  /// POSTs [body] and parses the envelope's `data` object with [parse].
  ///
  /// The raw body is `{ success, data, timestamp }`, so models must be fed
  /// `body['data']` — handing them the envelope makes every lookup null.
  /// A malformed envelope throws a [FormatException] instead of silently
  /// producing empty models.
  Future<T> _post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> data) parse, {
    Options? options,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: body,
      options: options,
    );
    return parse(ApiEnvelope.unwrapData(response.data, path: path));
  }

  /// Void endpoints (forgot/reset password) may return an empty body â€” nothing
  /// is parsed, only the transport status matters.
  Future<void> _postVoid(
    String path,
    Map<String, dynamic> body, {
    Options? options,
  }) async {
    await _dio.post<dynamic>(path, data: body, options: options);
  }
}
