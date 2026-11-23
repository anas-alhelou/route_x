// lib/features/home/presentation/bloc/home_state.dart
// Convention: events, states and the bloc live in separate files, all exported
// through home_bloc.dart.
import 'package:equatable/equatable.dart';
import 'package:routex_mobile/features/home/domain/entities/home_overview.dart';
import 'package:routex_mobile/features/home/presentation/widgets/go_online/go_online_sheet.dart';

/// Status of the Home screen's data.
enum HomeStatus {
  /// Nothing requested yet — the first frame after `HomePage` is built.
  initial,

  /// First load in flight and no snapshot to show yet.
  loading,

  /// A snapshot is on screen.
  ///
  /// This also covers a background refresh and an in-flight action: the content
  /// stays visible for all three, so the screen never blanks while the driver
  /// is toggling the switch or tapping Join.
  success,

  /// No snapshot could be loaded and [HomeState.errorMessage] is set.
  failure,
}

/// Immutable state held by `HomeBloc`.
///
/// One state object carries the status, the dashboard and any error rather than
/// a status plus a separate error field the widgets would have to keep in sync
/// by hand: `success` with an error and `failure` with data are both states the
/// UI would render incorrectly.
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.overview,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.blockedReason,
  });

  /// Current stage of the load.
  final HomeStatus status;

  /// The dashboard, non-null whenever [status] is [HomeStatus.success].
  final HomeOverview? overview;

  /// A refresh or action is in flight while content remains on screen.
  final bool isRefreshing;

  /// A mutating action (Join) is in flight, used to disable the button that
  /// triggered it.
  final bool isSubmitting;

  /// Non-null only when [status] is [HomeStatus.failure].
  final String? errorMessage;

  /// One-shot reason emitted when the driver taps the switch while locked.
  final GoOnlineBlockedReason? blockedReason;

  /// Whether the header switch accepts input.
  ///
  /// Reads the entity's own rule rather than re-deriving "has a fleet" here, so
  /// the bloc, the switch and the tile can never disagree about the lock.
  bool get canToggleOnline => overview?.availability.canToggle ?? false;

  /// [errorMessage] is deliberately not copied forward: it only ever describes
  /// the state being replaced, and silently carrying a stale message through a
  /// successful reload would put an error on screen with nothing wrong.
  HomeState copyWith({
    HomeStatus? status,
    HomeOverview? overview,
    bool? isRefreshing,
    bool? isSubmitting,
    String? errorMessage,
    GoOnlineBlockedReason? blockedReason,
    bool clearBlockedReason = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      blockedReason: clearBlockedReason
          ? null
          : (blockedReason ?? this.blockedReason),
    );
  }

  @override
  List<Object?> get props => [
    status,
    overview,
    isRefreshing,
    isSubmitting,
    errorMessage,
    blockedReason,
  ];
}
