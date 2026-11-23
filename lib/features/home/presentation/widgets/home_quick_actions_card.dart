// lib/features/home/presentation/widgets/home_quick_actions_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_header.dart';
import 'package:routex_mobile/features/home/presentation/widgets/quick_action_tile.dart';

/// The "Quick actions" card: browse for a fleet, or enter a fleet code.
///
/// The only Home section with a fixed height
/// ([AppSizes.quickActionsCardH]) — the design draws it at 200 so its two rows
/// sit centred in a fixed panel instead of hugging the heading, and the card
/// would otherwise shrink-wrap to its content.
class HomeQuickActionsCard extends StatelessWidget {
  const HomeQuickActionsCard({
    super.key,
    required this.onFindFleet,
    required this.onEnterFleetCode,
  });

  /// Opens fleet search.
  final VoidCallback onFindFleet;

  /// Opens the Enter Fleet Code screen.
  final VoidCallback onEnterFleetCode;

  @override
  Widget build(BuildContext context) {
    return HomeSectionCard(
      height: AppSizes.quickActionsCardH,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: context.tr.homeQuickActions),
          SizedBox(height: AppSpacing.s10.w),
          QuickActionTile(
            iconPath: AppAssets.icSearch,
            label: context.tr.homeFindAFleet,
            onTap: onFindFleet,
          ),
          SizedBox(height: AppSpacing.s10.w),
          QuickActionTile(
            iconPath: AppAssets.icKey,
            label: context.tr.homeEnterFleetCode,
            onTap: onEnterFleetCode,
          ),
        ],
      ),
    );
  }
}