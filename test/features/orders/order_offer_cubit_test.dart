import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_offer_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_offer_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';
import 'package:routex_mobile/features/orders/domain/usecases/order_offer_usecases.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/order_offer_cubit.dart';

import 'fake_network_info.dart';
import 'offers_test_support.dart';

void main() {
  late DateTime now;
  late FakeNetworkInfo network;

  setUp(() {
    now = DateTime(2025, 10, 11, 9, 0);
    network = FakeNetworkInfo();
  });

  Future<(OrderOfferCubit, OrderOfferEntity)> cubitFor(
    OrderOfferMockScenario scenario, {
    Duration answerWindow = const Duration(minutes: 10),
  }) async {
    // The real repository, over a mock that shares the test clock.
    final repository = OrderOfferRepositoryImpl(
      remote: OrderOfferMockDataSource(
        scenario: scenario,
        delay: Duration.zero,
        answerWindow: answerWindow,
        clock: () => now,
      ),
      networkInfo: network,
    );
    final offer = (await repository.getPendingOffers()).single;
    final cubit = OrderOfferCubit(
      offer: offer,
      acceptOfferUseCase: AcceptOfferUseCase(repository),
      declineOfferUseCase: DeclineOfferUseCase(repository),
      clock: () => now,
      tick: const Duration(milliseconds: 5),
    );
    addTearDown(cubit.close);
    return (cubit, offer);
  }

  test('counts down from the deadline', () async {
    final (cubit, _) = await cubitFor(OrderOfferMockScenario.single);
    expect(cubit.state.remaining, const Duration(minutes: 10));

    now = now.add(const Duration(seconds: 18));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state.remaining, const Duration(minutes: 9, seconds: 42));
    expect(cubit.state.status, OrderOfferStatus.open);
  });

  test('expires when the deadline passes, and stops answering', () async {
    final (cubit, _) = await cubitFor(OrderOfferMockScenario.single);

    now = now.add(const Duration(minutes: 10));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state.status, OrderOfferStatus.expired);
    expect(cubit.state.remaining, Duration.zero);

    await cubit.accept();
    expect(cubit.state.status, OrderOfferStatus.expired);
  });

  test('an answer the server finds late comes back expired', () async {
    final (cubit, _) = await cubitFor(OrderOfferMockScenario.single);
    // The server's clock is past the deadline; the screen's timer has not
    // ticked yet.
    now = now.add(const Duration(minutes: 11));
    await cubit.accept();
    expect(cubit.state.status, OrderOfferStatus.expired);
  });

  test('offline keeps the offer open with the error, retry sends it',
      () async {
    final (cubit, _) = await cubitFor(OrderOfferMockScenario.single);
    network.setSilently(false);

    await cubit.accept();
    expect(cubit.state.status, OrderOfferStatus.open);
    expect(cubit.state.error, OrderOfferError.acceptOffline);

    network.setSilently(true);
    await cubit.retry();
    expect(cubit.state.status, OrderOfferStatus.accepted);
    expect(cubit.state.result?.customerName, 'Ahmed Ali');
  });

  test('a decline that fails offline is retried as a decline', () async {
    final (cubit, _) = await cubitFor(OrderOfferMockScenario.single);
    network.setSilently(false);

    await cubit.decline(OfferDeclineReason.vanFull);
    expect(cubit.state.error, OrderOfferError.declineOffline);

    network.setSilently(true);
    await cubit.retry();
    expect(cubit.state.status, OrderOfferStatus.declined);
  });

  test('skipping applies to groups only, and accepts the rest', () async {
    final (single, offer) = await cubitFor(OrderOfferMockScenario.single);
    single.toggleSkip(offer.orders.single.id);
    expect(single.state.skipped, isEmpty);

    final (group, _) = await cubitFor(OrderOfferMockScenario.group);
    group.toggleSkip('RX-1053');
    expect(group.state.acceptedOrders.map((o) => o.id), ['RX-1052', 'RX-1054']);

    await group.accept();
    expect(group.state.result?.acceptedCount, 2);
    expect(group.state.result?.customerName, isNull);
  });

  test('falls back to the label when there is no deadline', () async {
    final (_, offer) = await cubitFor(OrderOfferMockScenario.single);
    final preview = OrderOfferEntity(
      id: offer.id,
      fleetName: offer.fleetName,
      deadlineLabel: '09:42',
      stopsCount: 1,
      distanceLabel: '',
      timeLabel: '',
      orders: offer.orders,
    );
    final cubit = OrderOfferCubit(
      offer: preview,
      acceptOfferUseCase: AcceptOfferUseCase(offersRepository()),
      declineOfferUseCase: DeclineOfferUseCase(offersRepository()),
      clock: () => now,
    );
    addTearDown(cubit.close);
    expect(cubit.state.remaining, const Duration(minutes: 9, seconds: 42));
  });
}
