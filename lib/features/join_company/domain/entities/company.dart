import 'package:equatable/equatable.dart';

/// Company entity representing a delivery organization the driver can join.
class Company extends Equatable {
  const Company({
    required this.id,
    required this.name,
    required this.code,
    required this.logoAsset,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String code;
  final String logoAsset;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, code, logoAsset, isActive];
}
