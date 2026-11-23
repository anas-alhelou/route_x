// lib/features/home/presentation/bloc/enter_fleet_code_event.dart
import 'package:equatable/equatable.dart';

/// Anything the Enter Fleet Code screen can ask its BLoC to do.
///
/// Sealed so the BLoC's `on<Event>` registrations are checked against this list
/// at compile time: adding a case here without handling it is a build error
/// rather than an event that is silently dropped at runtime.
sealed class EnterFleetCodeEvent extends Equatable {
  const EnterFleetCodeEvent();

  @override
  List<Object?> get props => [];
}

/// A box changed — a keystroke, a backspace, or a paste landing inside one.
///
/// Carries the whole code rather than a single character: the boxes are one
/// field split six ways, so a partial update would leave the BLoC guessing about
/// the other five.
class CodeChanged extends EnterFleetCodeEvent {
  const CodeChanged(this.code);

  /// The code as the row now holds it, in any casing.
  final String code;

  @override
  List<Object?> get props => [code];
}

/// The driver pressed "Paste".
///
/// Separate from [CodeChanged] because the clipboard is asynchronous: reading it
/// is the page's job, and the page has to check `mounted` after the await before
/// it can be sure the screen is still there to receive the event.
class PasteRequested extends EnterFleetCodeEvent {
  const PasteRequested(this.pastedCode);

  /// Raw clipboard contents, which may contain anything at all.
  final String pastedCode;

  @override
  List<Object?> get props => [pastedCode];
}

/// The driver pressed Join.
///
/// Ignored unless the code is complete and nothing is already in flight, so a
/// double tap cannot start two verifications.
class Submitted extends EnterFleetCodeEvent {
  const Submitted();
}

/// The driver dismissed the error without changing the code — by tapping a box,
/// or by pressing "Try again", which also empties the boxes.
class ErrorCleared extends EnterFleetCodeEvent {
  const ErrorCleared();
}

/// The driver asked to start over, from "Try again".
///
/// Distinct from [ErrorCleared] because clearing the error and clearing the code
/// are different intentions: one says "this was a mistake, let me try again",
/// the other says "never mind".
class CodeCleared extends EnterFleetCodeEvent {
  const CodeCleared();
}
