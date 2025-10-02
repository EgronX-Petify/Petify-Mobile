part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}

// User management states
class UsersLoaded extends AdminState {
  final List<UserModel> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class PendingProvidersLoaded extends AdminState {
  final List<UserModel> providers;

  const PendingProvidersLoaded(this.providers);

  @override
  List<Object> get props => [providers];
}

class ProviderApproved extends AdminState {
  final String message;

  const ProviderApproved(this.message);

  @override
  List<Object> get props => [message];
}

class UserBanned extends AdminState {
  final String message;

  const UserBanned(this.message);

  @override
  List<Object> get props => [message];
}

class UserUnbanned extends AdminState {
  final String message;

  const UserUnbanned(this.message);

  @override
  List<Object> get props => [message];
}

// Content management states
class ProductRemoved extends AdminState {
  final String message;

  const ProductRemoved(this.message);

  @override
  List<Object> get props => [message];
}

class ServiceRemoved extends AdminState {
  final String message;

  const ServiceRemoved(this.message);

  @override
  List<Object> get props => [message];
}

// Analytics states
class UserCountsLoaded extends AdminState {
  final Map<String, int> counts;

  const UserCountsLoaded(this.counts);

  @override
  List<Object> get props => [counts];
}

