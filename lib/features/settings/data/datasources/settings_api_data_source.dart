import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routex_mobile/core/session/driver_identity.dart';
import 'package:routex_mobile/core/session/local_session_cleaner.dart';
import 'package:routex_mobile/core/config/constants/api_endpoints.dart';
import 'package:routex_mobile/core/network/api_envelope.dart';
import 'package:routex_mobile/core/network/dio_client.dart';
import 'package:routex_mobile/core/storage/secure_storage_service.dart';

import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/nearby_fleet_entity.dart';
import '../models/driver_profile_model.dart';
import 'settings_local_data_source.dart';

/// Settings backed by the real API.
///
/// Account data (name, phone, company, vehicle) comes from `GET /auth/me`.
/// Preferences the backend knows nothing about (navigation app, route
/// options, notification options, quiet hours) are kept on the device in
/// [SharedPreferences], so they survive an app restart.
class SettingsApiDataSource implements SettingsLocalDataSource {
  SettingsApiDataSource({
    required Dio dio,
    required SecureStorageService storage,
    required SharedPreferences preferences,
  }) : _dio = dio,
       _storage = storage,
       _prefs = preferences;

  final Dio _dio;
  final SecureStorageService _storage;
  final SharedPreferences _prefs;

  /// Last profile shown; carries the device-only preferences.
  DriverProfileModel? _profile;

  /// Single-use token from `verify-reset-otp`, consumed by `reset-password`.
  String? _resetToken;

  static const String _codePrefix = 'code:';


  // ── Device-only preferences ──────────────────────────────────────────

  static const String _prefsKey = 'settings.device_preferences';

  static const List<String> _deviceKeys = [
    'is_notifications_enabled',
    'navigation_app',
    'avoid_tolls',
    'avoid_highways',
    'avoid_unpaved',
    'notify_new_routes',
    'notify_order_changes',
    'notify_dispatch_messages',
    'notification_sound',
    'notification_vibrate',
    'quiet_hours_enabled',
    'quiet_hours_start_minutes',
    'quiet_hours_end_minutes',
    'quiet_hours_days',
    'location_access',
  ];

  Map<String, dynamic> _readSaved() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
    } catch (_) {
      return const {};
    }
  }

  Future<void> _saveDevicePrefs(DriverProfileModel model) async {
    final json = model.toJson();
    await _prefs.setString(
      _prefsKey,
      jsonEncode({for (final k in _deviceKeys) k: json[k]}),
    );
  }

  /// First non-empty string found under any of [keys] in any of [sources].
  static String? _pick(Iterable<Map<String, dynamic>?> sources, List<String> keys) {
    for (final source in sources) {
      if (source == null) continue;
      for (final key in keys) {
        final v = source[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }

  static Map<String, dynamic>? _map(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;

  // ── Profile ──────────────────────────────────────────────────────────

  /// The picture URL `/auth/me` returns for the driver, if any. The backend
  /// field name is not documented, so the likely names are tried in turn.
  static String? profileImageUrl(Map<String, dynamic> user) {
    for (final key in const [
      'profileImage',
      'profileImageUrl',
      'profilePhoto',
      'profilePicture',
      'photoUrl',
      'photo',
      'avatarUrl',
      'avatar',
      'imageUrl',
      'image',
      'picture',
    ]) {
      final v = user[key];
      if (v is String && v.startsWith('http')) return v;
    }
    return null;
  }

  @override
  Future<DriverProfileModel> getProfile() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.me);
    final data = ApiEnvelope.unwrapData(response.data, path: ApiEndpoints.me);
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    final driver = (data['driverProfile'] ?? user['driverProfile']);
    final driverMap = driver is Map ? Map<String, dynamic>.from(driver) : const <String, dynamic>{};

    final memberships = (data['memberships'] ?? user['memberships']);
    Map<String, dynamic>? approved;
    if (memberships is List) {
      for (final m in memberships.whereType<Map>()) {
        if ('${m['status']}'.toUpperCase() == 'APPROVED') {
          approved = Map<String, dynamic>.from(m);
        }
      }
    }

    if (kDebugMode) {
      // Field names only (never values), to see what the backend really sends.
      debugPrint('[me] keys: ${data.keys.toList()}; user: ${user.keys.toList()}; '
          'driverProfile: ${driverMap.keys.toList()}; '
          'membership: ${approved?.keys.toList()}');
    }
    String s(Object? v) => v?.toString() ?? '';
    final name = '${s(user['firstName'])} ${s(user['lastName'])}'.trim();
    final prev = _profile;
    final saved = _readSaved();
    final photo = prev?.photoPath ?? profileImageUrl(user) ?? profileImageUrl(driverMap);
    DriverIdentity.update(name: name, photo: photo);

    T pref<T>(String key, T? current, T fallback) {
      if (current != null) return current;
      final v = saved[key];
      return v is T ? v : fallback;
    }

    final company = _map(approved?['company']);
    final sources = <Map<String, dynamic>?>[approved, company];
    final days = prev?.quietHoursDays ??
        (saved['quiet_hours_days'] is List
            ? (saved['quiet_hours_days'] as List).whereType<num>().map((e) => e.toInt()).toList()
            : const <int>[1, 2, 3, 4, 5, 6, 7]);
    final ratingValue = driverMap['rating'] ?? driverMap['averageRating'] ?? user['rating'];
    final logo = _pick(sources, const ['companyLogo', 'companyLogoUrl', 'logoUrl', 'logo']);
    final capacity = driverMap['loadCapacityKg'] ?? driverMap['capacityKg'];

    return _profile = DriverProfileModel(
      name: name,
      email: s(user['email']),
      phone: s(user['phone']),
      vehicleType: s(driverMap['vehicleType'] ?? user['vehicleType']).toLowerCase(),
      vehicleNumber: s(driverMap['vehicleNumber'] ?? user['vehicleNumber']),
      rating: ratingValue is num ? ratingValue.toDouble() : 0,
      isNotificationsEnabled: pref('is_notifications_enabled', prev?.isNotificationsEnabled, true),
      photoPath: photo,
      loadCapacityKg: capacity is num ? capacity.toInt() : null,
      vehicleModel: _pick([driverMap], const ['vehicleModel', 'model']),
      vehicleColour: _pick([driverMap], const ['vehicleColour', 'vehicleColor', 'color']),
      companyName: approved == null ? null : (_pick(sources, const ['companyName', 'name']) ?? ''),
      companyCode: _pick(sources, const ['companyCode', 'joinCode', 'code']),
      companyPhone: _pick(sources, const ['companyPhone', 'contactPhone', 'phone']),
      companyEmail: _pick(sources, const ['companyEmail', 'contactEmail', 'email']),
      companyLogoUrl: logo != null && logo.startsWith('http') ? logo : null,
      companyJoinedAt: DateTime.tryParse(
        _pick(sources, const ['approvedAt', 'joinedAt', 'createdAt']) ?? '',
      ),
      navigationApp: pref('navigation_app', prev?.navigationApp, 'google_maps'),
      avoidTolls: pref('avoid_tolls', prev?.avoidTolls, false),
      avoidHighways: pref('avoid_highways', prev?.avoidHighways, false),
      avoidUnpaved: pref('avoid_unpaved', prev?.avoidUnpaved, false),
      notifyNewRoutes: pref('notify_new_routes', prev?.notifyNewRoutes, true),
      notifyOrderChanges: pref('notify_order_changes', prev?.notifyOrderChanges, true),
      notifyDispatchMessages: pref('notify_dispatch_messages', prev?.notifyDispatchMessages, true),
      notificationSound: pref('notification_sound', prev?.notificationSound, true),
      notificationVibrate: pref('notification_vibrate', prev?.notificationVibrate, true),
      quietHoursEnabled: pref('quiet_hours_enabled', prev?.quietHoursEnabled, false),
      quietHoursStartMinutes: pref('quiet_hours_start_minutes', prev?.quietHoursStartMinutes, 23 * 60),
      quietHoursEndMinutes: pref('quiet_hours_end_minutes', prev?.quietHoursEndMinutes, 7 * 60),
      quietHoursDays: days,
      locationAccess: pref('location_access', prev?.locationAccess, 'always'),
    );
  }

  @override
  Future<DriverProfileModel> updateProfile(DriverProfileEntity profile) async {
    final parts = profile.name.trim().split(RegExp(r'\s+'));
    final first = parts.isEmpty ? '' : parts.first;
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final fields = <String, dynamic>{
      if (first.isNotEmpty) 'firstName': first,
      if (last.isNotEmpty) 'lastName': last,
      if (profile.phone.trim().isNotEmpty) 'phone': profile.phone.trim(),
    };
    final photo = profile.photoPath;
    final previous = _profile;
    final photoChanged = photo != null && photo.isNotEmpty && photo != previous?.photoPath;
    if (photoChanged) {
      fields['profileImage'] = await MultipartFile.fromFile(photo);
    }
    // TODO(backend): email is not editable through PATCH /auth/profile.
    await _dio.patch<dynamic>(ApiEndpoints.profile, data: FormData.fromMap(fields));
    _profile = DriverProfileModel.fromEntity(profile);
    await _saveDevicePrefs(_profile!);
    DriverIdentity.update(name: profile.name, photo: profile.photoPath);
    return _profile!;
  }

  @override
  Future<void> logout() async {
    // The sign-out request is sent first so the interceptor attaches the
    // token, but it is not awaited for long: the host can take 30-50 s to wake
    // and signing out must feel instant. Local sign-out follows either way.
    final request = _dio
        .post<dynamic>(ApiEndpoints.logout)
        .then<void>((_) {})
        .catchError((_) {});
    await Future.any<void>([
      request,
      Future<void>.delayed(const Duration(milliseconds: 600)),
    ]);
    await _storage.clear();
    DriverIdentity.clear();
    await _prefs.remove(_prefsKey);
    await LocalSessionCleaner.clear();
    _profile = null;
    _resetToken = null;
  }

  // ── Fleets ───────────────────────────────────────────────────────────

  @override
  Future<List<NearbyFleetEntity>> getNearbyFleets() async {
    // TODO(backend): no "nearby" endpoint; the search with an empty query is used.
    final response = await _dio.get<dynamic>(
      ApiEndpoints.companiesSearch,
      queryParameters: {'query': ''},
    );
    final body = response.data;
    final data = body is Map ? body['data'] : body;
    if (data is! List) return const [];
    return [
      for (final c in data.whereType<Map>())
        NearbyFleetEntity(
          id: '${c['companyId']}',
          name: '${c['companyName']}',
          area: '${c['registrationNumber'] ?? ''}',
          distanceKm: 0,
        ),
    ];
  }

  @override
  Future<NearbyFleetEntity?> findFleetByCode(String code) async {
    // TODO(backend): no endpoint validates a code without sending a request,
    // so the code itself stands for the fleet until it is sent.
    final normalized = code.trim().toUpperCase();
    if (normalized.length != 6) return null;
    return NearbyFleetEntity(
      id: '$_codePrefix$normalized',
      name: normalized,
      area: '',
      distanceKm: 0,
    );
  }

  @override
  Future<void> sendJoinRequest(String fleetId) async {
    if (fleetId.startsWith(_codePrefix)) {
      await _dio.post<dynamic>(
        ApiEndpoints.driversJoinByCode,
        data: {'code': fleetId.substring(_codePrefix.length)},
      );
    } else {
      await _dio.post<dynamic>(
        ApiEndpoints.driversJoin,
        data: {'companyId': fleetId},
      );
    }
  }

  @override
  Future<void> cancelJoinRequest(String fleetId) async {
    // TODO(backend): no endpoint cancels a join request.
  }

  // ── Passwords ────────────────────────────────────────────────────────

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.patch<dynamic>(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': newPassword,
      },
    );
  }

  Options get _publicOptions =>
      Options(extra: {DioClient.skipAuthFlag: true});

  @override
  Future<void> sendPasswordResetCode(String email) async {
    await _dio.post<dynamic>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
      options: _publicOptions,
    );
  }

  @override
  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.verifyResetOtp,
        data: {'email': email, 'otp': code},
        options: _publicOptions,
      );
      final data = ApiEnvelope.unwrapData(
        response.data,
        path: ApiEndpoints.verifyResetOtp,
      );
      final token = data['resetToken'];
      _resetToken = token is String && token.isNotEmpty ? token : null;
      return _resetToken != null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 404) return false;
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final token = _resetToken;
    if (token == null) {
      throw StateError('Reset token missing: verify the code first');
    }
    await _dio.post<dynamic>(
      ApiEndpoints.resetPassword,
      data: {
        'resetToken': token,
        'newPassword': newPassword,
        'confirmPassword': newPassword,
      },
      options: _publicOptions,
    );
    _resetToken = null;
  }

  // ── Support ──────────────────────────────────────────────────────────

  @override
  Future<String> sendProblemReport({
    required String category,
    required String description,
    required List<String> screenshotPaths,
    required bool includeDeviceDetails,
  }) async {
    // TODO(backend): no endpoint receives problem reports yet; a local
    // reference is returned so the confirmation screen still works.
    final number = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;
    return 'RPT-$number';
  }
}
