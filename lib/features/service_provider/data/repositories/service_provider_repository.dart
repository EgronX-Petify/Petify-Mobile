import '../services/service_provider_service.dart';
import '../../../services/data/models/service_model.dart';
import '../../../appointments/data/models/appointment_model.dart';

class ServiceProviderRepository {
  final ServiceProviderService _service;

  ServiceProviderRepository(this._service);

  // Dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // Get provider services and appointments in parallel
      final servicesTask = _service.getProviderServices();
      final appointmentsTask = _service.getProviderAppointments();
      
      final results = await Future.wait([servicesTask, appointmentsTask]);
      final services = results[0] as List<ServiceModel>;
      final appointments = results[1] as List<AppointmentModel>;
      
      // Calculate statistics
      final pendingAppointments = appointments.where((a) => a.status == AppointmentStatus.pending).toList();
      final completedToday = appointments.where((a) => 
        a.status == AppointmentStatus.completed && 
        _isToday(a.scheduledTime ?? a.requestedTime)
      ).length;
      
      // Calculate total revenue (mock calculation)
      final totalRevenue = services.fold<double>(0, (sum, service) => sum + service.price) * 10;
      
      return {
        'services': services,
        'appointments': appointments,
        'pendingAppointments': pendingAppointments,
        'completedToday': completedToday,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  // Services management
  Future<List<ServiceModel>> getProviderServices() async {
    return await _service.getProviderServices();
  }

  Future<ServiceModel> createService(CreateServiceRequest request) async {
    return await _service.createService(request);
  }

  Future<ServiceModel> updateService(int serviceId, UpdateServiceRequest request) async {
    return await _service.updateService(serviceId, request);
  }

  Future<void> deleteService(int serviceId) async {
    await _service.deleteService(serviceId);
  }

  // Appointments management
  Future<List<AppointmentModel>> getProviderAppointments() async {
    return await _service.getProviderAppointments();
  }

  Future<void> approveAppointment(int appointmentId) async {
    await _service.approveAppointment(appointmentId);
  }

  Future<void> approveAppointmentWithDetails(
    int appointmentId,
    DateTime scheduledTime,
    String? notes,
  ) async {
    await _service.approveAppointmentWithDetails(appointmentId, scheduledTime, notes);
  }

  Future<void> disapproveAppointment(int appointmentId, {String? rejectionReason}) async {
    await _service.disapproveAppointment(appointmentId, rejectionReason: rejectionReason);
  }

  Future<void> rejectAppointment(int appointmentId, {String? rejectionReason}) async {
    await _service.rejectAppointment(appointmentId, rejectionReason: rejectionReason);
  }

  Future<void> completeAppointment(int appointmentId) async {
    await _service.completeAppointment(appointmentId);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}
