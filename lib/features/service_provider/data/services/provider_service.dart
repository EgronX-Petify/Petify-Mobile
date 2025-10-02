import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../services/data/models/service_model.dart';
import '../../../appointments/data/models/appointment_model.dart';

class ProviderService {
  final Dio _dio = DioFactory.dio;

  /// Get services for current provider
  Future<List<ServiceModel>> getMyServices() async {
    try {
      final response = await _dio.get(ApiConstants.providerServices);

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = response.data;
        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Service provider role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create new service
  Future<ServiceModel> createService(CreateServiceRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.providerServices,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return ServiceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid service data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Service provider role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update service
  Future<ServiceModel> updateService(int serviceId, CreateServiceRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.getProviderServiceByIdUrl(serviceId),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ServiceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid service data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete service
  Future<void> deleteService(int serviceId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.getProviderServiceByIdUrl(serviceId),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get appointments for provider
  Future<AppointmentsResponse> getProviderAppointments({
    AppointmentStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (status != null) {
        queryParams['status'] = status.name.toUpperCase();
      }

      final response = await _dio.get(
        ApiConstants.providerAppointments,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return AppointmentsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get appointments: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Service provider role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Approve appointment
  Future<AppointmentModel> approveAppointment(
    int appointmentId,
    ApproveAppointmentRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        ApiConstants.approveAppointmentUrl(appointmentId),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to approve appointment: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid appointment data');
      } else if (e.response?.statusCode == 401) {
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
      final response = await getProviderAppointments(status: AppointmentStatus.pending);
      return response.appointments;
    } catch (e) {
      throw Exception('Failed to get pending appointments: $e');
    }
  }

  /// Get approved appointments
  Future<List<AppointmentModel>> getApprovedAppointments() async {
    try {
      final response = await getProviderAppointments(status: AppointmentStatus.approved);
      return response.appointments;
    } catch (e) {
      throw Exception('Failed to get approved appointments: $e');
    }
  }

  /// Get completed appointments
  Future<List<AppointmentModel>> getCompletedAppointments() async {
    try {
      final response = await getProviderAppointments(status: AppointmentStatus.completed);
      return response.appointments;
    } catch (e) {
      throw Exception('Failed to get completed appointments: $e');
    }
  }
}
