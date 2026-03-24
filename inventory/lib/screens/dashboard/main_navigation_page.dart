import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dashboard_page.dart';
import '../profile/profile_page.dart';
import '../cart/cart_page.dart';
import '../orders/user_orders_page.dart';
import '../categories/categories_page.dart';

class MainNavigationPage extends StatefulWidget {
  final String? role;

  const MainNavigationPage({super.key, this.role});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  @override
  void didUpdateWidget(covariant MainNavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _initializePages();
      // Ensure index is within bounds of new pages list
      if (_currentIndex >= _pages.length) {
        setState(() => _currentIndex = _pages.length - 1);
      }
    }
  }

  void _initializePages() {
    final isAdmin = widget.role == 'admin';
    if (isAdmin) {
      _pages = [
        DashboardPage(role: widget.role),
        const CategoriesPage(),
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
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() => _currentIndex = index);
              },
              elevation: 0,
              backgroundColor: Colors.transparent,
              indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                _navItem(Icons.dashboard_outlined, Icons.dashboard_rounded,
                    'Home', theme),
                if (widget.role == 'admin')
                  _navItem(Icons.category_outlined, Icons.category_rounded,
                      'Categories', theme),
                if (widget.role != 'admin') ...[
                  _navItem(Icons.shopping_basket_outlined,
                      Icons.shopping_basket_rounded, 'Cart', theme),
                  _navItem(Icons.receipt_long_outlined,
                      Icons.receipt_long_rounded, 'Orders', theme),
                ],
                _navItem(Icons.person_outline_rounded, Icons.person_rounded,
                    'Profile', theme),
              ],
            ),
          ),
        ),
      )
          .animate()
          .slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutCubic),
    );
  }

  NavigationDestination _navItem(
      IconData icon, IconData selectedIcon, String label, ThemeData theme) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.grey.shade400, size: 24),
      selectedIcon:
          Icon(selectedIcon, color: theme.colorScheme.primary, size: 24),
      label: label,
    );
  }
}
