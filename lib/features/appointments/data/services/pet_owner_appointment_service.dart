import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/appointment_model.dart';

class PetOwnerAppointmentService {
  final Dio _dio = DioFactory.dio;

  /// Create new appointment
  Future<AppointmentModel> createAppointment(CreateAppointmentRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.appointments,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create appointment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid appointment data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Pet owner role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Pet or service not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get appointments with filters
  Future<List<AppointmentModel>> getMyAppointments({
    AppointmentStatus? status,
    String? timeFilter, // 'upcoming', 'past', 'today'
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (status != null) {
        queryParams['status'] = status.name.toUpperCase();
      }
      
      if (timeFilter != null) {
        queryParams['timeFilter'] = timeFilter;
      }

      final response = await _dio.get(
        ApiConstants.appointments,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        // API returns array directly, not wrapped in AppointmentsResponse
        if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          return data.map((json) {
            if (json == null || json is! Map<String, dynamic>) {
              print('Invalid appointment data: $json');
              return null;
            }
            try {
              return AppointmentModel.fromJson(json);
            } catch (e) {
              print('Error parsing appointment: $e');
              return null;
            }
          }).where((appointment) => appointment != null).cast<AppointmentModel>().toList();
        } else {
          print('Unexpected response format: ${response.data}');
          return [];
        }
      } else {
        throw Exception('Failed to get appointments: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Pet owner role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get appointment by ID
  Future<AppointmentModel> getAppointmentById(int appointmentId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getAppointmentByIdUrl(appointmentId),
      );

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get appointment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get pending appointments
  Future<List<AppointmentModel>> getPendingAppointments() async {
    try {
      return await getMyAppointments(status: AppointmentStatus.pending);
    } catch (e) {
      throw Exception('Failed to get pending appointments: $e');
    }
  }

  /// Get approved appointments
  Future<List<AppointmentModel>> getApprovedAppointments() async {
    try {
      return await getMyAppointments(status: AppointmentStatus.approved);
    } catch (e) {
      throw Exception('Failed to get approved appointments: $e');
    }
  }

  /// Get completed appointments
  Future<List<AppointmentModel>> getCompletedAppointments() async {
    try {
      return await getMyAppointments(status: AppointmentStatus.completed);
    } catch (e) {
      throw Exception('Failed to get completed appointments: $e');
    }
  }

  /// Get upcoming appointments
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    try {
      return await getMyAppointments(timeFilter: 'upcoming');
    } catch (e) {
      throw Exception('Failed to get upcoming appointments: $e');
    }
  }

  /// Get past appointments
  Future<List<AppointmentModel>> getPastAppointments() async {
    try {
      return await getMyAppointments(timeFilter: 'past');
    } catch (e) {
      throw Exception('Failed to get past appointments: $e');
    }
  }

  /// Get today's appointments
  Future<List<AppointmentModel>> getTodayAppointments() async {
    try {
      return await getMyAppointments(timeFilter: 'today');
    } catch (e) {
      throw Exception('Failed to get today\'s appointments: $e');
    }
  }

  /// Get appointment history
  Future<List<AppointmentModel>> getAppointmentHistory() async {
    try {
      return await getMyAppointments();
    } catch (e) {
      throw Exception('Failed to get appointment history: $e');
    }
  }
}
