import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/domain/utils/route_fleet_utils.dart';

void main() {
  group('RouteFleetUtils.currentIndexAfterMoveToEnd', () {
    test('moving the current stop makes the next stop current', () {
      // Stops 0,1,2; current = 0; move stop 0 to the end -> stop 1 is now at 0.
      expect(
        RouteFleetUtils.currentIndexAfterMoveToEnd(
            currentIndex: 0, movedIndex: 0, stopCount: 3),
        0,
      );
      // current = 1; move stop 1 -> the old stop 2 is now at index 1.
      expect(
        RouteFleetUtils.currentIndexAfterMoveToEnd(
            currentIndex: 1, movedIndex: 1, stopCount: 3),
        1,
      );
    });

    test('moving a stop before the current one shifts the index back by 1', () {
      expect(
        RouteFleetUtils.currentIndexAfterMoveToEnd(
            currentIndex: 2, movedIndex: 0, stopCount: 4),
        1,
      );
    });

    test('moving a stop after the current one keeps the index', () {
      expect(
        RouteFleetUtils.currentIndexAfterMoveToEnd(
            currentIndex: 0, movedIndex: 2, stopCount: 3),
        0,
      );
    });

    test('moving the last stop when it is current wraps to the first stop', () {
      expect(
        RouteFleetUtils.currentIndexAfterMoveToEnd(
            currentIndex: 2, movedIndex: 2, stopCount: 3),
        0,
      );
    });
  });
}
