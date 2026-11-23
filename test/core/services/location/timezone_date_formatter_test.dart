// test/core/services/location/timezone_date_formatter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/services/location/timezone_date_formatter.dart';
import 'package:routex_mobile/core/services/location/user_location.dart';

void main() {
  group('TimezoneDateFormatter Tests', () {
    test('calculateTimezoneOffset calculates correct solar offsets', () {
      // Greenwich / London (0 deg lon) -> UTC+0
      expect(
        TimezoneDateFormatter.calculateTimezoneOffset(51.5, 0.0),
        Duration.zero,
      );

      // Cairo / Jordan / Riyadh (~45 deg lon) -> approx UTC+3
      expect(
        TimezoneDateFormatter.calculateTimezoneOffset(24.7, 45.0),
        const Duration(hours: 3),
      );

      // New York (-74 deg lon) -> approx UTC-5
      expect(
        TimezoneDateFormatter.calculateTimezoneOffset(40.7, -74.0),
        const Duration(hours: -5),
      );

      // Tokyo (139.7 deg lon) -> approx UTC+9:30 or UTC+9
      final tokyoOffset = TimezoneDateFormatter.calculateTimezoneOffset(35.6, 139.7);
      expect(tokyoOffset.inHours, isIn([9, 10]));
    });

    test('calculateTimezoneOffset clamps within valid UTC ranges (-12h to +14h)', () {
      final westClamped = TimezoneDateFormatter.calculateTimezoneOffset(0, -180.0);
      expect(westClamped.inHours, greaterThanOrEqualTo(-12));

      final eastClamped = TimezoneDateFormatter.calculateTimezoneOffset(0, 180.0);
      expect(eastClamped.inHours, lessThanOrEqualTo(14));
    });

    test('getLocalDateTime falls back to DateTime.now when location is null', () {
      final now = DateTime.now();
      final local = TimezoneDateFormatter.getLocalDateTime(location: null);
      expect(local.difference(now).inSeconds.abs(), lessThan(2));
    });

    test('getLocalDateTime adjusts reference UTC by coordinate offset when far from device timezone', () {
      const remoteLoc = UserLocation(
        latitude: -33.86,
        longitude: 151.2, // Sydney ~UTC+10
      );

      final refUtc = DateTime.utc(2026, 10, 19, 12, 0, 0); // 12:00 PM UTC
      final local = TimezoneDateFormatter.getLocalDateTime(
        location: remoteLoc,
        referenceUtc: refUtc,
      );

      // If device is UTC+3 and Sydney is UTC+10 (diff = 7h > 90 min),
      // Sydney offset is applied (approx 10h -> 22:00)
      expect(local.isUtc, isFalse);
      expect(local.hour, isNot(12));
    });

    test('formatDate formats day and date correctly', () {
      final date = DateTime(2026, 10, 19, 10, 0);
      final formatted = TimezoneDateFormatter.formatDate(date, locale: 'en');
      expect(formatted, 'Monday, 19 October');
    });

    test('formatHeaderDate produces formatted string matching Figma pattern', () {
      final formatted = TimezoneDateFormatter.formatHeaderDate(
        // Without a location the formatter uses the device clock, so pin one.
        location: const UserLocation(latitude: 31.5, longitude: 34.5),
        referenceUtc: DateTime.utc(2026, 10, 19, 12, 0),
        locale: 'en',
      );
      expect(formatted, contains('October'));
      expect(formatted, contains(','));
    });
  });
}
