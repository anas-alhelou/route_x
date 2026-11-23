import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/config/constants/preference_keys.dart';
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'package:routex_mobile/core/notifications/notification_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _resetDefaults() {
  NotificationPreferences.update(
    enabled: true,
    newRoutes: true,
    orderChanges: true,
    dispatch: true,
    sound: true,
    vibrate: true,
    quietEnabled: false,
    quietStartMinutes: 23 * 60,
    quietEndMinutes: 7 * 60,
    quietDays: const [1, 2, 3, 4, 5, 6, 7],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _resetDefaults();
  });

  test('save then load restores every setting (a background push reads it)',
      () async {
    NotificationPreferences.update(
      enabled: true,
      newRoutes: false,
      orderChanges: false,
      dispatch: true,
      sound: false,
      vibrate: false,
      quietEnabled: true,
      quietStartMinutes: 22 * 60,
      quietEndMinutes: 6 * 60,
      quietDays: const [1, 3, 5],
    );
    await NotificationPreferences.save();

    // A fresh isolate starts from the defaults.
    _resetDefaults();
    expect(NotificationPreferences.sound, isTrue);

    await NotificationPreferences.load(reload: true);

    expect(NotificationPreferences.newRoutes, isFalse);
    expect(NotificationPreferences.orderChanges, isFalse);
    expect(NotificationPreferences.sound, isFalse);
    expect(NotificationPreferences.vibrate, isFalse);
    expect(NotificationPreferences.quietEnabled, isTrue);
    expect(NotificationPreferences.quietStartMinutes, 22 * 60);
    expect(NotificationPreferences.quietEndMinutes, 6 * 60);
    expect(NotificationPreferences.quietDays, [1, 3, 5]);
  });

  test('load with nothing saved keeps the defaults', () async {
    await NotificationPreferences.load();
    expect(NotificationPreferences.enabled, isTrue);
    expect(NotificationPreferences.quietEnabled, isFalse);
    expect(NotificationPreferences.quietDays, [1, 2, 3, 4, 5, 6, 7]);
  });

  group('quiet hours', () {
    test('a window that wraps midnight covers both sides of it', () {
      NotificationPreferences.update(
        enabled: true,
        newRoutes: true,
        orderChanges: true,
        dispatch: true,
        sound: true,
        vibrate: true,
        quietEnabled: true,
        quietStartMinutes: 23 * 60,
        quietEndMinutes: 7 * 60,
        quietDays: const [1, 2, 3, 4, 5, 6, 7],
      );
      expect(NotificationPreferences.isQuietNow(DateTime(2026, 11, 16, 23, 30)),
          isTrue);
      expect(NotificationPreferences.isQuietNow(DateTime(2026, 11, 17, 3, 0)),
          isTrue);
      expect(NotificationPreferences.isQuietNow(DateTime(2026, 11, 17, 12, 0)),
          isFalse);
    });

    test('sound and vibration are silenced during quiet hours', () {
      NotificationPreferences.update(
        enabled: true,
        newRoutes: true,
        orderChanges: true,
        dispatch: true,
        sound: true,
        vibrate: true,
        quietEnabled: true,
        quietStartMinutes: 0,
        quietEndMinutes: 23 * 60 + 59,
        quietDays: const [1, 2, 3, 4, 5, 6, 7],
      );
      // The window covers the whole day, so right now is quiet whatever the
      // clock says.
      expect(NotificationPreferences.isQuietNow(DateTime(2026, 11, 16, 10, 0)),
          isTrue);
      final now = DateTime.now();
      if (now.hour * 60 + now.minute < 23 * 60 + 59) {
        expect(NotificationPreferences.playSound, isFalse);
        expect(NotificationPreferences.vibration, isFalse);
      }
    });
  });

  group('NotificationTexts.loadSavedLocale', () {
    tearDown(() => NotificationTexts.currentLocale = null);

    test('uses the language saved by the app, not the phone language',
        () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.languageCode: 'ar',
      });
      NotificationTexts.currentLocale = null;
      await NotificationTexts.loadSavedLocale(reload: true);
      expect(NotificationTexts.currentLocale?.languageCode, 'ar');
    });

    test('leaves the locale alone when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});
      NotificationTexts.currentLocale = null;
      await NotificationTexts.loadSavedLocale();
      expect(NotificationTexts.currentLocale, isNull);
    });
  });
}
