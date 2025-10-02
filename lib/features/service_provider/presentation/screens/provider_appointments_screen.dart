import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/repositories/service_provider_repository.dart';
import '../cubit/service_provider_cubit.dart';
import '../../../appointments/data/models/appointment_model.dart';

class ProviderAppointmentsScreen extends StatelessWidget {
  const ProviderAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceProviderCubit(sl<ServiceProviderRepository>())
        ..loadAppointments(),
      child: const ProviderAppointmentsView(),
    );
  }
}

class ProviderAppointmentsView extends StatefulWidget {
  const ProviderAppointmentsView({super.key});

  @override
  State<ProviderAppointmentsView> createState() => _ProviderAppointmentsViewState();
}

class _ProviderAppointmentsViewState extends State<ProviderAppointmentsView> {
  AppointmentStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatusChip('All', null),
                  _buildStatusChip('Pending', AppointmentStatus.pending),
                  _buildStatusChip('Approved', AppointmentStatus.approved),
                  _buildStatusChip('Completed', AppointmentStatus.completed),
                  _buildStatusChip('Cancelled', AppointmentStatus.cancelled),
                ],
              ),
            ),
          ),

          // Appointments List
          Expanded(
            child: BlocBuilder<ServiceProviderCubit, ServiceProviderState>(
              builder: (context, state) {
                if (state is ServiceProviderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is ServiceProviderError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading appointments',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<ServiceProviderCubit>().loadAppointments(),
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

                if (state is AppointmentsLoaded) {
                  final filteredAppointments = _filterAppointments(state.appointments);
                  
                  if (filteredAppointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedStatus == null ? 'No appointments yet' : 'No ${_getStatusDisplayName(_selectedStatus!).toLowerCase()} appointments',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedStatus == null 
                              ? 'Appointments will appear here when customers book your services.'
                              : 'Try selecting a different status filter.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<ServiceProviderCubit>().loadAppointments();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = filteredAppointments[index];
                        return AppointmentCard(
                          appointment: appointment,
                          onApprove: appointment.status == AppointmentStatus.pending
                            ? () => _showApproveDialog(context, appointment)
                            : null,
                          onReject: appointment.status == AppointmentStatus.pending
                            ? () => _showRejectDialog(context, appointment)
                            : null,
                          onComplete: appointment.status == AppointmentStatus.approved
                            ? () => _showCompleteDialog(context, appointment)
                            : null,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, AppointmentStatus? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedStatus = status;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  List<AppointmentModel> _filterAppointments(List<AppointmentModel> appointments) {
    if (_selectedStatus == null) return appointments;
    return appointments.where((appointment) => appointment.status == _selectedStatus).toList();
  }

  void _showApproveDialog(BuildContext context, AppointmentModel appointment) {
    final notesController = TextEditingController();
    DateTime selectedDate = appointment.requestedTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(appointment.requestedTime);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Approve Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointment for ${appointment.petName}'),
                Text('Service: ${appointment.serviceName}'),
                const SizedBox(height: 16),
                
                // Date Selection
                ListTile(
                  title: const Text('Scheduled Date'),
                  subtitle: Text(DateFormat('MMM d, y').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                
                // Time Selection
                ListTile(
                  title: const Text('Scheduled Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add any notes for the appointment...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final scheduledDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                
                Navigator.pop(context);
                context.read<ServiceProviderCubit>().approveAppointmentWithDetails(
                  appointment.id,
                  scheduledDateTime,
                  notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AppointmentModel appointment) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appointment for ${appointment.petName}'),
            Text('Service: ${appointment.serviceName}'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (optional)',
                hintText: 'Please provide a reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ServiceProviderCubit>().disapproveAppointment(
                appointment.id,
                rejectionReason: reasonController.text.trim().isEmpty 
                  ? null 
                  : reasonController.text.trim(),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Appointment'),
        content: Text('Mark this appointment as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ServiceProviderCubit>().completeAppointment(appointment.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Approved';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onApprove,
    this.onReject,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment #${appointment.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pet: ${appointment.petName}',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(appointment.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusDisplayName(appointment.status),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.grey600,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, y').format(appointment.scheduledTime ?? appointment.requestedTime),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.grey600,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(appointment.scheduledTime ?? appointment.requestedTime),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.notes}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            if (appointment.rejectionReason?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Rejection Reason: ${appointment.rejectionReason}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            if (onApprove != null || onReject != null || onComplete != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  if (onReject != null && (onApprove != null || onComplete != null))
                    const SizedBox(width: 12),
                  if (onApprove != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (onComplete != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.approved:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.approved:
        return 'Approved';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
