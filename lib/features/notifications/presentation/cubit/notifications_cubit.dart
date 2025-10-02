import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  Future<void> loadNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    try {
      emit(NotificationsLoading());
      
      final response = await _repository.getNotifications(
        page: page,
        size: size,
        unreadOnly: unreadOnly,
      );
      
      emit(NotificationsLoaded(
        notifications: response.content,
        hasMore: !response.last,
        currentPage: response.number,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> loadMoreNotifications({
    bool unreadOnly = false,
  }) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      if (!currentState.hasMore) return;

      try {
        final response = await _repository.getNotifications(
          page: currentState.currentPage + 1,
          size: 20,
          unreadOnly: unreadOnly,
        );

        emit(NotificationsLoaded(
          notifications: [...currentState.notifications, ...response.content],
          hasMore: !response.last,
          currentPage: response.number,
        ));
      } catch (e) {
        emit(NotificationsError(e.toString()));
      }
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
      
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        emit(NotificationsLoaded(
          notifications: updatedNotifications,
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
        ));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();

        emit(NotificationsLoaded(
          notifications: updatedNotifications,
          hasMore: currentState.hasMore,
          currentPage: currentState.currentPage,
        ));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> getNotificationCount() async {
    try {
      final count = await _repository.getNotificationCount();
      emit(NotificationCountLoaded(
        unreadCount: count.unreadCount,
        totalCount: count.totalCount,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }
}
