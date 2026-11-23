// lib/features/route_fleet/domain/services/route_flow_engine.dart
import '../entities/route_stop.dart';
import '../entities/stop_status.dart';
import '../entities/proof_of_delivery.dart';
import '../utils/route_fleet_utils.dart';

enum RouteFlowPhase { ready, driving, approaching, arrived, delivering, deliveredToast, leftUnmarked, onBreak, complete }

class RouteFlowEngine {
  RouteFlowEngine({required List<RouteStop> stops})
      : _stops = List.from(stops),
        _currentIndex = 0,
        _phase = RouteFlowPhase.ready,
        _stopStatuses = {
          for (int i = 0; i < stops.length; i++)
            stops[i].id: i == 0 ? StopDeliveryStatus.current : StopDeliveryStatus.upcoming
        };

  final List<RouteStop> _stops;
  int _currentIndex;
  RouteFlowPhase _phase;
  final Map<String, StopDeliveryStatus> _stopStatuses;
  final Map<String, ProofOfDeliveryData> _proofs = {};
  final Map<String, String> _failureReasons = {};
  
  // History stack for undoLast (snapshots recorded only before user actions)
  final List<_EngineStateSnapshot> _history = [];

  List<RouteStop> get stops => List.unmodifiable(_stops);
  int get currentIndex => _currentIndex;
  RouteFlowPhase get phase => _phase;
  Map<String, StopDeliveryStatus> get stopStatuses => Map.unmodifiable(_stopStatuses);
  Map<String, ProofOfDeliveryData> get proofs => Map.unmodifiable(_proofs);
  Map<String, String> get failureReasons => Map.unmodifiable(_failureReasons);

  /// User Action: Slide/press to start route
  void startRoute() {
    _saveSnapshot();
    _phase = RouteFlowPhase.driving;
    _updateStatuses();
  }

  /// Automated/internal step: driver approaching stop
  void approach() {
    if (_phase == RouteFlowPhase.driving) {
      _phase = RouteFlowPhase.approaching;
      _updateStatuses();
    }
  }

  /// Automated/internal step: driver arrived at stop
  void arrive() {
    if (_phase == RouteFlowPhase.driving || _phase == RouteFlowPhase.approaching || _phase == RouteFlowPhase.leftUnmarked) {
      _phase = RouteFlowPhase.arrived;
      _updateStatuses();
    }
  }

  /// System step: driver left stop without marking
  void markLeftUnmarked() {
    if (_phase == RouteFlowPhase.arrived) {
      _phase = RouteFlowPhase.leftUnmarked;
    }
  }

  /// User action: Go back to arrived from leftUnmarked
  void returnToArrived() {
    if (_phase == RouteFlowPhase.leftUnmarked) {
      _phase = RouteFlowPhase.arrived;
    }
  }

  /// User/System Action: Reorder stop to end of route (R29/R30)
  void moveStopToEnd(int stopIndex) {
    _saveSnapshot();
    if (stopIndex < 0 || stopIndex >= _stops.length) return;
    final moved = _stops.removeAt(stopIndex);
    _stops.add(moved);

    _currentIndex = RouteFleetUtils.currentIndexAfterMoveToEnd(
      currentIndex: _currentIndex,
      movedIndex: stopIndex,
      stopCount: _stops.length,
    );

    if (_phase == RouteFlowPhase.arrived || _phase == RouteFlowPhase.approaching || _phase == RouteFlowPhase.leftUnmarked) {
      _phase = RouteFlowPhase.driving;
    }
    _updateStatuses();
  }

  bool get isOnBreak => _isOnBreak;
  DateTime? get breakStartTime => _breakStartTime;
  int get allowedBreakMinutes => _allowedBreakMinutes;

  bool _isOnBreak = false;
  DateTime? _breakStartTime;
  int _allowedBreakMinutes = 15;

  void startBreak() {
    if (_phase == RouteFlowPhase.driving || _phase == RouteFlowPhase.approaching) {
      _saveSnapshot();
      _phase = RouteFlowPhase.onBreak;
      _isOnBreak = true;
      _breakStartTime ??= DateTime.now();
    }
  }

  void extendBreak(int minutes) {
    _allowedBreakMinutes += minutes;
  }

  void resumeBreak() {
    if (_phase == RouteFlowPhase.onBreak) {
      _saveSnapshot();
      _phase = RouteFlowPhase.driving;
      _isOnBreak = false;
    }
  }

  /// Automated/internal step: open proof flow
  void startDelivery() {
    if (_phase == RouteFlowPhase.arrived) {
      _phase = RouteFlowPhase.delivering;
    }
  }

  /// User Action: Complete delivery with proof
  void completeDelivery(ProofOfDeliveryData proof) {
    _saveSnapshot();
    if (_currentIndex < _stops.length) {
      final stopId = _stops[_currentIndex].id;
      _proofs[stopId] = proof;
      _stopStatuses[stopId] = StopDeliveryStatus.delivered;
    }

    if (_currentIndex >= _stops.length - 1) {
      _phase = RouteFlowPhase.complete;
    } else if (_currentIndex >= _stops.length - 2) {
      // Next stop is the last stop: go straight to driving the last stop (R17, no toast)
      _currentIndex++;
      _phase = RouteFlowPhase.driving;
      _updateStatuses();
    } else {
      // Show R13 toast
      _phase = RouteFlowPhase.deliveredToast;
    }
  }

  /// Timer/Button step: Toast countdown finishes or user taps next
  void advanceToNextStop() {
    if (_phase == RouteFlowPhase.deliveredToast) {
      if (_currentIndex < _stops.length - 1) {
        _currentIndex++;
        _phase = RouteFlowPhase.driving;
        _updateStatuses();
      } else {
        _phase = RouteFlowPhase.complete;
      }
    }
  }

  /// User Action: Fail stop with reason
  void failStop(String reasonCode, String reasonText) {
    _saveSnapshot();
    if (_currentIndex < _stops.length) {
      final stopId = _stops[_currentIndex].id;
      _stopStatuses[stopId] = StopDeliveryStatus.failed;
      _failureReasons[stopId] = reasonText;
    }

    if (_currentIndex >= _stops.length - 1) {
      _phase = RouteFlowPhase.complete;
    } else {
      _currentIndex++;
      _phase = RouteFlowPhase.driving;
      _updateStatuses();
    }
  }

  /// User Action: End route early (remaining non-delivered stops are marked as failed/returned)
  void endRoute({
    String reasonCode = 'returned_by_end_route',
    String reasonText = 'Returned by end route',
  }) {
    _saveSnapshot();
    for (int i = 0; i < _stops.length; i++) {
      final id = _stops[i].id;
      if (_stopStatuses[id] != StopDeliveryStatus.delivered &&
          _stopStatuses[id] != StopDeliveryStatus.failed) {
        _stopStatuses[id] = StopDeliveryStatus.failed;
        _failureReasons[id] = reasonText;
      }
    }
    _phase = RouteFlowPhase.complete;
  }

  /// User Action: Undo last user action (delivery, failure, or end route)
  bool undoLast() {
    if (_history.isEmpty) return false;
    final snapshot = _history.removeLast();
    _currentIndex = snapshot.currentIndex;
    _phase = snapshot.phase;
    _stops.clear();
    _stops.addAll(snapshot.stops);
    _stopStatuses.clear();
    _stopStatuses.addAll(snapshot.stopStatuses);
    _proofs.clear();
    _proofs.addAll(snapshot.proofs);
    _failureReasons.clear();
    _failureReasons.addAll(snapshot.failureReasons);
    return true;
  }

  void _updateStatuses() {
    for (int i = 0; i < _stops.length; i++) {
      final id = _stops[i].id;
      if (_stopStatuses[id] == StopDeliveryStatus.delivered ||
          _stopStatuses[id] == StopDeliveryStatus.failed) {
        continue;
      }
      if (i == _currentIndex) {
        _stopStatuses[id] = StopDeliveryStatus.current;
      } else if (i > _currentIndex) {
        _stopStatuses[id] = StopDeliveryStatus.upcoming;
      }
    }
  }

  void _saveSnapshot() {
    _history.add(_EngineStateSnapshot(
      currentIndex: _currentIndex,
      phase: _phase,
      stopStatuses: Map.from(_stopStatuses),
      proofs: Map.from(_proofs),
      failureReasons: Map.from(_failureReasons),
      stops: List.from(_stops),
    ));
  }
}

class _EngineStateSnapshot {
  _EngineStateSnapshot({
    required this.currentIndex,
    required this.phase,
    required this.stopStatuses,
    required this.proofs,
    required this.failureReasons,
    required this.stops,
  });

  final int currentIndex;
  final RouteFlowPhase phase;
  final Map<String, StopDeliveryStatus> stopStatuses;
  final Map<String, ProofOfDeliveryData> proofs;
  final Map<String, String> failureReasons;
  final List<RouteStop> stops;
}

// ── Arrival Detection Interface & TEMP Simulation ────────────────────────────

abstract class ArrivalSource {
  Stream<ArrivalEvent> get arrivalStream;
}

enum ArrivalEventType { approaching, arrived, autoDetectArriving, leftWithoutMarking }

class ArrivalEvent {
  const ArrivalEvent(this.type);
  final ArrivalEventType type;
}

// TEMP: Simulated arrival detection timer
class SimulatedArrivalSource implements ArrivalSource {
  SimulatedArrivalSource({
    this.approachDelay = const Duration(milliseconds: 2500),
    this.arrivalDelay = const Duration(milliseconds: 5000),
    this.emitAutoDetect = false,
    this.emitLeftUnmarked = false,
  });

  final Duration approachDelay;
  final Duration arrivalDelay;
  final bool emitAutoDetect;
  final bool emitLeftUnmarked;
  
  @override
  Stream<ArrivalEvent> get arrivalStream async* {
    if (emitAutoDetect) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield const ArrivalEvent(ArrivalEventType.autoDetectArriving);
      return;
    }
    await Future.delayed(approachDelay);
    yield const ArrivalEvent(ArrivalEventType.approaching);
    await Future.delayed(arrivalDelay - approachDelay);
    if (emitLeftUnmarked) {
      yield const ArrivalEvent(ArrivalEventType.arrived);
      await Future.delayed(const Duration(milliseconds: 1000));
      yield const ArrivalEvent(ArrivalEventType.leftWithoutMarking);
    } else {
      yield const ArrivalEvent(ArrivalEventType.arrived);
    }
  }
}
