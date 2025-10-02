import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/service_search_service.dart';
import '../../data/services/service_service.dart';
import '../../data/models/service_model.dart';
import '../../data/models/service_provider_model.dart';

part 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServiceSearchService _serviceSearchService;
  final ServiceService _serviceService;

  ServicesCubit({
    required ServiceSearchService serviceSearchService,
    required ServiceService serviceService,
  })  : _serviceSearchService = serviceSearchService,
        _serviceService = serviceService,
        super(ServicesInitial());

  // Service search and discovery
  Future<void> searchServices(String searchTerm) async {
    emit(ServicesLoading());
    try {
      final services = await _serviceService.searchServices(searchTerm);
      
      // Group search results by provider
      final servicesByProvider = <int, List<ServiceModel>>{};
      final providerNames = <int, String?>{};
      
      for (final service in services) {
        final providerId = service.providerId;
        
        if (!servicesByProvider.containsKey(providerId)) {
          servicesByProvider[providerId] = [];
          providerNames[providerId] = service.providerName ?? 'Service Provider $providerId';
        }
        servicesByProvider[providerId]!.add(service);
      }
      
      emit(ServicesLoaded(
        services,
        servicesByProvider: servicesByProvider,
        providerNames: providerNames,
      ));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadServiceCategories() async {
    emit(ServicesLoading());
    try {
      final categoriesResponse = await _serviceSearchService.getServiceCategories();
      emit(ServiceCategoriesLoaded(categoriesResponse.categories.map((e) => e.name).toList()));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadServices({ServiceCategory? category, int? userId}) async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getServices(
        category: category,
        userId: userId,
      );
      
      // Group services by provider for caching
      final servicesByProvider = <int, List<ServiceModel>>{};
      final providerNames = <int, String?>{};
      
      for (final service in services) {
        // Use userId if available, otherwise fall back to providerId
        final groupId = service.userId ?? service.providerId;
        if (!servicesByProvider.containsKey(groupId)) {
          servicesByProvider[groupId] = [];
          providerNames[groupId] = service.providerName;
        }
        servicesByProvider[groupId]!.add(service);
      }
      
      emit(ServicesLoaded(
        services,
        servicesByProvider: servicesByProvider,
        providerNames: providerNames,
      ));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadServiceById(int serviceId) async {
    emit(ServicesLoading());
    try {
      final service = await _serviceSearchService.getServiceById(serviceId);
      emit(ServiceLoaded(service));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  // Load services by category
  Future<void> loadServicesByCategory(ServiceCategory category) async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getServicesByCategory(category);
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadServicesByProvider(int userId) async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getServicesByProvider(userId);
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  // Specialized service loading methods
  Future<void> loadVeterinaryServices() async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getVeterinaryServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadGroomingServices() async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getGroomingServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadTrainingServices() async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getTrainingServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadBoardingServices() async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getBoardingServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadWalkingServices() async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getWalkingServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadSittingServices() async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getSittingServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> loadVaccinationServices() async {
    emit(ServicesLoading());
    try {
      final services = await _serviceSearchService.getVaccinationServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  // Helper methods
  Future<void> refreshServices() async {
    await loadServices();
  }

  void clearServices() {
    emit(ServicesInitial());
  }

  // Get cached services for a specific provider
  List<ServiceModel>? getCachedServicesForProvider(int providerId) {
    final currentState = state;
    if (currentState is ServicesLoaded) {
      return currentState.servicesByProvider[providerId];
    }
    return null;
  }

  // Get cached provider name
  String? getCachedProviderName(int providerId) {
    final currentState = state;
    if (currentState is ServicesLoaded) {
      return currentState.providerNames[providerId];
    }
    return null;
  }

  // New provider-based methods

  // Load all service providers and their services using new API approach
  Future<void> loadServiceProviders({ServiceCategory? category}) async {
    emit(ServicesLoading());
    try {
      print('🔍 ServicesCubit: Loading all services from /api/v1/service...');
      
      // New approach: Get all services from /api/v1/service
      final allServices = await _serviceService.getAllServices(category: category);
      print('✅ ServicesCubit: Loaded ${allServices.length} services from API');
      
      // Group services by providerId to show service providers
      final servicesByProvider = <int, List<ServiceModel>>{};
      final providerNames = <int, String?>{};
      
      for (final service in allServices) {
        final providerId = service.providerId;
        
        if (!servicesByProvider.containsKey(providerId)) {
          servicesByProvider[providerId] = [];
          // Use provider name from service, with fallback
          providerNames[providerId] = service.providerName ?? 'Service Provider $providerId';
        }
        servicesByProvider[providerId]!.add(service);
      }
      
      print('✅ ServicesCubit: Grouped ${allServices.length} services from ${servicesByProvider.length} providers');
      
      emit(ServicesLoaded(
        allServices,
        servicesByProvider: servicesByProvider,
        providerNames: providerNames,
      ));
    } catch (e) {
      print('❌ ServicesCubit: Error loading services: $e');
      emit(ServicesError('Failed to load services. Please check your connection and try again.'));
    }
  }

  // Load services for a specific provider
  Future<void> loadServicesForProvider(int providerId) async {
    emit(ServicesLoading());
    try {
      print('🔍 ServicesCubit: Loading services for provider $providerId');
      
      final services = await _serviceService.getServicesByProviderId(providerId);
      
      // Also get provider details
      ServiceProviderModel? provider;
      try {
        provider = await _serviceService.getServiceProviderById(providerId);
      } catch (e) {
        print('⚠️ ServicesCubit: Could not load provider details: $e');
      }
      
      final servicesByProvider = <int, List<ServiceModel>>{providerId: services};
      final providerNames = <int, String?>{providerId: provider?.name ?? 'Service Provider $providerId'};
      
      emit(ServicesLoaded(
        services,
        servicesByProvider: servicesByProvider,
        providerNames: providerNames,
      ));
    } catch (e) {
      print('❌ ServicesCubit: Error loading services for provider $providerId: $e');
      emit(ServicesError(e.toString()));
    }
  }

  // Load veterinary providers and their services
  Future<void> loadVeterinaryProviders() async {
    await loadServiceProviders(category: ServiceCategory.vet);
  }
}
