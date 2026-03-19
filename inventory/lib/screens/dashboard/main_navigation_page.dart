import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../computers/computer_list_page.dart';
import 'dashboard_page.dart';
import '../profile/profile_page.dart';
import '../cart/cart_page.dart';
import '../orders/user_orders_page.dart';

class MainNavigationPage extends StatefulWidget {
  final String? role;

  const MainNavigationPage({super.key, this.role});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final isAdmin = widget.role == 'admin';
    if (isAdmin) {
      _pages = [
        DashboardPage(role: widget.role),
        const ComputerListPage(), // Dedicated Items page in navigation
        const ProfilePage(),
      ];
    } else {
      _pages = [
        DashboardPage(role: widget.role),
        const CartPage(),
        const UserOrdersPage(),
        const ProfilePage(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: theme.colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.dashboard_rounded, color: theme.colorScheme.primary),
            label: 'Home',
          ),
          if (widget.role == 'admin')
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.inventory_2_rounded, color: theme.colorScheme.primary),
              label: 'Items',
            ),
          if (widget.role != 'admin') ...[
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.shopping_cart_rounded, color: theme.colorScheme.primary),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
              label: 'Orders',
            ),
          ],
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: theme.colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
            label: 'Profile',
          ),
        ],
      ).animate().slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutCubic),
    );
  }
}
