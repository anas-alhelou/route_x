// test/features/home/enter_fleet_code_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/usecases/verify_fleet_code_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/enter_fleet_code_bloc.dart';

class MockVerifyFleetCodeUseCase extends Mock
    implements VerifyFleetCodeUseCase {}

void main() {
  late MockVerifyFleetCodeUseCase verifyFleetCode;

  final tRequest = FleetRequest(
    fleetId: 'fleet-red-sea',
    fleetName: 'Red Sea Express',
    fleetLogoPath: 'assets/images/png/img_fleet_red_sea_express.png',
    requestedAt: DateTime(2026, 10, 3, 10, 30),
    status: FleetRequestStatus.pending,
  );

  setUpAll(() {
    registerFallbackValue(const VerifyFleetCodeParams(code: 'RSX482'));
  });

  setUp(() {
    verifyFleetCode = MockVerifyFleetCodeUseCase();
  });

  EnterFleetCodeBloc buildBloc() =>
      EnterFleetCodeBloc(verifyFleetCodeUseCase: verifyFleetCode);

  group('EnterFleetCodeBloc', () {
    test('initial state has default values', () {
      final bloc = buildBloc();
      expect(bloc.state.code, '');
      expect(bloc.state.status, EnterFleetCodeStatus.idle);
      expect(bloc.state.isSubmitEnabled, false);
      expect(bloc.state.hasError, false);
      bloc.close();
    });

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'CodeChanged emits updated uppercase code and clears any error',
      build: buildBloc,
      act: (bloc) => bloc.add(const CodeChanged('rsx482')),
      expect: () => [
        const EnterFleetCodeState(
          code: 'RSX482',
          status: EnterFleetCodeStatus.idle,
          errorMessage: null,
        ),
      ],
    );

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'CodeChanged strips spaces and clamps an over-long code to six',
      build: buildBloc,
      act: (bloc) => bloc.add(const CodeChanged('rs-x482999')),
      expect: () => [
        const EnterFleetCodeState(
          code: 'RSX482',
          status: EnterFleetCodeStatus.idle,
        ),
      ],
    );

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'PasteRequested filters non-alphanumeric chars, truncates to 6 chars, and uppercase',
      build: buildBloc,
      act: (bloc) => bloc.add(const PasteRequested('rs-x482999')),
      expect: () => [
        const EnterFleetCodeState(
          code: 'RSX482',
          status: EnterFleetCodeStatus.idle,
          errorMessage: null,
        ),
      ],
    );

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'Submitted emits submitting then success when code is valid',
      setUp: () {
        when(
          () => verifyFleetCode(any()),
        ).thenAnswer((_) async => Right(tRequest));
      },
      build: buildBloc,
      seed: () => const EnterFleetCodeState(
        code: 'RSX482',
        status: EnterFleetCodeStatus.idle,
      ),
      act: (bloc) => bloc.add(const Submitted()),
      expect: () => [
        const EnterFleetCodeState(
          code: 'RSX482',
          status: EnterFleetCodeStatus.submitting,
        ),
        EnterFleetCodeState(
          code: 'RSX482',
          status: EnterFleetCodeStatus.success,
          request: tRequest,
        ),
      ],
    );

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'Submitted on a valid code keeps the code in the invalid frame',
      setUp: () {
        when(() => verifyFleetCode(any())).thenAnswer(
          (_) async => const Left(ValidationFailure('errFleetCodeInvalid')),
        );
      },
      build: buildBloc,
      seed: () => const EnterFleetCodeState(
        code: 'WRONG1',
        status: EnterFleetCodeStatus.idle,
      ),
      act: (bloc) => bloc.add(const Submitted()),
      expect: () => [
        const EnterFleetCodeState(
          code: 'WRONG1',
          status: EnterFleetCodeStatus.submitting,
        ),
        // The boxes are not emptied: the driver needs to see which code was
        // rejected in order to correct it.
        const EnterFleetCodeState(
          code: 'WRONG1',
          status: EnterFleetCodeStatus.invalid,
          errorMessage: 'errFleetCodeInvalid',
        ),
      ],
    );

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'ErrorCleared resets status to idle and clears errorMessage but keeps the code',
      build: buildBloc,
      seed: () => const EnterFleetCodeState(
        code: 'WRONG1',
        status: EnterFleetCodeStatus.invalid,
        errorMessage: 'errFleetCodeInvalid',
      ),
      act: (bloc) => bloc.add(const ErrorCleared()),
      expect: () => [
        const EnterFleetCodeState(
          code: 'WRONG1',
          status: EnterFleetCodeStatus.idle,
          errorMessage: null,
        ),
      ],
    );

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'CodeCleared empties the boxes and clears the error',
      build: buildBloc,
      seed: () => const EnterFleetCodeState(
        code: 'WRONG1',
        status: EnterFleetCodeStatus.invalid,
        errorMessage: 'errFleetCodeInvalid',
      ),
      act: (bloc) => bloc.add(const CodeCleared()),
      expect: () => [
        const EnterFleetCodeState(
          status: EnterFleetCodeStatus.idle,
          errorMessage: null,
        ),
      ],
    );

    blocTest<EnterFleetCodeBloc, EnterFleetCodeState>(
      'CodeCleared after a rejected code re-enables nothing until six chars are typed',
      build: buildBloc,
      seed: () => const EnterFleetCodeState(
        code: 'WRONG1',
        status: EnterFleetCodeStatus.invalid,
        errorMessage: 'errFleetCodeInvalid',
      ),
      act: (bloc) => bloc.add(const CodeCleared()),
      verify: (bloc) {
        expect(bloc.state.code, isEmpty);
        expect(bloc.state.isSubmitEnabled, isFalse);
      },
    );
  });
}
