import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../../core/services/secure_storage_service.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserModel?> getCurrentUser();
  Future<void> saveAuthData(AuthResponse authResponse);
  Future<void> clearAuthData();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._authService, this._prefs);

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
  Future<AuthResponse> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _authService.register({
        'email': email,
        'password': password,
        'name': name,
      });
      await saveAuthData(response);
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
    final userJson = _prefs.getString('current_user');
    if (userJson != null) {
      // For now, return a mock user - in real app you'd parse the JSON
      return UserModel(
        id: '1',
        email: 'user@petify.com',
        name: 'Pet Lover',
        phone: '+1234567890',
        profileImage: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<void> saveAuthData(AuthResponse authResponse) async {
    await SecureStorageService.saveToken(authResponse.token);
    await SecureStorageService.saveRefreshToken(authResponse.refreshToken);
    await SecureStorageService.saveUserData('mock_user_data');
  }

  @override
  Future<void> clearAuthData() async {
    await SecureStorageService.clearAll();
  }
}
