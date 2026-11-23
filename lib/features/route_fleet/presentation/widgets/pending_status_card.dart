// lib/features/route_fleet/presentation/widgets/pending_status_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class PendingStatusCard extends StatelessWidget {
  const PendingStatusCard({
    super.key,
    required this.fleetName,
    required this.onJoinAnotherFleet,
    required this.onCancelRequest,
  });

  final String fleetName;
  final VoidCallback onJoinAnotherFleet;
  final VoidCallback onCancelRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PENDING REVIEW Tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF84E300),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: AppColors.brandWhite),
                SizedBox(width: 6.w),
                Text(
                  context.tr.routePendingReviewCaps,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceWhite,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            context.tr.routeRequestSentTo(fleetName),
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlack,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6.h),

          // Description
          Text(
            context.tr.routeDispatcherReviewingNotify,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.slateMuted,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),

          // Timeline Indicator (Sent -> Reviewing -> Start shift)
          Row(
            children: [
              _TimelineNode(title: context.tr.routeTimelineSent, isDone: true, isCurrent: false),
              Expanded(
                child: Container(
                  height: 2.h,
                  color: const Color(0xFF84E300),
                ),
              ),
              _TimelineNode(title: context.tr.routeTimelineReviewing, isDone: false, isCurrent: true),
              Expanded(
                child: Container(
                  height: 2.h,
                  color: AppColors.slateBorder,
                ),
              ),
              _TimelineNode(title: context.tr.routeStartShift, isDone: false, isCurrent: false),
            ],
          ),
          SizedBox(height: 20.h),

          // Button: Join another fleet
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: onJoinAnotherFleet,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.brandBlack,
                side: BorderSide(color: AppColors.slateBorder, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr.routeJoinAnotherFleet,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.brandBlack),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Cancel request
          Center(
            child: TextButton(
              onPressed: onCancelRequest,
              child: Text(
                context.tr.routeCancelRequest,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.errorRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.title, required this.isDone, required this.isCurrent});
  final String title;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: isDone
                ? const Color(0xFF84E300)
                : isCurrent
                    ? AppColors.surfaceWhite
                    : AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone || isCurrent ? const Color(0xFF84E300) : AppColors.slateBorder,
              width: 2.0,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 12, color: Colors.black)
                : isCurrent
                    ? Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF84E300),
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: isDone || isCurrent ? AppColors.brandBlack : AppColors.slateSoft,
          ),
        ),
      ],
    );
  }
}
