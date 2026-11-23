// lib/features/orders/presentation/pages/order_offer_accepted_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';

import '../../domain/entities/order_offer_entity.dart';
import '../widgets/history/history_primary_button.dart';
import '../widgets/offers/order_offer_widgets.dart';
import '../widgets/orders_today/orders_today_metrics.dart';

/// "Added to your route" — where the new order landed and what the route
/// looks like now. Replaces the offer on the stack, so Back returns to
/// Orders.
class OrderOfferAcceptedPage extends StatelessWidget {
  const OrderOfferAcceptedPage({
    super.key,
    required this.result,
    this.onSeeRoute,
  });

  final AcceptedOfferEntity result;

  /// Opens the route the orders joined; null closes this screen instead.
  final VoidCallback? onSeeRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tr;
    final name = result.customerName;
    final gutter = EdgeInsets.symmetric(horizontal: OrdersTodayMetrics.gutter.w);
    void back() => Navigator.of(context).maybePop();

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 150.h, bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stands in for the 3D check illustration until it is
                    // exported from Figma.
                    Center(
                      child: Container(
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFA6E34F), AppColors.brandMain],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandMain.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 58.w,
                          color: AppColors.surfaceWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: gutter,
                      child: Text(
                        l10n.offerAcceptedTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.s28Bold.scaled.copyWith(
                          height: 1.35,
                          letterSpacing: -0.56.sp,
                          color: AppColors.brandBlack,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 46.w),
                      child: Text(
                        name != null
                            ? l10n.offerAcceptedOne(
                                name,
                                result.firstStopNumber,
                                result.totalStops,
                                result.doneBy,
                              )
                            : l10n.offerAcceptedMany(
                                result.acceptedCount,
                                result.firstStopNumber,
                                result.totalStops,
                                result.doneBy,
                              ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.s14Regular.scaled.copyWith(
                          height: 1.35,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 69.h),
                    Padding(
                      padding: gutter,
                      child: OfferCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 21.w,
                          vertical: 7.h,
                        ),
                        child: Column(
                          children: [
                            _RouteRow(
                              label: l10n.offerStopsTomorrow,
                              value: '${result.totalStops}',
                            ),
                            const _RowDivider(),
                            _RouteRow(
                              label: l10n.offerDistance,
                              value: l10n.offerKm(
                                result.distanceKm.toStringAsFixed(1),
                              ),
                            ),
                            const _RowDivider(),
                            _RouteRow(
                              label: l10n.offerDoneBy,
                              value: result.doneBy,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                OrdersTodayMetrics.gutter.w,
                0,
                OrdersTodayMetrics.gutter.w,
                16.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HistoryPrimaryButton(
                    label: l10n.offerSeeRoute,
                    busy: false,
                    onPressed: onSeeRoute ?? back,
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: back,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandBlack,
                      minimumSize: Size.fromHeight(44.h),
                    ),
                    child: Text(
                      l10n.offerBackToOrders,
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
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.s14Regular.scaled.copyWith(
                height: 1.35,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.s14Bold.scaled.copyWith(
              height: 1.35,
              color: AppColors.brandBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => Divider(
        height: 1.h,
        thickness: 1.h,
        color: AppColors.borderDeactivated,
      );
}
