import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:petify_mobile/core/constants/app_assets.dart';
import 'package:petify_mobile/core/widgets/petify_app_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../../features/authentication/viewmodel/auth_cubit.dart';
import '../../features/authentication/viewmodel/auth_state.dart';

class MainWrapper extends StatefulWidget {
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  List<NavigationItem> get _navigationItems {
    final authState = context.read<AuthCubit>().state;
    String homeRoute = '/home';
    bool isServiceProvider = false;
    
    if (authState is AuthAuthenticated) {
      if (authState.isAdmin) {
        homeRoute = '/admin-dashboard';
      } else if (authState.isServiceProvider) {
        homeRoute = '/provider-dashboard';
        isServiceProvider = true;
      }
    }
    
    List<NavigationItem> items = [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: AppStrings.home,
        route: homeRoute,
      ),
    ];

    // Add shop, vets, and services tabs for non-service providers
    if (!isServiceProvider) {
      items.addAll([
        NavigationItem(
          icon: Icons.shopping_bag_outlined,
          activeIcon: Icons.shopping_bag,
          label: AppStrings.shop,
          route: '/shop',
        ),
        NavigationItem(
          icon: Icons.local_hospital_outlined,
          activeIcon: Icons.local_hospital,
          label: AppStrings.vets,
          route: '/vets',
        ),
        NavigationItem(
          icon: Icons.business_center_outlined,
          activeIcon: Icons.business_center,
          label: 'Services',
          route: '/services',
        ),
        NavigationItem(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today,
          label: 'Appointments',
          route: '/appointments',
        ),
      ]);
    }
    
    return items;
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      context.go(_navigationItems[index].route);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.background), context);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final String location = GoRouterState.of(context).uri.path;
    final navigationItems = _navigationItems;
    for (int i = 0; i < navigationItems.length; i++) {
      if (location.startsWith(navigationItems[i].route) ||
          (i == 0 && (location == '/home' || location == '/admin-dashboard' || location == '/provider-dashboard'))) {
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i;
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PetifyAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.background),
            fit: BoxFit.cover,
          ),
        ),
        child: widget.child,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  _navigationItems.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final NavigationItem item = entry.value;
                    final bool isSelected = index == _selectedIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.grey400,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.grey400,
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
