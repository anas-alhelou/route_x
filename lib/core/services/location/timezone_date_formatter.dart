// lib/core/services/location/timezone_date_formatter.dart
import 'package:intl/intl.dart';
import 'user_location.dart';

/// Helper utility for calculating geographic timezones and formatting header dates.
class TimezoneDateFormatter {
  const TimezoneDateFormatter._();

  /// Calculates the estimated UTC offset for a geographic coordinate.
  ///
  /// Since the Earth rotates 360 degrees in 24 hours (15° per hour, or 4 minutes per 1°),
  /// the longitude directly indicates standard solar time. Standard time zones are aligned
  /// to 30 or 60 minute intervals (e.g. UTC+3, UTC+5:30).
  static Duration calculateTimezoneOffset(double latitude, double longitude) {
    // 1 degree = 4 minutes; round to the nearest 30-minute block
    final totalMinutes = ((longitude * 4) / 30).round() * 30;
    // Standard IANA time zone bounds are between UTC-12 and UTC+14
    final clampedMinutes = totalMinutes.clamp(-12 * 60, 14 * 60);
    return Duration(minutes: clampedMinutes);
  }

  /// Calculates the local [DateTime] for a given [UserLocation].
  ///
  /// If [location] is null, falls back safely to [DateTime.now].
  /// When [location] is provided:
  /// - Computes the geographic offset from longitude.
  /// - If the device's clock offset is within ±90 minutes of the coordinate offset
  ///   (standard for real devices in their home timezone), uses the device offset to
  ///   benefit from OS-level Daylight Saving Time (DST) and political borders.
  /// - Otherwise uses the coordinate-derived offset (e.g. for mock locations or remote simulation).
  static DateTime getLocalDateTime({
    UserLocation? location,
    DateTime? referenceUtc,
  }) {
    if (location == null) {
      return DateTime.now();
    }

    final utc = referenceUtc ?? DateTime.now().toUtc();
    final coordinateOffset = calculateTimezoneOffset(
      location.latitude,
      location.longitude,
    );
    final deviceOffset = DateTime.now().timeZoneOffset;

    final diffMinutes = (coordinateOffset.inMinutes - deviceOffset.inMinutes).abs();
    final effectiveOffset = diffMinutes <= 90 ? deviceOffset : coordinateOffset;

    final target = utc.add(effectiveOffset);
    return DateTime(
      target.year,
      target.month,
      target.day,
      target.hour,
      target.minute,
      target.second,
      target.millisecond,
    );
  }

  /// Formats the date according to the RouteX header requirement:
  /// E.g. "Sunday, 11 October" or localized equivalent.
  static String formatDate(DateTime dateTime, {String? locale}) {
    try {
      return DateFormat('EEEE, d MMMM', locale).format(dateTime);
    } catch (_) {
      // Fallback in case of an unsupported/missing locale table
      return DateFormat('EEEE, d MMMM').format(dateTime);
    }
  }

  /// Convenience method combining location timezone calculation and header date formatting.
  static String formatHeaderDate({
    UserLocation? location,
    DateTime? referenceUtc,
    String? locale,
  }) {
    final localTime = getLocalDateTime(
      location: location,
      referenceUtc: referenceUtc,
    );
    return formatDate(localTime, locale: locale);
  }
}
