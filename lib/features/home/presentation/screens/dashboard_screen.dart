import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petify_mobile/features/authentication/viewmodel/auth_cubit.dart';
import 'package:petify_mobile/features/authentication/viewmodel/auth_state.dart';

import '../../../authentication/data/models/user_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../pets/data/repositories/pet_repository.dart';
import '../../../pets/data/models/pet_model.dart';
import '../../views/widgets/pets_section.dart';
import '../../../services/presentation/cubit/services_cubit.dart';

class EnhancedDashboardScreen extends StatelessWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Welcome, ${state.displayName}'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<AuthCubit>().refreshPets();
                    // Also refresh services if user is a service provider
                    if (state.user.role == UserRole.serviceProvider) {
                      context.read<ServicesCubit>().loadServices();
                    }
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        _showProfileDialog(context, state.user);
                        break;
                      case 'logout':
                        context.read<AuthCubit>().logout();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Text('Profile'),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Text('Logout'),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    _buildUserInfoCard(state),
                    const SizedBox(height: 16),

                    // Role-specific content
                    if (state.isPetOwner) ...[
                      _buildPetOwnerDashboard(context, state),
                    ] else if (state.isServiceProvider) ...[
                      _buildServiceProviderDashboard(context, state),
                    ] else if (state.isAdmin) ...[
                      _buildAdminDashboard(state),
                    ],

                    const SizedBox(height: 16),

                    // API Features Demo
                    _buildAPIFeaturesCard(),
                  ],
                ),
              ),
            ),
            floatingActionButton:
                state.isPetOwner
                    ? FloatingActionButton(
                      onPressed: () => context.go('/add-pet'),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                    : null,
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildUserInfoCard(AuthAuthenticated state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    state.displayName.isNotEmpty
                        ? state.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        state.user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(state.user.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getRoleDisplayName(state.user.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.user.address != null ||
                state.user.phoneNumber != null) ...[
              const SizedBox(height: 16),
              if (state.user.phoneNumber != null)
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(state.user.phoneNumber!),
                  ],
                ),
              if (state.user.address != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.user.address!)),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPetOwnerDashboard(BuildContext context, AuthAuthenticated state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use the updated PetsSection widget
        const PetsSection(),
        const SizedBox(height: 16),

        // Quick Actions for Pet Owners
        Text(
          'Quick Actions',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.medical_services,
                title: 'Find Vets',
                subtitle: 'Book appointments',
                color: Colors.red,
                onTap: (ctx) => ctx.go('/vets'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.content_cut,
                title: 'Grooming',
                subtitle: 'Pet grooming',
                color: Colors.purple,
                onTap: (ctx) => ctx.go('/services'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.school,
                title: 'Training',
                subtitle: 'Pet training',
                color: Colors.orange,
                onTap: (ctx) => ctx.go('/services'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.hotel,
                title: 'Boarding',
                subtitle: 'Pet boarding',
                color: Colors.green,
                onTap: (ctx) => ctx.go('/services'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceProviderDashboard(BuildContext context, AuthAuthenticated state) {
    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, servicesState) {
        int servicesCount = 0;
        if (servicesState is ServicesLoaded) {
          servicesCount = servicesState.services.length;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Services',
                    value: servicesCount.toString(),
                    icon: Icons.build,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    title: 'Appointments',
                    value: '0', // Will be updated with real data
                    icon: Icons.calendar_today,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending',
                    value: '0', // Will be updated with real data
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    title: 'Completed',
                    value: '0', // Will be updated with real data
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick Actions for Service Providers
            Text(
              'Quick Actions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Appointments',
                    subtitle: 'Manage bookings',
                    color: AppColors.primary,
                    onTap: (ctx) => ctx.go('/provider-appointments'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.build,
                    title: 'Services',
                    subtitle: 'Manage services',
                    color: AppColors.secondary,
                    onTap: (ctx) => ctx.go('/provider-dashboard'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdminDashboard(AuthAuthenticated state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.admin_panel_settings, size: 48, color: Colors.red),
                SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Manage users, services, and system settings'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Function(BuildContext) onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildAPIFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.serviceProvider:
        return AppColors.secondary;
      case UserRole.petOwner:
        return AppColors.primary;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.serviceProvider:
        return 'Service Provider';
      case UserRole.petOwner:
        return 'Pet Owner';
    }
  }

  void _showProfileDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Profile Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${user.id}'),
                Text('Email: ${user.email}'),
                if (user.name != null) Text('Name: ${user.name}'),
                if (user.phoneNumber != null)
                  Text('Phone: ${user.phoneNumber}'),
                if (user.address != null) Text('Address: ${user.address}'),
                Text('Role: ${_getRoleDisplayName(user.role)}'),
                if (user.description != null)
                  Text('Description: ${user.description}'),
                if (user.contactInfo != null)
                  Text('Contact Info: ${user.contactInfo}'),
              ],
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

  void _showAddPetDialog(BuildContext context, AuthAuthenticated state) {
    final nameController = TextEditingController();
    final speciesController = TextEditingController();
    final breedController = TextEditingController();
    String selectedGender = 'Male';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add New Pet'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Pet Name',
                          ),
                        ),
                        TextField(
                          controller: speciesController,
                          decoration: const InputDecoration(
                            labelText: 'Species (e.g., Dog, Cat)',
                          ),
                        ),
                        TextField(
                          controller: breedController,
                          decoration: const InputDecoration(labelText: 'Breed'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                          items:
                              ['Male', 'Female'].map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedGender = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Date of Birth'),
                          subtitle: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => selectedDate = date);
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
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            speciesController.text.isNotEmpty &&
                            breedController.text.isNotEmpty) {
                          try {
                            final petRepo = sl<PetRepository>();
                            await petRepo.createPet(
                              CreatePetRequest(
                                name: nameController.text.trim(),
                                type:
                                    PetType
                                        .dog, // Default to dog, should be selected from UI
                                breed: breedController.text.trim(),
                                description: 'Pet created from dashboard',
                              ),
                            );

                            Navigator.of(context).pop();

                            // Refresh pets data
                            context.read<AuthCubit>().refreshPets();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pet added successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add pet: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Add Pet'),
                    ),
                  ],
                ),
          ),
    );
  }
}
