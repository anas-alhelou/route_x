// lib/features/home/presentation/widgets/home_fleets_near_you_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_row.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_header.dart';

/// The "Fleets near you" card: the three seeded fleets, each with a Join button.
///
/// Joining is reported through [onJoin] rather than dispatched from here. This
/// widget used to call `context.read<HomeBloc>()` itself, which meant it could
/// only ever be used under a Home page — the section was untestable on its own
/// and could not be reused on another screen even though nothing about it is
/// Home-specific.
class HomeFleetsNearYouCard extends StatelessWidget {
  const HomeFleetsNearYouCard({
    super.key,
    required this.fleets,
    required this.isJoining,
    required this.hasPendingRequest,
    required this.onJoin,
    required this.onSeeAll,
  });

  /// The fleets to list, in the order the data layer returned them.
  final List<FleetSummary> fleets;

  /// Whether a join is in flight; shows every row's spinner and disables Join.
  final bool isJoining;

  /// Whether the driver already has a request awaiting review.
  ///
  /// Passed in rather than read from a BLoC or an overview: a driver can only be
  /// waiting on one review at a time, so once a request is pending no row may
  /// start another, and that is a fact about the driver rather than about the
  /// list being drawn.
  final bool hasPendingRequest;

  /// Reports a Join press for [fleetId].
  final ValueChanged<String> onJoin;

  /// Opens the full fleet list.
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return HomeSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: context.tr.homeFleetsNearYou,
            trailing: Text(
              context.tr.homeSeeAll,
              style: AppTextStyles.statLabel.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            onTrailingTap: onSeeAll,
          ),
          SizedBox(height: AppSpacing.s10.w),
          for (final fleet in fleets)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.s10.w),
              child: FleetRow(
                fleet: fleet,
                isJoining: isJoining,
                isJoinEnabled: fleet.canJoin && !hasPendingRequest,
                onJoin: () => onJoin(fleet.id),
              ),
            ),
        ],
      ),
    );
  }
}