import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../../core/constants/app_colors.dart';
import '../../../pets/presentation/cubit/pet_cubit.dart';
import '../../../pets/data/models/pet_model.dart';

class PetsSection extends StatefulWidget {
  const PetsSection({super.key});

  @override
  State<PetsSection> createState() => _PetsSectionState();
}

class _PetsSectionState extends State<PetsSection> {
  @override
  void initState() {
    super.initState();
    print('🐾 PetsSection initState called');
    // Load pets when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🐾 Loading pets...');
      context.read<PetCubit>().loadPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🐾 PetsSection build called');
    return BlocBuilder<PetCubit, PetState>(
      builder: (context, state) {
        print('🐾 BlocBuilder state: ${state.runtimeType}');
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Pets',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/add-pet'),
                    child: Text(
                      'Add Pet',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPetsContent(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPetsContent(BuildContext context, PetState state) {
    print('🐾 PetState: ${state.runtimeType}');
    
    if (state is PetLoading) {
      print('🐾 Loading pets...');
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is PetError) {
      print('🐾 Pet error: ${state.message}');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to load pets: ${state.message}',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            IconButton(
              onPressed: () => context.read<PetCubit>().loadPets(),
              icon: Icon(Icons.refresh, color: AppColors.error),
            ),
          ],
        ),
      );
    }

    if (state is PetsLoaded) {
      print('🐾 Pets loaded: ${state.pets.length} pets');
      if (state.pets.isEmpty) {
        print('🐾 No pets found');
        return _buildEmptyState(context);
      }
      print('🐾 Displaying ${state.pets.length} pets');
      for (var pet in state.pets) {
        print('🐾 Pet: ${pet.name} (${pet.type}) - Images: ${pet.images?.length ?? 0}');
      }
      return _buildPetsList(context, state.pets);
    }

    // Initial state or other states - show loading
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets,
            size: 48,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No pets yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.grey600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pet to get started with our services',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/add-pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Add Pet'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(BuildContext context, List<PetModel> pets) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: pets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final pet = pets[index];
          return SizedBox(
            width: 80,
            child: _buildPetCard(context, pet),
          );
        },
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet) {
    return GestureDetector(
      onTap: () {
        // Navigate to pet details screen
        context.go('/pet-details/${pet.id}');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getPetTypeColor(pet.type).withOpacity(0.1),
              border: Border.all(
                color: _getPetTypeColor(pet.type),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: _buildPetAvatar(pet),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Pet name
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // Pet type
          Text(
            _getPetTypeDisplayName(pet.type),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.grey600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatar(PetModel pet) {
    print('🐾 Building avatar for ${pet.name}, images: ${pet.images?.length ?? 0}');
    
    // Check if pet has images with base64 data
    if (pet.images != null && pet.images!.isNotEmpty) {
      final image = pet.images!.first;
      print('🐾 Image name: ${image.name}, contentType: ${image.contentType}');
      print('🐾 Image data length: ${image.data?.length ?? 0}');
      
      if (image.data != null && image.data!.isNotEmpty) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey100,
          ),
          child: ClipOval(
            child: _buildImageFromBase64(image.data!, pet.name),
          ),
        );
      }
    }

    // Show default pet icon
    return _buildDefaultIcon(pet);
  }

  Widget _buildDefaultIcon(PetModel pet) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getPetTypeColor(pet.type).withOpacity(0.2),
      ),
      child: Icon(
        _getPetTypeIcon(pet.type),
        size: 28,
        color: _getPetTypeColor(pet.type),
      ),
    );
  }

  Color _getPetTypeColor(PetType type) {
    switch (type) {
      case PetType.dog:
        return AppColors.vetCategory;
      case PetType.cat:
        return AppColors.groomingCategory;
      case PetType.bird:
        return AppColors.shopCategory;
      case PetType.fish:
        return AppColors.secondary;
      case PetType.rabbit:
        return AppColors.primary;
      case PetType.hamster:
        return AppColors.emergencyCategory;
      case PetType.guineaPig:
        return AppColors.vetCategory;
      case PetType.reptile:
        return AppColors.groomingCategory;
      case PetType.horse:
        return AppColors.shopCategory;
      case PetType.other:
        return AppColors.grey600;
    }
  }

  IconData _getPetTypeIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.pets;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.fish:
        return Icons.set_meal;
      case PetType.rabbit:
        return Icons.cruelty_free;
      case PetType.hamster:
        return Icons.pets;
      case PetType.guineaPig:
        return Icons.pets;
      case PetType.reptile:
        return Icons.pets;
      case PetType.horse:
        return Icons.pets;
      case PetType.other:
        return Icons.pets;
    }
  }

  String _getPetTypeDisplayName(PetType type) {
    switch (type) {
      case PetType.dog:
        return 'Dog';
      case PetType.cat:
        return 'Cat';
      case PetType.bird:
        return 'Bird';
      case PetType.fish:
        return 'Fish';
      case PetType.rabbit:
        return 'Rabbit';
      case PetType.hamster:
        return 'Hamster';
      case PetType.guineaPig:
        return 'Guinea Pig';
      case PetType.reptile:
        return 'Reptile';
      case PetType.horse:
        return 'Horse';
      case PetType.other:
        return 'Other';
    }
  }

  Widget _buildImageFromBase64(String base64Data, String petName) {
    try {
      print('🐾 Attempting to decode base64 image data for $petName');
      final Uint8List bytes = base64Decode(base64Data);
      print('🐾 Successfully decoded ${bytes.length} bytes for $petName');

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image.memory error for $petName: $error');
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey200,
            ),
            child: Icon(
              Icons.pets,
              size: 28,
              color: AppColors.grey600,
            ),
          );
        },
      );
    } catch (e) {
      print('❌ Base64 decode error for $petName: $e');
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grey200,
        ),
        child: Icon(
          Icons.pets,
          size: 28,
          color: AppColors.grey600,
        ),
      );
    }
  }
}
