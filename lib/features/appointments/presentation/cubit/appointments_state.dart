part of 'appointments_cubit.dart';

abstract class AppointmentsState {}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsError extends AppointmentsState {
  final String message;
  AppointmentsError(this.message);
}

// Appointment states
class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentModel> appointments;
  AppointmentsLoaded(this.appointments);
}

class AppointmentLoaded extends AppointmentsState {
  final AppointmentModel appointment;
  AppointmentLoaded(this.appointment);
}

class AppointmentCreated extends AppointmentsState {
  final AppointmentModel appointment;
  AppointmentCreated(this.appointment);
}
