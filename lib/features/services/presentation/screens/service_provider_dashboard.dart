import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../service_provider/presentation/cubit/service_provider_cubit.dart';
import '../../../service_provider/presentation/screens/provider_appointments_screen.dart';
import '../../../service_provider/data/repositories/service_provider_repository.dart';
import '../../../authentication/viewmodel/auth_cubit.dart';
import '../../../authentication/viewmodel/auth_state.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';
import '../../../ecommerce/presentation/screens/product_management_screen.dart';

class ServiceProviderDashboard extends StatelessWidget {
  const ServiceProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ServiceProviderCubit(sl<ServiceProviderRepository>())
                ..loadDashboardData(),
      child: const ServiceProviderDashboardView(),
    );
  }
}

class ServiceProviderDashboardView extends StatelessWidget {
  const ServiceProviderDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocConsumer<ServiceProviderCubit, ServiceProviderState>(
          listener: (context, state) {
            // Handle success states and reload dashboard data
            if (state is AppointmentApproved || 
                state is AppointmentRejected || 
                state is AppointmentCompleted ||
                state is ServiceCreated ||
                state is ServiceUpdated ||
                state is ServiceDeleted) {
              // Reload dashboard data to refresh the UI
              context.read<ServiceProviderCubit>().loadDashboardData();
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Service Provider Dashboard'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed:
                        () =>
                            context
                                .read<ServiceProviderCubit>()
                                .loadDashboardData(),
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
              body: _buildBody(context, state),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showAddServiceDialog(context),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ServiceProviderState state) {
    if (state is ServiceProviderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ServiceProviderError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () =>
                      context.read<ServiceProviderCubit>().loadDashboardData(),
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

    if (state is ServiceProviderDashboardLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<ServiceProviderCubit>().loadDashboardData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              _buildStatsSection(state),
              const SizedBox(height: 24),

              // Services Section
              _buildServicesSection(context, state.services),
              const SizedBox(height: 24),

              // Products Section
              _buildProductsSection(context),
              const SizedBox(height: 24),

              // Appointments Section
              _buildAppointmentsSection(context, state.appointments),
            ],
          ),
        ),
      );
    }

    // Handle success states by showing loading while dashboard reloads
    if (state is AppointmentApproved || 
        state is AppointmentRejected || 
        state is AppointmentCompleted ||
        state is ServiceCreated ||
        state is ServiceUpdated ||
        state is ServiceDeleted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Refreshing dashboard...'),
          ],
        ),
      );
    }

    return const Center(child: Text('No data available'));
  }

  Widget _buildStatsSection(ServiceProviderDashboardLoaded state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Services',
                state.services.length.toString(),
                Icons.build,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Appointments',
                state.appointments.length.toString(),
                Icons.calendar_today,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending',
                state.pendingAppointments.length.toString(),
                Icons.pending,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Completed Today',
                state.completedToday.toString(),
                Icons.check_circle,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Revenue',
                '\$${state.totalRevenue.toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()), // Empty space for symmetry
          ],
        ),
      ],
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
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    List<ServiceModel> services,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddServiceDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildServicesList(context, services),
      ],
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'My Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: ElevatedButton.icon(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProductManagementScreen(),
                      ),
                    ),
                icon: const Icon(Icons.inventory, size: 16),
                label: const Text('Manage', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.inventory, size: 32, color: AppColors.secondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create, edit, and manage your products for sale',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(BuildContext context, List<ServiceModel> services) {
    if (services.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.build, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('No services yet', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                'Add your first service to start receiving appointments',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(service.category),
              child: Icon(
                _getCategoryIcon(service.category),
                color: Colors.white,
              ),
            ),
            title: Text(service.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.description ?? ''),
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditServiceDialog(context, service);
                } else if (value == 'delete') {
                  _deleteService(context, service.id);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsSection(
    BuildContext context,
    List<AppointmentModel> appointments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Appointments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderAppointmentsScreen(),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAppointmentsList(context, appointments),
      ],
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    List<AppointmentModel> appointments,
  ) {
    final recentAppointments = appointments.take(5).toList();

    if (recentAppointments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('No appointments yet', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                'Appointments will appear here once customers book your services',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentAppointments.length,
      itemBuilder: (context, index) {
        final appointment = recentAppointments[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(appointment.status),
              child: Icon(
                _getStatusIcon(appointment.status),
                color: Colors.white,
              ),
            ),
            title: Text(appointment.serviceName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pet: ${appointment.petName}'),
                Text(
                  'Requested: ${_formatDateTime(appointment.requestedTime)}',
                ),
                if (appointment.scheduledTime != null)
                  Text(
                    'Scheduled: ${_formatDateTime(appointment.scheduledTime!)}',
                  ),
              ],
            ),
            trailing: _buildAppointmentActions(context, appointment),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentActions(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    if (appointment.status == AppointmentStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.success),
            onPressed: () => _approveAppointment(context, appointment),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error),
            onPressed: () => _rejectAppointment(context, appointment),
          ),
        ],
      );
    } else if (appointment.status == AppointmentStatus.approved) {
      return IconButton(
        icon: const Icon(Icons.done_all, color: AppColors.primary),
        onPressed: () => _completeAppointment(context, appointment),
      );
    }
    return const SizedBox.shrink();
  }

  void _showAddServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final notesController = TextEditingController();
    ServiceCategory? selectedCategory;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (builderContext, setState) => AlertDialog(
                  title: const Text('Add New Service'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Service Name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ServiceCategory>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items:
                              ServiceCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    _getCategoryDisplayName(category),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (\$)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            descriptionController.text.isNotEmpty &&
                            priceController.text.isNotEmpty &&
                            selectedCategory != null) {
                          try {
                            final serviceRepo = sl<ServiceRepository>();
                            await serviceRepo.createService(
                              CreateServiceRequest(
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                category: selectedCategory!,
                                price: double.parse(priceController.text),
                                notes: notesController.text.trim(),
                              ),
                            );

                            Navigator.of(dialogContext).pop();

                            // Use the original context, not dialogContext
                            if (context.mounted) {
                              BlocProvider.of<ServiceProviderCubit>(
                                context,
                              ).loadDashboardData();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Service added successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add service: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Add Service'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditServiceDialog(BuildContext context, ServiceModel service) {
    final nameController = TextEditingController(text: service.name);
    final descriptionController = TextEditingController(
      text: service.description ?? '',
    );
    final priceController = TextEditingController(
      text: service.price.toString(),
    );
    final notesController = TextEditingController(text: service.notes ?? '');
    ServiceCategory selectedCategory = service.category;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (builderContext, setState) => AlertDialog(
                  title: const Text('Edit Service'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Service Name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ServiceCategory>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items:
                              ServiceCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    _getCategoryDisplayName(category),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (\$)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            priceController.text.isNotEmpty) {
                          try {
                            final price = double.parse(priceController.text);
                            final updateRequest = UpdateServiceRequest(
                              name: nameController.text,
                              description:
                                  descriptionController.text.isEmpty
                                      ? null
                                      : descriptionController.text,
                              category: selectedCategory,
                              price: price,
                              notes:
                                  notesController.text.isEmpty
                                      ? null
                                      : notesController.text,
                            );

                            // Update service via repository
                            final serviceRepo = sl<ServiceRepository>();
                            await serviceRepo.updateService(
                              service.id,
                              updateRequest,
                            );

                            // Refresh dashboard data
                            BlocProvider.of<ServiceProviderCubit>(
                              context,
                            ).loadDashboardData();
                            Navigator.of(dialogContext).pop();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Service updated successfully!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating service: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill in all required fields',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update Service'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _deleteService(BuildContext context, int serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Service'),
            content: const Text(
              'Are you sure you want to delete this service?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final serviceRepo = sl<ServiceRepository>();
        await serviceRepo.deleteService(serviceId);

        if (context.mounted) {
          BlocProvider.of<ServiceProviderCubit>(context).loadDashboardData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service deleted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete service: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _approveAppointment(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final scheduledTime = DateTime.now().add(const Duration(hours: 1));

    try {
      // Use the ServiceProviderCubit to approve the appointment
      await context.read<ServiceProviderCubit>().approveAppointmentWithDetails(
        appointment.id,
        scheduledTime,
        'Appointment approved from dashboard',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectAppointment(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    try {
      // Use the ServiceProviderCubit to disapprove the appointment
      await context.read<ServiceProviderCubit>().disapproveAppointment(
        appointment.id,
        rejectionReason: 'Appointment rejected from dashboard',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rejected successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _completeAppointment(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    try {
      // Use the ServiceProviderCubit to complete the appointment
      await context.read<ServiceProviderCubit>().completeAppointment(appointment.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.vet:
        return AppColors.vetCategory;
      case ServiceCategory.grooming:
        return AppColors.groomingCategory;
      case ServiceCategory.training:
        return AppColors.primary;
      case ServiceCategory.boarding:
        return AppColors.secondary;
      case ServiceCategory.walking:
        return AppColors.success;
      case ServiceCategory.sitting:
        return AppColors.warning;
      case ServiceCategory.vaccination:
        return AppColors.error;
      case ServiceCategory.other:
        return AppColors.grey500;
    }
  }

  IconData _getCategoryIcon(ServiceCategory category) {
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
        return Icons.build;
    }
  }

  String _getCategoryDisplayName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.vet:
        return 'Veterinary';
      case ServiceCategory.grooming:
        return 'Grooming';
      case ServiceCategory.training:
        return 'Training';
      case ServiceCategory.boarding:
        return 'Boarding';
      case ServiceCategory.walking:
        return 'Walking';
      case ServiceCategory.sitting:
        return 'Pet Sitting';
      case ServiceCategory.vaccination:
        return 'Vaccination';
      case ServiceCategory.other:
        return 'Other';
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.approved:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.pending;
      case AppointmentStatus.approved:
        return Icons.check;
      case AppointmentStatus.completed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not set';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
