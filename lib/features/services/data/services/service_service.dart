import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/service_model.dart';
import '../models/service_provider_model.dart';

class ServiceService {
  final Dio _dio = DioFactory.dio;

  // Public service endpoints

  // Search services by term
  Future<List<ServiceModel>> searchServices(String searchTerm) async {
    try {
      final response = await _dio.get(
        ApiConstants.serviceSearch,
        queryParameters: {'searchTerm': searchTerm},
      );

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = response.data;
        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get all service categories
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final response = await _dio.get(ApiConstants.serviceCategories);

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = response.data;
        return categoriesJson.map((categoryStr) {
          switch (categoryStr) {
            case 'VET':
              return ServiceCategory.vet;
            case 'GROOMING':
              return ServiceCategory.grooming;
            case 'TRAINING':
              return ServiceCategory.training;
            case 'BOARDING':
              return ServiceCategory.boarding;
            case 'WALKING':
              return ServiceCategory.walking;
            case 'SITTING':
              return ServiceCategory.sitting;
            case 'VACCINATION':
              return ServiceCategory.vaccination;
            case 'OTHER':
              return ServiceCategory.other;
            default:
              return ServiceCategory.other;
          }
        }).toList();
      } else {
        throw Exception('Failed to get categories: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get all services (new primary method)
  Future<List<ServiceModel>> getAllServices({ServiceCategory? category}) async {
    try {
      print('🔍 ServiceService: Loading all services from ${ApiConstants.services}');
      
      final queryParams = <String, dynamic>{};
      if (category != null) {
        queryParams['category'] = _categoryToString(category);
      }

      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        print('✅ ServiceService: Successfully loaded services');
        final List<dynamic> servicesJson = response.data;
        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ ServiceService: DioException loading services: ${e.message}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ ServiceService: Unexpected error loading services: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Get services with filters (legacy method, now uses getAllServices)
  Future<List<ServiceModel>> getServices({
    ServiceCategory? category,
    int? providerId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) {
        queryParams['category'] = _categoryToString(category);
      }
      if (providerId != null) {
        queryParams['providerId'] = providerId;
      }

      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = response.data;
        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && providerId != null) {
        // If provider not found, return empty list instead of throwing error
        print('⚠️ Provider with ID $providerId not found, returning empty list');
        return [];
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get service by ID
  Future<ServiceModel> getServiceById(int serviceId) async {
    try {
      final response = await _dio.get(ApiConstants.getServiceByIdUrl(serviceId));

      if (response.statusCode == 200) {
        return ServiceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Provider service endpoints (requires SERVICE_PROVIDER role)

  // Get services for current provider
  Future<List<ServiceModel>> getProviderServices() async {
    try {
      final response = await _dio.get(ApiConstants.providerServices);

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = response.data;
        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get provider services: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Create new service
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
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid service data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Update service
  Future<ServiceModel> updateService(int serviceId, UpdateServiceRequest request) async {
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
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied - SERVICE_PROVIDER role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid service data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Delete service
  Future<void> deleteService(int serviceId) async {
    try {
      final response = await _dio.delete(ApiConstants.getProviderServiceByIdUrl(serviceId));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete service: ${response.statusMessage}');
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

  // New provider-based endpoints

  // Get all service providers
  Future<List<ServiceProviderModel>> getAllServiceProviders() async {
    try {
      print('🔍 ServiceService: Loading all service providers from ${ApiConstants.serviceProviders}');
      
      final response = await _dio.get(ApiConstants.serviceProviders);

      if (response.statusCode == 200) {
        print('✅ ServiceService: Successfully loaded providers');
        final List<dynamic> providersJson = response.data;
        return providersJson.map((json) => ServiceProviderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get service providers: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ ServiceService: DioException loading providers: ${e.message}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        print('⚠️ ServiceService: 403 Forbidden - endpoint may require authentication or specific permissions');
        // Return empty list for 403 errors to prevent app crashes
        return [];
      } else if (e.response?.statusCode == 404) {
        print('⚠️ ServiceService: 404 Not Found - returning empty providers list');
        return [];
      } else if (e.response?.statusCode == 500) {
        print('⚠️ ServiceService: Server error - returning empty providers list');
        return [];
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ ServiceService: Unexpected error loading providers: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Get service provider by ID
  Future<ServiceProviderModel> getServiceProviderById(int providerId) async {
    try {
      print('🔍 ServiceService: Loading provider $providerId');
      
      final response = await _dio.get(ApiConstants.getServiceProviderByIdUrl(providerId));

      if (response.statusCode == 200) {
        print('✅ ServiceService: Successfully loaded provider $providerId');
        return ServiceProviderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get service provider: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Service provider not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get services by provider ID
  Future<List<ServiceModel>> getServicesByProviderId(int providerId) async {
    try {
      print('🔍 ServiceService: Loading services for provider $providerId');
      
      final response = await _dio.get(ApiConstants.getServicesByProviderUrl(providerId));

      if (response.statusCode == 200) {
        print('✅ ServiceService: Successfully loaded services for provider $providerId');
        final List<dynamic> servicesJson = response.data;
        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get services for provider: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('⚠️ ServiceService: Provider $providerId not found, returning empty list');
        return [];
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to convert category enum to string
  String _categoryToString(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.vet:
        return 'VET';
      case ServiceCategory.grooming:
        return 'GROOMING';
      case ServiceCategory.training:
        return 'TRAINING';
      case ServiceCategory.boarding:
        return 'BOARDING';
      case ServiceCategory.walking:
        return 'WALKING';
      case ServiceCategory.sitting:
        return 'SITTING';
      case ServiceCategory.vaccination:
        return 'VACCINATION';
      case ServiceCategory.other:
        return 'OTHER';
    }
  }
}
