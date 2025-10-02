import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/service_model.dart';
import '../cubit/services_cubit.dart';
import 'service_provider_details_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicesView();
  }
}

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  ServiceCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load service providers on init
    context.read<ServicesCubit>().loadServiceProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<ServicesCubit>().searchServices(value);
                    } else {
                      context.read<ServicesCubit>().loadServiceProviders(category: _selectedCategory);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(null, 'All'),
                      ...ServiceCategory.values.map(
                        (category) => _buildCategoryChip(category, _getCategoryDisplayName(category)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Services List
          Expanded(
            child: BlocBuilder<ServicesCubit, ServicesState>(
              builder: (context, state) {
                if (state is ServicesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is ServicesError) {
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
                          'Error loading services',
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
                          onPressed: () => context.read<ServicesCubit>().loadServiceProviders(),
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

                if (state is ServicesLoaded) {
                  if (state.services.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 64,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No services found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters.',
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
                      context.read<ServicesCubit>().loadServiceProviders(category: _selectedCategory);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.servicesByProvider.length,
                      itemBuilder: (context, index) {
                        final groupId = state.servicesByProvider.keys.elementAt(index);
                        final services = state.servicesByProvider[groupId]!;
                        final providerName = state.providerNames[groupId] ?? 'Unknown Provider';
                        
                        return _buildProviderCard(groupId, providerName, services);
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
      ),
    );
  }

  Widget _buildCategoryChip(ServiceCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          context.read<ServicesCubit>().loadServiceProviders(category: _selectedCategory);
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.grey600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProviderCard(int groupId, String providerName, List<ServiceModel> services) {
    // groupId is now the providerId from the API response
    final providerId = groupId;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceProviderDetailsScreen(
                providerId: providerId, // Pass providerId for API calls
                providerName: providerName,
                cachedServices: services, // Pass cached services
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.business,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          providerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${services.length} service${services.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.grey400,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: services.take(3).map((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(service.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getCategoryColor(service.category).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      service.name,
                      style: TextStyle(
                        color: _getCategoryColor(service.category),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (services.length > 3) ...[
                const SizedBox(height: 8),
                Text(
                  '+${services.length - 3} more services',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.vet:
        return Colors.red;
      case ServiceCategory.grooming:
        return Colors.blue;
      case ServiceCategory.training:
        return Colors.green;
      case ServiceCategory.boarding:
        return Colors.purple;
      case ServiceCategory.walking:
        return Colors.orange;
      case ServiceCategory.sitting:
        return Colors.teal;
      case ServiceCategory.vaccination:
        return Colors.pink;
      case ServiceCategory.other:
        return Colors.grey;
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
}
