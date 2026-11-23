// lib/features/home/domain/value_objects/fleet_code.dart

/// The rules that make a fleet code a fleet code.
///
/// This is a value object with no state: it exists so the one place that
/// decides what a well-formed code is can be *named* and read once, instead of
/// being restated as a `6` and a `[^a-zA-Z0-9]` in the input row, the paste
/// handler, the BLoC and the local data source — where the four copies had
/// already drifted (the widget clamped to six while the BLoC sanitized but the
/// data source only trimmed).
///
/// It sits in `domain` because the rules are domain rules, not input-widget
/// rules: the mock fleet's code is alphanumeric, case-insensitive and exactly
/// six characters long, and that is true whether the code arrives by keyboard,
/// by clipboard, or from a deep link in a future release.
abstract final class FleetCode {
  const FleetCode._();

  /// How many boxes the design draws, and therefore how many characters a code
  /// has. The Enter Fleet Code screen is laid out around this number, so it is a
  /// format rule rather than a widget constant.
  static const int length = 6;

  /// The only code the mock backend accepts: it maps to the seeded Red Sea
  /// Express fleet.
  ///
  /// Lives here rather than on the data source so the UI, its tests and the data
  /// layer all read the same literal instead of each hard-coding `RSX482`.
  static const String validCode = 'RSX482';

  /// Anything that is not a letter or a digit — spaces, hyphens, the dashes a
  /// driver adds when reading a code aloud, emoji pasted by accident.
  static final RegExp _nonAlphanumeric = RegExp(r'[^a-zA-Z0-9]');

  /// Reduces arbitrary user input to the canonical form the rest of the feature
  /// compares against: uppercase, alphanumeric only, and never longer than
  /// [length].
  ///
  /// Order matters. Filtering first would otherwise let a very long string of
  /// junk survive as junk; clamping last means the truncation is applied to
  /// *valid* characters, so `"rs-x482999"` yields `"RSX482"` rather than a
  /// value cut off mid-word at an arbitrary position.
  ///
  /// Safe to call on input that is already normalized — it is idempotent — so
  /// callers do not have to know whether a value has been through it yet.
  static String normalize(String raw) {
    final sanitized = raw.replaceAll(_nonAlphanumeric, '').toUpperCase();
    return sanitized.length > length
        ? sanitized.substring(0, length)
        : sanitized;
  }

  /// Whether [raw] is a complete, correctly formatted code.
  ///
  /// Length alone is not enough: the same check guards the Join button, so a
  /// five-character code must not enable it.
  static bool isComplete(String raw) => raw.length == length;

  /// Whether [raw] is the code the mock backend accepts.
  ///
  /// Normalizing first means a driver who types the code in lower case, or
  /// pastes it with a stray space, is not rejected for the wrong reason.
  static bool isValid(String raw) => normalize(raw) == validCode;
}
