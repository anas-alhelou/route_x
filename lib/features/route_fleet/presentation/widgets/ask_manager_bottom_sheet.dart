// lib/features/route_fleet/presentation/widgets/ask_manager_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/enter_fleet_code_cubit.dart';

class AskManagerBottomSheet extends StatelessWidget {
  const AskManagerBottomSheet({super.key, required this.fleetCode});
  final String fleetCode;

  @override
  Widget build(BuildContext context) {
    final codeStr = fleetCode.isNotEmpty ? fleetCode : 'RSX48Z';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            context.tr.routeAskManagerNewCode,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slateInk,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            context.tr.routeSendMessageToManager,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.slateMuted,
            ),
          ),
          SizedBox(height: 20.h),

          // Message Preview Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.slateSurface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.routeMessage,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slateMuted,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  context.tr.routeManagerMessage(codeStr),
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.slateInk,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // WhatsApp Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                // WhatsApp share action
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CE600),
                foregroundColor: AppColors.onBrand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, size: 20, color: AppColors.slateInk),
                  SizedBox(width: 8.w),
                  Text(
                    context.tr.routeShareOnWhatsapp,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Copy Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slateInk,
                side: BorderSide(color: AppColors.slateBorder, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copy_rounded, size: 20, color: AppColors.slateInk),
                  SizedBox(width: 8.w),
                  Text(
                    context.tr.routeCopyMessage,
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Cancel Button
          Center(
            child: TextButton(
              onPressed: () => context.read<EnterFleetCodeCubit>().closeAskManagerSheet(),
              child: Text(
                context.tr.routeCancel,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
