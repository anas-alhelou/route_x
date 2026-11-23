// lib/features/orders/data/repositories/order_offer_repository_impl.dart
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/network_info.dart';

import '../../domain/entities/order_offer_entity.dart';
import '../../domain/repositories/order_offer_repository.dart';
import '../datasources/order_offer_remote_data_source.dart';

class OrderOfferRepositoryImpl implements OrderOfferRepository {
  const OrderOfferRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final OrderOfferRemoteDataSource remote;
  final NetworkInfo networkInfo;

  /// An answer has to reach the fleet to count. With no link at all, say
  /// so at once — the offer stays open while its timer runs.
  Future<void> _online() async {
    if (!await networkInfo.isConnected) throw const NetworkFailure();
  }

  @override
  Future<List<OrderOfferEntity>> getPendingOffers() async {
    await _online();
    final offers = await remote.getPendingOffers();
    final sorted = [...offers]..sort((a, b) {
        final ea = a.expiresAt, eb = b.expiresAt;
        if (ea == null || eb == null) return 0;
        return ea.compareTo(eb);
      });
    return sorted;
  }

  @override
  Future<AcceptedOfferEntity> accept(
    String offerId,
    List<String> orderIds,
  ) async {
    await _online();
    return remote.accept(offerId, orderIds);
  }

  @override
  Future<void> decline(String offerId, OfferDeclineReason? reason) async {
    await _online();
    return remote.decline(offerId, reason);
  }

  @override
  Future<void> undoDecline(String offerId) async {
    await _online();
    return remote.undoDecline(offerId);
  }
}
