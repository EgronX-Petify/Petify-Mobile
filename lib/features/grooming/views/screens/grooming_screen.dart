import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class GroomingScreen extends StatefulWidget {
  const GroomingScreen({super.key});

  @override
  State<GroomingScreen> createState() => _GroomingScreenState();
}

class _GroomingScreenState extends State<GroomingScreen> {
  String _selectedService = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.grooming,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Professional grooming services for your pets',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search grooming services...',
                        hintStyle: TextStyle(
                          color: AppColors.grey400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.grey500,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Service Filters
            Container(
              height: 60,
              color: AppColors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildServiceChip('All'),
                  _buildServiceChip('Bath & Brush'),
                  _buildServiceChip('Full Groom'),
                  _buildServiceChip('Nail Trim'),
                  _buildServiceChip('Teeth Cleaning'),
                ],
              ),
            ),
            
            // Services Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return _GroomingServiceCard(
                      service: _getServiceData(index),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChip(String label) {
    final isSelected = _selectedService == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedService = selected ? label : 'All';
          });
        },
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.groomingCategory.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.groomingCategory : AppColors.grey600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.groomingCategory : AppColors.border,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getServiceData(int index) {
    final services = [
      {
        'name': 'Basic Bath & Brush',
        'duration': '45 min',
        'price': '\$25',
        'description': 'Bath, brush, and basic grooming',
        'icon': Icons.bathtub,
      },
      {
        'name': 'Full Grooming Package',
        'duration': '90 min',
        'price': '\$55',
        'description': 'Complete grooming with styling',
        'icon': Icons.content_cut,
      },
      {
        'name': 'Nail Trimming',
        'duration': '15 min',
        'price': '\$10',
        'description': 'Professional nail care',
        'icon': Icons.healing,
      },
      {
        'name': 'Teeth Cleaning',
        'duration': '30 min',
        'price': '\$20',
        'description': 'Dental hygiene service',
        'icon': Icons.clean_hands,
      },
      {
        'name': 'De-shedding Treatment',
        'duration': '60 min',
        'price': '\$35',
        'description': 'Reduce shedding with special treatment',
        'icon': Icons.pets,
      },
      {
        'name': 'Flea & Tick Treatment',
        'duration': '45 min',
        'price': '\$30',
        'description': 'Professional pest control',
        'icon': Icons.bug_report,
      },
      {
        'name': 'Ear Cleaning',
        'duration': '20 min',
        'price': '\$15',
        'description': 'Gentle ear care and cleaning',
        'icon': Icons.hearing,
      },
      {
        'name': 'Premium Spa Package',
        'duration': '120 min',
        'price': '\$80',
        'description': 'Luxury spa treatment for your pet',
        'icon': Icons.spa,
      },
    ];
    return services[index % services.length];
  }
}

class _GroomingServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const _GroomingServiceCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.groomingCategory.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'] as IconData,
                color: AppColors.groomingCategory,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service['name'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              service['description'] as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['price'] as String,
                      style: TextStyle(
                        color: AppColors.groomingCategory,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      service['duration'] as String,
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.groomingCategory,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Book',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 