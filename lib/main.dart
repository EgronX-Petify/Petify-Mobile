import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petify_mobile/features/authentication/viewmodel/auth_cubit.dart';
import 'package:petify_mobile/features/ecommerce/presentation/cubit/ecommerce_cubit.dart';
import 'package:petify_mobile/features/pets/presentation/cubit/pet_cubit.dart';
import 'package:petify_mobile/features/services/presentation/cubit/services_cubit.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator with all dependencies
  await initServiceLocator();

  runApp(const PetifyApp());
}

class PetifyApp extends StatelessWidget {
  const PetifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = sl<AuthCubit>()..checkAuthStatus();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (context) => sl<EcommerceCubit>()),
        BlocProvider(create: (context) => sl<PetCubit>()),
        BlocProvider.value(value: sl<ServicesCubit>()..loadServices()),
      ],
      child: MaterialApp.router(
        title: 'Petify - Complete Pet Services Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.createRouter(authCubit),
      ),
    );
  }
}
