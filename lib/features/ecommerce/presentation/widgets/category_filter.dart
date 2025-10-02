import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryFilter extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'All', 'value': null, 'icon': Icons.grid_view},
    {'name': 'Pet Food', 'value': 'Pet Food', 'icon': Icons.restaurant},
    {'name': 'Toys', 'value': 'Toys', 'icon': Icons.toys},
    {'name': 'Accessories', 'value': 'Accessories', 'icon': Icons.pets},
    {'name': 'Health', 'value': 'Health', 'icon': Icons.medical_services},
    {'name': 'Grooming', 'value': 'Grooming', 'icon': Icons.content_cut},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'],
                    size: 16,
                    color: isSelected ? AppColors.white : AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.grey600,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                onCategorySelected(selected ? category['value'] : null);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.grey300,
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
