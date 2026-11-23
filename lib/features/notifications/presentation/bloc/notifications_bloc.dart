// lib/features/notifications/presentation/bloc/notifications_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/notifications/notification_preferences.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:routex_mobile/features/notifications/domain/usecases/toggle_notifications_empty_usecase.dart';
import 'package:routex_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:routex_mobile/features/notifications/presentation/bloc/notifications_state.dart';

export 'notifications_event.dart';
export 'notifications_state.dart';

/// Owns the Notifications inbox screen (N01 Populated and N02 Empty variants).
///
/// Handles initial load, pull-to-refresh, marking all as read, and toggling
/// between populated and empty states for testing.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkAllNotificationsReadUseCase markAllRead,
    required ToggleNotificationsEmptyUseCase toggleEmpty,
    NotificationsState? initialState,
  })  : _getNotifications = getNotifications,
        _markAllRead = markAllRead,
        _toggleEmpty = toggleEmpty,
        super(initialState ?? const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsRefreshed>(_onRefreshed);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
    on<NotificationsToggleEmpty>(_onToggleEmpty);
    on<NotificationsErrorDismissed>(_onErrorDismissed);
  }

  @override
  void onChange(Change<NotificationsState> change) {
    super.onChange(change);
    if (change.nextState.status == NotificationsStatus.success) {
      NotificationInboxBadge.unread.value = change.nextState.unreadCount;
    }
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final ToggleNotificationsEmptyUseCase _toggleEmpty;

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.notifications.isEmpty &&
        state.status != NotificationsStatus.success) {
      emit(state.copyWith(status: NotificationsStatus.loading));
      await _load(emit);
      return;
    }

    emit(
      state.copyWith(status: NotificationsStatus.success, isRefreshing: true),
    );
    await _load(emit);
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _markAllRead(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: _message(failure)),
      ),
      (notifications) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: notifications,
        ),
      ),
    );
  }

  Future<void> _onToggleEmpty(
    NotificationsToggleEmpty event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _toggleEmpty(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: _message(failure)),
      ),
      (notifications) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: notifications,
        ),
      ),
    );
  }

  void _onErrorDismissed(
    NotificationsErrorDismissed event,
    Emitter<NotificationsState> emit,
  ) {
    emit(
      state.copyWith(
        status: state.notifications.isEmpty
            ? NotificationsStatus.failure
            : NotificationsStatus.success,
      ),
    );
  }

  Future<void> _load(Emitter<NotificationsState> emit) async {
    final result = await _getNotifications(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: state.notifications.isEmpty
              ? NotificationsStatus.failure
              : NotificationsStatus.success,
          isRefreshing: false,
          errorMessage: _message(failure),
        ),
      ),
      (notifications) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: notifications,
          isRefreshing: false,
        ),
      ),
    );
  }

  String _message(Failure failure) => failure.message;
}
