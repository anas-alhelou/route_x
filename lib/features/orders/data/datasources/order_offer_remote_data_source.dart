// lib/features/orders/data/datasources/order_offer_remote_data_source.dart
import '../../domain/entities/order_offer_entity.dart';
import '../../domain/entities/order_offer_failures.dart';

/// Offers a fleet sends the driver, and the driver's answers to them.
abstract class OrderOfferRemoteDataSource {
  Future<List<OrderOfferEntity>> getPendingOffers();
  Future<AcceptedOfferEntity> accept(String offerId, List<String> orderIds);
  Future<void> decline(String offerId, OfferDeclineReason? reason);
  Future<void> undoDecline(String offerId);
}

/// Which offers the mock serves.
enum OrderOfferMockScenario {
  /// Three orders for tomorrow, offered together — the Figma group offer.
  group,

  /// One order — the Figma single offer.
  single,

  /// Nothing waiting.
  none,

  /// The fleet takes the offer back as the driver accepts.
  takenBack,
}

/// Stand-in for the offers API. Keeps its own list, so declining removes an
/// offer and Undo brings it back, as the server would.
class OrderOfferMockDataSource implements OrderOfferRemoteDataSource {
  OrderOfferMockDataSource({
    this.scenario = OrderOfferMockScenario.group,
    this.delay = const Duration(milliseconds: 600),
    this.answerWindow = const Duration(minutes: 10),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final OrderOfferMockScenario scenario;
  final Duration delay;
  final Duration answerWindow;
  final DateTime Function() _now;

  List<OrderOfferEntity>? _pending;
  final Map<String, OrderOfferEntity> _declined = {};

  static const String _fleet = 'Red Sea Express';
  static const String _note = 'Customer asked you to call when you arrive.';

  /// Tomorrow already holds four stops; the route ends at 12:58 over 24 km.
  static const int _routeStops = 4;
  static const double _routeKm = 24.0;
  static const int _routeEndMinutes = 12 * 60 + 58;

  static const OfferOrderEntity _ahmed = OfferOrderEntity(
    id: 'RX-1052',
    customerName: 'Ahmed Ali',
    orderCode: 'RX-1052',
    area: 'Al Rawdah',
    addressLine: 'Prince Sultan St 22, Al Rawdah',
    addressDetails: 'Building 7, 3rd floor, flat 12',
    timeWindow: '09:00 – 11:00',
    distanceKm: '+2.4 km',
    addedMinutes: 12,
    packagesCount: 2,
    instructions: 'Signature needed at the door',
    deliveryDateLabel: 'Tomorrow, Mon 12 Oct',
    routePosition: 3,
  );

  static const List<OfferOrderEntity> _group = [
    _ahmed,
    OfferOrderEntity(
      id: 'RX-1053',
      customerName: 'Lina Fares',
      orderCode: 'RX-1053',
      area: 'Al Nahda',
      addressLine: 'Tahlia St 4, Al Nahda',
      timeWindow: '11:00 – 13:00',
      distanceKm: '+1.9 km',
      addedMinutes: 10,
      packagesCount: 1,
      deliveryDateLabel: 'Tomorrow, Mon 12 Oct',
      routePosition: 4,
    ),
    OfferOrderEntity(
      id: 'RX-1054',
      customerName: 'Omar Haddad',
      orderCode: 'RX-1054',
      area: 'Al Zahra',
      addressLine: 'Sari St 9, Al Zahra',
      timeWindow: '13:00 – 15:00',
      distanceKm: '+2.5 km',
      addedMinutes: 14,
      packagesCount: 3,
      deliveryDateLabel: 'Tomorrow, Mon 12 Oct',
      routePosition: 5,
    ),
  ];

  List<OrderOfferEntity> _seed() {
    final expiresAt = _now().add(answerWindow);
    OrderOfferEntity offer(String id, List<OfferOrderEntity> orders) =>
        OrderOfferEntity(
          id: id,
          fleetName: _fleet,
          deadlineLabel: '',
          stopsCount: orders.length,
          distanceLabel: '',
          timeLabel: '',
          orders: orders,
          note: orders.length == 1 ? _note : null,
          expiresAt: expiresAt,
          answerWindow: answerWindow,
        );

    return switch (scenario) {
      OrderOfferMockScenario.none => [],
      OrderOfferMockScenario.group => [offer('offer-group', _group)],
      OrderOfferMockScenario.single ||
      OrderOfferMockScenario.takenBack =>
        [offer('offer-single', const [_ahmed])],
    };
  }

  List<OrderOfferEntity> get _offers => _pending ??= _seed();

  @override
  Future<List<OrderOfferEntity>> getPendingOffers() async {
    await Future<void>.delayed(delay);
    return List.unmodifiable(_offers);
  }

  @override
  Future<AcceptedOfferEntity> accept(
    String offerId,
    List<String> orderIds,
  ) async {
    await Future<void>.delayed(delay);
    final offer = _offers.firstWhere((o) => o.id == offerId);
    if (scenario == OrderOfferMockScenario.takenBack) {
      _offers.remove(offer);
      throw const OfferTakenBackFailure();
    }
    final expiresAt = offer.expiresAt;
    if (expiresAt != null && !_now().isBefore(expiresAt)) {
      _offers.remove(offer);
      throw const OfferExpiredFailure();
    }
    _offers.remove(offer);

    final taken = offer.orders.where((o) => orderIds.contains(o.id)).toList();
    final km = taken.fold<double>(0, (sum, o) => sum + o.addedKm);
    final minutes = taken.fold<int>(0, (sum, o) => sum + (o.addedMinutes ?? 0));
    final end = _routeEndMinutes + minutes;

    return AcceptedOfferEntity(
      acceptedCount: taken.length,
      firstStopNumber: _routeStops,
      totalStops: _routeStops + taken.length,
      distanceKm: double.parse((_routeKm + km).toStringAsFixed(1)),
      doneBy: '${end ~/ 60}:${(end % 60).toString().padLeft(2, '0')}',
      customerName: taken.length == 1 ? taken.single.customerName : null,
    );
  }

  @override
  Future<void> decline(String offerId, OfferDeclineReason? reason) async {
    await Future<void>.delayed(delay);
    final offer = _offers.firstWhere((o) => o.id == offerId);
    _offers.remove(offer);
    _declined[offerId] = offer;
  }

  @override
  Future<void> undoDecline(String offerId) async {
    await Future<void>.delayed(delay);
    final offer = _declined.remove(offerId);
    if (offer == null) return;
    final expiresAt = offer.expiresAt;
    if (expiresAt != null && !_now().isBefore(expiresAt)) {
      throw const OfferExpiredFailure();
    }
    _offers.add(offer);
  }
}
