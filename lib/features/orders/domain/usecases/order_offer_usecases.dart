// lib/features/orders/domain/usecases/order_offer_usecases.dart
import '../entities/order_offer_entity.dart';
import '../repositories/order_offer_repository.dart';

class GetPendingOffersUseCase {
  const GetPendingOffersUseCase(this._repository);
  final OrderOfferRepository _repository;

  Future<List<OrderOfferEntity>> call() => _repository.getPendingOffers();
}

class AcceptOfferUseCase {
  const AcceptOfferUseCase(this._repository);
  final OrderOfferRepository _repository;

  Future<AcceptedOfferEntity> call(String offerId, List<String> orderIds) =>
      _repository.accept(offerId, orderIds);
}

class DeclineOfferUseCase {
  const DeclineOfferUseCase(this._repository);
  final OrderOfferRepository _repository;

  Future<void> call(String offerId, OfferDeclineReason? reason) =>
      _repository.decline(offerId, reason);
}

class UndoDeclineOfferUseCase {
  const UndoDeclineOfferUseCase(this._repository);
  final OrderOfferRepository _repository;

  Future<void> call(String offerId) => _repository.undoDecline(offerId);
}
