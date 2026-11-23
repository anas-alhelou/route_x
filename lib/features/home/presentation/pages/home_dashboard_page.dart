// lib/features/home/presentation/pages/home_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/widgets/dialogs/routex_alert_dialog.dart';
import 'package:routex_mobile/core/widgets/routex_skeleton.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/presentation/bloc/driver_status_cubit.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_dashboard_bloc.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/driver_header_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/performance_insights.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/referral_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/stats_grid.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/status_toggle_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/dashboard/upcoming_rides_section.dart';

/// The dashboard screen.
///
/// The only `StatefulWidget` in this block: it kicks off the first load and the
/// status load in [initState], then hands off to stateless sections. The blocs
/// are supplied by the caller so the page carries no `getIt` dependency and can
/// be pumped directly in a test.
class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({
    required this.bloc,
    required this.statusCubit,
    super.key,
  });

  final HomeDashboardBloc bloc;
  final DriverStatusCubit statusCubit;

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(const HomeDashboardInitialized());
    widget.statusCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeDashboardBloc>.value(value: widget.bloc),
        BlocProvider<DriverStatusCubit>.value(value: widget.statusCubit),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _onRefresh(BuildContext context) async {
    context
        .read<HomeDashboardBloc>()
        .add(const HomeDashboardRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _Header(state: state),
                  if (state.hasContent)
                    _Content(state: state)
                  else if (state.status == HomeDashboardStatus.failure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadFailed(
                        message: state.errorMessage,
                        onRetry: () => context
                            .read<HomeDashboardBloc>()
                            .add(const HomeDashboardInitialized()),
                      ),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RouteXSkeleton.block(width: double.infinity, height: 60, radius: 16),
                              SizedBox(height: 16),
                              RouteXSkeleton.block(width: double.infinity, height: 60, radius: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final HomeDashboardState state;

  @override
  Widget build(BuildContext context) {
    final driver = state.driver;
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.surfaceCanvas,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 168.h,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: driver == null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: DriverHeaderCard(
                  driver: driver,
                  onSettingsTap: () {},
                  onProfileTap: () {},
                ),
              ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final HomeDashboardState state;

  @override
  Widget build(BuildContext context) {
    final driver = state.driver!;
    final stats = state.stats!;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(height: 8.h),
          BlocBuilder<DriverStatusCubit, DriverStatusState>(
            builder: (context, statusState) {
              return StatusToggleCard(
                status: statusState.status?.status ?? DriverStatus.online,
                isUpdating: statusState.isUpdating,
                onChanged: (status) =>
                    context.read<DriverStatusCubit>().update(status),
              );
            },
          ),
          SizedBox(height: 16.h),
          StatsGrid(stats: stats),
          SizedBox(height: 20.h),
          BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
            buildWhen: (previous, current) =>
                !identical(previous.rides, current.rides),
            builder: (context, state) => UpcomingRidesSection(rides: state.rides),
          ),
          SizedBox(height: 20.h),
          ReferralCard(
            bonus: driver.referralBonus,
            onShare: () {
              RouteXAlertDialog.show(
                context: context,
                title: context.tr.successTitle,
                message: context.tr.referralLinkShared,
                icon: Icons.check_circle_outline,
                iconColor: AppColors.brandMain,
                confirmLabel: context.tr.routeOk,
              );
            },
          ),
          SizedBox(height: 20.h),
          PerformanceInsights(stats: stats),
          SizedBox(height: 32.h),
        ]),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 40.r, color: AppColors.textHint),
          SizedBox(height: 12.h),
          Text(
            message ?? 'Could not load your dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16.h),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: AppColors.brandMain),
            child: Text(
              'Retry',
              style: TextStyle(
                fontFamily: AppFonts.fontFamilySatoshi,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
