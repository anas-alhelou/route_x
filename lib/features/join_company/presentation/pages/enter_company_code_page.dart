import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/dialogs/logout_dialog.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_shake.dart';
import '../bloc/join_company_bloc.dart';
import '../widgets/company_code_caption_row.dart';
import '../widgets/company_code_error_row.dart';
import '../widgets/company_code_input_row.dart';
import '../widgets/company_info_card.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// Screen J01 (Enter company code), J02 (Code not valid), J03 (Code turned off).
class EnterCompanyCodePage extends StatelessWidget {
  const EnterCompanyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinCompanyBloc>.value(
      value: getIt<JoinCompanyBloc>(),
      child: const _EnterCompanyCodeView(),
    );
  }
}

class _EnterCompanyCodeView extends StatelessWidget {
  const _EnterCompanyCodeView();

  Future<void> _handlePaste(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return;
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      context.read<JoinCompanyBloc>().add(CompanyCodePasted(text));
    }
  }

  void _handleLogOut(BuildContext context) {
    context.showLogoutDialog(
      onConfirm: () {
        context.go(RoutersName.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return BlocConsumer<JoinCompanyBloc, JoinCompanyState>(
      listenWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (state.currentStep == JoinCompanyStep.confirmCompany) {
          context.pushNamed(RoutersName.confirmCompanyScreen);
        }
      },
      builder: (context, state) {
        final bloc = context.read<JoinCompanyBloc>();

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.screenGutter.w,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSpacing.s10.h),
                          // Top Bar: Right-aligned "Log out" button
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: RouteXTapScale(
                              onTap: () => _handleLogOut(context),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.icLogout,
                                    width: 18.w,
                                    height: 18.h,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.textMuted,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.s6.w),
                                  Text(
                                    tr.logOut,
                                    style: AppTextStyles.s14Medium.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Header Block: Display heading + Subtitle
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.s32Bold.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                              children: [
                                TextSpan(text: tr.joinCompanyTitleStart),
                                TextSpan(
                                  text: tr.joinCompanyTitleEnd,
                                  style: AppTextStyles.s32Bold.copyWith(
                                    color: AppColors.brandMain,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.s12.h),
                          Text(
                            tr.joinCompanySubtitle,
                            style: AppTextStyles.s14Regular.copyWith(
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 44.h),

                          // 6-Character Code Input Row + Error / Caption Row
                          RouteXShake(
                            hasError: state.hasError,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CompanyCodeInputRow(
                                  code: state.code,
                                  hasError: state.hasError,
                                  readOnly: state.isLoading,
                                  onChanged: (newCode) {
                                    bloc.add(CompanyCodeChanged(newCode));
                                  },
                                  onTap: () {
                                    if (state.hasError) {
                                      bloc.add(const CompanyCodeCleared());
                                    }
                                  },
                                ),
                                SizedBox(height: AppSpacing.s12.h),
                                if (state.validationError ==
                                    CodeValidationError.invalidCode)
                                  CompanyCodeErrorRow(
                                    message: tr.joinCompanyInvalidCode,
                                  )
                                else if (state.validationError ==
                                    CodeValidationError.codeDisabled)
                                  CompanyCodeErrorRow(
                                    message: tr.joinCompanyCodeDisabled,
                                  )
                                else
                                  CompanyCodeCaptionRow(
                                    caption: tr.joinCompanyCodeCaption,
                                    pasteLabel: tr.joinCompanyPaste,
                                    onPaste: () => _handlePaste(context),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.s24.h),

                          // Info Box: "Where do I find my code?"
                          CompanyInfoCard(
                            title: tr.joinCompanyWhereFindTitle,
                            body: tr.joinCompanyWhereFindBody,
                          ),

                          const Spacer(),
                          SizedBox(height: AppSpacing.s24.h),

                          // Full-width bright lime-green "Continue" button
                          RouteXMainButton(
                            text: tr.joinCompanyContinue,
                            isLoading: state.isLoading,
                            onPressed: state.isContinueEnabled
                                ? () => bloc.add(const VerifyCodeSubmitted())
                                : null,
                          ),
                          SizedBox(height: AppSpacing.s16.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
