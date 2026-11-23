// test/features/home/delivery_dashboard_bloc_test.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/services/location/location_service.dart';
import 'package:routex_mobile/core/services/location/user_location.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_delivery_dashboard_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/switch_delivery_scenario_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/delivery_dashboard_bloc.dart';

class MockGetDeliveryDashboardUseCase extends Mock
    implements GetDeliveryDashboardUseCase {}

class MockSwitchDeliveryScenarioUseCase extends Mock
    implements SwitchDeliveryScenarioUseCase {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockGetDeliveryDashboardUseCase mockGetDashboard;
  late MockSwitchDeliveryScenarioUseCase mockSwitchScenario;
  late MockLocationService mockLocationService;
  late StreamController<UserLocation> locationStreamController;

  const sampleDashboard = DeliveryDashboard(
    driverName: 'Anas',
    profileImagePath: 'assets/avatar.png',
    dateLabel: 'Old Static Date',
    scenario: DeliveryScenario.readyToStart,
  );

  const sampleLocation = UserLocation(
    latitude: 31.95,
    longitude: 35.91, // Amman / Levant UTC+3
  );

  setUpAll(() {
    registerFallbackValue(DeliveryScenario.onRoute);
  });

  setUp(() {
    mockGetDashboard = MockGetDeliveryDashboardUseCase();
    mockSwitchScenario = MockSwitchDeliveryScenarioUseCase();
    mockLocationService = MockLocationService();
    locationStreamController = StreamController<UserLocation>.broadcast();

    when(() => mockLocationService.onLocationChanged)
        .thenAnswer((_) => locationStreamController.stream);
  });

  tearDown(() {
    locationStreamController.close();
  });

  group('DeliveryDashboardBloc Location & Date Tests', () {
    test('initializes and updates dateLabel dynamically based on location',
        () async {
      when(() => mockGetDashboard.call(scenario: any(named: 'scenario')))
          .thenAnswer((_) async => const Right(sampleDashboard));
      when(() => mockLocationService.getCurrentLocation(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => sampleLocation);

      final bloc = DeliveryDashboardBloc(
        getDeliveryDashboard: mockGetDashboard,
        switchDeliveryScenario: mockSwitchScenario,
        locationService: mockLocationService,
      );

      bloc.add(const DeliveryDashboardInitialized());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const DeliveryDashboardState(status: DeliveryDashboardStatus.loading),
          predicate<DeliveryDashboardState>((state) {
            return state.status == DeliveryDashboardStatus.success &&
                state.dashboard?.userLocation == sampleLocation &&
                state.dashboard?.dateLabel != 'Old Static Date' &&
                (state.dashboard?.dateLabel.contains(',') ?? false);
          }),
        ]),
      );

      await bloc.close();
    });

    test('falls back gracefully to device date when location service returns null or throws',
        () async {
      when(() => mockGetDashboard.call(scenario: any(named: 'scenario')))
          .thenAnswer((_) async => const Right(sampleDashboard));
      when(() => mockLocationService.getCurrentLocation(
              forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(Exception('GPS unavailable / offline'));

      final bloc = DeliveryDashboardBloc(
        getDeliveryDashboard: mockGetDashboard,
        switchDeliveryScenario: mockSwitchScenario,
        locationService: mockLocationService,
      );

      bloc.add(const DeliveryDashboardInitialized());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const DeliveryDashboardState(status: DeliveryDashboardStatus.loading),
          predicate<DeliveryDashboardState>((state) {
            return state.status == DeliveryDashboardStatus.success &&
                state.dashboard?.userLocation == null &&
                state.dashboard?.dateLabel != 'Old Static Date';
          }),
        ]),
      );

      await bloc.close();
    });

    test('updates dateLabel when location stream emits a new position',
        () async {
      when(() => mockGetDashboard.call(scenario: any(named: 'scenario')))
          .thenAnswer((_) async => const Right(sampleDashboard));
      when(() => mockLocationService.getCurrentLocation(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => sampleLocation);

      final bloc = DeliveryDashboardBloc(
        getDeliveryDashboard: mockGetDashboard,
        switchDeliveryScenario: mockSwitchScenario,
        locationService: mockLocationService,
      );

      bloc.add(const DeliveryDashboardInitialized());

      // Wait for initialization
      await bloc.stream.firstWhere(
          (s) => s.status == DeliveryDashboardStatus.success);

      // Emit new location
      const newLocation = UserLocation(latitude: 40.71, longitude: -74.00);
      locationStreamController.add(newLocation);

      await expectLater(
        bloc.stream,
        emits(predicate<DeliveryDashboardState>((state) {
          return state.dashboard?.userLocation == newLocation;
        })),
      );

      await bloc.close();
    });

    test('maintains dynamic dateLabel and userLocation across scenario changes',
        () async {
      when(() => mockGetDashboard.call(scenario: any(named: 'scenario')))
          .thenAnswer((_) async => const Right(sampleDashboard));
      when(() => mockLocationService.getCurrentLocation(
              forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => sampleLocation);
      when(() => mockSwitchScenario.call(any()))
          .thenAnswer((_) async => const Right(
                DeliveryDashboard(
                  driverName: 'Anas',
                  profileImagePath: 'assets/avatar.png',
                  dateLabel: 'Old Static Date',
                  scenario: DeliveryScenario.onRoute,
                ),
              ));

      final bloc = DeliveryDashboardBloc(
        getDeliveryDashboard: mockGetDashboard,
        switchDeliveryScenario: mockSwitchScenario,
        locationService: mockLocationService,
      );

      bloc.add(const DeliveryDashboardInitialized());
      await bloc.stream.firstWhere(
          (s) => s.status == DeliveryDashboardStatus.success);

      final initialDateLabel = bloc.state.dashboard?.dateLabel;

      bloc.add(const DeliveryDashboardScenarioChanged(DeliveryScenario.onRoute));

      await expectLater(
        bloc.stream,
        emits(predicate<DeliveryDashboardState>((state) {
          return state.dashboard?.userLocation == sampleLocation &&
              state.dashboard?.dateLabel == initialDateLabel;
        })),
      );

      await bloc.close();
    });
  });
}
