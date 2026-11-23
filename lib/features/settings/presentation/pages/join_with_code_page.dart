// lib/features/settings/presentation/pages/join_with_code_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import '../../domain/entities/nearby_fleet_entity.dart';
import '../../domain/usecases/find_fleet_by_code_usecase.dart';
import '../../domain/usecases/send_join_request_usecase.dart';
import '../widgets/fleet_logo.dart';
import '../navigation/settings_navigator.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';

/// Joins a fleet with the 6-character code its manager shares. The code is
/// looked up as soon as it is complete, and the request can only be sent once
/// it matches a fleet.
class JoinWithCodePage extends StatefulWidget {
  const JoinWithCodePage({super.key});

  @override
  State<JoinWithCodePage> createState() => _JoinWithCodePageState();
}

class _JoinWithCodePageState extends State<JoinWithCodePage> {
  static const _codeLength = 6;

  final _codeController = TextEditingController();
  NearbyFleetEntity? _match;
  bool _isLookingUp = false;
  bool _noMatch = false;
  bool _isSending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String code) {
    if (code.length < _codeLength && (_match != null || _noMatch)) {
      setState(() {
        _match = null;
        _noMatch = false;
      });
    }
  }

  Future<void> _lookUp(String code) async {
    setState(() {
      _isLookingUp = true;
      _match = null;
      _noMatch = false;
    });
    final fleet = await getIt<FindFleetByCodeUseCase>()(code);
    // Ignore a late answer for a code the user has already changed.
    if (!mounted || _codeController.text != code) return;
    setState(() {
      _isLookingUp = false;
      _match = fleet;
      _noMatch = fleet == null;
    });
  }

  Future<void> _sendRequest() async {
    final fleet = _match;
    if (fleet == null) return;
    setState(() => _isSending = true);
    try {
      await getIt<SendJoinRequestUseCase>()(fleet.id);
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
    // Replaces this page, so going back from the status lands on My fleets.
    context.pushReplacement(
      RoutersName.fleetRequestPendingScreen,
      extra: FleetRequestArgs(fleet: fleet, sentAt: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.joinCodeTitle,
              subtitle: tr.joinCodeSubtitle,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              title: tr.joinCodeFleetCode,
              subtitle: tr.joinCodeFleetCodeHint,
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 18.h, 16.w, 16.h),
              children: [
                _CodeInput(
                  controller: _codeController,
                  length: _codeLength,
                  onChanged: _onCodeChanged,
                  onCompleted: _lookUp,
                ),
                if (_isLookingUp)
                  Center(
                    child: SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.brandMain,
                      ),
                    ),
                  )
                else if (_match != null)
                  _MatchedFleet(fleet: _match!)
                else if (_noMatch)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 18.r, color: AppColors.textError),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          tr.joinCodeNoMatch,
                          style: AppTextStyles.s14Regular.copyWith(
                            fontSize: AppFonts.size14.sp,
                            color: AppColors.textError,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            RouteXMainButton(
              isLoading: _isSending,
              onPressed: _match == null ? null : _sendRequest,
              text: tr.joinCodeSend,
            ),
            SizedBox(height: 16.h),
            Text(
              tr.joinCodeReviewNote,
              textAlign: TextAlign.center,
              style: AppTextStyles.s14Regular.copyWith(
                fontSize: AppFonts.size14.sp,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Six tinted boxes; letters are upper-cased as they are typed.
class _CodeInput extends StatelessWidget {
  const _CodeInput({
    required this.controller,
    required this.length,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final gap = 8.w;
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = (constraints.maxWidth - gap * (length - 1)) / length;
        final base = PinTheme(
          width: boxWidth,
          height: 52.h,
          textStyle: AppTextStyles.s24Bold.copyWith(
            fontSize: AppFonts.size24.sp,
            color: AppColors.textPrimary,
          ),
          decoration: BoxDecoration(
            color: AppColors.iconBrand,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.brandMain.withValues(alpha: 0.35)),
          ),
        );
        return Pinput(
          controller: controller,
          length: length,
          autofocus: true,
          keyboardType: TextInputType.visiblePassword,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            const _UpperCaseFormatter(),
          ],
          separatorBuilder: (_) => SizedBox(width: gap),
          defaultPinTheme: base,
          focusedPinTheme: base.copyBorderWith(
            border: Border.all(color: AppColors.brandMain, width: 1.5),
          ),
          onChanged: onChanged,
          onCompleted: onCompleted,
        );
      },
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Green-outlined card confirming which fleet the code belongs to.
class _MatchedFleet extends StatelessWidget {
  const _MatchedFleet({required this.fleet});

  final NearbyFleetEntity fleet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.iconBrand,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.brandMain),
      ),
      child: Row(
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
                  context.tr.joinCodeMatches(fleet.area),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s14Regular.copyWith(
                    fontSize: AppFonts.size14.sp,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 26.r,
            height: 26.r,
            decoration: const BoxDecoration(
              color: AppColors.brandMain,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 17.r, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
