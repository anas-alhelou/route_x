import '../entities/order_history_entity.dart';
import '../entities/order_history_snapshot.dart';

abstract class OrderHistoryRepository {
  /// The live history when the server answers; otherwise the last copy
  /// saved for [period]. Throws a `NetworkFailure` when there is neither.
  Future<OrderHistorySnapshot> getHistory(HistoryPeriod period);
}
