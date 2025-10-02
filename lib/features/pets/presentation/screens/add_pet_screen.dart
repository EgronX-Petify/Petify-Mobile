import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/pet_model.dart';
import '../../data/constants/pet_breed_data.dart';
import '../cubit/pet_cubit.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _microchipController = TextEditingController();

  PetType? _selectedType;
  String? _selectedBreed;
  PetGender? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _isVaccinated = false;
  bool _isNeutered = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _medicalNotesController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        // Calculate age from birth date
        final age = DateTime.now().difference(picked).inDays ~/ 365;
        _ageController.text = age.toString();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a pet type'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedBirthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a birth date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final request = CreatePetRequest(
        name: _nameController.text.trim(),
        type: _selectedType!,
        breed: _selectedBreed?.isNotEmpty == true ? _selectedBreed : null,
        age:
            _ageController.text.isNotEmpty
                ? int.tryParse(_ageController.text)
                : null,
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        weight:
            _weightController.text.isNotEmpty
                ? double.tryParse(_weightController.text)
                : null,
        color:
            _colorController.text.isNotEmpty
                ? _colorController.text.trim()
                : null,
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text.trim()
                : null,
        medicalNotes:
            _medicalNotesController.text.isNotEmpty
                ? _medicalNotesController.text.trim()
                : null,
        isVaccinated: _isVaccinated,
        isNeutered: _isNeutered,
        microchipId:
            _microchipController.text.isNotEmpty
                ? _microchipController.text.trim()
                : null,
      );

      context.read<PetCubit>().createPet(request).then((_) {
        if (_selectedImage != null &&
            context.read<PetCubit>().state is PetCreated) {
          final petId = (context.read<PetCubit>().state as PetCreated).pet.id;
          context.read<PetCubit>().uploadPetImage(petId, _selectedImage!);
        }
      });
    }
  }

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
          title: const Text(
            'Add New Pet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: BlocListener<PetCubit, PetState>(
          listener: (context, state) {
            if (state is PetCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${state.pet.name} has been added successfully!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/home');
            } else if (state is PetError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildPhysicalInfoSection(),
                  const SizedBox(height: 24),
                  _buildMedicalInfoSection(),
                  const SizedBox(height: 24),
                  _buildAdditionalInfoSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pet Photo 📸',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information 📝',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name *',
                hintText: 'Enter your pet\'s name',
                prefixIcon: Icon(Icons.pets, color: AppColors.primary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Pet name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PetType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Pet Type *',
                prefixIcon: Icon(Icons.category, color: AppColors.primary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              isExpanded: true,
              items:
                  PetType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        PetBreedData.getPetTypeDisplayName(type),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                  _selectedBreed = null; // Reset breed when type changes
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a pet type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_selectedType != null)
              DropdownButtonFormField<String>(
                value: _selectedBreed,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  prefixIcon: Icon(Icons.pets, color: AppColors.primary),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                isExpanded: true,
                items:
                    PetBreedData.getBreedsForType(_selectedType!).map((breed) {
                      return DropdownMenuItem(
                        value: breed,
                        child: Text(breed, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBreed = value;
                  });
                },
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PetGender>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc, color: AppColors.primary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              isExpanded: true,
              items:
                  PetGender.values.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(
                        PetBreedData.getPetGenderDisplayName(gender),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Physical Information 📏',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age (years)',
                      hintText: 'e.g., 3',
                      prefixIcon: Icon(Icons.cake, color: AppColors.primary),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final age = int.tryParse(value);
                        if (age == null || age < 0 || age > 50) {
                          return 'Enter valid age (0-50)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectBirthDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Birth Date *',
                          hintText: 'DD/MM/YYYY',
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        controller: TextEditingController(
                          text:
                              _selectedBirthDate != null
                                  ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                                  : '',
                        ),
                        validator: (value) {
                          if (_selectedBirthDate == null) {
                            return 'Birth date is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      hintText: 'e.g., 25.5',
                      prefixIcon: Icon(
                        Icons.monitor_weight,
                        color: AppColors.primary,
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0 || weight > 1000) {
                          return 'Enter valid weight';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value:
                        _colorController.text.isNotEmpty
                            ? _colorController.text
                            : null,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      prefixIcon: Icon(Icons.palette, color: AppColors.primary),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    isExpanded: true,
                    items:
                        PetBreedData.commonColors.map((color) {
                          return DropdownMenuItem(
                            value: color,
                            child: Text(
                              color,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _colorController.text = value ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Information ��',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              title: const Text('Vaccinated'),
              value: _isVaccinated,
              onChanged: (value) {
                setState(() {
                  _isVaccinated = value;
                });
              },
              activeColor: AppColors.primary,
              secondary: const Icon(
                Icons.health_and_safety,
                color: AppColors.primary,
              ),
            ),
            SwitchListTile.adaptive(
              title: const Text('Neutered / Spayed'),
              value: _isNeutered,
              onChanged: (value) {
                setState(() {
                  _isNeutered = value;
                });
              },
              activeColor: AppColors.primary,
              secondary: const Icon(Icons.cut, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicalNotesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Medical Notes',
                hintText: 'e.g., Allergies, medications, past surgeries',
                prefixIcon: Icon(
                  Icons.medical_services,
                  color: AppColors.primary,
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information ℹ️',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _microchipController,
              decoration: const InputDecoration(
                labelText: 'Microchip ID',
                hintText: 'Enter microchip number if available',
                prefixIcon: Icon(Icons.memory, color: AppColors.primary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Personality, favorite toys, habits',
                prefixIcon: Icon(Icons.description, color: AppColors.primary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<PetCubit, PetState>(
      builder: (context, state) {
        final isLoading = state is PetLoading;
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(
                          color: AppColors.white,
                        )
                        : const Text(
                          'Save Pet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed:
                    isLoading
                        ? null
                        : () {
                          // TODO: Implement 'Add Another Pet' functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This feature is coming soon!'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                child: const Text(
                  'Save and Add Another Pet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
