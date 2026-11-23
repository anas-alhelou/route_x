// lib/features/settings/presentation/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../controllers/settings_cubit.dart';
import '../widgets/quiet_hours_schedule_sheet.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_switch_tile.dart';

/// Alert types, sound / vibration and quiet hours.
///
/// Expects the [SettingsCubit] of the settings screen above it.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.profile});

  final DriverProfileEntity profile;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  bool _systemDenied = false;

  late bool _newRoutes;
  late bool _orderChanges;
  late bool _dispatch;
  late bool _sound;
  late bool _vibrate;
  late bool _quietHours;
  late TimeOfDay _quietStart;
  late TimeOfDay _quietEnd;
  late List<int> _quietDays;
  bool _isSaving = false;

  static TimeOfDay _fromMinutes(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60 % 24, minute: minutes % 60);

  static int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSystemPermission();
    final p = widget.profile;
    _newRoutes = p.notifyNewRoutes;
    _orderChanges = p.notifyOrderChanges;
    _dispatch = p.notifyDispatchMessages;
    _sound = p.notificationSound;
    _vibrate = p.notificationVibrate;
    _quietHours = p.quietHoursEnabled;
    _quietStart = _fromMinutes(p.quietHoursStartMinutes);
    _quietEnd = _fromMinutes(p.quietHoursEndMinutes);
    _quietDays = p.quietHoursDays;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the phone's settings: look again.
    if (state == AppLifecycleState.resumed) _checkSystemPermission();
  }

  Future<void> _checkSystemPermission() async {
    try {
      final status = await Permission.notification.status;
      final denied = status.isDenied || status.isPermanentlyDenied;
      if (mounted && denied != _systemDenied) {
        setState(() => _systemDenied = denied);
      }
    } catch (_) {}
  }

  Future<void> _openPhoneSettings() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        _checkSystemPermission();
        return;
      }
    }
    await openAppSettings();
  }

  /// "11 PM", or "11:30 PM" when the minutes are not zero.
  String _formatTime(TimeOfDay time) {
    final locale = Localizations.localeOf(context).toString();
    final date = DateTime(2000, 1, 1, time.hour, time.minute);
    return DateFormat(time.minute == 0 ? 'h a' : 'h:mm a', locale).format(date);
  }

  Future<void> _editSchedule() async {
    final schedule = await showQuietHoursScheduleSheet(
      context,
      start: _quietStart,
      end: _quietEnd,
      days: _quietDays,
    );
    if (schedule == null || !mounted) return;
    setState(() {
      _quietStart = schedule.start;
      _quietEnd = schedule.end;
      _quietDays = schedule.days;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final error = await context.read<SettingsCubit>().updateProfile(
          widget.profile.copyWith(
            notifyNewRoutes: _newRoutes,
            notifyOrderChanges: _orderChanges,
            notifyDispatchMessages: _dispatch,
            notificationSound: _sound,
            notificationVibrate: _vibrate,
            quietHoursEnabled: _quietHours,
            quietHoursStartMinutes: _toMinutes(_quietStart),
            quietHoursEndMinutes: _toMinutes(_quietEnd),
            quietHoursDays: _quietDays,
          ),
        );
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSaving = false);
    ErrorAlertDialog.show(
      context: context,
      message: context.tr.somethingWentWrong,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final cardPadding = EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 12.h);
    final sectionGap = SizedBox(height: 17.h);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsNotifications,
              subtitle: tr.notificationsPageSubtitle,
            ),
            SizedBox(height: 24.h),
            if (_systemDenied) ...[
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.notificationsPageSystemOffTitle,
                      style: AppTextStyles.s14Regular.copyWith(
                        fontSize: AppFonts.size14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tr.notificationsPageSystemOffBody,
                      style: AppTextStyles.s14Regular.copyWith(
                        fontSize: AppFonts.size14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: _openPhoneSettings,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        tr.notificationsPageSystemOffAction,
                        style: AppTextStyles.s14Regular.copyWith(
                          fontSize: AppFonts.size14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              sectionGap,
            ],
            SettingsCard(
              title: tr.notificationsPageAlerts,
              padding: cardPadding,
              children: [
                SettingsSwitchTile(
                  leading: Assets.icons.svg.newRoutes.svg(width: 36.r, height: 36.r),
                  title: tr.notificationsPageNewRoutes,
                  subtitle: tr.notificationsPageNewRoutesHint,
                  value: _newRoutes,
                  onChanged: (v) => setState(() => _newRoutes = v),
                ),
                SettingsSwitchTile(
                  icon: Icons.assignment_outlined,
                  title: tr.notificationsPageOrderChanges,
                  subtitle: tr.notificationsPageOrderChangesHint,
                  value: _orderChanges,
                  onChanged: (v) => setState(() => _orderChanges = v),
                ),
                SettingsSwitchTile(
                  icon: Icons.chat_bubble_outline,
                  title: tr.notificationsPageDispatch,
                  value: _dispatch,
                  onChanged: (v) => setState(() => _dispatch = v),
                ),
              ],
            ),
            sectionGap,
            SettingsCard(
              title: tr.notificationsPageSoundVibration,
              padding: cardPadding,
              children: [
                SettingsSwitchTile(
                  icon: Icons.notifications_none,
                  title: tr.notificationsPageSound,
                  value: _sound,
                  onChanged: (v) => setState(() => _sound = v),
                ),
                SettingsSwitchTile(
                  icon: Icons.vibration,
                  title: tr.notificationsPageVibrate,
                  value: _vibrate,
                  onChanged: (v) => setState(() => _vibrate = v),
                ),
              ],
            ),
            sectionGap,
            SettingsCard(
              title: tr.notificationsPageQuietHours,
              subtitle: tr.notificationsPageQuietHoursHint,
              padding: cardPadding,
              children: [
                SettingsSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: tr.notificationsPageQuietHours,
                  value: _quietHours,
                  onChanged: (v) => setState(() => _quietHours = v),
                ),
                SettingsOptionTile(
                  icon: Icons.schedule,
                  title: tr.notificationsPageSchedule,
                  onTap: _editSchedule,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_formatTime(_quietStart)} – ${_formatTime(_quietEnd)}',
                        style: AppTextStyles.s14Regular.copyWith(
                          fontSize: AppFonts.size14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.chevron_right, size: 22.r, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 17.h),
            RouteXMainButton(
              isLoading: _isSaving,
              onPressed: _save,
              text: tr.editProfileSaveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
