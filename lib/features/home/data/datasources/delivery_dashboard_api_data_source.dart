// lib/features/home/data/datasources/delivery_dashboard_api_data_source.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart';
import 'package:routex_mobile/core/session/driver_identity.dart';
import 'package:routex_mobile/core/config/constants/api_endpoints.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/core/network/api_envelope.dart';
import 'package:routex_mobile/features/home/data/datasources/delivery_dashboard_local_data_source.dart';
import 'package:routex_mobile/features/settings/data/datasources/settings_api_data_source.dart';
import 'package:routex_mobile/features/home/data/models/attention_item_model.dart';
import 'package:routex_mobile/features/home/data/models/delivery_dashboard_model.dart';
import 'package:routex_mobile/features/home/data/models/first_day_check_item_model.dart';
import 'package:routex_mobile/features/home/data/models/first_day_step_model.dart';
import 'package:routex_mobile/features/home/data/models/next_stop_info_model.dart';
import 'package:routex_mobile/features/home/data/models/today_summary_model.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/orders/data/datasources/driver_orders_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/models/driver_order_dto.dart';

/// Builds the Home dashboard from the live API instead of canned scenarios.
///
/// Sources: `GET /auth/me` (name, approved company, vehicle) and
/// `GET /orders/mine` (the day's orders). The scenario is derived from the
/// orders, never stored.
///
/// TODO(backend): distance and driving time for the day, and the ETA of the
/// next stop, are not in `/orders/mine`; they stay at 0 / empty until the
/// backend sends them (docs/pending_backend_hooks.md, item 13).
class DeliveryDashboardApiDataSource implements DeliveryDashboardLocalDataSource {
  DeliveryDashboardApiDataSource({
    required Dio dio,
    required DriverOrdersRemoteDataSource orders,
    DateTime Function()? now,
  }) : _dio = dio,
       _orders = orders,
       _now = now ?? DateTime.now;

  final Dio _dio;
  final DriverOrdersRemoteDataSource _orders;
  final DateTime Function() _now;

  @override
  Future<DeliveryDashboardModel> getDashboard({DeliveryScenario? scenario}) =>
      _build();

  /// Debug-only design review: long-pressing the Home header cycles the
  /// Figma states (HM1 ... HM9) with the real name and photo. Release builds
  /// always return the live dashboard.
  @override
  Future<DeliveryDashboardModel> switchScenario(DeliveryScenario scenario) async {
    if (!kDebugMode) return _build();
    final live = await _build();
    final sample = await DeliveryDashboardLocalDataSourceImpl().switchScenario(
      scenario,
    );
    return DeliveryDashboardModel(
      driverName: live.driverName,
      profileImagePath: live.profileImagePath,
      dateLabel: live.dateLabel,
      scenario: sample.scenario,
      today: sample.today,
      nextStop: sample.nextStop,
      attentionItems: sample.attentionItems,
      firstDayChecklist: sample.firstDayChecklist,
      firstDaySteps: sample.firstDaySteps,
      readyOrderCount: sample.readyOrderCount,
      companyName: live.companyName,
      isOffline: sample.isOffline,
      incomingOrderNotification: sample.incomingOrderNotification,
    );
  }

  Future<DeliveryDashboardModel> _build() async {
    // Both calls start together, and the name/photo lookup is capped: the
    // orders are the point of the screen, so a slow `/auth/me` must not hold
    // the whole Home on its skeleton.
    final whoFuture = _readDriver().timeout(
      const Duration(seconds: 8),
      onTimeout: () => (name: '', company: null, vehicle: null, photo: null),
    );
    final ordersFuture = _loadOrders();
    final who = await whoFuture;
    final all = await ordersFuture;
    return buildDashboard(
      driverName: who.name,
      companyName: who.company,
      vehicle: who.vehicle,
      photo: who.photo,
      orders: all,
      now: _now(),
    );
  }

  Future<List<DriverOrderDto>> _loadOrders() async {
    try {
      return await _orders.getMine();
    } on DioException catch (e) {
      // 403: the account has no approved company yet, so it has no orders.
      if (e.response?.statusCode == 403) return const <DriverOrderDto>[];
      rethrow;
    }
  }

  Future<({String name, String? company, String? vehicle, String? photo})> _readDriver() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.me);
      final data = ApiEnvelope.unwrapData(response.data, path: ApiEndpoints.me);
      final user = data['user'] is Map
          ? Map<String, dynamic>.from(data['user'] as Map)
          : data;
      String? company;
      final memberships = data['memberships'] ?? user['memberships'];
      if (memberships is List) {
        for (final m in memberships.whereType<Map>()) {
          if ('${m['status']}'.toUpperCase() == 'APPROVED') {
            company = m['companyName']?.toString();
          }
        }
      }
      final driver = data['driverProfile'] ?? user['driverProfile'];
      final vehicle = driver is Map ? driver['vehicleType']?.toString() : null;
      final photo = SettingsApiDataSource.profileImageUrl(user);
      DriverIdentity.update(
        name: '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
        photo: photo,
      );
      return (
        name: (user['firstName'] ?? '').toString().trim(),
        company: company,
        vehicle: vehicle,
        photo: photo,
      );
    } on DioException {
      // The orders are the point of this screen; a failed name lookup must
      // not blank it.
      return (name: '', company: null, vehicle: null, photo: null);
    }
  }

  /// Pure mapping from the day's orders to a dashboard snapshot.
  static DeliveryDashboardModel buildDashboard({
    required String driverName,
    required String? companyName,
    required List<DriverOrderDto> orders,
    required DateTime now,
    String? vehicle,
    String? photo,
  }) {
    bool isToday(DateTime? d) {
      if (d == null) return false;
      final l = d.toLocal();
      return l.year == now.year && l.month == now.month && l.day == now.day;
    }

    final delivered = orders
        .where((o) => o.status == 'DELIVERED' && isToday(o.deliveredAt))
        .length;
    final inTransit = orders.where((o) => o.status == 'IN_TRANSIT').toList();
    final assigned = orders.where((o) => o.status == 'ASSIGNED').toList();
    final offers = orders.where((o) => o.isOffer).length;
    final cancelled = orders
        .where((o) => o.status == 'CANCELLED' && isToday(o.createdAt))
        .length;

    final open = inTransit.length + assigned.length;
    final total = delivered + open;

    final attention = <AttentionItemModel>[
      if (offers > 0)
        AttentionItemModel(
          id: 'att_offers',
          type: AttentionItemType.newOrders,
          title: offers == 1 ? '1 new order offered' : '$offers new orders offered',
          subtitle: 'Review and accept them',
        ),
      if (cancelled > 0)
        AttentionItemModel(
          id: 'att_cancelled',
          type: AttentionItemType.cancelledOrder,
          title: cancelled == 1
              ? '1 order was cancelled'
              : '$cancelled orders were cancelled',
          subtitle: 'No action needed',
        ),
    ];

    final summary = TodaySummaryModel(
      deliveredCount: delivered,
      totalOrders: total,
      distanceKm: 0,
      onRouteTime: '0m',
      couldNotDeliver: 0,
      progressPercent: total == 0 ? 0 : delivered / total,
    );

    final name = driverName.isEmpty ? 'Driver' : driverName;
    final date = DateFormat('EEEE, d MMMM').format(now);

    DeliveryDashboardModel make(
      DeliveryScenario scenario, {
      TodaySummaryModel? today,
      NextStopInfoModel? nextStop,
      int readyOrderCount = 0,
      List<FirstDayStepModel> steps = const [],
      List<FirstDayCheckItemModel> checklist = const [],
    }) => DeliveryDashboardModel(
      driverName: name,
      profileImagePath: photo ?? '',
      dateLabel: date,
      scenario: scenario,
      companyName: companyName ?? '',
      today: today,
      nextStop: nextStop,
      readyOrderCount: readyOrderCount,
      attentionItems: attention,
      firstDaySteps: steps,
      firstDayChecklist: checklist,
    );

    if (inTransit.isNotEmpty) {
      final next = inTransit.first;
      return make(
        DeliveryScenario.onRoute,
        today: summary,
        nextStop: NextStopInfoModel(
          stopLabel: 'Stop ${delivered + 1} of $total',
          customerName: next.customerName,
          address: next.address,
          estimatedArrival: '',
          currentStop: delivered + 1,
          totalStops: total,
        ),
      );
    }
    if (assigned.isNotEmpty) {
      return make(
        DeliveryScenario.readyToStart,
        today: summary,
        readyOrderCount: assigned.length,
      );
    }
    if (total > 0) {
      return make(DeliveryScenario.allCaughtUp, today: summary);
    }
    if (orders.isEmpty) {
      return make(
        DeliveryScenario.firstDay,
        steps: const [
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
        checklist: [
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
            status: (vehicle != null && vehicle.isNotEmpty) ? vehicle : 'Not set',
            isComplete: vehicle != null && vehicle.isNotEmpty,
            iconAsset: AppAssets.icVan,
          ),
        ],
      );
    }
    return make(DeliveryScenario.noOrdersToday, today: summary);
  }
}
