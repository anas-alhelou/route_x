// lib/features/home/domain/entities/driver_status_entity.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Driver status enumeration.
enum DriverStatus { online, offline, onRide, onBreak }

/// Represents driver availability status with timing information.
class DriverStatusEntity extends Equatable {
  const DriverStatusEntity({
    required this.status,
    required this.lastUpdated,
    this.onlineForDuration,
  });

  final DriverStatus status;
  final DateTime lastUpdated;
  final Duration? onlineForDuration;

  /// Whether the driver is online.
  bool get isOnline => status == DriverStatus.online;

  /// Whether the driver is offline.
  bool get isOffline => status == DriverStatus.offline;

  /// Whether the driver is busy (on ride or on break).
  bool get isBusy => status == DriverStatus.onRide || status == DriverStatus.onBreak;

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case DriverStatus.online:
        return 'Online';
      case DriverStatus.offline:
        return 'Offline';
      case DriverStatus.onRide:
        return 'On Ride';
      case DriverStatus.onBreak:
        return 'On Break';
    }
  }

  /// Status color.
  Color get statusColor {
    switch (status) {
      case DriverStatus.online:
        return Colors.green;
      case DriverStatus.offline:
        return Colors.grey;
      case DriverStatus.onRide:
        return Colors.blue;
      case DriverStatus.onBreak:
        return Colors.orange;
    }
  }

  @override
  List<Object?> get props => [status, lastUpdated, onlineForDuration];
}
