import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class DioFactory {
  static Dio? _dio;
  
  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }
  
  static Dio _createDio() {
    final dio = Dio();
    
    // Base configuration
    dio.options = BaseOptions(
      baseUrl: ApiConstants.fullBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: ApiConstants.defaultHeaders,
    );
    
    // Add interceptors
    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_LoggingInterceptor());
    
    return dio;
  }
  
  // Method to reset dio instance (useful for testing or changing base URL)
  static void reset() {
    _dio = null;
  }
}

class _AuthInterceptor extends Interceptor {
  static bool _isRefreshing = false;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add authorization header if token exists (except for refresh token endpoint)
    if (options.path != ApiConstants.refreshToken) {
      final token = await SecureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        print('🔑 Auth Interceptor: Added Bearer token to ${options.path}');
      } else {
        print('⚠️ Auth Interceptor: No token found for ${options.path}');
      }
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('🚨 Auth Interceptor: Error ${err.response?.statusCode} on ${err.requestOptions.path}');
    
    // Don't try to refresh token for logout or refresh endpoints
    if (err.requestOptions.path == ApiConstants.logout || 
        err.requestOptions.path == ApiConstants.refreshToken) {
      print('🚨 Auth Interceptor: Skipping token refresh for ${err.requestOptions.path}');
      handler.next(err);
      return;
    }
    
    // Handle 401 Unauthorized - token might be expired
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      print('🔄 Auth Interceptor: Attempting token refresh for 401 error');
      _isRefreshing = true;
      
      try {
        // Try to refresh token using HTTP-only cookie
        final newToken = await _refreshToken();
        if (newToken != null) {
          print('✅ Auth Interceptor: Token refresh successful, retrying request');
          // Save new token
          await SecureStorageService.saveToken(newToken);
          
          // Retry the original request with new token
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          
          final response = await DioFactory.dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        }
        
        // If we reach here, refresh failed
        print('❌ Auth Interceptor: Token refresh failed, clearing storage');
        await SecureStorageService.clearAll();
      } catch (e) {
        // Refresh failed, clear tokens
        print('❌ Auth Interceptor: Token refresh error: $e');
        await SecureStorageService.clearAll();
      } finally {
        _isRefreshing = false;
      }
    }
    
    handler.next(err);
  }
  
  Future<String?> _refreshToken() async {
    try {
      // Create a new Dio instance to avoid interceptor loops
      final dio = Dio();
      dio.options = BaseOptions(
        baseUrl: ApiConstants.fullBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: ApiConstants.defaultHeaders,
      );

      final response = await dio.post(
        ApiConstants.refreshToken,
      );

      if (response.statusCode == 200) {
        // API returns { token: "..." }
        return response.data['token'] as String?;
      }
    } catch (e) {
      print('❌ Token refresh failed: $e');
      return null;
    }
    return null;
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => FULL URL: ${options.uri}');
    print('🚀 REQUEST PATH: ${options.path}');
    print('🚀 REQUEST DATA: ${options.data}');
    print('🚀 REQUEST HEADERS: ${options.headers}');
    print('🚀 BASE URL: ${options.baseUrl}');
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('✅ RESPONSE DATA: ${response.data}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ ERROR TYPE: ${err.type}');
    print('❌ ERROR MESSAGE: ${err.message}');
    print('❌ ERROR DATA: ${err.response?.data}');
    print('❌ FULL URL: ${err.requestOptions.uri}');
    
    // Additional debugging for connection issues
    if (err.type == DioExceptionType.connectionTimeout) {
      print('❌ CONNECTION TIMEOUT: Check if server is running and accessible');
    } else if (err.type == DioExceptionType.receiveTimeout) {
      print('❌ RECEIVE TIMEOUT: Server is taking too long to respond');
    } else if (err.type == DioExceptionType.connectionError) {
      print('❌ CONNECTION ERROR: Cannot connect to server');
    }
    
    handler.next(err);
  }
}
