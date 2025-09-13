import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class VetsScreen extends StatefulWidget {
  const VetsScreen({super.key});

  @override
  State<VetsScreen> createState() => _VetsScreenState();
}

class _VetsScreenState extends State<VetsScreen> {
  String _selectedFilter = 'All';

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
                    AppStrings.vets,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find and book appointments with veterinarians',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
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
                        hintText: 'Search veterinarians...',
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

            // Filters
            Container(
              height: 60,
              color: AppColors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('General Practice'),
                  _buildFilterChip('Surgery'),
                  _buildFilterChip('Emergency'),
                  _buildFilterChip('Specialist'),
                ],
              ),
            ),

            // Veterinarians List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _VetCard(
                    name: 'Dr. ${_getVetName(index)}',
                    specialty: _getVetSpecialty(index),
                    rating: 4.5 + (index * 0.1),
                    distance: '${2 + index} km away',
                    isAvailable: index % 3 != 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : 'All';
          });
        },
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.vetCategory.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.vetCategory : AppColors.grey600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.vetCategory : AppColors.border,
          ),
        ),
      ),
    );
  }

  String _getVetName(int index) {
    final names = [
      'Sarah Johnson',
      'Michael Chen',
      'Emma Davis',
      'James Wilson',
      'Lisa Anderson',
      'David Brown',
    ];
    return names[index % names.length];
  }

  String _getVetSpecialty(int index) {
    final specialties = [
      'General Practice',
      'Surgery',
      'Emergency Care',
      'Cardiology',
      'Dermatology',
      'Orthopedics',
    ];
    return specialties[index % specialties.length];
  }
}

class _VetCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String distance;
  final bool isAvailable;

  const _VetCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.vetCategory.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: AppColors.vetCategory,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: [
                        Icon(Icons.star, color: AppColors.warning, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: AppColors.grey700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          color: AppColors.grey500,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isAvailable
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Busy',
                  style: TextStyle(
                    color: isAvailable ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: View profile
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.vetCategory),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: AppColors.vetCategory,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      isAvailable
                          ? () {
                            // TODO: Book appointment
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vetCategory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppStrings.bookAppointment,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
