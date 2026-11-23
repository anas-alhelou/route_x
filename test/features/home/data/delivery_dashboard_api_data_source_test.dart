import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/home/data/datasources/delivery_dashboard_api_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/orders/data/models/driver_order_dto.dart';

DriverOrderDto order(String id, String status, {DateTime? deliveredAt}) =>
    DriverOrderDto(
      id: id,
      status: status,
      customerName: 'Customer $id',
      address: 'Street $id',
      deliveredAt: deliveredAt,
      createdAt: deliveredAt,
    );

void main() {
  final now = DateTime(2026, 11, 16, 12);

  test('no orders at all is the first-day state', () {
    final d = DeliveryDashboardApiDataSource.buildDashboard(
      driverName: 'Hamza',
      companyName: null,
      orders: const [],
      now: now,
    );
    expect(d.scenario, DeliveryScenario.firstDay);
    expect(d.driverName, 'Hamza');
  });

  test('assigned orders and offers give ready-to-start with attention', () {
    final d = DeliveryDashboardApiDataSource.buildDashboard(
      driverName: 'Hamza',
      companyName: 'Acme',
      orders: [
        order('1', 'ASSIGNED'),
        order('2', 'ASSIGNED'),
        order('3', 'DELIVERED', deliveredAt: now),
        order('4', 'PENDING'),
      ],
      now: now,
    );
    expect(d.scenario, DeliveryScenario.readyToStart);
    expect(d.readyOrderCount, 2);
    expect(d.today!.deliveredCount, 1);
    expect(d.today!.totalOrders, 3);
    expect(d.attentionItems.single.title, '1 new order offered');
  });

  test('an in-transit order is the next stop of an on-route day', () {
    final d = DeliveryDashboardApiDataSource.buildDashboard(
      driverName: 'Hamza',
      companyName: null,
      orders: [
        order('1', 'DELIVERED', deliveredAt: now),
        order('2', 'IN_TRANSIT'),
        order('3', 'ASSIGNED'),
      ],
      now: now,
    );
    expect(d.scenario, DeliveryScenario.onRoute);
    expect(d.nextStop!.stopLabel, 'Stop 2 of 3');
    expect(d.nextStop!.customerName, 'Customer 2');
  });

  test('everything delivered today is all caught up', () {
    final d = DeliveryDashboardApiDataSource.buildDashboard(
      driverName: 'Hamza',
      companyName: null,
      orders: [order('1', 'DELIVERED', deliveredAt: now)],
      now: now,
    );
    expect(d.scenario, DeliveryScenario.allCaughtUp);
  });

  test('only yesterday’s deliveries means no orders today', () {
    final d = DeliveryDashboardApiDataSource.buildDashboard(
      driverName: 'Hamza',
      companyName: null,
      orders: [
        order('1', 'DELIVERED', deliveredAt: now.subtract(const Duration(days: 1))),
      ],
      now: now,
    );
    expect(d.scenario, DeliveryScenario.noOrdersToday);
  });
}
