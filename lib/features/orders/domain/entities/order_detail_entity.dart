// lib/features/orders/domain/entities/order_detail_entity.dart
import 'package:equatable/equatable.dart';

/// What the driver has to collect at the door, beyond handing the parcel
/// over. Each one becomes a chip on the packages card.
enum DeliveryRequirement { signature, photo }

/// Everything the detail screen needs about one stop that the Today list
/// does not already carry.
///
/// The list's [TodayStopEntity] still supplies the name, route number and
/// status, so the header can paint before this arrives.
class OrderDetailEntity extends Equatable {
  const OrderDetailEntity({
    required this.id,
    required this.orderCode,
    required this.totalStops,
    required this.customerPhone,
    required this.addressLine,
    required this.addressDetails,
    required this.gateCode,
    required this.eta,
    required this.isOnTime,
    required this.packagesCount,
    required this.scannedCount,
    required this.requirements,
    required this.dispatchNote,
    required this.latitude,
    required this.longitude,
    this.minutesAway,
  });

  final String id;

  /// The human-facing reference printed on the label, e.g. `RX-1041`.
  /// Without the leading `#` — that is presentation.
  final String orderCode;

  /// Stops on today's route in total, delivered ones included, so the
  /// header can say "Stop 4 of 5".
  final int totalStops;

  final String customerPhone;

  /// Street and district, e.g. `Prince Sultan St 22, Al Rawdah`.
  final String addressLine;

  /// Building, floor and flat, e.g. `Building 7, 3rd floor, flat 12`.
  /// Empty when the customer gave none.
  final String addressDetails;

  /// Null when the building has no gate — the badge is hidden then, not
  /// shown empty.
  final String? gateCode;

  /// Projected arrival time, e.g. `12:25`.
  final String eta;

  /// Whether [eta] falls inside the promised window.
  final bool isOnTime;

  final int packagesCount;
  final int scannedCount;
  final List<DeliveryRequirement> requirements;

  /// Free text from dispatch. Null hides the card.
  final String? dispatchNote;

  final double latitude;
  final double longitude;

  /// Driving time from the driver's position, e.g. `6`. Only known — and
  /// only meaningful — for the stop being driven to; null for the rest.
  final int? minutesAway;

  @override
  List<Object?> get props => [
        id,
        orderCode,
        totalStops,
        customerPhone,
        addressLine,
        addressDetails,
        gateCode,
        eta,
        isOnTime,
        packagesCount,
        scannedCount,
        requirements,
        dispatchNote,
        latitude,
        longitude,
        minutesAway,
      ];
}
