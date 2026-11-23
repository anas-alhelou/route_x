// lib/features/home/data/stores/in_memory_fleet_request_store.dart
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/repositories/fleet_request_store.dart';

/// Process-lifetime [FleetRequestStore] backed by a single field.
///
/// Registered as a lazy singleton, and that registration is the entire point of
/// the class: Home and Enter Fleet Code must be looking at the *same* request, so
/// a code entered on one screen is still pending when the driver returns to the
/// dashboard. Two instances would be two independent truths and the bug this
/// store was introduced to remove would come straight back.
///
/// Nothing is persisted. The feature has no backend yet, and a full restart
/// should return the driver to the seeded first-run state rather than to a
/// half-finished join request from a previous session — which is also what makes
/// the Go Online debug transitions safe to use while reviewing the design.
class InMemoryFleetRequestStore implements FleetRequestStore {
  FleetRequest? _current;

  @override
  FleetRequest? get current => _current;

  @override
  Future<FleetRequest> save(FleetRequest request) async {
    _current = request;
    return request;
  }

  @override
  Future<void> clear() async {
    _current = null;
  }
}
