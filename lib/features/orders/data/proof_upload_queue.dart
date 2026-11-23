import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'datasources/driver_orders_remote_data_source.dart';

/// Delivery photos that could not be uploaded yet.
///
/// A driver often delivers where the signal is weak. [submit] tries the upload
/// twice right away; if both fail the photo is saved here (it survives an app
/// restart) and sent again every minute and whenever [resume] is called, until
/// it goes through. A photo whose file no longer exists, or that failed
/// [maxAttempts] times, is dropped so the queue cannot grow forever.
class ProofUploadQueue {
  ProofUploadQueue({
    required DriverOrdersRemoteDataSource orders,
    required SharedPreferences preferences,
    this.retryEvery = const Duration(minutes: 1),
    this.maxAttempts = 30,
  }) : _orders = orders,
       _prefs = preferences;

  static const String _key = 'proof_upload_queue';

  final DriverOrdersRemoteDataSource _orders;
  final SharedPreferences _prefs;
  final Duration retryEvery;
  final int maxAttempts;

  Timer? _timer;
  bool _flushing = false;

  /// Number of photos still waiting.
  int get pending => _read().length;

  /// Uploads now (two tries); on failure the photo waits in the queue.
  Future<void> submit(String orderId, String photoPath) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await _orders.deliver(orderId, photoPath);
        return;
      } catch (_) {}
    }
    final items = _read()..removeWhere((e) => e['orderId'] == orderId);
    items.add(<String, dynamic>{
      'orderId': orderId,
      'path': photoPath,
      'attempts': 2,
    });
    await _write(items);
    _ensureTimer();
  }

  /// Sends what is waiting. Safe to call at any time.
  Future<void> resume() async {
    if (_read().isEmpty) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _ensureTimer();
    await flush();
  }

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final remaining = <Map<String, dynamic>>[];
      for (final item in _read()) {
        final path = item['path'] as String? ?? '';
        final orderId = item['orderId'] as String? ?? '';
        final attempts = (item['attempts'] as num?)?.toInt() ?? 0;
        if (orderId.isEmpty || path.isEmpty || !File(path).existsSync()) {
          continue; // nothing left to send
        }
        try {
          await _orders.deliver(orderId, path);
        } catch (_) {
          if (attempts + 1 < maxAttempts) {
            remaining.add(<String, dynamic>{...item, 'attempts': attempts + 1});
          }
        }
      }
      await _write(remaining);
      if (remaining.isEmpty) {
        _timer?.cancel();
        _timer = null;
      }
    } finally {
      _flushing = false;
    }
  }

  /// Forgets everything that is waiting and deletes the saved photos. Called on
  /// sign-out so the next driver on the device never sends, or sees, the
  /// previous driver's proofs.
  Future<void> clear() async {
    _timer?.cancel();
    _timer = null;
    for (final item in _read()) {
      final path = item['path'] as String? ?? '';
      if (path.isEmpty) continue;
      try {
        final file = File(path);
        if (file.existsSync()) await file.delete();
      } catch (_) {}
    }
    await _prefs.remove(_key);
  }

  void _ensureTimer() {
    _timer ??= Timer.periodic(retryEvery, (_) => unawaited(flush()));
  }

  List<Map<String, dynamic>> _read() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return [
        for (final e in decoded)
          if (e is Map) Map<String, dynamic>.from(e),
      ];
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _write(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, jsonEncode(items));
    }
  }
}
