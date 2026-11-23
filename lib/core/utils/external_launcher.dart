import 'package:url_launcher/url_launcher.dart';

/// Opens the phone, messaging and maps apps outside RouteX.
///
/// Every call is safe to fire from a button: a missing number, a device
/// without the target app or a launch error ends in `false`, never in an
/// exception. Callers may show their own message when it returns `false`.
abstract final class ExternalLauncher {
  const ExternalLauncher._();

  /// Opens the dialer with [phone] filled in.
  static Future<bool> call(String? phone) => _launch(_phoneUri('tel', phone));

  /// Opens the messaging app with a new message to [phone].
  static Future<bool> sms(String? phone) => _launch(_phoneUri('sms', phone));

  /// Opens Google Maps navigation to a destination. Coordinates win over the
  /// address when both are known (they are exact); with neither, returns
  /// `false`. The link opens the Google Maps app when installed and the
  /// browser version otherwise, and is free: no API key or billing is used.
  static Future<bool> googleMaps(
    String? destination, {
    double? latitude,
    double? longitude,
  }) {
    final hasCoordinates =
        latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        !(latitude == 0 && longitude == 0);
    final text = hasCoordinates
        ? '$latitude,$longitude'
        : (destination?.trim() ?? '');
    if (text.isEmpty) return Future.value(false);
    return _launch(
      Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': text,
        'travelmode': 'driving',
      }),
    );
  }

  /// Opens a web page in the browser.
  static Future<bool> web(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return Future.value(false);
    return _launch(uri);
  }

  static Uri? _phoneUri(String scheme, String? phone) {
    final cleaned = phone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '';
    if (cleaned.isEmpty) return null;
    return Uri(scheme: scheme, path: cleaned);
  }

  static Future<bool> _launch(Uri? uri) async {
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
