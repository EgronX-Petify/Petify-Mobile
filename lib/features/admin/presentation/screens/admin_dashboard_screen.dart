import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/repositories/admin_repository.dart';
import '../cubit/admin_cubit.dart';
import 'users_management_screen.dart';
import 'pending_providers_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(sl<AdminRepository>())..loadUserCounts(),
      child: const AdminDashboardView(),
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
            BlocBuilder<AdminCubit, AdminState>(
              builder: (context, state) {
                if (state is UserCountsLoaded) {
                  return _buildStatisticsCards(context, state.counts);
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

  Widget _buildStatisticsCards(BuildContext context, Map<String, int> counts) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Users',
          counts['total']?.toString() ?? '0',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Users',
          counts['active']?.toString() ?? '0',
          Icons.person,
          Colors.green,
        ),
        _buildStatCard(
          'Service Providers',
          counts['providers']?.toString() ?? '0',
          Icons.business,
          Colors.purple,
        ),
        _buildStatCard(
          'Pending Approvals',
          counts['pending']?.toString() ?? '0',
          Icons.pending_actions,
          Colors.orange,
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
            'Pending Providers',
            'Review service provider applications',
            Icons.business_center,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PendingProvidersScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            'User Management',
            'Manage user accounts and permissions',
            Icons.admin_panel_settings,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsersManagementScreen(),
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

  Widget _buildManagementSections(BuildContext context) {
    final sections = [
      {
        'title': 'Users & Accounts',
        'subtitle': 'Manage user accounts, roles, and permissions',
        'icon': Icons.people,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UsersManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Service Providers',
        'subtitle': 'Review and approve service provider applications',
        'icon': Icons.business,
        'color': Colors.purple,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingProvidersScreen(),
          ),
        ),
      },
      {
        'title': 'Content Moderation',
        'subtitle': 'Remove inappropriate products and services',
        'icon': Icons.content_cut,
        'color': Colors.red,
        'onTap': () => _showContentModerationDialog(context),
      },
      {
        'title': 'System Analytics',
        'subtitle': 'View platform usage and performance metrics',
        'icon': Icons.analytics,
        'color': Colors.green,
        'onTap': () => _showComingSoonDialog(context, 'System Analytics'),
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

  void _showContentModerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content Moderation'),
        content: const Text(
          'Content moderation features are integrated into the respective management screens. '
          'You can remove products and services from the Users Management screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
}
