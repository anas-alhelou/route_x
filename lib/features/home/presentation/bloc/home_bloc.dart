import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_availability.dart';
import 'package:routex_mobile/features/home/domain/entities/fleet_request.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_debug_repository.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_home_overview_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/join_fleet_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/set_online_status_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:routex_mobile/features/home/presentation/bloc/home_state.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_sheet.dart';

export 'home_event.dart';
export 'home_state.dart';

/// Owns the Home dashboard.
///
/// One bloc for the whole screen rather than one per section: the stats, the
/// setup checklist and the nearby-fleet list describe a single moment for a
/// single driver, and joining a fleet updates the checklist, the switch lock
/// and the list at once. Splitting them would mean three sources of truth for
/// one snapshot.
///
/// Actions that fail leave the previous content on screen and surface the
/// failure through the existing error dialog; they never fall back to
/// [HomeStatus.failure], which would throw away data the driver can already
/// read just because a switch flip did not save.
/// Depends only on use cases and on [HomeDebugRepository] — no data source, no
/// `getIt`, no `BuildContext`. It previously called
/// `getIt<HomeLocalDataSource>()` from its debug handler, which put a service
/// locator and an inward-pointing import in the same line.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetHomeOverviewUseCase getHomeOverview,
    required SetOnlineStatusUseCase setOnlineStatus,
    required JoinFleetUseCase joinFleet,
    required HomeDebugRepository debugRepository,
  }) : _getHomeOverview = getHomeOverview,
       _setOnlineStatus = setOnlineStatus,
       _joinFleet = joinFleet,
       _debugRepository = debugRepository,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeOnlineToggled>(_onOnlineToggled);
    on<HomeOnlineBlockedTapped>(_onOnlineBlockedTapped);
    on<HomeBlockedReasonDismissed>(_onBlockedReasonDismissed);
    on<HomeDebugRequestStatusChanged>(_onDebugRequestStatusChanged);
    on<HomeFleetJoinRequested>(_onFleetJoinRequested);
    on<HomeErrorDismissed>(_onErrorDismissed);
  }

  final GetHomeOverviewUseCase _getHomeOverview;
  final SetOnlineStatusUseCase _setOnlineStatus;
  final JoinFleetUseCase _joinFleet;
  final HomeDebugRepository _debugRepository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (state.overview != null) {
      // Re-entering Home from Find Fleet or Notifications. Refreshing quietly
      // rather than reloading keeps the previous snapshot on screen, so
      // returning to the tab does not flash a spinner.
      add(const HomeRefreshed());
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    if (state.overview == null) {
      emit(state.copyWith(status: HomeStatus.loading));
      await _load(emit);
      return;
    }

    emit(state.copyWith(status: HomeStatus.success, isRefreshing: true));
    await _load(emit);
  }

  Future<void> _load(Emitter<HomeState> emit) async {
    final result = await _getHomeOverview(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: state.overview == null
              ? HomeStatus.failure
              : HomeStatus.success,
          isRefreshing: false,
          isSubmitting: false,
          errorMessage: _message(failure),
        ),
      ),
      (overview) => emit(
        state.copyWith(
          status: HomeStatus.success,
          overview: overview,
          isRefreshing: false,
          isSubmitting: false,
        ),
      ),
    );
  }

  Future<void> _onOnlineToggled(
    HomeOnlineToggled event,
    Emitter<HomeState> emit,
  ) async {
    final overview = state.overview;
    if (overview == null || !overview.availability.canToggle) {
      // Locked switch: emit one-shot GoOnlineBlocked signal.
      final reqStatus =
          overview?.fleetRequest?.status ?? FleetRequestStatus.none;
      final reason = switch (reqStatus) {
        FleetRequestStatus.pending => GoOnlineBlockedReason.pending,
        FleetRequestStatus.declined => GoOnlineBlockedReason.declined,
        _ => GoOnlineBlockedReason.noFleet,
      };
      emit(state.copyWith(blockedReason: reason));
      return;
    }

    final result = await _setOnlineStatus(
      SetOnlineStatusParams(isOnline: event.isOnline),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: _message(failure))),
      (availability) => emit(
        state.copyWith(
          overview: _withAvailability(
            overview,
            availability.isOnline,
            availability.fleetId,
          ),
        ),
      ),
    );
  }

  void _onOnlineBlockedTapped(
    HomeOnlineBlockedTapped event,
    Emitter<HomeState> emit,
  ) {
    final overview = state.overview;
    final reqStatus = overview?.fleetRequest?.status ?? FleetRequestStatus.none;
    final reason = switch (reqStatus) {
      FleetRequestStatus.pending => GoOnlineBlockedReason.pending,
      FleetRequestStatus.declined => GoOnlineBlockedReason.declined,
      _ => GoOnlineBlockedReason.noFleet,
    };
    emit(state.copyWith(blockedReason: reason));
  }

  void _onBlockedReasonDismissed(
    HomeBlockedReasonDismissed event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(clearBlockedReason: true));
  }

  /// Moves the driver to the next request state so every Go Online frame can be
  /// reviewed without a backend.
  ///
  /// Gated on [kDebugMode] even though the UI that dispatches the event is gated
  /// too: the event is part of [HomeEvent]'s sealed hierarchy and therefore
  /// constructible from anywhere, so the check that actually protects a release
  /// build belongs here rather than only at the call site.
  Future<void> _onDebugRequestStatusChanged(
    HomeDebugRequestStatusChanged event,
    Emitter<HomeState> emit,
  ) async {
    if (!kDebugMode) return;

    await _debugRepository.resolveRequest(
      status: event.status,
      reason: event.reason,
    );
    await _load(emit);
  }

  Future<void> _onFleetJoinRequested(
    HomeFleetJoinRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.overview?.fleetRequest?.status == FleetRequestStatus.pending) {
      // Prevent double requests when already pending
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    final result = await _joinFleet(JoinFleetParams(fleetId: event.fleetId));

    result.fold(
      (failure) => emit(
        state.copyWith(isSubmitting: false, errorMessage: _message(failure)),
      ),
      (overview) => emit(
        state.copyWith(
          status: HomeStatus.success,
          overview: overview,
          isSubmitting: false,
        ),
      ),
    );
  }

  void _onErrorDismissed(HomeErrorDismissed event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        status: state.overview == null
            ? HomeStatus.failure
            : HomeStatus.success,
      ),
    );
  }

  /// Rebuilds the snapshot with a new availability, leaving the other parts
  /// untouched.
  HomeOverview _withAvailability(
    HomeOverview overview,
    bool isOnline,
    String? fleetId,
  ) {
    return HomeOverview(
      profile: overview.profile,
      availability: DriverAvailability(
        isOnline: isOnline,
        fleetId: fleetId,
        requestStatus: overview.fleetRequest?.status ?? FleetRequestStatus.none,
      ),
      stats: overview.stats,
      setup: overview.setup,
      nearbyFleets: overview.nearbyFleets,
      fleetRequest: overview.fleetRequest,
    );
  }

  /// The failure's message *is* the localization key — the data layer has no
  /// `BuildContext`, so it names the condition (`err*`) and the UI resolves it
  /// through `translateValidationKey` at the point of display.
  String _message(Failure failure) => failure.message;
}
