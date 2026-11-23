import 'package:equatable/equatable.dart';
import 'stop_status.dart';

class RouteStopSummary extends Equatable {
  const RouteStopSummary({
    required this.stopId,
    required this.customerName,
    required this.status,
    this.failureReasonText,
    required this.timeText,
  });

  final String stopId;
  final String customerName;
  final StopDeliveryStatus status;
  final String? failureReasonText;
  final String timeText;

  @override
  List<Object?> get props => [stopId, customerName, status, failureReasonText, timeText];
}

class ReturnPackageTask extends Equatable {
  const ReturnPackageTask({
    required this.customerNames,
    required this.depotName,
    required this.depotDistanceText,
    this.orderIds = const [],
    this.failureReasons = const [],
  });

  final List<String> customerNames;
  final String depotName;
  final String depotDistanceText;
  final List<String> orderIds;
  final List<String> failureReasons;

  String get customerName => customerNames.join(', ');
  String get orderId => orderIds.join(', ');
  String get failureReason => failureReasons.join(', ');

  @override
  List<Object?> get props => [customerNames, depotName, depotDistanceText, orderIds, failureReasons];
}

class RouteSummary extends Equatable {
  const RouteSummary({
    required this.date,
    required this.driverName,
    required this.deliveredCount,
    required this.failedCount,
    required this.totalStopsCount,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.stopSummaries,
    this.returnTask,
  });

  final DateTime date;
  final String driverName;
  final int deliveredCount;
  final int failedCount;
  final int totalStopsCount;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final List<RouteStopSummary> stopSummaries;
  final ReturnPackageTask? returnTask;

  @override
  List<Object?> get props => [
        date,
        driverName,
        deliveredCount,
        failedCount,
        totalStopsCount,
        totalDistanceKm,
        totalDurationMinutes,
        stopSummaries,
        returnTask,
      ];
}
