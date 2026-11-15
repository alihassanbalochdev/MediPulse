import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medipulse_medical/core/theme/app_colors.dart';

/// The frame around the five tabs: page on top, navigation bar below.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: Icons.home_outlined, selected: Icons.home, label: 'Home'),
    (icon: Icons.today_outlined, selected: Icons.today, label: 'Today'),
    (icon: Icons.medication_outlined, selected: Icons.medication, label: 'Cabinet'),
    (icon: Icons.history, selected: Icons.history, label: 'History'),
    (icon: Icons.person_outline, selected: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.paper,
        indicatorColor: AppColors.aqua,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // tapping the tab you are already on returns to its first page
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon, color: AppColors.muted),
              selectedIcon: Icon(tab.selected, color: AppColors.scrub),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
