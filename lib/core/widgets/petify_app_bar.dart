import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petify_mobile/core/constants/app_colors.dart';
import 'package:petify_mobile/core/constants/app_assets.dart';

class PetifyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PetifyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(AppAssets.logo, height: 48, width: 48),
                const SizedBox(width: 12),
                Text(
                  'Petify',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                context.push('/profile');
              },
              icon: const Icon(
                Icons.person_outline,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
