// lib/core/notifications/app_notification_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:routex_mobile/core/notifications/app_notification_payload.dart';
import 'package:routex_mobile/core/notifications/notification_inbox_store.dart';
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:routex_mobile/core/notifications/notification_texts.dart';

/// Runs when an action is tapped while the app is not running.
///
/// Every action opens the app (`showsUserInterface`), so the tap reaches
/// [AppNotificationService.taps] through the launch details instead.
@pragma('vm:entry-point')
void appNotificationTapBackground(NotificationResponse response) {}

/// The notifications RouteX puts on the lock screen and in the shade.
///
/// * NF1 — one new order, with Decline and Accept.
/// * NF2 — a group of new orders, with View orders.
/// * R35 — the ongoing "On a route" notification, with Open and Navigate.
class AppNotificationService {
  AppNotificationService._();

  static final AppNotificationService instance = AppNotificationService._();

  static const String _offerChannelId = 'new_orders';
  static const String _routeChannelId = 'ongoing_route';
  static const String _updatesChannelId = 'updates';
  static const int _routeNotificationId = 4001;
  static const String _iosOfferCategory = 'offer_single';
  static const String _iosGroupCategory = 'offer_group';
  static const String _iosRouteCategory = 'ongoing_route';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<AppNotificationTap> _taps =
      StreamController<AppNotificationTap>.broadcast();

  bool _initialized = false;
  AppNotificationTap? _launchTap;

  /// Taps on a notification or one of its buttons while the app is alive.
  Stream<AppNotificationTap> get taps => _taps.stream;

  /// The tap that started the app from a closed state. Returned once.
  AppNotificationTap? takeLaunchTap() {
    final tap = _launchTap;
    _launchTap = null;
    return tap;
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final l10n = NotificationTexts.l10n;
      const foreground = <DarwinNotificationActionOption>{
        DarwinNotificationActionOption.foreground,
      };
      final settings = InitializationSettings(
        android: const AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: <DarwinNotificationCategory>[
            DarwinNotificationCategory(
              _iosOfferCategory,
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain(
                  AppNotificationTap.declineId,
                  l10n.orderOfferNotificationDecline,
                  options: foreground,
                ),
                DarwinNotificationAction.plain(
                  AppNotificationTap.acceptId,
                  l10n.orderOfferNotificationAccept,
                  options: foreground,
                ),
              ],
            ),
            DarwinNotificationCategory(
              _iosGroupCategory,
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain(
                  AppNotificationTap.viewOrdersId,
                  l10n.orderOfferNotificationViewOrders,
                  options: foreground,
                ),
              ],
            ),
            DarwinNotificationCategory(
              _iosRouteCategory,
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain(
                  AppNotificationTap.openId,
                  l10n.routeOngoingNotificationOpen,
                  options: foreground,
                ),
                DarwinNotificationAction.plain(
                  AppNotificationTap.navigateId,
                  l10n.routeOngoingNotificationNavigate,
                  options: foreground,
                ),
              ],
            ),
          ],
        ),
      );
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onResponse,
        onDidReceiveBackgroundNotificationResponse:
            appNotificationTapBackground,
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          _offerChannelId,
          l10n.notificationChannelOffers,
          description: l10n.notificationChannelOffersDesc,
          importance: Importance.max,
        ),
      );
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          _updatesChannelId,
          l10n.notificationChannelUpdates,
          description: l10n.notificationChannelUpdatesDesc,
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          _routeChannelId,
          l10n.notificationChannelRoute,
          description: l10n.notificationChannelRouteDesc,
          importance: Importance.low,
        ),
      );

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        final response = launch!.notificationResponse;
        _launchTap = AppNotificationTap.fromResponse(
          payload: response?.payload,
          actionId: response?.actionId,
        );
      }
    } catch (error) {
      _initialized = false;
      debugPrint('Notification service init error: $error');
    }
  }

  void _onResponse(NotificationResponse response) {
    final tap = AppNotificationTap.fromResponse(
      payload: response.payload,
      actionId: response.actionId,
    );
    if (tap != null) _taps.add(tap);
  }

  int _offerNotificationId(String offerId) => offerId.hashCode & 0x7fffffff;

  /// NF1 (one order) or NF2 (a group) — [data] decides which.
  Future<void> showOffer(OfferNotificationData data) async {
    if (!NotificationPreferences.enabled ||
        !NotificationPreferences.newRoutes) {
      return;
    }
    await init();
    final l10n = NotificationTexts.l10n;
    final distance = l10n.offerKmDelta(data.addedKm.toStringAsFixed(1));
    final deadline = l10n.notificationMinutes(data.answerMinutes);

    final title = data.isGroup
        ? l10n.orderOfferNotificationGroupTitle(data.orderCount)
        : l10n.orderOfferNotificationSingleTitle(data.customerName, data.area);
    NotificationInboxStore.instance.add(
      id: 'offer-${data.offerId}',
      title: title,
      body: data.isGroup ? data.areas : '${data.packages}',
      kind: AppNotificationKind.newOrder,
    );
    final body = data.isGroup
        ? l10n.orderOfferNotificationGroupDetails(
            data.areas,
            distance,
            deadline,
          )
        : l10n.orderOfferNotificationDetails(data.packages, distance, deadline);

    final actions = data.isGroup
        ? <AndroidNotificationAction>[
            AndroidNotificationAction(
              AppNotificationTap.viewOrdersId,
              l10n.orderOfferNotificationViewOrders,
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ]
        : <AndroidNotificationAction>[
            AndroidNotificationAction(
              AppNotificationTap.declineId,
              l10n.orderOfferNotificationDecline,
              showsUserInterface: true,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              AppNotificationTap.acceptId,
              l10n.orderOfferNotificationAccept,
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ];

    await _plugin.show(
      _offerNotificationId(data.offerId),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _offerChannelId,
          l10n.notificationChannelOffers,
          channelDescription: l10n.notificationChannelOffersDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: NotificationPreferences.playSound,
          enableVibration: NotificationPreferences.vibration,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.message,
          styleInformation: BigTextStyleInformation(body),
          timeoutAfter: data.answerMinutes * Duration.millisecondsPerMinute,
          actions: actions,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: NotificationPreferences.playSound,
          categoryIdentifier:
              data.isGroup ? _iosGroupCategory : _iosOfferCategory,
        ),
      ),
      payload: AppNotificationTap(
        type: AppNotificationType.orderOffer,
        offerId: data.offerId,
      ).encode(),
    );
  }

  static AppNotificationKind _inboxKind(String kind) => switch (kind) {
        'order_cancelled' => AppNotificationKind.orderCancelled,
        'route_update' => AppNotificationKind.routeUpdate,
        'vehicle_updated' => AppNotificationKind.vehicleUpdated,
        'fleet_approved' => AppNotificationKind.fleetApproved,
        'dispatch_message' => AppNotificationKind.dispatchMessage,
        _ => AppNotificationKind.system,
      };

  static bool _allowed(String kind) {
    if (!NotificationPreferences.enabled) return false;
    return switch (kind) {
      'order_cancelled' => NotificationPreferences.orderChanges,
      'route_update' || 'vehicle_updated' => NotificationPreferences.newRoutes,
      'dispatch_message' => NotificationPreferences.dispatch,
      _ => true,
    };
  }

  /// Order cancelled, route or vehicle changed, company decision, dispatch
  /// message. The text comes from the message itself; it is also kept in the
  /// Notifications inbox.
  Future<void> showInfo({
    required String kind,
    required String title,
    required String body,
    String? id,
  }) async {
    final key = id ?? '$kind-${DateTime.now().millisecondsSinceEpoch}';
    NotificationInboxStore.instance
        .add(id: key, title: title, body: body, kind: _inboxKind(kind));
    if (!_allowed(kind)) return;
    await init();
    final l10n = NotificationTexts.l10n;
    await _plugin.show(
      key.hashCode & 0x7fffffff,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _updatesChannelId,
          l10n.notificationChannelUpdates,
          channelDescription: l10n.notificationChannelUpdatesDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: NotificationPreferences.playSound,
          enableVibration: NotificationPreferences.vibration,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: NotificationPreferences.playSound,
        ),
      ),
      payload: AppNotificationTap(
        type: AppNotificationType.info,
        kind: kind,
      ).encode(),
    );
  }

  /// The offer was answered or ran out: take its notification away.
  Future<void> cancelOffer(String offerId) async {
    try {
      await _plugin.cancel(_offerNotificationId(offerId));
    } catch (_) {}
  }

  /// R35 — shown while a route runs, updated at every stop.
  Future<void> showOngoingRoute(OngoingRouteNotificationData data) async {
    if (!NotificationPreferences.enabled) return;
    await init();
    final l10n = NotificationTexts.l10n;
    final title = l10n.routeOngoingNotificationTitle(
      data.stopNumber,
      data.totalStops,
      data.customerName,
    );
    final body = l10n.routeOngoingNotificationBody(
      data.address,
      data.minutes,
      data.arriveAt,
    );

    await _plugin.show(
      _routeNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _routeChannelId,
          l10n.notificationChannelRoute,
          channelDescription: l10n.notificationChannelRouteDesc,
          importance: Importance.low,
          priority: Priority.low,
          visibility: NotificationVisibility.public,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: data.totalStops,
          // Stops already done: the bar fills one segment per stop.
          progress: (data.stopNumber - 1).clamp(0, data.totalStops).toInt(),
          styleInformation: BigTextStyleInformation(body),
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              AppNotificationTap.openId,
              l10n.routeOngoingNotificationOpen,
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              AppNotificationTap.navigateId,
              l10n.routeOngoingNotificationNavigate,
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: false,
          presentSound: false,
          categoryIdentifier: _iosRouteCategory,
        ),
      ),
      payload: const AppNotificationTap(
        type: AppNotificationType.ongoingRoute,
      ).encode(),
    );
  }

  Future<void> cancelOngoingRoute() async {
    try {
      await _plugin.cancel(_routeNotificationId);
    } catch (_) {}
  }
}
