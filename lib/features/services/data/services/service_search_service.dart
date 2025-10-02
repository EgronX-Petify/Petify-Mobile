import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/service_model.dart';

class ServiceSearchService {
  final Dio _dio = DioFactory.dio;

  /// Search services by term (public endpoint)
  Future<ServiceSearchResponse> searchServices(String searchTerm) async {
    try {
      final response = await _dio.get(
        ApiConstants.serviceSearch,
        queryParameters: {'searchTerm': searchTerm},
      );

      if (response.statusCode == 200) {
        return ServiceSearchResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to search services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get all service categories (public endpoint)
  Future<ServiceCategoriesResponse> getServiceCategories() async {
    try {
      final response = await _dio.get(ApiConstants.serviceCategories);

      if (response.statusCode == 200) {
        return ServiceCategoriesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get categories: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get services with filters (public endpoint)
  Future<List<ServiceModel>> getServices({
    ServiceCategory? category,
    int? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (category != null) {
        queryParams['category'] = category.name.toUpperCase();
      }
      
      if (userId != null) {
        queryParams['providerId'] = userId; // API expects 'providerId' but we pass userId
      }

      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = response.data;
        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get service by ID (public endpoint)
  Future<ServiceModel> getServiceById(int serviceId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getServiceByIdUrl(serviceId),
      );

      if (response.statusCode == 200) {
        return ServiceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get services by category
  Future<List<ServiceModel>> getServicesByCategory(ServiceCategory category) async {
    try {
      return await getServices(category: category);
    } catch (e) {
      throw Exception('Failed to get services by category: $e');
    }
  }

  /// Get services by provider (using userId)
  Future<List<ServiceModel>> getServicesByProvider(int userId) async {
    try {
      return await getServices(userId: userId);
    } catch (e) {
      throw Exception('Failed to get services by provider: $e');
    }
  }

  /// Get veterinary services
  Future<List<ServiceModel>> getVeterinaryServices() async {
    return getServicesByCategory(ServiceCategory.vet);
  }

  /// Get grooming services
  Future<List<ServiceModel>> getGroomingServices() async {
    return getServicesByCategory(ServiceCategory.grooming);
  }

  /// Get training services
  Future<List<ServiceModel>> getTrainingServices() async {
    return getServicesByCategory(ServiceCategory.training);
  }

  /// Get boarding services
  Future<List<ServiceModel>> getBoardingServices() async {
    return getServicesByCategory(ServiceCategory.boarding);
  }

  /// Get walking services
  Future<List<ServiceModel>> getWalkingServices() async {
    return getServicesByCategory(ServiceCategory.walking);
  }

  /// Get sitting services
  Future<List<ServiceModel>> getSittingServices() async {
    return getServicesByCategory(ServiceCategory.sitting);
  }

  /// Get vaccination services
  Future<List<ServiceModel>> getVaccinationServices() async {
    return getServicesByCategory(ServiceCategory.vaccination);
  }
}
