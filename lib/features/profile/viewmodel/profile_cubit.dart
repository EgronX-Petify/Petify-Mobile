import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/user_service.dart';
import '../../authentication/data/models/user_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserService _userService;
  final ImagePicker _imagePicker = ImagePicker();

  // Cache the user data to avoid repeated API calls
  UserModel? _cachedUser;
  List<UserImageModel>? _cachedImages;

  ProfileCubit(this._userService) : super(ProfileInitial());

  /// Load profile from cache or API
  Future<void> loadProfile({bool forceRefresh = false}) async {
    emit(ProfileLoading());

    try {
      // If we have cached data and not forcing refresh, use cache
      if (!forceRefresh && _cachedUser != null && _cachedImages != null) {
        print('✅ Using cached profile data');
        print('🖼️ Cached images: ${_cachedImages!.length} images');
        for (var image in _cachedImages!) {
          print('🖼️ Image ID: ${image.id}, URL: ${image.url}');
        }
        emit(ProfileLoaded(user: _cachedUser!, images: _cachedImages!));
        return;
      }

      // Load from API
      print('🔄 Loading profile from API...');
      final user = await _userService.getCurrentUser();
      print('✅ User loaded from API: ${user.email}');
      print('🖼️ Raw user images from API: ${user.images}');

      // Filter out any images with invalid data
      final images =
          (user.images ?? [])
              .where(
                (image) =>
                    image.id >= 0 &&
                    image.imageUrl != null &&
                    image.imageUrl!.isNotEmpty,
              )
              .toList();

      print('🖼️ Filtered images: ${images.length} valid images');
      for (var image in images) {
        print('🖼️ Image ID: ${image.id}, Name: ${image.name}');
        print(
          '🖼️ Has URL: ${image.url != null}, Has Data: ${image.data != null}',
        );
        print('🖼️ ContentType: ${image.contentType}');
        print('🖼️ ImageURL: ${image.imageUrl?.substring(0, 100)}...');
      }

      // Cache the data
      _cachedUser = user;
      _cachedImages = images;

      emit(ProfileLoaded(user: user, images: images));
    } catch (e) {
      print('❌ Error loading profile: $e');
      if (e.toString().contains('type cast')) {
        print('Error type: ${e.runtimeType}');
      }
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  /// Clear cache (useful for logout)
  void clearCache() {
    _cachedUser = null;
    _cachedImages = null;
  }

  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(ProfileUpdating());

    try {
      final updatedUser = await _userService.updateProfile(updateData);
      // Use images from the updated user response
      final images = updatedUser.images ?? [];
      emit(ProfileLoaded(user: updatedUser, images: images));
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
      // Restore previous state
      emit(currentState);
    }
  }

  Future<void> pickAndUploadImage({String source = 'gallery'}) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Emit uploading state but keep user data to prevent "failed to load" flash
      emit(
        ProfileImageUploading(
          user: currentState.user,
          images: currentState.images,
        ),
      );

      // Delete ALL existing images before uploading new one using the working delete function
      await _deleteAllImagesInternal();

      // Double-check that all images are deleted before uploading
      final preUploadCheck = await _userService.getCurrentUser();
      final preUploadCount = preUploadCheck.images?.length ?? 0;
      if (preUploadCount > 0) {
        print(
          '❌ CRITICAL: Still $preUploadCount images on server before upload!',
        );
        print('❌ Forcing final deletion of remaining images...');

        for (var img in preUploadCheck.images ?? []) {
          try {
            await _userService.deleteProfileImage(img.id);
            print('🗑️ Force deleted image ID ${img.id}');
            await Future.delayed(const Duration(milliseconds: 300));
          } catch (e) {
            print('❌ Force delete failed for image ${img.id}: $e');
          }
        }

        // Final verification
        await Future.delayed(const Duration(milliseconds: 1000));
        final finalCheck = await _userService.getCurrentUser();
        final finalCount = finalCheck.images?.length ?? 0;
        if (finalCount > 0) {
          throw Exception(
            'CRITICAL: Cannot proceed with upload. Server still has $finalCount images after forced deletion.',
          );
        }
      }

      // Now upload the new image
      final imageFile = File(pickedFile.path);
      final uploadedImage = await _userService.uploadProfileImage(imageFile);
      print('✅ New profile image uploaded - ID: ${uploadedImage.id}');

      // Verify upload by checking current user state
      try {
        final verifyUser = await _userService.getCurrentUser();
        final totalImages = verifyUser.images?.length ?? 0;
        print('🔍 AFTER UPLOAD: Server now has $totalImages total images');
        for (var img in verifyUser.images ?? []) {
          print('🔍 Server image: ID ${img.id}');
        }

        if (totalImages == 1) {
          print('🎉 SUCCESS: Only 1 image on server (as expected)');
        } else {
          print('❌ PROBLEM: Server has $totalImages images instead of 1!');
        }
      } catch (e) {
        print('⚠️ Could not verify upload result: $e');
      }

      // Refresh profile from API to get the updated user data with new image
      // Use silent refresh to avoid error state flashing
      await _silentRefreshProfile();

      print('🎉 Image upload and replacement completed successfully');
    } catch (e) {
      print('❌ Upload failed: ${e.toString()}');

      // Restore the previous state without showing error
      emit(ProfileLoaded(user: currentState.user, images: currentState.images));

      // Show error message via snackbar (handled in UI listener)
      emit(ProfileError('Failed to upload image: ${e.toString()}'));
    }
  }

  Future<void> deleteImage(int imageId) async {
    if (state is! ProfileLoaded) return;

    print('🗑️ Deleting single image with ID $imageId');

    try {
      await _userService.deleteProfileImage(imageId);
      print('✅ Successfully deleted image with ID $imageId');

      // Wait a moment for server to process
      await Future.delayed(const Duration(milliseconds: 300));

      // Update the UI immediately by removing the image from current state
      final currentState = state as ProfileLoaded;
      final updatedImages =
          currentState.images.where((img) => img.id != imageId).toList();

      // Update cache and emit new state
      _cachedImages = updatedImages;
      emit(ProfileLoaded(user: currentState.user, images: updatedImages));

      print('✅ Updated UI after image deletion');
    } catch (e) {
      print('❌ Failed to delete image $imageId: $e');

      // Refresh to show actual state if delete failed
      await loadProfile(forceRefresh: true);
    }
  }

  /// Silent refresh that doesn't show error states (prevents flashing)
  Future<void> _silentRefreshProfile() async {
    try {
      final user = await _userService.getCurrentUser();

      // Filter out any images with invalid data
      final images =
          (user.images ?? [])
              .where(
                (image) =>
                    image.id >= 0 &&
                    image.imageUrl != null &&
                    image.imageUrl!.isNotEmpty,
              )
              .toList();

      // Update cache
      _cachedUser = user;
      _cachedImages = images;

      // Only emit if we're currently in a loaded state (don't show loading/error)
      if (state is ProfileLoaded || state is ProfileImageUploading) {
        emit(ProfileLoaded(user: user, images: images));
      }

      print('✅ Silent refresh completed - ${images.length} images loaded');
    } catch (e) {
      print('❌ Silent refresh failed: $e');
      // Don't emit error state - just keep current state
    }
  }

  /// Internal method to delete all images (used during upload)
  Future<void> _deleteAllImagesInternal() async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;

    if (currentState.images.isEmpty) {
      print('🗑️ No images to delete');
      return;
    }

    print(
      '🗑️ DELETING ALL ${currentState.images.length} IMAGES BEFORE UPLOAD',
    );
    print(
      '🗑️ Images to delete: ${currentState.images.map((img) => 'ID:${img.id}').join(', ')}',
    );

    // First, get fresh list of images from server to make sure we have all current images
    try {
      final freshUser = await _userService.getCurrentUser();
      final allServerImages = freshUser.images ?? [];
      print(
        '🗑️ Fresh server check: Found ${allServerImages.length} images on server',
      );
      for (var img in allServerImages) {
        print('🗑️ Server image: ID ${img.id}');
      }

      // Delete ALL images found on server, not just cached ones
      for (var image in allServerImages) {
        try {
          print('🗑️ Attempting to delete image ID ${image.id}');
          await _userService.deleteProfileImage(image.id);
          print('✅ Successfully deleted image ID ${image.id}');

          // Wait longer between deletions to ensure server processes each one
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          print('❌ Failed to delete image ${image.id}: $e');
          // Don't throw immediately, try to delete other images first
        }
      }

      // Wait a bit more for server to process all deletions
      await Future.delayed(const Duration(milliseconds: 1000));

      // Verify all images are deleted with multiple attempts
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          print('🔍 Verification attempt $attempt/3');
          final verifyUser = await _userService.getCurrentUser();
          final remainingCount = verifyUser.images?.length ?? 0;

          if (remainingCount == 0) {
            print('🎉 SUCCESS: All images deleted! Server now has 0 images.');
            return;
          } else {
            print(
              '⚠️ Attempt $attempt: Server still has $remainingCount images',
            );
            for (var img in verifyUser.images ?? []) {
              print('⚠️ Remaining image: ID ${img.id}');
            }

            if (attempt < 3) {
              // Wait and try verification again
              await Future.delayed(const Duration(milliseconds: 1000));
            } else {
              // Last attempt failed - try to delete remaining images
              print(
                '🗑️ Final cleanup: Deleting remaining $remainingCount images',
              );
              for (var img in verifyUser.images ?? []) {
                try {
                  await _userService.deleteProfileImage(img.id);
                  print('✅ Final cleanup: Deleted image ID ${img.id}');
                } catch (e) {
                  print('❌ Final cleanup failed for image ${img.id}: $e');
                }
              }
            }
          }
        } catch (e) {
          print('❌ Verification attempt $attempt failed: $e');
          if (attempt == 3) {
            print(
              '⚠️ Could not verify deletion after 3 attempts, proceeding anyway',
            );
          }
        }
      }
    } catch (e) {
      print('❌ Failed to get fresh image list: $e');
      throw Exception('Failed to prepare for image deletion: $e');
    }
  }

  void showImagePickerOptions() {
    // This will be handled by the UI to show bottom sheet
  }

  UserImageModel? get primaryImage {
    if (state is ProfileLoaded) {
      final images = (state as ProfileLoaded).images;
      return images.isNotEmpty ? images.first : null;
    }
    return null;
  }

  bool get hasImages {
    if (state is ProfileLoaded) {
      return (state as ProfileLoaded).images.isNotEmpty;
    }
    return false;
  }
}
