// lib/features/home/presentation/widgets/home_get_started_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/home/domain/entities/setup_progress.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/home_section_header.dart';
import 'package:routex_mobile/features/home/presentation/widgets/setup_steps_card.dart';

/// The "Get started" card: the setup checklist and the action that unblocks it.
///
/// Takes [SetupProgress] rather than the whole overview, and the destination as a
/// callback rather than navigating itself. Two reasons, both about this widget
/// not knowing more than it needs: the checklist is the only part of the
/// snapshot it draws, and the navigation target belongs to the page, which is the
/// layer that knows where the driver came from.
class HomeGetStartedCard extends StatelessWidget {
  const HomeGetStartedCard({
    super.key,
    required this.progress,
    required this.onTap,
  });

  /// Which of the three gates are done.
  final SetupProgress progress;

  /// Sends the driver to fleet search.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: context.tr.homeGetStarted),
          SizedBox(height: AppSpacing.s10.w),
          SetupStepsCard(progress: progress, onTap: onTap),
        ],
      ),
    );
  }
}