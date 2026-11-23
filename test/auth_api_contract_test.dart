// Contract tests for the auth API integration, driven by the payloads the real
// backend returns. They pin the bugs that used to make auth silently misparse:
// the `{success, data, timestamp}` envelope was never unwrapped, tokens were
// read from the wrong level, and validation messages arrive as a list.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/errors/exceptions.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/dio_client.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';
import 'package:routex_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:routex_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:routex_mobile/features/auth/data/models/login_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/register_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/refresh_token_request_model.dart';
import 'package:routex_mobile/features/auth/data/models/verify_otp_request_model.dart';
import 'package:routex_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:routex_mobile/features/auth/domain/entities/login_credentials.dart';
import 'package:routex_mobile/features/auth/domain/entities/user_role.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';

void main() {
  group('AuthRemoteDataSource against the real contract', () {
    test(
      'register posts the documented body and parses message + user',
      () async {
        final adapter = _FakeAdapter((options) async {
          expect(options.path, '/auth/register');
          expect(options.data, {
            'firstName': 'John',
            'lastName': 'Doe',
            'country': 'Saudi Arabia',
            'email': 'john@example.com',
            'password': 'Passw0rd!',
            'phone': '+966500000000',
            'role': 'DRIVER',
          });
          return _json(_registerPayload);
        });
        final source = AuthRemoteDataSourceImpl(_dataSourceDio(adapter));

        final response = await source.register(
          const RegisterRequestModel(
            firstName: 'John',
            lastName: 'Doe',
            country: 'Saudi Arabia',
            email: 'john@example.com',
            password: 'Passw0rd!',
            phone: '+966500000000',
            role: 'DRIVER',
          ),
        );

        // Register returns no tokens: it confirms and returns the inactive user.
        expect(response.message, 'Registration successful');
        expect(response.user.id, 'usr_01');
        expect(response.user.firstName, 'John');
        expect(response.user.lastName, 'Doe');
        expect(response.user.fullName, 'John Doe');
        expect(response.user.email, 'john@example.com');
        expect(response.user.role, UserRole.driver);
        expect(response.user.isActive, isFalse);
      },
    );

    test(
      'register never sends a fullName key and always sends country',
      () async {
        final adapter = _FakeAdapter((options) async {
          final body = options.data as Map<String, dynamic>;
          expect(body.containsKey('fullName'), isFalse);
          expect(body['country'], isNotNull);
          expect(body.containsKey('vehicleType'), isFalse);
          return _json(_registerPayload);
        });
        final source = AuthRemoteDataSourceImpl(_dataSourceDio(adapter));

        await source.register(
          const RegisterRequestModel(
            firstName: 'John',
            lastName: 'Doe',
            country: 'Saudi Arabia',
            email: 'john@example.com',
            password: 'Passw0rd!',
            phone: '+966500000000',
            role: 'DRIVER',
          ),
        );
      },
    );

    test('verifyOtp on a 2xx with no tokens is a success, not a failure', () async {
      // The reported bug: a *correct* code showed an error. The backend accepted
      // it (2xx) but returned no `tokens`, and the strict parser turned that into
      // a failure. Success must follow the HTTP status.
      final adapter = _FakeAdapter(
        (options) async => _json({
          'success': true,
          'data': {'message': 'Email verified successfully'},
          'timestamp': '2026-01-01T00:00:00.000Z',
        }),
      );
      final storage = _FakeStorage();
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
        storage,
      );

      final result = await repository.verifyOtp(
        email: 'john@example.com',
        otp: '123456',
      );

      expect(result.isRight(), isTrue);
      // No tokens means no session is written: empty credentials must never be
      // persisted, or a later cold start would read them as a signed-in user.
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.userId, isNull);
    });

    test(
      'verifyOtp still persists the session when tokens are present',
      () async {
        final adapter = _FakeAdapter(
          (options) async => _json(_sessionPayload()),
        );
        final storage = _FakeStorage();
        final repository = AuthRepositoryImpl(
          AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
          storage,
        );

        final result = await repository.verifyOtp(
          email: 'john@example.com',
          otp: '123456',
        );

        expect(result.isRight(), isTrue);
        expect(storage.accessToken, 'access.jwt');
        expect(storage.userId, 'usr_01');
        expect(storage.role, 'DRIVER');
      },
    );

    test('verifyOtp reads the tokens nested under data.tokens', () async {
      final adapter = _FakeAdapter((options) async => _json(_sessionPayload()));
      final source = AuthRemoteDataSourceImpl(_dataSourceDio(adapter));

      final response = await source.verifyOtp(
        const VerifyOtpRequestModel(email: 'john@example.com', otp: '123456'),
      );

      expect(response.accessToken, 'access.jwt');
      expect(response.refreshToken, 'refresh.jwt');
      expect(response.user.firstName, 'John');
      expect(response.user.lastName, 'Doe');
      expect(response.user.isActive, isTrue);

      final session = response.toEntity();
      expect(session.tokens.accessToken, 'access.jwt');
      expect(session.tokens.refreshToken, 'refresh.jwt');
      expect(session.user.fullName, 'John Doe');
      expect(session.user.isActive, isTrue);
    });

    test('login parses the same envelope shape as verify-otp', () async {
      final adapter = _FakeAdapter((options) async => _json(_sessionPayload()));
      final source = AuthRemoteDataSourceImpl(_dataSourceDio(adapter));

      final response = await source.login(
        const LoginRequestModel(
          email: 'john@example.com',
          password: 'Passw0rd!',
        ),
      );

      expect(response.accessToken, 'access.jwt');
      expect(response.refreshToken, 'refresh.jwt');
      expect(response.user.id, 'usr_01');
    });

    test('refresh parses the new token pair', () async {
      final adapter = _FakeAdapter((options) async => _json(_sessionPayload()));
      final source = AuthRemoteDataSourceImpl(_dataSourceDio(adapter));

      final response = await source.refresh(
        const RefreshTokenRequestModel(refreshToken: 'refresh.jwt'),
      );

      expect(response.accessToken, 'access.jwt');
      expect(response.refreshToken, 'refresh.jwt');
    });

    test('an envelope without data is rejected instead of parsed as empty', () {
      // This is exactly what the old code mis-parsed into empty models.
      final source = AuthRemoteDataSourceImpl(
        _dataSourceDio(
          null,
          payload: {'success': true, 'timestamp': '2026-01-01T00:00:00.000Z'},
        ),
      );

      expect(
        () => source.login(
          const LoginRequestModel(
            email: 'john@example.com',
            password: 'Passw0rd!',
          ),
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('data'), contains('/auth/login')),
          ),
        ),
      );
    });

    test(
      'a response without tokens is rejected instead of parsed as empty',
      () {
        final source = AuthRemoteDataSourceImpl(
          _dataSourceDio(
            null,
            payload: {
              'success': true,
              'data': {
                'message': 'Logged in',
                'user': {'id': 'usr_01'},
              },
              'timestamp': '2026-01-01T00:00:00.000Z',
            },
          ),
        );

        expect(
          () => source.login(
            const LoginRequestModel(
              email: 'john@example.com',
              password: 'Passw0rd!',
            ),
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('tokens'),
            ),
          ),
        );
      },
    );
  });

  group('ExceptionMapper', () {
    test('uses a nested error.statusCode over the 500 envelope', () {
      // The backend wraps a 400 inside a 500 envelope. Trusting the outer
      // status turned every such rejection into a generic ServerFailure, which
      // is what made a rejected OTP look like a server fault.
      final failure = const ExceptionMapper().map(
        _dioError(500, {
          'statusCode': 500,
          'message': 'Internal server error',
          'error': {
            'statusCode': 400,
            'message': 'Invalid or expired verification code',
          },
        }),
      );

      expect(
        ExceptionMapper.effectiveStatusOf(
          _dioError(500, {
            'statusCode': 500,
            'error': {'statusCode': 400, 'message': 'nope'},
          }),
        ),
        400,
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Invalid or expired verification code');
    });

    test('falls back to the envelope status when nothing is nested', () {
      expect(
        ExceptionMapper.effectiveStatusOf(
          _dioError(401, {'statusCode': 401, 'message': 'Unauthorized'}),
        ),
        401,
      );
      expect(
        ExceptionMapper.effectiveStatusOf(_dioError(500, <String, dynamic>{})),
        500,
      );
      // No response at all (connectivity): there is no status to report.
      expect(ExceptionMapper.effectiveStatusOf(FormatException('x')), isNull);
    });

    test('a nested numeric-string status is honoured too', () {
      expect(
        ExceptionMapper.effectiveStatusOf(
          _dioError(500, {
            'error': {'statusCode': '422'},
          }),
        ),
        422,
      );
    });

    test('keeps a list of validation messages instead of "Bad Request"', () {
      final failure = const ExceptionMapper().map(
        _dioError(400, {
          'statusCode': 400,
          'timestamp': '2026-01-01T00:00:00.000Z',
          'path': '/auth/login',
          'message': [
            'password must be longer than or equal to 8 characters',
            'email must be an email',
          ],
          'error': 'Bad Request',
        }),
      );

      expect(failure, isA<ValidationFailure>());
      expect(
        failure.message,
        'password must be longer than or equal to 8 characters\n'
        'email must be an email',
      );
    });

    test('still handles a single string message', () {
      final failure = const ExceptionMapper().map(
        _dioError(401, {
          'statusCode': 401,
          'message': 'Invalid credentials',
          'error': 'Unauthorized',
        }),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Invalid credentials');
    });

    test('still passes a real "Invalid email or password" through untouched', () {
      // The regression guard for Issue 1: sanitising unexpected exceptions must
      // not cost us the backend's own wording for a genuine auth failure.
      final failure = const ExceptionMapper().map(
        _dioError(401, {
          'statusCode': 401,
          'message': 'Invalid email or password',
          'error': 'Unauthorized',
        }),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Invalid email or password');
    });

    test('never puts a raw non-Dio exception in the failure message', () {
      // A model's fromJson used to reach the SnackBar verbatim, tokens and all.
      final failure = const ExceptionMapper().map(
        FormatException(
          'Missing `user` in the auth response: '
          '{message: Login successful., tokens: {accessToken: secret.jwt}}',
        ),
        StackTrace.current,
      );

      expect(failure, isA<ServerFailure>());
      expect(
        failure.message,
        ExceptionMapper.unexpectedErrorKey,
        reason: 'a translation key, not the exception text',
      );
      expect(failure.message, isNot(contains('secret.jwt')));
      expect(failure.message, isNot(contains('FormatException')));
    });

    test('gives an incomplete auth response its own distinguishable key', () {
      // Tokens but no user: the request was accepted, so this must not be
      // reported as a network or a generic server error.
      final failure = const ExceptionMapper().map(
        IncompleteAuthResponseException(
          'Missing `user` in the auth response: {tokens: {...}}',
        ),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, ExceptionMapper.incompleteResponseKey);
      expect(
        failure.message,
        isNot(ExceptionMapper.unexpectedErrorKey),
        reason: 'triage can tell the two apart',
      );
    });
  });

  group('AuthResponseModel.fromLoginJson', () {
    // The payload below is the real `/auth/login` success body, confirmed
    // against the live backend with Postman: `message` + `tokens`, no `user`.
    // The token is a standard three-part JWT whose claims are the account's
    // only identity source at login time.
    const realAccessToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJzdWIiOiI1Yjg0YWJiZi0zNWJmLTQzODEtOWU5Yy03ZmI2N2M3NGRhZmQi'
        'LCJlbWFpbCI6ImFuYXMuc2guYWxoaWxvQGdtYWlsLmNvbSIsInJvbGUiOiJEUklW'
        'RVIiLCJpYXQiOjE3NjcyMjU2MDAsImV4cCI6MTc2NzIyOTIwMH0'
        '.c2lnbmF0dXJl';

    test('parses the real tokens-only payload from its JWT claims', () {
      final response = AuthResponseModel.fromLoginJson({
        'message': 'Login successful.',
        'tokens': {
          'accessToken': realAccessToken,
          'refreshToken': 'refresh.jwt',
        },
      });

      expect(response.user.id, '5b84abbf-35bf-4381-9e9c-7fb67c74dafd');
      expect(response.user.email, 'anas.sh.alhilo@gmail.com');
      expect(response.user.role, UserRole.driver);
      expect(response.accessToken, realAccessToken);
      expect(response.refreshToken, 'refresh.jwt');
      // No source for the names at login time; active by definition, since the
      // backend only issues a successful login for a verified account.
      expect(response.user.firstName, isEmpty);
      expect(response.user.lastName, isEmpty);
      expect(response.user.isActive, isTrue);
    });

    test('still prefers a user object when the response carries one', () {
      // Guards against the fallback quietly replacing the real thing: signup and
      // the OTP/Google flows depend on firstName/lastName coming from the API.
      final response = AuthResponseModel.fromLoginJson({
        'user': _user(),
        'tokens': {
          'accessToken': realAccessToken,
          'refreshToken': 'refresh.jwt',
        },
      });

      expect(response.user.id, 'usr_01');
      expect(response.user.firstName, 'John');
      expect(response.user.lastName, 'Doe');
      expect(response.user.role, UserRole.driver);
    });

    test('throws for an undecodable token when no user is present', () {
      // A plain FormatException (not IncompleteAuthResponseException) so it
      // lands on ExceptionMapper's generic-error path: something is genuinely
      // broken, and signing in an unidentified account is not an option.
      expect(
        () => AuthResponseModel.fromLoginJson({
          'message': 'Login successful.',
          'tokens': {'accessToken': 'not-a-jwt', 'refreshToken': 'refresh.jwt'},
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e is IncompleteAuthResponseException,
            'is an IncompleteAuthResponseException',
            isFalse,
          ),
        ),
      );
    });

    test('throws when a decodable token carries no `sub`', () {
      final header = base64Url
          .encode(utf8.encode('{"alg":"HS256"}'))
          .replaceAll('=', '');
      final noSubject = base64Url
          .encode(utf8.encode('{"email":"john@example.com","role":"DRIVER"}'))
          .replaceAll('=', '');
      final subjectlessToken = '$header.$noSubject.sig';

      expect(
        () => AuthResponseModel.fromLoginJson({
          'tokens': {
            'accessToken': subjectlessToken,
            'refreshToken': 'refresh.jwt',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('keeps the strict contract for endpoints that do send a user', () {
      // verifyOtp / googleAuth / refresh all use fromJson: a missing `user`
      // there is a contract break, not a variant to tolerate.
      expect(
        () => AuthResponseModel.fromJson({
          'tokens': {
            'accessToken': realAccessToken,
            'refreshToken': 'refresh.jwt',
          },
        }),
        throwsA(isA<IncompleteAuthResponseException>()),
      );
    });

    test('still requires the tokens themselves', () {
      expect(
        () => AuthResponseModel.fromLoginJson({'message': 'Login successful.'}),
        throwsA(isA<IncompleteAuthResponseException>()),
      );
      expect(
        () => AuthResponseModel.fromLoginJson({
          'tokens': {'refreshToken': 'refresh.jwt'},
        }),
        throwsA(isA<IncompleteAuthResponseException>()),
      );
    });
  });

  group('login with the real tokens-only response', () {
    test('signs the user in using the identity decoded from the JWT', () async {
      // End-to-end through the data source and repository: the shape returned by
      // the live backend for correct credentials.
      const accessToken =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
          '.eyJzdWIiOiI1Yjg0YWJiZi0zNWJmLTQzODEtOWU5Yy03ZmI2N2M3NGRhZmQi'
          'LCJlbWFpbCI6ImFuYXMuc2guYWxoaWxvQGdtYWlsLmNvbSIsInJvbGUiOiJEUklW'
          'RVIiLCJpYXQiOjE3NjcyMjU2MDAsImV4cCI6MTc2NzIyOTIwMH0'
          '.c2lnbmF0dXJl';
      final adapter = _FakeAdapter(
        (options) async => _json({
          'success': true,
          'data': {
            'message': 'Login successful.',
            'tokens': {
              'accessToken': accessToken,
              'refreshToken': 'refresh.jwt',
            },
          },
          'timestamp': '2026-01-01T00:00:00.000Z',
        }),
      );
      final storage = _FakeStorage();
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
        storage,
      );

      final result = await repository.login(
        const LoginCredentials(
          email: 'anas.sh.alhilo@gmail.com',
          password: 'Passw0rd!',
        ),
      );

      expect(result.isRight(), isTrue);
      final session = result.fold((_) => fail('expected success'), (s) => s);
      expect(session.user.id, '5b84abbf-35bf-4381-9e9c-7fb67c74dafd');
      expect(session.user.email, 'anas.sh.alhilo@gmail.com');
      expect(session.user.role, UserRole.driver);
      expect(session.tokens.accessToken, accessToken);
      // _persistSession is unchanged: it reads only user.id and user.role, both
      // of which now come from the token claims.
      expect(storage.userId, '5b84abbf-35bf-4381-9e9c-7fb67c74dafd');
      expect(storage.role, 'DRIVER');
      expect(storage.accessToken, accessToken);
    });

    test('a broken token fails safely and persists no session', () async {
      final adapter = _FakeAdapter(
        (options) async => _json({
          'success': true,
          'data': {
            'message': 'Login successful.',
            'tokens': {
              'accessToken': 'not-a-jwt',
              'refreshToken': 'refresh.jwt',
            },
          },
          'timestamp': '2026-01-01T00:00:00.000Z',
        }),
      );
      final storage = _FakeStorage();
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
        storage,
      );

      final result = await repository.login(
        const LoginCredentials(
          email: 'john@example.com',
          password: 'Passw0rd!',
        ),
      );

      expect(result.isLeft(), isTrue);
      final failure = result.fold(
        (f) => f,
        (_) => fail('login should not succeed'),
      );
      expect(failure.message, ExceptionMapper.unexpectedErrorKey);
      expect(failure.message, isNot(contains('not-a-jwt')));
      // No half-built session: nothing is written and nobody is signed in.
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.userId, isNull);
    });

    test('still signs the user in on a well-formed response', () async {
      final adapter = _FakeAdapter((options) async => _json(_sessionPayload()));
      final storage = _FakeStorage();
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
        storage,
      );

      final result = await repository.login(
        const LoginCredentials(
          email: 'john@example.com',
          password: 'Passw0rd!',
        ),
      );

      expect(result.isRight(), isTrue);
      final session = result.fold((_) => fail('expected success'), (s) => s);
      expect(session.user.email, 'john@example.com');
      expect(session.tokens.accessToken, 'access.jwt');
      expect(storage.accessToken, 'access.jwt');
    });
  });

  group('AuthResponseModel.fromVerifyOtpJson', () {
    // The body below is the real `/auth/verify-otp` success payload for a
    // correct code, confirmed against the live backend: the tokens are FLAT in
    // `data`, not nested under `data.tokens`, and a `resetToken` sits beside
    // them. The strict nested-only parser threw here, the resulting placeholder
    // was reported as a token-less success, and the user saw
    // "Invalid or expired verification code." for a code that had worked.
    test('parses the flat token body into a usable session', () {
      final response = AuthResponseModel.fromVerifyOtpJson(
        _verifyOtpSuccessPayload()['data'] as Map<String, dynamic>,
      );

      expect(response.hasSession, isTrue);
      expect(response.accessToken, 'flat-access.jwt');
      expect(response.refreshToken, 'flat-refresh.jwt');
      // The user comes from `data.user`, not from token claims.
      expect(response.user.id, 'usr_01');
      expect(response.user.firstName, 'John');
      expect(response.user.lastName, 'Doe');
      expect(response.user.email, 'john@example.com');
      expect(response.user.role, UserRole.driver);
      expect(response.user.isActive, isTrue);
    });

    test('accepts either token placement', () {
      // Nested (login / google / refresh) and flat (verify-otp) must both work
      // through the same parser, so neither endpoint can regress into the
      // other's parse error.
      final nested = AuthResponseModel.fromJson(
        _sessionPayload()['data'] as Map<String, dynamic>,
      );
      expect(nested.hasSession, isTrue);
      expect(nested.accessToken, 'access.jwt');
      expect(nested.refreshToken, 'refresh.jwt');

      final flat = AuthResponseModel.fromVerifyOtpJson(
        _verifyOtpSuccessPayload()['data'] as Map<String, dynamic>,
      );
      expect(flat.hasSession, isTrue);
      expect(flat.accessToken, 'flat-access.jwt');

      // The nested shape still wins when an endpoint ever sends both.
      final both = AuthResponseModel.fromVerifyOtpJson({
        'user': _user(),
        'tokens': {
          'accessToken': 'nested.jwt',
          'refreshToken': 'nested-refresh.jwt',
        },
        'accessToken': 'flat.jwt',
        'refreshToken': 'flat-refresh.jwt',
      });
      expect(both.accessToken, 'nested.jwt');
      expect(both.refreshToken, 'nested-refresh.jwt');
    });

    test('a 2xx with no tokens at all is still verified, with no session', () {
      // The documented fallback: acceptance is decided by the status, and
      // nothing may be persisted when there is no token to persist.
      final response = AuthResponseModel.fromVerifyOtpJson({
        'message': 'Email verified successfully',
      });

      expect(response.hasSession, isFalse);
      expect(response.accessToken, isEmpty);
      expect(response.refreshToken, isEmpty);
    });

    test('an empty token string does not count as a session', () {
      final response = AuthResponseModel.fromVerifyOtpJson({
        'user': _user(),
        'accessToken': '   ',
        'refreshToken': '',
      });

      expect(
        response.hasSession,
        isFalse,
        reason: 'a blank credential must never look like a signed-in session',
      );
    });
  });

  group('verify-otp end to end against the real contract', () {
    test('a correct code persists the session and returns the user', () async {
      final adapter = _FakeAdapter(
        (options) async => _json(_verifyOtpSuccessPayload()),
      );
      final storage = _FakeStorage();
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
        storage,
      );

      final result = await repository.verifyOtp(
        email: 'john@example.com',
        otp: '123456',
      );

      expect(result.isRight(), isTrue);
      final session = result.fold((_) => fail('expected success'), (s) => s);
      expect(session.tokens.accessToken, 'flat-access.jwt');
      expect(session.tokens.refreshToken, 'flat-refresh.jwt');
      expect(session.user.id, 'usr_01');
      expect(session.user.isActive, isTrue);

      // Persisted, so the next screen can continue into the app.
      expect(storage.accessToken, 'flat-access.jwt');
      expect(storage.refreshToken, 'flat-refresh.jwt');
      expect(storage.userId, 'usr_01');
      expect(storage.role, 'DRIVER');
    });

    test('a rejected code is a validation failure with no session', () async {
      // The 500-envelope-wrapped 400 the endpoint answers for a wrong, expired
      // or already-used code — the message the user reported seeing after a
      // successful verification, caused by a second request.
      final adapter = _FakeAdapter(
        (options) async => _json(_rejectedOtpPayload(), statusCode: 500),
      );
      final storage = _FakeStorage();
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
        storage,
      );

      final result = await repository.verifyOtp(
        email: 'john@example.com',
        otp: '123456',
      );

      expect(result.isLeft(), isTrue);
      final failure = result.fold((f) => f, (_) => fail('should be rejected'));
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Invalid or expired verification code.');
      // A rejected attempt never signs anybody in.
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
    });

    test('the nested shape is still accepted on the same endpoint', () async {
      // Guards the other direction: making verify-otp tolerate flat tokens must
      // not cost it the nested shape.
      final adapter = _FakeAdapter((options) async => _json(_sessionPayload()));
      final storage = _FakeStorage();
      final repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(_dataSourceDio(adapter)),
        storage,
      );

      final result = await repository.verifyOtp(
        email: 'john@example.com',
        otp: '123456',
      );

      expect(result.isRight(), isTrue);
      expect(storage.accessToken, 'access.jwt');
      expect(storage.refreshToken, 'refresh.jwt');
    });
  });

  group('DioClient auth interceptor', () {
    test(
      'attaches the stored access token, and skipAuth suppresses it',
      () async {
        final storage = _FakeStorage(accessToken: 'access.jwt');
        final adapter = _FakeAdapter(
          (options) async => _json(_sessionPayload()),
        );
        final dio = _clientWith(storage, adapter);

        await dio.post<dynamic>(
          '/orders',
          data: const {},
          options: Options(extra: const {DioClient.skipAuthFlag: true}),
        );
        expect(adapter.requests.first.headers['Authorization'], isNull);

        await dio.post<dynamic>('/orders', data: const {});
        expect(
          adapter.requests.last.headers['Authorization'],
          'Bearer access.jwt',
        );
      },
    );

    test('adds no Authorization header when nothing is stored', () async {
      final storage = _FakeStorage();
      final adapter = _FakeAdapter(
        (options) async =>
            _json({'success': true, 'data': <String, dynamic>{}}),
      );
      final dio = _clientWith(storage, adapter);

      await dio.post<dynamic>('/auth/login', data: const {});

      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('refreshes once on 401 and replays the request', () async {
      final storage = _FakeStorage(
        accessToken: 'stale.jwt',
        refreshToken: 'refresh.jwt',
      );
      final adapter = _FakeAdapter((options) async {
        if (options.path == '/auth/refresh') {
          expect(options.data, {'refreshToken': 'refresh.jwt'});
          // The refresh call must not carry the stale Authorization header.
          expect(options.headers['Authorization'], isNull);
          return _json(_refreshedSessionPayload());
        }
        if (storage.accessToken == 'fresh.jwt') {
          return _json({
            'success': true,
            'data': {'ok': true},
          });
        }
        return _unauthorized();
      });
      final dio = _clientWith(storage, adapter);

      final response = await dio.post<dynamic>('/orders', data: const {});

      expect(response.data, {
        'success': true,
        'data': {'ok': true},
      });
      expect(storage.accessToken, 'fresh.jwt');
      expect(storage.refreshToken, 'refresh-2.jwt');
      expect(
        adapter.requests.where((r) => r.path == '/orders').length,
        2,
        reason: 'the original request is replayed exactly once',
      );
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer fresh.jwt',
      );
    });

    test('concurrent 401s share a single refresh round-trip', () async {
      final storage = _FakeStorage(
        accessToken: 'stale.jwt',
        refreshToken: 'refresh.jwt',
      );
      var refreshCalls = 0;
      final adapter = _FakeAdapter((options) async {
        if (options.path == '/auth/refresh') {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return _json(_refreshedSessionPayload());
        }
        if (storage.accessToken == 'fresh.jwt') {
          return _json({
            'success': true,
            'data': {'ok': true},
          });
        }
        return _unauthorized();
      });
      final dio = _clientWith(storage, adapter);

      await Future.wait([
        dio.post<dynamic>('/orders', data: const {}),
        dio.post<dynamic>('/orders', data: const {}),
        dio.post<dynamic>('/orders', data: const {}),
      ]);

      expect(refreshCalls, 1);
    });

    test(
      'clears the session and surfaces UnauthorizedFailure when refresh fails',
      () async {
        final storage = _FakeStorage(
          accessToken: 'stale.jwt',
          refreshToken: 'refresh.jwt',
        );
        final adapter = _FakeAdapter((options) async {
          if (options.path == '/auth/refresh') {
            return _json({
              'statusCode': 401,
              'message': 'Refresh token expired',
              'error': 'Unauthorized',
            }, statusCode: 401);
          }
          return _unauthorized();
        });
        final dio = _clientWith(storage, adapter);

        Object? caught;
        try {
          await dio.post<dynamic>('/orders', data: const {});
        } on DioException catch (error) {
          caught = error;
        }

        expect(caught, isNotNull);
        final failure = const ExceptionMapper().map(caught!);
        expect(failure, isA<UnauthorizedFailure>());
        expect(storage.cleared, isTrue);
        expect(storage.accessToken, isNull);
        expect(storage.refreshToken, isNull);
        expect(
          adapter.requests.where((r) => r.path == '/auth/refresh').length,
          1,
          reason: 'a rejected refresh is not retried',
        );
      },
    );

    test('does not loop when the replayed request is rejected again', () async {
      final storage = _FakeStorage(
        accessToken: 'stale.jwt',
        refreshToken: 'refresh.jwt',
      );
      var orderCalls = 0;
      final adapter = _FakeAdapter((options) async {
        if (options.path == '/auth/refresh') {
          return _json(_refreshedSessionPayload());
        }
        orderCalls++;
        return _unauthorized();
      });
      final dio = _clientWith(storage, adapter);

      await expectLater(
        dio.post<dynamic>('/orders', data: const {}),
        throwsA(isA<DioException>()),
      );
      expect(orderCalls, 2, reason: 'one original call plus exactly one retry');
    });
  });

  test('VehicleType wire values match the documented contract', () {
    // The API's `RegisterDto.vehicleType` enum is ["BIKE", "CAR", "VAN",
    // "TRUCK"] per its published OpenAPI schema. "MOTORCYCLE" is not accepted
    // and came back as `400 "نوع المركبة غير مدعوم"`.
    expect(VehicleType.motorcycle.wireValue, 'BIKE');
    expect(VehicleType.car.wireValue, 'CAR');
    expect(VehicleType.van.wireValue, 'VAN');
    expect(VehicleType.truck.wireValue, 'TRUCK');
  });

  test('every vehicle type maps to a value the API accepts', () {
    const accepted = {'BIKE', 'CAR', 'VAN', 'TRUCK'};
    for (final type in VehicleType.values) {
      expect(
        accepted,
        contains(type.wireValue),
        reason: '${type.name} sends an unaccepted vehicleType',
      );
      // The selector's lowercase keys must all resolve, or the request would
      // go out with a null vehicleType and fail as `errVehicleRequired`.
      expect(VehicleType.fromDisplayKey(type.name), type);
    }
  });
}

// ── Sample payloads (the shapes the backend actually returns) ──────────────

Map<String, dynamic> _user({bool isActive = true}) => {
  'id': 'usr_01',
  'firstName': 'John',
  'lastName': 'Doe',
  'email': 'john@example.com',
  'role': 'DRIVER',
  'isActive': isActive,
};

const _registerPayload = {
  'success': true,
  'data': {
    'message': 'Registration successful',
    'user': {
      'id': 'usr_01',
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'john@example.com',
      'role': 'DRIVER',
      'isActive': false,
    },
  },
  'timestamp': '2026-01-01T00:00:00.000Z',
};

Map<String, dynamic> _sessionPayload() => {
  'success': true,
  'data': {
    'message': 'Login successful',
    'user': _user(),
    'tokens': {'accessToken': 'access.jwt', 'refreshToken': 'refresh.jwt'},
  },
  'timestamp': '2026-01-01T00:00:00.000Z',
};

Map<String, dynamic> _refreshedSessionPayload() => {
  'success': true,
  'data': {
    'message': 'Token refreshed',
    'user': _user(),
    'tokens': {'accessToken': 'fresh.jwt', 'refreshToken': 'refresh-2.jwt'},
  },
  'timestamp': '2026-01-01T00:00:00.000Z',
};

/// The real `POST /auth/verify-otp` success body for a correct code.
///
/// `accessToken` / `refreshToken` are **flat** inside `data`, sitting next to
/// `user` and a `resetToken`; there is no nested `tokens` object on this
/// endpoint. Parsing it with the nested-only rule is what turned a correct code
/// into "Invalid or expired verification code".
Map<String, dynamic> _verifyOtpSuccessPayload() => {
  'success': true,
  'data': {
    'message': 'Account activated successfully.',
    'user': _user(),
    'resetToken': 'reset.jwt',
    'accessToken': 'flat-access.jwt',
    'refreshToken': 'flat-refresh.jwt',
  },
  'timestamp': '2026-01-01T00:00:00.000Z',
};

/// The real rejection body for a wrong, expired or already-used code: a 500
/// envelope wrapping the 400 the route actually meant to send.
Map<String, dynamic> _rejectedOtpPayload() => {
  'statusCode': 500,
  'message': 'Invalid or expired verification code.',
  'error': {
    'statusCode': 400,
    'message': 'Invalid or expired verification code.',
    'error': 'Bad Request',
  },
};

ResponseBody _unauthorized() => _json({
  'statusCode': 401,
  'message': 'Expired',
  'error': 'Unauthorized',
}, statusCode: 401);

// ── Test doubles ────────────────────────────────────────────────────────────

/// A [Dio] wired to [adapter] for the data-source tests (no interceptors).
Dio _dataSourceDio(_FakeAdapter? adapter, {Map<String, dynamic>? payload}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://backend.test'));
  dio.httpClientAdapter =
      adapter ??
      _FakeAdapter(
        (options) async => _json(
          payload ??
              {
                'success': true,
                'data': <String, dynamic>{},
                'timestamp': '2026-01-01T00:00:00.000Z',
              },
        ),
      );
  return dio;
}

/// The production client, with its interceptor-free transport pointed at
/// [adapter] so both the refresh call and the replay are observable.
Dio _clientWith(SecureStorageService storage, _FakeAdapter adapter) =>
    DioClient.createClient(
      storage: storage,
      refreshClientFactory: () =>
          Dio(BaseOptions(baseUrl: 'https://backend.test'))
            ..httpClientAdapter = adapter,
    )..httpClientAdapter = adapter;

ResponseBody _json(Object? payload, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

DioException _dioError(int statusCode, Map<String, dynamic> body) {
  final options = RequestOptions(path: '/auth/login');
  return DioException.badResponse(
    statusCode: statusCode,
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: body,
    ),
  );
}

/// Serves canned responses and records what was sent.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeStorage implements SecureStorageService {
  _FakeStorage({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  String? userId;
  String? role;
  bool cleared = false;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<String?> readUserId() async => userId;

  @override
  Future<String?> readUserRole() async => role;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> writeSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.userId = userId;
    this.role = role;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    accessToken = null;
    refreshToken = null;
    userId = null;
    role = null;
  }
}
