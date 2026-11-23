// lib/features/orders/domain/entities/order_offer_failures.dart
import 'package:routex_mobile/core/errors/failures.dart';

/// The fleet withdrew the offer before the driver answered.
class OfferTakenBackFailure extends Failure {
  const OfferTakenBackFailure() : super('errOfferTakenBack');
}

/// The answer arrived after the offer ran out.
class OfferExpiredFailure extends Failure {
  const OfferExpiredFailure() : super('errOfferExpired');
}
