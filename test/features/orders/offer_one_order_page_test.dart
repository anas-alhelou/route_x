import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_offer_remote_data_source.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';
import 'package:routex_mobile/features/orders/presentation/pages/offer_one_order_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/order_offer_accepted_page.dart';

import 'fake_network_info.dart';
import 'offers_test_support.dart';

const _designSize = Size(412, 917);

/// Opens the offer from a launcher screen, so the test can read what it
/// popped with.
class _Launcher {
  OrderOfferOutcome? outcome;
  bool closed = false;
}

Future<_Launcher> _open(WidgetTester tester, OrderOfferEntity offer) async {
  await tester.binding.setSurfaceSize(_designSize);
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final launcher = _Launcher();
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  launcher.outcome =
                      await Navigator.of(context).push<OrderOfferOutcome>(
                    MaterialPageRoute(
                      builder: (_) => OrderOfferPage(offer: offer),
                    ),
                  );
                  launcher.closed = true;
                },
                child: const Text('Open offer'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open offer'));
  await _settle(tester);
  return launcher;
}

/// Lets a route transition and a zero-delay answer finish. Never
/// pumpAndSettle: the countdown rebuilds every second while the offer is
/// open.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Leaves no countdown running behind the test.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

void main() {
  late FakeNetworkInfo network;

  Future<OrderOfferEntity> offerFor(
    WidgetTester tester,
    OrderOfferMockScenario scenario,
  ) async {
    network = FakeNetworkInfo();
    final repository = offersRepository(scenario: scenario, network: network);
    registerOffers(repository);
    addTearDown(unregisterOffers);
    final offers = await tester.runAsync(repository.getPendingOffers);
    return offers!.single;
  }

  group('one order', () {
    testWidgets('matches the design', (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.single);
      await _open(tester, offer);

      expect(find.textContaining(' left'), findsOneWidget);
      expect(find.text('New order · Red Sea Express'), findsOneWidget);
      expect(find.text('Ahmed Ali'), findsOneWidget);
      expect(find.text('#RX-1052 · Tomorrow, Mon 12 Oct'), findsOneWidget);
      expect(find.text('+2.4 km · +12 min to your route'), findsOneWidget);
      expect(find.text('Prince Sultan St 22, Al Rawdah'), findsOneWidget);
      expect(find.text('Building 7, 3rd floor, flat 12'), findsOneWidget);
      expect(find.text('Deliver 09:00 – 11:00'), findsOneWidget);
      expect(find.text('Fits after stop 3 on your route'), findsOneWidget);
      expect(find.text('2 packages'), findsOneWidget);
      expect(find.text('Signature needed at the door'), findsOneWidget);
      expect(find.text('NOTE FROM YOUR COMPANY'), findsOneWidget);
      expect(
        find.text('Customer asked you to call when you arrive.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'If you don’t answer, the order goes back to Red Sea Express.',
        ),
        findsOneWidget,
      );
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Accept order'), findsOneWidget);

      await _close(tester);
    });

    testWidgets('Accept shows where it landed, and completes as accepted',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.single);
      final launcher = await _open(tester, offer);

      await tester.tap(find.text('Accept order'));
      await _settle(tester);

      expect(find.byType(OrderOfferAcceptedPage), findsOneWidget);
      expect(find.text('Added to your route'), findsOneWidget);
      expect(
        find.text(
          'Ahmed Ali is now stop 4 of 5. We re-planned the route so you '
          'still finish by 13:10.',
        ),
        findsOneWidget,
      );
      expect(find.text('Stops tomorrow'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('26.4 km'), findsOneWidget);
      expect(find.text('13:10'), findsOneWidget);
      expect(launcher.outcome, OrderOfferOutcome.accepted);

      await tester.tap(find.text('Back to orders'));
      await _settle(tester);
      expect(find.byType(OrderOfferAcceptedPage), findsNothing);
    });

    testWidgets('Decline asks why, and only declines with a reason',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.single);
      final launcher = await _open(tester, offer);

      await tester.tap(find.text('Decline'));
      await _settle(tester);
      expect(find.text('Why are you declining?'), findsOneWidget);
      expect(find.text('My van is full'), findsOneWidget);
      expect(find.text('It’s outside my area'), findsOneWidget);
      expect(find.text('My shift ends before then'), findsOneWidget);
      expect(find.text('Something else'), findsOneWidget);
      expect(
        find.text('Red Sea Express will offer the order to another driver.'),
        findsOneWidget,
      );

      // No reason yet: nothing happens.
      await tester.tap(find.text('Decline order'));
      await _settle(tester);
      expect(find.text('Why are you declining?'), findsOneWidget);

      await tester.tap(find.text('My van is full'));
      await tester.pump();
      await tester.tap(find.text('Decline order'));
      await _settle(tester);

      expect(launcher.outcome, OrderOfferOutcome.declined);
      expect(find.byType(OrderOfferPage), findsNothing);
    });

    testWidgets('Keep the order closes the sheet and leaves it open',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.single);
      final launcher = await _open(tester, offer);

      await tester.tap(find.text('Decline'));
      await _settle(tester);
      await tester.tap(find.text('Keep the order'));
      await _settle(tester);

      expect(find.text('Why are you declining?'), findsNothing);
      expect(find.text('Accept order'), findsOneWidget);
      expect(launcher.closed, isFalse);

      await _close(tester);
    });

    testWidgets('offline, the answer waits and Try again sends it',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.single);
      final launcher = await _open(tester, offer);
      network.setSilently(false);

      await tester.tap(find.text('Accept order'));
      await _settle(tester);

      expect(find.text('Couldn’t accept. You’re offline.'), findsOneWidget);
      expect(
        find.text('The offer stays open while the timer runs.'),
        findsOneWidget,
      );
      expect(find.textContaining(' left'), findsOneWidget);

      network.setSilently(true);
      await tester.tap(find.text('Try again'));
      await _settle(tester);

      expect(find.byType(OrderOfferAcceptedPage), findsOneWidget);
      expect(launcher.outcome, OrderOfferOutcome.accepted);
    });

    testWidgets('taken back while answering', (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.takenBack);
      await _open(tester, offer);

      await tester.tap(find.text('Accept order'));
      await _settle(tester);

      expect(find.text('No longer available'), findsOneWidget);
      expect(
        find.text('Red Sea Express took this order back'),
        findsOneWidget,
      );
      expect(
        find.text(
          'They gave it to another driver before you answered. Nothing '
          'changed on your route.',
        ),
        findsOneWidget,
      );
      expect(find.text('Accept order'), findsNothing);
      expect(find.text('Back to orders'), findsOneWidget);

      await _close(tester);
    });

    testWidgets('an offer past its deadline opens expired', (tester) async {
      final live = await offerFor(tester, OrderOfferMockScenario.single);
      final offer = OrderOfferEntity(
        id: live.id,
        fleetName: live.fleetName,
        deadlineLabel: '',
        stopsCount: 1,
        distanceLabel: '',
        timeLabel: '',
        orders: live.orders,
        note: live.note,
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      final launcher = await _open(tester, offer);

      expect(find.text('Time’s up'), findsOneWidget);
      expect(find.text('This offer expired'), findsOneWidget);
      expect(
        find.text(
          'You didn’t answer in 10 minutes, so it went back to Red Sea '
          'Express. Nothing changed on your route.',
        ),
        findsOneWidget,
      );
      expect(find.text('Accept order'), findsNothing);

      await tester.tap(find.text('Back to orders'));
      await _settle(tester);
      expect(launcher.outcome, isNull);
      expect(launcher.closed, isTrue);
    });

    testWidgets('the screens that open one order still show the offer',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.single);
      await tester.binding.setSurfaceSize(_designSize);
      tester.view.physicalSize = _designSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: _designSize,
          builder: (context, child) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OfferOneOrderPage(offer: offer, order: offer.orders.single),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ahmed Ali'), findsOneWidget);
      await _close(tester);
    });
  });

  group('a group', () {
    testWidgets('matches the design, and skipping one updates the totals',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.group);
      await _open(tester, offer);

      expect(find.text('Red Sea Express'), findsOneWidget);
      expect(find.text('3 new orders'), findsOneWidget);
      expect(
        find.text('For tomorrow, Mon 12 Oct. Pick the ones you can take.'),
        findsOneWidget,
      );
      expect(find.text('3'), findsOneWidget);
      expect(find.text('stops added'), findsOneWidget);
      expect(find.text('+6.8 km'), findsOneWidget);
      expect(find.text('+36 min'), findsOneWidget);
      expect(find.text('Ahmed Ali · #RX-1052'), findsOneWidget);
      expect(find.text('Al Nahda · 11:00 – 13:00'), findsOneWidget);
      expect(find.text('Omar Haddad · #RX-1054'), findsOneWidget);
      expect(
        find.text(
          'Tap an order to leave it out. Your company sees which ones you '
          'skipped.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('If you don’t answer, all 3 go back to Red Sea Express.'),
        findsOneWidget,
      );
      expect(find.text('Decline all'), findsOneWidget);
      expect(find.text('Accept all 3'), findsOneWidget);

      await tester.tap(find.text('Lina Fares · #RX-1053'));
      await tester.pump();

      expect(find.text('Skipping'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('+4.9 km'), findsOneWidget);
      expect(find.text('+26 min'), findsOneWidget);
      expect(find.text('Accept 2, skip 1'), findsOneWidget);

      // Tapping again takes it back in.
      await tester.tap(find.text('Lina Fares · #RX-1053'));
      await tester.pump();
      expect(find.text('Skipping'), findsNothing);
      expect(find.text('Accept all 3'), findsOneWidget);

      await _close(tester);
    });

    testWidgets('accepting part of a group reports the orders added',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.group);
      final launcher = await _open(tester, offer);

      await tester.tap(find.text('Lina Fares · #RX-1053'));
      await tester.pump();
      await tester.tap(find.text('Accept 2, skip 1'));
      await _settle(tester);

      expect(
        find.text(
          '2 orders added, from stop 4 of 6. We re-planned the route so you '
          'still finish by 13:24.',
        ),
        findsOneWidget,
      );
      expect(find.text('6'), findsOneWidget);
      expect(find.text('28.9 km'), findsOneWidget);
      expect(launcher.outcome, OrderOfferOutcome.accepted);
    });

    testWidgets('with every order skipped there is nothing to accept',
        (tester) async {
      final offer = await offerFor(tester, OrderOfferMockScenario.group);
      await _open(tester, offer);

      for (final name in [
        'Ahmed Ali · #RX-1052',
        'Lina Fares · #RX-1053',
        'Omar Haddad · #RX-1054',
      ]) {
        await tester.tap(find.text(name));
        await tester.pump();
      }

      expect(find.text('Accept 0, skip 3'), findsOneWidget);
      await tester.tap(find.text('Accept 0, skip 3'));
      await _settle(tester);
      expect(find.byType(OrderOfferAcceptedPage), findsNothing);

      await _close(tester);
    });
  });
}
