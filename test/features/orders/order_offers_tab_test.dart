import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_offer_remote_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/orders_today_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/orders_today_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_orders_today_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/order_offer_usecases.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/order_offers_cubit.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_today_cubit.dart';
import 'package:routex_mobile/features/orders/presentation/pages/offer_one_order_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/orders_today_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/offers/offers_tab_widgets.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/orders_today/new_orders_banner.dart';

import 'fake_network_info.dart';
import 'offers_test_support.dart';

const _designSize = Size(412, 917);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// The Orders tab with the day loaded and [scenario]'s offers waiting.
Future<void> _pumpTab(
  WidgetTester tester, {
  OrderOfferMockScenario scenario = OrderOfferMockScenario.group,
}) async {
  await tester.binding.setSurfaceSize(_designSize);
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final network = FakeNetworkInfo();
  final offers = offersRepository(scenario: scenario, network: network);
  registerOffers(offers);
  addTearDown(unregisterOffers);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _designSize,
      builder: (context, child) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => OrdersTodayCubit(
                getOrdersTodayUseCase: GetOrdersTodayUseCase(
                  OrdersTodayRepositoryImpl(
                    localDataSource: const OrdersTodayLocalDataSourceImpl(
                      loadDelay: Duration.zero,
                    ),
                    networkInfo: network,
                  ),
                ),
                networkInfo: network,
              )..load(),
            ),
            BlocProvider(
              create: (_) => OrderOffersCubit(
                getPendingOffersUseCase: GetPendingOffersUseCase(offers),
                undoDeclineOfferUseCase: UndoDeclineOfferUseCase(offers),
              )..load(),
            ),
          ],
          child: const OrdersTodayView(),
        ),
      ),
    ),
  );
  await _settle(tester);
}

/// Unmounts the tab so no countdown or toast timer outlives the test.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  testWidgets('offers waiting take the banner slot', (tester) async {
    await _pumpTab(tester);

    expect(find.byType(OffersWaitingBanner), findsOneWidget);
    expect(find.text('3 orders waiting for you'), findsOneWidget);
    expect(find.textContaining('Answer in '), findsOneWidget);
    expect(find.textContaining(' or they go back'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    // One banner at a time: offers outrank "new orders".
    expect(find.byType(NewOrdersBanner), findsNothing);

    await _close(tester);
  });

  testWidgets('with nothing waiting, the new-orders banner is back',
      (tester) async {
    await _pumpTab(tester, scenario: OrderOfferMockScenario.none);

    expect(find.byType(OffersWaitingBanner), findsNothing);
    expect(find.byType(NewOrdersBanner), findsOneWidget);

    await _close(tester);
  });

  testWidgets('View opens the offer; declining shows the toast, Undo '
      'brings it back', (tester) async {
    await _pumpTab(tester);

    await tester.tap(find.text('View'));
    await _settle(tester);
    expect(find.byType(OrderOfferPage), findsOneWidget);
    expect(find.text('3 new orders'), findsOneWidget);

    await tester.tap(find.text('Decline all'));
    await _settle(tester);
    await tester.tap(find.text('It’s outside my area'));
    await tester.pump();
    await tester.tap(find.text('Decline order'));
    await _settle(tester);

    expect(find.byType(OrderOfferPage), findsNothing);
    expect(find.byType(OffersWaitingBanner), findsNothing);
    expect(find.text('Orders declined'), findsOneWidget);
    expect(
      find.text('Red Sea Express will give them to another driver.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Undo'));
    await _settle(tester);

    expect(find.text('Orders declined'), findsNothing);
    expect(find.text('3 orders waiting for you'), findsOneWidget);

    await _close(tester);
  });

  testWidgets('the toast goes by itself', (tester) async {
    await _pumpTab(tester, scenario: OrderOfferMockScenario.single);

    await tester.tap(find.text('View'));
    await _settle(tester);
    await tester.tap(find.text('Decline'));
    await _settle(tester);
    await tester.tap(find.text('My van is full'));
    await tester.pump();
    await tester.tap(find.text('Decline order'));
    await _settle(tester);

    expect(find.text('Order declined'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await _settle(tester);
    expect(find.text('Order declined'), findsNothing);

    await _close(tester);
  });

  testWidgets('accepting takes the offer off the tab', (tester) async {
    await _pumpTab(tester, scenario: OrderOfferMockScenario.single);

    await tester.tap(find.text('View'));
    await _settle(tester);
    await tester.tap(find.text('Accept order'));
    await _settle(tester);
    expect(find.text('Added to your route'), findsOneWidget);

    await tester.tap(find.text('Back to orders'));
    await _settle(tester);
    expect(find.byType(OffersWaitingBanner), findsNothing);

    await _close(tester);
  });
}
