// lib/features/home/data/models/driver_model.dart
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';

/// Data-layer shape of a [DriverEntity].
class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    super.profileImageUrl,
    required super.vehicleType,
    required super.vehicleNumber,
    required super.licenseNumber,
    required super.rating,
    required super.reviewCount,
    required super.isVerified,
    required super.joinDate,
    required super.totalEarnings,
    required super.weeklyEarnings,
    required super.referralBonus,
    required super.yearsActive,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profileImageUrl:
          json['profileImageUrl'] as String? ?? json['profile_image_url'] as String?,
      vehicleType: json['vehicleType'] as String? ?? json['vehicle_type'] as String? ?? '',
      vehicleNumber:
          json['vehicleNumber'] as String? ?? json['vehicle_number'] as String? ?? '',
      licenseNumber:
          json['licenseNumber'] as String? ?? json['license_number'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:
          (json['reviewCount'] as num?)?.toInt() ?? (json['review_count'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] as bool? ?? json['is_verified'] as bool? ?? false,
      joinDate: DateTime.tryParse(
            json['joinDate'] as String? ?? json['join_date'] as String? ?? '',
          ) ??
          DateTime.now(),
      totalEarnings:
          (json['totalEarnings'] as num?)?.toDouble() ?? (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings:
          (json['weeklyEarnings'] as num?)?.toDouble() ?? (json['weekly_earnings'] as num?)?.toDouble() ?? 0.0,
      referralBonus:
          (json['referralBonus'] as num?)?.toDouble() ?? (json['referral_bonus'] as num?)?.toDouble() ?? 0.0,
      yearsActive:
          (json['yearsActive'] as num?)?.toInt() ?? (json['years_active'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'joinDate': joinDate.toIso8601String(),
      'totalEarnings': totalEarnings,
      'weeklyEarnings': weeklyEarnings,
      'referralBonus': referralBonus,
      'yearsActive': yearsActive,
    };
  }

  DriverEntity toEntity() {
    return DriverEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: licenseNumber,
      rating: rating,
      reviewCount: reviewCount,
      isVerified: isVerified,
      joinDate: joinDate,
      totalEarnings: totalEarnings,
      weeklyEarnings: weeklyEarnings,
      referralBonus: referralBonus,
      yearsActive: yearsActive,
    );
  }
}
