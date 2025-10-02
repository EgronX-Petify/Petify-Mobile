import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/provider_service.dart';
import '../../../services/data/models/service_model.dart';
import '../../../appointments/data/models/appointment_model.dart';

part 'provider_state.dart';

class ProviderCubit extends Cubit<ProviderState> {
  final ProviderService _providerService;

  ProviderCubit({
    required ProviderService providerService,
  })  : _providerService = providerService,
        super(ProviderInitial());

  // Service management
  Future<void> loadMyServices() async {
    emit(ProviderLoading());
    try {
      final services = await _providerService.getMyServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> createService(CreateServiceRequest request) async {
    emit(ProviderLoading());
    try {
      final service = await _providerService.createService(request);
      emit(ServiceCreated(service));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> updateService(int serviceId, CreateServiceRequest request) async {
    emit(ProviderLoading());
    try {
      final service = await _providerService.updateService(serviceId, request);
      emit(ServiceUpdated(service));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> deleteService(int serviceId) async {
    emit(ProviderLoading());
    try {
      await _providerService.deleteService(serviceId);
      emit(ServiceDeleted());
      // Reload services after deletion
      loadMyServices();
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  // Appointment management
  Future<void> loadProviderAppointments({AppointmentStatus? status}) async {
    emit(ProviderLoading());
    try {
      final appointmentsResponse = await _providerService.getProviderAppointments(status: status);
      emit(AppointmentsLoaded(appointmentsResponse.appointments));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> approveAppointment(int appointmentId, DateTime scheduledTime, String? notes) async {
    emit(ProviderLoading());
    try {
      final request = ApproveAppointmentRequest(
        scheduledTime: scheduledTime,
        notes: notes,
      );
      final appointment = await _providerService.approveAppointment(appointmentId, request);
      emit(AppointmentApproved(appointment));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> loadPendingAppointments() async {
    emit(ProviderLoading());
    try {
      final appointments = await _providerService.getPendingAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> loadApprovedAppointments() async {
    emit(ProviderLoading());
    try {
      final appointments = await _providerService.getApprovedAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  Future<void> loadCompletedAppointments() async {
    emit(ProviderLoading());
    try {
      final appointments = await _providerService.getCompletedAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }

  // Dashboard data
  Future<void> loadDashboardData() async {
    emit(ProviderLoading());
    try {
      // Load services and pending appointments in parallel
      final servicesTask = _providerService.getMyServices();
      final pendingAppointmentsTask = _providerService.getPendingAppointments();
      
      final results = await Future.wait([servicesTask, pendingAppointmentsTask]);
      final services = results[0] as List<ServiceModel>;
      final pendingAppointments = results[1] as List<AppointmentModel>;
      
      emit(DashboardDataLoaded(services, pendingAppointments));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }
}
