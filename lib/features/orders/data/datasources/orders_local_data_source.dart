// lib/features/orders/data/datasources/orders_local_data_source.dart
import '../models/order_model.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatusType newStatus);
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  OrdersLocalDataSourceImpl();

  final List<OrderModel> _orders = const [
    OrderModel(
      id: 'ORD-9821',
      customerName: 'Mohammed Al-Qahtani',
      customerPhone: '+966 50 123 4567',
      deliveryAddress: 'Villa 14, Al Nakheel District, Riyadh',
      items: ['Express Package (Fragile)', 'Documents Envelope'],
      totalAmount: 185.00,
      status: OrderStatusType.enRoute,
      tabType: OrderTabType.active,
      eta: '10:45 AM',
    ),
    OrderModel(
      id: 'ORD-9822',
      customerName: 'Sarah Al-Ahmari',
      customerPhone: '+966 55 987 6543',
      deliveryAddress: 'Tower B, King Abdullah Financial District',
      items: ['Electronics & Accessories'],
      totalAmount: 420.50,
      status: OrderStatusType.pending,
      tabType: OrderTabType.active,
      eta: '11:30 AM',
    ),
    OrderModel(
      id: 'ORD-9710',
      customerName: 'Fahad Al-Harbi',
      customerPhone: '+966 56 444 3322',
      deliveryAddress: 'Street 8, Industrial Area, Riyadh',
      items: ['Industrial Spare Parts'],
      totalAmount: 1250.00,
      status: OrderStatusType.delivered,
      tabType: OrderTabType.past,
      eta: 'Yesterday',
    ),
    OrderModel(
      id: 'ORD-9905',
      customerName: 'Noura Al-Subaie',
      customerPhone: '+966 53 111 2233',
      deliveryAddress: 'Apartment 302, Al Malaz, Riyadh',
      items: ['Organic Groceries Box'],
      totalAmount: 95.00,
      status: OrderStatusType.scheduled,
      tabType: OrderTabType.scheduled,
      eta: 'Tomorrow, 02:00 PM',
    ),
  ];

  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders;
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatusType newStatus) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      final updated = OrderModel(
        id: old.id,
        customerName: old.customerName,
        customerPhone: old.customerPhone,
        deliveryAddress: old.deliveryAddress,
        items: old.items,
        totalAmount: old.totalAmount,
        status: newStatus,
        tabType: newStatus == OrderStatusType.delivered ? OrderTabType.past : old.tabType,
        eta: old.eta,
      );
      _orders[index] = updated;
      return updated;
    }
    throw Exception('Order not found');
  }
}
