// lib/features/home/presentation/bloc/enter_fleet_code_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/domain/usecases/verify_fleet_code_usecase.dart';
import 'package:routex_mobile/features/home/domain/value_objects/fleet_code.dart';
import 'package:routex_mobile/features/home/presentation/bloc/enter_fleet_code_event.dart';
import 'package:routex_mobile/features/home/presentation/bloc/enter_fleet_code_state.dart';

export 'enter_fleet_code_event.dart';
export 'enter_fleet_code_state.dart';

/// Owns the code on the Enter Fleet Code screen.
///
/// The single rule this class exists to enforce: the code has exactly one owner.
/// The page reads [EnterFleetCodeState.code] and renders it; the input row
/// reports changes and renders what it is given. Neither pushes the value at the
/// other, which is what removed the build-phase `setState` and the `GlobalKey`.
///
/// Depends only on [VerifyFleetCodeUseCase], a domain contract — no data source,
/// no `getIt`, no `BuildContext`.
class EnterFleetCodeBloc
    extends Bloc<EnterFleetCodeEvent, EnterFleetCodeState> {
  EnterFleetCodeBloc({required VerifyFleetCodeUseCase verifyFleetCodeUseCase})
    : _verifyFleetCodeUseCase = verifyFleetCodeUseCase,
      super(const EnterFleetCodeState()) {
    on<CodeChanged>(_onCodeChanged);
    on<PasteRequested>(_onPasteRequested);
    on<Submitted>(_onSubmitted);
    on<ErrorCleared>(_onErrorCleared);
    on<CodeCleared>(_onCodeCleared);
  }

  final VerifyFleetCodeUseCase _verifyFleetCodeUseCase;

  /// Normalizes on the way in, so no downstream code has to accept lowercase,
  /// spaces or an over-long paste. Also drops the error, because the driver is
  /// demonstrably correcting it.
  void _onCodeChanged(CodeChanged event, Emitter<EnterFleetCodeState> emit) {
    emit(
      state.copyWith(
        code: FleetCode.normalize(event.code),
        status: EnterFleetCodeStatus.idle,
        clearError: true,
      ),
    );
  }

  /// The page could not pre-sanitize the clipboard without duplicating the rules,
  /// so it hands the raw string over and the BLoC applies the same
  /// [FleetCode.normalize] the row applies.
  void _onPasteRequested(
    PasteRequested event,
    Emitter<EnterFleetCodeState> emit,
  ) {
    emit(
      state.copyWith(
        code: FleetCode.normalize(event.pastedCode),
        status: EnterFleetCodeStatus.idle,
        clearError: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    Submitted event,
    Emitter<EnterFleetCodeState> emit,
  ) async {
    // Guards the double tap: `isSubmitEnabled` is false while submitting, so the
    // second press lands here and is dropped rather than starting a second
    // verification whose result would race the first.
    if (!state.isSubmitEnabled) return;

    emit(state.copyWith(status: EnterFleetCodeStatus.submitting));

    final result = await _verifyFleetCodeUseCase(
      VerifyFleetCodeParams(code: state.code),
    );

    // The code is deliberately left untouched on failure. Keeping it is what
    // lets the driver see and correct the character the mock rejected; the old
    // input row emptied the boxes on the error frame, which left them with a
    // rejected code and nothing to fix.
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EnterFleetCodeStatus.invalid,
          errorMessage: _message(failure),
        ),
      ),
      (request) => emit(
        state.copyWith(
          status: EnterFleetCodeStatus.success,
          request: request,
        ),
      ),
    );
  }

  /// Dismiss the error but keep the code, for a driver who tapped a box and has
  /// not typed yet.
  void _onErrorCleared(ErrorCleared event, Emitter<EnterFleetCodeState> emit) {
    emit(
      state.copyWith(
        status: EnterFleetCodeStatus.idle,
        clearError: true,
      ),
    );
  }

  /// Empty the boxes and dismiss the error, for "Try again".
  void _onCodeCleared(CodeCleared event, Emitter<EnterFleetCodeState> emit) {
    emit(
      state.copyWith(
        code: '',
        status: EnterFleetCodeStatus.idle,
        clearError: true,
      ),
    );
  }

  /// The localization key the failure carries.
  ///
  /// Taken from the [Failure] rather than mapped here so a new failure type
  /// cannot ship without a message.
  String _message(Failure failure) => failure.message;
}
