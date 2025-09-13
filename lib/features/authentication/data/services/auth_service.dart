import '../models/user_model.dart';

class AuthService {
  // Mock authentication service - always succeeds!
  
  Future<AuthResponse> login(Map<String, dynamic> loginData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Create a mock user
    final mockUser = UserModel(
      id: '1',
      email: loginData['email'] ?? 'user@petify.com',
      name: 'Pet Lover',
      phone: '+1234567890',
      profileImage: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Return mock auth response
    return AuthResponse(
      user: mockUser,
      token: 'mock_jwt_token_12345',
      refreshToken: 'mock_refresh_token_67890',
    );
  }

  Future<AuthResponse> register(Map<String, dynamic> registerData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Create a mock user
    final mockUser = UserModel(
      id: '2',
      email: registerData['email'] ?? 'newuser@petify.com',
      name: registerData['name'] ?? 'New Pet Owner',
      phone: null,
      profileImage: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Return mock auth response
    return AuthResponse(
      user: mockUser,
      token: 'mock_jwt_token_54321',
      refreshToken: 'mock_refresh_token_09876',
    );
  }

  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock logout - always succeeds
  }

  Future<void> forgotPassword(Map<String, dynamic> emailData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Mock forgot password - always succeeds
  }
} 