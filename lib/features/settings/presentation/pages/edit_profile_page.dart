// lib/features/settings/presentation/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_profile_image.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import '../navigation/settings_navigator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_phone_field.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/features/auth/domain/entities/phone_country.dart';
import 'package:routex_mobile/features/auth/domain/usecases/pick_profile_image_usecase.dart';
import 'package:routex_mobile/features/auth/domain/utils/auth_validators.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/profile_update_exception.dart';
import '../controllers/settings_cubit.dart';
import '../widgets/profile_photo_sheet.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/vehicle_type_label.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile});

  final DriverProfileEntity profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

/// A field problem: [message] goes under the field, [summary] is the phrase
/// used in the "Changes not saved" banner.
typedef _Issue = ({String message, String summary});

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final RouteXPhoneFieldController _phoneCountryController;
  String? _photoPath;

  /// Problems found by the last save attempt, locally or by the backend. The
  /// field validators only read from here, so what the banner lists and what
  /// the fields show can never disagree.
  Map<ProfileField, _Issue> _issues = const {};

  /// Banner text; null hides the banner.
  String? _bannerMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    // The stored number is international; the field edits the national part
    // against a country picker, so split it back apart.
    final split = AuthValidators.splitE164(profile.phone);
    // The profile stores one full name: the first word is the first name and
    // the rest is the last name.
    final nameParts = profile.name.trim().split(RegExp(r'\s+'));
    _firstNameController = TextEditingController(text: nameParts.first);
    _lastNameController = TextEditingController(
      text: nameParts.skip(1).join(' '),
    );
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(
      text: split?.nationalNumber ?? profile.phone,
    );
    _phoneCountryController = RouteXPhoneFieldController(
      initialCountry: phoneCountryByIsoCode(split?.isoCode),
    );
    _photoPath = profile.photoPath;
    _phoneCountryController.addListener(() => _clearIssue(ProfileField.phone));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phoneCountryController.dispose();
    super.dispose();
  }

  /// Editing a field means the user is fixing it: drop its stale issue.
  void _clearIssue(ProfileField field) {
    if (!_issues.containsKey(field)) return;
    setState(() => _issues = Map.of(_issues)..remove(field));
  }

  _Issue? _firstNameIssue() {
    final tr = context.tr;
    final key = AuthValidators.validateFirstName(_firstNameController.text);
    if (key == null) return null;
    return (
      message: context.translateValidationKey(key),
      summary: key == 'errFirstNameRequired'
          ? tr.editProfileSummaryFirstNameMissing
          : tr.editProfileSummaryFirstNameShort,
    );
  }

  _Issue? _lastNameIssue() {
    final tr = context.tr;
    final key = AuthValidators.validateLastName(_lastNameController.text);
    if (key == null) return null;
    return (
      message: context.translateValidationKey(key),
      summary: key == 'errLastNameRequired'
          ? tr.editProfileSummaryLastNameMissing
          : tr.editProfileSummaryLastNameShort,
    );
  }

  _Issue? _emailIssue() {
    final tr = context.tr;
    final key = AuthValidators.validateEmail(_emailController.text.trim());
    if (key == null) return null;
    return (
      message: context.translateValidationKey(key),
      summary: key == 'errEmailRequired'
          ? tr.editProfileSummaryEmailMissing
          : tr.editProfileSummaryEmailInvalid,
    );
  }

  _Issue? _phoneIssue() {
    final tr = context.tr;
    final isoCode = _phoneCountryController.isoCode;
    final value = _phoneController.text.trim();
    if (value.isEmpty) {
      return (
        message: context.translateValidationKey('errPhoneRequired'),
        summary: tr.editProfileSummaryPhoneMissing,
      );
    }
    // A wrong digit count gets a precise message ("Enter 9 digits after
    // +966"); a full `+` number is left to the parser.
    final expected = AuthValidators.expectedMobileLength(isoCode);
    if (expected != null && !value.startsWith('+')) {
      final digits = value
          .replaceAll(RegExp(r'\D'), '')
          .replaceFirst(RegExp(r'^0+'), '');
      if (digits.length != expected) {
        return (
          message: tr.editProfilePhoneDigits(
            expected,
            _phoneCountryController.dialCode,
          ),
          summary: digits.length < expected
              ? tr.editProfileSummaryPhoneShort
              : tr.editProfileSummaryPhoneLong,
        );
      }
    }
    final key = AuthValidators.validateInternationalPhone(isoCode, value);
    if (key == null) return null;
    return (
      message: context.translateValidationKey(key),
      summary: tr.editProfileSummaryPhoneInvalid,
    );
  }

  /// Maps a backend field error key to what the screen shows.
  _Issue _serverIssue(String key) {
    final tr = context.tr;
    if (key == 'errEmailTaken') {
      return (
        message: tr.editProfileEmailTaken,
        summary: tr.editProfileSummaryEmailTaken,
      );
    }
    final message = context.translateValidationKey(key);
    return (message: message, summary: message);
  }

  /// "A, B, and C." built from the issues in field order.
  String _summarize(Map<ProfileField, _Issue> issues) {
    final tr = context.tr;
    final parts = [
      for (final field in ProfileField.values)
        if (issues[field] != null) issues[field]!.summary,
    ];
    final text = parts.length == 1
        ? parts.single
        : parts.sublist(0, parts.length - 1).join(tr.listSeparator) +
              tr.listLastSeparator +
              parts.last;
    return '${text[0].toUpperCase()}${text.substring(1)}.';
  }

  void _showIssues(
    Map<ProfileField, _Issue> issues, {
    String? fallbackMessage,
  }) {
    setState(() {
      _issues = issues;
      _bannerMessage = issues.isEmpty ? fallbackMessage : _summarize(issues);
    });
    _formKey.currentState?.validate();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickPhoto() async {
    final isCamera = await showProfilePhotoSheet(context);
    if (isCamera == null) return;
    final file = await getIt<PickProfileImageUseCase>()(isCamera: isCamera);
    if (file != null && mounted) setState(() => _photoPath = file.path);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final localIssues = <ProfileField, _Issue>{
      if (_firstNameIssue() case final issue?) ProfileField.firstName: issue,
      if (_lastNameIssue() case final issue?) ProfileField.lastName: issue,
      if (_emailIssue() case final issue?) ProfileField.email: issue,
      if (_phoneIssue() case final issue?) ProfileField.phone: issue,
    };
    if (localIssues.isNotEmpty) {
      _showIssues(localIssues);
      return;
    }

    final isoCode = _phoneCountryController.isoCode;
    final phone = _phoneController.text.trim();
    final updated = widget.profile.copyWith(
      name:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      email: _emailController.text.trim(),
      phone: AuthValidators.toE164(isoCode, phone) ?? phone,
      photoPath: _photoPath,
    );

    setState(() {
      _isSaving = true;
      _issues = const {};
      _bannerMessage = null;
    });
    final error = await context.read<SettingsCubit>().updateProfile(updated);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSaving = false);
    _showIssues({
      for (final entry in error.fieldErrors.entries)
        entry.key: _serverIssue(entry.value),
    }, fallbackMessage: context.tr.somethingWentWrong);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final labelStyle = AppTextStyles.s16Medium.copyWith(
      fontSize: AppFonts.size16.sp,
      color: AppColors.textPrimary,
    );
    final inputStyle = AppTextStyles.s16Regular.copyWith(
      fontSize: AppFonts.size16.sp,
      color: AppColors.textPrimary,
    );

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: RouteXFormScope(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsetsDirectional.fromSTEB(26.w, 12.h, 26.w, 32.h),
              children: [
                SettingsPageHeader(
                  title: tr.editProfileTitle,
                  subtitle: switch (widget.profile.companyName) {
                    final company? => tr.editProfileCompanySees(company),
                    null => tr.editProfileYourCompanySees,
                  },
                ),
                SizedBox(height: 24.h),
                Center(
                  child: _EditableAvatar(
                    name: widget.profile.name,
                    photoPath: _photoPath,
                    label: tr.changePhoto,
                    onTap: _pickPhoto,
                  ),
                ),
                SizedBox(height: 20.h),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _bannerMessage == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _ErrorBanner(
                            title: tr.editProfileNotSaved,
                            message: _bannerMessage!,
                          ),
                        ),
                ),
                SettingsCard(
                  title: tr.editProfilePersonalDetails,
                  spacing: 16,
                  padding: EdgeInsetsDirectional.fromSTEB(
                    16.w,
                    18.h,
                    16.w,
                    16.h,
                  ),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RouteXTextField(
                            controller: _firstNameController,
                            labelText: tr.editProfileFirstName,
                            hintText: tr.editProfileFirstNameHint,
                            labelStyle: labelStyle,
                            labelInset: 4,
                            textStyle: inputStyle,
                            textInputAction: TextInputAction.next,
                            outlinedErrorIcon: true,
                            onChanged: (_) =>
                                _clearIssue(ProfileField.firstName),
                            validator: (_) =>
                                _issues[ProfileField.firstName]?.message,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: RouteXTextField(
                            controller: _lastNameController,
                            labelText: tr.editProfileLastName,
                            hintText: tr.editProfileLastNameHint,
                            labelStyle: labelStyle,
                            labelInset: 4,
                            textStyle: inputStyle,
                            textInputAction: TextInputAction.next,
                            outlinedErrorIcon: true,
                            onChanged: (_) =>
                                _clearIssue(ProfileField.lastName),
                            validator: (_) =>
                                _issues[ProfileField.lastName]?.message,
                          ),
                        ),
                      ],
                    ),
                    RouteXTextField(
                      controller: _emailController,
                      labelText: tr.editProfileEmail,
                      hintText: tr.editProfileEmailHint,
                      labelStyle: labelStyle,
                      labelInset: 4,
                      textStyle: inputStyle,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      outlinedErrorIcon: true,
                      onChanged: (_) => _clearIssue(ProfileField.email),
                      validator: (_) => _issues[ProfileField.email]?.message,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RouteXPhoneField(
                          controller: _phoneController,
                          countryController: _phoneCountryController,
                          labelText: tr.editProfilePhone,
                          hintText: tr.editProfilePhoneHint,
                          labelStyle: labelStyle,
                          labelInset: 4,
                          textStyle: inputStyle,
                          outlinedErrorIcon: true,
                          onChanged: (_) => _clearIssue(ProfileField.phone),
                          validator: (_) =>
                              _issues[ProfileField.phone]?.message,
                        ),
                        // The error row takes the helper's place.
                        if (!_issues.containsKey(ProfileField.phone)) ...[
                          SizedBox(height: 8.h),
                          Text(
                            tr.editProfilePhoneHelper,
                            style: AppTextStyles.s14Regular.copyWith(
                              fontSize: AppFonts.size14.sp,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 17.h),
                SettingsCard(
                  title: tr.settingsVehicle,
                  padding: EdgeInsetsDirectional.fromSTEB(
                    16.w,
                    18.h,
                    16.w,
                    16.h,
                  ),
                  children: [
                    // S02 vehicle row -> S05.
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => SettingsNavigator.pushWithProfile(
                        context,
                        RoutersName.vehicleScreen,
                        widget.profile,
                      ),
                      child: _VehicleTile(
                        vehicleType: widget.profile.vehicleType,
                        vehicleNumber: widget.profile.vehicleNumber,
                        subtitle: tr.editProfileSetByCompany,
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
        ),
      ),
    );
  }
}

/// Red "Changes not saved" banner summarizing why the save was refused.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.iconWarning,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textError.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 24.r, color: AppColors.textError),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s16Bold.copyWith(
                    fontSize: 15.sp,
                    height: 1.35,
                    color: AppColors.textError,
                  ),
                ),
                Text(
                  message,
                  style: AppTextStyles.s16Regular.copyWith(
                    fontSize: 15.sp,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Large avatar with the brand ring and a camera badge; tapping anywhere on
/// it (or on the label) opens the photo source sheet.
class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.name,
    required this.photoPath,
    required this.label,
    required this.onTap,
  });

  final String name;
  final String? photoPath;
  final String label;
  final VoidCallback onTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'DR';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = 96.r;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: diameter,
                  height: diameter,
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brandMain, width: 3),
                  ),
                  child: ClipOval(
                    child: (photoPath != null && photoPath!.isNotEmpty)
                        ? RouteXProfileImage(
                            path: photoPath,
                            placeholder: const SizedBox.shrink(),
                          )
                        : ColoredBox(
                            color: AppColors.iconBrand,
                            child: Center(
                              child: Text(
                                _initials,
                                style: AppTextStyles.s28Bold.copyWith(
                                  fontSize: AppFonts.size28.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                PositionedDirectional(
                  end: -4.r,
                  bottom: -2.r,
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: AppColors.brandMain,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceWhite, width: 2),
                    ),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 18.r,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: AppTextStyles.s16Bold.copyWith(
              fontSize: AppFonts.size16.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlighted, read-only row showing the vehicle. The company manages it, so
/// it carries a lock instead of opening an editor.
class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.vehicleType,
    required this.vehicleNumber,
    required this.subtitle,
  });

  final String vehicleType;
  final String vehicleNumber;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 12.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.iconBrand,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.brandMain, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandMain, width: 1.5),
            ),
            child: vehicleTypeIcon(vehicleType).svg(
              colorFilter: ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.vehicleTypeLabel(vehicleType)} • $vehicleNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s20Bold.copyWith(
                    fontSize: AppFonts.size20.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
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
          SizedBox(width: 8.w),
          Icon(Icons.lock_outline, size: 24.r, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
