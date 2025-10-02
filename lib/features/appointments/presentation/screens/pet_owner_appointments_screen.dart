import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../cubit/appointments_cubit.dart';
import '../../data/services/pet_owner_appointment_service.dart';
import '../../data/models/appointment_model.dart';

class PetOwnerAppointmentsScreen extends StatelessWidget {
  const PetOwnerAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentsCubit(
        appointmentService: sl<PetOwnerAppointmentService>(),
      )..loadMyAppointments(),
      child: const PetOwnerAppointmentsView(),
    );
  }
}

class PetOwnerAppointmentsView extends StatefulWidget {
  const PetOwnerAppointmentsView({super.key});

  @override
  State<PetOwnerAppointmentsView> createState() => _PetOwnerAppointmentsViewState();
}

class _PetOwnerAppointmentsViewState extends State<PetOwnerAppointmentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedTimeFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final cubit = context.read<AppointmentsCubit>();
    
    switch (_tabController.index) {
      case 0: // All
        cubit.loadMyAppointments();
        break;
      case 1: // Pending
        cubit.loadMyAppointments(status: AppointmentStatus.pending);
        break;
      case 2: // Confirmed
        cubit.loadMyAppointments(status: AppointmentStatus.approved);
        break;
      case 3: // Completed
        cubit.loadMyAppointments(status: AppointmentStatus.completed);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              _applyTimeFilter(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Time'),
              ),
              const PopupMenuItem(
                value: 'upcoming',
                child: Text('Upcoming'),
              ),
              const PopupMenuItem(
                value: 'past',
                child: Text('Past'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAppointmentsList(), // All
            _buildAppointmentsList(), // Pending
            _buildAppointmentsList(), // Confirmed
            _buildAppointmentsList(), // Completed
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to services screen to book new appointment
          // TODO: Implement navigation to services screen
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Book New'),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is AppointmentsError) {
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
                  onPressed: () => _refreshAppointments(),
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
          if (state.appointments.isEmpty) {
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
                    _getEmptyMessage(),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book your first appointment to get started!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to services screen
                      // TODO: Implement navigation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Book Appointment'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _refreshAppointments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.appointments.length,
              itemBuilder: (context, index) {
                final appointment = state.appointments[index];
                return PetOwnerAppointmentCard(
                  appointment: appointment,
                  onCancel: appointment.status == AppointmentStatus.pending
                      ? () => _showCancelDialog(appointment)
                      : null,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _applyTimeFilter(String filter) {
    final cubit = context.read<AppointmentsCubit>();
    
    switch (filter) {
      case 'all':
        _selectedTimeFilter = null;
        break;
      case 'upcoming':
        _selectedTimeFilter = 'upcoming';
        break;
      case 'past':
        _selectedTimeFilter = 'past';
        break;
    }

    // Apply filter based on current tab
    switch (_tabController.index) {
      case 0: // All
        cubit.loadMyAppointments(timeFilter: _selectedTimeFilter);
        break;
      case 1: // Pending
        cubit.loadMyAppointments(
          status: AppointmentStatus.pending,
          timeFilter: _selectedTimeFilter,
        );
        break;
      case 2: // Confirmed
        cubit.loadMyAppointments(
          status: AppointmentStatus.approved,
          timeFilter: _selectedTimeFilter,
        );
        break;
      case 3: // Completed
        cubit.loadMyAppointments(
          status: AppointmentStatus.completed,
          timeFilter: _selectedTimeFilter,
        );
        break;
    }
  }

  void _refreshAppointments() {
    _onTabChanged(); // Reload current tab
  }

  String _getEmptyMessage() {
    switch (_tabController.index) {
      case 1:
        return 'No pending appointments';
      case 2:
        return 'No confirmed appointments';
      case 3:
        return 'No completed appointments';
      default:
        return 'No appointments yet';
    }
  }

  void _showCancelDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Appointment'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel appointment
              // context.read<AppointmentsCubit>().cancelAppointment(appointment.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }
}

class PetOwnerAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;

  const PetOwnerAppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
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
            // Header with service name and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.serviceCategory.name.toUpperCase(),
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

            // Pet and provider info
            Row(
              children: [
                Icon(Icons.pets, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  appointment.petName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.providerName ?? 'Unknown Provider',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date and time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, y').format(
                    appointment.scheduledTime ?? appointment.requestedTime,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(
                    appointment.scheduledTime ?? appointment.requestedTime,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            // Price
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  'Service Price: Contact Provider',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Notes if available
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Notes: ${appointment.notes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            // Actions
            if (onCancel != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
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
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
