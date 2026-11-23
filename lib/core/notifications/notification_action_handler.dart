// lib/core/notifications/notification_action_handler.dart
import 'dart:async';

import 'package:flutter/material.dart' show NavigatorState;

import 'package:flutter/foundation.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/notifications/app_notification_payload.dart';
import 'package:routex_mobile/core/notifications/app_notification_service.dart';
import 'package:routex_mobile/core/notifications/app_shell_bus.dart';
import 'package:routex_mobile/core/notifications/push_messaging_service.dart';
import 'package:routex_mobile/core/router/app_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/order_offer_usecases.dart';
import 'package:routex_mobile/features/orders/presentation/pages/offer_one_order_page.dart';

/// Sends a tap on a system notification where the Figma prototype sends it:
///
/// * NF1 notification -> OF1, Decline -> OF4, Accept -> OF5
/// * NF2 notification / View orders -> OF2
/// * R35 notification / Open / Navigate -> R10 (the Route tab, driving)
///
/// A tap that arrives before the main shell is on screen (the app was closed,
/// or the driver is still logging in) is kept and handled once it is.
class NotificationActionHandler {
  NotificationActionHandler._();

  static final NotificationActionHandler instance =
      NotificationActionHandler._();

  final List<StreamSubscription<AppNotificationTap>> _subscriptions = [];
  AppNotificationTap? _pending;
  bool _started = false;

  /// Call once at startup, after the notification services are initialised.
  void start() {
    if (_started) return;
    _started = true;
    _subscriptions
      ..add(AppNotificationService.instance.taps.listen(_receive))
      ..add(PushMessagingService.instance.taps.listen(_receive));
    final launch = AppNotificationService.instance.takeLaunchTap() ??
        PushMessagingService.instance.takeLaunchTap();
    if (launch != null) _receive(launch);
  }

  /// The main shell calls this when it appears, to run a tap that came first.
  void shellReady() {
    final pending = _pending;
    _pending = null;
    if (pending != null) unawaited(_handle(pending));
  }

  void _receive(AppNotificationTap tap) {
    if (!AppShellBus.instance.isReady) {
      _pending = tap;
      return;
    }
    unawaited(_handle(tap));
  }

  Future<void> _handle(AppNotificationTap tap) async {
    final navigator = AppRouter.router.routerDelegate.navigatorKey.currentState;
    if (navigator == null) {
      _pending = tap;
      return;
    }

    switch (tap.type) {
      case AppNotificationType.ongoingRoute:
        navigator.popUntil((route) => route.isFirst);
        AppShellBus.instance.openRoute();
      case AppNotificationType.orderOffer:
        await _openOffer(navigator, tap);
      case AppNotificationType.info:
        navigator.popUntil((route) => route.isFirst);
        switch (tap.kind) {
          case 'order_cancelled':
            AppShellBus.instance.openTab(2);
          case 'route_update' || 'vehicle_updated':
            AppShellBus.instance.openRoute();
          case 'fleet_approved':
            AppRouter.router.push(RoutersName.companyApprovedScreen);
          case 'fleet_declined':
            AppRouter.router.push(RoutersName.companyDeclinedScreen);
          default:
            AppRouter.router.push(RoutersName.notificationsScreen);
        }
    }
  }

  Future<void> _openOffer(
    NavigatorState navigator,
    AppNotificationTap tap,
  ) async {
    OrderOfferEntity? offer;
    try {
      final offers = await getIt<GetPendingOffersUseCase>()();
      for (final candidate in offers) {
        if (candidate.id == tap.offerId) offer = candidate;
      }
    } catch (error) {
      debugPrint('Could not load the offer for a notification: $error');
    }

    navigator.popUntil((route) => route.isFirst);
    if (offer == null) {
      // Answered elsewhere or ran out: the Orders tab shows what is left.
      AppShellBus.instance.openTab(2);
      return;
    }

    final intent = switch (tap.action) {
      AppNotificationAction.accept => OrderOfferIntent.accept,
      AppNotificationAction.decline => OrderOfferIntent.decline,
      _ => OrderOfferIntent.none,
    };
    await pushOrderOffer(navigator, offer, intent: intent);
  }
}
