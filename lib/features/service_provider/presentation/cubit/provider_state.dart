part of 'provider_cubit.dart';

abstract class ProviderState {}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProviderError extends ProviderState {
  final String message;
  ProviderError(this.message);
}

// Service states
class ServicesLoaded extends ProviderState {
  final List<ServiceModel> services;
  ServicesLoaded(this.services);
}

class ServiceCreated extends ProviderState {
  final ServiceModel service;
  ServiceCreated(this.service);
}

class ServiceUpdated extends ProviderState {
  final ServiceModel service;
  ServiceUpdated(this.service);
}

class ServiceDeleted extends ProviderState {}

// Appointment states
class AppointmentsLoaded extends ProviderState {
  final List<AppointmentModel> appointments;
  AppointmentsLoaded(this.appointments);
}

class AppointmentApproved extends ProviderState {
  final AppointmentModel appointment;
  AppointmentApproved(this.appointment);
}

// Dashboard state
class DashboardDataLoaded extends ProviderState {
  final List<ServiceModel> services;
  final List<AppointmentModel> pendingAppointments;
  
  DashboardDataLoaded(this.services, this.pendingAppointments);
}
