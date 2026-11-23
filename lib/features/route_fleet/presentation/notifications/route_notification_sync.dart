// lib/features/route_fleet/presentation/notifications/route_notification_sync.dart
import 'dart:async';

import 'package:routex_mobile/core/notifications/app_notification_payload.dart';
import 'package:routex_mobile/core/notifications/app_notification_service.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_cubit.dart';
import 'package:routex_mobile/features/route_fleet/presentation/controllers/route_fleet_state.dart';

/// Keeps the R35 "On a route" notification in step with the route.
///
/// It appears when the route starts driving, updates at every stop (title,
/// minutes, arrival time and the progress bar) and goes away when the route
/// ends or is left. While the driver is at a stop (arrived, taking the proof
/// photo, signing) the notification is left as it was.
class RouteNotificationSync {
  RouteNotificationSync(this._cubit, {AppNotificationService? service})
      : _service = service ?? AppNotificationService.instance {
    _subscription = _cubit.stream.listen(_onState);
    _onState(_cubit.state);
  }

  final RouteFleetCubit _cubit;
  final AppNotificationService _service;
  late final StreamSubscription<RouteFleetState> _subscription;

  String? _lastKey;

  void _onState(RouteFleetState state) {
    if (state is RouteFleetDriving) {
      final data = _dataFor(state);
      if (data == null) return;
      final key = '${data.stopNumber}/${data.totalStops}/'
          '${data.minutes}/${data.arriveAt}';
      if (key == _lastKey) return;
      _lastKey = key;
      unawaited(_service.showOngoingRoute(data));
      return;
    }

    // The driver is at a stop: the route is still running.
    if (state is RouteFleetArrived ||
        state is RouteFleetDelivered ||
        state is RouteFleetProofCamera ||
        state is RouteFleetProofCheckPhoto ||
        state is RouteFleetProofSignature) {
      return;
    }

    if (_lastKey != null) {
      _lastKey = null;
      unawaited(_service.cancelOngoingRoute());
    }
  }

  OngoingRouteNotificationData? _dataFor(RouteFleetDriving state) {
    final stops = state.fleetInfo.stops;
    final index = state.currentStopIndex;
    if (index < 0 || index >= stops.length) return null;
    final stop = stops[index];
    return OngoingRouteNotificationData(
      stopNumber: index + 1,
      totalStops: stops.length,
      customerName: stop.title,
      address: stop.address,
      minutes: state.remainingMinutes,
      arriveAt: state.arrivalTime,
    );
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    if (_lastKey != null) {
      _lastKey = null;
      await _service.cancelOngoingRoute();
    }
  }
}
