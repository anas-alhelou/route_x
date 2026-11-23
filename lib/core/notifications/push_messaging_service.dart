// lib/core/notifications/push_messaging_service.dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:routex_mobile/core/notifications/app_notification_payload.dart';
import 'package:routex_mobile/core/notifications/app_notification_service.dart';
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'package:routex_mobile/core/notifications/notification_texts.dart';
import 'package:routex_mobile/firebase_options.dart';

/// Push messages that arrive while the app is closed or in the background.
///
/// A data-only message is turned into the NF1 / NF2 notification here. A
/// message that already carries a `notification` block is shown by the
/// system, so it is left alone to avoid showing it twice.
@pragma('vm:entry-point')
Future<void> routexFirebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  if (message.notification != null) return;
  // This isolate starts with default settings and no language: restore what
  // the driver chose (quiet hours, sound, vibration, language) first.
  await NotificationPreferences.load(reload: true);
  await NotificationTexts.loadSavedLocale(reload: true);
  await _showFromData(message.data);
}

/// Offer data -> NF1/NF2; a `kind` -> an update notification.
Future<void> _showFromData(Map<String, dynamic> map) async {
  final offer = OfferNotificationData.fromMap(map);
  if (offer != null) {
    await AppNotificationService.instance.showOffer(offer);
    return;
  }
  final kind = map['kind']?.toString();
  if (kind == null || kind.isEmpty) return;
  await AppNotificationService.instance.showInfo(
    kind: kind,
    title: map['title']?.toString() ?? '',
    body: map['body']?.toString() ?? '',
    id: map['id']?.toString(),
  );
}

/// Wires Firebase Messaging to [AppNotificationService].
///
/// Message `data` for a new offer: `offer_id`, `orders`, `customer`, `area`,
/// `areas`, `packages`, `added_km`, `minutes`.
class PushMessagingService {
  PushMessagingService._();

  static final PushMessagingService instance = PushMessagingService._();

  final StreamController<AppNotificationTap> _taps =
      StreamController<AppNotificationTap>.broadcast();
  StreamSubscription<RemoteMessage>? _foreground;
  StreamSubscription<RemoteMessage>? _opened;
  AppNotificationTap? _launchTap;
  bool _started = false;

  /// Taps on a push notification while the app is alive.
  Stream<AppNotificationTap> get taps => _taps.stream;

  /// The tap that started the app from a closed state. Returned once.
  AppNotificationTap? takeLaunchTap() {
    final tap = _launchTap;
    _launchTap = null;
    return tap;
  }

  /// The device token the backend needs to send pushes to this driver.
  Future<String?> token() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Fires with the new device token whenever Firebase rotates it. The
  /// backend has to be told, otherwise pushes stop reaching this driver.
  /// TODO(fcmToken): upload it once the backend has an endpoint for it
  /// (Backend_MVP_Requests.md, item 4); until then it is only exposed here.
  Stream<String> get tokenRefreshes {
    try {
      return FirebaseMessaging.instance.onTokenRefresh;
    } catch (_) {
      return const Stream<String>.empty();
    }
  }

  /// Call once after Firebase is initialised. Asking the driver for the
  /// notification permission is the job of the permissions screens.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    try {
      FirebaseMessaging.onBackgroundMessage(routexFirebaseBackgroundHandler);
      _foreground = FirebaseMessaging.onMessage.listen(_onForeground);
      _opened = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          final tap = _tapFrom(message);
          if (tap != null) _taps.add(tap);
        },
      );
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _launchTap = _tapFrom(initial);
    } catch (error) {
      _started = false;
      debugPrint('Push messaging init error: $error');
    }
  }

  Future<void> _onForeground(RemoteMessage message) async {
    await _showFromData(message.data);
  }

  AppNotificationTap? _tapFrom(RemoteMessage message) {
    final kind = message.data['kind']?.toString();
    if (kind != null && kind.isNotEmpty) {
      return AppNotificationTap(type: AppNotificationType.info, kind: kind);
    }
    final offerId = message.data['offer_id']?.toString();
    if (offerId == null || offerId.isEmpty) return null;
    return AppNotificationTap(
      type: AppNotificationType.orderOffer,
      offerId: offerId,
    );
  }

  Future<void> dispose() async {
    await _foreground?.cancel();
    await _opened?.cancel();
    _started = false;
  }
}
