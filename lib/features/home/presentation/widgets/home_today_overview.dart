// lib/features/home/presentation/widgets/home_today_overview.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_header.dart';
import 'package:routex_mobile/features/home/presentation/widgets/shift_stats_row.dart';

/// "Today's overview" — the only Home section that is not a card.
///
/// Takes the whole [HomeOverview] rather than just the stats because the trailing
/// hint is not a property of the stats: it is a fixed design string that only
/// makes sense next to them. Passing the overview keeps the call site in the page
/// down to `HomeTodayOverview(overview: overview)` and leaves the layout here.
///
/// The heading is inset 4pt from the screen gutter and dropped 16pt below the
/// header, rather than sharing the card sections' 12pt inset — the design draws
/// this one heading that way, and it is the only heading drawn that way.
class HomeTodayOverview extends StatelessWidget {
  const HomeTodayOverview({super.key, required this.overview});

  /// The snapshot this section summarises.
  final HomeOverview overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.s4,
            AppSpacing.s16,
            AppSpacing.s4,
            0,
          ),
          child: HomeSectionHeader(
            title: context.tr.homeTodayOverview,
            trailing: Text(
              context.tr.homeOverviewStartsFirstShift,
              style: AppTextStyles.sectionHint.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s12.w),
        ShiftStatsRow(stats: overview.stats),
      ],
    );
  }
}