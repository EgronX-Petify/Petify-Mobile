import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/views/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/services/presentation/screens/service_provider_dashboard.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/ecommerce/presentation/screens/shop_screen.dart';
import '../../features/ecommerce/presentation/screens/cart_screen.dart';
import '../../features/ecommerce/presentation/screens/product_details_screen.dart';
import '../../features/ecommerce/data/models/product_model.dart';
import '../../features/vets/presentation/screens/vets_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/profile/views/screens/profile_screen.dart';
import '../../features/pets/presentation/screens/add_pet_screen.dart';
import '../../features/pets/presentation/screens/pet_details_screen.dart';
import '../../features/pets/presentation/screens/edit_pet_screen.dart';
import '../../features/pets/presentation/cubit/pet_cubit.dart';
import '../../features/pets/data/services/pet_management_service.dart';
import '../../features/pets/data/models/pet_model.dart';
import '../../features/appointments/presentation/screens/pet_owner_appointments_screen.dart';
import '../../features/service_provider/presentation/screens/provider_appointments_screen.dart';
import '../utils/main_wrapper.dart';
import '../../features/authentication/viewmodel/auth_cubit.dart';
import '../../features/authentication/viewmodel/auth_state.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthCubit authCubit) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authCubit,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const EnhancedLoginScreen(),
      ),
      ShellRoute(
        builder:
            (context, state, child) => BlocProvider<PetCubit>(
              create: (_) => PetCubit(petService: PetManagementService()),
              child: MainWrapper(child: child),
            ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const EnhancedDashboardScreen(),
          ),
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const AdminDashboard(),
          ),
          GoRoute(
            path: '/provider-dashboard',
            builder: (context, state) => const ServiceProviderDashboard(),
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/product-details',
            builder: (context, state) {
              final product = state.extra as ProductModel;
              return ProductDetailsScreen(product: product);
            },
          ),
          GoRoute(
            path: '/vets',
            builder: (context, state) => const VetsScreen(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: '/add-pet',
            builder: (context, state) => const AddPetScreen(),
          ),
          GoRoute(
            path: '/pet-details/:petId',
            builder: (context, state) {
              final petId = state.pathParameters['petId']!;
              return PetDetailsScreen(petId: petId);
            },
          ),
          GoRoute(
            path: '/edit-pet/:petId',
            builder: (context, state) {
              final pet = state.extra as PetModel;
              return EditPetScreen(pet: pet);
            },
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const PetOwnerAppointmentsScreen(),
          ),
          GoRoute(
            path: '/provider-appointments',
            builder: (context, state) => const ProviderAppointmentsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final currentLocation = state.matchedLocation;

      print(
        '🔍 Router redirect: AuthState=${authState.runtimeType}, Location=$currentLocation',
      );

      // Don't redirect if we're on splash and still loading
      if (currentLocation == '/splash' &&
          (authState is AuthInitial || authState is AuthLoading)) {
        return null;
      }

      // Redirect unauthenticated users to login (except when already on login or splash)
      if (authState is AuthUnauthenticated &&
          currentLocation != '/login' &&
          currentLocation != '/splash') {
        print('🔄 Router: Redirecting unauthenticated user to login');
        return '/login';
      }

      // Redirect authenticated users away from auth screens
      if (authState is AuthAuthenticated &&
          (currentLocation == '/login' || currentLocation == '/splash')) {
        print('🔄 Router: Redirecting authenticated user to dashboard');
        if (authState.isAdmin) {
          return '/admin-dashboard';
        } else if (authState.isServiceProvider) {
          return '/provider-dashboard';
        } else {
          return '/home';
        }
      }

      return null;
    },
  );
}
