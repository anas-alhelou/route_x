import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_colors_sync.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../../domain/entities/route_summary.dart';
import '../../domain/entities/stop_status.dart';

class RouteCompleteView extends StatelessWidget {
  const RouteCompleteView({
    super.key,
    required this.summary,
    required this.onDirectionsToDepotTapped,
    required this.onDoneTapped,
    required this.onSeeInHistoryTapped,
  });

  final RouteSummary summary;
  // R40: opens the depot directions.
  final VoidCallback onDirectionsToDepotTapped;
  // Done: back to the Home tab.
  final VoidCallback onDoneTapped;
  // See in history: opens the Orders tab.
  final VoidCallback onSeeInHistoryTapped;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(pageSystemUiOverlayStyle());

    // Format date in presentation layer
    final formattedDate = DateFormat('EEEE, d MMMM', Localizations.localeOf(context).languageCode).format(summary.date).toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Date
              Text(
                formattedDate,
                style: AppTextStyles.s11Bold12.copyWith(color: AppColors.textBody),
              ),
              SizedBox(height: 3.h),

              // 2. Title
              Text(
                context.tr.routeRouteComplete,
                style: AppTextStyles.s38Bold105.copyWith(color: AppColors.brandBlack),
              ),
              SizedBox(height: 12.h),

              // 3. Subtitle
              Text(
                summary.returnTask != null
                    ? context.tr.routeAlmostDone(summary.driverName)
                    : context.tr.routeAllDone(summary.driverName),
                style: AppTextStyles.s15Regular135.copyWith(color: AppColors.textBody),
              ),
              SizedBox(height: 16.h),

              // 4. To-do return-package card (optional if return task exists)
              if (summary.returnTask != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppSizes.r24),
                    border: Border.all(color: AppColors.borderDeactivated, width: 1.w),
                    boxShadow: AppTextStyles.tripSheetShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr.routeOneThingLeft,
                        style: AppTextStyles.s10Bold12.copyWith(color: AppColors.statusAmber),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        context.tr.routeReturnPackageToDepot(summary.returnTask!.customerName),
                        style: AppTextStyles.s20Bold03.copyWith(color: AppColors.brandBlack),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        context.tr.routeDepotAway(summary.returnTask!.depotName, summary.returnTask!.depotDistanceText),
                        style: AppTextStyles.s13Regular145.copyWith(color: AppColors.textBody),
                      ),
                      SizedBox(height: 26.h),
                      SizedBox(
                        height: 56.h,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandMain,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r), // Figma R19: radius 6
                            ),
                          ),
                          onPressed: onDirectionsToDepotTapped,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr.routeDirectionsToDepot,
                                style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                              ),
                              SvgPicture.asset(
                                AppAssets.routeIcArrowRight,
                                width: 18.w,
                                height: 14.h,
                                colorFilter: ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
              ],

              // 5. Outcome Row (Donut 104x104 + Text Column)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 104.w,
                    height: 104.h,
                    child: CustomPaint(
                      painter: _OutcomeDonutPainter(
                        deliveredCount: summary.deliveredCount,
                        failedCount: summary.failedCount,
                        totalCount: summary.totalStopsCount,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.routeDeliveredOfTotal(summary.deliveredCount.toString(), summary.totalStopsCount.toString()),
                          style: AppTextStyles.s26Black11.copyWith(color: AppColors.brandBlack),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.brandMain,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              context.tr.routeCountDelivered(summary.deliveredCount.toString()),
                              style: AppTextStyles.s14Medium.copyWith(color: AppColors.textBody),
                            ),
                          ],
                        ),
                        if (summary.failedCount > 0) ...[
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.dangerText,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                context.tr.routeCountCouldntDeliver(summary.failedCount.toString()),
                                style: AppTextStyles.s14Medium.copyWith(color: AppColors.textBody),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),

              // 6. Metrics Row (Figma: content-width columns, 40 apart)
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: '${summary.totalDistanceKm.toStringAsFixed(1)} ',
                            style: AppTextStyles.s24Black11.copyWith(color: AppColors.brandBlack),
                            children: [
                              TextSpan(
                                text: context.tr.routeKmUnit,
                                style: AppTextStyles.s14Bold14.copyWith(color: AppColors.textBody),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          context.tr.routeDrivenToday,
                          style: AppTextStyles.s13Medium135.copyWith(color: AppColors.textBody),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 40.w),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: '${summary.totalDurationMinutes} ',
                            style: AppTextStyles.s24Black11.copyWith(color: AppColors.brandBlack),
                            children: [
                              TextSpan(
                                text: context.tr.routeMinUnit,
                                style: AppTextStyles.s14Bold14.copyWith(color: AppColors.textBody),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          context.tr.routeOnTheRoad,
                          style: AppTextStyles.s13Medium135.copyWith(color: AppColors.textBody),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),

              // 7. Divider
              Divider(color: AppColors.borderDeactivated, height: 1),
              SizedBox(height: 24.h),

              // 8. Stops List (Figma: rows of 63 with a 1px divider between them)
              Text(
                context.tr.routeStopsCaps,
                style: AppTextStyles.s10Bold12.copyWith(color: AppColors.textBody),
              ),
              Column(
                children: summary.stopSummaries.asMap().entries.map((entry) {
                  final stop = entry.value;
                  final isDelivered = stop.status == StopDeliveryStatus.delivered;

                  return Column(
                    children: [
                      if (entry.key > 0) Divider(color: AppColors.borderDeactivated, height: 1),
                      Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          isDelivered ? AppAssets.statusDelivered : AppAssets.statusFailed,
                          width: 30.w,
                          height: 30.h,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop.customerName,
                                style: AppTextStyles.s15Bold135.copyWith(color: AppColors.brandBlack),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                isDelivered
                                    ? context.tr.routeDelivered
                                    : context.tr.routeSentForReview(stop.failureReasonText ?? context.tr.routeCouldntDeliver),
                                style: AppTextStyles.s13Regular145.copyWith(
                                  color: isDelivered ? AppColors.textBody : AppColors.dangerIcon,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          stop.timeText,
                          style: AppTextStyles.s13Medium135.copyWith(color: AppColors.textBody),
                        ),
                      ],
                    ),
                  ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 28.h),

              // 9. Done Button (Scrolls with content)
              SizedBox(
                height: 56.h,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandMain,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                  ),
                  onPressed: onDoneTapped,
                  child: Text(
                    context.tr.routeDone,
                    style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              // 10. See in history button
              Center(
                child: SizedBox(
                  height: 48.h,
                  child: TextButton(
                    onPressed: onSeeInHistoryTapped,
                    child: Text(
                      context.tr.routeSeeInHistory,
                      style: AppTextStyles.s14Bold14.copyWith(color: AppColors.brandBlack),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutcomeDonutPainter extends CustomPainter {
  _OutcomeDonutPainter({
    required this.deliveredCount,
    required this.failedCount,
    required this.totalCount,
  });

  final int deliveredCount;
  final int failedCount;
  final int totalCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalCount == 0) return;

    final strokeWidth = 12.w;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final gap = 0.15; // Gap angle between arcs

    final totalAngle = 2 * 3.1415926535 - (failedCount > 0 ? (gap * 2) : 0.0);
    final deliveredAngle = (deliveredCount / totalCount) * totalAngle;
    final failedAngle = (failedCount / totalCount) * totalAngle;

    final deliveredPaint = Paint()
      ..color = AppColors.brandMain
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final failedPaint = Paint()
      ..color = AppColors.dangerText
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double startAngle = -3.1415926535 / 2;

    // Draw Delivered Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      deliveredAngle,
      false,
      deliveredPaint,
    );

    // Draw Failed Arc if failedCount > 0
    if (failedCount > 0) {
      startAngle += deliveredAngle + gap;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        failedAngle,
        false,
        failedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OutcomeDonutPainter oldDelegate) {
    return oldDelegate.deliveredCount != deliveredCount || oldDelegate.failedCount != failedCount;
  }
}
