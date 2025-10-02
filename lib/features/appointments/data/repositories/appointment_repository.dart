import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

abstract class AppointmentRepository {
  // Pet Owner appointment methods
  Future<AppointmentModel> createAppointment(CreateAppointmentRequest request);
  Future<AppointmentModel> getAppointmentById(int appointmentId);
  Future<List<AppointmentModel>> getAppointments({
    int? petId,
    AppointmentStatus? status,
    String? timeFilter,
  });
  Future<void> cancelAppointment(int appointmentId);
  
  // Service Provider appointment methods
  Future<List<AppointmentModel>> getServiceAppointments(
    int serviceId, {
    AppointmentStatus? status,
    String? timeFilter,
  });
  Future<List<AppointmentModel>> getProviderAppointments({
    AppointmentStatus? status,
    String? timeFilter,
  });
  Future<AppointmentModel> getProviderAppointmentById(int appointmentId);
  Future<AppointmentModel> approveAppointment(int appointmentId, ApproveAppointmentRequest request);
  Future<AppointmentModel> rejectAppointment(int appointmentId, RejectAppointmentRequest request);
  Future<AppointmentModel> completeAppointment(int appointmentId);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentService _appointmentService;

  AppointmentRepositoryImpl(this._appointmentService);

  @override
  Future<AppointmentModel> createAppointment(CreateAppointmentRequest request) async {
    try {
      return await _appointmentService.createAppointment(request);
    } catch (e) {
      throw Exception('Failed to create appointment: ${e.toString()}');
    }
  }

  @override
  Future<AppointmentModel> getAppointmentById(int appointmentId) async {
    try {
      return await _appointmentService.getAppointmentById(appointmentId);
    } catch (e) {
      throw Exception('Failed to get appointment: ${e.toString()}');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointments({
    int? petId,
    AppointmentStatus? status,
    String? timeFilter,
  }) async {
    try {
      return await _appointmentService.getAppointments(
        petId: petId,
        status: status,
        timeFilter: timeFilter,
      );
    } catch (e) {
      throw Exception('Failed to get appointments: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelAppointment(int appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(appointmentId);
    } catch (e) {
      throw Exception('Failed to cancel appointment: ${e.toString()}');
    }
  }

  @override
  Future<List<AppointmentModel>> getServiceAppointments(
    int serviceId, {
    AppointmentStatus? status,
    String? timeFilter,
  }) async {
    try {
      return await _appointmentService.getServiceAppointments(
        serviceId,
        status: status,
        timeFilter: timeFilter,
      );
    } catch (e) {
      throw Exception('Failed to get service appointments: ${e.toString()}');
    }
  }

  @override
  Future<List<AppointmentModel>> getProviderAppointments({
    AppointmentStatus? status,
    String? timeFilter,
  }) async {
    try {
      return await _appointmentService.getProviderAppointments(
        status: status,
        timeFilter: timeFilter,
      );
    } catch (e) {
      throw Exception('Failed to get provider appointments: ${e.toString()}');
    }
  }

  @override
  Future<AppointmentModel> getProviderAppointmentById(int appointmentId) async {
    try {
      return await _appointmentService.getProviderAppointmentById(appointmentId);
    } catch (e) {
      throw Exception('Failed to get provider appointment: ${e.toString()}');
    }
  }

  @override
  Future<AppointmentModel> approveAppointment(int appointmentId, ApproveAppointmentRequest request) async {
    try {
      return await _appointmentService.approveAppointment(appointmentId, request);
    } catch (e) {
      throw Exception('Failed to approve appointment: ${e.toString()}');
    }
  }

  @override
  Future<AppointmentModel> rejectAppointment(int appointmentId, RejectAppointmentRequest request) async {
    try {
      return await _appointmentService.rejectAppointment(appointmentId, request);
    } catch (e) {
      throw Exception('Failed to reject appointment: ${e.toString()}');
    }
  }

  @override
  Future<AppointmentModel> completeAppointment(int appointmentId) async {
    try {
      return await _appointmentService.completeAppointment(appointmentId);
    } catch (e) {
      throw Exception('Failed to complete appointment: ${e.toString()}');
    }
  }
}
