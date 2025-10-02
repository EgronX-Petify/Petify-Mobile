import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DebugService {
  static Future<void> debugLogin() async {
    print('🔍 DEBUGGING LOGIN PROCESS...');
    print('🔍 Base URL: ${ApiConstants.baseUrl}');
    print('🔍 Full API URL: ${ApiConstants.fullBaseUrl}');
    print('🔍 Login endpoint: ${ApiConstants.fullBaseUrl}${ApiConstants.login}');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Test 1: Check if server is reachable
    print('\n🔍 TEST 1: Checking server connectivity...');
    try {
      final response = await dio.get(ApiConstants.baseUrl);
      print('✅ Server is reachable: ${response.statusCode}');
    } catch (e) {
      print('❌ Server not reachable: $e');
      print('💡 Make sure your backend server is running on ${ApiConstants.baseUrl}');
      return;
    }
    
    // Test 2: Check API endpoint
    print('\n🔍 TEST 2: Checking API endpoint...');
    try {
      final response = await dio.get('${ApiConstants.fullBaseUrl}/service/categories');
      print('✅ API endpoint accessible: ${response.statusCode}');
      print('✅ Response: ${response.data}');
    } catch (e) {
      print('❌ API endpoint not accessible: $e');
    }
    
    // Test 3: Test login with correct credentials from Postman
    print('\n🔍 TEST 3: Testing login with Postman credentials...');
    try {
      final response = await dio.post(
        '${ApiConstants.fullBaseUrl}${ApiConstants.login}',
        data: {
          'email': 'petowner1@email.com', // From Postman collection
          'password': 'PetOwner123!',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      print('✅ Login successful: ${response.statusCode}');
      print('✅ Response: ${response.data}');
    } catch (e) {
      if (e is DioException) {
        print('❌ Login failed: ${e.type}');
        print('❌ Message: ${e.message}');
        if (e.response != null) {
          print('❌ Status: ${e.response!.statusCode}');
          print('❌ Data: ${e.response!.data}');
        }
      } else {
        print('❌ Unexpected error: $e');
      }
    }
  }
  
  static Future<void> testAllCredentials() async {
    final credentials = [
      {'email': 'admin@petify.com', 'password': 'Admin123!'},
      {'email': 'petowner1@email.com', 'password': 'PetOwner123!'},
      {'email': 'petowner2@email.com', 'password': 'PetOwner123!'},
      {'email': 'sp1@email.com', 'password': 'ServiceProvider123!'},
      {'email': 'sp2@email.com', 'password': 'ServiceProvider123!'},
    ];
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    for (final cred in credentials) {
      print('\n🔍 Testing login for: ${cred['email']}');
      try {
        final response = await dio.post(
          '${ApiConstants.fullBaseUrl}${ApiConstants.login}',
          data: cred,
          options: Options(
            headers: ApiConstants.defaultHeaders,
          ),
        );
        print('✅ Login successful for ${cred['email']}: ${response.statusCode}');
      } catch (e) {
        if (e is DioException && e.response != null) {
          print('❌ Login failed for ${cred['email']}: ${e.response!.statusCode}');
        } else {
          print('❌ Connection failed for ${cred['email']}: $e');
        }
      }
    }
  }
}
