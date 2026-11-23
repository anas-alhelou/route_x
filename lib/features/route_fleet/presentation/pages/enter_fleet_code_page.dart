// lib/features/route_fleet/presentation/pages/enter_fleet_code_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/custom_button.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/enter_fleet_code_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/enter_fleet_code_state.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/pages/route_fleet_page.dart';
import 'package:routex_mobile/features/route_fleet/presentation/widgets/ask_manager_bottom_sheet.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class EnterFleetCodePage extends StatelessWidget {
  const EnterFleetCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EnterFleetCodeCubit>(),
      child: const EnterFleetCodeView(),
    );
  }
}

class EnterFleetCodeView extends StatefulWidget {
  const EnterFleetCodeView({super.key});

  @override
  State<EnterFleetCodeView> createState() => _EnterFleetCodeViewState();
}

class _EnterFleetCodeViewState extends State<EnterFleetCodeView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value, BuildContext context) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    final code = _controllers.map((c) => c.text).join();
    context.read<EnterFleetCodeCubit>().updateCode(code);
  }

  void _syncCodeToControllers(String code) {
    if (code.length == 6) {
      for (int i = 0; i < 6; i++) {
        if (_controllers[i].text != code[i]) {
          _controllers[i].text = code[i];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnterFleetCodeCubit, EnterFleetCodeState>(
      listener: (context, state) {
        _syncCodeToControllers(state.code);

        if (state.joinedFleetName != null) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => RouteFleetCubit(
                  getActiveRouteUseCase: getIt(),
                  updateStopStatusUseCase: getIt(),
                )..goToPendingReview(fleetName: state.joinedFleetName!),
                child: const RouteFleetPage(),
              ),
            ),
            (route) => false,
          );
        }

        if (state.showAskManagerSheet) {
          final fleetCodeCubit = context.read<EnterFleetCodeCubit>();
          showRoutexSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SafeArea(
              top: false,
              child: BlocProvider.value(
                value: fleetCodeCubit,
                child: AskManagerBottomSheet(fleetCode: state.code),
              ),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<EnterFleetCodeCubit>().closeAskManagerSheet();
            }
          });
        }
      },
      builder: (context, state) {
        _syncCodeToControllers(state.code);

        return Scaffold(
          backgroundColor: AppColors.brandBackground,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 26.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),

                        // ── 1. Header & Back Navigation ─────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              behavior: HitTestBehavior.opaque,
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.slateInk,
                                size: 28,
                              ),
                            ),
                            if (state.isError)
                              OutlinedButton(
                                onPressed: () {
                                  // Help action
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.slateInk,
                                  side: BorderSide(color: AppColors.borderDeactivated),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                ),
                                child: Text(
                                  context.tr.routeHelp,
                                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 13.sp, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // ── 2. Main Title Typography ────────────────────────
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                            children: [
                              TextSpan(
                                text: context.tr.routeEnterYour,
                                style: TextStyle(color: AppColors.slateInk),
                              ),
                              TextSpan(
                                text: context.tr.routeFleetCodeWord,
                                style: TextStyle(color: Color(0xFF8FE600)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // ── 3. Subtitle / Description Text (Two-line split) ──
                        Text(
                          context.tr.routeTypeSixCharCode,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.slateMuted,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ── 4. Code Input Fields (6 OTP Fields) ─────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final isFocused = _focusNodes[index].hasFocus;
                            final borderColor = state.isError
                                ? AppColors.errorRed
                                : isFocused
                                    ? const Color(0xFF8FE600)
                                    : AppColors.borderDeactivated;

                            return Container(
                              width: 52.w,
                              height: 64.h,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: borderColor,
                                  width: isFocused || state.isError ? 2.0 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.slateInk,
                                  ),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (val) => _onDigitChanged(index, val, context),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 12.h),

                        // Helper Row: "Letters and numbers, not case-sensitive" / Error & Paste
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (state.isError)
                              Row(
                                children: [
                                  Icon(Icons.error_outline, size: 14, color: AppColors.errorRed),
                                  SizedBox(width: 4.w),
                                  Text(
                                    context.translateValidationKey(state.errorMessage ?? 'errInvalidOrExpiredCode'),
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.errorRed,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Expanded(
                                child: Text(
                                  context.tr.routeLettersNumbersHint,
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.slateMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            RouteXTapScale(
                              onTap: () {
                                context.read<EnterFleetCodeCubit>().pasteCode();
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.content_paste_rounded, size: 14, color: AppColors.slateMuted),
                                  SizedBox(width: 4.w),
                                  Text(
                                    context.tr.routePaste,
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slateMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // ── 5. "Where do I find my code?" Info Card ─────────
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.borderDeactivated, width: 1.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: Icon(Icons.info_outline_rounded, color: AppColors.slateMuted, size: 22),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr.routeWhereFindCode,
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.slateInk,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      context.tr.routeManagerCreatesCode,
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.slateMuted,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Fixed Action Bar (Anchored to Screen Bottom) ─────
                Padding(
                  padding: EdgeInsets.fromLTRB(26.w, 12.h, 26.w, 24.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!state.isError) ...[
                        _PrimaryActionButton(
                          text: context.tr.routeJoinFleet,
                          isEnabled: state.code.length == 6,
                          onPressed: () {
                            final code = _controllers.map((c) => c.text).join();
                            context.read<EnterFleetCodeCubit>().submitFleetCode(code);
                          },
                        ),
                      ] else ...[
                        _PrimaryActionButton(
                          text: context.tr.routeTryAgain,
                          isEnabled: true,
                          onPressed: () {
                            final code = _controllers.map((c) => c.text).join();
                            context.read<EnterFleetCodeCubit>().submitFleetCode(code);
                          },
                        ),
                        SizedBox(height: 12.h),
                        CustomButton(
                          text: context.tr.routeAskManagerForNewCode,
                          backgroundColor: AppColors.surfaceWhite,
                          textColor: AppColors.slateInk,
                          borderColor: AppColors.borderDeactivated,
                          width: double.infinity,
                          height: 52.h,
                          borderRadius: 12.r,
                          onPressed: () => context.read<EnterFleetCodeCubit>().openAskManagerSheet(),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      RouteXTapScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              !state.isError ? context.tr.routeLostYourCode : context.tr.routeStillStuck,
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.slateMuted,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr.routeFindFleetInstead,
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slateInk,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  width: 127.w,
                                  height: 1.5.h,
                                  color: const Color(0xFF8FE600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360.w,
      height: 56.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? const Color(0xFF8CE600) : AppColors.slateBorder,
          foregroundColor: isEnabled ? AppColors.onBrand : AppColors.slateSoft,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
          padding: EdgeInsets.only(left: 24.w, right: 16.w),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: isEnabled ? AppColors.slateInk : AppColors.slateSoft,
              ),
            ),
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 24,
                color: isEnabled ? AppColors.slateInk : AppColors.slateSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
