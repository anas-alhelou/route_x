// lib/features/home/presentation/widgets/dashboard/upcoming_rides_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/empty_state_widget.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/ride_card.dart';

/// Vertical stack of upcoming [RideCard]s, or an empty state when there are
/// none.
class UpcomingRidesSection extends StatelessWidget {
  const UpcomingRidesSection({required this.rides, super.key});

  final List<UpcomingRideEntity> rides;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming rides',
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        if (rides.isEmpty)
          const EmptyStateWidget(
            title: 'No upcoming rides',
            message: 'New ride requests will appear here.',
            icon: Icons.directions_car_outlined,
          )
        else
          for (final ride in rides) ...[
            RideCard(ride: ride),
            if (ride != rides.last) SizedBox(height: 12.h),
          ],
      ],
    );
  }
}
