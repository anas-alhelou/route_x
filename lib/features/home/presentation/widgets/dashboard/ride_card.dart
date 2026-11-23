// lib/features/home/presentation/widgets/dashboard/ride_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';

/// A single upcoming ride: passenger, route, logistics and scheduled time.
class RideCard extends StatelessWidget {
  const RideCard({required this.ride, super.key});

  final UpcomingRideEntity ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCard.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PassengerAvatar(
                imageUrl: ride.passengerImageUrl,
                name: ride.passengerName,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.passengerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilySatoshi,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 14.r, color: AppColors.warning),
                        SizedBox(width: 2.w),
                        Text(
                          ride.passengerRating.toStringAsFixed(1),
                          style: _muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _TimePill(formatted: ride.formattedTime),
            ],
          ),
          SizedBox(height: 12.h),
          _RouteLine(
            icon: Icons.trip_origin,
            color: AppColors.brandMain,
            text: ride.pickupLocation,
          ),
          SizedBox(height: 6.h),
          _RouteLine(
            icon: Icons.place,
            color: AppColors.textPrimary,
            text: ride.dropoffLocation,
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: AppColors.textUnderline),
          SizedBox(height: 10.h),
          Row(
            children: [
              _Metric(
                icon: Icons.straighten,
                label: '${ride.distance.toStringAsFixed(1)} km',
              ),
              SizedBox(width: 16.w),
              _Metric(icon: Icons.schedule, label: '${ride.duration.inMinutes} min'),
              const Spacer(),
              Text(
                'SAR ${ride.fare.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle get _muted => TextStyle(
        fontFamily: AppFonts.fontFamilySatoshi,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );
}

class _PassengerAvatar extends StatelessWidget {
  const _PassengerAvatar({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppColors.surfaceTint,
      child: Icon(Icons.person, size: 20.r, color: AppColors.textMuted),
    );
    return Semantics(
      image: true,
      label: 'Passenger avatar for $name',
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: imageUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15.r, color: AppColors.textMuted),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.formatted});

  final String formatted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        formatted,
        style: TextStyle(
          fontFamily: AppFonts.fontFamilySatoshi,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.brandBlack,
        ),
      ),
    );
  }
}
