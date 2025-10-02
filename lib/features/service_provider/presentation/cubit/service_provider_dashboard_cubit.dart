import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/service_provider_repository.dart';
import '../../../services/data/models/service_model.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';

// States
abstract class ServiceProviderDashboardState extends Equatable {
  const ServiceProviderDashboardState();

  @override
  List<Object?> get props => [];
}

class ServiceProviderDashboardInitial extends ServiceProviderDashboardState {}

class ServiceProviderDashboardLoading extends ServiceProviderDashboardState {}

class ServiceProviderDashboardLoaded extends ServiceProviderDashboardState {
  final List<ServiceModel> services;
  final List<AppointmentModel> appointments;
  final int pendingAppointments;
  final int completedToday;
  final double totalRevenue;

  const ServiceProviderDashboardLoaded({
    required this.services,
    required this.appointments,
    required this.pendingAppointments,
    required this.completedToday,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
        services,
        appointments,
        pendingAppointments,
        completedToday,
        totalRevenue,
      ];
}

class ServiceProviderDashboardError extends ServiceProviderDashboardState {
  final String message;

  const ServiceProviderDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ServiceProviderDashboardCubit extends Cubit<ServiceProviderDashboardState> {
  final ServiceProviderRepository _serviceProviderRepository;
  final AppointmentRepository _appointmentRepository;

  ServiceProviderDashboardCubit({
    required ServiceProviderRepository serviceProviderRepository,
    required AppointmentRepository appointmentRepository,
  })  : _serviceProviderRepository = serviceProviderRepository,
        _appointmentRepository = appointmentRepository,
        super(ServiceProviderDashboardInitial());

  Future<void> loadDashboardData() async {
    if (state is ServiceProviderDashboardLoaded) {
      // Don't reload if we already have data
      return;
    }

    emit(ServiceProviderDashboardLoading());

    try {
      final services = await _serviceProviderRepository.getProviderServices();
      final appointments = await _appointmentRepository.getProviderAppointments();

      // Calculate statistics
      final pendingCount = appointments
          .where((a) => a.status == AppointmentStatus.pending)
          .length;

      final today = DateTime.now();
      final completedTodayCount = appointments
          .where((a) =>
              a.status == AppointmentStatus.completed &&
              a.scheduledTime != null &&
              _isSameDay(a.scheduledTime!, today))
          .length;

      // Note: Revenue calculation removed since service price is not available in appointment response
      // Service providers should track revenue through their service management system
      final revenue = 0.0; // Placeholder - implement revenue tracking separately

      emit(ServiceProviderDashboardLoaded(
        services: services,
        appointments: appointments,
        pendingAppointments: pendingCount,
        completedToday: completedTodayCount,
        totalRevenue: revenue,
      ));
    } catch (e) {
      emit(ServiceProviderDashboardError('Failed to load dashboard data: $e'));
    }
  }

  Future<void> refreshDashboardData() async {
    emit(ServiceProviderDashboardLoading());
    await loadDashboardData();
  }

  void addService(ServiceModel service) {
    final currentState = state;
    if (currentState is ServiceProviderDashboardLoaded) {
      final updatedServices = List<ServiceModel>.from(currentState.services)
        ..add(service);
      
      emit(ServiceProviderDashboardLoaded(
        services: updatedServices,
        appointments: currentState.appointments,
        pendingAppointments: currentState.pendingAppointments,
        completedToday: currentState.completedToday,
        totalRevenue: currentState.totalRevenue,
      ));
    }
  }

  void updateService(ServiceModel updatedService) {
    final currentState = state;
    if (currentState is ServiceProviderDashboardLoaded) {
      final updatedServices = currentState.services
          .map((s) => s.id == updatedService.id ? updatedService : s)
          .toList();
      
      emit(ServiceProviderDashboardLoaded(
        services: updatedServices,
        appointments: currentState.appointments,
        pendingAppointments: currentState.pendingAppointments,
        completedToday: currentState.completedToday,
        totalRevenue: currentState.totalRevenue,
      ));
    }
  }

  Future<void> updateServiceOnServer(int serviceId, UpdateServiceRequest request) async {
    try {
      final updatedService = await _serviceProviderRepository.updateService(serviceId, request);
      updateService(updatedService);
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  void removeService(int serviceId) {
    final currentState = state;
    if (currentState is ServiceProviderDashboardLoaded) {
      final updatedServices = currentState.services
          .where((s) => s.id != serviceId)
          .toList();
      
      emit(ServiceProviderDashboardLoaded(
        services: updatedServices,
        appointments: currentState.appointments,
        pendingAppointments: currentState.pendingAppointments,
        completedToday: currentState.completedToday,
        totalRevenue: currentState.totalRevenue,
      ));
    }
  }

  void updateAppointment(AppointmentModel updatedAppointment) {
    final currentState = state;
    if (currentState is ServiceProviderDashboardLoaded) {
      final updatedAppointments = currentState.appointments
          .map((a) => a.id == updatedAppointment.id ? updatedAppointment : a)
          .toList();

      // Recalculate statistics
      final pendingCount = updatedAppointments
          .where((a) => a.status == AppointmentStatus.pending)
          .length;

      final today = DateTime.now();
      final completedTodayCount = updatedAppointments
          .where((a) =>
              a.status == AppointmentStatus.completed &&
              a.scheduledTime != null &&
              _isSameDay(a.scheduledTime!, today))
          .length;

      // Note: Revenue calculation removed since service price is not available in appointment response
      // Service providers should track revenue through their service management system
      final revenue = 0.0; // Placeholder - implement revenue tracking separately
      
      emit(ServiceProviderDashboardLoaded(
        services: currentState.services,
        appointments: updatedAppointments,
        pendingAppointments: pendingCount,
        completedToday: completedTodayCount,
        totalRevenue: revenue,
      ));
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
