import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// iconly import removed

import '../transactions/transactions_page.dart';
import '../transactions/add_transaction_page.dart';
import '../notifications/notifications_page.dart';
import '../reporting/dashboard_page.dart';
import '../settings/settings_page.dart';
import '../../widgets/glass_container.dart';
import '../../theme/app_theme.dart';
import 'add_actions.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.client});

  final SupabaseClient client;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(client: widget.client),
      TransactionsPage(client: widget.client),
      const SizedBox(), // Placeholder for FAB
      NotificationsPage(client: widget.client),
      SettingsPage(client: widget.client),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.neuralBlack,
      body: Stack(
        children: [
          // Main Body
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),

          // Floating Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SafeArea(
              child: GlassContainer(
                height: 72,
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavBarItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _NavBarItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Activity',
                      isSelected: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    const SizedBox(width: 48), // Spacer for Center FAB
                    _NavBarItem(
                      icon: Icons.notifications_rounded,
                      label: 'Alerts',
                      isSelected: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                    _NavBarItem(
                      icon: Icons.person_rounded,
                      label: 'Settings',
                      isSelected: _currentIndex == 4,
                      onTap: () => setState(() => _currentIndex = 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 44, // Adjusted to float above the bar center
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => showAddActions(context, widget.client),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neuralBlue.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
