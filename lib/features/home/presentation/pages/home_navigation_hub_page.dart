// lib/features/home/presentation/pages/home_navigation_hub_page.dart
import 'package:routex_mobile/core/widgets/routex_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/bloc/language/language_bloc.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/presentation/pages/delivery_dashboard_page.dart';
import 'package:routex_mobile/features/home/presentation/pages/home_page.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_sheet.dart';
import 'package:routex_mobile/features/main_layout/presentation/pages/main_layout_screen.dart';

/// Categories for filtering Home navigation items.
enum HomeNavCategory { all, scenarios, notifications, fleet, shell }

/// A destination or scenario target displayed in the Home Navigation Hub.
class HomeNavTarget {
  const HomeNavTarget({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.onLaunch,
    required this.searchKeywords,
  });

  final String id;
  final String Function(BuildContext) title;
  final String Function(BuildContext) description;
  final HomeNavCategory category;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final void Function(BuildContext) onLaunch;
  final List<String> searchKeywords;
}

/// A dedicated developer and testing showcase screen to navigate across all
/// Home screens, delivery dashboard states (HM0 through HM9), notification
/// states (N01, N02), fleet flows, and app shell.
class HomeNavigationHubPage extends StatefulWidget {
  const HomeNavigationHubPage({super.key});

  @override
  State<HomeNavigationHubPage> createState() => _HomeNavigationHubPageState();
}

class _HomeNavigationHubPageState extends State<HomeNavigationHubPage> {
  final TextEditingController _searchController = TextEditingController();
  HomeNavCategory _selectedCategory = HomeNavCategory.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HomeNavTarget> _getAllTargets(BuildContext context) {
    return [
      // ── Scenarios ──────────────────────────────────────────────────────────
      HomeNavTarget(
        id: 'HM1',
        title: (ctx) => ctx.tr.homeNavScenarioHm1Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm1Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: AppColors.brandMain,
        badgeTextColor: AppColors.textPrimary,
        icon: Icons.play_circle_outline_rounded,
        searchKeywords: const [
          'hm1',
          'ready',
          'start',
          'delivery',
          'جاهز',
          'بدء',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.readyToStart,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM2',
        title: (ctx) => ctx.tr.homeNavScenarioHm2Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm2Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: AppColors.blueStrong,
        badgeTextColor: Colors.white,
        icon: Icons.navigation_outlined,
        searchKeywords: const [
          'hm2',
          'route',
          'on route',
          'stop',
          'مسار',
          'محطة',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.onRoute,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM3',
        title: (ctx) => ctx.tr.homeNavScenarioHm3Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm3Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: const Color(0xFF059669),
        badgeTextColor: Colors.white,
        icon: Icons.task_alt_rounded,
        searchKeywords: const [
          'hm3',
          'caught up',
          'completed',
          'all',
          'اكتملت',
          'تسليم',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.allCaughtUp,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM4',
        title: (ctx) => ctx.tr.homeNavScenarioHm4Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm4Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: const Color(0xFFD97706),
        badgeTextColor: Colors.white,
        icon: Icons.wifi_off_rounded,
        searchKeywords: const [
          'hm4',
          'offline',
          'internet',
          'connection',
          'انترنت',
          'اتصال',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.offline,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM5',
        title: (ctx) => ctx.tr.homeNavScenarioHm5Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm5Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: const Color(0xFF7C3AED),
        badgeTextColor: Colors.white,
        icon: Icons.waving_hand_outlined,
        searchKeywords: const [
          'hm5',
          'first day',
          'new driver',
          'أول يوم',
          'سائق',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.firstDay,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM6',
        title: (ctx) => ctx.tr.homeNavScenarioHm6Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm6Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: const Color(0xFF4B5563),
        badgeTextColor: Colors.white,
        icon: Icons.inbox_outlined,
        searchKeywords: const [
          'hm6',
          'no orders',
          'empty today',
          'لا توجد طلبات',
          'فارغة',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.noOrdersToday,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM8',
        title: (ctx) => ctx.tr.homeNavScenarioHm8Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm8Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: const Color(0xFFDB2777),
        badgeTextColor: Colors.white,
        icon: Icons.notification_add_outlined,
        searchKeywords: const [
          'hm8',
          'new order',
          'overlay',
          'banner',
          'first day',
          'طلب جديد',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.newOrderFirstDay,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM9',
        title: (ctx) => ctx.tr.homeNavScenarioHm9Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm9Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: const Color(0xFFDB2777),
        badgeTextColor: Colors.white,
        icon: Icons.notification_important_outlined,
        searchKeywords: const [
          'hm9',
          'new order',
          'overlay',
          'on route',
          'طلب وارد',
          'مسار',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.newOrderOnRoute,
            ),
          ),
        ),
      ),
      HomeNavTarget(
        id: 'HM0',
        title: (ctx) => ctx.tr.homeNavScenarioHm0Title,
        description: (ctx) => ctx.tr.homeNavScenarioHm0Desc,
        category: HomeNavCategory.scenarios,
        badgeColor: const Color(0xFF9CA3AF),
        badgeTextColor: Colors.white,
        icon: Icons.hourglass_empty_rounded,
        searchKeywords: const [
          'hm0',
          'loading',
          'skeleton',
          'shimmer',
          'تحميل',
          'هيكل',
        ],
        onLaunch: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (_) => const DeliveryDashboardPage(
              initialScenario: DeliveryScenario.loading,
            ),
          ),
        ),
      ),

      // ── Notifications ───────────────────────────────────────────────────────
      HomeNavTarget(
        id: 'N01',
        title: (ctx) => ctx.tr.homeNavScreenN01Title,
        description: (ctx) => ctx.tr.homeNavScreenN01Desc,
        category: HomeNavCategory.notifications,
        badgeColor: AppColors.brandMain,
        badgeTextColor: AppColors.textPrimary,
        icon: Icons.notifications_active_outlined,
        searchKeywords: const [
          'n01',
          'notifications',
          'list',
          'inbox',
          'unread',
          'إشعارات',
          'قائمة',
        ],
        onLaunch: (ctx) =>
            ctx.push(RoutersName.notificationsScreen, extra: false),
      ),
      HomeNavTarget(
        id: 'N02',
        title: (ctx) => ctx.tr.homeNavScreenN02Title,
        description: (ctx) => ctx.tr.homeNavScreenN02Desc,
        category: HomeNavCategory.notifications,
        badgeColor: AppColors.grey6B7280,
        badgeTextColor: Colors.white,
        icon: Icons.notifications_none_outlined,
        searchKeywords: const [
          'n02',
          'notifications',
          'empty',
          '3d bell',
          'فارغة',
          'جرس',
        ],
        onLaunch: (ctx) =>
            ctx.push(RoutersName.notificationsScreen, extra: true),
      ),

      // ── Fleet & Joining ─────────────────────────────────────────────────────
      HomeNavTarget(
        id: 'FL01',
        title: (ctx) => ctx.tr.homeNavScreenFindFleetTitle,
        description: (ctx) => ctx.tr.homeNavScreenFindFleetDesc,
        category: HomeNavCategory.fleet,
        badgeColor: const Color(0xFF0284C7),
        badgeTextColor: Colors.white,
        icon: Icons.search_rounded,
        searchKeywords: const [
          'fl01',
          'find',
          'fleet',
          'nearby',
          'بحث',
          'أسطول',
        ],
        onLaunch: (ctx) => ctx.push(RoutersName.findFleetScreen),
      ),
      HomeNavTarget(
        id: 'FL02',
        title: (ctx) => ctx.tr.homeNavScreenEnterCodeTitle,
        description: (ctx) => ctx.tr.homeNavScreenEnterCodeDesc,
        category: HomeNavCategory.fleet,
        badgeColor: const Color(0xFF0D9488),
        badgeTextColor: Colors.white,
        icon: Icons.pin_outlined,
        searchKeywords: const [
          'fl02',
          'enter',
          'code',
          'fleet code',
          'كود',
          'رمز',
        ],
        onLaunch: (ctx) => ctx.push(RoutersName.enterFleetCodeScreen),
      ),
      HomeNavTarget(
        id: 'J01-J10',
        title: (ctx) => 'Join Company Flow (J01 · J02 · J03 · J04 · J10)',
        description: (ctx) =>
            'Company code entry, validation errors, confirm company, and review timeline.',
        category: HomeNavCategory.fleet,
        badgeColor: const Color(0xFF8FE600),
        badgeTextColor: Colors.black,
        icon: Icons.business_outlined,
        searchKeywords: const [
          'join',
          'company',
          'j01',
          'j02',
          'j03',
          'j04',
          'j10',
          'شركة',
          'انضمام',
        ],
        onLaunch: (ctx) => ctx.push(RoutersName.joinCompanyScreen),
      ),
      HomeNavTarget(
        id: 'HM-FR',
        title: (ctx) => ctx.tr.homeNavScreenHomeFirstRunTitle,
        description: (ctx) => ctx.tr.homeNavScreenHomeFirstRunDesc,
        category: HomeNavCategory.fleet,
        badgeColor: const Color(0xFF4F46E5),
        badgeTextColor: Colors.white,
        icon: Icons.home_outlined,
        searchKeywords: const [
          'first run',
          'overview',
          'get started',
          'بدء',
          'بداية',
        ],
        onLaunch: (ctx) => Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) => const HomePage())),
      ),

      // ── App Shell ───────────────────────────────────────────────────────────
      HomeNavTarget(
        id: 'SHELL',
        title: (ctx) => ctx.tr.homeNavScreenMainShellTitle,
        description: (ctx) => ctx.tr.homeNavScreenMainShellDesc,
        category: HomeNavCategory.shell,
        badgeColor: const Color(0xFF111827),
        badgeTextColor: Colors.white,
        icon: Icons.layers_outlined,
        searchKeywords: const [
          'shell',
          'main layout',
          'tabs',
          'bottom nav',
          'هيكل',
          'تبويبات',
        ],
        onLaunch: (ctx) => Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) => const MainLayoutScreen())),
      ),
    ];
  }

  List<HomeNavTarget> _filterTargets(
    List<HomeNavTarget> targets,
    BuildContext context,
  ) {
    return targets.where((target) {
      if (_selectedCategory != HomeNavCategory.all &&
          target.category != _selectedCategory) {
        return false;
      }

      if (_searchQuery.isEmpty) return true;

      final title = target.title(context).toLowerCase();
      final desc = target.description(context).toLowerCase();
      final id = target.id.toLowerCase();
      final keywords = target.searchKeywords
          .map((k) => k.toLowerCase())
          .toList();

      return id.contains(_searchQuery) ||
          title.contains(_searchQuery) ||
          desc.contains(_searchQuery) ||
          keywords.any((k) => k.contains(_searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTargets = _getAllTargets(context);
    final filteredTargets = _filterTargets(allTargets, context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar Header ───────────────────────────────────────────────
            _buildHeader(context, isArabic, filteredTargets.length),

            // ── Search & Filter Row ──────────────────────────────────────────
            _buildSearchAndFilters(context),

            // ── Targets List ─────────────────────────────────────────────────
            Expanded(
              child: filteredTargets.isEmpty
                  ? _buildEmptySearch(context)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 26.w,
                        vertical: 12.h,
                      ),
                      itemCount: filteredTargets.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final target = filteredTargets[index];
                        return _buildTargetCard(context, target, isArabic);
                      },
                    ),
            ),

            // ── Quick Modals Tester Bar ──────────────────────────────────────
            _buildQuickModalsBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isArabic, int visibleCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.borderCard, width: 1.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTint,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: AppColors.brandMain, width: 1.w),
                  ),
                  child: Text(
                    'RouteX · Navigator',
                    style: TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Language Switcher
              InkWell(
                onTap: () {
                  context.read<LanguageBloc>().add(ToggleLanguageEvent());
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCanvas,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.borderCard, width: 1.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 14.r,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        isArabic ? 'العربية 🇸🇦' : 'English 🇬🇧',
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            context.tr.homeNavHubTitle,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr.homeNavHubSubtitle,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      color: AppColors.surfaceWhite,
      padding: EdgeInsets.only(left: 26.w, right: 26.w, bottom: 12.h),
      child: Column(
        children: [
          // Search bar
          RouteXSearchField(
            controller: _searchController,
            hintText: context.tr.homeNavHubSearchHint,
            showClearButton: true,
            onChanged: (_) {},
          ),
          SizedBox(height: 10.h),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip(
                  label: context.tr.homeNavCategoryAll,
                  category: HomeNavCategory.all,
                ),
                SizedBox(width: 6.w),
                _buildFilterChip(
                  label: context.tr.homeNavCategoryScenarios,
                  category: HomeNavCategory.scenarios,
                ),
                SizedBox(width: 6.w),
                _buildFilterChip(
                  label: context.tr.homeNavCategoryNotifications,
                  category: HomeNavCategory.notifications,
                ),
                SizedBox(width: 6.w),
                _buildFilterChip(
                  label: context.tr.homeNavCategoryFleet,
                  category: HomeNavCategory.fleet,
                ),
                SizedBox(width: 6.w),
                _buildFilterChip(
                  label: context.tr.homeNavCategoryShell,
                  category: HomeNavCategory.shell,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required HomeNavCategory category,
  }) {
    final bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandMain : AppColors.surfaceCanvas,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.brandMain : AppColors.borderCard,
            width: 1.w,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.fontFamilySatoshi,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetCard(
    BuildContext context,
    HomeNavTarget target,
    bool isArabic,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => target.onLaunch(context),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.borderCard, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: target.badgeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    target.icon,
                    size: 22.r,
                    color: target.badgeColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Tag Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: target.badgeColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            target.id,
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: target.badgeTextColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            target.title(context),
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilySatoshi,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      target.description(context),
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilySatoshi,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Arrow Action
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Transform.flip(
                  flipX: isArabic,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.r,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 40.r, color: AppColors.textHint),
          SizedBox(height: 10.h),
          Text(
            context.tr.noResultsFound,
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickModalsBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppColors.borderCard, width: 1.w),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                showGoOnlineSheet(
                  context,
                  reason: GoOnlineBlockedReason.noFleet,
                );
              },
              icon: Icon(Icons.flash_on_rounded, size: 16.r),
              label: Text(
                'Go Online Sheet',
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.borderSubtle, width: 1.w),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DeliveryDashboardPage(
                      initialScenario: DeliveryScenario.readyToStart,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.rocket_launch_rounded, size: 16.r),
              label: Text(
                'Launch Home',
                style: TextStyle(
                  fontFamily: AppFonts.fontFamilySatoshi,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandMain,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
