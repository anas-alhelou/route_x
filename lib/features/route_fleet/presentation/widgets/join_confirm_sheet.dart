// lib/features/route_fleet/presentation/widgets/join_confirm_sheet.dart
import 'package:flutter/material.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';

class JoinConfirmSheet extends StatelessWidget {
  const JoinConfirmSheet({super.key, required this.fleetName});
  final String fleetName;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RouteFleetCubit>().state;
    final isUnavailable = state is RouteFleetJoinConfirmSheetState ? state.isUnavailable : false;
    final companyId = state is RouteFleetJoinConfirmSheetState ? state.companyId : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag Handle Bar (Top Center) ─────────────────────────────
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
          SizedBox(height: 12.h),

          // ── Header Section (Fleet Details) ───────────────────────────
          Row(
            children: [
              Container(
                width: 52.w,
                height: 52.h,
                decoration: BoxDecoration(
                  color: AppColors.blueLink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.lineLight, width: 1.0),
                ),
                child: Center(
                  child: Text(
                    fleetName.isNotEmpty ? fleetName[0] : 'F',
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueLink,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.routeJoinFleetQ(fleetName),
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilySatoshi,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slateInk,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_pin, size: 16, color: AppColors.slateMuted),
                        SizedBox(width: 4.w),
                        Text(
                          context.tr.routeNearbyFleet,
                          style: TextStyle(
                            fontFamily: AppFonts.fontFamilySatoshi,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Statistics Grid Cards Row (3 equal-width cards) ───────────
          Row(
            children: [
              Expanded(child: _StatCard(value: context.tr.routeActive, label: context.tr.routeStatus)),
              SizedBox(width: 10.w),
              Expanded(child: _StatCard(value: context.tr.routeVerified, label: context.tr.routeCompany)),
              SizedBox(width: 10.w),
              Expanded(child: _StatCard(value: context.tr.routeDelivery, label: context.tr.routeNetwork)),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Shared Details Section ───────────────────────────────────
          Text(
            context.tr.routeSharedWithFleet,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slateInk,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.paleSurface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.slatePale, width: 1.0),
            ),
            child: Column(
              children: [
                _ProfileDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: context.tr.routeName,
                  value: context.tr.routeDriver,
                  showDivider: true,
                ),
                _ProfileDetailRow(
                  icon: Icons.local_shipping_outlined,
                  label: context.tr.routeVehicle,
                  value: context.tr.routeActiveVehicle,
                  showDivider: false,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          if (isUnavailable) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.redPale3,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.redBorder, width: 1.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.errorRedText, size: 24),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.routeStoppedAccepting(fleetName),
                          style: TextStyle(
                            fontFamily: AppFonts.fontFamilySatoshi,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.errorRedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => context.read<RouteFleetCubit>().closeJoinConfirmSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CE600),
                  foregroundColor: AppColors.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  context.tr.routeSeeOtherFleets,
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilySatoshi,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              context.tr.routeDispatcherReviewsBeforeRoutes,
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.slateSoft,
                height: 1.35,
              ),
            ),
            SizedBox(height: 16.h),

            // Primary Action Button ("Send join request")
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () => context.read<RouteFleetCubit>().sendJoinRequest(fleetName, companyId: companyId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CE600),
                  foregroundColor: AppColors.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr.routeSendJoinRequest,
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilySatoshi,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slateInk,
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.slateInk),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 4.h),

          Center(
            child: TextButton(
              onPressed: () => context.read<RouteFleetCubit>().closeJoinConfirmSheet(),
              style: TextButton.styleFrom(foregroundColor: AppColors.slateMuted),
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
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.paleSurface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.slateBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slateInk,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.slateMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.slateSoft),
              SizedBox(width: 10.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.slateMuted,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateInk,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: AppColors.slateBorder),
      ],
    );
  }
}
