import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/data/datasources/order_detail_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/datasources/orders_today_local_data_source.dart';
import 'package:routex_mobile/features/orders/data/repositories/order_detail_repository_impl.dart';
import 'package:routex_mobile/features/orders/data/repositories/orders_today_repository_impl.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_detail_entity.dart';
import 'package:routex_mobile/features/orders/domain/entities/orders_today_entity.dart';
import 'package:routex_mobile/features/orders/domain/repositories/order_detail_repository.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_order_detail_usecase.dart';
import 'package:routex_mobile/features/orders/domain/usecases/get_orders_today_usecase.dart';
import 'package:routex_mobile/features/orders/presentation/controllers/orders_today_cubit.dart';
import 'package:routex_mobile/features/orders/presentation/pages/order_detail_page.dart';
import 'package:routex_mobile/features/orders/presentation/pages/orders_today_page.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/order_detail/order_detail_cards.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/order_detail/order_detail_header.dart';

import 'fake_network_info.dart';
import 'offers_test_support.dart';

const _designSize = Size(412, 917);

const _ahmed = TodayStopEntity(
  id: 'ORD-10032',
  sequence: 4,
  customerName: 'Ahmed Ali',
  area: 'Prince Sultan St, Al Rawdah',
  timeWindow: '12:00 — 14:00',
  status: TodayStopStatus.upNext,
);

Future<void> _pumpApp(WidgetTester tester, Widget home) async {
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
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  // OrderDetailPage resolves its use case from getIt, as it does in the app.
  setUp(() {
    getIt.registerLazySingleton<GetOrderDetailUseCase>(
      () => GetOrderDetailUseCase(
        const OrderDetailRepositoryImpl(
          localDataSource: OrderDetailLocalDataSourceImpl(),
        ),
      ),
    );
  });
  tearDown(() => getIt.unregister<GetOrderDetailUseCase>());

  testWidgets('renders every section of the mockup for Ahmed Ali',
      (tester) async {
    await _pumpApp(tester, const OrderDetailPage(stop: _ahmed));
    await tester.pump();

    expect(find.text('Orders'), findsWidgets);
    expect(find.text('To do'), findsOneWidget);
    expect(find.text('#RX-1041'), findsOneWidget);
    expect(find.text('Ahmed Ali'), findsOneWidget);
    expect(find.text('Stop 4 of 5 · Today'), findsOneWidget);

    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Navigate'), findsOneWidget);

    expect(find.text('ADDRESS'), findsOneWidget);
    expect(find.text('Prince Sultan St 22, Al Rawdah'), findsOneWidget);
    expect(find.text('Building 7, 3rd floor, flat 12'), findsOneWidget);
    expect(find.text('Gate code'), findsOneWidget);
    expect(find.text('4471'), findsOneWidget);

    expect(find.text('DELIVERY WINDOW'), findsOneWidget);
    expect(find.text('12:00 — 14:00'), findsOneWidget);
    expect(find.text('ETA 12:25 · on time'), findsOneWidget);

    expect(find.text('PACKAGES'), findsOneWidget);
    expect(find.text('2 packages'), findsOneWidget);
    expect(find.text('0 of 2 scanned'), findsOneWidget);
    expect(find.text('Signature needed'), findsOneWidget);
    expect(find.text('Photo on delivery'), findsOneWidget);

    expect(find.text('NOTE FROM DISPATCH'), findsOneWidget);
    expect(
      find.textContaining('Customer asked you to call when you arrive.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Message dispatch about this order'),
      200,
    );
    expect(find.text('Message dispatch about this order'), findsOneWidget);
  });

  testWidgets('on the way: green pill, minutes away, gate code outlined',
      (tester) async {
    const lina = TodayStopEntity(
      id: 'ORD-10031',
      sequence: 3,
      customerName: 'Lina Fares',
      area: 'Tahlia St, Al Nahda',
      timeWindow: '10:00 — 12:00',
      status: TodayStopStatus.onTheWay,
    );
    await _pumpApp(tester, const OrderDetailPage(stop: lina));
    await tester.pump();

    expect(find.text('On the way'), findsOneWidget);
    // The navigate arrow leads the label inside the pill.
    expect(
      find.descendant(
        of: find.byType(OrderStatusPill),
        matching: find.byType(SvgPicture),
      ),
      findsOneWidget,
    );
    expect(find.text('#RX-1040'), findsOneWidget);
    expect(find.text('Stop 3 of 5 · Today · 6 min away'),
        findsOneWidget);

    expect(find.text('Tahlia St 14, Al Nahda'), findsOneWidget);
    expect(find.text('Villa 7, blue gate'), findsOneWidget);
    expect(find.text('2290'), findsOneWidget);
    expect(tester.widget<GateCodeBadge>(find.byType(GateCodeBadge)).emphasized,
        isTrue);

    expect(find.text('1 package'), findsOneWidget);
    expect(find.text('1 of 1 scanned'), findsOneWidget);
    expect(find.text('Photo on delivery'), findsOneWidget);
    expect(find.text('Signature needed'), findsNothing);
    expect(
      find.text('Fragile: glass items. Please don’t leave it at the '
          'gate.'),
      findsOneWidget,
    );
  });

  testWidgets('a stop not yet on the way shows neither the minutes nor the '
      'outline', (tester) async {
    await _pumpApp(tester, const OrderDetailPage(stop: _ahmed));
    await tester.pump();

    expect(find.text('To do'), findsOneWidget);
    expect(find.textContaining('min away'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(OrderStatusPill),
        matching: find.byType(SvgPicture),
      ),
      findsNothing,
    );
    expect(tester.widget<GateCodeBadge>(find.byType(GateCodeBadge)).emphasized,
        isFalse);
  });

  testWidgets('hides the gate code and note when the order has none',
      (tester) async {
    getIt.unregister<GetOrderDetailUseCase>();
    getIt.registerLazySingleton<GetOrderDetailUseCase>(
      () => const GetOrderDetailUseCase(_FixedDetailRepository()),
    );

    await _pumpApp(tester, const OrderDetailPage(stop: _ahmed));
    await tester.pump();

    expect(find.text('ADDRESS'), findsOneWidget);
    expect(find.byType(GateCodeBadge), findsNothing);
    expect(find.byType(OrderDispatchNoteCard), findsNothing);
  });

  testWidgets('flags a late ETA instead of claiming on time', (tester) async {
    const sara = TodayStopEntity(
      id: 'ORD-10033',
      sequence: 5,
      customerName: 'Sara Mansour',
      area: 'Al Salamah',
      timeWindow: '12:00 — 14:00',
      status: TodayStopStatus.upNext,
    );
    await _pumpApp(tester, const OrderDetailPage(stop: sara));
    await tester.pump();

    expect(find.text('ETA 14:20 · running late'), findsOneWidget);
    expect(find.textContaining('on time'), findsNothing);
  });

  testWidgets('an unknown order shows the localized error, not a crash',
      (tester) async {
    const ghost = TodayStopEntity(
      id: 'ORD-missing',
      sequence: 9,
      customerName: 'Nobody',
      area: '',
      timeWindow: '',
      status: TodayStopStatus.upNext,
    );
    await _pumpApp(tester, const OrderDetailPage(stop: ghost));
    await tester.pump();

    expect(find.text('Nobody'), findsOneWidget);
    expect(
      find.text('We couldn’t load this order. Go back and try again.'),
      findsOneWidget,
    );
    expect(find.byType(OrderAddressCard), findsNothing);
  });

  testWidgets('tapping a stop on Today opens its detail, and back returns',
      (tester) async {
    final network = FakeNetworkInfo();
    addTearDown(network.dispose);
    final cubit = OrdersTodayCubit(
      getOrdersTodayUseCase: GetOrdersTodayUseCase(
        OrdersTodayRepositoryImpl(
          localDataSource: const OrdersTodayLocalDataSourceImpl(),
          networkInfo: network,
        ),
      ),
      networkInfo: network,
    );
    addTearDown(cubit.close);
    cubit.load();

    await _pumpApp(
      tester,
      MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(create: (_) => noOffersCubit()),
          ],
          child: const OrdersTodayView(),
        ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    await tester.tap(find.text('Ahmed Ali'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailView), findsOneWidget);
    expect(find.text('#RX-1041'), findsOneWidget);

    await tester.tap(find.text('Orders').first);
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailView), findsNothing);
    expect(find.byType(OrdersTodayView), findsOneWidget);
  });
}

/// An order with no gate and no note from dispatch — a case the mock data no
/// longer happens to contain, so the test does not lean on it.
class _FixedDetailRepository implements OrderDetailRepository {
  const _FixedDetailRepository();

  @override
  Future<OrderDetailEntity> getOrderDetail(String orderId) async =>
      const OrderDetailEntity(
        id: 'ORD-10032',
        orderCode: 'RX-1041',
        totalStops: 5,
        customerPhone: '+966502223344',
        addressLine: 'Prince Sultan St 22, Al Rawdah',
        addressDetails: '',
        gateCode: null,
        eta: '12:25',
        isOnTime: true,
        packagesCount: 1,
        scannedCount: 0,
        requirements: [],
        dispatchNote: null,
        latitude: 0,
        longitude: 0,
      );
}
