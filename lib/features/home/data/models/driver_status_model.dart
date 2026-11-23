// lib/features/home/data/models/driver_status_model.dart
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';

/// Data-layer shape of a [DriverStatusEntity].
class DriverStatusModel extends DriverStatusEntity {
  const DriverStatusModel({
    required super.status,
    required super.lastUpdated,
    super.onlineForDuration,
  });

  factory DriverStatusModel.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        json['status'] as String? ?? json['driverStatus'] as String? ?? '';
    final durationSeconds = (json['onlineForDuration'] as num?)?.toInt() ??
        (json['online_for_duration'] as num?)?.toInt();

    return DriverStatusModel(
      status: DriverStatus.values.firstWhere(
        (value) => value.name == rawStatus,
        orElse: () => DriverStatus.offline,
      ),
      lastUpdated: DateTime.tryParse(
            json['lastUpdated'] as String? ?? json['last_updated'] as String? ?? '',
          ) ??
          DateTime.now(),
      onlineForDuration:
          durationSeconds == null ? null : Duration(seconds: durationSeconds),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'lastUpdated': lastUpdated.toIso8601String(),
      'onlineForDuration': onlineForDuration?.inSeconds,
    };
  }

  DriverStatusEntity toEntity() {
    return DriverStatusEntity(
      status: status,
      lastUpdated: lastUpdated,
      onlineForDuration: onlineForDuration,
    );
  }
}
