// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:routex_mobile/core/session/local_session_cleaner.dart';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';
import 'package:routex_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:routex_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:routex_mobile/features/auth/data/models/forgot_password_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/login_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/refresh_token_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/register_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/reset_password_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/verify_otp_request_model.dart';
import 'package:routex_mobile/features/auth/domain/entities/auth_session_entity.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/login_credentials.dart';
import 'package:routex_mobile/features/auth/domain/entities/register_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/signup_credentials.dart';
import 'package:routex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:routex_mobile/features/auth/domain/repositories/login_repository.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';

/// Implementation of [AuthRepository] and [LoginRepository].
///
/// Satisfies both contracts (Liskov Substitution Principle): anywhere a
/// [LoginRepository] or [AuthRepository] is requested, this instance works.
///
/// Responsibilities (Single Responsibility): coordinate the remote data source
/// + secure token storage, and translate every thrown exception into a
/// [Failure] via [ExceptionMapper] â€” no [DioException] ever leaves this layer.
class AuthRepositoryImpl implements AuthRepository, LoginRepository {
  AuthRepositoryImpl(
    this._remote,
    this._storage, {
    this.googleSignInService,
    ExceptionMapper exceptionMapper = const ExceptionMapper(),
  }) : _exceptionMapper = exceptionMapper;

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;
  final GoogleSignInService? googleSignInService;
  final ExceptionMapper _exceptionMapper;

  /// In-memory cache holding the registration state across signup steps
  /// (the bloc + the summary screen share it as the source of truth).
  SignupCredentials? _inMemoryRegistration;

  // â”€â”€ Existing local cache contract (unchanged) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Future<Either<Failure, void>> cacheSignupCredentials(
    SignupCredentials credentials,
  ) async {
    try {
      _inMemoryRegistration = credentials;
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SignupCredentials>>
  getCachedSignupCredentials() async {
    if (_inMemoryRegistration != null) {
      return Right(_inMemoryRegistration!);
    } else {
      return const Left(CacheFailure('No cached credentials found'));
    }
  }

  /// Reports whether secure storage still holds a refresh token.
  ///
  /// Only the refresh token is inspected: it is the long-lived credential the
  /// Dio interceptor exchanges for a new access token, so its presence means
  /// the session can be resumed without a network round-trip at startup.
  @override
  Future<Either<Failure, bool>> hasStoredSession() => _guard(() async {
    final refreshToken = await _storage.readRefreshToken();
    return (refreshToken ?? '').trim().isNotEmpty;
  });

  // â”€â”€ Backend-backed operations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Future<Either<Failure, void>> register(RegisterParams params) =>
      _guardVoid(() async {
        // Register never returns tokens: the account stays inactive until the
        // emailed OTP is verified (see RegisterResponseModel).
        final response = await _remote.register(
          RegisterRequestModel(
            firstName: params.firstName,
            lastName: params.lastName,
            country: params.country,
            email: params.email,
            password: params.password,
            phone: params.phone,
            role: params.role.wireValue,
          ),
        );
        if (response.user.id.isEmpty) {
          throw const FormatException('Register response has no user id');
        }
      });

  /// Verifies an emailed OTP; success is decided by the HTTP status, not by the
  /// presence of tokens.
  ///
  /// A 2xx means the code was correct and the account is now active, so a
  /// body without `tokens` is still a success: the account is verified and the
  /// flow moves on without a session. Persisting anything in that case would
  /// write empty credentials that later look like a usable session. When tokens
  /// *are* present the session is persisted exactly as before.
  @override
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String email,
    required String otp,
  }) => _guard(() async {
    final response = await _remote
        .verifyOtp(VerifyOtpRequestModel(email: email, otp: otp))
        .onError<Object>((error, stackTrace) {
          // A rejected code must be visible in the device logs with the status the
          // backend *meant* to send: some routes wrap a 400 inside a 500 envelope,
          // and without the unwrapped status it is impossible to tell a wrong code
          // from a transport or server fault. Token values are never logged.
          ExceptionMapper.logRejection(error, label: 'POST /auth/verify-otp');
          throw error;
        });
    if (!response.hasSession) {
      _logVerifyOtp(
        '2xx without tokens: the account is verified, no session persisted',
      );
      return response.toEntity();
    }
    await _persistSession(response);
    return response.toEntity();
  });

  /// Debug-only breadcrumb for a successful-but-noteworthy
  /// `POST /auth/verify-otp` outcome.
  ///
  /// Records only whether the body carried tokens, never their values.
  void _logVerifyOtp(String reason) {
    if (!kDebugMode) return;
    developer.log(
      'POST /auth/verify-otp: $reason',
      name: 'AuthRepository.verifyOtp',
    );
  }

  /// Verifies a reset OTP without persisting the returned auth credentials.
  @override
  Future<Either<Failure, String>> verifyResetOtp({
    required String email,
    required String otp,
  }) => _guard(() async {
    final response = await _remote.verifyResetOtp(
      VerifyOtpRequestModel(email: email, otp: otp),
    );
    return response.resetToken;
  });

  @override
  Future<Either<Failure, AuthSessionEntity>> login(
    LoginCredentials credentials,
  ) => _guard(() async {
    final response = await _remote.login(
      LoginRequestModel(
        email: credentials.email,
        password: credentials.password,
      ),
    );
    await _persistSession(response);
    return response.toEntity();
  });

  /// `POST /auth/google` with the token the SDK already produced, plus the
  /// vehicle details when this attempt carries them.
  ///
  /// The call is made twice at most. The first attempt sends only the identity
  /// (token, platform, push token): an account that already registered with
  /// Google answers with a session right there, while a brand-new one is
  /// answered with the vehicle-required signal that [_googleFailureMapper]
  /// turns into [GoogleVehicleRequiredFailure]. Only that second attempt — the
  /// one that registers the new identity — puts [GoogleAuthParams.vehicleType]
  /// and [GoogleAuthParams.vehicleNumber] in the body, so an existing user's
  /// stored vehicle is never re-sent and can never be overwritten. Any other
  /// refusal keeps the app-wide mapping and is surfaced verbatim to the user
  /// and to the developer log by [_googleFailureMapper] / [_logGoogleRejection].
  ///
  /// The Google SDK is **not** touched here: [GetGoogleIdTokenUseCase] owns the
  /// single interactive call, so this method is a pure backend exchange and can
  /// be retried (for example after a failed vehicle submission) without ever
  /// showing the account chooser again.
  @override
  Future<Either<Failure, AuthSessionEntity>> googleSignIn(
    GoogleAuthParams params,
  ) async {
    final token = params.idToken.trim();
    if (token.isEmpty) {
      // Unreachable through the UI (the token only exists once the SDK returned
      // one), but guarded so a caller cannot fire a request that is certain to
      // be rejected and turn that into a confusing "invalid token" message.
      return const Left(GoogleAuthCancelledFailure());
    }

    return _guard(() async {
      final request = GoogleAuthRequestModel(
        idToken: token,
        platform: params.platform,
        fcmToken: params.fcmToken,
        vehicleType: params.vehicleType?.wireValue,
        vehicleNumber: params.vehicleNumber,
      );
      final response = await _remote.googleAuth(request).onError<Object>((
        error,
        stackTrace,
      ) {
        // A rejected `/auth/google` is the one auth call whose failure modes
        // are not documented, so its status, the server's own message and the
        // exact set of fields this request carried are surfaced to the
        // developer log. Re-thrown unchanged: `_guard` still owns the
        // mapping, and no credential is ever passed to the log.
        _logGoogleRejection(request, error: error, stackTrace: stackTrace);
        throw error;
      });
      await _persistSession(response);
      return response.toEntity();
    }, mapper: _googleFailureMapper);
  }

  /// Maps a `POST /auth/google` failure.
  ///
  /// The first thing it looks for is the one signal that means "this Google
  /// account is brand-new and still needs a vehicle": a `422` whose body names
  /// [vehicleRequiredErrorCode]. Both halves of that signal are placeholders
  /// pending backend confirmation, and both are required on purpose — a plain
  /// `400`, `401` or `404`, or a `422` for an unrelated validation problem,
  /// must never be read as "new account", or an existing user would be sent to
  /// the vehicle step they exist to skip.
  ///
  /// Everything else keeps the app-wide mapping: `401` and `500` collapse into
  /// the retryable [GoogleAuthTokenRejectedFailure] (see
  /// [ExceptionMapper.mapGoogleAuth]), and timeouts, transport errors and
  /// readable validation messages keep the mapping they have everywhere else.
  Failure _googleFailureMapper(Object error, StackTrace stackTrace) {
    // TODO(backend): confirm the wire signal for "new Google account" before
    // merging — both the status and the code are assumed, not documented yet.
    const vehicleRequiredStatus = 422;
    const vehicleRequiredErrorCode = 'VEHICLE_REQUIRED';

    if (error is DioException &&
        error.type == DioExceptionType.badResponse &&
        ExceptionMapper.effectiveStatusOf(error) == vehicleRequiredStatus &&
        _carriesErrorCode(error, vehicleRequiredErrorCode)) {
      return const GoogleVehicleRequiredFailure();
    }
    return _exceptionMapper.mapGoogleAuth(error, stackTrace);
  }

  /// Whether the failed response's body names [code] anywhere a backend error
  /// code can legitimately appear.
  ///
  /// The envelope is `{ statusCode, message, error }` and the backend is free
  /// to put the code in any of them — `error` is a bare string on some routes
  /// and a nested object on others — so the search walks one level into each
  /// field rather than fixing a single shape the contract has not confirmed.
  static bool _carriesErrorCode(DioException error, String code) {
    final data = error.response?.data;
    if (data is! Map) return false;
    return _namesCode(code, data['error']) ||
        _namesCode(code, data['message']) ||
        _namesCode(code, data['code']) ||
        _namesCode(code, data['errorCode']);
  }

  /// Whether [field] — a string, a nested envelope object or a list of either
  /// — contains [code].
  static bool _namesCode(String code, Object? field) {
    if (field is String) return field.toUpperCase().contains(code);
    if (field is Map) {
      return _namesCode(code, field['code']) ||
          _namesCode(code, field['errorCode']) ||
          _namesCode(code, field['message']) ||
          _namesCode(code, field['error']);
    }
    if (field is List) return field.any((entry) => _namesCode(code, entry));
    return false;
  }

  /// Debug-only diagnostic for a `POST /auth/google` the server answered to.
  ///
  /// Records the effective status, the message the body carried and the field
  /// names this request sent — the token itself is replaced by a presence flag,
  /// so the credential can never reach the log while the *shape* of the request
  /// (which is what tells a registration-only body apart from a login-only one)
  /// stays visible. Reached only from the `onError` above, so this is the one
  /// place that still has the raw request and the raw response.
  ///
  /// A transport error (no response at all) is skipped: it is connectivity, it
  /// already maps to its own [NetworkFailure], and labelling it "rejected"
  /// would point the reader at the backend for a problem on the device.
  void _logGoogleRejection(
    GoogleAuthRequestModel request, {
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (!kDebugMode) return;
    if (error is! DioException) return;
    final response = error.response;
    if (response == null) return;
    final sentFields = request.toJson().keys.toList()..remove('idToken');
    developer.log(
      'POST /auth/google rejected the sign-in '
      '(status: ${ExceptionMapper.effectiveStatusOf(error)}, '
      'message: ${ExceptionMapper.messageOf(error) ?? 'none'}, '
      'sent: idToken + ${sentFields.isEmpty ? 'nothing' : sentFields.join(', ')})',
      name: 'AuthRepository.google',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) =>
      _guardVoid(
        () => _remote.forgotPassword(ForgotPasswordRequestModel(email: email)),
      );

  @override
  Future<Either<Failure, void>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _guardVoid(
    () => _remote.resetPassword(
      ResetPasswordRequestModel(
        resetToken: resetToken,
        newPassword: newPassword,
      ),
    ),
  );

  @override
  Future<Either<Failure, String>> refreshAccessToken(String refreshToken) =>
      _guard(() async {
        final response = await _remote.refresh(
          RefreshTokenRequestModel(refreshToken: refreshToken),
        );
        final newRefreshToken = response.refreshToken.isNotEmpty
            ? response.refreshToken
            : refreshToken;
        await _storage.writeTokens(
          accessToken: response.accessToken,
          refreshToken: newRefreshToken,
        );
        return response.accessToken;
      });

  @override
  Future<Either<Failure, void>> logout() => _guardVoid(() async {
    await _storage.clear();
    await LocalSessionCleaner.clear();
    // Disconnect the device from the Google account so the next sign-in shows
    // the account chooser instead of silently reusing the previous identity.
    await googleSignInService?.signOut();
  });

  // â”€â”€ Mappers / helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<Either<Failure, void>> _guardVoid(Future<void> Function() run) async {
    try {
      await run();
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(_exceptionMapper.map(error, stackTrace));
    }
  }

  /// Runs [run] and converts anything it throws into a [Failure].
  ///
  /// [mapper] exists so an endpoint can narrow the mapping (see
  /// [_googleFailureMapper]) without duplicating the try/catch; it defaults to
  /// the app-wide [ExceptionMapper.map]. The stack trace is always forwarded so
  /// an unexpected (non-HTTP) exception is logged in full while the UI only
  /// receives a safe message.
  Future<Either<Failure, T>> _guard<T>(
    Future<T> Function() run, {
    Failure Function(Object error, StackTrace stackTrace)? mapper,
  }) async {
    try {
      final value = await run();
      return Right(value);
    } catch (error, stackTrace) {
      final map = mapper ?? _exceptionMapper.map;
      return Left(map(error, stackTrace));
    }
  }

  Future<void> _persistSession(AuthResponseModel response) =>
      _storage.writeSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        role: response.user.role.wireValue,
      );
}
