part of 'service_provider_cubit.dart';

abstract class ServiceProviderState extends Equatable {
  const ServiceProviderState();

  @override
  List<Object> get props => [];
}

class ServiceProviderInitial extends ServiceProviderState {}

class ServiceProviderLoading extends ServiceProviderState {}

class ServiceProviderError extends ServiceProviderState {
  final String message;

  const ServiceProviderError(this.message);

  @override
  List<Object> get props => [message];
}

// Dashboard state
class ServiceProviderDashboardLoaded extends ServiceProviderState {
  final List<ServiceModel> services;
  final List<AppointmentModel> appointments;
  final List<AppointmentModel> pendingAppointments;
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
  List<Object> get props => [
    services,
    appointments,
    pendingAppointments,
    completedToday,
    totalRevenue,
  ];
}

// Services states
class ServicesLoaded extends ServiceProviderState {
  final List<ServiceModel> services;

  const ServicesLoaded(this.services);

  @override
  List<Object> get props => [services];
}

class ServiceCreated extends ServiceProviderState {
  final String message;

  const ServiceCreated(this.message);

  @override
  List<Object> get props => [message];
}

class ServiceUpdated extends ServiceProviderState {
  final String message;

  const ServiceUpdated(this.message);

  @override
  List<Object> get props => [message];
}

class ServiceDeleted extends ServiceProviderState {
  final String message;

  const ServiceDeleted(this.message);

  @override
  List<Object> get props => [message];
}

// Appointments states
class AppointmentsLoaded extends ServiceProviderState {
  final List<AppointmentModel> appointments;

  const AppointmentsLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class AppointmentApproved extends ServiceProviderState {
  final String message;

  const AppointmentApproved(this.message);

  @override
  List<Object> get props => [message];
}

class AppointmentRejected extends ServiceProviderState {
  final String message;

  const AppointmentRejected(this.message);

  @override
  List<Object> get props => [message];
}

class AppointmentCompleted extends ServiceProviderState {
  final String message;

  const AppointmentCompleted(this.message);

  @override
  List<Object> get props => [message];
}
