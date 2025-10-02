import 'package:dio/dio.dart';
import 'dio_factory.dart';

abstract class BaseApiService {
  final Dio _dio = DioFactory.dio;
  
  Dio get dio => _dio;
  
  // Common error handling
  Exception handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Exception('Bad request: ${e.response?.data['message'] ?? 'Invalid data'}');
      case 401:
        return Exception('Unauthorized: Please login again');
      case 403:
        return Exception('Forbidden: Access denied');
      case 404:
        return Exception('Not found: Resource does not exist');
      case 409:
        return Exception('Conflict: ${e.response?.data['message'] ?? 'Resource already exists'}');
      case 422:
        return Exception('Validation error: ${e.response?.data['message'] ?? 'Invalid data'}');
      case 500:
        return Exception('Server error: Please try again later');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
  
  // Common success response handling
  T handleResponse<T>(Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return fromJson(response.data);
    } else {
      throw Exception('Request failed: ${response.statusMessage}');
    }
  }
  
  // Handle list responses
  List<T> handleListResponse<T>(Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data is List ? response.data : response.data['data'] ?? [];
      return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Request failed: ${response.statusMessage}');
    }
  }
}
