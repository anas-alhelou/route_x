import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routex_mobile/features/tracking/data/codec/tracking_frame_encoder.dart';
import 'package:routex_mobile/features/tracking/data/tracking_remote_data_source.dart';

/// Streams the driver's position to the backend while a route is running.
///
/// Lifecycle: [start] when the route starts, [stop] when it ends.
///  1. `POST /tracking/session` -> tracking token (kept in memory only).
///  2. For every GPS fix that is worth sending, build a binary frame and
///     `POST /tracking/location` with `X-Tracking-Seq`.
///  3. `POST /tracking/session/end`.
///
/// Rules (see the backend contract):
///  * at most one upload every [minInterval];
///  * send when moved >= [minMeters], or after [heartbeat] when standing still;
///  * the sequence number starts at 1 per session, grows only for a NEW sample,
///    is stored BEFORE sending, and a retry reuses the same number;
///  * positions are never queued: a point that fails is replaced by the next;
///  * 401/403 -> open a new session once; 400 -> drop; 429 -> back off.
///
/// Neither the token nor coordinates are ever logged.
/// What the driver-facing UI can show about sharing the position.
enum TrackingStatus {
  /// No route is being driven; nothing is shared.
  idle,

  /// The session is open and positions are being sent.
  active,

  /// The session could not be opened (offline, not eligible, ...). The service
  /// keeps trying with a growing delay until the route ends.
  retrying,
}

class TrackingService {
  TrackingService({
    required TrackingRemoteDataSource remote,
    required SharedPreferences preferences,
    TrackingFrameEncoder encoder = const TrackingFrameEncoder(),
    Stream<Position> Function()? positionStream,
    DateTime Function()? clock,
    this.appVersion = const String.fromEnvironment(
      'APP_VERSION',
      defaultValue: '1.0.0',
    ),
    this.minInterval = const Duration(seconds: 15),
    this.heartbeat = const Duration(seconds: 60),
    this.minMeters = 15,
    this.backoff = const Duration(seconds: 30),
  }) : _remote = remote,
       _prefs = preferences,
       _encoder = encoder,
       _positions = positionStream ?? _defaultStream,
       _now = clock ?? DateTime.now;

  static const String _seqKey = 'tracking_last_seq';

  final TrackingRemoteDataSource _remote;
  final SharedPreferences _prefs;
  final TrackingFrameEncoder _encoder;
  final Stream<Position> Function() _positions;
  final DateTime Function() _now;
  final String appVersion;
  final Duration minInterval;
  final Duration heartbeat;
  final double minMeters;
  final Duration backoff;

  StreamSubscription<Position>? _sub;
  String? _token;
  bool _starting = false;
  bool _sending = false;
  bool _restartedOnce = false;
  DateTime? _lastSentAt;
  Position? _lastSentPosition;
  DateTime? _pausedUntil;

  bool get isRunning => _sub != null;

  /// Latest GPS fix, for showing the driver's puck on the map. It is updated
  /// on every fix (not only the ones sent to the backend) and cleared on stop.
  final ValueNotifier<Position?> lastPosition = ValueNotifier<Position?>(null);

  /// Follows [TrackingStatus]; the route screen shows a banner on `retrying`.
  final ValueNotifier<TrackingStatus> status =
      ValueNotifier<TrackingStatus>(TrackingStatus.idle);

  Timer? _retryTimer;
  int _retryAttempt = 0;
  bool _wanted = false;

  /// Android runs this as a foreground service (ongoing notification), so the
  /// position keeps flowing when the driver switches to a navigation app or
  /// the screen turns off. iOS needs the `location` background mode.
  static Stream<Position> _defaultStream() {
    final LocationSettings settings = switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'RouteX is sharing your location',
          notificationText:
              'Your company sees your position while you deliver.',
          notificationIcon: AndroidResource(
            name: 'ic_notification',
            defType: 'drawable',
          ),
          enableWakeLock: true,
          setOngoing: true,
        ),
      ),
      TargetPlatform.iOS => AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      ),
      _ => const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    };
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Opens a session and starts listening to GPS. Safe to call twice.
  Future<void> start() async {
    _wanted = true;
    if (isRunning || _starting) return;
    _starting = true;
    try {
      if (!await _openSession()) {
        _scheduleRetry();
        return;
      }
      _beginStream();
    } finally {
      _starting = false;
    }
  }

  void _beginStream() {
    _retryTimer?.cancel();
    _retryAttempt = 0;
    _restartedOnce = false;
    _sub = _positions().listen(_onPosition, onError: (Object _) {});
    status.value = TrackingStatus.active;
  }

  /// Opens the session again after 15s, 30s, 60s, 2min, 4min, then every 5min,
  /// for as long as the route is being driven.
  void _scheduleRetry() {
    if (!_wanted) return;
    status.value = TrackingStatus.retrying;
    _retryTimer?.cancel();
    final seconds = math.min(300, 15 * (1 << math.min(_retryAttempt, 5)));
    _retryAttempt++;
    _retryTimer = Timer(Duration(seconds: seconds), () async {
      if (!_wanted || isRunning || _starting) return;
      _starting = true;
      try {
        if (await _openSession()) {
          _beginStream();
        } else {
          _scheduleRetry();
        }
      } finally {
        _starting = false;
      }
    });
  }

  /// The server rejected the session: drop the stream and try again later.
  Future<void> _suspendAndRetry() async {
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
    _token = null;
    _lastSentAt = null;
    _lastSentPosition = null;
    _scheduleRetry();
  }

  /// Stops listening and closes the session (best effort).
  Future<void> stop() async {
    _wanted = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;
    status.value = TrackingStatus.idle;
    lastPosition.value = null;
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
    final hadSession = _token != null;
    _token = null;
    _lastSentAt = null;
    _lastSentPosition = null;
    _pausedUntil = null;
    if (!hadSession) return;
    try {
      await _remote.endSession();
    } catch (_) {
      // The server expires idle sessions on its own.
    }
  }

  Future<bool> _openSession() async {
    try {
      _token = await _remote.startSession(appVersion);
      await _prefs.setInt(_seqKey, 0); // a new session starts again at 1
      return true;
    } catch (e) {
      // DRIVER_NOT_ELIGIBLE / MEMBERSHIP_AMBIGUOUS / offline: no tracking now.
      if (kDebugMode) {
        developer.log('tracking session not opened', name: 'Tracking');
      }
      _token = null;
      return false;
    }
  }

  Future<void> _onPosition(Position p) async {
    lastPosition.value = p;
    if (_token == null || _sending) return;
    final now = _now();
    if (_pausedUntil != null && now.isBefore(_pausedUntil!)) return;
    if (!_worthSending(p, now)) return;

    _sending = true;
    try {
      await _send(p, now);
    } finally {
      _sending = false;
    }
  }

  bool _worthSending(Position p, DateTime now) {
    final lastAt = _lastSentAt;
    final last = _lastSentPosition;
    if (lastAt == null || last == null) return true;
    final since = now.difference(lastAt);
    if (since < minInterval) return false;
    if (since >= heartbeat) return true;
    return _distanceMeters(last, p) >= minMeters;
  }

  Future<void> _send(Position p, DateTime now) async {
    final age = now.difference(p.timestamp).inMilliseconds / 1000.0;
    final speed = p.speed.isFinite && p.speed >= 0 ? p.speed : null;
    final heading = p.heading.isFinite && p.heading >= 0 ? p.heading : null;
    final Uint8List frame;
    try {
      frame = _encoder.encode(
        TrackingSample(
          lat: p.latitude,
          lng: p.longitude,
          speedMps: speed,
          headingDeg: heading,
          ageSec: age < 0 ? 0 : age,
        ),
      );
    } on TrackingFrameException {
      return; // a bad coordinate: skip this sample
    }

    // A new sample gets a new number, stored before the request goes out.
    final seq = (_prefs.getInt(_seqKey) ?? 0) + 1;
    await _prefs.setInt(_seqKey, seq);

    var result = await _remote.sendFrame(
      token: _token!,
      seq: seq,
      frame: frame,
    );
    if (result == TrackingSendResult.retryable) {
      // One retry, same number.
      result = await _remote.sendFrame(token: _token!, seq: seq, frame: frame);
    }

    switch (result) {
      case TrackingSendResult.ok:
        _lastSentAt = now;
        _lastSentPosition = p;
        _restartedOnce = false;
      case TrackingSendResult.sessionInvalid:
        if (_restartedOnce) {
          await _suspendAndRetry();
        } else {
          _restartedOnce = true;
          _lastSentAt = null;
          if (!await _openSession()) await _suspendAndRetry();
        }
      case TrackingSendResult.tooManyRequests:
        _pausedUntil = now.add(backoff);
      case TrackingSendResult.rejected:
      case TrackingSendResult.retryable:
        break; // dropped; the next fix replaces it
    }
  }

  static double _distanceMeters(Position a, Position b) {
    final dy = (b.latitude - a.latitude) * 111320;
    final dx =
        (b.longitude - a.longitude) *
        111320 *
        math.cos(((a.latitude + b.latitude) / 2) * math.pi / 180);
    return math.sqrt(dx * dx + dy * dy);
  }
}
