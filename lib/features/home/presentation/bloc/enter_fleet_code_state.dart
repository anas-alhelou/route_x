// lib/features/home/presentation/bloc/enter_fleet_code_state.dart
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/value_objects/fleet_code.dart';

/// Where a code-entry attempt has got to.
///
/// [idle] is both "nothing typed yet" and "ready to submit": what separates them
/// is [EnterFleetCodeState.code], not the status. The screen therefore branches
/// on [isInvalid] rather than on the status enum directly.
enum EnterFleetCodeStatus {
  /// No attempt in flight.
  idle,

  /// [Submitted] is being verified; the boxes are locked.
  submitting,

  /// The code was accepted and [EnterFleetCodeState.request] carries the fleet.
  success,

  /// The code was rejected; the boxes stay filled so it can be corrected.
  invalid,
}

/// Everything the Enter Fleet Code screen renders from.
///
/// [code] is the single source of truth for the six boxes. There is deliberately
/// no "code to push into the widget" field: the input row is controlled, so an
/// external change to [code] *is* the update, and a second channel for the same
/// value is what previously let the page and the widget disagree.
class EnterFleetCodeState extends Equatable {
  const EnterFleetCodeState({
    this.status = EnterFleetCodeStatus.idle,
    this.code = '',
    this.errorMessage,
    this.request,
  });

  /// Where the attempt has got to.
  final EnterFleetCodeStatus status;

  /// The current code, always normalized via [FleetCode.normalize]: uppercase,
  /// alphanumeric, at most [FleetCode.length] characters.
  final String code;

  /// Localization key of the reason the last attempt failed, or null when there
  /// is no error to show.
  final String? errorMessage;

  /// The fleet the accepted code belongs to, set only on success.
  final FleetRequest? request;

  /// Whether the boxes are locked against input.
  bool get isSubmitting => status == EnterFleetCodeStatus.submitting;

  /// Whether a code was accepted; the page pops on this.
  bool get isSuccess => status == EnterFleetCodeStatus.success;

  /// Whether the last attempt was rejected.
  bool get isInvalid => status == EnterFleetCodeStatus.invalid;

  /// Whether an error line should be drawn. Alias of [isInvalid], kept because
  /// the input row and the top bar both phrase their condition as "has an
  /// error" rather than "is invalid".
  bool get hasError => status == EnterFleetCodeStatus.invalid;

  /// Whether the Join button is live: the code is complete and no attempt is in
  /// flight.
  ///
  /// Length is the only test. An obviously malformed code is still submittable
  /// on purpose — the design shows a rejected code with its own "Try again"
  /// frame, which requires the driver to have been able to submit it.
  bool get isSubmitEnabled =>
      FleetCode.isComplete(code) && !isSubmitting;

  /// Returns a copy with the given fields replaced.
  ///
  /// [clearError] exists because `errorMessage` is nullable and "leave it alone"
  /// and "set it back to null" are different intents: every state change that
  /// follows new input drops the error, and without this flag there would be no
  /// way to say so.
  EnterFleetCodeState copyWith({
    EnterFleetCodeStatus? status,
    String? code,
    String? errorMessage,
    FleetRequest? request,
    bool clearError = false,
  }) {
    return EnterFleetCodeState(
      status: status ?? this.status,
      code: code ?? this.code,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      request: request ?? this.request,
    );
  }

  @override
  List<Object?> get props => [status, code, errorMessage, request];
}
