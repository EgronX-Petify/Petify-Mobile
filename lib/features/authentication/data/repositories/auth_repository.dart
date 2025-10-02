import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../../core/services/secure_storage_service.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<RegisterResponse> register(
    String email,
    String password, {
    String role = 'PET_OWNER',
  });
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile(Map<String, dynamic> profileData);
  Future<UserModel> getUserById(int userId);
  Future<ForgotPasswordResponse> forgotPassword(String email);
  Future<ChangePasswordResponse> changePassword(
    String token,
    String newPassword,
  );
  Future<LoginResponse> refreshToken();
  Future<void> saveAuthData(AuthResponse authResponse);
  Future<void> clearAuthData();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _authService.login({
        'email': email,
        'password': password,
      });
      await saveAuthData(response);
      return response;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<RegisterResponse> register(
    String email,
    String password, {
    String role = 'PET_OWNER',
  }) async {
    try {
      final response = await _authService.register({
        'email': email,
        'password': password,
        'role': role,
      });
      return response;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with local logout even if server logout fails
    } finally {
      await clearAuthData();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await SecureStorageService.hasToken();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      print('Failed to get current user: $e');
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      return await _authService.updateProfile(profileData);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserById(int userId) async {
    try {
      return await _authService.getUserById(userId);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      return await _authService.forgotPassword({'email': email});
    } catch (e) {
      throw Exception('Forgot password failed: ${e.toString()}');
    }
  }

  @override
  Future<ChangePasswordResponse> changePassword(
    String token,
    String newPassword,
  ) async {
    try {
      return await _authService.changePassword({
        'token': token,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Change password failed: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponse> refreshToken() async {
    try {
      return await _authService.refreshToken();
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  @override
  Future<void> saveAuthData(AuthResponse authResponse) async {
    await SecureStorageService.saveToken(authResponse.token);
    // AuthResponse only contains token, user data is loaded separately via /user/me
  }

  @override
  Future<void> clearAuthData() async {
    await SecureStorageService.clearAll();
  }
}
