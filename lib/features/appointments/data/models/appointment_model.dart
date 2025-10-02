import 'package:json_annotation/json_annotation.dart';
import '../../../services/data/models/service_model.dart';

part 'appointment_model.g.dart';

enum AppointmentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

@JsonSerializable()
class AppointmentModel {
  final int id;
  final int petId;
  final String petName;
  final int serviceId;
  final String serviceName;
  final ServiceCategory serviceCategory;
  final DateTime requestedTime;
  final DateTime? scheduledTime;
  final AppointmentStatus status;
  final String? notes;
  final String? rejectionReason;
  final String? providerName;
  final int providerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.petId,
    required this.petName,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.requestedTime,
    this.scheduledTime,
    required this.status,
    this.notes,
    this.rejectionReason,
    this.providerName,
    required this.providerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  bool get isPending => status == AppointmentStatus.pending;
  bool get isApproved => status == AppointmentStatus.approved;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
}

@JsonSerializable()
class CreateAppointmentRequest {
  final int petId;
  final int serviceId;
  final DateTime requestedTime;
  final String? notes;

  const CreateAppointmentRequest({
    required this.petId,
    required this.serviceId,
    required this.requestedTime,
    this.notes,
  });

  factory CreateAppointmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAppointmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAppointmentRequestToJson(this);
}

@JsonSerializable()
class RejectAppointmentRequest {
  final String? reason;

  const RejectAppointmentRequest({this.reason});

  factory RejectAppointmentRequest.fromJson(Map<String, dynamic> json) =>
      _$RejectAppointmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RejectAppointmentRequestToJson(this);
}

@JsonSerializable()
class ApproveAppointmentRequest {
  final DateTime scheduledTime;
  final String? notes;

  const ApproveAppointmentRequest({required this.scheduledTime, this.notes});

  factory ApproveAppointmentRequest.fromJson(Map<String, dynamic> json) =>
      _$ApproveAppointmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApproveAppointmentRequestToJson(this);
}

@JsonSerializable()
class AppointmentsResponse {
  final List<AppointmentModel> appointments;
  final int totalCount;

  const AppointmentsResponse({
    required this.appointments,
    required this.totalCount,
  });

  factory AppointmentsResponse.fromJson(Map<String, dynamic> json) =>
      _$AppointmentsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentsResponseToJson(this);
}
