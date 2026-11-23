// lib/features/home/presentation/bloc/find_fleet_state.dart
// Convention: events, states and the bloc live in separate files, all exported
// through find_fleet_bloc.dart.
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_filter.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_summary.dart';

/// Status of the Find a Fleet screen's data.
enum FindFleetStatus {
  /// Nothing requested yet — the first frame after [FindFleetPage] is built.
  initial,

  /// First load in flight and no fleets to show yet.
  loading,

  /// Fleets are on screen (may be empty after filtering).
  success,

  /// No fleets could be loaded and [FindFleetState.errorMessage] is set.
  failure,
}

/// Immutable state held by [FindFleetBloc].
class FindFleetState extends Equatable {
  const FindFleetState({
    this.status = FindFleetStatus.initial,
    this.fleets = const [],
    this.availableFilters = const [],
    // Nearby, not All: the design opens the screen on the chip that answers
    // "what can I join right now", and a driver on this screen is looking for
    // fleets close enough to drive for.
    this.selectedFilter = FleetFilter.nearby,
    this.query = '',
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Current stage of the load.
  final FindFleetStatus status;

  /// Fleets matching the current filter and query.
  final List<FleetSummary> fleets;

  /// Filters the data source reports as available.
  final List<FleetFilter> availableFilters;

  /// Currently selected filter chip.
  final FleetFilter selectedFilter;

  /// Current search query.
  final String query;

  /// A refresh is in flight while content remains on screen.
  final bool isRefreshing;

  /// A mutating action (Join) is in flight.
  final bool isSubmitting;

  /// Non-null only when [status] is [FindFleetStatus.failure] or an action
  /// failed while content was already on screen.
  final String? errorMessage;

  /// Whether the list is empty after a successful load.
  bool get isEmpty => status == FindFleetStatus.success && fleets.isEmpty;

  /// How many of the listed fleets a join request can actually be sent to.
  ///
  /// Deliberately not [fleets.length]. The design's default frame lists five
  /// cards and still reads "4 results": the count answers "how many can I join",
  /// while the list answers "what is around me". A paused fleet is shown so the
  /// driver knows it exists, and is excluded from the count so the number never
  /// promises something the screen cannot deliver.
  int get joinableCount => fleets.where((fleet) => fleet.canJoin).length;

  /// [errorMessage] is deliberately not copied forward: it only ever describes
  /// the state being replaced, and silently carrying a stale message through a
  /// successful reload would put an error on screen with nothing wrong.
  FindFleetState copyWith({
    FindFleetStatus? status,
    List<FleetSummary>? fleets,
    List<FleetFilter>? availableFilters,
    FleetFilter? selectedFilter,
    String? query,
    bool? isRefreshing,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return FindFleetState(
      status: status ?? this.status,
      fleets: fleets ?? this.fleets,
      availableFilters: availableFilters ?? this.availableFilters,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      query: query ?? this.query,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    fleets,
    availableFilters,
    selectedFilter,
    query,
    isRefreshing,
    isSubmitting,
    errorMessage,
  ];
}
