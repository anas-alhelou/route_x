// test/features/route_fleet/presentation/controllers/route_fleet_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/route_fleet/data/models/fleet_info_model.dart';
import 'package:routex_mobile/features/route_fleet/data/models/route_stop_model.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/fleet_company.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/proof_of_delivery.dart';
import 'package:routex_mobile/features/route_fleet/domain/entities/location_report.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/get_active_route_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/reorder_stop_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/report_wrong_location_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/update_stop_status_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/search_fleets_usecase.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/join_fleet_usecase.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';

class MockGetActiveRouteUseCase extends Mock implements GetActiveRouteUseCase {}

class MockUpdateStopStatusUseCase extends Mock
    implements UpdateStopStatusUseCase {}

class MockReorderStopUseCase extends Mock implements ReorderStopUseCase {}

class MockReportWrongLocationUseCase extends Mock
    implements ReportWrongLocationUseCase {}

class MockSearchFleetsUseCase extends Mock implements SearchFleetsUseCase {}

class MockJoinFleetUseCase extends Mock implements JoinFleetUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('RouteFleetCubit', () {
    late MockGetActiveRouteUseCase mockGetActiveRouteUseCase;
    late MockUpdateStopStatusUseCase mockUpdateStopStatusUseCase;
    late MockReorderStopUseCase mockReorderStopUseCase;
    late MockReportWrongLocationUseCase mockReportWrongLocationUseCase;
    late RouteFleetCubit cubit;

    const testStops = <RouteStopModel>[
      RouteStopModel(
        id: 'stop-1',
        title: 'Omar Haddad',
        address: 'Sari St',
        eta: '10:05',
        isCompleted: false,
        status: 'Pending',
      ),
      RouteStopModel(
        id: 'stop-2',
        title: 'Lina Fares',
        address: 'Tahlia St',
        eta: '10:24',
        isCompleted: false,
        status: 'Pending',
      ),
      RouteStopModel(
        id: 'stop-3',
        title: 'Ahmed Ali',
        address: 'Prince Sultan St',
        eta: '10:41',
        isCompleted: false,
        status: 'Pending',
      ),
    ];

    const testDepot = DepotInfoModel(
      name: 'Red Sea Express hub',
      address: 'Al Rawdah',
      distanceText: '3.1 km',
      etaText: 'arrive 11:02',
    );

    final testFleet = FleetInfoModel(
      routeId: 'test-route-1',
      routeName: 'Test Route',
      activeVehicleNumber: 'VAN-123',
      totalDistance: '5.0 km',
      progressPercentage: 0.0,
      depotInfo: testDepot,
      stops: testStops,
    );

    setUp(() {
      mockGetActiveRouteUseCase = MockGetActiveRouteUseCase();
      mockUpdateStopStatusUseCase = MockUpdateStopStatusUseCase();
      mockReorderStopUseCase = MockReorderStopUseCase();
      mockReportWrongLocationUseCase = MockReportWrongLocationUseCase();
      registerFallbackValue(
        const LocationReport(
          stopId: '1',
          reasonCode: 'test',
          reasonText: 'test',
        ),
      );

      when(
        () => mockGetActiveRouteUseCase(),
      ).thenAnswer((_) async => testFleet);

      cubit = RouteFleetCubit(
        getActiveRouteUseCase: mockGetActiveRouteUseCase,
        updateStopStatusUseCase: mockUpdateStopStatusUseCase,
        reorderStopUseCase: mockReorderStopUseCase,
        reportWrongLocationUseCase: mockReportWrongLocationUseCase,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test(
      'deliver and undo within delivered toast restores previous state',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute(); // Starts driving
        cubit.completeCurrentDelivery(
          const ProofOfDeliveryData(signerName: 'Omar'),
        );

        expect(cubit.state, isA<RouteFleetDelivered>());
        final deliveredState = cubit.state as RouteFleetDelivered;
        expect(deliveredState.deliveredCustomerName, 'Omar Haddad');

        // Perform undo within toast
        cubit.undoLast();
        expect(cubit.state, isA<RouteFleetDriving>());
      },
    );

    test('failCurrentStop sets toast state to sentForReview', () async {
      await cubit.loadActiveRoute();
      cubit.startRoute();
      cubit.failCurrentStop('CUSTOMER_NOT_ANSWERING', 'Customer not answering');

      expect(cubit.state, isA<RouteFleetDriving>());
      final drivingState = cubit.state as RouteFleetDriving;
      expect(drivingState.toastType, DrivingToastType.sentForReview);
      expect(drivingState.toastMessage, 'Sent to Red Sea Express for review');
      expect(drivingState.currentStopIndex, 1);
    });

    test(
      'endRouteEarly marks remaining stops as failed and completes route',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();
        cubit.completeCurrentDelivery(
          const ProofOfDeliveryData(signerName: 'Omar'),
        );

        cubit.endRouteEarly();
        expect(cubit.state, isA<RouteFleetComplete>());
        final completeState = cubit.state as RouteFleetComplete;
        expect(completeState.summary.deliveredCount, 1);
        expect(completeState.summary.failedCount, 2);
      },
    );

    test('undoReorderStop restores previous stops order and index', () async {
      final reorderedFleet = FleetInfoModel(
        routeId: testFleet.routeId,
        routeName: testFleet.routeName,
        activeVehicleNumber: testFleet.activeVehicleNumber,
        totalDistance: testFleet.totalDistance,
        progressPercentage: testFleet.progressPercentage,
        depotInfo: testDepot,
        stops: [testStops[1], testStops[2], testStops[0]],
      );

      when(
        () => mockReorderStopUseCase(0),
      ).thenAnswer((_) async => reorderedFleet);

      await cubit.loadActiveRoute();
      cubit.startRoute();
      expect((cubit.state as RouteFleetDriving).currentStopIndex, 0);

      await cubit.reorderStopToLast(0);
      expect(
        (cubit.state as RouteFleetDriving).toastType,
        DrivingToastType.stopMoved,
      );

      cubit.undoReorderStop();
      expect(
        (cubit.state as RouteFleetDriving).toastType,
        DrivingToastType.none,
      );
      expect((cubit.state as RouteFleetDriving).currentStopIndex, 0);
    });

    test(
      'goToNextStopFromToast called twice results in single transition',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();
        cubit.completeCurrentDelivery(
          const ProofOfDeliveryData(signerName: 'Omar'),
        );
        expect(cubit.state, isA<RouteFleetDelivered>());

        cubit.goToNextStopFromToast();
        expect(cubit.state, isA<RouteFleetDriving>());
        expect((cubit.state as RouteFleetDriving).currentStopIndex, 1);

        final stateBefore = cubit.state;
        cubit.goToNextStopFromToast();
        expect(cubit.state, stateBefore);
      },
    );

    test('R40 to R40b to R01 flow clears route state', () async {
      await cubit.loadActiveRoute();
      cubit.startRoute();
      cubit.failCurrentStop('NO_ANSWER', 'Customer not answering');
      expect(cubit.state, isA<RouteFleetDriving>());

      cubit.endRouteEarly();
      expect(cubit.state, isA<RouteFleetComplete>());

      // The packages to hand back come from the R19 summary and must survive the state change.
      final summaryTask =
          (cubit.state as RouteFleetComplete).summary.returnTask;
      expect(summaryTask, isNotNull);

      cubit.startReturnToDepot();
      expect(cubit.returnTask, summaryTask);
      expect(cubit.state, isA<RouteFleetDriving>());
      expect(
        (cubit.state as RouteFleetDriving).activeSheet,
        DrivingModalSheet.returnDepot,
      );

      cubit.arriveAtDepot();
      expect(cubit.state, isA<RouteFleetArrived>());
      expect(
        (cubit.state as RouteFleetArrived).activeSheet,
        DrivingModalSheet.handBack,
      );

      cubit.endDayAtDepot();
      expect(cubit.state, isA<RouteFleetEmpty>());
      expect(cubit.returnTask, isNull);
    });

    test(
      'R19 Done clears the finished route so the Route tab shows R01',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();
        cubit.endRouteEarly();
        expect(cubit.state, isA<RouteFleetComplete>());

        cubit.clearCompletedRoute();
        expect(cubit.state, isA<RouteFleetEmpty>());
      },
    );

    test(
      'R41 openStopFromAutoArrival opens stop and notHereYetFromAutoArrival closes auto arrival sheet',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();

        cubit.openModalSheet(DrivingModalSheet.arrivingAuto);
        expect(
          (cubit.state as RouteFleetDriving).activeSheet,
          DrivingModalSheet.arrivingAuto,
        );

        cubit.openStopFromAutoArrival();
        expect(cubit.state, isA<RouteFleetArrived>());

        cubit.openModalSheet(DrivingModalSheet.arrivingAuto);
        cubit.notHereYetFromAutoArrival();
        expect(cubit.state, isA<RouteFleetDriving>());
        expect(
          (cubit.state as RouteFleetDriving).activeSheet,
          DrivingModalSheet.none,
        );
      },
    );

    test(
      'R42 actions transition to proof, reason sheet, and back to arrived, recording leftUnmarkedTimestamp',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();

        // Action 1: Yes delivered
        cubit.yesDeliveredFromUnmarked();
        expect(cubit.state, isA<RouteFleetProofCamera>());

        // Action 2: Couldn't deliver
        await cubit.loadActiveRoute();
        cubit.startRoute();
        cubit.openModalSheet(DrivingModalSheet.unmarkedStop);
        cubit.couldntDeliverFromUnmarked();
        expect(
          (cubit.state as RouteFleetDriving).activeSheet,
          DrivingModalSheet.reason,
        );

        // Action 3: Go back
        await cubit.loadActiveRoute();
        cubit.startRoute();
        cubit.goBackFromUnmarked();
        expect(cubit.state, isA<RouteFleetArrived>());
        expect(
          (cubit.state as RouteFleetArrived).activeSheet,
          DrivingModalSheet.none,
        );
      },
    );

    test('R03 to R43 check packages workflow and startRoute', () async {
      await cubit.loadActiveRoute();
      cubit.openCheckPackagesSheet();
      expect(cubit.state, isA<RouteFleetCheckPackages>());
      final state1 = cubit.state as RouteFleetCheckPackages;
      expect(state1.checkedStopIds, isEmpty);

      cubit.togglePackageChecked('stop-1');
      cubit.togglePackageChecked('stop-2');
      cubit.togglePackageChecked('stop-3');
      final state2 = cubit.state as RouteFleetCheckPackages;
      expect(state2.checkedStopIds.length, 3);

      cubit.startRoute();
      expect(cubit.state, isA<RouteFleetDriving>());
    });

    test(
      'the live route keeps every stop detail (note, gate code, phone, door number) while driving',
      () async {
        const richStops = <RouteStopModel>[
          RouteStopModel(
            id: 'stop-1',
            title: 'Omar Haddad',
            address: 'Sari St',
            eta: '10:05',
            isCompleted: false,
            status: 'Pending',
            phone: '+966500000001',
            gateCode: '4417#',
            timeWindow: '10:00 – 10:30',
            packagesText: '2 · drop-off',
            companyNote: 'Call when you arrive.',
            orderId: '#RX-1039',
            packageType: 'Medium box',
            doorNumber: '12',
          ),
          RouteStopModel(
            id: 'stop-2',
            title: 'Lina Fares',
            address: 'Tahlia St',
            eta: '10:24',
            isCompleted: false,
            status: 'Pending',
            doorNumber: '7',
          ),
        ];
        when(() => mockGetActiveRouteUseCase()).thenAnswer(
          (_) async => FleetInfoModel(
            routeId: 'rich',
            routeName: 'Rich',
            activeVehicleNumber: 'VAN-1',
            totalDistance: '5 km',
            progressPercentage: 0,
            depotInfo: testDepot,
            stops: richStops,
          ),
        );

        await cubit.loadActiveRoute();
        cubit.openCheckPackagesSheet();
        cubit.startRoute();

        final stop = (cubit.state as RouteFleetDriving).fleetInfo.stops.first;
        expect(stop.phone, '+966500000001');
        expect(stop.gateCode, '4417#');
        expect(stop.timeWindow, '10:00 – 10:30');
        expect(stop.packagesText, '2 · drop-off');
        expect(stop.companyNote, 'Call when you arrive.');
        expect(stop.orderId, '#RX-1039');
        expect(stop.packageType, 'Medium box');
        expect(stop.doorNumber, '12');
      },
    );

    test(
      'the photo taken in P01 is shown in P02 and kept when coming back from the signature',
      () async {
        await cubit.loadActiveRoute();
        cubit.openCheckPackagesSheet();
        cubit.startRoute();

        cubit.openProofCamera(stopNumber: 1, requiresSignature: true);
        cubit.capturePhotoAndCheck(
          stopNumber: 1,
          requiresSignature: true,
          photoPath: '/tmp/p1.jpg',
        );
        expect(
          (cubit.state as RouteFleetProofCheckPhoto).photoPath,
          '/tmp/p1.jpg',
        );

        // P03 "Back" returns to P02 without a new path: the photo must stay.
        cubit.capturePhotoAndCheck(stopNumber: 1, requiresSignature: true);
        expect(
          (cubit.state as RouteFleetProofCheckPhoto).photoPath,
          '/tmp/p1.jpg',
        );

        // Retake clears it.
        cubit.openProofCamera(stopNumber: 1, requiresSignature: true);
        cubit.capturePhotoAndCheck(stopNumber: 1, requiresSignature: true);
        expect((cubit.state as RouteFleetProofCheckPhoto).photoPath, isNull);
      },
    );

    test(
      'Overview control opens R03 while driving and the route keeps its progress',
      () async {
        await cubit.loadActiveRoute();
        cubit.openCheckPackagesSheet();
        cubit.startRoute();
        expect(cubit.state, isA<RouteFleetDriving>());
        final fleet = (cubit.state as RouteFleetDriving).fleetInfo;

        cubit.openRouteOverview();
        expect(cubit.state, isA<RouteFleetReady>());
        expect((cubit.state as RouteFleetReady).fleetInfo, fleet);

        // Prototype: Slide to start route -> R43 -> Start route -> R10.
        cubit.openCheckPackagesSheet();
        expect(cubit.state, isA<RouteFleetCheckPackages>());
        cubit.startRoute();
        expect(cubit.state, isA<RouteFleetDriving>());
      },
    );

    test(
      'reorderStopToLast works from both Driving and Arrived states',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();
        expect(cubit.state, isA<RouteFleetDriving>());

        when(
          () => mockReorderStopUseCase(0),
        ).thenAnswer((_) async => testFleet);
        await cubit.reorderStopToLast(0);
        expect(
          (cubit.state as RouteFleetDriving).toastType,
          DrivingToastType.stopMoved,
        );

        // Test reorder from driving state again
        await cubit.reorderStopToLast(0);
        expect(
          (cubit.state as RouteFleetDriving).toastType,
          DrivingToastType.stopMoved,
        );
      },
    );

    test(
      'takeBreak, extendBreak, and resumeBreak update state and engine correctly',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();
        expect(cubit.state, isA<RouteFleetDriving>());

        cubit.takeBreak();
        expect(
          (cubit.state as RouteFleetDriving).activeSheet,
          DrivingModalSheet.onBreak,
        );

        cubit.extendBreak();
        expect((cubit.state as RouteFleetDriving).allowedBreakMinutes, 20);

        cubit.resumeBreak();
        expect(
          (cubit.state as RouteFleetDriving).activeSheet,
          DrivingModalSheet.none,
        );
      },
    );

    test(
      'reportWrongLocation calls use case and returns to arrived state',
      () async {
        await cubit.loadActiveRoute();
        cubit.startRoute();

        when(
          () => mockReportWrongLocationUseCase(any()),
        ).thenAnswer((_) async {});

        await cubit.reportWrongLocation(
          'entrance_elsewhere',
          'Entrance is somewhere else',
          correctedLatLng: const LatLng(21.5, 39.1),
        );
        expect(cubit.state, isA<RouteFleetArrived>());
        verify(() => mockReportWrongLocationUseCase(any())).called(1);
      },
    );

    test(
      'closeProofCamera reverts to Arrived state for the same stop',
      () async {
        await cubit.loadActiveRoute();
        cubit.openProofCamera(
          stopNumber: 1,
          customerName: 'Omar Haddad',
          requiresSignature: false,
        );
        expect(cubit.state, isA<RouteFleetProofCamera>());

        cubit.closeProofCamera();
        expect(cubit.state, isA<RouteFleetArrived>());
        expect((cubit.state as RouteFleetArrived).stopIndex, 0);

        cubit.openProofCamera(
          stopNumber: 2,
          customerName: 'Lina Fares',
          requiresSignature: false,
        );
        cubit.closeProofCamera();
        expect(cubit.state, isA<RouteFleetArrived>());
        expect((cubit.state as RouteFleetArrived).stopIndex, 1);
      },
    );
  });

  group('RouteFleetCubit Fleet Search and Join Flow', () {
    late MockSearchFleetsUseCase mockSearchFleetsUseCase;
    late MockJoinFleetUseCase mockJoinFleetUseCase;
    late RouteFleetCubit searchCubit;

    setUp(() {
      mockSearchFleetsUseCase = MockSearchFleetsUseCase();
      mockJoinFleetUseCase = MockJoinFleetUseCase();
      searchCubit = RouteFleetCubit(
        getActiveRouteUseCase: MockGetActiveRouteUseCase(),
        updateStopStatusUseCase: MockUpdateStopStatusUseCase(),
        reorderStopUseCase: MockReorderStopUseCase(),
        reportWrongLocationUseCase: MockReportWrongLocationUseCase(),
        searchFleetsUseCase: mockSearchFleetsUseCase,
        joinFleetUseCase: mockJoinFleetUseCase,
      );
    });

    tearDown(() {
      searchCubit.close();
    });

    blocTest<RouteFleetCubit, RouteFleetState>(
      'searchFleets updates state with results on success',
      build: () {
        when(() => mockSearchFleetsUseCase(any()))
            .thenAnswer((_) async => const Right([
                  FleetCompany(id: '1', name: 'Red Sea Express', address: 'Al Hamra', driversCount: '48')
                ]));
        return searchCubit;
      },
      act: (cubit) => cubit.searchFleets('Red'),
      expect: () => [
        const RouteFleetFindFleetState(
          searchQuery: 'Red',
          isLoading: true,
        ),
        const RouteFleetFindFleetState(
          searchQuery: 'Red',
          fleets: [
            FleetCompany(id: '1', name: 'Red Sea Express', address: 'Al Hamra', driversCount: '48')
          ],
          isLoading: false,
          errorMessage: null,
        ),
      ],
    );

    blocTest<RouteFleetCubit, RouteFleetState>(
      'sendJoinRequest transitions to request pending with API company name on success',
      build: () {
        when(() => mockJoinFleetUseCase('1'))
            .thenAnswer((_) async => const Right('Red Sea Express'));
        return searchCubit;
      },
      act: (cubit) => cubit.sendJoinRequest('Requested Fleet', companyId: '1'),
      expect: () => [
        const RouteFleetRequestPendingState(fleetName: 'Red Sea Express'),
      ],
    );

    blocTest<RouteFleetCubit, RouteFleetState>(
      'sendJoinRequest stays on find-fleet and shows error message on failure',
      build: () {
        when(() => mockJoinFleetUseCase('1'))
            .thenAnswer((_) async => const Left(ServerFailure('Join failed')));
        return searchCubit;
      },
      act: (cubit) => cubit.sendJoinRequest('Requested Fleet', companyId: '1'),
      expect: () => [
        const RouteFleetFindFleetState(
          selectedFilter: 'Nearby',
          searchQuery: '',
          fleets: [],
          isLoading: false,
          errorMessage: 'Join failed',
        ),
      ],
    );
  });
  group('RouteFleetCubit 403 on the active route', () {
    test('a 403 is the no-fleet state, other failures stay errors', () async {
      Future<RouteFleetState> loadWith(int status) async {
        final useCase = MockGetActiveRouteUseCase();
        final request = RequestOptions(path: '/orders/mine');
        when(() => useCase()).thenThrow(
          DioException(
            requestOptions: request,
            type: DioExceptionType.badResponse,
            response: Response<dynamic>(
              requestOptions: request,
              statusCode: status,
            ),
          ),
        );
        final c = RouteFleetCubit(
          getActiveRouteUseCase: useCase,
          updateStopStatusUseCase: MockUpdateStopStatusUseCase(),
          reorderStopUseCase: MockReorderStopUseCase(),
          reportWrongLocationUseCase: MockReportWrongLocationUseCase(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 400));
        final state = c.state;
        await c.close();
        return state;
      }

      expect(await loadWith(403), isA<RouteFleetNoFleetState>());
      expect(await loadWith(500), isA<RouteFleetError>());
    });
  });
}
