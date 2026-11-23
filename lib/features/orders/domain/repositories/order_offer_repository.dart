// lib/features/orders/domain/repositories/order_offer_repository.dart
import '../entities/order_offer_entity.dart';

abstract class OrderOfferRepository {
  /// Offers still waiting for an answer, soonest to expire first.
  Future<List<OrderOfferEntity>> getPendingOffers();

  /// Accepts [orderIds] of the offer; any order left out is declined. Throws
  /// a `NetworkFailure` offline, and `OfferTakenBackFailure` or
  /// `OfferExpiredFailure` when the offer is gone.
  Future<AcceptedOfferEntity> accept(String offerId, List<String> orderIds);

  /// Declines the whole offer. [reason] is null for "Decline all" in a
  /// group, where no reason is asked.
  Future<void> decline(String offerId, OfferDeclineReason? reason);

  /// Takes a decline back while the offer has not run out.
  Future<void> undoDecline(String offerId);
}
