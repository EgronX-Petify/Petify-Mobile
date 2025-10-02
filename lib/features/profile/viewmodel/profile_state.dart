import 'package:equatable/equatable.dart';
import '../../authentication/data/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final List<UserImageModel> images;

  const ProfileLoaded({
    required this.user,
    required this.images,
  });

  @override
  List<Object?> get props => [user, images];

  ProfileLoaded copyWith({
    UserModel? user,
    List<UserImageModel>? images,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      images: images ?? this.images,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileImageUploading extends ProfileState {
  final UserModel user;
  final List<UserImageModel> images;

  const ProfileImageUploading({
    required this.user,
    required this.images,
  });

  @override
  List<Object?> get props => [user, images];
}

class ProfileImageUploaded extends ProfileState {
  final UserImageModel image;

  const ProfileImageUploaded(this.image);

  @override
  List<Object?> get props => [image];
}

class ProfileImageDeleting extends ProfileState {
  final int imageId;

  const ProfileImageDeleting(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class ProfileImageDeleted extends ProfileState {
  final int imageId;

  const ProfileImageDeleted(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {
  final UserModel user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
