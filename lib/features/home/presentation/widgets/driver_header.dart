// lib/features/home/presentation/widgets/driver_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_profile.dart';
import 'package:routex_mobile/features/home/presentation/widgets/online_switch.dart';

/// The Home header: avatar, greeting, on-shift switch and the bell.
///
/// The switch is muted to the same #737373 the design uses for every other
/// secondary line rather than to a generic disabled grey, so the locked state
/// reads as "part of this screen" and not as a control that failed to load.
class DriverHeader extends StatelessWidget {
  const DriverHeader({
    required this.profile,
    required this.isOnline,
    required this.canToggleOnline,
    required this.onOnlineChanged,
    required this.onNotificationsTap,
    this.onLockedOnlineTap,
    this.hasGreenBorder = false,
    this.onSwitchLongPress,
    super.key,
  });

  final DriverProfile profile;
  final bool isOnline;
  final bool canToggleOnline;
  final ValueChanged<bool> onOnlineChanged;
  final VoidCallback onNotificationsTap;
  final VoidCallback? onLockedOnlineTap;
  final bool hasGreenBorder;
  final VoidCallback? onSwitchLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.s4,
        end: AppSpacing.s4,
      ),
      child: Row(
        children: [
          _Avatar(path: profile.avatarPath),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.homeGreeting,
                  style: AppTextStyles.greetingLabel.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  profile.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.driverName.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          OnlineSwitch(
            isOnline: isOnline,
            enabled: canToggleOnline,
            onChanged: onOnlineChanged,
            onLockedTap: onLockedOnlineTap,
            hasGreenBorder: hasGreenBorder,
            onLongPress: onSwitchLongPress,
          ),
          const SizedBox(width: AppSpacing.s16),
          _NotificationBell(onTap: onNotificationsTap),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: AppSizes.avatarMd,
      height: AppSizes.avatarMd,
      fit: BoxFit.cover,
      // The exported node is the composed avatar, ring and all. While the PNG
      // export is still blocked, degrade to the ring the design draws rather
      // than throwing a red box into the header.
      errorBuilder: (context, error, stackTrace) => Container(
        width: AppSizes.avatarMd,
        height: AppSizes.avatarMd,
        decoration: BoxDecoration(
          color: AppColors.brandSecondary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandMain),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      // 28 is the design's glyph box; the 48 default tap target would push the
      // header off its 48pt height.
      iconSize: AppSizes.iconLg,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: AppSizes.iconLg,
        height: AppSizes.iconLg,
      ),
      icon: SvgPicture.asset(
        AppAssets.icBell,
        width: AppSizes.iconLg,
        height: AppSizes.iconLg,
        colorFilter: ColorFilter.mode(
          AppColors.textPrimary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
