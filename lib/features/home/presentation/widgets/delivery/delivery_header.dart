// lib/features/home/presentation/widgets/delivery/delivery_header.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'package:routex_mobile/core/services/location/timezone_date_formatter.dart';
import 'package:routex_mobile/core/services/location/user_location.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';
import 'package:routex_mobile/core/widgets/routex_avatar.dart';

/// Header for the delivery dashboard — Figma HM1–HM6 top row (360 x 55 at top 58).
///
/// Left: profile photo 52 x 52 with lime-green border ring, 12px gap,
/// column with date line (17 high) above greeting line (34 high, "Morning, Hamza").
/// Right: notifications bell button 44 x 44 containing 28 x 28 bell SVG icon.
class DeliveryHeader extends StatelessWidget {
  const DeliveryHeader({
    required this.driverName,
    required this.profileImagePath,
    required this.dateLabel,
    required this.onNotificationsTap,
    this.userLocation,
    this.onLocationChanged,
    this.onScenarioCycleTap,
    this.onToggleNotificationOverlay,
    super.key,
  });

  final String driverName;
  final String profileImagePath;

  /// Pre-formatted: "Sunday, 11 October".
  final String dateLabel;

  final VoidCallback onNotificationsTap;

  /// Optional user location for manual override or display.
  final UserLocation? userLocation;

  /// Optional callback invoked when location changes.
  final ValueChanged<UserLocation>? onLocationChanged;

  /// Debug-only: cycles the mock scenario.
  final VoidCallback? onScenarioCycleTap;

  /// Debug-only: toggles the in-app notification overlay.
  final VoidCallback? onToggleNotificationOverlay;

  String _greeting(BuildContext context) {
    final localTime = userLocation != null
        ? TimezoneDateFormatter.getLocalDateTime(location: userLocation)
        : DateTime.now();
    final hour = localTime.hour;
    if (hour < 12) return context.tr.homeGreetingMorning;
    if (hour < 17) return context.tr.homeGreetingAfternoon;
    return context.tr.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 55.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Profile Photo (52 x 52 with lime-green border ring) ────────────
          GestureDetector(
            onLongPress: kDebugMode ? onScenarioCycleTap : null,
            onDoubleTap: kDebugMode ? onToggleNotificationOverlay : null,
            child: _ProfileAvatar(path: profileImagePath, name: driverName),
          ),
          SizedBox(width: AppSpacing.s12.w),

          // ── Date line (17h) + Greeting line (34h) ───────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                    height: 17 / 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // A long first name shrinks to fit instead of being cut off.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.tr.homeGreetingWithName(
                      _greeting(context),
                      driverName,
                    ),
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.56,
                      color: AppColors.textPrimary,
                      height: 38 / 28,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // ── Notifications bell button (44 x 44, icon 28 x 28) ──────────────
          _BellButton(onTap: onNotificationsTap),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.path, required this.name});

  final String path;
  final String name;

  @override
  Widget build(BuildContext context) {
    return RouteXAvatar(
      size: AppSizes.avatarLg.r,
      photo: path,
      name: name,
      ringColor: AppColors.brandMain,
      ringWidth: 2.r,
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: AppSizes.bellButton.r,
        height: AppSizes.bellButton.r,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.icBell,
              width: 28.r,
              height: 28.r,
              colorFilter: ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            PositionedDirectional(
              top: 10.r,
              end: 11.r,
              child: ValueListenableBuilder<int>(
                valueListenable: NotificationInboxBadge.unread,
                builder: (_, unread, __) => unread == 0
                    ? const SizedBox.shrink()
                    : Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surfaceWhite,
                            width: 1.5.r,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
