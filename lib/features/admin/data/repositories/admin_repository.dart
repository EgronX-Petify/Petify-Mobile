import '../services/admin_service.dart';
import '../../../authentication/data/models/user_model.dart';

class AdminRepository {
  final AdminService _adminService;

  AdminRepository(this._adminService);

  // User management
  Future<List<UserModel>> getAllUsers({UserStatus? status}) async {
    final response = await _adminService.getAllUsers(status: status);
    return response.users;
  }

  Future<List<UserModel>> getPendingProviders() async {
    final response = await _adminService.getPendingServiceProviders();
    return response.pendingProviders;
  }

  Future<void> approveServiceProvider(int userId) async {
    await _adminService.approveServiceProvider(userId);
  }

  Future<void> banUser(int userId) async {
    await _adminService.banUser(userId);
  }

  Future<void> unbanUser(int userId) async {
    await _adminService.unbanUser(userId);
  }

  // Content management
  Future<void> removeProduct(int productId) async {
    await _adminService.removeProduct(productId);
  }

  Future<void> removeService(int serviceId) async {
    await _adminService.removeService(serviceId);
  }

  // Analytics
  Future<Map<String, int>> getUserCounts() async {
    final response = await _adminService.getUserCounts();
    return {
      'total': response.totalUsers,
      'active': response.activeUsers,
      'banned': response.bannedUsers,
      'pending': response.pendingServiceProviders,
      'providers': response.totalServiceProviders,
    };
  }
}
