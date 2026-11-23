// lib/core/network/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the device has a network to try, and when that changes.
///
/// "Connected" means a Wi-Fi or mobile link exists, not that the server is
/// reachable over it: a weak signal still reports connected, and shows up
/// instead as a timeout — a `NetworkFailure` from the request itself.
/// Callers need both signals.
abstract class NetworkInfo {
  Future<bool> get isConnected;

  /// Emits only on an actual change, never the same value twice in a row.
  Stream<bool> get onStatusChange;
}

class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _hasLink(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<bool> get isConnected async =>
      _hasLink(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_hasLink).distinct();
}
