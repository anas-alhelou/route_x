// lib/features/orders/domain/entities/order_search_result_entity.dart
import 'package:equatable/equatable.dart';

import 'orders_today_entity.dart';

/// Which part of the driver's schedule a search looks in — the chips under
/// the search field.
enum OrderSearchScope { all, today, upcoming }

/// One order matching a search, from today's route or a later day.
class OrderSearchResultEntity extends Equatable {
  const OrderSearchResultEntity({
    required this.id,
    required this.customerName,
    required this.orderCode,
    required this.areaLabel,
    this.todayStop,
    this.dayLabel = '',
    this.isNew = false,
  });

  final String id;
  final String customerName;

  /// Printed reference without the `#`, e.g. `RX-1041`.
  final String orderCode;

  /// The address as the result row shows it: street and district for today,
  /// district only for later days, whose exact stop order is not set yet.
  final String areaLabel;

  /// Present only for an order on today's route. Carries the route number
  /// for the badge and is what the detail screen opens with.
  final TodayStopEntity? todayStop;

  /// For a later day: `Tomorrow` or a date such as `Tue 13 Oct`. Empty for
  /// today, whose label is localized by the UI.
  final String dayLabel;

  /// Dispatch added it since the driver last reviewed their schedule.
  final bool isNew;

  bool get isToday => todayStop != null;

  @override
  List<Object?> get props => [
        id,
        customerName,
        orderCode,
        areaLabel,
        todayStop,
        dayLabel,
        isNew,
      ];
}
