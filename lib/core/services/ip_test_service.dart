import 'package:dio/dio.dart';

class IpTestService {
  static Future<void> testAllIpAddresses() async {
    final ipAddresses = [
      'http://10.0.2.2:8080',        // Android emulator
      'http://localhost:8080',        // Localhost
      'http://127.0.0.1:8080',       // Loopback
      'http://172.17.0.1:8080',      // Your original IP
      'http://192.168.1.100:8080',   // Common local network IP (adjust as needed)
    ];
    
    print('🔍 TESTING DIFFERENT IP ADDRESSES...\n');
    
    for (final baseUrl in ipAddresses) {
      print('🔍 Testing: $baseUrl');
      
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      
      try {
        // Test basic connectivity
        final response = await dio.get('$baseUrl/api/v1/service/categories');
        print('✅ SUCCESS: $baseUrl is accessible (${response.statusCode})');
        print('   Response: ${response.data}');
        return; // Stop testing once we find a working IP
      } catch (e) {
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout) {
            print('❌ TIMEOUT: $baseUrl - server not reachable');
          } else if (e.response != null) {
            print('✅ REACHABLE: $baseUrl - server responded with ${e.response!.statusCode}');
            print('   This IP works! Update your api_constants.dart');
            return;
          } else {
            print('❌ ERROR: $baseUrl - ${e.message}');
          }
        } else {
          print('❌ ERROR: $baseUrl - $e');
        }
      }
      print(''); // Empty line for readability
    }
    
    print('❌ No working IP address found. Make sure your backend server is running!');
  }
  
  static Future<void> testSpecificIp(String baseUrl) async {
    print('🔍 Testing specific IP: $baseUrl\n');
    
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Test 1: Basic connectivity
    try {
      print('🔍 Test 1: Basic connectivity...');
      final response = await dio.get(baseUrl);
      print('✅ Server is running: ${response.statusCode}');
    } catch (e) {
      print('❌ Server not accessible: $e');
      return;
    }
    
    // Test 2: API endpoint
    try {
      print('🔍 Test 2: API endpoint...');
      final response = await dio.get('$baseUrl/api/v1/service/categories');
      print('✅ API working: ${response.statusCode}');
      print('✅ Response: ${response.data}');
    } catch (e) {
      print('❌ API not working: $e');
    }
    
    // Test 3: Login endpoint
    try {
      print('🔍 Test 3: Login endpoint...');
      final response = await dio.post(
        '$baseUrl/api/v1/auth/login',
        data: {
          'email': 'petowner1@email.com',
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
      if (e is DioException && e.response != null) {
        print('✅ Login endpoint accessible: ${e.response!.statusCode}');
        print('✅ Error response: ${e.response!.data}');
      } else {
        print('❌ Login endpoint not accessible: $e');
      }
    }
  }
}
