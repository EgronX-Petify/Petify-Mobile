import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../../core/constants/app_colors.dart';
import '../cubit/pet_cubit.dart';
import '../../data/models/pet_model.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petId;

  const PetDetailsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pet Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [],
        ),
        body: BlocBuilder<PetCubit, PetState>(
          builder: (context, state) {
            if (state is PetLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is PetError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load pet details',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _loadPet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PetLoaded) {
              return _buildPetDetails(context, state.pet);
            }

            // Load pet details
            _loadPet(context);
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          },
        ),
      ),
    );
  }

  void _loadPet(BuildContext context) {
    final petIdInt = int.tryParse(petId);
    if (petIdInt != null) {
      context.read<PetCubit>().loadPetById(petIdInt);
    }
  }

  Widget _buildPetDetails(BuildContext context, PetModel pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet Image and Basic Info
          _buildPetHeader(context, pet),
          const SizedBox(height: 24),

          // Pet Information Cards
          _buildInfoCard(context, 'Basic Information', [
            _buildInfoRow('Name', pet.name),
            _buildInfoRow('Species', _getPetTypeDisplayName(pet.type)),
            if (pet.breed != null) _buildInfoRow('Breed', pet.breed!),
            if (pet.gender != null)
              _buildInfoRow('Gender', _getGenderDisplayName(pet.gender!)),
            if (pet.birthDate != null)
              _buildInfoRow('Date of Birth', _formatDate(pet.birthDate!)),
            if (pet.age != null) _buildInfoRow('Age', '${pet.age} years'),
          ]),

          const SizedBox(height: 16),

          // Physical Information
          if (pet.weight != null || pet.color != null)
            _buildInfoCard(context, 'Physical Information', [
              if (pet.weight != null)
                _buildInfoRow('Weight', '${pet.weight} kg'),
              if (pet.color != null) _buildInfoRow('Color', pet.color!),
            ]),

          const SizedBox(height: 16),

          // Health Information
          if (pet.isVaccinated != null ||
              pet.isNeutered != null ||
              pet.medicalNotes != null)
            _buildInfoCard(context, 'Health Information', [
              if (pet.isVaccinated != null)
                _buildInfoRow('Vaccinated', pet.isVaccinated! ? 'Yes' : 'No'),
              if (pet.isNeutered != null)
                _buildInfoRow(
                  'Neutered/Spayed',
                  pet.isNeutered! ? 'Yes' : 'No',
                ),
              if (pet.microchipId != null)
                _buildInfoRow('Microchip ID', pet.microchipId!),
              if (pet.medicalNotes != null)
                _buildInfoRow('Medical Notes', pet.medicalNotes!),
            ]),

          const SizedBox(height: 16),

          // Description
          if (pet.description != null && pet.description!.isNotEmpty)
            _buildInfoCard(context, 'Description', [
              Text(
                pet.description!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
              ),
            ]),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, pet),
        ],
      ),
    );
  }

  Widget _buildPetHeader(BuildContext context, PetModel pet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          // Pet Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getPetTypeColor(pet.type).withOpacity(0.1),
              border: Border.all(color: _getPetTypeColor(pet.type), width: 3),
            ),
            child: ClipOval(child: _buildPetImage(pet)),
          ),
          const SizedBox(height: 16),

          // Pet Name
          Text(
            pet.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Pet Type and Breed
          Text(
            pet.breed != null
                ? '${_getPetTypeDisplayName(pet.type)} • ${pet.breed}'
                : _getPetTypeDisplayName(pet.type),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _getPetTypeColor(pet.type),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: AppColors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PetModel pet) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _editPet(context, pet),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _deletePet(context, pet),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete Pet'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetImage(PetModel pet) {
    // Check if pet has images with base64 data
    if (pet.images != null && pet.images!.isNotEmpty) {
      final image = pet.images!.first;
      if (image.data != null && image.data!.isNotEmpty) {
        return _buildImageFromBase64(image.data!, pet.name);
      }
    }

    // Show default pet icon
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getPetTypeColor(pet.type).withOpacity(0.2),
      ),
      child: Icon(
        _getPetTypeIcon(pet.type),
        size: 60,
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

  String _getGenderDisplayName(PetGender gender) {
    switch (gender) {
      case PetGender.male:
        return 'Male';
      case PetGender.female:
        return 'Female';
      case PetGender.unknown:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildImageFromBase64(String base64Data, String petName) {
    try {
      print('🖼️ Attempting to decode base64 image data for $petName');
      final Uint8List bytes = base64Decode(base64Data);
      print('🖼️ Successfully decoded ${bytes.length} bytes for $petName');

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Image.memory error for $petName: $error');
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey200,
            ),
            child: Icon(Icons.pets, size: 60, color: AppColors.grey600),
          );
        },
      );
    } catch (e) {
      print('❌ Base64 decode error for $petName: $e');
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grey200,
        ),
        child: Icon(Icons.pets, size: 60, color: AppColors.grey600),
      );
    }
  }

  void _editPet(BuildContext context, PetModel pet) {
    context.go('/edit-pet/${pet.id}', extra: pet);
  }

  void _deletePet(BuildContext context, PetModel pet) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Pet'),
            content: Text(
              'Are you sure you want to delete ${pet.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<PetCubit>().deletePet(pet.id);

                  // Show success message and navigate back
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet.name} has been deleted'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
