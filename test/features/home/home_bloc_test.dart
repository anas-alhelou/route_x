// test/features/home/home_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_profile.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/entities/setup_progress.dart';
import 'package:routex_mobile/features/home/domain/entities/shift_stats.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_debug_repository.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_home_overview_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/join_fleet_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/set_online_status_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_sheet.dart';

class MockGetHomeOverviewUseCase extends Mock
    implements GetHomeOverviewUseCase {}

class MockSetOnlineStatusUseCase extends Mock
    implements SetOnlineStatusUseCase {}

class MockJoinFleetUseCase extends Mock implements JoinFleetUseCase {}

class MockHomeDebugRepository extends Mock implements HomeDebugRepository {}

void main() {
  late MockGetHomeOverviewUseCase getHomeOverview;
  late MockSetOnlineStatusUseCase setOnlineStatus;
  late MockJoinFleetUseCase joinFleet;
  late MockHomeDebugRepository debugRepository;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const SetOnlineStatusParams(isOnline: true));
    registerFallbackValue(const JoinFleetParams(fleetId: 'fleet'));
  });

  setUp(() {
    getHomeOverview = MockGetHomeOverviewUseCase();
    setOnlineStatus = MockSetOnlineStatusUseCase();
    joinFleet = MockJoinFleetUseCase();
    debugRepository = MockHomeDebugRepository();
  });

  HomeBloc buildBloc() => HomeBloc(
    getHomeOverview: getHomeOverview,
    setOnlineStatus: setOnlineStatus,
    joinFleet: joinFleet,
    debugRepository: debugRepository,
  );

  group('HomeStarted', () {
    blocTest<HomeBloc, HomeState>(
      'emits loading then success with the overview',
      setUp: () {
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview()));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.success)
            .having((s) => s.overview, 'overview', _overview()),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits failure and keeps the error key when the load fails',
      setUp: () {
        when(() => getHomeOverview(any())).thenAnswer(
          (_) async => const Left(ServerFailure('errFleetNotFound')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const HomeStarted()),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'errFleetNotFound'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'refreshes quietly instead of reloading when data is already shown',
      setUp: () {
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview()));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await bloc.stream.firstWhere((s) => s.status == HomeStatus.success);
        bloc.add(const HomeStarted());
      },
      // The second start must not re-enter `loading`: re-entering Home from
      // another tab should never blank the dashboard the driver was reading.
      skip: 2,
      expect: () => [
        isA<HomeState>().having((s) => s.isRefreshing, 'isRefreshing', true),
        isA<HomeState>().having((s) => s.isRefreshing, 'isRefreshing', false),
      ],
    );
  });

  group('HomeOnlineToggled', () {
    blocTest<HomeBloc, HomeState>(
      'emits blocked reason when the driver has no approved fleet',
      setUp: () {
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview()));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await bloc.stream.firstWhere((s) => s.status == HomeStatus.success);
        bloc.add(const HomeOnlineToggled(isOnline: true));
      },
      skip: 2,
      expect: () => [
        isA<HomeState>().having(
          (s) => s.blockedReason,
          'blockedReason',
          GoOnlineBlockedReason.noFleet,
        ),
      ],
      verify: (_) {
        verifyNever(() => setOnlineStatus(any()));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'writes the new availability through when the driver has a fleet',
      setUp: () {
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview(joined: true)));
        when(() => setOnlineStatus(any())).thenAnswer(
          (_) async => const Right(
            DriverAvailability(isOnline: true, fleetId: 'red-sea-express'),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await bloc.stream.firstWhere((s) => s.status == HomeStatus.success);
        bloc.add(const HomeOnlineToggled(isOnline: true));
      },
      skip: 2,
      expect: () => [
        isA<HomeState>().having(
          (s) => s.overview?.availability.isOnline,
          'isOnline',
          true,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'surfaces the failure key and keeps the content on screen',
      setUp: () {
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview(joined: true)));
        when(() => setOnlineStatus(any())).thenAnswer(
          (_) async =>
              const Left(ValidationFailure('errJoinFleetBeforeGoingOnline')),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await bloc.stream.firstWhere((s) => s.status == HomeStatus.success);
        bloc.add(const HomeOnlineToggled(isOnline: true));
      },
      skip: 2,
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.success)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'errJoinFleetBeforeGoingOnline',
            ),
      ],
    );
  });

  group('HomeFleetJoinRequested', () {
    blocTest<HomeBloc, HomeState>(
      'replaces the overview with the refreshed one',
      setUp: () {
        final joined = _overview(joined: true);
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview()));
        when(() => joinFleet(any())).thenAnswer((_) async => Right(joined));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await bloc.stream.firstWhere((s) => s.status == HomeStatus.success);
        bloc.add(const HomeFleetJoinRequested(fleetId: 'red-sea-express'));
      },
      skip: 2,
      expect: () => [
        isA<HomeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<HomeState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.canToggleOnline, 'canToggleOnline', true)
            .having((s) => s.overview, 'overview', _overview(joined: true)),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'clears the busy flag and reports the key when the join fails',
      setUp: () {
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview()));
        when(() => joinFleet(any())).thenAnswer(
          (_) async => const Left(ServerFailure('errFleetNotFound')),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await bloc.stream.firstWhere((s) => s.status == HomeStatus.success);
        bloc.add(const HomeFleetJoinRequested(fleetId: 'gone'));
      },
      skip: 2,
      expect: () => [
        isA<HomeState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<HomeState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.errorMessage, 'errorMessage', 'errFleetNotFound')
            .having((s) => s.status, 'status', HomeStatus.success),
      ],
    );
  });

  group('HomeErrorDismissed', () {
    blocTest<HomeBloc, HomeState>(
      'returns to success and drops the message when content is present',
      setUp: () {
        when(
          () => getHomeOverview(any()),
        ).thenAnswer((_) async => Right(_overview()));
        when(() => joinFleet(any())).thenAnswer(
          (_) async => const Left(ServerFailure('errFleetNotFound')),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const HomeStarted());
        await bloc.stream.firstWhere((s) => s.status == HomeStatus.success);
        bloc.add(const HomeFleetJoinRequested(fleetId: 'gone'));
        await bloc.stream.firstWhere((s) => s.errorMessage != null);
        bloc.add(const HomeErrorDismissed());
      },
      skip: 4,
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.success)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );
  });
}

/// Builds the seeded dashboard the local source returns, optionally already
/// joined to a fleet.
HomeOverview _overview({bool joined = false}) {
  return HomeOverview(
    profile: const DriverProfile(
      displayName: 'Hamza Barakat',
      avatarPath: 'assets/images/png/img_driver_avatar.png',
    ),
    availability: DriverAvailability(
      isOnline: false,
      fleetId: joined ? 'red-sea-express' : null,
      requestStatus: joined
          ? FleetRequestStatus.approved
          : FleetRequestStatus.none,
    ),
    stats: const ShiftStats(
      deliveries: 0,
      deliveriesTarget: 0,
      distanceKm: 0,
      shiftDuration: Duration.zero,
    ),
    setup: SetupProgress(
      steps: [
        const SetupStep(id: SetupStepId.account, status: SetupStepStatus.done),
        const SetupStep(id: SetupStepId.phone, status: SetupStepStatus.done),
        SetupStep(
          id: SetupStepId.fleet,
          status: joined ? SetupStepStatus.done : SetupStepStatus.todo,
        ),
      ],
    ),
    nearbyFleets: const [
      FleetSummary(
        id: 'red-sea-express',
        name: 'Red Sea Express',
        zone: 'Al Hamra',
        distanceKm: 1.2,
        logoPath: 'assets/images/png/img_fleet_red_sea_express.png',
        accentColor: 0xFF1E87FD,
        avatarFill: 0xFFFEFEFE,
        status: FleetJoinStatus.active,
      ),
    ],
    fleetRequest: joined
        ? FleetRequest(
            fleetId: 'red-sea-express',
            fleetName: 'Red Sea Express',
            fleetLogoPath: 'assets/images/png/img_fleet_red_sea_express.png',
            requestedAt: DateTime(2026, 1, 1),
            status: FleetRequestStatus.approved,
          )
        : null,
  );
}
