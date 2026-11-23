import 'package:equatable/equatable.dart';
import '../../domain/entities/company.dart';

abstract class JoinCompanyEvent extends Equatable {
  const JoinCompanyEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the driver enters or modifies a character in the 6-character code.
class CompanyCodeChanged extends JoinCompanyEvent {
  const CompanyCodeChanged(this.code);
  final String code;

  @override
  List<Object?> get props => [code];
}

/// Dispatched when the driver taps "Paste" or pastes text from clipboard.
class CompanyCodePasted extends JoinCompanyEvent {
  const CompanyCodePasted(this.rawText);
  final String rawText;

  @override
  List<Object?> get props => [rawText];
}

/// Dispatched when the code error should be cleared (e.g. user touches a box).
class CompanyCodeCleared extends JoinCompanyEvent {
  const CompanyCodeCleared();
}

/// Dispatched when the driver taps "Continue" to verify the entered code.
class VerifyCodeSubmitted extends JoinCompanyEvent {
  const VerifyCodeSubmitted();
}

/// Dispatched when the driver taps "Send request" on J04 to confirm joining.
class SendCompanyRequestSubmitted extends JoinCompanyEvent {
  const SendCompanyRequestSubmitted(this.company);
  final Company company;

  @override
  List<Object?> get props => [company];
}

/// Dispatched when the driver pulls down or taps the update indicator on J10.
class CheckForUpdatesRequested extends JoinCompanyEvent {
  const CheckForUpdatesRequested();
}

/// Dispatched when the driver confirms "Cancel request" on J10.
class CancelCompanyRequestSubmitted extends JoinCompanyEvent {
  const CancelCompanyRequestSubmitted();
}

/// Dispatched to reset flow back to J01 (e.g. tapping "Not my company" on J04).
class ResetToCodeInput extends JoinCompanyEvent {
  const ResetToCodeInput();
}

/// Dispatched on a cold start when the driver already has a request: reads
/// where it stands from the server (pending, approved or declined).
class ResumeRequestRequested extends JoinCompanyEvent {
  const ResumeRequestRequested();
}
