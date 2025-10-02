import 'package:equatable/equatable.dart';
import '../data/models/user_model.dart';
import '../../pets/data/models/pet_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final List<PetModel> pets;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.pets,
    required this.token,
  });

  @override
  List<Object> get props => [user, pets, token];

  /// Check if user is a pet owner
  bool get isPetOwner => user.role == UserRole.petOwner;

  /// Check if user is a service provider
  bool get isServiceProvider => user.role == UserRole.serviceProvider;

  /// Check if user is an admin
  bool get isAdmin => user.role == UserRole.admin;

  /// Get user's display name
  String get displayName => user.name ?? user.email;

  /// Check if user has pets
  bool get hasPets => pets.isNotEmpty;

  /// Get pet count
  int get petCount => pets.length;
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthForgotPasswordSuccess extends AuthState {
  final String message;

  const AuthForgotPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthPasswordChanged extends AuthState {
  final String message;

  const AuthPasswordChanged(this.message);

  @override
  List<Object> get props => [message];
}
