import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_offer_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_offer_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/usecases/order_offer_usecases.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/order_offers_cubit.dart';

import 'fake_network_info.dart';

/// The offers repository over a mock, with a network the test can flip.
OrderOfferRepositoryImpl offersRepository({
  OrderOfferMockScenario scenario = OrderOfferMockScenario.none,
  FakeNetworkInfo? network,
  Duration delay = Duration.zero,
  DateTime Function()? clock,
}) =>
    OrderOfferRepositoryImpl(
      remote: OrderOfferMockDataSource(
        scenario: scenario,
        delay: delay,
        clock: clock,
      ),
      networkInfo: network ?? FakeNetworkInfo(),
    );

/// An Orders-tab offers cubit with nothing waiting, for tests about
/// everything else on the tab.
OrderOffersCubit noOffersCubit() {
  final repository = offersRepository();
  return OrderOffersCubit(
    getPendingOffersUseCase: GetPendingOffersUseCase(repository),
    undoDeclineOfferUseCase: UndoDeclineOfferUseCase(repository),
  );
}

/// Registers the offer use cases the offer screen resolves from getIt.
void registerOffers(OrderOfferRepositoryImpl repository) {
  unregisterOffers();
  getIt
    ..registerSingleton(GetPendingOffersUseCase(repository))
    ..registerSingleton(AcceptOfferUseCase(repository))
    ..registerSingleton(DeclineOfferUseCase(repository))
    ..registerSingleton(UndoDeclineOfferUseCase(repository));
}

void unregisterOffers() {
  if (getIt.isRegistered<GetPendingOffersUseCase>()) {
    getIt.unregister<GetPendingOffersUseCase>();
  }
  if (getIt.isRegistered<AcceptOfferUseCase>()) {
    getIt.unregister<AcceptOfferUseCase>();
  }
  if (getIt.isRegistered<DeclineOfferUseCase>()) {
    getIt.unregister<DeclineOfferUseCase>();
  }
  if (getIt.isRegistered<UndoDeclineOfferUseCase>()) {
    getIt.unregister<UndoDeclineOfferUseCase>();
  }
}
