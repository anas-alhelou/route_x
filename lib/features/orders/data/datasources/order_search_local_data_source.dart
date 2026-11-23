// lib/features/orders/data/datasources/order_search_local_data_source.dart
import '../../domain/entities/order_search_result_entity.dart';
import '../../domain/entities/orders_today_entity.dart';
import '../models/orders_today_model.dart';

abstract class OrderSearchLocalDataSource {
  Future<List<OrderSearchResultEntity>> search(
    String query,
    OrderSearchScope scope,
  );
}

/// One order the mock can find, with the fields it is matched on.
class _Searchable {
  const _Searchable({
    required this.result,
    required this.address,
    required this.phone,
  });

  final OrderSearchResultEntity result;

  /// Full street address — matched even where the row only shows the
  /// district.
  final String address;

  final String phone;
}

/// Stand-in for `GET /orders/search` until dispatch ships it.
///
/// Matching lives here, not in the use case, because it is the server's job
/// once the API exists: the app should send the query and trust the answer.
class OrderSearchLocalDataSourceImpl implements OrderSearchLocalDataSource {
  const OrderSearchLocalDataSourceImpl();

  static const List<_Searchable> _orders = [
    // ── Today ──────────────────────────────────────────────────────────
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10031',
        customerName: 'Lina Fares',
        orderCode: 'RX-1040',
        areaLabel: 'Tahlia St, Al Nahda',
        todayStop: TodayStopModel(
          id: 'ORD-10031',
          sequence: 3,
          customerName: 'Lina Fares',
          area: 'Tahlia St, Al Nahda',
          timeWindow: '10:00 — 12:00',
          status: TodayStopStatus.onTheWay,
        ),
      ),
      address: 'Tahlia St 8, Al Nahda',
      phone: '+966501112233',
    ),
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10032',
        customerName: 'Ahmed Ali',
        orderCode: 'RX-1041',
        areaLabel: 'Prince Sultan St, Al Rawdah',
        todayStop: TodayStopModel(
          id: 'ORD-10032',
          sequence: 4,
          customerName: 'Ahmed Ali',
          area: 'Prince Sultan St, Al Rawdah',
          timeWindow: '12:00 — 14:00',
          status: TodayStopStatus.upNext,
        ),
      ),
      address: 'Prince Sultan St 22, Al Rawdah',
      phone: '+966502223344',
    ),
    // ── Tomorrow ───────────────────────────────────────────────────────
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10052',
        customerName: 'Ahmed Ali',
        orderCode: 'RX-1052',
        areaLabel: 'Al Rawdah',
        dayLabel: 'Tomorrow',
        isNew: true,
      ),
      address: 'Prince Sultan St 22, Al Rawdah',
      phone: '+966502223344',
    ),
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10053',
        customerName: 'Huda Saad',
        orderCode: 'RX-1053',
        areaLabel: 'Al Zahra',
        dayLabel: 'Tomorrow',
        isNew: true,
      ),
      address: 'Al Ahsa St 5, Al Zahra',
      phone: '+966504445566',
    ),
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10054',
        customerName: 'Omar Nasser',
        orderCode: 'RX-1054',
        areaLabel: 'Al Rawdah',
        dayLabel: 'Tomorrow',
      ),
      address: 'Khalid Bin Al Walid St 40, Al Rawdah',
      phone: '+966505556677',
    ),
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10055',
        customerName: 'Reem Khalid',
        orderCode: 'RX-1055',
        areaLabel: 'Al Zahra',
        dayLabel: 'Tomorrow',
      ),
      address: 'Al Zahra St 11, Al Zahra',
      phone: '+966506667788',
    ),
    // ── Tue 13 Oct ─────────────────────────────────────────────────────
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10058',
        customerName: 'Ahmed Saleh',
        orderCode: 'RX-1058',
        areaLabel: 'Al Nahda',
        dayLabel: 'Tue 13 Oct',
      ),
      address: 'Al Nahda St 17, Al Nahda',
      phone: '+966507778899',
    ),
    _Searchable(
      result: OrderSearchResultEntity(
        id: 'ORD-10059',
        customerName: 'Faisal Omar',
        orderCode: 'RX-1059',
        areaLabel: 'Al Nahda',
        dayLabel: 'Tue 13 Oct',
      ),
      address: 'Tahlia St 30, Al Nahda',
      phone: '+966508889900',
    ),
  ];

  @override
  Future<List<OrderSearchResultEntity>> search(
    String query,
    OrderSearchScope scope,
  ) async {
    final needle = query.trim().toLowerCase().replaceFirst('#', '');
    if (needle.isEmpty) return const [];

    return [
      for (final order in _orders)
        if (_inScope(order.result, scope) && _matches(order, needle))
          order.result,
    ];
  }

  static bool _inScope(OrderSearchResultEntity result, OrderSearchScope scope) {
    return switch (scope) {
      OrderSearchScope.all => true,
      OrderSearchScope.today => result.isToday,
      OrderSearchScope.upcoming => !result.isToday,
    };
  }

  static bool _matches(_Searchable order, String needle) {
    final result = order.result;
    if (result.customerName.toLowerCase().contains(needle)) return true;
    if (order.address.toLowerCase().contains(needle)) return true;
    if (result.orderCode.toLowerCase().contains(needle)) return true;

    // Exactly four digits is how a driver reads a number off a missed call
    // or a label: match it against the end of the phone, not anywhere in it.
    final isLastFour = needle.length == 4 && int.tryParse(needle) != null;
    if (isLastFour && order.phone.endsWith(needle)) return true;

    return false;
  }
}
