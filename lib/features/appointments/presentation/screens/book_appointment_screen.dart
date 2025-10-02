import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../pets/data/models/pet_model.dart';
import '../../../services/data/models/service_model.dart';
import '../../../authentication/viewmodel/auth_cubit.dart';
import '../../../authentication/viewmodel/auth_state.dart';
import '../cubit/appointments_cubit.dart';
import '../../data/services/pet_owner_appointment_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final ServiceModel service;
  final int? preSelectedPetId;

  const BookAppointmentScreen({
    super.key,
    required this.service,
    this.preSelectedPetId,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  PetModel? _selectedPet;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late AppointmentsCubit _appointmentsCubit;

  @override
  void initState() {
    super.initState();
    _appointmentsCubit = AppointmentsCubit(
      appointmentService: sl<PetOwnerAppointmentService>(),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _appointmentsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentsCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Book Appointment'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        body: SafeArea(
          child: BlocConsumer<AppointmentsCubit, AppointmentsState>(
            listener: (context, state) {
              if (state is AppointmentCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment booked successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.of(context).pop(true);
              } else if (state is AppointmentsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, appointmentState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Info Card
                      _buildServiceInfoCard(),
                      const SizedBox(height: 20),

                      // Pet Selection
                      _buildPetSelectionWithAuth(),
                      const SizedBox(height: 20),

                      // Date Selection
                      _buildDateSelection(),
                      const SizedBox(height: 20),

                      // Time Selection
                      _buildTimeSelection(),
                      const SizedBox(height: 20),

                      // Notes
                      _buildNotesField(),
                      const SizedBox(height: 30),

                      // Book Button
                      _buildBookButton(appointmentState),
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

  Widget _buildServiceInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    _getServiceIcon(widget.service.category),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.service.category.name.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${widget.service.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.service.description?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                widget.service.description!,
                style: TextStyle(color: AppColors.grey600, fontSize: 14),
              ),
            ],
            if (widget.service.providerName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Text(
                    'Provider: ${widget.service.providerName}',
                    style: TextStyle(color: AppColors.grey600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelectionWithAuth() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Select Pet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Please log in to select a pet.'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return _buildPetSelection(authState.pets);
      },
    );
  }

  Widget _buildPetSelection(List<PetModel> pets) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Select Pet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (pets.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'You need to add a pet before booking an appointment.',
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<PetModel>(
                value: _selectedPet,
                decoration: InputDecoration(
                  hintText: 'Choose your pet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.pets, color: AppColors.primary),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a pet';
                  }
                  return null;
                },
                items:
                    pets.map((pet) {
                      return DropdownMenuItem<PetModel>(
                        value: pet,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Text(
                                pet.name.isNotEmpty
                                    ? pet.name[0].toUpperCase()
                                    : 'P',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              pet.name.length > 20
                                  ? '${pet.name.substring(0, 20)}...'
                                  : pet.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (pet) {
                  setState(() {
                    _selectedPet = pet;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Select Date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('MMM d, y').format(_selectedDate!)
                            : 'Choose appointment date',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _selectedDate != null
                                  ? Colors.black
                                  : AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Select Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Choose appointment time',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _selectedTime != null
                                  ? Colors.black
                                  : AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Additional Notes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Any special instructions or notes for the service provider...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.note, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(AppointmentsState appointmentState) {
    final isLoading = appointmentState is AppointmentsLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _bookAppointment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pet'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an appointment date'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an appointment time'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Combine date and time
    final requestedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Book the appointment
    _appointmentsCubit.bookAppointment(
      petId: _selectedPet!.id,
      serviceId: widget.service.id,
      requestedTime: requestedDateTime,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
    );
  }

  IconData _getServiceIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.vet:
        return Icons.medical_services;
      case ServiceCategory.grooming:
        return Icons.content_cut;
      case ServiceCategory.training:
        return Icons.school;
      case ServiceCategory.boarding:
        return Icons.hotel;
      case ServiceCategory.walking:
        return Icons.directions_walk;
      case ServiceCategory.sitting:
        return Icons.chair;
      case ServiceCategory.vaccination:
        return Icons.vaccines;
      case ServiceCategory.other:
        return Icons.pets;
    }
  }
}
