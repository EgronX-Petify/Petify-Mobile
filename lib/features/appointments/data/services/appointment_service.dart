import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final Dio _dio = DioFactory.dio;

  // Pet Owner appointment endpoints

  // Create new appointment
  Future<AppointmentModel> createAppointment(
    CreateAppointmentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.appointments,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to create appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - PET_OWNER role required');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid appointment data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get appointment by ID
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
      if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get appointments with filters (Pet Owner)
  Future<List<AppointmentModel>> getAppointments({
    int? petId,
    AppointmentStatus? status,
    String? timeFilter, // "upcoming" or "past"
  }) async {
    try {
      print('🔍 Getting appointments with filters - Status: $status, TimeFilter: $timeFilter');
      
      final queryParams = <String, dynamic>{};
      if (petId != null) {
        queryParams['petId'] = petId;
      }
      if (status != null) {
        queryParams['status'] = _statusToString(status);
      }
      if (timeFilter != null) {
        queryParams['timeFilter'] = timeFilter;
      }

      final response = await _dio.get(
        ApiConstants.appointments, // /api/v1/user/me/appointment
        queryParameters: queryParams,
      );

      print('📱 Pet Owner Appointments API Response: ${response.statusCode}');
      print('📱 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsJson = response.data;
        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to get appointments: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('❌ Pet Owner Appointments API Error: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Pet Owner Appointments Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(int appointmentId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.getAppointmentByIdUrl(appointmentId),
      );

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to cancel appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Service Provider appointment endpoints

  // Get appointments for specific service
  Future<List<AppointmentModel>> getServiceAppointments(
    int serviceId, {
    AppointmentStatus? status,
    String? timeFilter,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = _statusToString(status);
      }
      if (timeFilter != null) {
        queryParams['timeFilter'] = timeFilter;
      }

      final response = await _dio.get(
        ApiConstants.getProviderServiceAppointmentsUrl(serviceId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsJson = response.data;
        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to get service appointments: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get all appointments for provider
  Future<List<AppointmentModel>> getProviderAppointments({
    AppointmentStatus? status,
    String? timeFilter,
  }) async {
    try {
      print('🔍 Getting provider appointments with filters - Status: $status, TimeFilter: $timeFilter');
      
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = _statusToString(status);
      }
      if (timeFilter != null) {
        queryParams['timeFilter'] = timeFilter;
      }

      final response = await _dio.get(
        ApiConstants.providerAppointments, // /api/v1/provider/me/appointment
        queryParameters: queryParams,
      );

      print('🏥 Provider Appointments API Response: ${response.statusCode}');
      print('🏥 Response data: ${response.data}');
      print('🏥 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Handle null response data
        if (response.data == null) {
          print('⚠️ Provider appointments response data is null, returning empty list');
          return [];
        }
        
        // Handle different response formats
        if (response.data is List) {
          final List<dynamic> appointmentsJson = response.data as List<dynamic>;
          return appointmentsJson.map((json) {
            if (json == null) {
              print('⚠️ Null appointment data found, skipping');
              return null;
            }
            if (json is! Map<String, dynamic>) {
              print('⚠️ Invalid appointment data format: ${json.runtimeType}, skipping');
              return null;
            }
            try {
              return AppointmentModel.fromJson(json);
            } catch (e) {
              print('❌ Error parsing appointment: $e');
              return null;
            }
          }).where((appointment) => appointment != null).cast<AppointmentModel>().toList();
        } else {
          print('⚠️ Provider appointments response is not a list: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception(
          'Failed to get provider appointments: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('❌ Provider Appointments API Error: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 404) {
        print('ℹ️ No appointments found for provider, returning empty list');
        return [];
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Provider Appointments Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Get provider appointment by ID
  Future<AppointmentModel> getProviderAppointmentById(int appointmentId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getProviderAppointmentByIdUrl(appointmentId),
      );

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get appointment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Approve appointment (Service Provider)
  Future<AppointmentModel> approveAppointment(
    int appointmentId,
    ApproveAppointmentRequest request,
  ) async {
    try {
      print('✅ Approving appointment $appointmentId with data: ${request.toJson()}');
      
      final response = await _dio.patch(
        ApiConstants.approveAppointmentUrl(appointmentId), // /api/v1/provider/me/appointment/{id}/approve
        data: request.toJson(),
      );

      print('✅ Approve Appointment API Response: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to approve appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('❌ Approve Appointment API Error: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid appointment data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Approve Appointment Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Disapprove appointment (using the new disapprove endpoint)
  Future<AppointmentModel> disapproveAppointment(
    int appointmentId,
    RejectAppointmentRequest request,
  ) async {
    try {
      print('❌ Disapproving appointment $appointmentId with data: ${request.toJson()}');
      
      final response = await _dio.patch(
        ApiConstants.disapproveAppointmentUrl(appointmentId), // /api/v1/provider/me/appointment/{id}/disapprove
        data: request.toJson(),
      );

      print('❌ Disapprove Appointment API Response: ${response.statusCode}');
      print('❌ Response data: ${response.data}');

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to disapprove appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('❌ Disapprove Appointment API Error: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid rejection reason');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Disapprove Appointment Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Reject appointment (legacy method - keeping for backward compatibility)
  Future<AppointmentModel> rejectAppointment(
    int appointmentId,
    RejectAppointmentRequest request,
  ) async {
    // Use the new disapprove endpoint
    return await disapproveAppointment(appointmentId, request);
  }

  // Complete appointment
  Future<AppointmentModel> completeAppointment(int appointmentId) async {
    try {
      final response = await _dio.patch(
        ApiConstants.completeAppointmentUrl(appointmentId),
      );

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to complete appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to convert status enum to string
  String _statusToString(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'PENDING';
      case AppointmentStatus.approved:
        return 'APPROVED';
      case AppointmentStatus.completed:
        return 'COMPLETED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
