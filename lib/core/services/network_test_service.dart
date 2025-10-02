import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class NetworkTestService {
  static Future<void> testConnection() async {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    print('🔍 TESTING NETWORK CONNECTION...');
    print('🔍 Base URL: ${ApiConstants.baseUrl}');
    print('🔍 Full API URL: ${ApiConstants.fullBaseUrl}');
    
    try {
      // Test basic connectivity to base URL
      print('🔍 Testing base URL connectivity...');
      final response = await dio.get(ApiConstants.baseUrl);
      print('✅ Base URL accessible: ${response.statusCode}');
    } catch (e) {
      print('❌ Base URL not accessible: $e');
    }
    
    try {
      // Test API endpoint
      print('🔍 Testing API endpoint...');
      final response = await dio.get('${ApiConstants.fullBaseUrl}/health');
      print('✅ API endpoint accessible: ${response.statusCode}');
    } catch (e) {
      print('❌ API endpoint not accessible: $e');
    }
    
    try {
      // Test service categories endpoint (no auth required)
      print('🔍 Testing service categories endpoint...');
      final response = await dio.get('${ApiConstants.fullBaseUrl}${ApiConstants.serviceCategories}');
      print('✅ Service categories accessible: ${response.statusCode}');
      print('✅ Response: ${response.data}');
    } catch (e) {
      print('❌ Service categories not accessible: $e');
    }
  }
  
  static Future<void> testLoginEndpoint() async {
    final dio = Dio();
    
    print('🔍 TESTING LOGIN ENDPOINT...');
    
    try {
      // Test login endpoint with invalid data to see if it responds
      final response = await dio.post(
        '${ApiConstants.fullBaseUrl}${ApiConstants.login}',
        data: {'test': 'connection'},
        options: Options(
          headers: ApiConstants.defaultHeaders,
        ),
      );
      print('✅ Login endpoint responded: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          print('✅ Login endpoint accessible but returned error: ${e.response!.statusCode}');
          print('✅ Error response: ${e.response!.data}');
        } else {
          print('❌ Cannot reach login endpoint: ${e.message}');
          print('❌ Error type: ${e.type}');
        }
      } else {
        print('❌ Unexpected error: $e');
      }
    }
  }
}
