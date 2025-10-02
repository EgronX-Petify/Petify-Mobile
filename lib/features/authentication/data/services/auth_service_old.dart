// import 'package:dio/dio.dart';
// import '../../../../core/services/dio_factory.dart';
// import '../../../../core/constants/api_constants.dart';
// import '../../../../core/services/secure_storage_service.dart';
// import '../models/user_model.dart';

// class AuthService {
//   final Dio _dio = DioFactory.dio;

//   Future<AuthResponse> login(Map<String, dynamic> loginData) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.login,
//         data: {'email': loginData['email'], 'password': loginData['password']},
//       );

//       if (response.statusCode == 200) {
//         print("Login response received - Status: ${response.statusCode}");
//         print("Response data: ${response.data}");

//         // Parse login response (only contains token)
//         final loginResponse = LoginResponse.fromJson(response.data);
        
//         // Save token to secure storage
//         await SecureStorageService.saveToken(loginResponse.token);
        
//         // Get user profile after successful login
//         final user = await getCurrentUser();
        
//         return AuthResponse(
//           token: loginResponse.token,
//           user: user,
//         );
//       } else {
//         throw Exception('Login failed: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) {
//         throw Exception('Invalid credentials');
//       } else if (e.response?.statusCode == 400) {
//         throw Exception('Invalid request data');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<RegisterResponse> register(Map<String, dynamic> registerData) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.signup,
//         data: {
//           'email': registerData['email'],
//           'password': registerData['password'],
//           'role': registerData['role'] ?? 'PET_OWNER',
//         },
//       );

//       if (response.statusCode == 201) {
//         return RegisterResponse.fromJson(response.data);
//       } else {
//         throw Exception('Registration failed: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 409) {
//         throw Exception('User already exists');
//       } else if (e.response?.statusCode == 400) {
//         throw Exception('Invalid request data');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<void> logout() async {
//     try {
//       // Call logout endpoint if token exists
//       final token = await SecureStorageService.getToken();
//       if (token != null && token.isNotEmpty) {
//         try {
//           await _dio.post(ApiConstants.logout);
//           print('✅ Logout API call successful');
//         } catch (apiError) {
//           // Log the API error but don't throw - we still want to clear local storage
//           print('⚠️ Logout API failed but continuing with local cleanup: $apiError');
//         }
//       }
//     } catch (e) {
//       print('❌ Error during logout process: $e');
//     } finally {
//       // Always clear local storage regardless of API response
//       await SecureStorageService.clearAll();
//       print('✅ Local storage cleared successfully');
//     }
//   }

//   Future<ForgotPasswordResponse> forgotPassword(Map<String, dynamic> emailData) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.forgotPassword,
//         data: {'email': emailData['email']},
//       );

//       if (response.statusCode == 201) {
//         return ForgotPasswordResponse.fromJson(response.data);
//       } else {
//         throw Exception(
//           'Failed to send reset email: ${response.statusMessage}',
//         );
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 404) {
//         throw Exception('Email not found');
//       } else if (e.response?.statusCode == 400) {
//         throw Exception('Invalid email format');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<ChangePasswordResponse> changePassword(Map<String, dynamic> changePasswordData) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.changePassword,
//         data: {
//           'token': changePasswordData['token'],
//           'newPassword': changePasswordData['newPassword'],
//         },
//       );

//       if (response.statusCode == 202) {
//         return ChangePasswordResponse.fromJson(response.data);
//       } else {
//         throw Exception(
//           'Failed to change password: ${response.statusMessage}',
//         );
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 400) {
//         throw Exception('Invalid token or password');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<LoginResponse> refreshToken() async {
//     try {
//       final response = await _dio.post(ApiConstants.refreshToken);

//       if (response.statusCode == 200) {
//         final loginResponse = LoginResponse.fromJson(response.data);
//         await SecureStorageService.saveToken(loginResponse.token);
//         return loginResponse;
//       } else {
//         throw Exception('Token refresh failed: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 401) {
//         // Refresh token expired, need to login again
//         await SecureStorageService.clearAll();
//         throw Exception('Session expired, please login again');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<UserModel?> getCurrentUser() async {
//     try {
//       final response = await _dio.get(ApiConstants.userProfile);

//       if (response.statusCode == 200) {
//         final user = UserModel.fromJson(response.data);
//         // Save user data to secure storage
//         await SecureStorageService.saveUserData(user.toJson().toString());
//         return user;
//       }
//     } catch (e) {
//       print('Failed to get current user: $e');
//     }
//     return null;
//   }

//   Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
//     try {
//       final response = await _dio.put(
//         ApiConstants.updateProfile,
//         data: profileData,
//       );

//       if (response.statusCode == 200) {
//         final user = UserModel.fromJson(response.data);
//         await SecureStorageService.saveUserData(user.toJson().toString());
//         return user;
//       } else {
//         throw Exception('Profile update failed: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 400) {
//         throw Exception('Invalid profile data');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<UserModel> getUserById(int userId) async {
//     try {
//       final response = await _dio.get(ApiConstants.getUserByIdUrl(userId));

//       if (response.statusCode == 200) {
//         return UserModel.fromJson(response.data);
//       } else {
//         throw Exception('Failed to get user: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 404) {
//         throw Exception('User not found');
//       } else {
//         throw Exception('Network error: ${e.message}');
//       }
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<bool> isLoggedIn() async {
//     return await SecureStorageService.hasToken();
//   }
// }
