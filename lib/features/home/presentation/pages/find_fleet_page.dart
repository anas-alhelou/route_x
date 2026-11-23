// lib/features/home/presentation/pages/find_fleet_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/config/constants/app_sizes.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/theme/app_text_styles.dart';
import 'package:routex_mobile/core/widgets/routex_error_dialog.dart';
import 'package:routex_mobile/core/widgets/routex_load_failed.dart';
import 'package:routex_mobile/core/widgets/routex_top_bar.dart';
import 'package:routex_mobile/core/widgets/routex_loading_overlay.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/presentation/bloc/find_fleet_bloc.dart';
import 'package:routex_mobile/features/home/presentation/navigation/home_navigator.dart';
import 'package:routex_mobile/features/home/presentation/widgets/find_fleet_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/find_fleet_invite_footer.dart';
import 'package:routex_mobile/features/home/presentation/widgets/find_fleet_location_pill.dart';
import 'package:routex_mobile/features/home/presentation/widgets/find_fleet_search_field.dart';
import 'package:routex_mobile/features/home/presentation/widgets/fleet_filter_chips.dart';

/// Find a Fleet — Figma 5237:3435.
///
/// Self-providing like [HomePage]: wraps its content in a [BlocProvider] for
/// [FindFleetBloc] so the route never depends on an ancestor to supply the
/// bloc. The page is pushed via `HomeNavigator.toFindFleet` and pops with
/// `context.pop()`.
///
/// Layout follows the design's four stacked bands exactly: a 56pt top bar, then
/// a scrolling column padded 26/32/26/159, then the sticky invite footer. The
/// 159pt bottom padding is the footer's own 127pt plus 32pt of breathing room,
/// so the fifth fleet card clears the footer instead of hiding behind it.
class FindFleetPage extends StatelessWidget {
  const FindFleetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FindFleetBloc>(
      create: (_) => getIt<FindFleetBloc>()..add(const FindFleetStarted()),
      child: const _FindFleetView(),
    );
  }
}

class _FindFleetView extends StatelessWidget {
  const _FindFleetView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FindFleetBloc, FindFleetState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        RouteXErrorDialog.show(
          context: context,
          message: context.translateValidationKey(state.errorMessage!),
        );
        context.read<FindFleetBloc>().add(const FindFleetErrorDismissed());
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                RouteXTopBar(
                  height: AppSizes.topBarH56,
                  backgroundColor: AppColors.surfaceBackground,
                  onBack: () => context.pop(),
                  trailing: const FindFleetLocationPill(),
                ),
                Expanded(
                  child: switch (state.status) {
                    FindFleetStatus.initial || FindFleetStatus.loading =>
                      const RouteXLoadingOverlay(isLoading: true, child: SizedBox.expand()),
                    FindFleetStatus.failure => RouteXLoadFailed(
                      onRetry: () => context.read<FindFleetBloc>().add(
                        const FindFleetStarted(),
                      ),
                    ),
                    FindFleetStatus.success => _FindFleetContent(state: state),
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: FindFleetInviteFooter(
            onEnterFleetCode: () =>
                const HomeNavigator().toEnterFleetCode(context),
          ),
        );
      },
    );
  }
}

class _FindFleetContent extends StatelessWidget {
  const _FindFleetContent({required this.state});

  final FindFleetState state;

  /// The three chips the design draws, in its order.
  ///
  /// Repeated as a literal rather than read off `FleetFilter.values` because the
  /// enum's order is not the design's, and because `paused` has no chip — a
  /// driver cannot ask to see fleets that are not taking them.
  static const List<FleetFilter> _designFilters = [
    FleetFilter.nearby,
    FleetFilter.active,
    FleetFilter.all,
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<FindFleetBloc>().add(const FindFleetRefreshed()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSizes.screenGutter,
          AppSpacing.s32,
          AppSizes.screenGutter,
          // The footer's 127pt plus 32pt of clearance, as one token — the two
          // have to move together or the last card disappears behind the footer.
          AppSizes.findFleetBottomInset,
        ),
        children: [
          Text(
            tr.findFleetTitle,
            style: AppTextStyles.pageTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.s9.h),
          Text(
            tr.findFleetSubtitle,
            style: AppTextStyles.pageSubtitle.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.s20.h),
          FindFleetSearchField(
            hintText: tr.findFleetSearchHint,
            initialValue: state.query,
            onChanged: (value) => context.read<FindFleetBloc>().add(
              FindFleetQueryChanged(query: value),
            ),
          ),
          SizedBox(height: AppSpacing.s16.h),
          FleetFilterChips(
            filters: state.availableFilters.isEmpty
                ? _designFilters
                : state.availableFilters,
            selected: state.selectedFilter,
            onSelected: (filter) => context.read<FindFleetBloc>().add(
              FindFleetFilterSelected(filter: filter),
            ),
            labelFor: (filter) => _filterLabel(filter, tr),
          ),
          SizedBox(height: AppSpacing.s24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tr.findFleetSectionLabel,
                style: AppTextStyles.sectionEyebrow.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                // Counts joinable fleets, not rows: the design lists five cards
                // and reads "4 results", because the fifth is paused.
                tr.findFleetResultsCount(state.joinableCount),
                style: AppTextStyles.resultCount.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),
          if (state.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
              child: Center(
                child: Text(
                  tr.noResultsFound,
                  style: AppTextStyles.s14Regular.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            for (final fleet in state.fleets)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                child: FindFleetCard(
                  fleet: fleet,
                  isJoining: state.isSubmitting,
                  isJoinEnabled: !state.isSubmitting,
                  onJoin: () => context.read<FindFleetBloc>().add(
                    FindFleetJoinRequested(fleetId: fleet.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _filterLabel(FleetFilter filter, AppLocalizations tr) {
    return switch (filter) {
      FleetFilter.all => tr.findFleetFilterAll,
      FleetFilter.nearby => tr.findFleetFilterNearby,
      FleetFilter.active => tr.findFleetFilterActive,
      FleetFilter.paused => tr.findFleetFilterPaused,
    };
  }
}
