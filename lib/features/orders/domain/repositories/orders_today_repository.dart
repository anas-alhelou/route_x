// lib/features/orders/domain/repositories/orders_today_repository.dart
import '../entities/orders_today_snapshot.dart';

abstract class OrdersTodayRepository {
  /// The live day when the network allows, otherwise the last saved one.
  ///
  /// Throws a `NetworkFailure` only when there is no network *and* nothing
  /// has been saved yet.
  Future<OrdersTodaySnapshot> getOrdersToday();
}
