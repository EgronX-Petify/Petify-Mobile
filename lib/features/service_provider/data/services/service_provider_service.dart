import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../services/data/models/service_model.dart';
import '../../../appointments/data/models/appointment_model.dart';

class ServiceProviderService {
  final Dio _dio = DioFactory.dio;

  // Get provider's services
  Future<List<ServiceModel>> getProviderServices() async {
    try {
      final response = await _dio.get(ApiConstants.providerServices);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get provider services: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('❌ ServiceProviderService: DioException in getProviderServices: ${e.message}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 500) {
        print('⚠️ ServiceProviderService: Server error - returning empty services list');
        return []; // Return empty list instead of throwing for server errors
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ ServiceProviderService: Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Create a new service
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
      print('❌ ServiceProviderService: DioException in createService: ${e.message}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid service data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error: Unable to create service. Please try again later.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ ServiceProviderService: Unexpected error in createService: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Update a service
  Future<ServiceModel> updateService(
    int serviceId,
    UpdateServiceRequest request,
  ) async {
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
      } else if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Delete a service
  Future<void> deleteService(int serviceId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.getProviderServiceByIdUrl(serviceId),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get provider's appointments
  Future<List<AppointmentModel>> getProviderAppointments() async {
    try {
      print(
        '🔍 Getting provider appointments from: ${ApiConstants.providerAppointments}',
      );

      final response = await _dio.get(ApiConstants.providerAppointments);

      print('🏥 Provider Appointments API Response: ${response.statusCode}');
      print('🏥 Response data: ${response.data}');
      print('🏥 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Handle null response data
        if (response.data == null) {
          print(
            '⚠️ Provider appointments response data is null, returning empty list',
          );
          return [];
        }

        // Handle different response formats
        if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          return data
              .map((json) {
                if (json == null) {
                  print('⚠️ Null appointment data found, skipping');
                  return null;
                }
                if (json is! Map<String, dynamic>) {
                  print(
                    '⚠️ Invalid appointment data format: ${json.runtimeType}, skipping',
                  );
                  return null;
                }
                try {
                  return AppointmentModel.fromJson(json);
                } catch (e) {
                  print('❌ Error parsing appointment: $e');
                  return null;
                }
              })
              .where((appointment) => appointment != null)
              .cast<AppointmentModel>()
              .toList();
        } else {
          print(
            '⚠️ Provider appointments response is not a list: ${response.data.runtimeType}',
          );
          return [];
        }
      } else {
        throw Exception(
          'Failed to get provider appointments: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ Provider Appointments DioException: ${e.response?.statusCode} - ${e.message}',
      );
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        print('ℹ️ No appointments found for provider, returning empty list');
        return [];
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Provider Appointments Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Approve an appointment
  Future<void> approveAppointment(int appointmentId) async {
    try {
      print('✅ Approving appointment $appointmentId');

      // Use PATCH method as per API specification
      final response = await _dio.patch(
        ApiConstants.approveAppointmentUrl(
          appointmentId,
        ), // /api/v1/provider/me/appointment/{id}/approve
        data: {
          'scheduledTime':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'notes': 'Appointment confirmed',
        },
      );

      print('✅ Approve Appointment Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to approve appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ Approve Appointment Error: ${e.response?.statusCode} - ${e.message}',
      );
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Approve Appointment Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Approve an appointment with specific details
  Future<void> approveAppointmentWithDetails(
    int appointmentId,
    DateTime scheduledTime,
    String? notes,
  ) async {
    try {
      print(
        '✅ Approving appointment $appointmentId with scheduled time: $scheduledTime',
      );

      final response = await _dio.patch(
        ApiConstants.approveAppointmentUrl(
          appointmentId,
        ), // /api/v1/provider/me/appointment/{id}/approve
        data: {
          'scheduledTime': scheduledTime.toIso8601String(),
          'notes': notes ?? 'Appointment confirmed',
        },
      );

      print(
        '✅ Approve Appointment With Details Response: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to approve appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ Approve Appointment With Details Error: ${e.response?.statusCode} - ${e.message}',
      );
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Approve Appointment With Details Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Disapprove an appointment (using the new disapprove endpoint)
  Future<void> disapproveAppointment(int appointmentId, {String? rejectionReason}) async {
    try {
      print('❌ Disapproving appointment $appointmentId');

      final response = await _dio.patch(
        ApiConstants.disapproveAppointmentUrl(appointmentId), // /api/v1/provider/me/appointment/{id}/disapprove
        data: {
          'rejectionReason': rejectionReason ?? 'Appointment disapproved by provider',
        },
      );

      print('❌ Disapprove Appointment Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to disapprove appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ Disapprove Appointment Error: ${e.response?.statusCode} - ${e.message}',
      );
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Disapprove Appointment Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Reject an appointment (legacy method - keeping for backward compatibility)
  Future<void> rejectAppointment(int appointmentId, {String? rejectionReason}) async {
    // Use the new disapprove endpoint
    await disapproveAppointment(appointmentId, rejectionReason: rejectionReason);
  }

  // Complete an appointment
  Future<void> completeAppointment(int appointmentId) async {
    try {
      print('✅ Completing appointment $appointmentId');

      final response = await _dio.patch(
        ApiConstants.getProviderAppointmentByIdUrl(appointmentId),
        data: {'status': 'COMPLETED'},
      );

      print('✅ Complete Appointment Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to complete appointment: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ Complete Appointment Error: ${e.response?.statusCode} - ${e.message}',
      );
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Appointment not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Complete Appointment Unexpected Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
