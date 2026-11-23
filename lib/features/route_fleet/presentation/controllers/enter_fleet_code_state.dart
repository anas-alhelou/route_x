// lib/features/route_fleet/presentation/controllers/enter_fleet_code_state.dart
import 'package:equatable/equatable.dart';

class EnterFleetCodeState extends Equatable {
  const EnterFleetCodeState({
    this.code = '',
    this.isError = false,
    this.errorMessage,
    this.isNetworkError = false,
    this.showAskManagerSheet = false,
    this.joinedFleetName,
  });

  final String code;
  final bool isError;
  final String? errorMessage;
  final bool isNetworkError;
  final bool showAskManagerSheet;
  final String? joinedFleetName;

  EnterFleetCodeState copyWith({
    String? code,
    bool? isError,
    String? errorMessage,
    bool? isNetworkError,
    bool? showAskManagerSheet,
    String? joinedFleetName,
  }) {
    return EnterFleetCodeState(
      code: code ?? this.code,
      isError: isError ?? this.isError,
      errorMessage: errorMessage,
      isNetworkError: isNetworkError ?? this.isNetworkError,
      showAskManagerSheet: showAskManagerSheet ?? this.showAskManagerSheet,
      joinedFleetName: joinedFleetName,
    );
  }

  @override
  List<Object?> get props => [
        code,
        isError,
        errorMessage,
        isNetworkError,
        showAskManagerSheet,
        joinedFleetName,
      ];
}
