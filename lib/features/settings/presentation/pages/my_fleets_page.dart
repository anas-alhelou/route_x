// lib/features/settings/presentation/pages/my_fleets_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import 'package:routex_mobile/core/widgets/routex_skeleton.dart';
import '../../domain/entities/nearby_fleet_entity.dart';
import '../../domain/usecases/get_nearby_fleets_usecase.dart';
import '../../domain/usecases/send_join_request_usecase.dart';
import '../navigation/settings_navigator.dart';
import '../widgets/fleet_logo.dart';
import '../widgets/settings_page_header.dart';
import '../widgets/settings_section_card.dart';

/// Fleet membership: the "not joined yet" state plus the fleets near the
/// driver they can ask to join.
class MyFleetsPage extends StatefulWidget {
  const MyFleetsPage({super.key});

  @override
  State<MyFleetsPage> createState() => _MyFleetsPageState();
}

class _MyFleetsPageState extends State<MyFleetsPage> {
  late final Future<List<NearbyFleetEntity>> _nearbyFleets =
      getIt<GetNearbyFleetsUseCase>()();

  /// Fleet whose join request is being sent; one at a time.
  String? _joiningFleetId;

  Future<void> _join(NearbyFleetEntity fleet) async {
    setState(() => _joiningFleetId = fleet.id);
    try {
      await getIt<SendJoinRequestUseCase>()(fleet.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _joiningFleetId = null);
      ErrorAlertDialog.show(
        context: context,
        message: context.tr.somethingWentWrong,
      );
      return;
    }
    if (!mounted) return;
    setState(() => _joiningFleetId = null);
    context.push(
      RoutersName.fleetRequestPendingScreen,
      extra: FleetRequestArgs(fleet: fleet, sentAt: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final cardPadding = EdgeInsetsDirectional.fromSTEB(16.w, 18.h, 16.w, 16.h);

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 32.h),
          children: [
            SettingsPageHeader(
              title: tr.settingsMyFleets,
              subtitle: tr.myFleetsSubtitle,
            ),
            SizedBox(height: 24.h),
            SettingsCard(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 24.h, 16.w, 16.h),
              children: [
                Center(
                  child: Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      color: AppColors.iconBrand,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.apartment_outlined,
                      size: 30.r,
                      color: AppColors.brandMain,
                    ),
                  ),
                ),
                Text(
                  tr.myFleetsEmptyTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s20Bold.copyWith(
                    fontSize: AppFonts.size20.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  tr.myFleetsEmptyBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s14Regular.copyWith(
                    fontSize: AppFonts.size14.sp,
                    color: AppColors.textGray,
                  ),
                ),
                RouteXMainButton(
                  isLoading: false,
                  onPressed: () => context.push(RoutersName.joinWithCodeScreen),
                  text: tr.myFleetsEnterCode,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SettingsCard(
              title: tr.myFleetsNearYou,
              subtitle: tr.myFleetsNearYouHint,
              padding: cardPadding,
              children: [
                FutureBuilder<List<NearbyFleetEntity>>(
                  future: _nearbyFleets,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: RouteXSkeleton.block(width: double.infinity, height: 60.h, radius: 16.r),
                      );
                    }
                    final fleets = snapshot.data ?? const <NearbyFleetEntity>[];
                    return Column(
                      children: [
                        for (var i = 0; i < fleets.length; i++) ...[
                          if (i > 0) SizedBox(height: 12.h),
                          _NearbyFleetTile(
                            fleet: fleets[i],
                            isJoining: _joiningFleetId == fleets[i].id,
                            onJoin: _joiningFleetId == null
                                ? () => _join(fleets[i])
                                : null,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tinted row: logo, fleet name, area and distance, and a Join button.
class _NearbyFleetTile extends StatelessWidget {
  const _NearbyFleetTile({
    required this.fleet,
    required this.onJoin,
    this.isJoining = false,
  });

  final NearbyFleetEntity fleet;

  /// Null while another fleet's request is being sent.
  final VoidCallback? onJoin;

  /// Shows a spinner in the button while this fleet's request is sent.
  final bool isJoining;

  @override
  Widget build(BuildContext context) {
    final distance = NumberFormat(
      '0.0',
      Localizations.localeOf(context).toString(),
    ).format(fleet.distanceKm);
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 14.h, 12.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.iconBrand,
        borderRadius: BorderRadius.circular(12.r),
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
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Assets.icons.svg.carbonLocation.svg(
                      width: 14.r,
                      height: 14.r,
                      colorFilter: ColorFilter.mode(
                        AppColors.textGray,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '${fleet.area} • ${context.tr.myFleetsDistanceKm(distance)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.s14Regular.copyWith(
                          fontSize: AppFonts.size14.sp,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandMain,
              foregroundColor: AppColors.textPrimary,
              // Stay green while disabled during another row's request.
              disabledBackgroundColor: AppColors.brandMain,
              disabledForegroundColor: AppColors.textPrimary,
              elevation: 0,
              minimumSize: Size(76.w, 34.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            child: isJoining
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Text(
                    context.tr.settingsJoin,
                    style: AppTextStyles.s14Bold.copyWith(
                      fontSize: AppFonts.size14.sp,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
