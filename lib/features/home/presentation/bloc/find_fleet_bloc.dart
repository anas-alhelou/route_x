// lib/features/home/presentation/bloc/find_fleet_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_available_filters_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_fleets_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/join_find_fleet_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/find_fleet_event.dart';
import 'package:routex_mobile/features/home/presentation/bloc/find_fleet_state.dart';

export 'find_fleet_event.dart';
export 'find_fleet_state.dart';

/// Owns the Find a Fleet screen (Figma 5237:3435).
///
/// One bloc for the whole screen: the search query, the selected filter chip
/// and the fleet list describe a single filtered view. Splitting them would
/// mean three sources of truth for one list.
///
/// Search and filter changes reload the list through the same [_load] path as
/// the initial load, so the list always reflects the current query + filter
/// without the UI having to keep them in sync by hand.
class FindFleetBloc extends Bloc<FindFleetEvent, FindFleetState> {
  FindFleetBloc({
    required GetFleetsUseCase getFleets,
    required GetAvailableFiltersUseCase getAvailableFilters,
    required JoinFindFleetUseCase joinFindFleet,
  }) : _getFleets = getFleets,
       _getAvailableFilters = getAvailableFilters,
       _joinFindFleet = joinFindFleet,
       super(const FindFleetState()) {
    on<FindFleetStarted>(_onStarted);
    on<FindFleetRefreshed>(_onRefreshed);
    on<FindFleetQueryChanged>(_onQueryChanged);
    on<FindFleetFilterSelected>(_onFilterSelected);
    on<FindFleetJoinRequested>(_onJoinRequested);
    on<FindFleetErrorDismissed>(_onErrorDismissed);
  }

  final GetFleetsUseCase _getFleets;
  final GetAvailableFiltersUseCase _getAvailableFilters;
  final JoinFindFleetUseCase _joinFindFleet;

  Future<void> _onStarted(
    FindFleetStarted event,
    Emitter<FindFleetState> emit,
  ) async {
    emit(state.copyWith(status: FindFleetStatus.loading));
    await _loadFilters(emit);
    await _load(emit);
  }

  Future<void> _onRefreshed(
    FindFleetRefreshed event,
    Emitter<FindFleetState> emit,
  ) async {
    if (state.fleets.isEmpty && state.status != FindFleetStatus.success) {
      emit(state.copyWith(status: FindFleetStatus.loading));
      await _load(emit);
      return;
    }

    emit(state.copyWith(status: FindFleetStatus.success, isRefreshing: true));
    await _load(emit);
  }

  Future<void> _onQueryChanged(
    FindFleetQueryChanged event,
    Emitter<FindFleetState> emit,
  ) async {
    emit(state.copyWith(query: event.query, status: FindFleetStatus.loading));
    await _load(emit);
  }

  Future<void> _onFilterSelected(
    FindFleetFilterSelected event,
    Emitter<FindFleetState> emit,
  ) async {
    if (event.filter == state.selectedFilter) return;

    emit(
      state.copyWith(
        selectedFilter: event.filter,
        status: FindFleetStatus.loading,
      ),
    );
    await _load(emit);
  }

  Future<void> _onJoinRequested(
    FindFleetJoinRequested event,
    Emitter<FindFleetState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _joinFindFleet(
      JoinFindFleetParams(fleetId: event.fleetId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSubmitting: false, errorMessage: _message(failure)),
      ),
      (_) => emit(state.copyWith(isSubmitting: false)),
    );
  }

  void _onErrorDismissed(
    FindFleetErrorDismissed event,
    Emitter<FindFleetState> emit,
  ) {
    emit(
      state.copyWith(
        status: state.fleets.isEmpty
            ? FindFleetStatus.failure
            : FindFleetStatus.success,
      ),
    );
  }

  Future<void> _loadFilters(Emitter<FindFleetState> emit) async {
    final result = await _getAvailableFilters(const NoParams());
    result.fold(
      (_) => null,
      (filters) => emit(state.copyWith(availableFilters: filters)),
    );
  }

  Future<void> _load(Emitter<FindFleetState> emit) async {
    final result = await _getFleets(
      GetFleetsParams(filter: state.selectedFilter, query: state.query),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: state.fleets.isEmpty
              ? FindFleetStatus.failure
              : FindFleetStatus.success,
          isRefreshing: false,
          isSubmitting: false,
          errorMessage: _message(failure),
        ),
      ),
      (fleets) => emit(
        state.copyWith(
          status: FindFleetStatus.success,
          fleets: fleets,
          isRefreshing: false,
          isSubmitting: false,
        ),
      ),
    );
  }

  /// The failure's message *is* the localization key: the data layer has no
  /// `BuildContext`, so it names the condition (`err*`) and the UI resolves it
  /// through `translateValidationKey` at the point of display.
  String _message(Failure failure) => failure.message;
}
