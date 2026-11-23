// lib/features/orders/presentation/widgets/offers/offer_decline_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../../domain/entities/order_offer_entity.dart';
import '../orders_today/orders_today_metrics.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

/// "Why are you declining?" — one reason, picked before the order goes.
/// Pops with the reason, or null for "Keep the order".
class OfferDeclineSheet extends StatefulWidget {
  const OfferDeclineSheet({super.key, required this.fleetName});

  final String fleetName;

  static Future<OfferDeclineReason?> show(
    BuildContext context, {
    required String fleetName,
  }) {
    return showRoutexSheet<OfferDeclineReason>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      barrierColor: AppColors.brandBlack.withValues(alpha: 0.32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) => OfferDeclineSheet(fleetName: fleetName),
    );
  }

  @override
  State<OfferDeclineSheet> createState() => _OfferDeclineSheetState();
}

class _OfferDeclineSheetState extends State<OfferDeclineSheet> {
  OfferDeclineReason? _reason;

  static String _label(AppLocalizations l10n, OfferDeclineReason reason) =>
      switch (reason) {
        OfferDeclineReason.vanFull => l10n.offerReasonVanFull,
        OfferDeclineReason.outsideArea => l10n.offerReasonOutsideArea,
        OfferDeclineReason.shiftEnds => l10n.offerReasonShiftEnds,
        OfferDeclineReason.other => l10n.offerReasonOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final reason = _reason;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.borderDeactivated,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              l10n.offerDeclineTitle,
              style: AppTextStyles.s24Bold.scaled.copyWith(
                fontSize: 22.sp,
                height: 1.35,
                letterSpacing: -0.22.sp,
                color: AppColors.brandBlack,
              ),
            ),
            SizedBox(height: 14.h),
            for (final option in OfferDeclineReason.values) ...[
              if (option != OfferDeclineReason.values.first)
                SizedBox(height: 8.h),
              _ReasonOption(
                label: _label(l10n, option),
                selected: option == reason,
                onTap: () => setState(() => _reason = option),
              ),
            ],
            SizedBox(height: 14.h),
            Text(
              l10n.offerDeclineNotice(widget.fleetName),
              style: AppTextStyles.s14Regular.scaled.copyWith(
                fontSize: 14.sp,
                height: 1.35,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 14.h),
            Material(
              color: reason == null
                  ? AppColors.surfaceEmpty
                  : AppColors.iconRed,
              borderRadius: BorderRadius.circular(8.r),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: reason == null
                    ? null
                    : () => Navigator.of(context).pop(reason),
                child: SizedBox(
                  height: 56.h,
                  child: Center(
                    child: Text(
                      l10n.offerDeclineOrder,
                      style: AppTextStyles.s16Bold.scaled.copyWith(
                        height: 1.35,
                        color: reason == null
                            ? AppColors.textMuted
                            : AppColors.surfaceWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandBlack,
                minimumSize: Size.fromHeight(40.h),
              ),
              child: Text(
                l10n.offerKeepOrder,
                style: AppTextStyles.s14SemiBold.scaled.copyWith(
                  fontSize: 15.sp,
                  height: 1.35,
                  color: AppColors.brandBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonOption extends StatelessWidget {
  const _ReasonOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.iconBrand : AppColors.canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: BorderSide(
            color: selected ? AppColors.brandMain : AppColors.borderDeactivated,
            width: 1.w,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 52.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                children: [
                  _Radio(selected: selected),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s14SemiBold.scaled.copyWith(
                        fontSize: 15.sp,
                        height: 1.35,
                        color: AppColors.brandBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final size = 22.w;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.brandMain : AppColors.surfaceWhite,
        border: selected
            ? null
            : Border.all(color: AppColors.borderDeactivated, width: 1.5.w),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
