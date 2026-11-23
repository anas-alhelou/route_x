// lib/features/settings/presentation/widgets/quiet_hours_schedule_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// What the schedule sheet returns on "Save schedule".
typedef QuietHoursSchedule = ({TimeOfDay start, TimeOfDay end, List<int> days});

/// Edits the quiet hours window and the days it repeats on.
///
/// [days] are [DateTime.weekday] values. Resolves to the new schedule, or
/// `null` when cancelled or dismissed.
Future<QuietHoursSchedule?> showQuietHoursScheduleSheet(
  BuildContext context, {
  required TimeOfDay start,
  required TimeOfDay end,
  required List<int> days,
}) {
  return showRoutexSheet<QuietHoursSchedule>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuietHoursScheduleSheet(start: start, end: end, days: days),
  );
}

class _QuietHoursScheduleSheet extends StatefulWidget {
  const _QuietHoursScheduleSheet({
    required this.start,
    required this.end,
    required this.days,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final List<int> days;

  @override
  State<_QuietHoursScheduleSheet> createState() => _QuietHoursScheduleSheetState();
}

class _QuietHoursScheduleSheetState extends State<_QuietHoursScheduleSheet> {
  /// Week as shown, starting on Sunday (S M T W T F S).
  static const _week = [
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
  ];

  late TimeOfDay _start = widget.start;
  late TimeOfDay _end = widget.end;
  late final Set<int> _days = widget.days.toSet();

  /// Which time card is highlighted: the one last picked (From at first).
  bool _editingStart = true;

  String get _locale => Localizations.localeOf(context).toString();

  String _formatTime(TimeOfDay time) => DateFormat('h:mm a', _locale)
      .format(DateTime(2000, 1, 1, time.hour, time.minute));

  /// One-letter day name; 2023-01-01 was a Sunday, so day `n` of that week
  /// has weekday `n`.
  String _dayLetter(int weekday) =>
      DateFormat('EEEEE', _locale).format(DateTime(2023, 1, weekday % 7 + 1));

  Future<void> _pick({required bool start}) async {
    setState(() => _editingStart = start);
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (picked == null || !mounted) return;
    setState(() => start ? _start = picked : _end = picked);
  }

  void _toggleDay(int weekday) {
    setState(() => _days.contains(weekday) ? _days.remove(weekday) : _days.add(weekday));
  }

  void _save() {
    Navigator.pop<QuietHoursSchedule>(context, (
      start: _start,
      end: _end,
      days: [for (final day in _week) if (_days.contains(day)) day],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceEmpty,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 4.w),
                child: Text(
                  tr.quietScheduleTitle,
                  style: AppTextStyles.s24Bold.copyWith(
                    fontSize: 20.sp,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 4.w),
                child: Text(
                  tr.quietScheduleSubtitle,
                  style: AppTextStyles.s14Regular.copyWith(
                    fontSize: 15.sp,
                    height: 1.35,
                    color: AppColors.textGray,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      label: tr.quietScheduleFrom,
                      time: _formatTime(_start),
                      isActive: _editingStart,
                      onTap: () => _pick(start: true),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _TimeCard(
                      label: tr.quietScheduleTo,
                      time: _formatTime(_end),
                      isActive: !_editingStart,
                      onTap: () => _pick(start: false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 4.w),
                child: Text(
                  tr.quietScheduleRepeat,
                  style: AppTextStyles.s16Medium.copyWith(
                    fontSize: AppFonts.size16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final day in _week)
                    _DayChip(
                      letter: _dayLetter(day),
                      isSelected: _days.contains(day),
                      onTap: () => _toggleDay(day),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              RouteXMainButton(
                isLoading: false,
                // A schedule that never repeats has nothing to save.
                onPressed: _days.isEmpty ? null : _save,
                text: tr.quietScheduleSave,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.borderDeactivated),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    tr.cancel,
                    style: AppTextStyles.s16Bold.copyWith(fontSize: AppFonts.size16.sp),
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

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.time,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String time;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.iconBrand : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive ? AppColors.brandMain : AppColors.borderDeactivated,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.s14Regular.copyWith(
                fontSize: AppFonts.size14.sp,
                height: 1.4,
                color: AppColors.textGray,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                time,
                style: AppTextStyles.s24Bold.copyWith(
                  fontSize: 20.sp,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.letter,
    required this.isSelected,
    required this.onTap,
  });

  final String letter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40.r,
        height: 40.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.brandMain : AppColors.surfaceWhite,
          border: Border.all(
            color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
          ),
        ),
        child: Text(
          letter,
          style: AppTextStyles.s16Bold.copyWith(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
