// lib/features/home/presentation/widgets/delivery/needs_attention_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

/// "NEEDS YOUR ATTENTION" section — Figma HM1 (2 rows, 133h) & HM2 (1 row, 71h).
///
/// Small uppercase section label placed 30px below Up next card.
/// Grouped card 360 wide with rows 61 high separated by 1px dividers inset 17.
/// Each row: 36 x 36 circular icon container (18 x 18 icon), 12px gap,
/// title (20 high) over subtitle (17 high), and 24 x 24 chevron-right.
class NeedsAttentionSection extends StatelessWidget {
  const NeedsAttentionSection({
    required this.items,
    this.onItemTap,
    super.key,
  });

  final List<AttentionItem> items;

  /// A row was tapped — Figma HM1/HM2/HM9: "new order offered" opens the
  /// offer (OF1 / OF2), "order cancelled" opens the order (O05).
  final ValueChanged<AttentionItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Label ───────────────────────────────────────────────────
        SizedBox(
          height: 17.h,
          child: Text(
            context.tr.homeNeedsAttention,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
              height: 17 / 11,
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // ── Single Grouped Card (360 wide, 133h for 2 rows, 71h for 1 row) ───
        Container(
          width: double.infinity,
          // 4px inner padding top/bottom: rows are 61 high, card is 133 / 71.
          padding: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.borderDeactivated, width: 1),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onItemTap == null ? null : () => onItemTap!(item),
                    child: _AttentionRow(item: item),
                  ),
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.attentionDividerInset.w,
                      ),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.dividerSubtle,
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item});

  final AttentionItem item;

  Color get _iconBg {
    switch (item.type) {
      case AttentionItemType.newOrders:
      case AttentionItemType.routeUpdate:
        return AppColors.surfaceAttentionBlue;
      case AttentionItemType.cancelledOrder:
        return AppColors.surfaceAttentionGray;
    }
  }

  Border? get _iconBorder {
    switch (item.type) {
      case AttentionItemType.newOrders:
      case AttentionItemType.routeUpdate:
        return Border.all(color: AppColors.borderAttentionBlue, width: 1);
      case AttentionItemType.cancelledOrder:
        return null;
    }
  }

  String get _iconAsset {
    switch (item.type) {
      case AttentionItemType.newOrders:
        return AppAssets.icPackage;
      case AttentionItemType.cancelledOrder:
        return AppAssets.icBan;
      case AttentionItemType.routeUpdate:
        return AppAssets.icRoute;
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case AttentionItemType.newOrders:
      case AttentionItemType.routeUpdate:
        return AppColors.iconAttentionBlue;
      case AttentionItemType.cancelledOrder:
        return AppColors.iconAttentionGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: AppSizes.attentionRowH.h),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.attentionDividerInset.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 36 x 36 circular icon container
          Container(
            width: AppSizes.attentionIconContainer.r,
            height: AppSizes.attentionIconContainer.r,
            decoration: BoxDecoration(
              color: _iconBg,
              shape: BoxShape.circle,
              border: _iconBorder,
            ),
            child: Center(
              child: SvgPicture.asset(
                _iconAsset,
                width: 18.r,
                height: 18.r,
                colorFilter: ColorFilter.mode(_iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),

          // Title (20h) + Subtitle (17h)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontFamilyFallback: AppFonts.fontFamilyFallback,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 20 / 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.subtitle,
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
              ],
            ),
          ),
            SizedBox(width: 8.w),

            // 24 x 24 chevron-right
            SvgPicture.asset(
              AppAssets.icChevronRight,
              width: 24.r,
              height: 24.r,
              colorFilter: ColorFilter.mode(
                AppColors.textMuted,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      );
  }
}
