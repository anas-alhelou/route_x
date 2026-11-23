// lib/core/notifications/notification_preferences.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The driver's notification settings (Settings → Notifications), applied to
/// every notification the app shows.
class NotificationPreferences {
  NotificationPreferences._();

  static const String _kPrefix = 'notif.pref.';

  static bool enabled = true;
  static bool newRoutes = true;
  static bool orderChanges = true;
  static bool dispatch = true;
  static bool sound = true;
  static bool vibrate = true;
  static bool quietEnabled = false;
  static int quietStartMinutes = 23 * 60;
  static int quietEndMinutes = 7 * 60;
  static List<int> quietDays = const [1, 2, 3, 4, 5, 6, 7];

  static void update({
    required bool enabled,
    required bool newRoutes,
    required bool orderChanges,
    required bool dispatch,
    required bool sound,
    required bool vibrate,
    required bool quietEnabled,
    required int quietStartMinutes,
    required int quietEndMinutes,
    required List<int> quietDays,
  }) {
    NotificationPreferences.enabled = enabled;
    NotificationPreferences.newRoutes = newRoutes;
    NotificationPreferences.orderChanges = orderChanges;
    NotificationPreferences.dispatch = dispatch;
    NotificationPreferences.sound = sound;
    NotificationPreferences.vibrate = vibrate;
    NotificationPreferences.quietEnabled = quietEnabled;
    NotificationPreferences.quietStartMinutes = quietStartMinutes;
    NotificationPreferences.quietEndMinutes = quietEndMinutes;
    NotificationPreferences.quietDays = quietDays;
    // Fire and forget: a background push (separate isolate) reads this copy.
    unawaited(save());
  }

  /// Writes the current settings to the device so a push that arrives while
  /// the app is closed (its own isolate, with fresh statics) can apply them.
  static Future<void> save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('${_kPrefix}enabled', enabled);
      await p.setBool('${_kPrefix}newRoutes', newRoutes);
      await p.setBool('${_kPrefix}orderChanges', orderChanges);
      await p.setBool('${_kPrefix}dispatch', dispatch);
      await p.setBool('${_kPrefix}sound', sound);
      await p.setBool('${_kPrefix}vibrate', vibrate);
      await p.setBool('${_kPrefix}quietEnabled', quietEnabled);
      await p.setInt('${_kPrefix}quietStart', quietStartMinutes);
      await p.setInt('${_kPrefix}quietEnd', quietEndMinutes);
      await p.setStringList(
        '${_kPrefix}quietDays',
        quietDays.map((d) => d.toString()).toList(),
      );
    } catch (error) {
      debugPrint('Notification preferences save error: $error');
    }
  }

  /// Restores the saved settings. Call at app start and at the top of the
  /// background push handler. Missing values keep their defaults. [reload]
  /// re-reads the file, which a long-lived background isolate needs because
  /// the app isolate may have written to it since.
  static Future<void> load({bool reload = false}) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (reload) await p.reload();
      enabled = p.getBool('${_kPrefix}enabled') ?? enabled;
      newRoutes = p.getBool('${_kPrefix}newRoutes') ?? newRoutes;
      orderChanges = p.getBool('${_kPrefix}orderChanges') ?? orderChanges;
      dispatch = p.getBool('${_kPrefix}dispatch') ?? dispatch;
      sound = p.getBool('${_kPrefix}sound') ?? sound;
      vibrate = p.getBool('${_kPrefix}vibrate') ?? vibrate;
      quietEnabled = p.getBool('${_kPrefix}quietEnabled') ?? quietEnabled;
      quietStartMinutes = p.getInt('${_kPrefix}quietStart') ?? quietStartMinutes;
      quietEndMinutes = p.getInt('${_kPrefix}quietEnd') ?? quietEndMinutes;
      final days = p.getStringList('${_kPrefix}quietDays');
      if (days != null) {
        final parsed = days.map(int.tryParse).whereType<int>().toList();
        if (parsed.isNotEmpty) quietDays = parsed;
      }
    } catch (error) {
      debugPrint('Notification preferences load error: $error');
    }
  }

  /// True while the quiet-hours window (which may wrap past midnight) is on.
  static bool isQuietNow([DateTime? at]) {
    if (!quietEnabled) return false;
    final now = at ?? DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final s = quietStartMinutes;
    final e = quietEndMinutes;
    if (s == e) return false;
    if (s < e) {
      return quietDays.contains(now.weekday) && minutes >= s && minutes < e;
    }
    // Wraps midnight: the evening part belongs to today, the morning part to
    // the day that started the window.
    if (minutes >= s) return quietDays.contains(now.weekday);
    if (minutes < e) {
      final prev = now.weekday == 1 ? 7 : now.weekday - 1;
      return quietDays.contains(prev);
    }
    return false;
  }

  static bool get playSound => sound && !isQuietNow();
  static bool get vibration => vibrate && !isQuietNow();
}

/// Unread count of the notifications inbox, shown as a dot on the Home bell.
class NotificationInboxBadge {
  NotificationInboxBadge._();

  static final ValueNotifier<int> unread = ValueNotifier<int>(0);
}
