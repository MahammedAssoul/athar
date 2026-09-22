import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/di/app_dependencies.dart';
import '../../../data/models/app_notification.dart';

/// Notifications state.
class NotificationsState {
  const NotificationsState({
    this.loading = true,
    this.error = false,
    this.notifications = const [],
  });

  final bool loading;
  final bool error;
  final List<AppNotification> notifications;

  NotificationsState copyWith({
    bool? loading,
    bool? error,
    List<AppNotification>? notifications,
  }) {
    return NotificationsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      notifications: notifications ?? this.notifications,
    );
  }
}

/// Loads notifications and tracks read/unread state.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  Future<void> load() async {
    emit(const NotificationsState(loading: true));
    try {
      final notifications = await AppDependencies
          .instance
          .notificationRepository
          .getNotifications();
      emit(NotificationsState(loading: false, notifications: notifications));
    } catch (_) {
      emit(const NotificationsState(loading: false, error: true));
    }
  }

  Future<void> markAsRead(String id) async {
    final updated = await AppDependencies.instance.notificationRepository
        .markAsRead(id);
    emit(
      state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == updated.id ? updated : n)
            .toList(),
      ),
    );
  }

  Future<void> markAllAsRead() async {
    await AppDependencies.instance.notificationRepository.markAllAsRead();
    emit(
      state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList(),
      ),
    );
  }

  int get unreadCount => state.notifications.where((n) => !n.isRead).length;
}
