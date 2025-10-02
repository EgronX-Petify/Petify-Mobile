import '../models/service_model.dart';
import '../services/service_service.dart';

abstract class ServiceRepository {
  // Public service methods
  Future<List<ServiceModel>> searchServices(String searchTerm);
  Future<List<ServiceCategory>> getServiceCategories();
  Future<List<ServiceModel>> getServices({ServiceCategory? category, int? providerId});
  Future<ServiceModel> getServiceById(int serviceId);
  Future<List<ServiceModel>> getServicesByProviderId(int providerId);
  
  // Provider service methods (requires SERVICE_PROVIDER role)
  Future<List<ServiceModel>> getProviderServices();
  Future<ServiceModel> createService(CreateServiceRequest request);
  Future<ServiceModel> updateService(int serviceId, UpdateServiceRequest request);
  Future<void> deleteService(int serviceId);
}

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceService _serviceService;

  ServiceRepositoryImpl(this._serviceService);

  @override
  Future<List<ServiceModel>> searchServices(String searchTerm) async {
    try {
      return await _serviceService.searchServices(searchTerm);
    } catch (e) {
      throw Exception('Failed to search services: ${e.toString()}');
    }
  }

  @override
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      return await _serviceService.getServiceCategories();
    } catch (e) {
      throw Exception('Failed to get service categories: ${e.toString()}');
    }
  }

  @override
  Future<List<ServiceModel>> getServices({ServiceCategory? category, int? providerId}) async {
    try {
      return await _serviceService.getServices(category: category, providerId: providerId);
    } catch (e) {
      throw Exception('Failed to get services: ${e.toString()}');
    }
  }

  @override
  Future<ServiceModel> getServiceById(int serviceId) async {
    try {
      return await _serviceService.getServiceById(serviceId);
    } catch (e) {
      throw Exception('Failed to get service: ${e.toString()}');
    }
  }

  @override
  Future<List<ServiceModel>> getServicesByProviderId(int providerId) async {
    try {
      return await _serviceService.getServicesByProviderId(providerId);
    } catch (e) {
      throw Exception('Failed to get services for provider: ${e.toString()}');
    }
  }

  @override
  Future<List<ServiceModel>> getProviderServices() async {
    try {
      return await _serviceService.getProviderServices();
    } catch (e) {
      throw Exception('Failed to get provider services: ${e.toString()}');
    }
  }

  @override
  Future<ServiceModel> createService(CreateServiceRequest request) async {
    try {
      return await _serviceService.createService(request);
    } catch (e) {
      throw Exception('Failed to create service: ${e.toString()}');
    }
  }

  @override
  Future<ServiceModel> updateService(int serviceId, UpdateServiceRequest request) async {
    try {
      return await _serviceService.updateService(serviceId, request);
    } catch (e) {
      throw Exception('Failed to update service: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteService(int serviceId) async {
    try {
      await _serviceService.deleteService(serviceId);
    } catch (e) {
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }
}
