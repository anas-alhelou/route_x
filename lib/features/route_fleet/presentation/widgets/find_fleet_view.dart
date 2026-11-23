// lib/features/route_fleet/presentation/widgets/find_fleet_view.dart
import 'package:routex_mobile/core/widgets/routex_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/custom_button.dart';
import 'package:routex_mobile/core/widgets/routex_skeleton.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';
import 'package:routex_mobile/features/route_fleet/presentation/pages/enter_fleet_code_page.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

class FindFleetView extends StatefulWidget {
  const FindFleetView({super.key});

  @override
  State<FindFleetView> createState() => _FindFleetViewState();
}

class _FindFleetViewState extends State<FindFleetView> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = context.read<RouteFleetCubit>().state;
    final initialQuery = state is RouteFleetFindFleetState
        ? state.searchQuery
        : '';
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<RouteFleetCubit>().updateSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RouteFleetCubit>().state;
    final findState = state is RouteFleetFindFleetState ? state : null;
    final selectedFilter =
        findState?.selectedFilter ??
        (state is RouteFleetRequestedState ? state.selectedFilter : 'Nearby');
    final isRequested = state is RouteFleetRequestedState;
    final requestedFleetName = state is RouteFleetRequestedState
        ? state.fleetName
        : 'Red Sea Express';

    final fleets = findState?.fleets ?? [];
    final isLoading = findState?.isLoading ?? false;
    final errorMessage = findState?.errorMessage;

    final query = _searchController.text.trim().toLowerCase();
    final hasNoResults =
        query.isNotEmpty &&
        !isLoading &&
        fleets.isEmpty &&
        errorMessage == null;

    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Top Bar ────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () =>
                            context.read<RouteFleetCubit>().goToNoFleet(),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.brandBlack,
                          size: 24,
                        ),
                      ),
                      // Jeddah Location Button
                      Container(
                        width: 88.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0xFF8CE600),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              size: 16,
                              color: Color(0xFF8CE600),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Jeddah',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Header Section ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(
                                text: context.tr.routeFindYour,
                                style: TextStyle(color: AppColors.slateInk),
                              ),
                              TextSpan(
                                text: context.tr.routeFleetWord,
                                style: TextStyle(color: AppColors.blueLink),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          context.tr.routeSearchBrowseFleets,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.slateMuted,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Search & Filter Controls ──────────────────────
                        RouteXSearchField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          hintText: context.tr.routeSearchFleetHint,
                          showClearButton: true,
                          onChanged: (val) {
                            setState(() {});
                            context.read<RouteFleetCubit>().updateSearchQuery(
                              val,
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // ── Filter Chips Row ───────────────────────────────
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: context.tr.routeFilterNearby,
                                isSelected: selectedFilter == 'Nearby',
                                onTap: () => context
                                    .read<RouteFleetCubit>()
                                    .goToFindFleet(
                                      filter: 'Nearby',
                                      searchQuery: _searchController.text,
                                    ),
                              ),
                              SizedBox(width: 8.w),
                              _FilterChip(
                                label: context.tr.routeFilterOpenToJoin,
                                isSelected: selectedFilter == 'Open to join',
                                onTap: () => context
                                    .read<RouteFleetCubit>()
                                    .goToFindFleet(
                                      filter: 'Open to join',
                                      searchQuery: _searchController.text,
                                    ),
                              ),
                              SizedBox(width: 8.w),
                              _FilterChip(
                                label: context.tr.routeFilterAllFleets,
                                isSelected: selectedFilter == 'All fleets',
                                onTap: () => context
                                    .read<RouteFleetCubit>()
                                    .goToFindFleet(
                                      filter: 'All fleets',
                                      searchQuery: _searchController.text,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 13.5.h),

                // ── Animated Content ──────────────────────────────────────
                Expanded(
                  child: isLoading
                      ? Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            children: [
                              RouteXSkeleton.block(
                                width: double.infinity,
                                height: 70.h,
                                radius: 16.r,
                              ),
                              SizedBox(height: 12.h),
                              RouteXSkeleton.block(
                                width: double.infinity,
                                height: 70.h,
                                radius: 16.r,
                              ),
                            ],
                          ),
                        )
                      : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.errorRedText,
                                  size: 48,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.slateInk,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<RouteFleetCubit>()
                                      .searchFleets(_searchController.text),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8CE600),
                                    foregroundColor: AppColors.onBrand,
                                  ),
                                  child: Text(context.tr.routeRetry),
                                ),
                              ],
                            ),
                          ),
                        )
                      : hasNoResults
                      ? SingleChildScrollView(
                          key: ValueKey(
                            'empty_search_${_searchController.text}',
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24.w,
                              40.h,
                              24.w,
                              160.h,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.icSearchEmpty,
                                  width: 72.w,
                                  height: 72.h,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 16.h),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 336.w),
                                  child: Text(
                                    context.tr.routeNoFleetsMatch(
                                      _searchController.text,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 26 / 20,
                                      color: AppColors.slateInk,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 336.w),
                                  child: Text(
                                    context.tr.routeTryShorterName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      height: 20 / 14,
                                      color: AppColors.slateMuted,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                OutlinedButton(
                                  onPressed: _clearSearch,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.slateInk,
                                    side: BorderSide(
                                      color: AppColors.hairline,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 10.h,
                                    ),
                                  ),
                                  child: Text(
                                    context.tr.routeClearSearch,
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          key: const ValueKey('fleet_list_view'),
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 160.h),
                          itemCount: fleets.length,
                          itemBuilder: (context, index) {
                            final fleet = fleets[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _FleetItemCard(
                                name: fleet.name,
                                location:
                                    fleet.address ??
                                    context.tr.routeFilterNearby,
                                drivers: fleet.driversCount != null
                                    ? context.tr.routeDriversCount(
                                        '${fleet.driversCount}',
                                      )
                                    : context.tr.routeActive,
                                status: 'ACTIVE',
                                logoColor: AppColors.blueLink,
                                isRequested:
                                    isRequested &&
                                    requestedFleetName == fleet.name,
                                onJoin: () => context
                                    .read<RouteFleetCubit>()
                                    .openJoinConfirmSheet(
                                      fleet.name,
                                      companyId: fleet.id,
                                    ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // ── Sticky Footer ─────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(
                  color: AppColors.brandBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr.routeGotInvite,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey666,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Center(
                      child: CustomButton(
                        text: context.tr.routeEnterFleetCode,
                        backgroundColor: AppColors.surfaceWhite,
                        textColor: AppColors.ink111,
                        borderColor: AppColors.hairline,
                        width: 360.w,
                        height: 56.h,
                        borderRadius: 6.r,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const EnterFleetCodePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RouteXTapScale(
      onTap: onTap,
      child: SizedBox(
        width: 97.w,
        height: 34.h,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF8CE600)
                : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(
              color: isSelected ? const Color(0xFF8CE600) : AppColors.hairline,
              width: 1.2,
            ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.brandBlack,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}

class _FleetItemCard extends StatelessWidget {
  const _FleetItemCard({
    required this.name,
    required this.location,
    required this.drivers,
    required this.status,
    required this.logoColor,
    required this.isRequested,
    required this.onJoin,
  });

  final String name;
  final String location;
  final String drivers;
  final String status;
  final Color logoColor;
  final bool isRequested;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 360.w,
        height: 105.h,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isRequested ? const Color(0xFF8CE600) : AppColors.hairline,
              width: isRequested ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo Box
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: logoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : 'F',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: logoColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          size: 12,
                          color: AppColors.grey666,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          location,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey666,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          width: 69.w,
                          height: 21.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8CE600),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 5.w,
                                height: 5.h,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                status,
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.surfaceWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          drivers,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey888,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Join Button or Requested Badge
              isRequested
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mistSurface,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.slateMuted2,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            context.tr.routeRequested,
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slateMuted2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomButton(
                      text: context.tr.routeJoin,
                      backgroundColor: const Color(0xFF8CE600),
                      textColor: AppColors.brandBlack,
                      width: 80.w,
                      height: 36.h,
                      borderRadius: 4.r,
                      icon: null,
                      onPressed: onJoin,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
