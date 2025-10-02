import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/repositories/service_provider_repository.dart';
import '../cubit/service_provider_cubit.dart';
import '../../../appointments/data/models/appointment_model.dart';
import 'provider_services_screen.dart';
import 'provider_appointments_screen.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceProviderCubit(sl<ServiceProviderRepository>())
        ..loadDashboardData(),
      child: const ProviderDashboardView(),
    );
  }
}

class ProviderDashboardView extends StatefulWidget {
  const ProviderDashboardView({super.key});

  @override
  State<ProviderDashboardView> createState() => _ProviderDashboardViewState();
}

class _ProviderDashboardViewState extends State<ProviderDashboardView> with SingleTickerProviderStateMixin {
  late TabController _appointmentTabController;

  @override
  void initState() {
    super.initState();
    _appointmentTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _appointmentTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            BlocBuilder<ServiceProviderCubit, ServiceProviderState>(
              builder: (context, state) {
                if (state is ServiceProviderDashboardLoaded) {
                  return _buildStatisticsCards(context, state);
                }
                return _buildLoadingStatistics();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // Appointments Statistics
            _buildAppointmentStatistics(context),
            
            const SizedBox(height: 24),
            
            // Full Appointments Management Section
            Text(
              'Appointments Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFullAppointmentsManagement(context),
            
            const SizedBox(height: 24),
            
            // Management Sections
            Text(
              'Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildManagementSections(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, ServiceProviderDashboardLoaded state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'My Services',
          state.services.length.toString(),
          Icons.business_center,
          Colors.blue,
        ),
        _buildStatCard(
          'Pending Appointments',
          state.pendingAppointments.length.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          'Completed Today',
          state.completedToday.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Total Revenue',
          '\$${state.totalRevenue.toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildLoadingStatistics() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => 
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Add Service',
            'Create a new service offering',
            Icons.add_business,
            Colors.blue,
            () => _showAddServiceDialog(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'View Appointments',
            'Manage your appointments',
            Icons.calendar_today,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProviderAppointmentsScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullAppointmentsManagement(BuildContext context) {
    return BlocBuilder<ServiceProviderCubit, ServiceProviderState>(
      builder: (context, state) {
        if (state is ServiceProviderDashboardLoaded) {
          final appointments = state.appointments;
          
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // Header with search and refresh
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search appointments...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            // Search functionality can be added later
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          context.read<ServiceProviderCubit>().loadDashboardData();
                        },
                        icon: const Icon(Icons.refresh),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab bar for appointment status
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _appointmentTabController,
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey600,
                    indicatorColor: AppColors.primary,
                    onTap: (index) {
                      // Tab filtering functionality can be added later
                    },
                    tabs: [
                      Tab(text: 'All (${appointments.length})'),
                      Tab(text: 'Pending (${appointments.where((a) => a.status == AppointmentStatus.pending).length})'),
                      Tab(text: 'Approved (${appointments.where((a) => a.status == AppointmentStatus.approved).length})'),
                      Tab(text: 'Completed (${appointments.where((a) => a.status == AppointmentStatus.completed).length})'),
                      Tab(text: 'Cancelled (${appointments.where((a) => a.status == AppointmentStatus.cancelled).length})'),
                    ],
                  ),
                ),
                
                // Appointments list
                Container(
                  constraints: const BoxConstraints(maxHeight: 600), // Limit height for scrolling
                  child: appointments.isEmpty 
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 48,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No appointments yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appointments will appear here when customers book your services.',
                              style: TextStyle(
                                color: AppColors.grey600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(context, appointments[index]);
                        },
                      ),
                ),
              ],
            ),
          );
        }
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildManagementSections(BuildContext context) {
    final sections = [
      {
        'title': 'My Appointments',
        'subtitle': 'View and manage all your appointments',
        'icon': Icons.calendar_today,
        'color': AppColors.primary,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProviderAppointmentsScreen(),
          ),
        ),
      },
      {
        'title': 'My Services',
        'subtitle': 'Manage your service offerings and pricing',
        'icon': Icons.business_center,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProviderServicesScreen(),
          ),
        ),
      },
      {
        'title': 'Revenue Analytics',
        'subtitle': 'Track your earnings and performance',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'onTap': () => _showComingSoonDialog(context, 'Revenue Analytics'),
      },
    ];

    return Column(
      children: sections.map((section) => 
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (section['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                section['icon'] as IconData,
                color: section['color'] as Color,
              ),
            ),
            title: Text(
              section['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              section['subtitle'] as String,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: section['onTap'] as VoidCallback,
          ),
        ),
      ).toList(),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Service'),
        content: const Text(
          'This will open the service creation form. '
          'You can add details like service name, description, price, and category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderServicesScreen(),
                ),
              );
            },
            child: const Text('Go to Services'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentStatistics(BuildContext context) {
    return BlocBuilder<ServiceProviderCubit, ServiceProviderState>(
      builder: (context, state) {
        if (state is ServiceProviderDashboardLoaded) {
          final appointments = state.appointments;
          final pendingCount = appointments.where((a) => a.status == AppointmentStatus.pending).length;
          final completedCount = appointments.where((a) => a.status == AppointmentStatus.completed).length;
          
          // Calculate today's appointments
          final today = DateTime.now();
          final todayAppointments = appointments.where((a) {
            final appointmentDate = a.scheduledTime ?? a.requestedTime;
            return appointmentDate.year == today.year &&
                   appointmentDate.month == today.month &&
                   appointmentDate.day == today.day;
          }).length;
          
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  appointments.length.toString(),
                  Icons.calendar_today,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pendingCount.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Today',
                  todayAppointments.toString(),
                  Icons.today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                      Text(
                        'Service: ${appointment.serviceName}',
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
            
            // Action buttons for pending appointments
            if (appointment.status == AppointmentStatus.pending) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(context, appointment),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(context, appointment),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Complete button for approved appointments
            if (appointment.status == AppointmentStatus.approved) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteDialog(context, appointment),
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus? status) {
    if (status == null) return AppColors.primary;
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

  void _showApproveDialog(BuildContext context, AppointmentModel appointment) {
    final notesController = TextEditingController();
    DateTime selectedDate = appointment.requestedTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(appointment.requestedTime);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => AlertDialog(
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
                      context: builderContext,
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
                      context: builderContext,
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
              onPressed: () => Navigator.pop(builderContext),
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
                
                Navigator.pop(builderContext);
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
}
