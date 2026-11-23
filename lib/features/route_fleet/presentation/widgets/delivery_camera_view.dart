import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import '../services/proof_camera_service.dart';
import 'delivery_illustration_view.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

/// P01: live camera for the proof-of-delivery photo.
///
/// Shows the device camera behind the Figma controls. While the camera starts,
/// or when it is not available, the Figma illustration is shown instead.
class DeliveryCameraView extends StatefulWidget {
  const DeliveryCameraView({
    super.key,
    required this.stopNumber,
    required this.customerName,
    this.doorNumber,
    required this.requiresSignature,
    required this.onCloseTapped,
    required this.onShutterTapped,
    this.cameraService,
  });

  final int stopNumber;
  final String customerName;
  final String? doorNumber;
  final bool requiresSignature;
  final VoidCallback onCloseTapped;

  /// Called with the path of the photo that was taken.
  final ValueChanged<String> onShutterTapped;

  /// Camera used by this screen (a fake in tests). Defaults to the device camera.
  final ProofCameraService? cameraService;

  @override
  State<DeliveryCameraView> createState() => _DeliveryCameraViewState();
}

class _DeliveryCameraViewState extends State<DeliveryCameraView> {
  late final ProofCameraService _camera;
  ProofCameraStatus? _status;
  bool _isTaking = false;

  @override
  void initState() {
    super.initState();
    _camera = widget.cameraService ?? DeviceProofCameraService();
    _startCamera();
  }

  Future<void> _startCamera() async {
    final status = await _camera.start();
    if (!mounted) return;
    setState(() => _status = status);
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _onShutter() async {
    if (_isTaking) return;
    if (_status != ProofCameraStatus.ready) {
      // Not ready (permission denied / unavailable): try again.
      setState(() => _status = null);
      await _startCamera();
      return;
    }
    setState(() => _isTaking = true);
    final path = await _camera.takePhoto();
    if (!mounted) return;
    setState(() => _isTaking = false);
    if (path != null) widget.onShutterTapped(path);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final subtitleText = widget.requiresSignature
        ? context.tr.routePhotoThenSignature
        : context.tr.routeRequiredEveryDelivery;
    final isReady = _status == ProofCameraStatus.ready;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: Stack(
        children: [
          // 1. Live camera, or the Figma illustration while it starts / is unavailable
          Positioned.fill(
            child: isReady
                ? _camera.buildPreview()
                : DeliveryIllustrationView(
                    doorNumber: widget.doorNumber,
                    isFullFrame: true,
                  ),
          ),

          // 2. Framing guide (300 x 531 at x56, y175) - camera_framing_guide.svg
          Positioned(
            top: 175.h,
            left: 56.w,
            width: 300.w,
            height: 531.h,
            child: SvgPicture.asset(
              AppAssets.cameraFramingGuide,
              width: 300.w,
              height: 531.h,
            ),
          ),

          // 3. Close button (44 x 44 at 20, 60) - camera_close.svg
          Positioned(
            top: 60.h,
            left: 20.w,
            child: InkWell(
              onTap: widget.onCloseTapped,
              borderRadius: BorderRadius.circular(22.r),
              child: SvgPicture.asset(
                AppAssets.cameraClose,
                width: 44.w,
                height: 44.h,
                colorFilter: ColorFilter.mode(AppColors.brandBlack, BlendMode.srcIn),
              ),
            ),
          ),

          // 4. Stop tag (top, centered, y64)
          Positioned(
            top: 64.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppSizes.r100),
                  boxShadow: AppTextStyles.summaryChipShadow,
                ),
                child: Text(
                  context.tr.routeStopNumberName(widget.stopNumber.toString(), widget.customerName),
                  style: AppTextStyles.s13Bold.copyWith(color: AppColors.brandBlack),
                ),
              ),
            ),
          ),

          // 5. Hint (centered, y118) - or the permission message when the camera is blocked
          Positioned(
            top: 118.h,
            left: 0,
            right: 0,
            child: Center(
              child: _status == ProofCameraStatus.permissionDenied
                  ? _CameraMessage(
                      text: context.tr.routeAllowCameraAccess,
                      onTap: openAppSettings,
                    )
                  : _status == ProofCameraStatus.unavailable
                      ? _CameraMessage(text: context.tr.routeCameraUnavailable)
                      : Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(AppSizes.r100),
                            boxShadow: AppTextStyles.summaryChipShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppAssets.routeIcPackage,
                                width: 16.w,
                                height: 16.h,
                                colorFilter: ColorFilter.mode(
                                  AppColors.statusAmber,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                context.tr.routeShowPackageAndDoor,
                                style: AppTextStyles.s12BoldAmber,
                              ),
                            ],
                          ),
                        ),
            ),
          ),

          // 6. Camera panel (bottom, y718, height 199, full width)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 199.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.r26),
                ),
                boxShadow: AppTextStyles.tripSheetShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr.routePhotoOfDelivery,
                    style: AppTextStyles.s16Bold.copyWith(color: AppColors.brandBlack),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitleText,
                    style: AppTextStyles.s12Regular145.copyWith(color: AppColors.textBody),
                  ),
                  SizedBox(height: 14.h),

                  // Shutter button - camera_shutter.svg
                  RouteXTapScale(
                    onTap: _onShutter,
                    child: Opacity(
                      opacity: _isTaking ? 0.5 : 1,
                      child: SvgPicture.asset(
                        AppAssets.cameraShutter,
                        width: 76.w,
                        height: 76.h,
                      ),
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
}

/// Pill shown in the hint position when the camera cannot be used.
class _CameraMessage extends StatelessWidget {
  const _CameraMessage({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppSizes.r100),
          boxShadow: AppTextStyles.summaryChipShadow,
        ),
        child: Text(text, style: AppTextStyles.s12BoldAmber),
      ),
    );
  }
}
