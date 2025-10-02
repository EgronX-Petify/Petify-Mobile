import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/pet_owner_appointment_service.dart';
import '../../data/models/appointment_model.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final PetOwnerAppointmentService _appointmentService;

  AppointmentsCubit({
    required PetOwnerAppointmentService appointmentService,
  })  : _appointmentService = appointmentService,
        super(AppointmentsInitial());

  // Appointment CRUD operations
  Future<void> createAppointment(CreateAppointmentRequest request) async {
    emit(AppointmentsLoading());
    try {
      final appointment = await _appointmentService.createAppointment(request);
      emit(AppointmentCreated(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> loadMyAppointments({
    AppointmentStatus? status,
    String? timeFilter,
  }) async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getMyAppointments(
        status: status,
        timeFilter: timeFilter,
      );
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> loadAppointmentById(int appointmentId) async {
    emit(AppointmentsLoading());
    try {
      final appointment = await _appointmentService.getAppointmentById(appointmentId);
      emit(AppointmentLoaded(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  // Load appointments by status
  Future<void> loadPendingAppointments() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getPendingAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> loadApprovedAppointments() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getApprovedAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> loadCompletedAppointments() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getCompletedAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  // Load appointments by time filter
  Future<void> loadUpcomingAppointments() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getUpcomingAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> loadPastAppointments() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getPastAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> loadTodayAppointments() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getTodayAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> loadAppointmentHistory() async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _appointmentService.getAppointmentHistory();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  // Helper methods
  Future<void> refreshAppointments() async {
    await loadMyAppointments();
  }

  void clearAppointments() {
    emit(AppointmentsInitial());
  }

  // Book appointment with validation
  Future<void> bookAppointment({
    required int petId,
    required int serviceId,
    required DateTime requestedTime,
    String? notes,
  }) async {
    emit(AppointmentsLoading());
    try {
      final request = CreateAppointmentRequest(
        petId: petId,
        serviceId: serviceId,
        requestedTime: requestedTime,
        notes: notes,
      );
      final appointment = await _appointmentService.createAppointment(request);
      emit(AppointmentCreated(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }
}
