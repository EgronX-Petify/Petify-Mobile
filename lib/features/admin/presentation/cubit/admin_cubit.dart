import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/admin_repository.dart';
import '../../../authentication/data/models/user_model.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit(this._repository) : super(AdminInitial());

  // User management
  Future<void> loadAllUsers({UserStatus? status}) async {
    emit(AdminLoading());
    try {
      final users = await _repository.getAllUsers(status: status);
      emit(UsersLoaded(users));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> loadPendingProviders() async {
    emit(AdminLoading());
    try {
      final providers = await _repository.getPendingProviders();
      emit(PendingProvidersLoaded(providers));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> approveServiceProvider(int userId) async {
    try {
      await _repository.approveServiceProvider(userId);
      emit(ProviderApproved('Service provider approved successfully'));
      // Reload pending providers
      loadPendingProviders();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> banUser(int userId) async {
    try {
      await _repository.banUser(userId);
      emit(UserBanned('User banned successfully'));
      // Reload users
      loadAllUsers();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> unbanUser(int userId) async {
    try {
      await _repository.unbanUser(userId);
      emit(UserUnbanned('User unbanned successfully'));
      // Reload users
      loadAllUsers();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  // Content management
  Future<void> removeProduct(int productId) async {
    try {
      await _repository.removeProduct(productId);
      emit(ProductRemoved('Product removed successfully'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> removeService(int serviceId) async {
    try {
      await _repository.removeService(serviceId);
      emit(ServiceRemoved('Service removed successfully'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  // Analytics
  Future<void> loadUserCounts() async {
    try {
      final userCounts = await _repository.getUserCounts();
      emit(UserCountsLoaded(userCounts));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
