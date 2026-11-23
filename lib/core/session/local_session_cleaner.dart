import 'package:shared_preferences/shared_preferences.dart';
import 'package:routex_mobile/core/di/injection.dart';
import 'package:routex_mobile/features/orders/data/proof_upload_queue.dart';

/// Removes what the app keeps on the device for the signed-in driver, so the
/// next person to sign in on the same phone starts clean: the delivery photos
/// waiting to upload, the saved device preferences and the join-request time.
///
/// Called on an explicit sign-out. It is not called when a session merely
/// expires, because the same driver signs back in and their waiting proofs
/// must still be sent.
abstract final class LocalSessionCleaner {
  static const List<String> _keys = [
    'settings.device_preferences',
    'join_company.sent_at',
  ];

  static Future<void> clear() async {
    try {
      if (getIt.isRegistered<ProofUploadQueue>()) {
        await getIt<ProofUploadQueue>().clear();
      }
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in _keys) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }
}
