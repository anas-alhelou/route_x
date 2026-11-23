// lib/features/home/data/datasources/delivery_dashboard_local_data_source.dart
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/features/home/data/models/attention_item_model.dart';
import 'package:routex_mobile/features/home/data/models/delivery_dashboard_model.dart';
import 'package:routex_mobile/features/home/data/models/first_day_check_item_model.dart';
import 'package:routex_mobile/features/home/data/models/first_day_step_model.dart';
import 'package:routex_mobile/features/home/data/models/incoming_order_notification_model.dart';
import 'package:routex_mobile/features/home/data/models/next_stop_info_model.dart';
import 'package:routex_mobile/features/home/data/models/today_summary_model.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';

abstract class DeliveryDashboardLocalDataSource {
  Future<DeliveryDashboardModel> getDashboard({DeliveryScenario? scenario});
  Future<DeliveryDashboardModel> switchScenario(DeliveryScenario scenario);
}

class DeliveryDashboardLocalDataSourceImpl
    implements DeliveryDashboardLocalDataSource {
  DeliveryScenario _activeScenario = DeliveryScenario.onRoute;

  @override
  Future<DeliveryDashboardModel> getDashboard({
    DeliveryScenario? scenario,
  }) async {
    final target = scenario ?? _activeScenario;
    _activeScenario = target;
    return _buildMock(target);
  }

  @override
  Future<DeliveryDashboardModel> switchScenario(
    DeliveryScenario scenario,
  ) async {
    _activeScenario = scenario;
    return _buildMock(scenario);
  }

  DeliveryDashboardModel _buildMock(DeliveryScenario scenario) {
    const defaultDriver = 'Anas';
    const defaultDate = 'Monday, 11 October';
    const defaultAvatar = AppAssets.imgDriverAvatar;
    const defaultCompany = 'Red Sea Express';

    switch (scenario) {
      // ── HM2 · Home · on a route (Figma Node 6410:56040) ────────────────────
      case DeliveryScenario.onRoute:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.onRoute,
          companyName: defaultCompany,
          today: TodaySummaryModel(
            deliveredCount: 3,
            totalOrders: 5,
            distanceKm: 21.0,
            onRouteTime: '1h 52m',
            couldNotDeliver: 0,
            progressPercent: 0.60,
          ),
          nextStop: NextStopInfoModel(
            stopLabel: 'Stop 2 of 3',
            customerName: 'Lina Fares',
            address: 'Tahlia St, Al Nahda',
            estimatedArrival: 'about 6 min away',
            currentStop: 2,
            totalStops: 3,
          ),
          attentionItems: [
            AttentionItemModel(
              id: 'att_hm2_1',
              type: AttentionItemType.newOrders,
              title: '1 new order offered',
              subtitle: 'It joins your next route',
            ),
          ],
        );

      // ── HM3 · Home · all caught up (Figma Node 6410:56180) ─────────────────
      case DeliveryScenario.allCaughtUp:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.allCaughtUp,
          companyName: defaultCompany,
          today: TodaySummaryModel(
            deliveredCount: 4,
            totalOrders: 5,
            distanceKm: 26.7,
            onRouteTime: '2h 31m',
            couldNotDeliver: 1,
            progressPercent: 0.80,
          ),
          nextStop: null,
          attentionItems: [],
        );

      // ── HM5 · Home · first day (Figma Node 6410:56288) ─────────────────────
      case DeliveryScenario.firstDay:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.firstDay,
          companyName: defaultCompany,
          today: null,
          nextStop: null,
          attentionItems: [],
          firstDaySteps: [
            FirstDayStepModel(
              stepNumber: 1,
              title: 'Get orders',
              description: 'New orders show up in the Orders tab.',
            ),
            FirstDayStepModel(
              stepNumber: 2,
              title: "Accept the ones you'll deliver",
              description: 'Accepted orders join your next route.',
            ),
            FirstDayStepModel(
              stepNumber: 3,
              title: 'Start delivery',
              description: 'We plan the route and guide each stop.',
            ),
          ],
          firstDayChecklist: [
            FirstDayCheckItemModel(
              id: 'chk_1',
              title: 'Notifications',
              status: '✓ On',
              isComplete: true,
              iconAsset: AppAssets.icBell,
            ),
            FirstDayCheckItemModel(
              id: 'chk_2',
              title: 'Location access',
              status: '✓ Always',
              isComplete: true,
              iconAsset: AppAssets.icPin,
            ),
            FirstDayCheckItemModel(
              id: 'chk_3',
              title: 'Your vehicle',
              status: 'Toyota Hiace',
              isComplete: true,
              iconAsset: AppAssets.icVan,
            ),
          ],
        );

      // ── HM6 · Home · no orders today (Figma Node 6410:56236) ────────────────
      case DeliveryScenario.noOrdersToday:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.noOrdersToday,
          companyName: defaultCompany,
          today: TodaySummaryModel(
            deliveredCount: 0,
            totalOrders: 0,
            distanceKm: 0.0,
            onRouteTime: '0m',
            couldNotDeliver: 0,
            progressPercent: 0.0,
          ),
          nextStop: null,
          attentionItems: [],
        );

      // ── HM1 · Ready to start (auxiliary state) ──────────────────────────────
      case DeliveryScenario.readyToStart:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.readyToStart,
          companyName: defaultCompany,
          readyOrderCount: 3,
          today: TodaySummaryModel(
            deliveredCount: 2,
            totalOrders: 5,
            distanceKm: 18.4,
            onRouteTime: '1h 20m',
            couldNotDeliver: 0,
            progressPercent: 0.40,
          ),
          attentionItems: [
            AttentionItemModel(
              id: 'att_hm1_1',
              type: AttentionItemType.newOrders,
              title: '2 new orders offered',
              subtitle: 'Review and accept them',
            ),
            AttentionItemModel(
              id: 'att_hm1_2',
              type: AttentionItemType.cancelledOrder,
              title: '1 order was cancelled',
              subtitle: '#RX-1035 · No action needed',
            ),
          ],
        );

      // ── HM4 · Offline state (Figma Node 6410:56444) ─────────────────────────
      case DeliveryScenario.offline:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.offline,
          isOffline: true,
          companyName: defaultCompany,
          readyOrderCount: 3,
          today: TodaySummaryModel(
            deliveredCount: 2,
            totalOrders: 5,
            distanceKm: 18.4,
            onRouteTime: '1h 20m',
            couldNotDeliver: 0,
            progressPercent: 0.40,
          ),
          attentionItems: [
            AttentionItemModel(
              id: 'att_hm4_1',
              type: AttentionItemType.newOrders,
              title: '2 new orders offered',
              subtitle: 'Review and accept them',
            ),
            AttentionItemModel(
              id: 'att_hm4_2',
              type: AttentionItemType.cancelledOrder,
              title: '1 order was cancelled',
              subtitle: '#RX-1035 · No action needed',
            ),
          ],
        );

      // ── HM8 · New order arrives on first day (Figma Node 6410:56525) ────────
      case DeliveryScenario.newOrderFirstDay:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.newOrderFirstDay,
          companyName: defaultCompany,
          today: null,
          nextStop: null,
          attentionItems: [],
          incomingOrderNotification: IncomingOrderNotificationModel(
            id: 'inc_hm8_1',
            title: 'New order offered',
            timeAgo: 'now',
            subtitle: 'Ahmed Ali, Al Rawdah · 2.4 km',
          ),
          firstDaySteps: [
            FirstDayStepModel(
              stepNumber: 1,
              title: 'Get orders',
              description: 'New orders show up in the Orders tab.',
            ),
            FirstDayStepModel(
              stepNumber: 2,
              title: "Accept the ones you'll deliver",
              description: 'Accepted orders join your next route.',
            ),
            FirstDayStepModel(
              stepNumber: 3,
              title: 'Start delivery',
              description: 'We plan the route and guide each stop.',
            ),
          ],
          firstDayChecklist: [
            FirstDayCheckItemModel(
              id: 'chk_1',
              title: 'Notifications',
              status: '✓ On',
              isComplete: true,
              iconAsset: AppAssets.icBell,
            ),
            FirstDayCheckItemModel(
              id: 'chk_2',
              title: 'Location access',
              status: '✓ Always',
              isComplete: true,
              iconAsset: AppAssets.icPin,
            ),
            FirstDayCheckItemModel(
              id: 'chk_3',
              title: 'Your vehicle',
              status: 'Toyota Hiace',
              isComplete: true,
              iconAsset: AppAssets.icVan,
            ),
          ],
        );

      // ── HM9 · New order on a route (Figma Node 6410:56105) ──────────────────
      case DeliveryScenario.newOrderOnRoute:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.newOrderOnRoute,
          companyName: defaultCompany,
          today: TodaySummaryModel(
            deliveredCount: 3,
            totalOrders: 5,
            distanceKm: 21.0,
            onRouteTime: '1h 52m',
            couldNotDeliver: 0,
            progressPercent: 0.60,
          ),
          nextStop: NextStopInfoModel(
            stopLabel: 'Stop 2 of 3',
            customerName: 'Lina Fares',
            address: 'Tahlia St, Al Nahda',
            estimatedArrival: 'about 6 min away',
            currentStop: 2,
            totalStops: 3,
          ),
          attentionItems: [
            AttentionItemModel(
              id: 'att_hm9_1',
              type: AttentionItemType.newOrders,
              title: '1 new order offered',
              subtitle: 'It joins your next route',
            ),
          ],
          incomingOrderNotification: IncomingOrderNotificationModel(
            id: 'inc_hm9_1',
            title: 'New order offered',
            timeAgo: 'now',
            subtitle: 'Ahmed Ali, Al Rawdah · 2.4 km',
          ),
        );

      // ── HM0 Loading skeleton ───────────────────────────────────────────────
      case DeliveryScenario.loading:
        return const DeliveryDashboardModel(
          driverName: defaultDriver,
          profileImagePath: defaultAvatar,
          dateLabel: defaultDate,
          scenario: DeliveryScenario.loading,
        );
    }
  }
}
