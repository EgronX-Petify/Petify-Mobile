import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> with ChangeNotifier {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  @override
  void emit(AuthState state) {
    super.emit(state);
    notifyListeners();
  }

  /// Check authentication status and load complete user data
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final completeData = await _authService.loadCompleteUserData();
        if (completeData != null) {
          emit(AuthAuthenticated(
            user: completeData.user,
            pets: completeData.pets,
            token: completeData.token,
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Complete login flow: authenticate, load profile, load pets
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final completeResponse = await _authService.loginComplete({
        'email': email,
        'password': password,
      });
      
      emit(AuthAuthenticated(
        user: completeResponse.user,
        pets: completeResponse.pets,
        token: completeResponse.token,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Register user (returns success message, requires separate login)
  Future<void> register(String email, String password, {String role = 'PET_OWNER'}) async {
    emit(AuthLoading());
    try {
      final registerResponse = await _authService.register({
        'email': email,
        'password': password,
        'role': role,
      });
      
      emit(AuthRegistrationSuccess(registerResponse.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    print('🔄 AuthCubit: Starting logout process');
    
    try {
      print('🔄 AuthCubit: Calling auth service logout');
      await _authService.logout();
      print('🔄 AuthCubit: Auth service logout completed successfully');
      
      // Always emit unauthenticated after logout, regardless of API response
      emit(AuthUnauthenticated());
      print('✅ AuthCubit: Emitted AuthUnauthenticated state - logout complete');
    } catch (e) {
      // Even if logout fails, we should still clear the state
      // The AuthService already handles clearing local storage
      print('❌ AuthCubit: Logout error (handled): $e');
      emit(AuthUnauthenticated());
      print('✅ AuthCubit: Emitted AuthUnauthenticated state after error - logout complete');
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        final updatedUser = await _authService.updateProfile(profileData);
        emit(AuthAuthenticated(
          user: updatedUser,
          pets: currentState.pets,
          token: currentState.token,
        ));
      } catch (e) {
        // Restore previous state on error
        emit(currentState);
        emit(AuthError(e.toString()));
      }
    }
  }

  /// Update user data in the current authenticated state
  Future<void> updateUserData(UserModel updatedUser) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthAuthenticated(
        user: updatedUser,
        pets: currentState.pets,
        token: currentState.token,
      ));
    }
  }

  /// Refresh pets data
  Future<void> refreshPets() async {
    final currentState = state;
    if (currentState is AuthAuthenticated && 
        currentState.user.role == UserRole.petOwner) {
      try {
        final completeData = await _authService.loadCompleteUserData();
        if (completeData != null) {
          emit(AuthAuthenticated(
            user: completeData.user,
            pets: completeData.pets,
            token: completeData.token,
          ));
        }
      } catch (e) {
        // Don't emit error for pet refresh failure, just keep current state
        print('Failed to refresh pets: $e');
      }
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      final response = await _authService.forgotPassword({'email': email});
      emit(AuthForgotPasswordSuccess(response.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Change password
  Future<void> changePassword(String token, String newPassword) async {
    emit(AuthLoading());
    try {
      final response = await _authService.changePassword({
        'token': token,
        'newPassword': newPassword,
      });
      emit(AuthPasswordChanged(response.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    try {
      await _authService.refreshToken();
      // Token is automatically saved in the service
      // No need to change the current state
    } catch (e) {
      // If token refresh fails, user needs to login again
      emit(AuthUnauthenticated());
    }
  }

  /// Clear any error state and return to previous state
  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }

  /// Get user by ID (for viewing other users)
  Future<UserModel?> getUserById(int userId) async {
    try {
      return await _authService.getUserById(userId);
    } catch (e) {
      print('Failed to get user by ID: $e');
      return null;
    }
  }
}
