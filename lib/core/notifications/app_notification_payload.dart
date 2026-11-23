// lib/core/notifications/app_notification_payload.dart
import 'dart:convert';

import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';

/// What a system notification is about.
enum AppNotificationType {
  /// NF1 / NF2 — one new order, or a group of them, waiting for an answer.
  orderOffer,

  /// R35 — the ongoing "On a route" notification on the lock screen.
  ongoingRoute,

  /// An update from the company or dispatch: see [AppNotificationTap.kind].
  info,
}

/// Which part of a notification the driver tapped.
enum AppNotificationAction {
  /// The notification itself (Figma: NF1 -> OF1, NF2 -> OF2, R35 -> R10).
  open,

  /// NF1 "Accept" -> OF5.
  accept,

  /// NF1 "Decline" -> OF4.
  decline,

  /// NF2 "View orders" -> OF2.
  viewOrders,

  /// R35 "Navigate" -> R10.
  navigate,
}

/// A tap on a system notification, decoded from its payload and action id.
class AppNotificationTap {
  const AppNotificationTap({
    required this.type,
    this.offerId,
    this.kind,
    this.action = AppNotificationAction.open,
  });

  /// For [AppNotificationType.info]: `order_cancelled`, `route_update`,
  /// `vehicle_updated`, `fleet_approved`, `fleet_declined` or
  /// `dispatch_message`.
  final String? kind;

  final AppNotificationType type;

  /// The offer a [AppNotificationType.orderOffer] notification is about.
  final String? offerId;
  final AppNotificationAction action;

  /// Action ids used on the notification buttons.
  static const String acceptId = 'accept';
  static const String declineId = 'decline';
  static const String viewOrdersId = 'view_orders';
  static const String openId = 'open';
  static const String navigateId = 'navigate';

  /// The payload stored on the notification.
  String encode() => jsonEncode(<String, Object?>{
        'type': type.name,
        if (offerId != null) 'offerId': offerId,
        if (kind != null) 'kind': kind,
      });

  /// Null when the payload is missing or is not one of ours.
  static AppNotificationTap? fromResponse({
    required String? payload,
    String? actionId,
  }) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      AppNotificationType? type;
      for (final candidate in AppNotificationType.values) {
        if (candidate.name == decoded['type']) type = candidate;
      }
      if (type == null) return null;
      final offerId = decoded['offerId'];
      return AppNotificationTap(
        type: type,
        offerId: offerId is String ? offerId : null,
        kind: decoded['kind'] is String ? decoded['kind'] as String : null,
        action: _actionFor(actionId),
      );
    } catch (_) {
      return null;
    }
  }

  static AppNotificationAction _actionFor(String? id) => switch (id) {
        acceptId => AppNotificationAction.accept,
        declineId => AppNotificationAction.decline,
        viewOrdersId => AppNotificationAction.viewOrders,
        navigateId => AppNotificationAction.navigate,
        _ => AppNotificationAction.open,
      };
}

/// Everything the NF1 / NF2 notification prints. Built from an offer, or
/// from the `data` of a push message so it can be shown without the app
/// having loaded the offer first.
class OfferNotificationData {
  const OfferNotificationData({
    required this.offerId,
    required this.orderCount,
    required this.customerName,
    required this.area,
    required this.areas,
    required this.packages,
    required this.addedKm,
    required this.answerMinutes,
  });

  final String offerId;
  final int orderCount;

  /// The first order's customer and district (the single-order title).
  final String customerName;
  final String area;

  /// Districts of a group, comma separated.
  final String areas;
  final int packages;

  /// Extra kilometres the offer adds to the route.
  final double addedKm;
  final int answerMinutes;

  bool get isGroup => orderCount > 1;

  factory OfferNotificationData.fromOffer(OrderOfferEntity offer) {
    final first = offer.orders.first;
    return OfferNotificationData(
      offerId: offer.id,
      orderCount: offer.orders.length,
      customerName: first.customerName,
      area: first.area,
      areas: offer.orders.map((o) => o.area).toSet().join(', '),
      packages: offer.orders.fold<int>(0, (sum, o) => sum + o.packagesCount),
      addedKm: offer.orders.fold<double>(0, (sum, o) => sum + o.addedKm),
      answerMinutes: offer.answerWindow.inMinutes,
    );
  }

  /// The `data` map of a push message:
  /// `offer_id`, `orders`, `customer`, `area`, `areas`, `packages`,
  /// `added_km`, `minutes`. Null when it is not an offer message.
  static OfferNotificationData? fromMap(Map<String, dynamic> data) {
    final offerId = data['offer_id']?.toString();
    if (offerId == null || offerId.isEmpty) return null;
    final area = data['area']?.toString() ?? '';
    return OfferNotificationData(
      offerId: offerId,
      orderCount: int.tryParse('${data['orders'] ?? 1}') ?? 1,
      customerName: data['customer']?.toString() ?? '',
      area: area,
      areas: data['areas']?.toString() ?? area,
      packages: int.tryParse('${data['packages'] ?? 1}') ?? 1,
      addedKm: double.tryParse('${data['added_km'] ?? 0}') ?? 0,
      answerMinutes: int.tryParse('${data['minutes'] ?? 10}') ?? 10,
    );
  }
}

/// What the R35 "On a route" notification prints.
class OngoingRouteNotificationData {
  const OngoingRouteNotificationData({
    required this.stopNumber,
    required this.totalStops,
    required this.customerName,
    required this.address,
    required this.minutes,
    required this.arriveAt,
  });

  /// 1-based number of the stop the driver is heading to.
  final int stopNumber;
  final int totalStops;
  final String customerName;
  final String address;
  final int minutes;

  /// `10:24`.
  final String arriveAt;
}
