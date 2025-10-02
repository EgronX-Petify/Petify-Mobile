import 'package:dio/dio.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';

class ServiceProviderService extends BaseApiService {
  
  Future<List<String>> getServiceCategories() async {
    try {
      final response = await dio.get(ApiConstants.serviceCategories);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((category) => category.toString()).toList();
      } else {
        throw Exception('Failed to get service categories');
      }
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    try {
      final response = await dio.post(
        ApiConstants.providerServices,
        data: serviceData,
      );
      return handleResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<List<Map<String, dynamic>>> getProviderServices() async {
    try {
      final response = await dio.get(ApiConstants.providerServices);
      return handleListResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateService(int serviceId, Map<String, dynamic> serviceData) async {
    try {
      final response = await dio.put(
        '${ApiConstants.providerServices}/$serviceId',
        data: serviceData,
      );
      return handleResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<void> deleteService(int serviceId) async {
    try {
      await dio.delete('${ApiConstants.providerServices}/$serviceId');
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  
  Future<List<Map<String, dynamic>>> searchServices({
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (location != null) queryParams['location'] = location;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      
      final response = await dio.get(
        ApiConstants.services,
        queryParameters: queryParams,
      );
      return handleListResponse(response, (json) => json);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
