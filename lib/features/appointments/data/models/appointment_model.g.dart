// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: (json['id'] as num).toInt(),
      petId: (json['petId'] as num).toInt(),
      petName: json['petName'] as String,
      serviceId: (json['serviceId'] as num).toInt(),
      serviceName: json['serviceName'] as String,
      serviceCategory:
          $enumDecode(_$ServiceCategoryEnumMap, json['serviceCategory']),
      requestedTime: DateTime.parse(json['requestedTime'] as String),
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
      status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      providerName: json['providerName'] as String?,
      providerId: (json['providerId'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'petId': instance.petId,
      'petName': instance.petName,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'serviceCategory': _$ServiceCategoryEnumMap[instance.serviceCategory]!,
      'requestedTime': instance.requestedTime.toIso8601String(),
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'rejectionReason': instance.rejectionReason,
      'providerName': instance.providerName,
      'providerId': instance.providerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ServiceCategoryEnumMap = {
  ServiceCategory.vet: 'VET',
  ServiceCategory.grooming: 'GROOMING',
  ServiceCategory.training: 'TRAINING',
  ServiceCategory.boarding: 'BOARDING',
  ServiceCategory.walking: 'WALKING',
  ServiceCategory.sitting: 'SITTING',
  ServiceCategory.vaccination: 'VACCINATION',
  ServiceCategory.other: 'OTHER',
};

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.pending: 'PENDING',
  AppointmentStatus.approved: 'APPROVED',
  AppointmentStatus.completed: 'COMPLETED',
  AppointmentStatus.cancelled: 'CANCELLED',
};

CreateAppointmentRequest _$CreateAppointmentRequestFromJson(
        Map<String, dynamic> json) =>
    CreateAppointmentRequest(
      petId: (json['petId'] as num).toInt(),
      serviceId: (json['serviceId'] as num).toInt(),
      requestedTime: DateTime.parse(json['requestedTime'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateAppointmentRequestToJson(
        CreateAppointmentRequest instance) =>
    <String, dynamic>{
      'petId': instance.petId,
      'serviceId': instance.serviceId,
      'requestedTime': instance.requestedTime.toIso8601String(),
      'notes': instance.notes,
    };

RejectAppointmentRequest _$RejectAppointmentRequestFromJson(
        Map<String, dynamic> json) =>
    RejectAppointmentRequest(
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$RejectAppointmentRequestToJson(
        RejectAppointmentRequest instance) =>
    <String, dynamic>{
      'reason': instance.reason,
    };

ApproveAppointmentRequest _$ApproveAppointmentRequestFromJson(
        Map<String, dynamic> json) =>
    ApproveAppointmentRequest(
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ApproveAppointmentRequestToJson(
        ApproveAppointmentRequest instance) =>
    <String, dynamic>{
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'notes': instance.notes,
    };

AppointmentsResponse _$AppointmentsResponseFromJson(
        Map<String, dynamic> json) =>
    AppointmentsResponse(
      appointments: (json['appointments'] as List<dynamic>)
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$AppointmentsResponseToJson(
        AppointmentsResponse instance) =>
    <String, dynamic>{
      'appointments': instance.appointments,
      'totalCount': instance.totalCount,
    };
