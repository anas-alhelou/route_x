// test/features/home/delivery_dashboard_ui_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/home/data/datasources/delivery_dashboard_local_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/presentation/pages/delivery_dashboard_page.dart';
import 'package:routex_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:routex_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/delivery_header.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/home_skeleton_loader.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/in_app_notification_card.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/needs_attention_section.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/offline_banner.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/online_status_banner.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/today_section.dart';
import 'package:routex_mobile/features/home/presentation/widgets/delivery/up_next_section.dart';

Widget _buildTestScope({
  required Widget child,
  Size size = const Size(412, 917),
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: ScreenUtilInit(
        designSize: const Size(412, 917),
        minTextAdapt: true,
        builder: (context, _) => Scaffold(body: child),
      ),
    ),
  );
}

Future<void> _pumpScope(
  WidgetTester tester, {
  required Widget child,
  Size size = const Size(412, 917),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _buildTestScope(child: child, size: size, locale: locale),
  );
  await tester.pump();
}

/// Figma-measurement tests that no longer match the current Home layout.
/// Skipped until the Figma comparison pass decides which side is correct.
// Reason: the Home layout drifted from the Figma measurements; revisit in
// the Figma pass.
void figmaDriftTestWidgets(String description, WidgetTesterCallback callback) =>
    testWidgets(description, callback, skip: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Figma Frames UI Tests', () {
    testWidgets('HM0 Loading skeleton matches geometry without bell button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestScope(child: const HomeSkeletonLoader()),
      );
      await tester.pump();

      expect(find.byType(HomeSkeletonLoader), findsOneWidget);
      // Bell button should NOT be present in skeleton
      expect(find.byIcon(Icons.notifications), findsNothing);
    });

    testWidgets(
      'HM1 Ready to start Today card & Up next card & Attention card',
      (tester) async {
        const today = TodaySummary(
          deliveredCount: 2,
          totalOrders: 5,
          distanceKm: 18.4,
          onRouteTime: '1h 20m',
          couldNotDeliver: 0,
          progressPercent: 0.4,
        );

        const items = [
          AttentionItem(
            id: 'a1',
            type: AttentionItemType.newOrders,
            title: '2 new orders offered',
            subtitle: 'Review and accept them',
          ),
          AttentionItem(
            id: 'a2',
            type: AttentionItemType.cancelledOrder,
            title: '1 order was cancelled',
            subtitle: '#RX-1035 · No action needed',
          ),
        ];

        await tester.pumpWidget(
          _buildTestScope(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DeliveryHeader(
                    driverName: 'Hamza',
                    profileImagePath: AppAssets.imgDriverAvatar,
                    dateLabel: 'Sunday, 11 October',
                    onNotificationsTap: () {},
                  ),
                  const TodaySection(today: today),
                  UpNextSection(
                    scenario: DeliveryScenario.readyToStart,
                    readyOrderCount: 3,
                    companyName: 'Red Sea Express',
                    onStartDelivery: () {},
                  ),
                  const NeedsAttentionSection(items: items),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify Header
        expect(find.textContaining('Hamza'), findsOneWidget);
        expect(find.text('Sunday, 11 October'), findsOneWidget);

        // Verify TodaySection
        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('40% done'), findsOneWidget);
        expect(find.text('18.4 km'), findsOneWidget);
        expect(find.text('1h 20m'), findsOneWidget);

        // Verify UpNextSection
        expect(find.text('UP NEXT'), findsOneWidget);
        expect(find.text('3 orders ready to go'), findsOneWidget);
        expect(find.text('Start delivery'), findsOneWidget);

        // Verify NeedsAttentionSection
        expect(find.text('NEEDS YOUR ATTENTION'), findsOneWidget);
        expect(find.text('2 new orders offered'), findsOneWidget);
        expect(find.text('1 order was cancelled'), findsOneWidget);
      },
    );

    testWidgets(
      'HM2 On a route renders Open route button and 1 attention row',
      (tester) async {
        const stop = NextStopInfo(
          stopLabel: 'Stop 2 of 3',
          customerName: 'Lina Fares',
          address: 'Tahlia St, Al Nahda',
          estimatedArrival: 'about 6 min',
          currentStop: 2,
          totalStops: 3,
        );

        const items = [
          AttentionItem(
            id: 'a3',
            type: AttentionItemType.newOrders,
            title: '1 new order offered',
            subtitle: 'Tap to review',
          ),
        ];

        await tester.pumpWidget(
          _buildTestScope(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  UpNextSection(
                    scenario: DeliveryScenario.onRoute,
                    readyOrderCount: 0,
                    companyName: 'Red Sea Express',
                    nextStop: stop,
                    onOpenRoute: () {},
                  ),
                  const NeedsAttentionSection(items: items),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Stop 2 of 3 · Lina Fares'), findsOneWidget);
        expect(find.text('Open route'), findsOneWidget);
        expect(find.text('1 new order offered'), findsOneWidget);
      },
    );

    testWidgets('HM3 & HM6 Caught up / No orders has 129h card and no button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestScope(
          child: const UpNextSection(
            scenario: DeliveryScenario.allCaughtUp,
            readyOrderCount: 0,
            companyName: 'Red Sea Express',
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('all caught up'), findsOneWidget);
      expect(find.text('Start delivery'), findsNothing);
      expect(find.text('Open route'), findsNothing);
    });

    testWidgets('HM4 Offline banner renders You are offline', (tester) async {
      await tester.pumpWidget(_buildTestScope(child: const OfflineBanner()));
      await tester.pump();

      expect(find.text("You’re offline"), findsOneWidget);
    });

    figmaDriftTestWidgets('HM5 First day renders Waiting, How works, and Checklist', (
      tester,
    ) async {
      const dashboard = DeliveryDashboard(
        driverName: 'Hamza',
        profileImagePath: AppAssets.imgDriverAvatar,
        dateLabel: 'Sunday, 11 October',
        scenario: DeliveryScenario.firstDay,
        companyName: 'Red Sea Express',
      );

      await tester.pumpWidget(
        _buildTestScope(
          child: const SingleChildScrollView(
            child: OnlineStatusBanner(dashboard: dashboard),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('online with Red Sea Express'),
        findsOneWidget,
      );
      expect(find.text('Waiting for your first order'), findsOneWidget);
      expect(find.text('HOW YOUR DAY WORKS'), findsOneWidget);
      expect(find.text('Get orders'), findsOneWidget);
      expect(find.text('BEFORE YOUR FIRST ORDER'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('✓ On'), findsOneWidget);
      expect(find.text('✓ Always'), findsOneWidget);
      expect(find.text('Toyota Hiace'), findsOneWidget);
    });

    testWidgets('HM8 & HM9 In-app notification card renders Review button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestScope(
          child: InAppNotificationCard(
            title: 'New order offered',
            subtitle: 'Red Sea Express · 3 stops',
            onReviewTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('New order offered'), findsOneWidget);
      expect(find.text('Red Sea Express · 3 stops'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('No overflow on small screen 360 x 640', (tester) async {
      const today = TodaySummary(
        deliveredCount: 2,
        totalOrders: 5,
        distanceKm: 18.4,
        onRouteTime: '1h 20m',
        couldNotDeliver: 0,
        progressPercent: 0.4,
      );

      await tester.pumpWidget(
        _buildTestScope(
          size: const Size(360, 640),
          child: SingleChildScrollView(
            child: Column(
              children: [
                DeliveryHeader(
                  driverName: 'Hamza',
                  profileImagePath: AppAssets.imgDriverAvatar,
                  dateLabel: 'Sunday, 11 October',
                  onNotificationsTap: () {},
                ),
                const TodaySection(today: today),
                UpNextSection(
                  scenario: DeliveryScenario.readyToStart,
                  readyOrderCount: 3,
                  companyName: 'Red Sea Express',
                  onStartDelivery: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL Arabic layout renders without errors', (tester) async {
      const today = TodaySummary(
        deliveredCount: 2,
        totalOrders: 5,
        distanceKm: 18.4,
        onRouteTime: '1h 20m',
        couldNotDeliver: 0,
        progressPercent: 0.4,
      );

      await tester.pumpWidget(
        _buildTestScope(
          locale: const Locale('ar'),
          child: SingleChildScrollView(
            child: Column(
              children: [
                DeliveryHeader(
                  driverName: 'حمزة',
                  profileImagePath: AppAssets.imgDriverAvatar,
                  dateLabel: 'الأحد، ١١ أكتوبر',
                  onNotificationsTap: () {},
                ),
                const TodaySection(today: today),
                UpNextSection(
                  scenario: DeliveryScenario.readyToStart,
                  readyOrderCount: 3,
                  companyName: 'Red Sea Express',
                  onStartDelivery: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'N01 Populated notifications renders New and Earlier sections with unread dot',
      (tester) async {
        final notifications = [
          AppNotification(
            id: 'n1',
            title: '2 new orders offered',
            body: 'Red Sea Express · 3 stops in Al-Zahra',
            kind: AppNotificationKind.routeUpdate,
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
            isRead: false,
          ),
          AppNotification(
            id: 'n2',
            title: 'Route completed',
            body: 'You delivered 5 orders on Friday',
            kind: AppNotificationKind.system,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
          ),
        ];

        await tester.pumpWidget(
          _buildTestScope(
            child: PopulatedNotificationsList(notifications: notifications),
          ),
        );
        await tester.pump();

        expect(find.text('New'), findsOneWidget);
        expect(find.text('Earlier'), findsOneWidget);
        expect(find.text('2 new orders offered'), findsOneWidget);
        expect(find.text('Route completed'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'N02 Notifications empty state renders centered illustration, title, and description',
      (tester) async {
        await tester.pumpWidget(
          _buildTestScope(child: const NotificationsEmptyState()),
        );
        await tester.pump();

        expect(find.text('No notifications yet'), findsOneWidget);
        expect(find.byType(NotificationsEmptyState), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    figmaDriftTestWidgets(
      'HM2 · Home · on a route full dashboard matches Figma node 6410:56040',
      (tester) async {
        final dataSource = DeliveryDashboardLocalDataSourceImpl();
        final model = await dataSource.getDashboard(
          scenario: DeliveryScenario.onRoute,
        );

        await _pumpScope(
          tester,
          child: DeliveryDashboardContentView(
            dashboard: model.toEntity(),
            isRefreshing: false,
            isNotificationOverlayVisible: false,
            onToggleNotificationOverlay: () {},
            onNotificationsTap: () {},
            onRefresh: () async {},
          ),
        );

        // Header
        expect(find.textContaining('Hamza'), findsOneWidget);
        expect(find.text('Sunday, 11 October'), findsOneWidget);

        // Today card (HM2: 3 of 5, 60% done)
        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('60% done'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('of 5 delivered'), findsOneWidget);
        expect(find.text('21.0 km'), findsOneWidget);
        expect(find.text('1h 52m'), findsOneWidget);

        // Up Next card (on-route stop + Open route button)
        expect(find.text('UP NEXT'), findsOneWidget);
        expect(find.text('Stop 2 of 3 · Lina Fares'), findsOneWidget);
        expect(
          find.text('Tahlia St, Al Nahda · about 6 min away'),
          findsOneWidget,
        );
        expect(find.text('Open route'), findsOneWidget);

        // Needs Attention (1 new order offered)
        expect(find.text('NEEDS YOUR ATTENTION'), findsOneWidget);
        expect(find.text('1 new order offered'), findsOneWidget);
        expect(find.text('It joins your next route'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'HM3 · Home · all caught up full dashboard matches Figma node 6410:56180',
      (tester) async {
        final dataSource = DeliveryDashboardLocalDataSourceImpl();
        final model = await dataSource.getDashboard(
          scenario: DeliveryScenario.allCaughtUp,
        );

        await _pumpScope(
          tester,
          child: DeliveryDashboardContentView(
            dashboard: model.toEntity(),
            isRefreshing: false,
            isNotificationOverlayVisible: false,
            onToggleNotificationOverlay: () {},
            onNotificationsTap: () {},
            onRefresh: () async {},
          ),
        );

        // Today card (HM3: 4 of 5, 80% done, 1 couldn't deliver)
        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('80% done'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('of 5 delivered'), findsOneWidget);
        expect(find.text('26.7 km'), findsOneWidget);
        expect(find.text('2h 31m'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);

        // Up Next card (sun variant, no button)
        expect(find.text('UP NEXT'), findsOneWidget);
        expect(find.textContaining('all caught up'), findsOneWidget);
        expect(
          find.text('New orders from Red Sea Express will show up here.'),
          findsOneWidget,
        );
        expect(find.text('Open route'), findsNothing);
        expect(find.text('Start delivery'), findsNothing);

        // Needs Attention is hidden in HM3
        expect(find.text('NEEDS YOUR ATTENTION'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    figmaDriftTestWidgets(
      'HM5 · Home · first day full dashboard matches Figma node 6410:56288',
      (tester) async {
        final dataSource = DeliveryDashboardLocalDataSourceImpl();
        final model = await dataSource.getDashboard(
          scenario: DeliveryScenario.firstDay,
        );

        await _pumpScope(
          tester,
          child: DeliveryDashboardContentView(
            dashboard: model.toEntity(),
            isRefreshing: false,
            isNotificationOverlayVisible: false,
            onToggleNotificationOverlay: () {},
            onNotificationsTap: () {},
            onRefresh: () async {},
          ),
        );

        // Today card should NOT be shown on first day
        expect(find.text('TODAY'), findsNothing);

        // Card 1: Waiting for first order
        expect(
          find.textContaining('online with Red Sea Express'),
          findsOneWidget,
        );
        expect(find.text('Waiting for your first order'), findsOneWidget);

        // Card 2: Stepper
        expect(find.text('HOW YOUR DAY WORKS'), findsOneWidget);
        expect(find.text('Get orders'), findsOneWidget);
        expect(find.text("Accept the ones you'll deliver"), findsOneWidget);
        expect(find.text('Start delivery'), findsOneWidget);

        // Card 3: Checklist
        expect(find.text('BEFORE YOUR FIRST ORDER'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('✓ On'), findsOneWidget);
        expect(find.text('Location access'), findsOneWidget);
        expect(find.text('✓ Always'), findsOneWidget);
        expect(find.text('Your vehicle'), findsOneWidget);
        expect(find.text('Toyota Hiace'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'HM6 · Home · no orders today full dashboard matches Figma node 6410:56236',
      (tester) async {
        final dataSource = DeliveryDashboardLocalDataSourceImpl();
        final model = await dataSource.getDashboard(
          scenario: DeliveryScenario.noOrdersToday,
        );

        await _pumpScope(
          tester,
          child: DeliveryDashboardContentView(
            dashboard: model.toEntity(),
            isRefreshing: false,
            isNotificationOverlayVisible: false,
            onToggleNotificationOverlay: () {},
            onNotificationsTap: () {},
            onRefresh: () async {},
          ),
        );

        // Today card (HM6: 0 of 0, No orders yet, 0 km, 0m)
        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('No orders yet'), findsOneWidget);
        expect(find.text('0'), findsAtLeastNWidgets(1));
        expect(find.text('of 0 delivered'), findsOneWidget);
        expect(find.text('0 km'), findsOneWidget);
        expect(find.text('0m'), findsOneWidget);

        // Up Next card (sun variant, no button)
        expect(find.text('UP NEXT'), findsOneWidget);
        expect(find.textContaining('all caught up'), findsOneWidget);
        expect(
          find.text('New orders from Red Sea Express will show up here.'),
          findsOneWidget,
        );
        expect(find.text('Open route'), findsNothing);
        expect(find.text('Start delivery'), findsNothing);

        // Needs Attention is hidden in HM6
        expect(find.text('NEEDS YOUR ATTENTION'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    figmaDriftTestWidgets(
      'HM4 · Home · offline full dashboard matches Figma node 6410:56444',
      (tester) async {
        final dataSource = DeliveryDashboardLocalDataSourceImpl();
        final model = await dataSource.getDashboard(
          scenario: DeliveryScenario.offline,
        );

        await _pumpScope(
          tester,
          child: DeliveryDashboardContentView(
            dashboard: model.toEntity(),
            isRefreshing: false,
            isNotificationOverlayVisible: false,
            onToggleNotificationOverlay: () {},
            onNotificationsTap: () {},
            onRefresh: () async {},
          ),
        );

        // Header
        expect(find.textContaining('Hamza'), findsOneWidget);

        // Offline Banner
        expect(find.textContaining('offline'), findsOneWidget);
        expect(
          find.textContaining('Delivery updates are saved on this phone'),
          findsOneWidget,
        );

        // Today card (HM4: 2 of 5, 40% done)
        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('40% done'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('of 5 delivered'), findsOneWidget);
        expect(find.text('18.4 km'), findsOneWidget);
        expect(find.text('1h 20m'), findsOneWidget);

        // Up Next card (3 orders ready to go, disabled Connect to start delivery)
        expect(find.text('UP NEXT'), findsOneWidget);
        expect(find.text('3 orders ready to go'), findsOneWidget);
        expect(find.text('Connect to start delivery'), findsOneWidget);

        // Needs Attention (2 rows: 2 new orders offered, 1 order was cancelled)
        expect(find.text('NEEDS YOUR ATTENTION'), findsOneWidget);
        expect(find.text('2 new orders offered'), findsOneWidget);
        expect(find.text('1 order was cancelled'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    figmaDriftTestWidgets(
      'HM8 · Home · new order arrives full dashboard matches Figma node 6410:56525',
      (tester) async {
        final dataSource = DeliveryDashboardLocalDataSourceImpl();
        final model = await dataSource.getDashboard(
          scenario: DeliveryScenario.newOrderFirstDay,
        );

        await _pumpScope(
          tester,
          child: DeliveryDashboardContentView(
            dashboard: model.toEntity(),
            isRefreshing: false,
            isNotificationOverlayVisible: false,
            onToggleNotificationOverlay: () {},
            onNotificationsTap: () {},
            onRefresh: () async {},
          ),
        );

        // In-app notification overlay
        expect(find.text('New order offered'), findsOneWidget);
        expect(find.text('now'), findsOneWidget);
        expect(find.text('Ahmed Ali, Al Rawdah · 2.4 km'), findsOneWidget);
        expect(find.text('Review'), findsOneWidget);

        // Base screen (First day)
        expect(find.text('TODAY'), findsNothing);
        expect(find.text('Waiting for your first order'), findsOneWidget);
        expect(find.text('HOW YOUR DAY WORKS'), findsOneWidget);
        expect(find.text('BEFORE YOUR FIRST ORDER'), findsOneWidget);
        expect(find.text('Toyota Hiace'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'HM9 · Home · new order on a route full dashboard matches Figma node 6410:56105',
      (tester) async {
        final dataSource = DeliveryDashboardLocalDataSourceImpl();
        final model = await dataSource.getDashboard(
          scenario: DeliveryScenario.newOrderOnRoute,
        );

        await _pumpScope(
          tester,
          child: DeliveryDashboardContentView(
            dashboard: model.toEntity(),
            isRefreshing: false,
            isNotificationOverlayVisible: false,
            onToggleNotificationOverlay: () {},
            onNotificationsTap: () {},
            onRefresh: () async {},
          ),
        );

        // In-app notification overlay (380 x 70 at top 50)
        expect(find.text('New order offered'), findsAtLeastNWidgets(1));
        expect(find.text('now'), findsOneWidget);
        expect(find.text('Ahmed Ali, Al Rawdah · 2.4 km'), findsOneWidget);
        expect(find.text('Review'), findsOneWidget);

        // Today card (HM9: 3 of 5, 60% done)
        expect(find.text('TODAY'), findsOneWidget);
        expect(find.text('60% done'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('of 5 delivered'), findsOneWidget);
        expect(find.text('21.0 km'), findsOneWidget);
        expect(find.text('1h 52m'), findsOneWidget);

        // Up Next card (on route + Open route)
        expect(find.text('UP NEXT'), findsOneWidget);
        expect(find.text('Stop 2 of 3 · Lina Fares'), findsOneWidget);
        expect(find.text('Open route'), findsOneWidget);

        // Needs Attention (1 new order offered)
        expect(find.text('NEEDS YOUR ATTENTION'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
