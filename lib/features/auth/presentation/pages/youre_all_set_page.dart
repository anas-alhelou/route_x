import 'package:flutter/material.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:routex_mobile/core/config/constants/assets.gen.dart';
import 'package:routex_mobile/core/widgets/routex_logo.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_page_header.dart';

/// Post-registration celebration screen shown after the email is verified.
/// Displays a success illustration and a "Start driving" call to action.
///
/// The call to action has to know whether the verification actually produced a
/// session, because that decides where "Start driving" can go: into the app when
/// there is one, or back to the login form when there is none. It receives only
/// that fact as [hasSession] — no token ever reaches this widget.
class YoureAllSetPage extends StatelessWidget {
  const YoureAllSetPage({super.key, required this.hasSession});

  /// Whether the verification issued a usable session.
  ///
  /// True when `POST /auth/verify-otp` returned tokens and the repository
  /// persisted them; false for a 2xx without tokens, where the account is
  /// activated but nobody is signed in yet.
  final bool hasSession;

  /// Where "Start driving" goes.
  ///
  /// With a session this is exactly where `LoginPage` sends a successful login
  /// (`RoutersName.appPermissionsScreen`), so both entry points continue into
  /// the same first-authenticated screen. Without one there is nothing to
  /// continue into, so the user is sent to the login form to establish a
  /// session.
  void _onStartDriving(BuildContext context) {
    context.go(
      hasSession ? RoutersName.joinCompanyScreen : RoutersName.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: RouteXAuthFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              const RouteXLogo(),
              SizedBox(height: 16.h),

              RouteXPageHeader(
                titleStart: context.tr.youreReadyTitleStart,
                titleEnd: context.tr.youreReadyTitleEnd,
                subtitle: context.tr.youreAllSetSubtitle,
                titleStartSize: AppFonts.size48,
                titleEndSize: AppFonts.size48,
              ),
              SizedBox(height: 40.h),

              Center(
                child: Assets.images.png.imgYoureAllSetIllustration.image(
                  width: 360.w,
                  height: 330.w,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 48.h),

              RouteXMainButton(
                isLoading: false,
                onPressed: () => _onStartDriving(context),
                text: context.tr.startDrivingLabel,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route payload for [YoureAllSetPage].
///
/// Carries the single fact the screen branches on. It travels as the route's
/// `extra`, so the router can build the page without reading storage or tokens
/// itself; a route reached without it (a deep link, for example) is rendered
/// with `hasSession: false` and therefore lands on the login form.
class YoureAllSetArgs {
  const YoureAllSetArgs({required this.hasSession});

  /// See [YoureAllSetPage.hasSession].
  final bool hasSession;
}
