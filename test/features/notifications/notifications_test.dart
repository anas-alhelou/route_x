// test/features/notifications/notifications_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:routex_mobile/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/toggle_notifications_empty_usecase.dart';
import 'package:routex_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:routex_mobile/features/notifications/presentation/pages/notifications_page.dart';

Widget _buildTestScope({
  required Widget child,
  Size size = const Size(412, 917),
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: ScreenUtilInit(
        designSize: const Size(412, 917),
        minTextAdapt: true,
        builder: (context, _) => Scaffold(body: child),
      ),
    ),
  );
}

Future<void> _pumpScope(
  WidgetTester tester, {
  required Widget child,
  Size size = const Size(412, 917),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _buildTestScope(
      child: child,
      size: size,
      locale: locale,
    ),
  );
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotificationsLocalDataSource dataSource;
  late NotificationsRepositoryImpl repository;
  late GetNotificationsUseCase getNotifications;
  late MarkAllNotificationsReadUseCase markAllRead;
  late ToggleNotificationsEmptyUseCase toggleEmpty;
  late NotificationsBloc bloc;

  setUp(() {
    dataSource = NotificationsLocalDataSourceImpl(readDelay: Duration.zero);
    repository = NotificationsRepositoryImpl(localDataSource: dataSource);
    getNotifications = GetNotificationsUseCase(repository: repository);
    markAllRead = MarkAllNotificationsReadUseCase(repository: repository);
    toggleEmpty = ToggleNotificationsEmptyUseCase(repository: repository);
    bloc = NotificationsBloc(
      getNotifications: getNotifications,
      markAllRead: markAllRead,
      toggleEmpty: toggleEmpty,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('NotificationsBloc & Clean Architecture', () {
    test('initial state is initial and empty', () {
      expect(bloc.state.status, NotificationsStatus.initial);
      expect(bloc.state.notifications, isEmpty);
    });

    test('NotificationsStarted loads populated notifications (N01)', () async {
      bloc.add(const NotificationsStarted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const NotificationsState(status: NotificationsStatus.loading),
          predicate<NotificationsState>((state) {
            return state.status == NotificationsStatus.success &&
                state.notifications.length == 5 &&
                state.unreadCount == 2;
          }),
        ]),
      );
    });

    test('NotificationsMarkAllRead marks all unread items as read', () async {
      bloc.add(const NotificationsStarted());
      await bloc.stream.firstWhere((s) => s.status == NotificationsStatus.success);

      expect(bloc.state.hasUnread, isTrue);
      expect(bloc.state.unreadCount, 2);

      bloc.add(const NotificationsMarkAllRead());
      await bloc.stream.firstWhere((s) => s.unreadCount == 0);

      expect(bloc.state.hasUnread, isFalse);
      expect(bloc.state.unreadCount, 0);
      expect(bloc.state.notifications.every((n) => n.isRead), isTrue);
    });

    test('NotificationsToggleEmpty toggles between N01 and N02', () async {
      bloc.add(const NotificationsStarted());
      await bloc.stream.firstWhere((s) => s.status == NotificationsStatus.success);
      expect(bloc.state.notifications, isNotEmpty);

      // Toggle to empty (N02)
      bloc.add(const NotificationsToggleEmpty());
      await bloc.stream.firstWhere((s) => s.notifications.isEmpty);
      expect(bloc.state.isEmpty, isTrue);

      // Toggle back to populated (N01)
      bloc.add(const NotificationsToggleEmpty());
      await bloc.stream.firstWhere((s) => s.notifications.isNotEmpty);
      expect(bloc.state.notifications.length, 5);
    });
  });

  group('NotificationsPage UI Verification', () {
    testWidgets('renders N01 Populated screen with sections, items and headers',
        (tester) async {
      final sample = (await dataSource.getNotifications()).getOrElse(() => []);
      final populatedBloc = NotificationsBloc(
        getNotifications: getNotifications,
        markAllRead: markAllRead,
        toggleEmpty: toggleEmpty,
        initialState: NotificationsState(
          status: NotificationsStatus.success,
          notifications: sample,
        ),
      );
      addTearDown(populatedBloc.close);

      await _pumpScope(tester, child: NotificationsPage(bloc: populatedBloc));
      await tester.pump();

      // Header Bar
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      // Section 1: "New"
      expect(find.text('New'), findsOneWidget);
      expect(find.text('New order offered'), findsOneWidget);
      expect(find.text('Ahmed Ali · Al Rawdah, Jeddah'), findsOneWidget);
      expect(find.text('2m'), findsOneWidget);

      expect(find.text('Order cancelled'), findsOneWidget);
      expect(find.text('Red Sea Express cancelled #RX-1035'), findsOneWidget);
      expect(find.text('1h'), findsOneWidget);

      // Section 2: "Earlier"
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('Route started'), findsOneWidget);
      expect(
        find.text('2 of 3 orders are on your route. 1 was sent for review.'),
        findsOneWidget,
      );
      expect(find.text('Yesterday'), findsOneWidget);

      expect(find.text('Vehicle updated'), findsOneWidget);
      expect(
        find.text('Your company set your vehicle to Toyota Hiace · PAL-99488'),
        findsOneWidget,
      );
      expect(find.text('2d'), findsOneWidget);

      expect(find.text("You're approved"), findsOneWidget);
      expect(
        find.text('Red Sea Express approved your request. Welcome aboard!'),
        findsOneWidget,
      );
      expect(find.text('3d'), findsOneWidget);
    });

    testWidgets('tapping Mark all read updates items to read state',
        (tester) async {
      final sample = (await dataSource.getNotifications()).getOrElse(() => []);
      final populatedBloc = NotificationsBloc(
        getNotifications: getNotifications,
        markAllRead: markAllRead,
        toggleEmpty: toggleEmpty,
        initialState: NotificationsState(
          status: NotificationsStatus.success,
          notifications: sample,
        ),
      );
      addTearDown(populatedBloc.close);

      await _pumpScope(tester, child: NotificationsPage(bloc: populatedBloc));
      await tester.pump();

      expect(find.text('New'), findsOneWidget);

      // Tap Mark all read
      await tester.tap(find.text('Mark all read'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      // Section "New" disappears because all items are now in "Earlier"
      expect(find.text('New'), findsNothing);
      expect(find.text('Earlier'), findsOneWidget);
    });

    testWidgets('renders N02 Empty state correctly', (tester) async {
      final emptyBloc = NotificationsBloc(
        getNotifications: getNotifications,
        markAllRead: markAllRead,
        toggleEmpty: toggleEmpty,
        initialState: const NotificationsState(
          status: NotificationsStatus.success,
          notifications: [],
        ),
      );
      addTearDown(emptyBloc.close);

      await _pumpScope(tester, child: NotificationsPage(bloc: emptyBloc));
      await tester.pump();

      // Header has title, but NO "Mark all read" in empty state
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);

      // N02 empty contents
      expect(find.text('No notifications yet'), findsOneWidget);
      expect(
        find.text(
          'Route updates, replies from fleets and messages from dispatch will show up here.',
        ),
        findsOneWidget,
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders Arabic (RTL) localization properly', (tester) async {
      final sample = (await dataSource.getNotifications()).getOrElse(() => []);
      final populatedBloc = NotificationsBloc(
        getNotifications: getNotifications,
        markAllRead: markAllRead,
        toggleEmpty: toggleEmpty,
        initialState: NotificationsState(
          status: NotificationsStatus.success,
          notifications: sample,
        ),
      );
      addTearDown(populatedBloc.close);

      await _pumpScope(
        tester,
        locale: const Locale('ar'),
        child: NotificationsPage(bloc: populatedBloc),
      );
      await tester.pump();

      // Arabic Title & Buttons
      expect(find.text('الإشعارات'), findsOneWidget);
      expect(find.text('تحديد الكل كمقروء'), findsOneWidget);
      expect(find.text('جديد'), findsOneWidget);
      expect(find.text('سابقاً'), findsOneWidget);

      // Arabic notifications
      expect(find.text('تم عرض طلب جديد'), findsOneWidget);
      expect(find.text('أحمد علي · الروضة، جدة'), findsOneWidget);
      expect(find.text('٢ د'), findsOneWidget);
    });
  });
}
