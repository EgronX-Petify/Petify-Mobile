import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:petify_mobile/features/authentication/viewmodel/auth_cubit.dart';
import 'package:petify_mobile/features/authentication/viewmodel/auth_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../viewmodel/profile_cubit.dart';
import '../../viewmodel/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileCubit _profileCubit;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactInfoController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _profileCubit = sl<ProfileCubit>();
    // Load from cache first (no API call)
    _profileCubit.loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _contactInfoController.dispose();
    _profileCubit.close();
    super.dispose();
  }

  void _populateFields(UserModel user) {
    _nameController.text = user.name ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _addressController.text = user.address ?? '';
    _descriptionController.text = user.description ?? '';
    _contactInfoController.text = user.contactInfo ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            setState(() => _isEditing = false);
            _profileCubit.loadProfile();
          } else if (state is ProfileImageUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ProfileImageDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image deleted successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Handle ProfileImageUploading state - show the profile with loading indicator
          if (state is ProfileImageUploading) {
            if (!_isEditing) {
              _populateFields(state.user);
            }
            return _buildProfileContent(
              ProfileLoaded(user: state.user, images: state.images),
              isUploading: true,
            );
          }

          if (state is! ProfileLoaded) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              body: const Center(child: Text('Failed to load profile')),
            );
          }

          if (!_isEditing) {
            _populateFields(state.user);
          }

          return _buildProfileContent(state);
        },
      ),
    );
  }

  Widget _buildProfileContent(ProfileLoaded state, {bool isUploading = false}) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _populateFields(state.user);
                });
              },
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveProfile,
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _profileCubit.loadProfile(forceRefresh: true),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                _buildProfileImage(state, isUploading: isUploading),
                const SizedBox(height: 20),
                _buildUserInfoCard(state),
                const SizedBox(height: 30),
                if (!_isEditing) _buildProfileDetailsCard(state),
                if (state.user.isPetOwner && !_isEditing) _buildStatsCard(),
                const SizedBox(height: 30),
                if (!_isEditing) ..._buildProfileOptions(),
                const SizedBox(height: 30),
                if (!_isEditing) _buildLogoutButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(ProfileLoaded state, {bool isUploading = false}) {
    print('🖼️ Building profile image with ${state.images.length} images');
    for (var img in state.images) {
      print(
        '🖼️ Available image: ID=${img.id}, hasImageUrl=${img.imageUrl != null}',
      );
    }

    // Always try to find image with ID 1 first, fallback to first image
    final primaryImage = state.images.firstWhere(
      (image) => image.id == 1,
      orElse:
          () =>
              state.images.isNotEmpty
                  ? state.images.first
                  : const UserImageModel(),
    );

    print(
      '🖼️ Selected primary image: ID=${primaryImage.id}, hasImageUrl=${primaryImage.imageUrl != null}',
    );

    // Only use the image if it has a valid ID (not the default empty one)
    final validPrimaryImage = primaryImage.id > 0 ? primaryImage : null;
    final displayName = state.user.name ?? state.user.email;

    if (validPrimaryImage != null) {
      print('🖼️ Using image with ID ${validPrimaryImage.id}');
      print('🖼️ Image URL: ${validPrimaryImage.imageUrl}');
      print('🖼️ Image URL length: ${validPrimaryImage.imageUrl?.length}');
    } else {
      print('🖼️ No valid image found, showing avatar');
    }

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: ClipOval(
            child:
                validPrimaryImage != null && validPrimaryImage.data != null
                    ? _buildImageFromBase64(
                      validPrimaryImage.data!,
                      displayName,
                    )
                    : Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
          ),
        ),
        // Loading overlay when uploading
        if (isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        // Add image button - always visible but disabled when uploading
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: isUploading ? AppColors.grey400 : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: isUploading ? null : _showImageOptions,
            ),
          ),
        ),
        // Delete image button - only show if there's an image and not uploading
        if (validPrimaryImage != null && !isUploading)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                onPressed: () => _deleteImage(validPrimaryImage.id),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfoCard(ProfileLoaded state) {
    final displayName = state.user.name ?? state.user.email;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_isEditing) ...[
              _buildEditableField('Name', _nameController),
              const SizedBox(height: 16),
              _buildEditableField('Phone', _phoneController),
              const SizedBox(height: 16),
              _buildEditableField('Address', _addressController, maxLines: 2),
              if (state.user.isServiceProvider) ...[
                const SizedBox(height: 16),
                _buildEditableField(
                  'Description',
                  _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildEditableField(
                  'Contact Info',
                  _contactInfoController,
                  maxLines: 2,
                ),
              ],
            ] else ...[
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                state.user.email,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(state.user.role),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getRoleDisplayName(state.user.role),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsCard(ProfileLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (state.user.phoneNumber != null)
              _buildInfoRow('Phone', state.user.phoneNumber!),
            if (state.user.address != null)
              _buildInfoRow('Address', state.user.address!),
            if (state.user.description != null)
              _buildInfoRow('Description', state.user.description!),
            if (state.user.contactInfo != null)
              _buildInfoRow('Contact Info', state.user.contactInfo!),
            _buildInfoRow('User ID', state.user.id.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Pets', '0'),
            Container(height: 40, width: 1, color: AppColors.grey300),
            _buildStatItem('Appointments', '0'), // TODO: Load real appointment count
            Container(height: 40, width: 1, color: AppColors.grey300),
            _buildStatItem('Services Used', '0'),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProfileOptions() {
    final currentState = _profileCubit.state;
    final isServiceProvider = currentState is ProfileLoaded && currentState.user.isServiceProvider;
    
    List<Widget> options = [];
    
    // Only show My Pets and Appointments for pet owners
    if (!isServiceProvider) {
      options.addAll([
        _buildProfileOption(
          icon: Icons.pets,
          title: 'My Pets',
          onTap: () => context.go('/home'),
        ),
        const SizedBox(height: 15),
        _buildProfileOption(
          icon: Icons.calendar_today,
          title: 'Appointments',
          onTap: () => context.go('/appointments'),
        ),
        const SizedBox(height: 15),
      ]);
    }
    
    // Common options for all users
    options.addAll([
      _buildProfileOption(
        icon: Icons.notifications,
        title: 'Notifications',
        onTap: () => _showFeatureNotImplemented('Notifications'),
      ),
      const SizedBox(height: 15),
      _buildProfileOption(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () => _showFeatureNotImplemented('Settings'),
      ),
    ]);
    
    return options;
  }

  Widget _buildLogoutButton() {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.serviceProvider:
        return AppColors.secondary;
      case UserRole.petOwner:
        return AppColors.primary;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.serviceProvider:
        return 'Service Provider';
      case UserRole.petOwner:
        return 'Pet Owner';
    }
  }

  Future<void> _saveProfile() async {
    final updateData = <String, dynamic>{};

    if (_nameController.text.isNotEmpty) {
      updateData['name'] = _nameController.text.trim();
    }
    if (_phoneController.text.isNotEmpty) {
      updateData['phoneNumber'] = _phoneController.text.trim();
    }
    if (_addressController.text.isNotEmpty) {
      updateData['address'] = _addressController.text.trim();
    }

    final currentState = _profileCubit.state;
    if (currentState is ProfileLoaded && currentState.user.isServiceProvider) {
      if (_descriptionController.text.isNotEmpty) {
        updateData['description'] = _descriptionController.text.trim();
      }
      if (_contactInfoController.text.isNotEmpty) {
        updateData['contactInfo'] = _contactInfoController.text.trim();
      }
    }

    _profileCubit.updateProfile(updateData);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _profileCubit.pickAndUploadImage(source: 'camera');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _profileCubit.pickAndUploadImage(source: 'gallery');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _deleteImage(int imageId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Image'),
            content: const Text('Are you sure you want to delete this image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _profileCubit.deleteImage(imageId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showFeatureNotImplemented(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(feature),
            content: Text(
              '$feature is ready for implementation with the existing API structure.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildImageFromBase64(String base64Data, String displayName) {
    try {
      print('🖼️ Attempting to decode base64 image data');
      final Uint8List bytes = base64Decode(base64Data);
      print('🖼️ Successfully decoded ${bytes.length} bytes');

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image.memory error: $error');
          return Center(
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('❌ Base64 decode error: $e');
      return Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await context.read<AuthCubit>().logout();
                if (context.mounted) {
                  final router = GoRouter.of(context);
                  router.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
