import 'package:dio/dio.dart';
import '../../../../core/services/dio_factory.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/admin_model.dart';

class AdminService {
  final Dio _dio = DioFactory.dio;

  /// Get all users with optional status filter
  Future<AdminUsersResponse> getAllUsers({UserStatus? status}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) {
        queryParams['status'] = status.name.toUpperCase();
      }

      final response = await _dio.get(
        ApiConstants.adminUsers,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return AdminUsersResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get users: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get pending service providers awaiting approval
  Future<PendingServiceProvidersResponse> getPendingServiceProviders() async {
    try {
      final response = await _dio.get(ApiConstants.adminPendingProviders);

      if (response.statusCode == 200) {
        return PendingServiceProvidersResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get pending providers: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Approve service provider
  Future<AdminActionResponse> approveServiceProvider(int userId) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminApproveProviderUrl(userId),
      );

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to approve provider: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('User is not a pending service provider');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Ban user
  Future<AdminActionResponse> banUser(int userId) async {
    try {
      final response = await _dio.post(ApiConstants.adminBanUserUrl(userId));

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to ban user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Cannot ban this user');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Unban user
  Future<AdminActionResponse> unbanUser(int userId) async {
    try {
      final response = await _dio.post(ApiConstants.adminUnbanUserUrl(userId));

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to unban user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('User is not banned');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Remove product
  Future<AdminActionResponse> removeProduct(int productId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.adminRemoveProductUrl(productId),
      );

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to remove product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Remove service
  Future<AdminActionResponse> removeService(int serviceId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.adminRemoveServiceUrl(serviceId),
      );

      if (response.statusCode == 200) {
        return AdminActionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to remove service: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Service not found');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user status counts
  Future<UserCountsResponse> getUserCounts() async {
    try {
      final response = await _dio.get(ApiConstants.adminUserCounts);

      if (response.statusCode == 200) {
        return UserCountsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get user counts: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Admin role required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get active users
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final response = await getAllUsers(status: UserStatus.active);
      return response.users;
    } catch (e) {
      throw Exception('Failed to get active users: $e');
    }
  }

  /// Get banned users
  Future<List<UserModel>> getBannedUsers() async {
    try {
      final response = await getAllUsers(status: UserStatus.banned);
      return response.users;
    } catch (e) {
      throw Exception('Failed to get banned users: $e');
    }
  }

  /// Get inactive users
  Future<List<UserModel>> getInactiveUsers() async {
    try {
      final response = await getAllUsers(status: UserStatus.inactive);
      return response.users;
    } catch (e) {
      throw Exception('Failed to get inactive users: $e');
    }
  }
}
