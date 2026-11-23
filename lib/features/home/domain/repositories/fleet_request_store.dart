// lib/features/home/domain/repositories/fleet_request_store.dart
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';

/// The app's one record of the driver's current fleet-join request.
///
/// **Why this is its own abstraction.** Two features create requests: Home joins
/// a fleet from a list row, and Enter Fleet Code joins one from a code. When the
/// second wrote through the first's data source, "enter your code" was reaching
/// across into Home's storage to record what it had just learned — a dependency
/// pointing sideways between two unrelated user journeys, and one that made Home
/// a prerequisite for the Enter Code screen working at all.
///
/// Both now depend on this instead. It is deliberately narrower than a
/// repository: it stores and returns a [FleetRequest] and nothing else. There is
/// no `getOverview`, no `joinFleet`, no failure type — a caller that needs those
/// goes to [HomeRepository]. Narrow enough that mocking it in a test is one line.
///
/// Synchronous reads with asynchronous writes, deliberately: reading the current
/// request is a local field access and pretending it is I/O would force every
/// reader to await a value it already has.
abstract interface class FleetRequestStore {
  /// The request currently on record, or null if the driver has never asked to
  /// join a fleet (or has had the record withdrawn).
  FleetRequest? get current;

  /// Records [request] as the current one, replacing any previous request, and
  /// returns it.
  ///
  /// Returns the stored value rather than `void` so a caller can use what it just
  /// saved without reading it back.
  Future<FleetRequest> save(FleetRequest request);

  /// Forgets the current request, leaving the driver with no fleet membership.
  Future<void> clear();
}
