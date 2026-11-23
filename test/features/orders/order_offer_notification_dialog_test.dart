import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/orders/domain/entities/order_offer_entity.dart';
import 'package:routex_mobile/features/orders/presentation/widgets/order_offer_notification_dialog.dart';

const _offer = OrderOfferEntity(
  id: 'offer-1',
  fleetName: 'RouteX',
  deadlineLabel: '10 دقائق',
  stopsCount: 1,
  distanceLabel: '+2.4 كم',
  timeLabel: '+5 دقائق',
  orders: [
    OfferOrderEntity(
      id: 'order-1',
      customerName: 'أحمد علي',
      orderCode: 'RX-1052',
      area: 'الروضة',
      timeWindow: '09:00 — 11:00',
      distanceKm: '+2.4 كم',
      packagesCount: 2,
    ),
  ],
);

const _groupOffer = OrderOfferEntity(
  id: 'offer-group',
  fleetName: 'RouteX',
  deadlineLabel: '10 min',
  stopsCount: 3,
  distanceLabel: '+6.8 km',
  timeLabel: '+36 min',
  orders: [
    OfferOrderEntity(
      id: 'order-1',
      customerName: 'Ahmed Ali',
      orderCode: 'RX-1052',
      area: 'Al Rawdah',
      timeWindow: '09:00 — 11:00',
      distanceKm: '+2.4 km',
      packagesCount: 2,
    ),
    OfferOrderEntity(
      id: 'order-2',
      customerName: 'Sara Hassan',
      orderCode: 'RX-1053',
      area: 'Al Nahda',
      timeWindow: '09:00 — 11:00',
      distanceKm: '+2.0 km',
      packagesCount: 1,
    ),
    OfferOrderEntity(
      id: 'order-3',
      customerName: 'Omar Khalid',
      orderCode: 'RX-1054',
      area: 'Al Zahra',
      timeWindow: '09:00 — 11:00',
      distanceKm: '+2.4 km',
      packagesCount: 1,
    ),
  ],
);

void main() {
  testWidgets('shows order details and calls the selected action', (
    tester,
  ) async {
    var accepted = false;
    var declined = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(412, 917),
        builder: (context, child) => MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => OrderOfferNotificationDialog.show(
                    context: context,
                    offer: _offer,
                    onAccept: () => accepted = true,
                    onDecline: () => declined = true,
                    onViewOrders: () {},
                  ),
                  child: const Text('Show offer'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show offer'));
    await tester.pumpAndSettle();

    expect(find.text('طلب جديد: أحمد علي، الروضة'), findsOneWidget);
    expect(find.textContaining('2 طرود'), findsOneWidget);
    expect(find.text('قبول'), findsOneWidget);
    expect(find.text('رفض'), findsOneWidget);

    await tester.tap(find.text('قبول'));
    await tester.pumpAndSettle();

    expect(accepted, isTrue);
    expect(declined, isFalse);
    expect(find.byType(OrderOfferNotificationDialog), findsNothing);
  });

  testWidgets('shows a view-orders action for a grouped offer', (tester) async {
    var viewedOrders = false;
    var accepted = false;
    var declined = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(412, 917),
        builder: (context, child) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => OrderOfferNotificationDialog.show(
                    context: context,
                    offer: _groupOffer,
                    onAccept: () => accepted = true,
                    onDecline: () => declined = true,
                    onViewOrders: () => viewedOrders = true,
                  ),
                  child: const Text('Show offer'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show offer'));
    await tester.pumpAndSettle();

    expect(find.text('ROUTEX · 3 NEW ORDERS · NOW'), findsOneWidget);
    expect(find.text('3 new orders for tomorrow'), findsOneWidget);
    expect(
      find.textContaining('Al Rawdah, Al Nahda, Al Zahra'),
      findsOneWidget,
    );
    expect(find.text('View orders'), findsOneWidget);
    expect(find.text('Accept'), findsNothing);
    expect(find.text('Decline'), findsNothing);

    await tester.tap(find.text('View orders'));
    await tester.pumpAndSettle();

    expect(viewedOrders, isTrue);
    expect(accepted, isFalse);
    expect(declined, isFalse);
    expect(find.byType(OrderOfferNotificationDialog), findsNothing);
  });
}
