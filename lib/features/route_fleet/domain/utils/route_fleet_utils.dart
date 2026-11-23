// lib/features/route_fleet/domain/utils/route_fleet_utils.dart
class RouteFleetUtils {
  const RouteFleetUtils._();

  /// Index of the current stop after the stop at [movedIndex] was moved to the
  /// end of the route.
  ///
  /// - The current stop was moved: the stop that followed it takes its index
  ///   and becomes current. If it was the last stop there is no next one, so
  ///   the route wraps to the first stop (index 0).
  /// - A stop before the current one was moved: every stop after it shifts one
  ///   place back, so the current index decreases by 1.
  /// - A stop after the current one was moved: the current index is unchanged.
  static int currentIndexAfterMoveToEnd({
    required int currentIndex,
    required int movedIndex,
    required int stopCount,
  }) {
    if (movedIndex == currentIndex) {
      return movedIndex < stopCount - 1 ? movedIndex : 0;
    }
    if (movedIndex < currentIndex) {
      return currentIndex - 1;
    }
    return currentIndex;
  }
}
