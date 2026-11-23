import 'package:equatable/equatable.dart';

enum StopDeliveryStatus { upcoming, current, delivered, failed }

class StopStatusInfo extends Equatable {
  const StopStatusInfo({
    required this.stopId,
    required this.status,
    this.failureReasonCode,
    this.failureReasonText,
  });

  final String stopId;
  final StopDeliveryStatus status;
  final String? failureReasonCode;
  final String? failureReasonText;

  @override
  List<Object?> get props => [stopId, status, failureReasonCode, failureReasonText];
}
