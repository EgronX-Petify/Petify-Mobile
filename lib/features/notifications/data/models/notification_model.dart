import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

enum NotificationType {
  @JsonValue('GENERAL')
  general,
  @JsonValue('WELCOME')
  welcome,
  @JsonValue('APPOINTMENT_CREATED')
  appointmentCreated,
  @JsonValue('APPOINTMENT_APPROVED')
  appointmentApproved,
  @JsonValue('APPOINTMENT_COMPLETED')
  appointmentCompleted,
  @JsonValue('APPOINTMENT_CANCELLED')
  appointmentCancelled,
  @JsonValue('APPOINTMENT_REJECTED')
  appointmentRejected,
  @JsonValue('NEW_APPOINTMENT_REQUEST')
  newAppointmentRequest,
  @JsonValue('SERVICE_REMINDER')
  serviceReminder,
  @JsonValue('SYSTEM_MAINTENANCE')
  systemMaintenance,
  @JsonValue('PROFILE_UPDATE')
  profileUpdate,
  @JsonValue('APPOINTMENT_REMINDER')
  appointmentReminder,
  @JsonValue('PET_CHECKUP_DUE')
  petCheckupDue,
}

@JsonSerializable()
class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object> get props => [
        id,
        title,
        message,
        type,
        createdAt,
        isRead,
      ];
}

@JsonSerializable()
class NotificationResponse extends Equatable {
  final List<NotificationModel> notifications;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const NotificationResponse({
    required this.notifications,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) => _$NotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);

  @override
  List<Object> get props => [
        notifications,
        page,
        size,
        totalElements,
        totalPages,
        hasNext,
        hasPrevious,
      ];
}

@JsonSerializable()
class NotificationCountResponse extends Equatable {
  final int unreadCount;
  final int totalCount;

  const NotificationCountResponse({
    required this.unreadCount,
    required this.totalCount,
  });

  factory NotificationCountResponse.fromJson(Map<String, dynamic> json) => _$NotificationCountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationCountResponseToJson(this);

  @override
  List<Object> get props => [unreadCount, totalCount];
}

@JsonSerializable()
class NotificationsResponse {
  final List<NotificationModel> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;

  const NotificationsResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) => _$NotificationsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsResponseToJson(this);
}
