// lib/features/settings/presentation/pages/report_problem_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import 'package:routex_mobile/features/auth/domain/usecases/pick_profile_image_usecase.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/send_problem_report_usecase.dart';
import '../navigation/settings_navigator.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_switch_tile.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Lets the driver report a problem: a category, a description, optional
/// screenshots and, if allowed, device details.
class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  static const _maxLength = 500;
  static const _maxScreenshots = 3;

  final _descriptionController = TextEditingController();
  String? _category;
  final List<String> _screenshots = [];
  bool _includeDevice = true;
  bool _isSending = false;

  bool get _canSend =>
      _category != null && _descriptionController.text.trim().isNotEmpty && !_isSending;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addScreenshot() async {
    final file = await getIt<PickProfileImageUseCase>()(isCamera: false);
    if (file != null && mounted) setState(() => _screenshots.add(file.path));
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);
    final String reference;
    final DriverProfileEntity profile;
    try {
      reference = await getIt<SendProblemReportUseCase>()(
        category: _category!,
        description: _descriptionController.text,
        screenshotPaths: _screenshots,
        includeDeviceDetails: _includeDevice,
      );
      // Who gets the reply; the page can be opened without the profile
      // (from Help center), so it is read here.
      profile = await getIt<GetProfileUseCase>()();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ErrorAlertDialog.show(
        context: context,
        message: context.tr.somethingWentWrong,
      );
      return;
    }
    if (!mounted) return;
    final name = profile.name.trim();
    context.pushReplacement(
      RoutersName.reportSentScreen,
      extra: ReportSentArgs(
        firstName: name.isEmpty ? name : name.split(RegExp(r'\s+')).first,
        email: profile.email,
        reference: reference,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final categories = [
      (key: 'app', label: tr.reportCatApp),
      (key: 'route', label: tr.reportCatRoute),
      (key: 'order', label: tr.reportCatOrder),
      (key: 'account', label: tr.reportCatAccount),
      (key: 'other', label: tr.reportCatOther),
    ];
    final cardPadding = EdgeInsetsDirectional.fromSTEB(12.w, 16.h, 12.w, 12.h);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
          children: [
            SettingsPageHeader(title: tr.settingsReportProblem, subtitle: tr.reportSubtitle),
            SizedBox(height: 24.h),
            SettingsCard(
              title: tr.reportWhatAbout,
              padding: cardPadding,
              children: [
                Wrap(
                  spacing: 9.w,
                  runSpacing: 8.5.h,
                  children: [
                    for (final category in categories)
                      _CategoryChip(
                        label: category.label,
                        isSelected: _category == category.key,
                        onTap: () => setState(() => _category = category.key),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 17.h),
            SettingsCard(
              title: tr.reportWhatHappened,
              padding: cardPadding,
              children: [
                Stack(
                  children: [
                    RouteXTextField(
                      controller: _descriptionController,
                      hintText: tr.reportWhatHappenedHint,
                      minLines: 4,
                      maxLines: 5,
                      textStyle: AppTextStyles.s16Regular.copyWith(
                        fontSize: AppFonts.size16.sp,
                        height: 1.375,
                        color: AppColors.textPrimary,
                      ),
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [LengthLimitingTextInputFormatter(_maxLength)],
                      // Room at the bottom for the counter.
                      contentPadding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 34.h),
                      onChanged: (_) => setState(() {}),
                    ),
                    PositionedDirectional(
                      end: 16.w,
                      bottom: 13.h,
                      child: Text(
                        '${_descriptionController.text.characters.length} / $_maxLength',
                        style: AppTextStyles.s14Regular.copyWith(
                          fontSize: 13.sp,
                          height: 1.3,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 17.h),
            SettingsCard(
              title: tr.reportScreenshot,
              subtitle: tr.reportScreenshotHint,
              padding: cardPadding,
              children: [
                Wrap(
                  spacing: 10.5.w,
                  runSpacing: 10.5.h,
                  children: [
                    for (final path in _screenshots)
                      _ScreenshotThumb(
                        path: path,
                        onRemove: () => setState(() => _screenshots.remove(path)),
                      ),
                    if (_screenshots.length < _maxScreenshots)
                      _AddScreenshotTile(label: tr.reportAdd, onTap: _addScreenshot),
                  ],
                ),
              ],
            ),
            SizedBox(height: 17.h),
            SettingsCard(
              padding: EdgeInsets.all(12.r),
              children: [
                SettingsSwitchTile(
                  icon: Icons.info_outline,
                  title: tr.reportDeviceDetails,
                  subtitle: tr.reportDeviceDetailsHint,
                  value: _includeDevice,
                  onChanged: (v) => setState(() => _includeDevice = v),
                ),
              ],
            ),
            SizedBox(height: 17.h),
            RouteXMainButton(
              isLoading: _isSending,
              onPressed: _canSend ? _send : null,
              text: tr.reportSend,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped category option; the selected one is filled with the brand
/// color.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandMain : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected ? AppColors.brandMain : AppColors.borderDeactivated,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.s16Bold.copyWith(
            fontSize: 15.sp,
            height: 1.3,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Picked screenshot with a remove button in its top corner.
class _ScreenshotThumb extends StatelessWidget {
  const _ScreenshotThumb({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final size = 87.5.r;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: size,
              height: size,
              color: AppColors.iconBrand,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.image_outlined, size: 32.r, color: AppColors.textGray),
              ),
            ),
          ),
          PositionedDirectional(
            top: 4.r,
            end: 4.r,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderDeactivated),
                ),
                child: Icon(Icons.close, size: 14.r, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed square that opens the gallery.
class _AddScreenshotTile extends StatelessWidget {
  const _AddScreenshotTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 87.5.r;
    return RouteXTapScale(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(radius: 8.r),
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 24.r, color: AppColors.textPrimary),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppTextStyles.s14Bold.copyWith(
                  fontSize: AppFonts.size14.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderDeactivated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += dash + gap) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) => oldDelegate.radius != radius;
}
