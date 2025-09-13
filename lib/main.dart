import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/authentication/data/services/auth_service.dart';
import 'features/authentication/data/repositories/auth_repository.dart';
import 'features/authentication/viewmodel/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize services and repositories (no API needed!)
  final authService = AuthService();
  final authRepository = AuthRepositoryImpl(authService, sharedPreferences);
  
  runApp(PetifyApp(
    authRepository: authRepository,
  ));
}

class PetifyApp extends StatelessWidget {
  final AuthRepository authRepository;
  
  const PetifyApp({
    super.key,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository)..checkAuthStatus(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Petify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
