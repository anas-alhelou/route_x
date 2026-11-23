// test/features/home/find_fleet_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_available_filters_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_fleets_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/join_find_fleet_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/find_fleet_bloc.dart';

class MockGetFleetsUseCase extends Mock implements GetFleetsUseCase {}

class MockGetAvailableFiltersUseCase extends Mock
    implements GetAvailableFiltersUseCase {}

class MockJoinFindFleetUseCase extends Mock implements JoinFindFleetUseCase {}

void main() {
  late MockGetFleetsUseCase getFleets;
  late MockGetAvailableFiltersUseCase getAvailableFilters;
  late MockJoinFindFleetUseCase joinFindFleet;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const GetFleetsParams());
    registerFallbackValue(const JoinFindFleetParams(fleetId: 'fleet'));
  });

  setUp(() {
    getFleets = MockGetFleetsUseCase();
    getAvailableFilters = MockGetAvailableFiltersUseCase();
    joinFindFleet = MockJoinFindFleetUseCase();
  });

  FindFleetBloc buildBloc() => FindFleetBloc(
    getFleets: getFleets,
    getAvailableFilters: getAvailableFilters,
    joinFindFleet: joinFindFleet,
  );

  const fleets = [
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
  ];

  group('FindFleetStarted', () {
    blocTest<FindFleetBloc, FindFleetState>(
      'emits loading then success with fleets and filters',
      setUp: () {
        when(() => getAvailableFilters(any())).thenAnswer(
          (_) async => const Right([FleetFilter.all, FleetFilter.nearby]),
        );
        when(
          () => getFleets(any()),
        ).thenAnswer((_) async => const Right(fleets));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FindFleetStarted()),
      expect: () => [
        isA<FindFleetState>().having(
          (s) => s.status,
          'status',
          FindFleetStatus.loading,
        ),
        isA<FindFleetState>().having(
          (s) => s.availableFilters,
          'availableFilters',
          [FleetFilter.all, FleetFilter.nearby],
        ),
        isA<FindFleetState>()
            .having((s) => s.status, 'status', FindFleetStatus.success)
            .having((s) => s.fleets, 'fleets', fleets),
      ],
    );

    blocTest<FindFleetBloc, FindFleetState>(
      'emits failure when the load fails and no fleets are present',
      setUp: () {
        when(
          () => getAvailableFilters(any()),
        ).thenAnswer((_) async => const Right([FleetFilter.all]));
        when(() => getFleets(any())).thenAnswer(
          (_) async => const Left(ServerFailure('errFleetNotFound')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FindFleetStarted()),
      expect: () => [
        isA<FindFleetState>().having(
          (s) => s.status,
          'status',
          FindFleetStatus.loading,
        ),
        isA<FindFleetState>().having(
          (s) => s.availableFilters,
          'availableFilters',
          [FleetFilter.all],
        ),
        isA<FindFleetState>()
            .having((s) => s.status, 'status', FindFleetStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'errFleetNotFound'),
      ],
    );
  });

  group('FindFleetQueryChanged', () {
    blocTest<FindFleetBloc, FindFleetState>(
      'reloads with the new query',
      setUp: () {
        when(
          () => getAvailableFilters(any()),
        ).thenAnswer((_) async => const Right([FleetFilter.all]));
        when(
          () => getFleets(any()),
        ).thenAnswer((_) async => const Right(fleets));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const FindFleetStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == FindFleetStatus.success,
        );
        bloc.add(const FindFleetQueryChanged(query: 'Red'));
      },
      skip: 3,
      expect: () => [
        isA<FindFleetState>()
            .having((s) => s.query, 'query', 'Red')
            .having((s) => s.status, 'status', FindFleetStatus.loading),
        isA<FindFleetState>().having(
          (s) => s.status,
          'status',
          FindFleetStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () => getFleets(
            const GetFleetsParams(filter: FleetFilter.nearby, query: 'Red'),
          ),
        ).called(1);
      },
    );
  });

  group('FindFleetFilterSelected', () {
    blocTest<FindFleetBloc, FindFleetState>(
      'ignores the event when the filter is already selected',
      setUp: () {
        when(() => getAvailableFilters(any())).thenAnswer(
          (_) async => const Right([FleetFilter.all, FleetFilter.nearby]),
        );
        when(
          () => getFleets(any()),
        ).thenAnswer((_) async => const Right(fleets));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const FindFleetStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == FindFleetStatus.success,
        );
        bloc.add(const FindFleetFilterSelected(filter: FleetFilter.nearby));
      },
      skip: 3,
      expect: () => <FindFleetState>[],
      verify: (_) {
        // Only the initial load should have called getFleets.
        verify(() => getFleets(any())).called(1);
      },
    );

    blocTest<FindFleetBloc, FindFleetState>(
      'reloads with the new filter',
      setUp: () {
        when(() => getAvailableFilters(any())).thenAnswer(
          (_) async => const Right([FleetFilter.all, FleetFilter.nearby]),
        );
        when(
          () => getFleets(any()),
        ).thenAnswer((_) async => const Right(fleets));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const FindFleetStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == FindFleetStatus.success,
        );
        bloc.add(const FindFleetFilterSelected(filter: FleetFilter.all));
      },
      skip: 3,
      expect: () => [
        isA<FindFleetState>()
            .having((s) => s.selectedFilter, 'selectedFilter', FleetFilter.all)
            .having((s) => s.status, 'status', FindFleetStatus.loading),
        isA<FindFleetState>().having(
          (s) => s.status,
          'status',
          FindFleetStatus.success,
        ),
      ],
    );
  });

  group('FindFleetJoinRequested', () {
    blocTest<FindFleetBloc, FindFleetState>(
      'clears the busy flag on success',
      setUp: () {
        when(
          () => getAvailableFilters(any()),
        ).thenAnswer((_) async => const Right([FleetFilter.all]));
        when(
          () => getFleets(any()),
        ).thenAnswer((_) async => const Right(fleets));
        when(
          () => joinFindFleet(any()),
        ).thenAnswer((_) async => const Right(null));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const FindFleetStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == FindFleetStatus.success,
        );
        bloc.add(const FindFleetJoinRequested(fleetId: 'red-sea-express'));
      },
      skip: 3,
      expect: () => [
        isA<FindFleetState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<FindFleetState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          false,
        ),
      ],
    );

    blocTest<FindFleetBloc, FindFleetState>(
      'surfaces the failure key and clears the busy flag',
      setUp: () {
        when(
          () => getAvailableFilters(any()),
        ).thenAnswer((_) async => const Right([FleetFilter.all]));
        when(
          () => getFleets(any()),
        ).thenAnswer((_) async => const Right(fleets));
        when(() => joinFindFleet(any())).thenAnswer(
          (_) async => const Left(ServerFailure('errFleetNotFound')),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const FindFleetStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == FindFleetStatus.success,
        );
        bloc.add(const FindFleetJoinRequested(fleetId: 'gone'));
      },
      skip: 3,
      expect: () => [
        isA<FindFleetState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<FindFleetState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.errorMessage, 'errorMessage', 'errFleetNotFound'),
      ],
    );
  });

  group('FindFleetErrorDismissed', () {
    blocTest<FindFleetBloc, FindFleetState>(
      'drops the message and returns to success when content is present',
      setUp: () {
        when(
          () => getAvailableFilters(any()),
        ).thenAnswer((_) async => const Right([FleetFilter.all]));
        when(
          () => getFleets(any()),
        ).thenAnswer((_) async => const Right(fleets));
        when(() => joinFindFleet(any())).thenAnswer(
          (_) async => const Left(ServerFailure('errFleetNotFound')),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const FindFleetStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == FindFleetStatus.success,
        );
        bloc.add(const FindFleetJoinRequested(fleetId: 'gone'));
        await bloc.stream.firstWhere((s) => s.errorMessage != null);
        bloc.add(const FindFleetErrorDismissed());
      },
      skip: 5,
      expect: () => [
        isA<FindFleetState>()
            .having((s) => s.status, 'status', FindFleetStatus.success)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );
  });
}
