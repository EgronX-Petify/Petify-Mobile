import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petify_mobile/core/services/service_locator.dart';
import 'package:petify_mobile/features/appointments/data/models/appointment_model.dart';
import 'package:petify_mobile/features/appointments/data/repositories/appointment_repository.dart';
import 'package:petify_mobile/features/services/data/repositories/service_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/service_model.dart';
import '../../../authentication/viewmodel/auth_cubit.dart';
import '../../../authentication/viewmodel/auth_state.dart';
import '../../../appointments/presentation/screens/book_appointment_screen.dart';

class ServiceProviderDetailsScreen extends StatefulWidget {
  final int providerId;
  final String? providerName; // Made nullable to handle null provider names
  final List<ServiceModel>? cachedServices;

  const ServiceProviderDetailsScreen({
    super.key,
    required this.providerId,
    this.providerName, // No longer required
    this.cachedServices,
  });

  @override
  State<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _serviceRepo = sl<ServiceRepository>();
  final _appointmentRepo = sl<AppointmentRepository>();

  late TabController _tabController;
  List<ServiceModel> _allServices = [];
  final Map<ServiceCategory, List<ServiceModel>> _servicesByCategory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviderServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderServices() async {
    setState(() => _isLoading = true);
    try {
      // Use cached services if available, otherwise fetch from API
      if (widget.cachedServices != null && widget.cachedServices!.isNotEmpty) {
        print(
          '🔍 ServiceProviderDetailsScreen: Using cached services for provider: ${widget.providerName ?? 'Service Provider'}',
        );
        _allServices = widget.cachedServices!;
      } else {
        print(
          '🔍 ServiceProviderDetailsScreen: Loading services from API for providerId: ${widget.providerId}',
        );
        // Get services for this specific provider using /api/v1/provider/{providerId}/service
        final services = await _serviceRepo.getServicesByProviderId(widget.providerId);
        _allServices = services;
      }

      _groupServicesByCategory();

      // Initialize tab controller after we know the categories
      if (_servicesByCategory.isNotEmpty) {
        _tabController = TabController(
          length: _servicesByCategory.keys.length,
          vsync: this,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load services: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _groupServicesByCategory() {
    _servicesByCategory.clear();
    for (final service in _allServices) {
      if (!_servicesByCategory.containsKey(service.category)) {
        _servicesByCategory[service.category] = [];
      }
      _servicesByCategory[service.category]!.add(service);
    }
  }

  Future<void> _bookService(ServiceModel service) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to book services'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!authState.isPetOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only pet owners can book services'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (authState.pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a pet first before booking services'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to the comprehensive booking screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(service: service),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showPetSelectionDialog(
    ServiceModel service,
    AuthAuthenticated authState,
  ) {
    if (authState.pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a pet first before booking services'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Book ${service.name}'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select a pet for this service:'),
                    const SizedBox(height: 16),
                    ...authState.pets.map(
                      (pet) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            pet.name[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(pet.name),
                        subtitle: Text('Type: ${pet.type.name} • ${pet.breed}'),
                        onTap: () {
                          Navigator.pop(context);
                          _confirmBooking(service, pet.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmBooking(ServiceModel service, int petId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Booking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service: ${service.name}'),
                Text('Provider: ${widget.providerName ?? 'Service Provider'}'),
                Text('Price: \$${service.price.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Text('This will create a pending appointment request.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Book Now'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _createAppointment(service, petId);
    }
  }

  Future<void> _createAppointment(ServiceModel service, int petId) async {
    try {
      final request = CreateAppointmentRequest(
        serviceId: service.id,
        petId: petId,
        requestedTime: DateTime.now().add(
          const Duration(days: 1),
        ), // Default to tomorrow
        notes: 'Booked through mobile app',
      );

      await _appointmentRepo.createAppointment(request);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment request sent successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.providerName ?? 'Service Provider'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _servicesByCategory.isEmpty
              ? _buildEmptyState()
              : Column(
                children: [
                  // Provider Info Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            (widget.providerName?.isNotEmpty == true) 
                                ? widget.providerName![0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.providerName ?? 'Service Provider',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_allServices.length} services available',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Tabs
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      tabs:
                          _servicesByCategory.keys.map((category) {
                            return Tab(
                              text: _getCategoryDisplayName(category),
                              icon: Icon(_getCategoryIcon(category)),
                            );
                          }).toList(),
                    ),
                  ),

                  // Services Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children:
                          _servicesByCategory.entries.map((entry) {
                            return _buildServicesGrid(entry.value);
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildServicesGrid(List<ServiceModel> services) {
    return RefreshIndicator(
      onRefresh: _loadProviderServices,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8, // Increased to give better proportions
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10), // Reduced padding further
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Important: Use minimum space needed
            children: [
              // Header with Icon and Category
              Row(
                children: [
                  Container(
                    width: 40, // Further reduced size
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        service.category,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _getCategoryColor(
                          service.category,
                        ).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(service.category),
                      color: _getCategoryColor(service.category),
                      size: 20, // Further reduced icon size
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              service.category,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getCategoryDisplayName(service.category),
                            style: TextStyle(
                              color: _getCategoryColor(service.category),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8), // Reduced spacing
              // Service Name
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4), // Reduced spacing
              // Service Description
              Flexible(
                child: Text(
                  service.description ??
                      'Professional service with quality care',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 11,
                    height: 1.2,
                  ),
                  maxLines: 2, // Reduced to 2 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8), // Reduced spacing
              // Book Button
              SizedBox(
                width: double.infinity,
                height: 30, // Further reduced button height
                child: ElevatedButton(
                  onPressed: () => _bookService(service),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Book Service',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(ServiceModel service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Service Header
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                  service.category,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                _getCategoryIcon(service.category),
                                color: _getCategoryColor(service.category),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getCategoryDisplayName(service.category),
                                    style: TextStyle(
                                      color: _getCategoryColor(
                                        service.category,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Price
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Price: \$${service.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Description
                        if (service.description != null) ...[
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service.description!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Provider Info
                        const Text(
                          'Service Provider',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.providerName ?? 'Service Provider',
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 30),

                        // Book Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _bookService(service);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Book This Service',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No services available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This provider hasn\'t added any services yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
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

  Color _getCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.vet:
        return Colors.red;
      case ServiceCategory.grooming:
        return Colors.purple;
      case ServiceCategory.training:
        return Colors.blue;
      case ServiceCategory.boarding:
        return Colors.green;
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

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.vet:
        return Icons.medical_services;
      case ServiceCategory.grooming:
        return Icons.content_cut;
      case ServiceCategory.training:
        return Icons.school;
      case ServiceCategory.boarding:
        return Icons.home;
      case ServiceCategory.walking:
        return Icons.directions_walk;
      case ServiceCategory.sitting:
        return Icons.pets;
      case ServiceCategory.vaccination:
        return Icons.vaccines;
      case ServiceCategory.other:
        return Icons.more_horiz;
    }
  }
}
