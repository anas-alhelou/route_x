// lib/features/auth/presentation/widgets/google_vehicle_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/features/auth/domain/entities/vehicle_type.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/vehicle_type_selector.dart';
import 'package:routex_mobile/core/widgets/routex_error_dialog.dart';

/// Reusable "collect the vehicle" form required before `POST /auth/google`.
///
/// Purely presentational and callback-driven: it owns no bloc, never touches the
/// Google SDK and never receives an ID token. Whoever opens it owns the token in
/// memory and receives the collected [VehicleType] + plate number through
/// [onSubmit]. Both the login and the signup Google flows render this same
/// widget, so the two cannot drift apart.
///
/// The form is never submitted without a vehicle type and a non-empty, trimmed
/// plate number: [onSubmit] is simply not called otherwise.
class GoogleVehicleStep extends StatefulWidget {
  const GoogleVehicleStep({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  /// Reports the collected vehicle type and trimmed plate number.
  final void Function(VehicleType type, String number) onSubmit;

  /// Whether a request is in flight. Bound to the submit button's spinner only;
  /// the form itself stays interactive otherwise.
  final bool isLoading;

  @override
  State<GoogleVehicleStep> createState() => _GoogleVehicleStepState();
}

class _GoogleVehicleStepState extends State<GoogleVehicleStep> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  String? _selectedVehicle;

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  /// Validates both fields and reports the result to the owner.
  ///
  /// A whitespace-only plate number fails validation exactly like an empty one,
  /// so a request can never carry a blank vehicle number.
  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final type = VehicleType.fromDisplayKey(_selectedVehicle);
    if (type == null) {
      RouteXErrorDialog.show(
        context: context,
        message: context.translateValidationKey('errVehicleRequired'),
      );
      return;
    }

    widget.onSubmit(type, _vehicleNumberController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr.vehicleTypeLabel,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontFamilyFallback: AppFonts.fontFamilyFallback,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          VehicleTypeSelector(
            selectedVehicle: _selectedVehicle,
            cardHeight: 104,
            onSelected: (value) => setState(() => _selectedVehicle = value),
          ),
          SizedBox(height: 18.h),
          RouteXTextField(
            controller: _vehicleNumberController,
            labelText: context.tr.vehicleNumber,
            hintText: context.tr.vehicleNumberHint,
            textInputAction: TextInputAction.done,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.translateValidationKey(
                  'errVehicleNumberRequired',
                );
              }
              return null;
            },
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 10.w),
              child: Assets.icons.svg.icVehicleBadge.svg(),
            ),
          ),
          SizedBox(height: 24.h),
          RouteXMainButton(
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _onSubmit,
            text: context.tr.next,
          ),
        ],
      ),
    );
  }
}
