import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart' as theme;
import 'package:routex_mobile/core/widgets/routex_avatar_picker.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_keyboard_scroll_view.dart';

import 'package:routex_mobile/core/widgets/routex_page_header.dart';
import 'package:routex_mobile/core/widgets/routex_phone_field.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/core/utils/formatters.dart';
import 'package:routex_mobile/features/auth/domain/entities/phone_country.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';
import 'package:routex_mobile/features/auth/presentation/controllers/signup_bloc.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/signup_footer_login.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';

class SignupStep1Content extends StatefulWidget {
  const SignupStep1Content({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<SignupStep1Content> createState() => _SignupStep1ContentState();
}

class _SignupStep1ContentState extends State<SignupStep1Content>
    with AutomaticKeepAliveClientMixin<SignupStep1Content> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneCountryController = RouteXPhoneFieldController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final state = context.read<SignupBloc>().state;
    _firstNameController.text = state.firstName;
    _lastNameController.text = state.lastName;
    _emailController.text = state.email;
    _phoneCountryController.selectCountry(
      AuthValidators.resolvePhoneCountry(state.phoneCountryIsoCode) ??
          kDefaultPhoneCountry,
    );
    // The bloc stores the phone as E.164, but the field takes the *national*
    // number and puts the dial code in its own prefix. Feeding it "+970599..."
    // would therefore show a duplicated country code and fail validation on a
    // form the user never touched. Anything that does not parse as E.164 is
    // passed through as typed.
    final stored = AuthValidators.splitE164(state.phone);
    _phoneController.text = stored?.nationalNumber ?? state.phone;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phoneCountryController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<SignupBloc>().add(
      SignupStep1Submitted(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        phoneCountryIsoCode: _phoneCountryController.isoCode,
      ),
    );
  }

  void _onImageSourceSelected(bool isCamera) {
    context.read<SignupBloc>().add(
      SignupProfileImageRequested(isCamera: isCamera),
    );
  }

  void _onLoginTapped() {
    context.go(RoutersName.login);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        final isLoading = state.status == SignupStatus.loading;

        return RouteXFormScope(
          child: RouteXKeyboardScrollView(
            horizontalPadding: 26.w,
            builder: (context, constraints, compact, contentWidth) {
              final fieldContentPadding = EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: (compact ? 10 : 14).h,
              );

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RouteXPageHeader(
                      titleStart: context.tr.letsGet,
                      titleEnd: context.tr.started,
                      subtitle: context.tr.createYourAccount,
                      titleStartSize: compact ? 24 : 32,
                      titleEndSize: compact ? 24 : 32,
                      subtitleSize: compact ? 12 : 14,
                      subtitleGap: compact ? 16 : 8,
                    ),
                    SizedBox(height: (compact ? 10 : 36).h),
                    Center(
                      child: RouteXAvatarPicker(
                        currentImage: state.profileImage,
                        diameter: compact ? 72 : 96,
                        onImageSourceSelected: _onImageSourceSelected,
                      ),
                    ),
                    SizedBox(height: (compact ? 12 : 31).h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RouteXTextField(
                            controller: _firstNameController,
                            labelText: context.tr.firstName,
                            hintText: context.tr.enterYourFirstName,
                            textInputAction: TextInputAction.next,
                            contentPadding: fieldContentPadding,
                            validator: (val) {
                              final err = AuthValidators.validateFirstName(
                                val,
                              );
                              return err != null
                                  ? context.translateValidationKey(err)
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: RouteXTextField(
                            controller: _lastNameController,
                            labelText: context.tr.lastName,
                            hintText: context.tr.enterYourLastName,
                            textInputAction: TextInputAction.next,
                            contentPadding: fieldContentPadding,
                            validator: (val) {
                              final err = AuthValidators.validateLastName(val);
                              return err != null
                                  ? context.translateValidationKey(err)
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (compact ? 10 : 18).h),
                    RouteXTextField(
                      controller: _emailController,
                      labelText: context.tr.email,
                      hintText: context.tr.enterYourEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [EmailSuffixFormatter()],
                      contentPadding: fieldContentPadding,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 14.w, right: 10.w),
                        child: Icon(
                          Icons.email_outlined,
                          size: 20.sp,
                          color: theme.AppColors.textGray,
                        ),
                      ),
                      validator: (val) {
                        final err = AuthValidators.validateEmail(val);
                        return err != null
                            ? context.translateValidationKey(err)
                            : null;
                      },
                    ),
                    SizedBox(height: (compact ? 10 : 20).h),
                    RouteXPhoneField(
                      controller: _phoneController,
                      countryController: _phoneCountryController,
                      validator: (val) {
                        final err = AuthValidators.validateInternationalPhone(
                          _phoneCountryController.isoCode,
                          val ?? '',
                        );
                        return err != null
                            ? context.translateValidationKey(err)
                            : null;
                      },
                    ),
                    SizedBox(height: (compact ? 14 : 28).h),
                    RouteXMainButton(
                      isLoading: isLoading,
                      onPressed: _onNextPressed,
                      text: context.tr.continueLabel,
                    ),
                    SizedBox(height: 34.h),
                    SignupFooterLogin(onLoginTapped: _onLoginTapped),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
