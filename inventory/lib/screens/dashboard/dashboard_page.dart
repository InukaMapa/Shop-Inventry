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
  int _totalAssets = 0;
  int _availableAssets = 0;
  int _maintenanceAssets = 0;
  List<Map<String, dynamic>> _recentActivity = [];
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

      final recentResponse = await supabase
          .from('computers')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _totalAssets = assets.length;
          
          int availableQty = 0;
          for (var a in assets) {
            String status = (a['status'] ?? '').toString();
            if (status == 'Available') {
              availableQty += int.tryParse(a['ram'].toString()) ?? 1;
            }
          }
          
          _availableAssets = availableQty;
          _maintenanceAssets = assets.where((a) => a['status'] == 'Maintenance').length;
          _recentActivity = List<Map<String, dynamic>>.from(recentResponse);
          
          _totalOrders = assets.where((a) => a['status'] == 'In Use').length;
          _totalRevenue = _totalOrders * 25000.0;
          _isLowStock = _availableAssets < 5;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAdmin = widget.role == 'admin';

    if (_isLoading && isAdmin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, theme, isAdmin),
          if (isAdmin && _isLowStock)
            SliverToBoxAdapter(
              child: _buildLowStockNotification(theme),
            ),
          SliverToBoxAdapter(
            child: isAdmin ? _buildAdminLayout(theme) : _buildUserLayout(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockNotification(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low Stock Alert', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
                Text('Only $_availableAssets items left in inventory. Consider restocking.', style: TextStyle(fontSize: 12, color: theme.colorScheme.error.withOpacity(0.8))),
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
      backgroundColor: theme.colorScheme.surface,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(
        isAdmin ? 'Admin Portal' : 'Dashboard',
        style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1, fontSize: 24),
      ),
      actions: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
            foregroundColor: theme.colorScheme.error,
          ),
          icon: const Icon(Icons.logout_rounded),
          onPressed: () async {
            await supabase.auth.signOut();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          },
        ).animate().fadeIn(duration: 600.ms),
        const SizedBox(width: 12),
      ],
    );
  }

  // --- ADMIN VIEW ---
  Widget _buildAdminLayout(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📊 Stats Horizontal Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _StatCard(
                  label: 'Total Revenue',
                  value: 'Rs. ${_totalRevenue > 1000 ? '${(_totalRevenue / 1000).toStringAsFixed(1)}k' : _totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.payments_rounded,
                  color: theme.colorScheme.primary,
                  delayMs: 100,
                ),
                _StatCard(
                  label: 'Total Orders',
                  value: _totalOrders.toString(),
                  icon: Icons.local_shipping_rounded,
                  color: Colors.teal,
                  delayMs: 200,
                ),
                _StatCard(
                  label: 'Available',
                  value: _availableAssets.toString(),
                  icon: Icons.inventory_rounded,
                  color: _isLowStock ? Colors.red : Colors.orange,
                  delayMs: 300,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ⚡ Admin Actions Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Business Hub',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _AdminActionTile(
                  title: 'Order Tracking',
                  icon: Icons.receipt_long_rounded,
                  color: Colors.blueAccent,
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                  delayMs: 500,
                ),
                _AdminActionTile(
                  title: 'Add New Asset',
                  icon: Icons.add_business_rounded,
                  color: Colors.indigoAccent,
                  onTap: () => Navigator.pushNamed(context, '/add-computer'),
                  delayMs: 600,
                ),
                _AdminActionTile(
                  title: 'Categories',
                  icon: Icons.category_rounded,
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/categories'),
                  delayMs: 700,
                ),
                _AdminActionTile(
                  title: 'Data Reports',
                  icon: Icons.analytics_rounded,
                  color: Colors.purple,
                  onTap: () {},
                  delayMs: 800,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),


          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- USER VIEW ---
  Widget _buildUserLayout(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _GreetingCard(theme: theme),
          ).animate().scaleXY(begin: 0.95, end: 1.0, duration: 600.ms, curve: Curves.easeOut),

          const SizedBox(height: 32),

          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 20),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Categories', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                 TextButton(onPressed: () => Navigator.pushNamed(context, '/computers'), child: const Text('View All')),
               ],
             ),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 12),
          
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _CategoryCard(icon: Icons.computer_rounded, title: 'Desktops', color: const Color(0xFF6366F1), delayMs: 400),
                _CategoryCard(icon: Icons.laptop_mac_rounded, title: 'Laptops', color: const Color(0xFF14B8A6), delayMs: 500),
                _CategoryCard(icon: Icons.mouse_rounded, title: 'Accessories', color: const Color(0xFFF59E0B), delayMs: 600),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _DashboardCard(
              icon: Icons.inventory_2_rounded,
              title: 'All Inventory List',
              subtitle: 'View and manage all your assets',
              color: theme.colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, '/computers'),
              delayMs: 500,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- SUPPORTING WIDGETS ---

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final int delayMs;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withOpacity(0.7))),
        ],
      ),
    ).animate().fadeIn(delay: delayMs.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _AdminActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delayMs;

  const _AdminActionTile({required this.title, required this.icon, required this.color, required this.onTap, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.2);
  }
}

class _GreetingCard extends StatelessWidget {
  final ThemeData theme;
  const _GreetingCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome Back 👋', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('View and track your assigned assets instantly.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
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
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 28),
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
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComputerListPage(category: title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideX(begin: 0.1);
  }
}
