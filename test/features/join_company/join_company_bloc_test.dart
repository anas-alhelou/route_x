import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/features/join_company/domain/entities/company.dart';
import 'package:routex_mobile/features/join_company/domain/entities/company_review_status.dart';
import 'package:routex_mobile/features/join_company/domain/errors/join_company_failures.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/cancel_company_request_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/get_request_status_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/send_company_request_usecase.dart';
import 'package:routex_mobile/features/join_company/domain/usecases/verify_company_code_usecase.dart';
import 'package:routex_mobile/features/join_company/presentation/bloc/join_company_bloc.dart';

class MockVerifyCompanyCodeUseCase extends Mock
    implements VerifyCompanyCodeUseCase {}

class MockSendCompanyRequestUseCase extends Mock
    implements SendCompanyRequestUseCase {}

class MockGetRequestStatusUseCase extends Mock
    implements GetRequestStatusUseCase {}

class MockCancelCompanyRequestUseCase extends Mock
    implements CancelCompanyRequestUseCase {}

void main() {
  late MockVerifyCompanyCodeUseCase mockVerifyCode;
  late MockSendCompanyRequestUseCase mockSendRequest;
  late MockGetRequestStatusUseCase mockGetStatus;
  late MockCancelCompanyRequestUseCase mockCancelRequest;

  const tCompany = Company(
    id: 'c_rsx482',
    name: 'Red Sea Express',
    code: 'RSX482',
    logoAsset: 'assets/images/png/img_fleet_red_sea_express.png',
    isActive: true,
  );

  const tReviewStatus = CompanyReviewStatus(
    company: tCompany,
    currentStep: CompanyReviewStep.companyReview,
    sentTimeFormatted: 'Today, 10:24 AM',
    driverName: 'Hamza Barakat',
  );

  setUp(() {
    mockVerifyCode = MockVerifyCompanyCodeUseCase();
    mockSendRequest = MockSendCompanyRequestUseCase();
    mockGetStatus = MockGetRequestStatusUseCase();
    mockCancelRequest = MockCancelCompanyRequestUseCase();
  });

  JoinCompanyBloc buildBloc() => JoinCompanyBloc(
        verifyCompanyCodeUseCase: mockVerifyCode,
        sendCompanyRequestUseCase: mockSendRequest,
        getRequestStatusUseCase: mockGetStatus,
        cancelCompanyRequestUseCase: mockCancelRequest,
      );

  group('JoinCompanyBloc', () {
    test('initial state has default values', () {
      final bloc = buildBloc();
      expect(bloc.state.code, '');
      expect(bloc.state.currentStep, JoinCompanyStep.enterCode);
      expect(bloc.state.validationError, CodeValidationError.none);
      expect(bloc.state.isContinueEnabled, false);
      expect(bloc.state.hasError, false);
      bloc.close();
    });

    blocTest<JoinCompanyBloc, JoinCompanyState>(
      'CompanyCodeChanged normalizes input to uppercase alphanumeric and clears error',
      build: buildBloc,
      seed: () => const JoinCompanyState(
        code: 'RSX481',
        validationError: CodeValidationError.invalidCode,
      ),
      act: (bloc) => bloc.add(const CompanyCodeChanged('rsx482')),
      expect: () => [
        const JoinCompanyState(
          code: 'RSX482',
          validationError: CodeValidationError.none,
          currentStep: JoinCompanyStep.enterCode,
        ),
      ],
    );

    blocTest<JoinCompanyBloc, JoinCompanyState>(
      'VerifyCodeSubmitted emits invalidCode error on InvalidCompanyCodeFailure (J02)',
      build: () {
        when(() => mockVerifyCode('RSX481'))
            .thenAnswer((_) async => const Left(InvalidCompanyCodeFailure()));
        return buildBloc();
      },
      seed: () => const JoinCompanyState(code: 'RSX481'),
      act: (bloc) => bloc.add(const VerifyCodeSubmitted()),
      expect: () => [
        const JoinCompanyState(code: 'RSX481', isLoading: true),
        const JoinCompanyState(
          code: 'RSX481',
          isLoading: false,
          validationError: CodeValidationError.invalidCode,
        ),
      ],
    );

    blocTest<JoinCompanyBloc, JoinCompanyState>(
      'VerifyCodeSubmitted emits codeDisabled error on CompanyCodeDisabledFailure (J03)',
      build: () {
        when(() => mockVerifyCode('KTW210'))
            .thenAnswer((_) async => const Left(CompanyCodeDisabledFailure()));
        return buildBloc();
      },
      seed: () => const JoinCompanyState(code: 'KTW210'),
      act: (bloc) => bloc.add(const VerifyCodeSubmitted()),
      expect: () => [
        const JoinCompanyState(code: 'KTW210', isLoading: true),
        const JoinCompanyState(
          code: 'KTW210',
          isLoading: false,
          validationError: CodeValidationError.codeDisabled,
        ),
      ],
    );

    blocTest<JoinCompanyBloc, JoinCompanyState>(
      'VerifyCodeSubmitted navigates to confirmCompany on valid code (J04)',
      build: () {
        when(() => mockVerifyCode('RSX482'))
            .thenAnswer((_) async => const Right(tCompany));
        return buildBloc();
      },
      seed: () => const JoinCompanyState(code: 'RSX482'),
      act: (bloc) => bloc.add(const VerifyCodeSubmitted()),
      expect: () => [
        const JoinCompanyState(code: 'RSX482', isLoading: true),
        const JoinCompanyState(
          code: 'RSX482',
          isLoading: false,
          verifiedCompany: tCompany,
          currentStep: JoinCompanyStep.confirmCompany,
        ),
      ],
    );

    blocTest<JoinCompanyBloc, JoinCompanyState>(
      'SendCompanyRequestSubmitted navigates to underReview (J10)',
      build: () {
        when(() => mockSendRequest(tCompany.code))
            .thenAnswer((_) async => const Right(tReviewStatus));
        return buildBloc();
      },
      seed: () => const JoinCompanyState(
        code: 'RSX482',
        verifiedCompany: tCompany,
        currentStep: JoinCompanyStep.confirmCompany,
      ),
      act: (bloc) => bloc.add(const SendCompanyRequestSubmitted(tCompany)),
      expect: () => [
        const JoinCompanyState(
          code: 'RSX482',
          verifiedCompany: tCompany,
          currentStep: JoinCompanyStep.confirmCompany,
          isLoading: true,
        ),
        const JoinCompanyState(
          code: 'RSX482',
          verifiedCompany: tCompany,
          currentStep: JoinCompanyStep.underReview,
          isLoading: false,
          reviewStatus: tReviewStatus,
        ),
      ],
    );

    blocTest<JoinCompanyBloc, JoinCompanyState>(
      'CancelCompanyRequestSubmitted resets to enterCode (J01)',
      build: () {
        when(() => mockCancelRequest(tCompany.code))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      seed: () => const JoinCompanyState(
        code: 'RSX482',
        verifiedCompany: tCompany,
        reviewStatus: tReviewStatus,
        currentStep: JoinCompanyStep.underReview,
      ),
      act: (bloc) => bloc.add(const CancelCompanyRequestSubmitted()),
      expect: () => [
        const JoinCompanyState(currentStep: JoinCompanyStep.enterCode),
      ],
    );
  });
}
