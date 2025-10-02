import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petify_mobile/features/authentication/viewmodel/auth_cubit.dart';
import 'package:petify_mobile/features/authentication/viewmodel/auth_state.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../services/data/repositories/service_repository.dart';
import '../../../appointments/data/repositories/appointment_repository.dart';
import '../../../notifications/data/repositories/notification_repository.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      // Load system statistics
      final serviceRepo = sl<ServiceRepository>();
      final appointmentRepo = sl<AppointmentRepository>();
      final notificationRepo = sl<NotificationRepository>();

      // Get all services
      final services = await serviceRepo.getServices();

      // Get all appointments
      final appointments = await appointmentRepo.getProviderAppointments();

      // Get notification counts
      final notificationCounts = await notificationRepo.getNotificationCount();

      setState(() {
        _stats = {
          'totalServices': services.length,
          'totalAppointments': appointments.length,
          'pendingAppointments':
              appointments
                  .where((a) => a.status.toString() == 'PENDING')
                  .length,
          'completedAppointments':
              appointments
                  .where((a) => a.status.toString() == 'COMPLETED')
                  .length,
          'totalNotifications': notificationCounts.totalCount,
          'unreadNotifications': notificationCounts.unreadCount,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load stats: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadStats,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthCubit>().logout();
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
              ),
            ],
          ),
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: _loadStats,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Card
                          Card(
                            color: AppColors.error.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.admin_panel_settings,
                                    size: 48,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome, ${state.displayName}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'System Administrator',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // System Statistics
                          const Text(
                            'System Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stats Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildStatCard(
                                'Total Services',
                                _stats['totalServices']?.toString() ?? '0',
                                Icons.build,
                                AppColors.primary,
                              ),
                              _buildStatCard(
                                'Total Appointments',
                                _stats['totalAppointments']?.toString() ?? '0',
                                Icons.calendar_today,
                                AppColors.secondary,
                              ),
                              _buildStatCard(
                                'Pending Appointments',
                                _stats['pendingAppointments']?.toString() ??
                                    '0',
                                Icons.pending,
                                AppColors.warning,
                              ),
                              _buildStatCard(
                                'Completed Appointments',
                                _stats['completedAppointments']?.toString() ??
                                    '0',
                                Icons.check_circle,
                                AppColors.success,
                              ),
                              _buildStatCard(
                                'Total Notifications',
                                _stats['totalNotifications']?.toString() ?? '0',
                                Icons.notifications,
                                AppColors.info,
                              ),
                              _buildStatCard(
                                'Unread Notifications',
                                _stats['unreadNotifications']?.toString() ??
                                    '0',
                                Icons.notifications_active,
                                AppColors.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Admin Actions
                          const Text(
                            'Admin Actions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildActionCard(
                            'User Management',
                            'Manage users, roles, and permissions',
                            Icons.people,
                            AppColors.primary,
                            () => _showFeatureNotImplemented('User Management'),
                          ),
                          const SizedBox(height: 12),

                          _buildActionCard(
                            'Service Categories',
                            'Manage service categories and settings',
                            Icons.category,
                            AppColors.secondary,
                            () => _showServiceCategories(),
                          ),
                          const SizedBox(height: 12),

                          _buildActionCard(
                            'System Settings',
                            'Configure system-wide settings',
                            Icons.settings,
                            AppColors.grey600,
                            () => _showFeatureNotImplemented('System Settings'),
                          ),
                          const SizedBox(height: 12),

                          _buildActionCard(
                            'Reports & Analytics',
                            'View system reports and analytics',
                            Icons.analytics,
                            AppColors.info,
                            () => _showFeatureNotImplemented(
                              'Reports & Analytics',
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildActionCard(
                            'Send Notifications',
                            'Send system-wide notifications',
                            Icons.send,
                            AppColors.warning,
                            () => _showSendNotificationDialog(),
                          ),
                          const SizedBox(height: 24),

                          // System Information
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'System Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('App Version', '1.0.0'),
                                  _buildInfoRow('API Version', 'v1'),
                                  _buildInfoRow(
                                    'Last Updated',
                                    DateTime.now().toString().split(' ')[0],
                                  ),
                                  _buildInfoRow('Environment', 'Production'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showServiceCategories() {
    final categories = [
      'VET',
      'GROOMING',
      'TRAINING',
      'BOARDING',
      'WALKING',
      'SITTING',
      'VACCINATION',
      'OTHER',
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Service Categories'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: Icon(
                      _getCategoryIcon(category),
                      color: AppColors.primary,
                    ),
                    title: Text(category),
                    subtitle: Text('${category.toLowerCase()} services'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSendNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'GENERAL';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Send System Notification'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items:
                              ['GENERAL', 'SYSTEM_MAINTENANCE', 'WELCOME'].map((
                                type,
                              ) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedType = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Here you would implement the notification sending logic
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notification feature ready - connect to API',
                            ),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'VET':
        return Icons.medical_services;
      case 'GROOMING':
        return Icons.content_cut;
      case 'TRAINING':
        return Icons.school;
      case 'BOARDING':
        return Icons.hotel;
      case 'WALKING':
        return Icons.directions_walk;
      case 'SITTING':
        return Icons.chair;
      case 'VACCINATION':
        return Icons.vaccines;
      case 'OTHER':
        return Icons.build;
      default:
        return Icons.category;
    }
  }
}
