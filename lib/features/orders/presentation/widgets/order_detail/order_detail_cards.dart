// lib/features/orders/presentation/widgets/order_detail/order_detail_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../orders_today/orders_today_metrics.dart';
import 'order_detail_metrics.dart';

/// The white bordered card every section of the detail screen sits in,
/// headed by a small-caps [label].
///
/// Every card is headed the same way so the driver can skim the labels down
/// the left edge and land on the one they need — address at the door,
/// window when running late, note before ringing.
class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: OrderDetailMetrics.cardPaddingH.w,
        vertical: OrderDetailMetrics.cardPaddingV.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(OrderDetailMetrics.cardRadius.r),
        border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.s10Bold.scaled.copyWith(
              height: 1.4,
              color: AppColors.textMuted,
              letterSpacing: 0.2.sp,
            ),
          ),
          SizedBox(height: OrderDetailMetrics.labelToContent.h),
          child,
        ],
      ),
    );
  }
}

// ── Address ──────────────────────────────────────────────────────────────

class OrderAddressCard extends StatelessWidget {
  const OrderAddressCard({
    super.key,
    required this.label,
    required this.addressLine,
    required this.addressDetails,
    this.gateCodeLabel,
    this.gateCode,
    this.emphasizeGateCode = false,
  });

  final String label;
  final String addressLine;

  /// Building / floor / flat. Empty hides the line.
  final String addressDetails;

  final String? gateCodeLabel;

  /// Null hides the badge entirely.
  final String? gateCode;

  /// Outlines the gate code — for the stop the driver is about to reach.
  final bool emphasizeGateCode;

  @override
  Widget build(BuildContext context) {
    return OrderInfoCard(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            addressLine,
            style: AppTextStyles.s16Bold.scaled
                .copyWith(height: 1.4, color: AppColors.brandBlack),
          ),
          if (addressDetails.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              addressDetails,
              style: AppTextStyles.s14Regular.scaled.copyWith(
                fontSize: 13.sp,
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (gateCode != null && gateCodeLabel != null) ...[
            SizedBox(height: 12.h),
            GateCodeBadge(
              label: gateCodeLabel!,
              code: gateCode!,
              emphasized: emphasizeGateCode,
            ),
          ],
        ],
      ),
    );
  }
}

/// The one piece of the address the driver must read off the screen at the
/// gate, so it gets the warmest surface on the page and the largest digits.
///
/// [emphasized] adds an outline on the stop being driven to: minutes from
/// the gate, it is the next thing the driver will need, so it should be the
/// first thing their eye lands on.
class GateCodeBadge extends StatelessWidget {
  const GateCodeBadge({
    super.key,
    required this.label,
    required this.code,
    this.emphasized = false,
  });

  final String label;
  final String code;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.statusAmberSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: emphasized
            ? Border.all(color: AppColors.statusAmber, width: 1.w)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.s12Medium.scaled
                .copyWith(height: 1.4, color: AppColors.statusAmber),
          ),
          SizedBox(width: 8.w),
          Text(
            code,
            style: AppTextStyles.s16Bold.scaled.copyWith(
              fontSize: 15.sp,
              height: 1.4,
              color: AppColors.brandBlack,
              letterSpacing: 1.2.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delivery window ──────────────────────────────────────────────────────

class OrderDeliveryWindowCard extends StatelessWidget {
  const OrderDeliveryWindowCard({
    super.key,
    required this.label,
    required this.timeWindow,
    required this.etaLabel,
    required this.isOnTime,
    this.onEtaPressed,
  });

  final String label;
  final String timeWindow;
  final String etaLabel;
  final bool isOnTime;
  final VoidCallback? onEtaPressed;

  @override
  Widget build(BuildContext context) {
    return OrderInfoCard(
      label: label,
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              // The window is the one figure on this card the driver plans
              // around; shrink it before ever wrapping it.
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                timeWindow,
                style: AppTextStyles.s20Bold.scaled
                    .copyWith(height: 1.4, color: AppColors.brandBlack),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Flexible, not fixed: the Arabic copy or a large system text
          // size would otherwise push the pill past the card edge.
          Flexible(
            child: EtaPill(
              label: etaLabel,
              isOnTime: isOnTime,
              onPressed: onEtaPressed,
            ),
          ),
        ],
      ),
    );
  }
}

/// Projected arrival against the promised window. Green while it fits;
/// red the moment it does not, so a late stop is visible without reading.
class EtaPill extends StatelessWidget {
  const EtaPill({
    super.key,
    required this.label,
    required this.isOnTime,
    this.onPressed,
  });

  final String label;
  final bool isOnTime;

  /// Null renders the pill as a plain status, not a button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = isOnTime ? AppColors.brandMain : AppColors.error;
    final radius = BorderRadius.circular(999.r);

    return Semantics(
      button: onPressed != null,
      child: Material(
        color: isOnTime ? AppColors.iconBrand : AppColors.iconWarning,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: accent, width: 1.w),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: _content(accent),
        ),
      ),
    );
  }

  Widget _content(Color accent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.svg.eta.svg(
            width: 16.w,
            height: 16.w,
            colorFilter: isOnTime
                ? null
                : ColorFilter.mode(accent, BlendMode.srcIn),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.s11Bold.scaled
                  .copyWith(height: 1.4, color: accent),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Packages ─────────────────────────────────────────────────────────────

class OrderPackagesCard extends StatelessWidget {
  const OrderPackagesCard({
    super.key,
    required this.label,
    required this.countLabel,
    required this.scannedLabel,
    required this.requirements,
  });

  final String label;
  final String countLabel;
  final String scannedLabel;

  /// Already-localized chip labels.
  final List<String> requirements;

  @override
  Widget build(BuildContext context) {
    return OrderInfoCard(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  countLabel,
                  style: AppTextStyles.s16Bold.scaled
                      .copyWith(height: 1.4, color: AppColors.brandBlack),
                ),
              ),
              Text(
                scannedLabel,
                style: AppTextStyles.s14Medium.scaled.copyWith(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (requirements.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final requirement in requirements)
                  _RequirementChip(label: requirement),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  const _RequirementChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceBadge,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.s12Bold.scaled
            .copyWith(height: 1.4, color: AppColors.brandBlack),
      ),
    );
  }
}

// ── Note from dispatch ───────────────────────────────────────────────────

class OrderDispatchNoteCard extends StatelessWidget {
  const OrderDispatchNoteCard({
    super.key,
    required this.label,
    required this.note,
  });

  final String label;
  final String note;

  @override
  Widget build(BuildContext context) {
    return OrderInfoCard(
      label: label,
      child: Text(
        note,
        style: AppTextStyles.s14Regular.scaled
            .copyWith(height: 1.4, color: AppColors.brandBlack),
      ),
    );
  }
}
