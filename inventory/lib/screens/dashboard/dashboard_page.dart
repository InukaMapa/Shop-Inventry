import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../computers/computer_list_page.dart';

class DashboardPage extends StatefulWidget {
  final String? role;

  const DashboardPage({super.key, this.role});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  int _availableAssets = 0;
  double _totalRevenue = 0;
  int _totalOrders = 0;
  bool _isLowStock = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (widget.role != 'admin') {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final assetsResponse = await supabase.from('computers').select();
      final assets = List<Map<String, dynamic>>.from(assetsResponse);
      final ordersResponse = await supabase.from('orders').select();
      final orders = List<Map<String, dynamic>>.from(ordersResponse);

      if (mounted) {
        setState(() {
          int availableQty = 0;
          double totalRev = 0;

          for (var a in assets) {
            final status = (a['status'] ?? '').toString();
            final qty = int.tryParse(a['ram']?.toString() ?? '0') ?? 0;
            if (status == 'Available' || status == 'In Use') {
              availableQty += qty;
            }
          }

          for (var o in orders) {
            final val = o['total_amount'];
            if (val != null) {
              totalRev += double.tryParse(val.toString()) ?? 0.0;
            }
          }
          
          _availableAssets = availableQty;
          _totalOrders = orders.length;
          _totalRevenue = totalRev;
          _isLowStock = _availableAssets < 5;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard stats fetch error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAdmin = widget.role == 'admin';

    if (_isLoading && isAdmin) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.03),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, theme, isAdmin),
            if (isAdmin && _isLowStock)
              SliverToBoxAdapter(child: _buildLowStockNotification(theme)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
                child: isAdmin ? _buildAdminLayout(theme) : _buildUserLayout(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockNotification(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.error.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low Stock Inventory', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.error, fontSize: 16)),
                const SizedBox(height: 2),
                Text('Only $_availableAssets units left. Restock soon.', style: TextStyle(fontSize: 13, color: theme.colorScheme.error.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 800.ms);
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, bool isAdmin) {
    return SliverAppBar(
      elevation: 0,
      floating: true,
      pinned: true,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAdmin ? 'DASHBOARD' : 'USER HUB',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 2),
            ),
            Text(
              isAdmin ? 'Tech Zone Pro' : 'Tech Zone',
              style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1, fontSize: 24),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withOpacity(0.3), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            color: theme.colorScheme.error,
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ).animate().fadeIn(duration: 600.ms).scale(),
      ],
    );
  }

  Widget _buildAdminLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _StatCard(
                label: 'Revenue',
                value: 'Rs. ${_totalRevenue > 1000 ? '${(_totalRevenue / 1000).toStringAsFixed(1)}k' : _totalRevenue.toStringAsFixed(0)}',
                icon: Icons.auto_graph_rounded,
                color: theme.colorScheme.primary,
                delayMs: 100,
              ),
              _StatCard(
                label: 'Orders',
                value: _totalOrders.toString(),
                icon: Icons.shopping_basket_rounded,
                color: Colors.teal,
                delayMs: 200,
              ),
              _StatCard(
                label: 'In Stock',
                value: _availableAssets.toString(),
                icon: Icons.inventory_2_rounded,
                color: _isLowStock ? Colors.red : Colors.indigo,
                delayMs: 300,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Operation Center', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.1,
            children: [
              _AdminActionTile(
                title: 'Orders',
                subtitle: 'Track status',
                icon: Icons.receipt_long_rounded,
                color: Colors.blueAccent,
                onTap: () => Navigator.pushNamed(context, '/orders'),
                delayMs: 100,
              ),
              _AdminActionTile(
                title: 'Add New',
                subtitle: 'Create asset',
                icon: Icons.add_circle_rounded,
                color: Colors.indigoAccent,
                onTap: () async {
                  await Navigator.pushNamed(context, '/add-computer');
                  _fetchStats();
                },
                delayMs: 200,
              ),
              _AdminActionTile(
                title: 'Inventory',
                subtitle: 'Manage stock',
                icon: Icons.category_rounded,
                color: Colors.teal,
                onTap: () => Navigator.pushNamed(context, '/categories'),
                delayMs: 300,
              ),
              _AdminActionTile(
                title: 'Analytics',
                subtitle: 'View growth',
                icon: Icons.leaderboard_rounded,
                color: Colors.orange,
                onTap: () {},
                delayMs: 400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _GreetingCard(theme: theme),
        ).animate().scaleXY(begin: 0.95, end: 1.0, duration: 600.ms, curve: Curves.easeOut),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Elite Categories', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/computers'),
                child: Text('Explore All', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _CategoryCard(icon: Icons.desktop_windows_rounded, title: 'Desktops', color: const Color(0xFF6366F1), delayMs: 400),
              _CategoryCard(icon: Icons.laptop_rounded, title: 'Laptops', color: const Color(0xFF14B8A6), delayMs: 500),
              _CategoryCard(icon: Icons.keyboard_rounded, title: 'Accessories', color: const Color(0xFFF59E0B), delayMs: 600),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _DashboardCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Inventory Catalog',
            subtitle: 'Browse premium computer hardware',
            color: theme.colorScheme.primary,
            onTap: () => Navigator.pushNamed(context, '/computers'),
            delayMs: 700,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final int delayMs;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade300)),
        ],
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.2, end: 0);
  }
}

class _AdminActionTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delayMs;

  const _AdminActionTile({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: color.withOpacity(0.12), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 32),
            ),
            const Spacer(),
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 18, letterSpacing: -0.5)),
            Text(subtitle, style: TextStyle(color: color.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _GreetingCard extends StatelessWidget {
  final ThemeData theme;
  const _GreetingCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.35), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('PREMIUM ACCESS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Your personalized inventory hub is ready.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delayMs;

  const _DashboardCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey.shade100, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.1);
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final int delayMs;

  const _CategoryCard({required this.icon, required this.title, required this.color, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ComputerListPage(category: title)));
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
              Text('Products', style: TextStyle(color: color.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
