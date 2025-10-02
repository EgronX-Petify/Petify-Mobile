import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/service_provider_repository.dart';
import '../../../services/data/models/service_model.dart';
import '../../../appointments/data/models/appointment_model.dart';

part 'service_provider_state.dart';

class ServiceProviderCubit extends Cubit<ServiceProviderState> {
  final ServiceProviderRepository _repository;

  ServiceProviderCubit(this._repository) : super(ServiceProviderInitial());

  Future<void> loadDashboardData() async {
    try {
      emit(ServiceProviderLoading());
      
      final dashboardData = await _repository.getDashboardData();
      
      emit(ServiceProviderDashboardLoaded(
        services: dashboardData['services'] as List<ServiceModel>,
        appointments: dashboardData['appointments'] as List<AppointmentModel>,
        pendingAppointments: dashboardData['pendingAppointments'] as List<AppointmentModel>,
        completedToday: dashboardData['completedToday'] as int,
        totalRevenue: dashboardData['totalRevenue'] as double,
      ));
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> loadServices() async {
    try {
      emit(ServiceProviderLoading());
      final services = await _repository.getProviderServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> createService(CreateServiceRequest request) async {
    try {
      await _repository.createService(request);
      emit(ServiceCreated('Service created successfully'));
      // Reload services
      loadServices();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> updateService(int serviceId, UpdateServiceRequest request) async {
    try {
      await _repository.updateService(serviceId, request);
      emit(ServiceUpdated('Service updated successfully'));
      // Reload services
      loadServices();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> deleteService(int serviceId) async {
    try {
      await _repository.deleteService(serviceId);
      emit(ServiceDeleted('Service deleted successfully'));
      // Reload services
      loadServices();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> loadAppointments() async {
    try {
      emit(ServiceProviderLoading());
      final appointments = await _repository.getProviderAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> approveAppointment(int appointmentId) async {
    try {
      await _repository.approveAppointment(appointmentId);
      emit(AppointmentApproved('Appointment approved successfully'));
      // Reload appointments
      loadAppointments();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> approveAppointmentWithDetails(
    int appointmentId,
    DateTime scheduledTime,
    String? notes,
  ) async {
    try {
      await _repository.approveAppointmentWithDetails(appointmentId, scheduledTime, notes);
      emit(AppointmentApproved('Appointment approved successfully'));
      // Reload appointments
      loadAppointments();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> disapproveAppointment(int appointmentId, {String? rejectionReason}) async {
    try {
      await _repository.disapproveAppointment(appointmentId, rejectionReason: rejectionReason);
      emit(AppointmentRejected('Appointment disapproved successfully'));
      // Reload appointments
      loadAppointments();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> rejectAppointment(int appointmentId, {String? rejectionReason}) async {
    try {
      await _repository.rejectAppointment(appointmentId, rejectionReason: rejectionReason);
      emit(AppointmentRejected('Appointment rejected successfully'));
      // Reload appointments
      loadAppointments();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  Future<void> completeAppointment(int appointmentId) async {
    try {
      await _repository.completeAppointment(appointmentId);
      emit(AppointmentCompleted('Appointment completed successfully'));
      // Reload appointments
      loadAppointments();
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }
}
