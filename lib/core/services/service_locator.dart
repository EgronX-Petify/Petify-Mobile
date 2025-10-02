import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Authentication
import '../../features/authentication/data/services/auth_service.dart';
import '../../features/authentication/data/repositories/auth_repository.dart';
import '../../features/authentication/viewmodel/auth_cubit.dart';

// Pets
import '../../features/pets/data/services/pet_service.dart';
import '../../features/pets/data/services/pet_management_service.dart';
import '../../features/pets/data/repositories/pet_repository.dart';
import '../../features/pets/presentation/cubit/pet_cubit.dart';

// Services
import '../../features/services/data/services/service_service.dart';
import '../../features/services/data/services/service_search_service.dart';
import '../../features/services/data/repositories/service_repository.dart';
import '../../features/services/presentation/cubit/services_cubit.dart';

// Appointments
import '../../features/appointments/data/services/appointment_service.dart';
import '../../features/appointments/data/services/pet_owner_appointment_service.dart';
import '../../features/appointments/data/repositories/appointment_repository.dart';

// Notifications
import '../../features/notifications/data/services/notification_service.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';

// Profile
import '../../features/profile/data/services/user_service.dart';
import '../../features/profile/viewmodel/profile_cubit.dart';

// Service Provider
import '../../features/service_provider/data/services/service_provider_service.dart';
import '../../features/service_provider/data/repositories/service_provider_repository.dart';
import '../../features/service_provider/presentation/cubit/service_provider_dashboard_cubit.dart';

// Ecommerce
import '../../features/ecommerce/data/services/product_service.dart';
import '../../features/ecommerce/data/services/cart_service.dart';
import '../../features/ecommerce/data/services/order_service.dart';
import '../../features/ecommerce/presentation/cubit/ecommerce_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<PetService>(() => PetService());
  sl.registerLazySingleton<PetManagementService>(() => PetManagementService());
  sl.registerLazySingleton<ServiceService>(() => ServiceService());
  sl.registerLazySingleton<ServiceSearchService>(() => ServiceSearchService());
  sl.registerLazySingleton<AppointmentService>(() => AppointmentService());
  sl.registerLazySingleton<PetOwnerAppointmentService>(() => PetOwnerAppointmentService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<UserService>(() => UserService());
  
  // Service Provider services
  sl.registerLazySingleton<ServiceProviderService>(() => ServiceProviderService());
  
  // Ecommerce services
  sl.registerLazySingleton<ProductService>(() => ProductService());
  sl.registerLazySingleton<CartService>(() => CartService());
  sl.registerLazySingleton<OrderService>(() => OrderService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthService>()),
  );
  sl.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(sl<PetService>()),
  );
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(sl<ServiceService>()),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(sl<AppointmentService>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationService>()),
  );
  sl.registerLazySingleton<ServiceProviderRepository>(
    () => ServiceProviderRepository(sl<ServiceProviderService>()),
  );
  // Cart repository moved to ecommerce feature

  // Cubits/ViewModels
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthService>()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<UserService>()));
  sl.registerFactory<PetCubit>(() => PetCubit(petService: sl<PetManagementService>()));
  sl.registerFactory<EcommerceCubit>(() => EcommerceCubit(
    productService: sl<ProductService>(),
    cartService: sl<CartService>(),
    orderService: sl<OrderService>(),
  ));
  sl.registerLazySingleton<ServiceProviderDashboardCubit>(() => ServiceProviderDashboardCubit(
    serviceProviderRepository: sl<ServiceProviderRepository>(),
    appointmentRepository: sl<AppointmentRepository>(),
  ));
  sl.registerLazySingleton<ServicesCubit>(() => ServicesCubit(
    serviceSearchService: sl<ServiceSearchService>(),
    serviceService: sl<ServiceService>(),
  ));
}
