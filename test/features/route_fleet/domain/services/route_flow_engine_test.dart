// test/features/route_fleet/domain/services/route_flow_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/route_stop.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/stop_status.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/proof_of_delivery.dart';
import 'package:routex_mobile/features/route_fleet/domain/services/route_flow_engine.dart';

void main() {
  group('RouteFlowEngine', () {
    late List<RouteStop> testStops;
    late RouteFlowEngine engine;

    setUp(() {
      testStops = [
        const RouteStop(
          id: 'stop-1',
          title: 'Omar Haddad',
          address: 'Sari St',
          eta: '10:05',
          isCompleted: false,
          status: 'Pending',
        ),
        const RouteStop(
          id: 'stop-2',
          title: 'Lina Fares',
          address: 'Tahlia St',
          eta: '10:24',
          isCompleted: false,
          status: 'Pending',
        ),
        const RouteStop(
          id: 'stop-3',
          title: 'Ahmed Ali',
          address: 'Prince Sultan St',
          eta: '10:41',
          isCompleted: false,
          status: 'Pending',
        ),
      ];
      engine = RouteFlowEngine(stops: testStops);
    });

    test('break lifecycle works correctly only while driving or approaching', () {
      engine.startBreak();
      expect(engine.phase, RouteFlowPhase.ready);
      expect(engine.isOnBreak, isFalse);

      engine.startRoute();
      expect(engine.phase, RouteFlowPhase.driving);

      engine.startBreak();
      expect(engine.phase, RouteFlowPhase.onBreak);
      expect(engine.isOnBreak, isTrue);
      expect(engine.allowedBreakMinutes, 15);

      engine.extendBreak(5);
      expect(engine.allowedBreakMinutes, 20);

      engine.resumeBreak();
      expect(engine.phase, RouteFlowPhase.driving);
      expect(engine.isOnBreak, isFalse);
    });

    test('moveStopToEnd reorders stops, updates currentIndex, and resets arrived phase to driving', () {
      engine.startRoute();
      engine.arrive();
      expect(engine.phase, RouteFlowPhase.arrived);
      expect(engine.currentIndex, 0);

      engine.moveStopToEnd(0);
      expect(engine.phase, RouteFlowPhase.driving);
      expect(engine.currentIndex, 0);
      expect(engine.stops.last.title, 'Omar Haddad');

      engine.undoLast();
      expect(engine.stops.first.title, 'Omar Haddad');
    });

    test('initial state is ready with stop 0 current', () {
      expect(engine.phase, RouteFlowPhase.ready);
      expect(engine.currentIndex, 0);
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.current);
      expect(engine.stopStatuses['stop-2'], StopDeliveryStatus.upcoming);
      expect(engine.stopStatuses['stop-3'], StopDeliveryStatus.upcoming);
    });

    test('startRoute transitions to driving', () {
      engine.startRoute();
      expect(engine.phase, RouteFlowPhase.driving);
      expect(engine.currentIndex, 0);
    });

    test('full delivery flow across stops leads to complete', () {
      engine.startRoute();
      
      // Stop 1
      engine.approach();
      expect(engine.phase, RouteFlowPhase.approaching);
      
      engine.arrive();
      expect(engine.phase, RouteFlowPhase.arrived);
      
      engine.startDelivery();
      expect(engine.phase, RouteFlowPhase.delivering);
      
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'Omar'));
      expect(engine.phase, RouteFlowPhase.deliveredToast);
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.delivered);
      
      engine.advanceToNextStop();
      expect(engine.phase, RouteFlowPhase.driving);
      expect(engine.currentIndex, 1);
      expect(engine.stopStatuses['stop-2'], StopDeliveryStatus.current);

      // Stop 2
      engine.arrive();
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'Lina'));
      engine.advanceToNextStop();
      expect(engine.currentIndex, 2);

      // Stop 3 (last)
      engine.arrive();
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'Ahmed'));
      expect(engine.phase, RouteFlowPhase.complete);
      expect(engine.stopStatuses['stop-3'], StopDeliveryStatus.delivered);
    });

    test('failStop stores reason and advances to next current stop', () {
      engine.startRoute();
      engine.arrive();
      
      engine.failStop('CUSTOMER_NOT_ANSWERING', 'Customer not answering');
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.failed);
      expect(engine.failureReasons['stop-1'], 'Customer not answering');
      expect(engine.currentIndex, 1);
      expect(engine.stopStatuses['stop-2'], StopDeliveryStatus.current);
      expect(engine.phase, RouteFlowPhase.driving);
    });

    test('failing the last stop completes the route', () {
      engine.startRoute();
      // Deliver stop 1
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'Omar'));
      engine.advanceToNextStop();
      // Deliver stop 2
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'Lina'));
      engine.advanceToNextStop();
      expect(engine.currentIndex, 2);

      // Fail stop 3 (last)
      engine.failStop('WRONG_ADDRESS', 'Wrong address');
      expect(engine.phase, RouteFlowPhase.complete);
      expect(engine.stopStatuses['stop-3'], StopDeliveryStatus.failed);
      expect(engine.failureReasons['stop-3'], 'Wrong address');
    });

    test('endRoute marks all remaining non-delivered stops as failed/returned', () {
      engine.startRoute();
      // Deliver stop 1
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'Omar'));
      engine.advanceToNextStop();
      expect(engine.currentIndex, 1);

      // End route early
      engine.endRoute(reasonCode: 'returned_by_end_route', reasonText: 'Returned by end route');
      expect(engine.phase, RouteFlowPhase.complete);
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.delivered);
      expect(engine.stopStatuses['stop-2'], StopDeliveryStatus.failed);
      expect(engine.stopStatuses['stop-3'], StopDeliveryStatus.failed);
      expect(engine.failureReasons['stop-2'], 'Returned by end route');
      expect(engine.failureReasons['stop-3'], 'Returned by end route');
    });

    test('undo after a delivery reverts user action', () {
      engine.startRoute();
      engine.arrive();
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'Omar'));
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.delivered);

      final success = engine.undoLast();
      expect(success, true);
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.current);
      expect(engine.phase, RouteFlowPhase.arrived);
    });

    test('undo after a failure reverts user action', () {
      engine.startRoute();
      engine.arrive();
      engine.failStop('NO_ANSWER', 'Customer not answering');
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.failed);
      expect(engine.currentIndex, 1);

      final success = engine.undoLast();
      expect(success, true);
      expect(engine.stopStatuses['stop-1'], StopDeliveryStatus.current);
      expect(engine.currentIndex, 0);
      expect(engine.phase, RouteFlowPhase.arrived);
      expect(engine.failureReasons.containsKey('stop-1'), false);
    });

    test('generic delivery rule for 2, 3, and 5 stops (toast vs straight to last stop)', () {
      // 3 stops test
      engine.startRoute();
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'C1'));
      expect(engine.phase, RouteFlowPhase.deliveredToast); // Stop 1 -> toast

      engine.advanceToNextStop();
      expect(engine.currentIndex, 1);
      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'C2'));
      expect(engine.phase, RouteFlowPhase.driving); // Stop 2 -> next is last stop -> straight to driving (no toast)
      expect(engine.currentIndex, 2);

      engine.completeDelivery(const ProofOfDeliveryData(signerName: 'C3'));
      expect(engine.phase, RouteFlowPhase.complete); // Stop 3 -> complete

      // 5 stops test
      final stops5 = List.generate(5, (i) => RouteStop(
            id: 'stop-${i + 1}',
            title: 'Cust ${i + 1}',
            address: 'Addr ${i + 1}',
            eta: '10:0$i',
            isCompleted: false,
            status: 'Pending',
          ));
      final engine5 = RouteFlowEngine(stops: stops5);
      engine5.startRoute();

      // Stop 1 -> toast
      engine5.completeDelivery(const ProofOfDeliveryData(signerName: '5C1'));
      expect(engine5.phase, RouteFlowPhase.deliveredToast);
      engine5.advanceToNextStop();

      // Stop 2 -> toast
      engine5.completeDelivery(const ProofOfDeliveryData(signerName: '5C2'));
      expect(engine5.phase, RouteFlowPhase.deliveredToast);
      engine5.advanceToNextStop();

      // Stop 3 -> toast
      engine5.completeDelivery(const ProofOfDeliveryData(signerName: '5C3'));
      expect(engine5.phase, RouteFlowPhase.deliveredToast);
      engine5.advanceToNextStop();

      // Stop 4 -> next is stop 5 (last) -> straight to driving (no toast)
      engine5.completeDelivery(const ProofOfDeliveryData(signerName: '5C4'));
      expect(engine5.phase, RouteFlowPhase.driving);
      expect(engine5.currentIndex, 4);

      // Stop 5 -> complete
      engine5.completeDelivery(const ProofOfDeliveryData(signerName: '5C5'));
      expect(engine5.phase, RouteFlowPhase.complete);
    });
  });

  group('SimulatedArrivalSource', () {
    test('emits approaching and arrived events with delays', () async {
      final source = SimulatedArrivalSource(
        approachDelay: const Duration(milliseconds: 50),
        arrivalDelay: const Duration(milliseconds: 100),
      );

      final events = <ArrivalEventType>[];
      await for (final event in source.arrivalStream) {
        events.add(event.type);
      }

      expect(events, [ArrivalEventType.approaching, ArrivalEventType.arrived]);
    });
  });
}
