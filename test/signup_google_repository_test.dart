// test/signup_google_repository_test.dart
//
// Repository test for the Google path: the params carry the ID token the flow
// already obtained, and the repository is a pure backend exchange — it never
// touches the SDK itself. Shared by the login screen's Google flow.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';
import 'package:routex_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:routex_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routex_mobile/features/auth/domain/entities/google_auth_params.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';
import 'package:routex_mobile/features/auth/domain/services/google_sign_in_service.dart';

const _sdkToken = 'id-token-from-sdk';

/// A complete, valid set of signup params.
const _params = GoogleAuthParams(
  idToken: _sdkToken,
  vehicleType: VehicleType.car,
  vehicleNumber: 'ABC123',
);

void main() {
  late _FakeGoogleSignInService google;
  late _FakeAdapter adapter;
  late _FakeStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    google = _FakeGoogleSignInService();
    storage = _FakeStorage();
    adapter = _authSucceeds();
    repository = _repositoryWith(google, storage, adapter);
  });

  group('Google repository', () {
    test('forwards idToken + platform + fcmToken + vehicle to /auth/google',
        () async {
      await repository.googleSignIn(
        const GoogleAuthParams(
          idToken: _sdkToken,
          platform: 'MOBILE',
          fcmToken: 'fcm-123',
          vehicleType: VehicleType.car,
          vehicleNumber: 'ABC123',
        ),
      );

      expect(adapter.requests.single.data, {
        'idToken': _sdkToken,
        'platform': 'MOBILE',
        'fcmToken': 'fcm-123',
        'vehicleType': 'CAR',
        'vehicleNumber': 'ABC123',
      });
    });

    test('never runs the SDK itself', () async {
      // The interactive chooser belongs to GetGoogleIdTokenUseCase; running it
      // here would ask the user to pick an account a second time.
      await repository.googleSignIn(_params);

      expect(google.signInCalls, 0);
      expect(google.signOutCalls, 0);
    });

    test('a blank token never reaches the backend', () async {
      final result = await repository.googleSignIn(
        const GoogleAuthParams(
          idToken: '   ',
          vehicleType: VehicleType.car,
          vehicleNumber: 'ABC123',
        ),
      );

      expect(
        result.fold((f) => f, (_) => null),
        isA<GoogleAuthCancelledFailure>(),
      );
      expect(adapter.requests, isEmpty);
    });

    test('persists session on success', () async {
      final result = await repository.googleSignIn(_params);

      expect(result.isRight(), isTrue);
      expect(storage.accessToken, 'access.jwt');
      expect(storage.refreshToken, 'refresh.jwt');
    });
  });
}

AuthRepositoryImpl _repositoryWith(
  GoogleSignInService google,
  SecureStorageService storage,
  HttpClientAdapter adapter,
) =>
    AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(
        Dio(BaseOptions(baseUrl: 'https://backend.test'))..httpClientAdapter = adapter,
      ),
      storage,
      googleSignInService: google,
    );

_FakeAdapter _authSucceeds() => _FakeAdapter((options) async {
      if (options.path == '/auth/google') {
        return _json({
          'success': true,
          'data': {
            'message': 'Google login successful',
            'user': {
              'id': 'usr_01',
              'firstName': 'John',
              'lastName': 'Doe',
              'email': 'john@example.com',
              'role': 'DRIVER',
            },
            'tokens': {'accessToken': 'access.jwt', 'refreshToken': 'refresh.jwt'},
          },
          'timestamp': '2026-01-01T00:00:00.000Z',
        });
      }
      return _json({'success': true, 'data': <String, dynamic>{}});
    });

/// Counts every interactive call so the "the repository never talks to Google"
/// contract can be asserted.
class _FakeGoogleSignInService implements GoogleSignInService {
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<GoogleAuthResult> signIn() async {
    signInCalls++;
    return const GoogleAuthResult.cancelled();
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}

class _FakeStorage implements SecureStorageService {
  String? accessToken;
  String? refreshToken;
  String? userId;
  String? role;
  @override
  Future<String?> readAccessToken() async => accessToken;
  @override
  Future<String?> readRefreshToken() async => refreshToken;
  @override
  Future<String?> readUserId() async => userId;
  @override
  Future<String?> readUserRole() async => role;
  @override
  Future<void> writeTokens({required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> writeSession({required String accessToken, required String refreshToken, required String userId, required String role}) async {
    await writeTokens(accessToken: accessToken, refreshToken: refreshToken);
    this.userId = userId;
    this.role = role;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    role = null;
  }
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object? payload, {int statusCode = 200}) => ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
