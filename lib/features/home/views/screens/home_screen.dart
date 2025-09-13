import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../widgets/home_header.dart';
import '../widgets/service_card.dart';

import '../widgets/featured_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.background),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 24),

                // Main Service Sections
                _buildMainSections(context),
                const SizedBox(height: 32),

                // Services Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.ourServices,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Services Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: [
                          ServiceCard(
                            title: AppStrings.veterinary,
                            subtitle: 'Professional vet care',
                            icon: Icons.local_hospital,
                            color: AppColors.vetCategory,
                            onTap: () => context.go('/vets'),
                          ),
                          ServiceCard(
                            title: AppStrings.petGrooming,
                            subtitle: 'Spa & grooming services',
                            icon: Icons.pets,
                            color: AppColors.groomingCategory,
                            onTap: () => context.go('/grooming'),
                          ),
                          ServiceCard(
                            title: AppStrings.petSupplies,
                            subtitle: 'Food, toys & accessories',
                            icon: Icons.shopping_bag,
                            color: AppColors.shopCategory,
                            onTap: () => context.go('/shop'),
                          ),
                          ServiceCard(
                            title: AppStrings.emergency,
                            subtitle: '24/7 emergency care',
                            icon: Icons.emergency,
                            color: AppColors.emergencyCategory,
                            onTap: () {
                              // TODO: Implement emergency feature
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Featured Section
                const FeaturedSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainSections(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // First row - Shop Now & Track Orders
          Row(
            children: [
              Expanded(
                child: _buildSectionCard(
                  context,
                  title: 'Shop Now',
                  subtitle: 'Browse pet products',
                  image: AppAssets.catsCategory,
                  color: AppColors.primary,
                  onTap: () => context.go('/shop'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSectionCard(
                  context,
                  title: 'Track Orders',
                  subtitle: 'Check order status',
                  image: AppAssets.trackOrders,
                  color: AppColors.secondary,
                  onTap: () {
                    // TODO: Navigate to track orders
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Second row - Find Nearby & Appointments
          Row(
            children: [
              Expanded(
                child: _buildSectionCard(
                  context,
                  title: 'Find Nearby',
                  subtitle: 'Pet services near you',
                  image: AppAssets.findNearBy,
                  color: AppColors.vetCategory,
                  onTap: () => context.go('/vets'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSectionCard(
                  context,
                  title: 'Appointments',
                  subtitle: 'Upcoming bookings',
                  image: AppAssets.upcomingAppointments,
                  color: AppColors.groomingCategory,
                  onTap: () {
                    // TODO: Navigate to appointments
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.95),
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
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: AppColors.grey600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
