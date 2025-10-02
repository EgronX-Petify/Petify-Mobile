part of 'services_cubit.dart';

abstract class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}

// Service states
class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;
  final Map<int, List<ServiceModel>> servicesByProvider;
  final Map<int, String?> providerNames;
  
  ServicesLoaded(
    this.services, {
    Map<int, List<ServiceModel>>? servicesByProvider,
    Map<int, String?>? providerNames,
  })  : servicesByProvider = servicesByProvider ?? {},
        providerNames = providerNames ?? {};
}

class ServiceLoaded extends ServicesState {
  final ServiceModel service;
  ServiceLoaded(this.service);
}

class ServiceCategoriesLoaded extends ServicesState {
  final List<String> categories;
  ServiceCategoriesLoaded(this.categories);
}
