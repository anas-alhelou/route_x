// lib/features/home/presentation/bloc/delivery_dashboard_bloc.dart
import 'dart:async';
import 'package:dartz/dartz.dart' show Either;
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/services/location/location_service.dart';
import 'package:routex_mobile/core/services/location/timezone_date_formatter.dart';
import 'package:routex_mobile/core/services/location/user_location.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/domain/usecases/get_delivery_dashboard_usecase.dart';
import 'package:routex_mobile/features/home/domain/usecases/switch_delivery_scenario_usecase.dart';
import 'package:routex_mobile/features/home/presentation/bloc/delivery_dashboard_event.dart';
import 'package:routex_mobile/features/home/presentation/bloc/delivery_dashboard_state.dart';

export 'delivery_dashboard_event.dart';
export 'delivery_dashboard_state.dart';

/// The delivery dashboard BLoC.
///
/// Owns the Home target screens (HM2 on-route, HM3 all caught up,
/// HM5 first day, HM6 no orders today) and delegates data retrieval to
/// domain use cases with zero remote network calls.
class DeliveryDashboardBloc
    extends Bloc<DeliveryDashboardEvent, DeliveryDashboardState> {
  DeliveryDashboardBloc({
    required this.getDeliveryDashboard,
    required this.switchDeliveryScenario,
    this.locationService,
  }) : super(const DeliveryDashboardState()) {
    on<DeliveryDashboardInitialized>(_onInitialized);
    on<DeliveryDashboardRefreshed>(_onRefreshed);
    on<DeliveryDashboardScenarioChanged>(_onScenarioChanged);
    on<DeliveryDashboardScenarioCycled>(_onScenarioCycled);
    on<DeliveryDashboardLocationUpdated>(_onLocationUpdated);
  }

  final GetDeliveryDashboardUseCase getDeliveryDashboard;
  final SwitchDeliveryScenarioUseCase switchDeliveryScenario;
  final LocationService? locationService;

  StreamSubscription<UserLocation>? _locationSubscription;

  /// Target scenarios matching Figma nodes:
  /// - HM2: [DeliveryScenario.onRoute] (Node 6410:56040)
  /// - HM3: [DeliveryScenario.allCaughtUp] (Node 6410:56180)
  /// - HM4: [DeliveryScenario.offline] (Node 6410:56444)
  /// - HM5: [DeliveryScenario.firstDay] (Node 6410:56288)
  /// - HM6: [DeliveryScenario.noOrdersToday] (Node 6410:56236)
  /// - HM8: [DeliveryScenario.newOrderFirstDay] (Node 6410:56525)
  /// - HM9: [DeliveryScenario.newOrderOnRoute] (Node 6410:56105)
  static const List<DeliveryScenario> _targetScenarios = [
    DeliveryScenario.onRoute,
    DeliveryScenario.allCaughtUp,
    DeliveryScenario.offline,
    DeliveryScenario.firstDay,
    DeliveryScenario.noOrdersToday,
    DeliveryScenario.newOrderFirstDay,
    DeliveryScenario.newOrderOnRoute,
  ];

  int _scenarioIndex = 0;

  Future<void> _onInitialized(
    DeliveryDashboardInitialized event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    emit(const DeliveryDashboardState(status: DeliveryDashboardStatus.loading));
    // Never leave the skeleton up for good: a stalled request or an
    // unexpected error ends in the failure view, which has a Retry button.
    final Either<Failure, DeliveryDashboard> result;
    try {
      result = await getDeliveryDashboard(
        scenario: event.initialScenario,
      ).timeout(const Duration(seconds: 25));
    } on TimeoutException {
      emit(state.copyWith(
        status: DeliveryDashboardStatus.failure,
        errorMessage: 'The dashboard took too long to load.',
      ));
      return;
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryDashboardStatus.failure,
        errorMessage: '$e',
      ));
      return;
    }
    await result.fold(
      (failure) async => emit(state.copyWith(
        status: DeliveryDashboardStatus.failure,
        errorMessage: failure.message,
      )),
      (dashboard) async {
        if (event.initialScenario != null) {
          final idx = _targetScenarios.indexOf(event.initialScenario!);
          if (idx != -1) _scenarioIndex = idx;
        } else {
          final idx = _targetScenarios.indexOf(dashboard.scenario);
          if (idx != -1) _scenarioIndex = idx;
        }

        var updatedDashboard = dashboard;
        if (locationService != null) {
          try {
            final loc = await Future<UserLocation?>.value(
              locationService!.getCurrentLocation(),
            ).timeout(const Duration(seconds: 4), onTimeout: () => null);
            if (loc != null) {
              final formatted =
                  TimezoneDateFormatter.formatHeaderDate(location: loc);
              updatedDashboard = updatedDashboard.copyWith(
                dateLabel: formatted,
                userLocation: loc,
              );
            } else {
              final formatted = TimezoneDateFormatter.formatHeaderDate();
              updatedDashboard =
                  updatedDashboard.copyWith(dateLabel: formatted);
            }
          } catch (_) {
            final formatted = TimezoneDateFormatter.formatHeaderDate();
            updatedDashboard = updatedDashboard.copyWith(dateLabel: formatted);
          }

          _listenToLocationUpdates();
        } else {
          final formatted = TimezoneDateFormatter.formatHeaderDate();
          updatedDashboard = updatedDashboard.copyWith(dateLabel: formatted);
        }

        emit(state.copyWith(
          status: DeliveryDashboardStatus.success,
          dashboard: updatedDashboard,
          isRefreshing: false,
        ));
      },
    );
  }

  void _onLocationUpdated(
    DeliveryDashboardLocationUpdated event,
    Emitter<DeliveryDashboardState> emit,
  ) {
    if (state.dashboard == null) return;
    final formatted =
        TimezoneDateFormatter.formatHeaderDate(location: event.location);
    emit(state.copyWith(
      dashboard: state.dashboard!.copyWith(
        dateLabel: formatted,
        userLocation: event.location,
      ),
    ));
  }

  Future<void> _onRefreshed(
    DeliveryDashboardRefreshed event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    final result =
        await getDeliveryDashboard(scenario: state.dashboard?.scenario);
    await result.fold(
      (failure) async => emit(state.copyWith(isRefreshing: false)),
      (dashboard) async {
        var updatedDashboard = dashboard;
        if (locationService != null) {
          try {
            final loc =
                await locationService!.getCurrentLocation(forceRefresh: true);
            if (loc != null) {
              final formatted =
                  TimezoneDateFormatter.formatHeaderDate(location: loc);
              updatedDashboard = updatedDashboard.copyWith(
                dateLabel: formatted,
                userLocation: loc,
              );
            } else {
              final formatted = TimezoneDateFormatter.formatHeaderDate();
              updatedDashboard =
                  updatedDashboard.copyWith(dateLabel: formatted);
            }
          } catch (_) {
            final formatted = TimezoneDateFormatter.formatHeaderDate();
            updatedDashboard = updatedDashboard.copyWith(dateLabel: formatted);
          }
        } else {
          final formatted = TimezoneDateFormatter.formatHeaderDate();
          updatedDashboard = updatedDashboard.copyWith(dateLabel: formatted);
        }

        emit(state.copyWith(
          status: DeliveryDashboardStatus.success,
          dashboard: updatedDashboard,
          isRefreshing: false,
        ));
      },
    );
  }

  Future<void> _onScenarioChanged(
    DeliveryDashboardScenarioChanged event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    final result = await switchDeliveryScenario(event.scenario);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (dashboard) {
        final idx = _targetScenarios.indexOf(event.scenario);
        if (idx != -1) _scenarioIndex = idx;
        final updatedDashboard = dashboard.copyWith(
          dateLabel: state.dashboard?.dateLabel,
          userLocation: state.dashboard?.userLocation,
        );
        emit(state.copyWith(
          status: DeliveryDashboardStatus.success,
          dashboard: updatedDashboard,
        ));
      },
    );
  }

  Future<void> _onScenarioCycled(
    DeliveryDashboardScenarioCycled event,
    Emitter<DeliveryDashboardState> emit,
  ) async {
    if (!kDebugMode) return;
    _scenarioIndex = (_scenarioIndex + 1) % _targetScenarios.length;
    final nextScenario = _targetScenarios[_scenarioIndex];
    final result = await switchDeliveryScenario(nextScenario);
    result.fold(
      (_) {},
      (dashboard) {
        final updatedDashboard = dashboard.copyWith(
          dateLabel: state.dashboard?.dateLabel,
          userLocation: state.dashboard?.userLocation,
        );
        emit(state.copyWith(
          status: DeliveryDashboardStatus.success,
          dashboard: updatedDashboard,
        ));
      },
    );
  }

  void _listenToLocationUpdates() {
    if (_locationSubscription != null) return;
    try {
      _locationSubscription = locationService?.onLocationChanged.listen(
        (location) {
          add(DeliveryDashboardLocationUpdated(location));
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    return super.close();
  }
}
