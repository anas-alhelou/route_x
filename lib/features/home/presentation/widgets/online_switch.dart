// lib/features/home/presentation/widgets/online_switch.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/motion.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';

/// The header's on-shift switch.
///
/// Hand-built rather than a themed [Switch] because the design's control is a
/// 44x24 track with an 18pt knob, a 3pt inset and a 10pt disconnected glyph
/// inside the knob while offline — none of which Material's switch exposes.
///
/// The control is also *locked* until the driver belongs to a fleet: [enabled]
/// false greys the tap out entirely rather than showing a disabled look and
/// still firing, so the rule is enforced by the widget and not only by the
/// bloc that also drops the event.
class OnlineSwitch extends StatelessWidget {
  const OnlineSwitch({
    required this.isOnline,
    required this.enabled,
    required this.onChanged,
    this.onLockedTap,
    this.hasGreenBorder = false,
    this.onLongPress,
    super.key,
  });

  /// Whether the driver is on shift.
  final bool isOnline;

  /// Whether the driver belongs to a fleet and the switch therefore responds.
  final bool enabled;

  /// Fires only when [enabled]; the header drops locked taps before this.
  final ValueChanged<bool> onChanged;

  /// Fires when the switch is tapped while locked.
  final VoidCallback? onLockedTap;

  /// Whether to render a green border around the track (pending / declined frames).
  final bool hasGreenBorder;

  /// Debug shortcut to toggle mock request states.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: isOnline,
      enabled: enabled,
      label: context.tr.homeGoOnlineSwitch,
      child: GestureDetector(
        onTap: enabled ? () => onChanged(!isOnline) : onLockedTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Motion.switchToggle,
          curve: Motion.switchToggleCurve,
          width: AppSizes.switchTrackW,
          height: AppSizes.switchTrackH,
          padding: const EdgeInsets.all(AppSpacing.s3),
          decoration: BoxDecoration(
            color: isOnline ? AppColors.brandMain : AppColors.borderSubtle,
            borderRadius: BorderRadius.circular(AppSizes.rPill),
            border: hasGreenBorder
                ? Border.all(color: AppColors.brandMain, width: AppSpacing.s1_5)
                : null,
          ),
          child: Row(
            children: [
              AnimatedAlign(
                duration: Motion.switchToggle,
                curve: Motion.switchToggleCurve,
                alignment: isOnline
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                  width: AppSizes.switchKnob,
                  height: AppSizes.switchKnob,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppSizes.rPill),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowKnob.withValues(alpha: 0.2),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  // The glyph only means anything while off — it is how the
                  // design says "you cannot receive routes yet".
                  child: isOnline
                      ? null
                      : SvgPicture.asset(
                          AppAssets.icWifiOffline,
                          width: AppSizes.iconXs,
                          height: AppSizes.iconXs,
                          colorFilter: ColorFilter.mode(
                            AppColors.borderDeactivated,
                            BlendMode.srcIn,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
