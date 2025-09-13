import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class PetifyLogo extends StatelessWidget {
  final double? size;
  final bool showText;

  const PetifyLogo({super.key, this.size, this.showText = true});

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 120;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main paw print design
              Icon(Icons.pets, size: logoSize * 0.6, color: AppColors.white),
              // Accent dots to represent multiple pets
              Positioned(
                top: logoSize * 0.15,
                right: logoSize * 0.15,
                child: Container(
                  width: logoSize * 0.12,
                  height: logoSize * 0.12,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: logoSize * 0.15,
                left: logoSize * 0.15,
                child: Container(
                  width: logoSize * 0.08,
                  height: logoSize * 0.08,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -1,
            ),
          ),
          // const SizedBox(height: 4),
          // Text(
          //   AppStrings.appSlogan,
          //   style: TextStyle(
          //     fontSize: 14,
          //     color: AppColors.grey600,
          //     fontWeight: FontWeight.w500,
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        ],
      ],
    );
  }
}
