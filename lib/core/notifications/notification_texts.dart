// lib/core/notifications/notification_texts.dart
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:routex_mobile/core/config/constants/preference_keys.dart';

import 'package:routex_mobile/core/l10n/app_localizations.dart';

/// Localised strings for system notifications.
///
/// A notification is built outside the widget tree (a push arriving while the
/// app is closed, the route changing in the background), so there is no
/// `BuildContext` to read the language from. The app keeps [currentLocale] up
/// to date from the language bloc; until it does, the phone's language is used.
abstract final class NotificationTexts {
  static Locale? currentLocale;

  /// Reads the language the driver chose in the app. A push that arrives while
  /// the app is closed runs in its own isolate where [currentLocale] is empty,
  /// so without this it would use the phone's language instead.
  static Future<void> loadSavedLocale({bool reload = false}) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (reload) await p.reload();
      final code = p.getString(PreferenceKeys.languageCode);
      if (code != null && code.isNotEmpty) currentLocale = Locale(code);
    } catch (_) {}
  }

  static AppLocalizations get l10n {
    final wanted = currentLocale ?? PlatformDispatcher.instance.locale;
    try {
      return lookupAppLocalizations(Locale(wanted.languageCode));
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }
}
