import '../models/notification_model.dart';
import '../services/notification_service.dart';

abstract class NotificationRepository {
  Future<NotificationsResponse> getNotifications({
    int page = 0,
    int size = 10,
    bool unreadOnly = false,
  });
  Future<NotificationCountResponse> getNotificationCount();
  Future<void> markNotificationAsRead(int notificationId);
  Future<void> markAllNotificationsAsRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepositoryImpl(this._notificationService);

  @override
  Future<NotificationsResponse> getNotifications({
    int page = 0,
    int size = 10,
    bool unreadOnly = false,
  }) async {
    try {
      return await _notificationService.getNotifications(
        page: page,
        size: size,
        unreadOnly: unreadOnly,
      );
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }

  @override
  Future<NotificationCountResponse> getNotificationCount() async {
    try {
      return await _notificationService.getNotificationCount();
    } catch (e) {
      throw Exception('Failed to get notification count: ${e.toString()}');
    }
  }

  @override
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _notificationService.markAllNotificationsAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }
}
