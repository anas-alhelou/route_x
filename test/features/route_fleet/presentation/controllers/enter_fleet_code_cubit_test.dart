import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/route_fleet/domain/usecases/join_fleet_by_code_usecase.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/enter_fleet_code_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/enter_fleet_code_state.dart';

class MockJoinFleetByCodeUseCase extends Mock implements JoinFleetByCodeUseCase {}

void main() {
  late MockJoinFleetByCodeUseCase mockJoinFleetByCodeUseCase;

  setUp(() {
    mockJoinFleetByCodeUseCase = MockJoinFleetByCodeUseCase();
  });

  group('EnterFleetCodeCubit', () {
    blocTest<EnterFleetCodeCubit, EnterFleetCodeState>(
      'emits validation/404 error message on ValidationFailure',
      build: () {
        when(() => mockJoinFleetByCodeUseCase(any()))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid code')));
        return EnterFleetCodeCubit(joinFleetByCodeUseCase: mockJoinFleetByCodeUseCase);
      },
      act: (cubit) => cubit.submitFleetCode('123456'),
      expect: () => [
        const EnterFleetCodeState(
          isError: true,
          errorMessage: 'errInvalidOrExpiredCode',
          isNetworkError: false,
        ),
      ],
    );

    blocTest<EnterFleetCodeCubit, EnterFleetCodeState>(
      'emits network error message on ServerFailure',
      build: () {
        when(() => mockJoinFleetByCodeUseCase(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Network error')));
        return EnterFleetCodeCubit(joinFleetByCodeUseCase: mockJoinFleetByCodeUseCase);
      },
      act: (cubit) => cubit.submitFleetCode('123456'),
      expect: () => [
        const EnterFleetCodeState(
          isError: true,
          errorMessage: 'Network error',
          isNetworkError: true,
        ),
      ],
    );

    blocTest<EnterFleetCodeCubit, EnterFleetCodeState>(
      'emits joinedFleetName on success',
      build: () {
        when(() => mockJoinFleetByCodeUseCase(any()))
            .thenAnswer((_) async => const Right('Red Sea Express'));
        return EnterFleetCodeCubit(joinFleetByCodeUseCase: mockJoinFleetByCodeUseCase);
      },
      act: (cubit) => cubit.submitFleetCode('RSX48Z'),
      expect: () => [
        const EnterFleetCodeState(
          joinedFleetName: 'Red Sea Express',
          isError: false,
        ),
      ],
    );
  });
}
