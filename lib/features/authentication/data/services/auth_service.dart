import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';
import '../../../pets/data/models/pet_model.dart';
import '../../../pets/data/services/pet_management_service.dart';

/// Authentication service that automatically loads user profile and pets after login
/// This follows the API specification where login only returns a token, requiring separate calls
class AuthService {
  final Dio _dio = DioFactory.dio;
  final PetManagementService _petService = PetManagementService();

  /// Simple login method for repository compatibility
  Future<AuthResponse> login(Map<String, dynamic> loginData) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': loginData['email'], 'password': loginData['password']},
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await SecureStorageService.saveToken(loginResponse.token);
        return AuthResponse(token: loginResponse.token);
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Complete login flow: authenticate, get profile, load pets
  Future<CompleteAuthResponse> loginComplete(Map<String, dynamic> loginData) async {
    try {
      // Step 1: Login and get token
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': loginData['email'], 'password': loginData['password']},
      );

      if (response.statusCode == 200) {
        print("Login response received - Status: ${response.statusCode}");
        print("Response data: ${response.data}");

        // Parse login response (only contains token)
        final loginResponse = LoginResponse.fromJson(response.data);
        
        // Step 2: Save token to secure storage
        await SecureStorageService.saveToken(loginResponse.token);
        
        // Step 3: Get user profile (now that we have the token)
        final user = await getCurrentUser();
        if (user == null) {
          throw Exception('Failed to load user profile after login');
        }
        
        // Step 4: Load pets if user is PET_OWNER
        List<PetModel> pets = [];
        if (user.role == UserRole.petOwner) {
          try {
            pets = await _petService.getPets();
            print("Loaded ${pets.length} pets for user");
          } catch (e) {
            print("Failed to load pets: $e");
            // Don't fail login if pets can't be loaded
          }
        }
        
        return CompleteAuthResponse(
          token: loginResponse.token,
          user: user,
          pets: pets,
        );
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Simple register method for repository compatibility
  Future<RegisterResponse> register(Map<String, dynamic> registerData) async {
    try {
      final response = await _dio.post(
        ApiConstants.signup,
        data: {
          'email': registerData['email'],
          'password': registerData['password'],
          'role': registerData['role'] ?? 'PET_OWNER',
        },
      );

      if (response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('User already exists');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Register user (returns message only, no automatic login) - DUPLICATE METHOD
  Future<RegisterResponse> registerComplete(Map<String, dynamic> registerData) async {
    try {
      final response = await _dio.post(
        ApiConstants.signup,
        data: {
          'email': registerData['email'],
          'password': registerData['password'],
          'role': registerData['role'] ?? 'PET_OWNER',
        },
      );

      if (response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('User already exists');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Logout user and clear all local data
  Future<void> logout() async {
    try {
      // Call logout endpoint if token exists
      final token = await SecureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        // Use ResponseType.plain to handle non-JSON responses from logout endpoint
        final response = await _dio.post(
          ApiConstants.logout,
          options: Options(
            responseType: ResponseType.plain,
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        print('Logout API response: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      // Even if logout API fails, we should clear local storage
      print('Logout API failed: $e');
      if (e is DioException) {
        print('DioException details:');
        print('  Type: ${e.type}');
        print('  Message: ${e.message}');
        print('  Response: ${e.response?.data}');
        print('  Status Code: ${e.response?.statusCode}');
      }
      // Don't rethrow the error - logout should always succeed locally
    } finally {
      // Always clear local storage regardless of API response
      await SecureStorageService.clearAll();
      print('Local storage cleared successfully');
    }
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUser() async {
    try {
      print("🔍 Fetching user profile from API...");
      final token = await SecureStorageService.getToken();
      print("🔍 Current token exists: ${token != null && token.isNotEmpty}");
      
      final response = await _dio.get(ApiConstants.userProfile);

      if (response.statusCode == 200) {
        print("✅ User profile response received: ${response.data}");
        final user = UserModel.fromJson(response.data);
        print("✅ User profile parsed successfully: ${user.email}, role: ${user.role}");
        // Save user data to secure storage
        await SecureStorageService.saveUserData(user.toJson().toString());
        return user;
      } else {
        print("❌ Failed to get user profile - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print('❌ DioException in getCurrentUser: ${e.message}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        print('❌ Authentication failed - token may be invalid or expired');
        // Clear storage if authentication fails
        await SecureStorageService.clearAll();
        throw Exception('Unauthorized: Please login again');
      }
    } catch (e) {
      print('❌ Unexpected error in getCurrentUser: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is FormatException) {
        print('❌ JSON parsing error - check API response format');
      }
    }
    return null;
  }

  /// Update user profile
  Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        await SecureStorageService.saveUserData(user.toJson().toString());
        return user;
      } else {
        throw Exception('Profile update failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid profile data');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user by ID (public endpoint)
  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await _dio.get(ApiConstants.getUserByIdUrl(userId));

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Forgot password
  Future<ForgotPasswordResponse> forgotPassword(Map<String, dynamic> emailData) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': emailData['email']},
      );

      if (response.statusCode == 201) {
        return ForgotPasswordResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to send reset email: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid email format');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Change password
  Future<ChangePasswordResponse> changePassword(Map<String, dynamic> changePasswordData) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'token': changePasswordData['token'],
          'newPassword': changePasswordData['newPassword'],
        },
      );

      if (response.statusCode == 202) {
        return ChangePasswordResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to change password: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token or password');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Refresh token using HTTP-only cookie
  Future<LoginResponse> refreshToken() async {
    try {
      final response = await _dio.post(ApiConstants.refreshToken);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await SecureStorageService.saveToken(loginResponse.token);
        return loginResponse;
      } else {
        throw Exception('Token refresh failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Refresh token expired, need to login again
        await SecureStorageService.clearAll();
        throw Exception('Session expired, please login again');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await SecureStorageService.hasToken();
  }

  /// Load complete user data (profile + pets if applicable)
  Future<CompleteAuthResponse?> loadCompleteUserData() async {
    try {
      print("🔍 Loading complete user data...");
      final token = await SecureStorageService.getToken();
      print("🔍 Token from storage: ${token != null ? 'EXISTS' : 'NULL'}");
      
      if (token == null || token.isEmpty) {
        print("❌ No valid token found in storage");
        return null;
      }

      print("🔍 Attempting to get current user profile...");
      final user = await getCurrentUser();
      if (user == null) {
        print("❌ Failed to get user profile, clearing storage");
        await SecureStorageService.clearAll();
        return null;
      }

      print("✅ User profile loaded: ${user.email}, role: ${user.role}");

      List<PetModel> pets = [];
      if (user.role == UserRole.petOwner) {
        try {
          print("🔍 Loading pets for pet owner...");
          pets = await _petService.getPets();
          print("✅ Loaded ${pets.length} pets");
        } catch (e) {
          print("⚠️ Failed to load pets: $e");
          // Don't fail if pets can't be loaded
        }
      }

      return CompleteAuthResponse(
        token: token,
        user: user,
        pets: pets,
      );
    } catch (e) {
      print('❌ Failed to load complete user data: $e');
      // Clear storage if there's an error
      await SecureStorageService.clearAll();
      return null;
    }
  }
}

/// Complete authentication response including user profile and pets
class CompleteAuthResponse {
  final String token;
  final UserModel user;
  final List<PetModel> pets;

  const CompleteAuthResponse({
    required this.token,
    required this.user,
    required this.pets,
  });
}
