import 'package:equatable/equatable.dart';

enum PermissionType { location, notification, gallery }

enum PermissionStateStatus { granted, denied, permanentlyDenied, restricted }

class PermissionStatusEntity extends Equatable {
  final PermissionType type;
  final PermissionStateStatus status;

  const PermissionStatusEntity({
    required this.type,
    required this.status,
  });

  @override
  List<Object?> get props => [type, status];
}
