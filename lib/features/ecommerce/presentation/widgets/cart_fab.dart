import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/ecommerce_cubit.dart';

class CartFab extends StatefulWidget {
  const CartFab({super.key});

  @override
  State<CartFab> createState() => _CartFabState();
}

class _CartFabState extends State<CartFab> {
  @override
  void initState() {
    super.initState();
    // Load cart once when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<EcommerceCubit>();
        if (cubit.state is! CartLoaded && cubit.state is! EcommerceLoading) {
          cubit.loadCart();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EcommerceCubit, EcommerceState>(
      builder: (context, state) {
        int itemCount = 0;

        if (state is CartLoaded) {
          itemCount = state.cart.totalItems;
        }

        return FloatingActionButton(
          onPressed: () => context.push('/cart'),
          backgroundColor: AppColors.primary,
          child: Stack(
            children: [
              const Icon(Icons.shopping_cart, color: AppColors.white),
              if (itemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      itemCount > 99 ? '99+' : itemCount.toString(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
