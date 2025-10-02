import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../cubit/pet_cubit.dart';
import '../../data/models/pet_model.dart';

class EditPetScreen extends StatefulWidget {
  final PetModel pet;

  const EditPetScreen({super.key, required this.pet});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _microchipIdController = TextEditingController();
  final _weightController = TextEditingController();

  PetType _selectedType = PetType.dog;
  PetGender _selectedGender = PetGender.male;
  DateTime? _selectedBirthDate;
  bool _isVaccinated = false;
  bool _isNeutered = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _nameController.text = widget.pet.name;
    _selectedType = widget.pet.type;
    _breedController.text = widget.pet.breed ?? '';
    _selectedGender = widget.pet.gender ?? PetGender.male;
    _selectedBirthDate = widget.pet.birthDate;
    _colorController.text = widget.pet.color ?? '';
    _descriptionController.text = widget.pet.description ?? '';
    _medicalNotesController.text = widget.pet.medicalNotes ?? '';
    _microchipIdController.text = widget.pet.microchipId ?? '';
    _weightController.text = widget.pet.weight?.toString() ?? '';
    _isVaccinated = widget.pet.isVaccinated ?? false;
    _isNeutered = widget.pet.isNeutered ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _medicalNotesController.dispose();
    _microchipIdController.dispose();
    _weightController.dispose();
    super.dispose();
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
          title: const Text('Edit Pet'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _savePet),
          ],
        ),
        body: BlocListener<PetCubit, PetState>(
          listener: (context, state) {
            if (state is PetUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet updated successfully!'),
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
            } else if (state is PetImageUploaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet image updated successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          child: BlocBuilder<PetCubit, PetState>(
            builder: (context, state) {
              final isLoading = state is PetLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Image Section
                      _buildImageSection(),
                      const SizedBox(height: 24),

                      // Basic Information
                      _buildSectionCard('Basic Information', [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Pet Name *',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter pet name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown<PetType>(
                          label: 'Species *',
                          value: _selectedType,
                          items: PetType.values,
                          onChanged:
                              (value) => setState(() => _selectedType = value!),
                          itemBuilder: (type) => _getPetTypeDisplayName(type),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _breedController,
                          label: 'Breed',
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown<PetGender>(
                          label: 'Gender',
                          value: _selectedGender,
                          items: PetGender.values,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedGender = value!),
                          itemBuilder:
                              (gender) => _getGenderDisplayName(gender),
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(),
                      ]),

                      const SizedBox(height: 16),

                      // Physical Information
                      _buildSectionCard('Physical Information', [
                        _buildTextField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _colorController,
                          label: 'Color',
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // Health Information
                      _buildSectionCard('Health Information', [
                        _buildSwitchTile(
                          title: 'Vaccinated',
                          value: _isVaccinated,
                          onChanged:
                              (value) => setState(() => _isVaccinated = value),
                        ),
                        _buildSwitchTile(
                          title: 'Neutered/Spayed',
                          value: _isNeutered,
                          onChanged:
                              (value) => setState(() => _isNeutered = value),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _microchipIdController,
                          label: 'Microchip ID',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _medicalNotesController,
                          label: 'Medical Notes',
                          maxLines: 3,
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // Additional Information
                      _buildSectionCard('Additional Information', [
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          maxLines: 3,
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _savePet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
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
          Text(
            'Pet Photo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Images Gallery
          _buildImagesGallery(),

          const SizedBox(height: 16),

          // Add Images Button
          Center(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGallery() {
    final List<Widget> imageWidgets = [];
    
    // Add selected image if any
    if (_selectedImage != null) {
      imageWidgets.add(_buildImageContainer(
        child: Image.file(_selectedImage!, fit: BoxFit.cover),
      ));
    }
    
    // Add existing pet images
    if (widget.pet.images != null && widget.pet.images!.isNotEmpty) {
      for (final image in widget.pet.images!) {
        if (image.data != null && image.data!.isNotEmpty) {
          try {
            final imageBytes = base64Decode(image.data!);
            imageWidgets.add(_buildImageContainer(
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            ));
          } catch (e) {
            // Skip invalid images
          }
        }
      }
    }
    
    // Show default if no images
    if (imageWidgets.isEmpty) {
      imageWidgets.add(_buildImageContainer(
        child: Icon(Icons.pets, size: 60, color: AppColors.grey600),
      ));
    }
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageWidgets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < imageWidgets.length - 1 ? 12 : 0,
            ),
            child: imageWidgets[index],
          );
        },
      ),
    );
  }
  
  Widget _buildImageContainer({required Widget child}) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.grey200,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: child,
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedBirthDate != null
                  ? 'Date of Birth: ${_formatDate(_selectedBirthDate!)}'
                  : 'Select Date of Birth',
              style: TextStyle(
                fontSize: 16,
                color:
                    _selectedBirthDate != null
                        ? AppColors.black
                        : AppColors.grey600,
              ),
            ),
            const Icon(Icons.calendar_today, color: AppColors.grey600),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedBirthDate = date);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Upload image immediately
        context.read<PetCubit>().uploadPetImage(widget.pet.id, _selectedImage!);
      }
    }
  }


  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final request = CreatePetRequest(
        name: _nameController.text.trim(),
        type: _selectedType,
        breed:
            _breedController.text.trim().isEmpty
                ? null
                : _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        weight:
            _weightController.text.trim().isEmpty
                ? null
                : double.tryParse(_weightController.text.trim()),
        color:
            _colorController.text.trim().isEmpty
                ? null
                : _colorController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        medicalNotes:
            _medicalNotesController.text.trim().isEmpty
                ? null
                : _medicalNotesController.text.trim(),
        isVaccinated: _isVaccinated,
        isNeutered: _isNeutered,
        microchipId:
            _microchipIdController.text.trim().isEmpty
                ? null
                : _microchipIdController.text.trim(),
      );

      context.read<PetCubit>().updatePet(widget.pet.id, request);
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
}
