import 'dart:async';

import 'package:routex_mobile/core/network/network_info.dart';

/// A network the test flips on and off. Starts connected unless told not to.
class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({bool connected = true}) : _connected = connected;

  bool _connected;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  bool get connected => _connected;

  /// Changes the link and notifies listeners, like the OS would.
  set connected(bool value) {
    if (value == _connected) return;
    _connected = value;
    _changes.add(value);
  }

  /// Changes the link *without* an event — the case Try again exists for,
  /// where the OS never reports that coverage came back.
  void setSilently(bool value) => _connected = value;

  @override
  Future<bool> get isConnected async => _connected;

  @override
  Stream<bool> get onStatusChange => _changes.stream;

  Future<void> dispose() => _changes.close();
}
