// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.general: 'GENERAL',
  NotificationType.welcome: 'WELCOME',
  NotificationType.appointmentCreated: 'APPOINTMENT_CREATED',
  NotificationType.appointmentApproved: 'APPOINTMENT_APPROVED',
  NotificationType.appointmentCompleted: 'APPOINTMENT_COMPLETED',
  NotificationType.appointmentCancelled: 'APPOINTMENT_CANCELLED',
  NotificationType.appointmentRejected: 'APPOINTMENT_REJECTED',
  NotificationType.newAppointmentRequest: 'NEW_APPOINTMENT_REQUEST',
  NotificationType.serviceReminder: 'SERVICE_REMINDER',
  NotificationType.systemMaintenance: 'SYSTEM_MAINTENANCE',
  NotificationType.profileUpdate: 'PROFILE_UPDATE',
  NotificationType.appointmentReminder: 'APPOINTMENT_REMINDER',
  NotificationType.petCheckupDue: 'PET_CHECKUP_DUE',
};

NotificationResponse _$NotificationResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationResponse(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );

Map<String, dynamic> _$NotificationResponseToJson(
        NotificationResponse instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'page': instance.page,
      'size': instance.size,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrevious': instance.hasPrevious,
    };

NotificationCountResponse _$NotificationCountResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationCountResponse(
      unreadCount: (json['unreadCount'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$NotificationCountResponseToJson(
        NotificationCountResponse instance) =>
    <String, dynamic>{
      'unreadCount': instance.unreadCount,
      'totalCount': instance.totalCount,
    };

NotificationsResponse _$NotificationsResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationsResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      first: json['first'] as bool,
      last: json['last'] as bool,
    );

Map<String, dynamic> _$NotificationsResponseToJson(
        NotificationsResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'size': instance.size,
      'number': instance.number,
      'first': instance.first,
      'last': instance.last,
    };
