// lib/features/home/domain/entities/driver_entity.dart
import 'package:equatable/equatable.dart';

/// Represents a driver with full profile information.
///
/// This entity encapsulates identity, vehicle, ratings, and earnings data.
class DriverEntity extends Equatable {
  const DriverEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNumber,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.joinDate,
    required this.totalEarnings,
    required this.weeklyEarnings,
    required this.referralBonus,
    required this.yearsActive,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImageUrl;

  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;

  final double rating;
  final int reviewCount;

  final bool isVerified;
  final DateTime joinDate;

  final double totalEarnings;
  final double weeklyEarnings;
  final double referralBonus;

  final int yearsActive;

  /// Full name computed from first and last name.
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        profileImageUrl,
        vehicleType,
        vehicleNumber,
        licenseNumber,
        rating,
        reviewCount,
        isVerified,
        joinDate,
        totalEarnings,
        weeklyEarnings,
        referralBonus,
        yearsActive,
      ];
}
