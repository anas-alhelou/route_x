// lib/features/settings/presentation/pages/myfleets_request_pending_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import '../../domain/entities/nearby_fleet_entity.dart';
import '../../domain/usecases/cancel_join_request_usecase.dart';
import '../widgets/fleet_logo.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';

/// Status of a join request the fleet has not answered yet: what happened,
/// what is happening now, and what unlocks after approval.
class MyFleetsRequestPendingPage extends StatefulWidget {
  const MyFleetsRequestPendingPage({
    super.key,
    required this.fleet,
    required this.sentAt,
  });

  final NearbyFleetEntity fleet;
  final DateTime sentAt;

  @override
  State<MyFleetsRequestPendingPage> createState() => _MyFleetsRequestPendingPageState();
}

class _MyFleetsRequestPendingPageState extends State<MyFleetsRequestPendingPage> {
  bool _isCancelling = false;

  String get _locale => Localizations.localeOf(context).toString();

  String get _time => DateFormat.Hm(_locale).format(widget.sentAt);

  bool get _sentToday {
    final now = DateTime.now();
    final sent = widget.sentAt;
    return sent.year == now.year && sent.month == now.month && sent.day == now.day;
  }

  String get _sentLabel => _sentToday
      ? context.tr.pendingSentToday(_time)
      : context.tr.pendingSentOn(DateFormat.MMMd(_locale).add_Hm().format(widget.sentAt));

  String get _sentStepLabel => _sentToday
      ? context.tr.pendingToday(_time)
      : DateFormat.MMMd(_locale).add_Hm().format(widget.sentAt);

  Future<void> _cancel() async {
    setState(() => _isCancelling = true);
    try {
      await getIt<CancelJoinRequestUseCase>()(widget.fleet.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      ErrorAlertDialog.show(
        context: context,
        message: context.tr.somethingWentWrong,
      );
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final fleet = widget.fleet;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsMyFleets,
              subtitle: tr.pendingSubtitle,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              spacing: 18,
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 16.h),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FleetLogo(fleet: fleet),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fleet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.s16Bold.copyWith(
                              fontSize: AppFonts.size16.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${fleet.area} • $_sentLabel',
                            style: AppTextStyles.s14Regular.copyWith(
                              fontSize: AppFonts.size14.sp,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.iconBrand,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        tr.pendingBadge,
                        style: AppTextStyles.s14Bold.copyWith(
                          fontSize: AppFonts.size14.sp,
                          color: AppColors.brandMain,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    _TimelineStep(
                      state: _StepState.done,
                      title: tr.pendingStepSent,
                      subtitle: _sentStepLabel,
                    ),
                    _TimelineStep(
                      state: _StepState.current,
                      title: tr.pendingStepReviewing,
                      subtitle: tr.pendingStepReviewingHint,
                    ),
                    _TimelineStep(
                      state: _StepState.upcoming,
                      title: tr.pendingStepFirstShift,
                      subtitle: tr.pendingStepFirstShiftHint,
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: AppColors.iconBrand,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 24.r, color: AppColors.textPrimary),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      tr.pendingDispatchLocked(fleet.name),
                      style: AppTextStyles.s16Regular.copyWith(
                        fontSize: AppFonts.size16.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                onPressed: _isCancelling ? null : _cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.borderDeactivated),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: _isCancelling
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.brandMain,
                        ),
                      )
                    : Text(
                        tr.pendingCancel,
                        style: AppTextStyles.s16Bold.copyWith(fontSize: AppFonts.size16.sp),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

/// One timeline row: a status dot joined to the next row by a line that is
/// green once this step is done.
class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.state,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final _StepState state;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = state == _StepState.upcoming;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24.r,
            child: Column(
              children: [
                _dot(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: state == _StepState.done
                          ? AppColors.brandMain
                          : AppColors.borderDeactivated,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.s16Bold.copyWith(
                      fontSize: AppFonts.size16.sp,
                      color: isUpcoming ? AppColors.textGray : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.s14Regular.copyWith(
                      fontSize: AppFonts.size14.sp,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    final size = 24.r;
    return switch (state) {
      _StepState.done => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.brandMain,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 16.r, color: AppColors.textPrimary),
        ),
      _StepState.current || _StepState.upcoming => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            border: Border.all(
              color: state == _StepState.current
                  ? AppColors.brandMain
                  : AppColors.borderDeactivated,
              width: 2,
            ),
          ),
          child: Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state == _StepState.current
                  ? AppColors.brandMain
                  : AppColors.borderDeactivated,
            ),
          ),
        ),
    };
  }
}
