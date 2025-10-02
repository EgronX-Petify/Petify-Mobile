import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = DioFactory.dio;

  // Get notifications with pagination
  Future<NotificationsResponse> getNotifications({
    int page = 0,
    int size = 10,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        'unreadOnly': unreadOnly,
      };

      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return NotificationsResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get notifications: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get notification counts
  Future<NotificationCountResponse> getNotificationCount() async {
    try {
      final response = await _dio.get(ApiConstants.notificationCount);

      if (response.statusCode == 200) {
        return NotificationCountResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get notification count: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _dio.put(
        ApiConstants.markNotificationReadUrl(notificationId),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark notification as read: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Notification not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await _dio.put(ApiConstants.markAllNotificationsRead);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark all notifications as read: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
