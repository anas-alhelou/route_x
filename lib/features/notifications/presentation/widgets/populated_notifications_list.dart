// lib/features/notifications/presentation/widgets/populated_notifications_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:routex_mobile/features/notifications/presentation/widgets/notification_card.dart';

/// Populated Notifications List matching Figma N01.
class PopulatedNotificationsList extends StatelessWidget {
  const PopulatedNotificationsList({required this.notifications, super.key});

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    // Partition into "New" (unread) and "Earlier" (read)
    final newItems = notifications.where((n) => !n.isRead).toList();
    final earlierItems = notifications.where((n) => n.isRead).toList();

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.screenGutter.w),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        if (newItems.isNotEmpty) ...[
          _SectionHeader(label: context.tr.notificationsSectionNew),
          SizedBox(height: 10.h),
          ...List.generate(newItems.length, (i) => Padding(
                padding: EdgeInsets.only(
                  bottom: i == newItems.length - 1 ? 0 : AppSpacing.s10.h,
                ),
                child: NotificationCard(
                  notification: newItems[i],
                  isNewSection: true,
                ),
              )),
          SizedBox(height: 18.h),
        ],
        if (earlierItems.isNotEmpty) ...[
          _SectionHeader(label: context.tr.notificationsSectionEarlier),
          SizedBox(height: 10.h),
          ...List.generate(earlierItems.length, (i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.s10.h),
                child: NotificationCard(
                  notification: earlierItems[i],
                  isNewSection: false,
                ),
              )),
        ],
        SizedBox(height: AppSpacing.s32.h),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppFonts.fontFamilySatoshi,
        fontFamilyFallback: AppFonts.fontFamilyFallback,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 17 / 12,
      ),
    );
  }
}
