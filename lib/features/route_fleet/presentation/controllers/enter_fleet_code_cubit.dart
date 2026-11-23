// lib/features/route_fleet/presentation/controllers/enter_fleet_code_cubit.dart
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/join_fleet_by_code_usecase.dart';
import 'enter_fleet_code_state.dart';

class EnterFleetCodeCubit extends Cubit<EnterFleetCodeState> {
  EnterFleetCodeCubit({required JoinFleetByCodeUseCase joinFleetByCodeUseCase})
      : _joinFleetByCodeUseCase = joinFleetByCodeUseCase,
        super(const EnterFleetCodeState());

  final JoinFleetByCodeUseCase _joinFleetByCodeUseCase;

  void updateCode(String code) {
    emit(state.copyWith(code: code, isError: false, errorMessage: null, isNetworkError: false));
  }

  Future<void> submitFleetCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;

    final result = await _joinFleetByCodeUseCase(trimmed);
    result.fold(
      (failure) {
        final isValidation = failure is ValidationFailure;
        final isUnauthorized = failure is UnauthorizedFailure;
        final message = isValidation
            ? 'errInvalidOrExpiredCode'
            : isUnauthorized
                ? 'errSessionExpired'
                : failure.message;

        emit(
          state.copyWith(
            isError: true,
            errorMessage: message,
            isNetworkError: !isValidation && !isUnauthorized,
          ),
        );
      },
      (companyName) {
        emit(
          state.copyWith(
            isError: false,
            errorMessage: null,
            isNetworkError: false,
            joinedFleetName: companyName ?? 'Fleet',
          ),
        );
      },
    );
  }

  void submitCode() {
    submitFleetCode(state.code);
  }

  Future<void> pasteCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim().toUpperCase() ?? '';
    if (text.isNotEmpty) {
      final code = text.length > 6 ? text.substring(0, 6) : text;
      emit(state.copyWith(code: code, isError: false, errorMessage: null));
    }
  }

  void openAskManagerSheet() {
    emit(state.copyWith(showAskManagerSheet: true));
  }

  void closeAskManagerSheet() {
    emit(state.copyWith(showAskManagerSheet: false));
  }
}
