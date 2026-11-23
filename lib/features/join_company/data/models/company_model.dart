import 'package:routex_mobile/core/config/constants/app_assets.dart';
import '../../domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    required super.code,
    required super.logoAsset,
    super.isActive = true,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      logoAsset: json['logoAsset'] as String? ?? AppAssets.imgFleetRedSeaExpress,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'logoAsset': logoAsset,
      'isActive': isActive,
    };
  }

  factory CompanyModel.fromEntity(Company entity) {
    return CompanyModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      logoAsset: entity.logoAsset,
      isActive: entity.isActive,
    );
  }
}
