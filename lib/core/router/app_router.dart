import 'package:go_router/go_router.dart';
import '../../features/splash/views/screens/splash_screen.dart';
import '../../features/authentication/views/screens/login_screen.dart';
import '../../features/authentication/views/screens/register_screen.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/shop/views/screens/shop_screen.dart';
import '../../features/vets/views/screens/vets_screen.dart';
import '../../features/grooming/views/screens/grooming_screen.dart';
import '../../features/profile/views/screens/profile_screen.dart';
import '../utils/main_wrapper.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/shop',
            name: 'shop',
            builder: (context, state) => const ShopScreen(),
          ),
          GoRoute(
            path: '/vets',
            name: 'vets',
            builder: (context, state) => const VetsScreen(),
          ),
          GoRoute(
            path: '/grooming',
            name: 'grooming',
            builder: (context, state) => const GroomingScreen(),
          ),
        ],
      ),

      // Profile Screen (outside shell route)
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
