import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/errors/join_company_failures.dart';
import '../../domain/usecases/cancel_company_request_usecase.dart';
import '../../domain/usecases/get_request_status_usecase.dart';
import '../../domain/usecases/send_company_request_usecase.dart';
import '../../domain/usecases/verify_company_code_usecase.dart';
import 'join_company_event.dart';
import 'join_company_state.dart';

export 'join_company_event.dart';
export 'join_company_state.dart';

class JoinCompanyBloc extends Bloc<JoinCompanyEvent, JoinCompanyState> {
  JoinCompanyBloc({
    required VerifyCompanyCodeUseCase verifyCompanyCodeUseCase,
    required SendCompanyRequestUseCase sendCompanyRequestUseCase,
    required GetRequestStatusUseCase getRequestStatusUseCase,
    required CancelCompanyRequestUseCase cancelCompanyRequestUseCase,
  })  : _verifyCompanyCodeUseCase = verifyCompanyCodeUseCase,
        _sendCompanyRequestUseCase = sendCompanyRequestUseCase,
        _getRequestStatusUseCase = getRequestStatusUseCase,
        _cancelCompanyRequestUseCase = cancelCompanyRequestUseCase,
        super(const JoinCompanyState()) {
    on<CompanyCodeChanged>(_onCodeChanged);
    on<CompanyCodePasted>(_onCodePasted);
    on<CompanyCodeCleared>(_onCodeCleared);
    on<VerifyCodeSubmitted>(_onVerifyCodeSubmitted);
    on<SendCompanyRequestSubmitted>(_onSendRequestSubmitted);
    on<CheckForUpdatesRequested>(_onCheckForUpdatesRequested);
    on<CancelCompanyRequestSubmitted>(_onCancelRequestSubmitted);
    on<ResetToCodeInput>(_onResetToCodeInput);
    on<ResumeRequestRequested>(_onResumeRequest);
  }

  final VerifyCompanyCodeUseCase _verifyCompanyCodeUseCase;
  final SendCompanyRequestUseCase _sendCompanyRequestUseCase;
  final GetRequestStatusUseCase _getRequestStatusUseCase;
  final CancelCompanyRequestUseCase _cancelCompanyRequestUseCase;

  static String _normalize(String input) {
    final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    return sanitized.length > 6 ? sanitized.substring(0, 6) : sanitized;
  }

  void _onCodeChanged(CompanyCodeChanged event, Emitter<JoinCompanyState> emit) {
    final normalized = _normalize(event.code);
    emit(
      state.copyWith(
        code: normalized,
        clearError: true,
      ),
    );
  }

  void _onCodePasted(CompanyCodePasted event, Emitter<JoinCompanyState> emit) {
    final normalized = _normalize(event.rawText);
    emit(
      state.copyWith(
        code: normalized,
        clearError: true,
      ),
    );
  }

  void _onCodeCleared(CompanyCodeCleared event, Emitter<JoinCompanyState> emit) {
    emit(
      state.copyWith(
        code: '',
        clearError: true,
      ),
    );
  }

  Future<void> _onVerifyCodeSubmitted(
    VerifyCodeSubmitted event,
    Emitter<JoinCompanyState> emit,
  ) async {
    if (state.code.length != 6 || state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _verifyCompanyCodeUseCase(state.code);

    result.fold(
      (failure) {
        if (failure is CompanyCodeDisabledFailure) {
          emit(
            state.copyWith(
              isLoading: false,
              validationError: CodeValidationError.codeDisabled,
            ),
          );
        } else {
          // Default to invalid code (J02)
          emit(
            state.copyWith(
              isLoading: false,
              validationError: CodeValidationError.invalidCode,
            ),
          );
        }
      },
      (company) {
        emit(
          state.copyWith(
            isLoading: false,
            verifiedCompany: company,
            currentStep: JoinCompanyStep.confirmCompany,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onSendRequestSubmitted(
    SendCompanyRequestSubmitted event,
    Emitter<JoinCompanyState> emit,
  ) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    final result = await _sendCompanyRequestUseCase(event.company.code);

    result.fold(
      (failure) {
        if (failure is InvalidCompanyCodeFailure) {
          // J02: back to the code screen with the error.
          emit(
            state.copyWith(
              isLoading: false,
              currentStep: JoinCompanyStep.enterCode,
              validationError: CodeValidationError.invalidCode,
            ),
          );
        } else if (failure is CompanyCodeDisabledFailure) {
          // J03.
          emit(
            state.copyWith(
              isLoading: false,
              currentStep: JoinCompanyStep.enterCode,
              validationError: CodeValidationError.codeDisabled,
            ),
          );
        } else {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        }
      },
      (reviewStatus) {
        emit(
          state.copyWith(
            isLoading: false,
            reviewStatus: reviewStatus,
            currentStep: JoinCompanyStep.underReview,
          ),
        );
      },
    );
  }

  Future<void> _onCheckForUpdatesRequested(
    CheckForUpdatesRequested event,
    Emitter<JoinCompanyState> emit,
  ) async {
    if (state.isCheckingForUpdates) return;

    // Transition to J10b
    emit(state.copyWith(isCheckingForUpdates: true));

    // Figma J10b: keep the checking state visible for a moment.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final code = state.verifiedCompany?.code ?? state.code;
    final result = await _getRequestStatusUseCase(code);

    result.fold(
      (failure) {
        emit(state.copyWith(isCheckingForUpdates: false));
      },
      (updatedStatus) {
        emit(
          state.copyWith(
            isCheckingForUpdates: false,
            reviewStatus: updatedStatus,
          ),
        );
      },
    );
  }

  Future<void> _onCancelRequestSubmitted(
    CancelCompanyRequestSubmitted event,
    Emitter<JoinCompanyState> emit,
  ) async {
    final code = state.verifiedCompany?.code ?? state.code;

    // Reset to J01 first so the code screen never shows the old request.
    emit(const JoinCompanyState());

    // TODO(backend): there is no cancel endpoint yet, so cancelling is local
    // only: the repository forgets the flow state and the request stays PENDING
    // on the server.
    try {
      await _cancelCompanyRequestUseCase(code);
    } catch (_) {
      // Local cleanup must never leave the flow stuck.
    }
  }

  Future<void> _onResumeRequest(
    ResumeRequestRequested event,
    Emitter<JoinCompanyState> emit,
  ) async {
    final result = await _getRequestStatusUseCase('');
    result.fold(
      (_) {}, // Stay on the review screen; "Check for updates" can retry.
      (status) => emit(
        state.copyWith(
          reviewStatus: status,
          currentStep: JoinCompanyStep.underReview,
        ),
      ),
    );
  }

  void _onResetToCodeInput(ResetToCodeInput event, Emitter<JoinCompanyState> emit) {
    emit(
      state.copyWith(
        currentStep: JoinCompanyStep.enterCode,
        clearError: true,
        clearVerifiedCompany: true,
      ),
    );
  }
}
