// lib/features/notifications/presentation/widgets/notification_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.isNewSection,
    super.key,
  });

  final AppNotification notification;
  final bool isNewSection;

  Color get _iconContainerBg {
    if (isNewSection) {
      return AppColors.brandMain;
    }
    return AppColors.dividerSubtle;
  }

  Widget _buildIcon() {
    switch (notification.kind) {
      case AppNotificationKind.newOrder:
      case AppNotificationKind.dispatchMessage:
      case AppNotificationKind.system:
        return SvgPicture.asset(
          AppAssets.icPackage,
          width: AppSizes.iconSm.r,
          height: AppSizes.iconSm.r,
          colorFilter: ColorFilter.mode(
            AppColors.textBlack,
            BlendMode.srcIn,
          ),
        );

      case AppNotificationKind.orderCancelled:
      case AppNotificationKind.fleetReply:
        return SvgPicture.asset(
          AppAssets.icBan,
          width: AppSizes.iconSm.r,
          height: AppSizes.iconSm.r,
          colorFilter: ColorFilter.mode(
            AppColors.textBlack,
            BlendMode.srcIn,
          ),
        );

      case AppNotificationKind.routeStarted:
      case AppNotificationKind.routeUpdate:
        return SvgPicture.asset(
          AppAssets.icRoute,
          width: AppSizes.iconSm.r,
          height: AppSizes.iconSm.r,
          colorFilter: ColorFilter.mode(
            AppColors.textBlack,
            BlendMode.srcIn,
          ),
        );

      case AppNotificationKind.vehicleUpdated:
        return SvgPicture.asset(
          AppAssets.icVan,
          width: 22.w,
          height: 15.h,
          fit: BoxFit.contain,
        );

      case AppNotificationKind.fleetApproved:
        return SvgPicture.asset(
          AppAssets.icCheckCircle,
          width: AppSizes.iconSm.r,
          height: AppSizes.iconSm.r,
          colorFilter: ColorFilter.mode(
            AppColors.textBlack,
            BlendMode.srcIn,
          ),
        );
    }
  }

  String _resolveTitle(BuildContext context) {
    switch (notification.kind) {
      case AppNotificationKind.newOrder:
        return context.tr.notifNewOrderOfferedTitle;
      case AppNotificationKind.orderCancelled:
        return context.tr.notifOrderCancelledTitle;
      case AppNotificationKind.routeStarted:
        return context.tr.notifRouteStartedTitle;
      case AppNotificationKind.vehicleUpdated:
        return context.tr.notifVehicleUpdatedTitle;
      case AppNotificationKind.fleetApproved:
        return context.tr.notifYoureApprovedTitle;
      default:
        return notification.title;
    }
  }

  String _resolveBody(BuildContext context) {
    switch (notification.kind) {
      case AppNotificationKind.newOrder:
        return context.tr.notifNewOrderOfferedBody;
      case AppNotificationKind.orderCancelled:
        return context.tr.notifOrderCancelledBody;
      case AppNotificationKind.routeStarted:
        return context.tr.notifRouteStartedBody;
      case AppNotificationKind.vehicleUpdated:
        return context.tr.notifVehicleUpdatedBody;
      case AppNotificationKind.fleetApproved:
        return context.tr.notifYoureApprovedBody;
      default:
        return notification.body;
    }
  }

  String _resolveTime(BuildContext context) {
    switch (notification.kind) {
      case AppNotificationKind.newOrder:
        return context.tr.notifTime2m;
      case AppNotificationKind.orderCancelled:
        return context.tr.notifTime1h;
      case AppNotificationKind.routeStarted:
        return context.tr.notifTimeYesterday;
      case AppNotificationKind.vehicleUpdated:
        return context.tr.notifTime2d;
      case AppNotificationKind.fleetApproved:
        return context.tr.notifTime3d;
      default:
        return notification.timeLabel ??
            _formatRelativeTime(notification.createdAt);
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;

    // "New" card: Light-green tinted fill with crisp 1px lime-green border stroke.
    // "Earlier" card: White fill with subtle light-gray border.
    final Color cardBackground = isNewSection
        ? AppColors.surfaceUpNext
        : AppColors.surfaceWhite;

    final Color cardBorderColor = isNewSection
        ? AppColors.brandMain
        : AppColors.dividerSubtle;

    // The "Order cancelled" row carries a 36 icon disc; every other kind is 40.
    final double iconDisc = notification.kind == AppNotificationKind.orderCancelled
        ? 36
        : AppSizes.avatarSm;

    return Container(
      width: double.infinity,
      // 15 from the outer edge in the design = 1 border + 14 padding.
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.r16.r),
        border: Border.all(
          color: cardBorderColor,
          width: AppSpacing.s1,
        ),
      ),
      child: Stack(
        children: [
          Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 40 x 40 circular icon container at inset 15
          Container(
            width: iconDisc.r,
            height: iconDisc.r,
            decoration: BoxDecoration(
              color: _iconContainerBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildIcon(),
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),

          // Text column starting at x:67 inside card (15 + 40 + 12 = 67)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        _resolveTitle(context),
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontFamilyFallback: AppFonts.fontFamilyFallback,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 18 / 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    Text(
                      _resolveTime(context),
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilySatoshi,
                        fontFamilyFallback: AppFonts.fontFamilyFallback,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 18 / 12,
                      ),
                    ),
                    // Unread rows reserve room for the dot (8) + 13 gap so the
                    // time stops 21 short of the right edge.
                    if (isUnread) SizedBox(width: 21.w),
                  ],
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  _resolveBody(context),
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                    height: 17 / 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
          // 8 x 8 solid green unread dot in the top-right corner (x:337, y:15)
          if (isUnread)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Container(
                width: AppSizes.r8.r,
                height: AppSizes.r8.r,
                decoration: const BoxDecoration(
                  color: AppColors.brandMain,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
