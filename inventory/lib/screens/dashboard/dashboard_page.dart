import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../computers/computer_list_page.dart';
import '../reports/reports_page.dart';

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
  String? _currentRole;
  List<Map<String, dynamic>> _allAssets = [];

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role;
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);

    try {
      // 1. Determine the actual user role first
      String activeRole = _currentRole ?? widget.role ?? 'user';
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        final profile = await supabase.from('profiles').select('role').eq('id', userId).maybeSingle();
        if (profile != null) {
          activeRole = profile['role']?.toString().toLowerCase() == 'admin' ? 'admin' : 'user';
          if (mounted) setState(() => _currentRole = activeRole);
        }
      }

      // 2. Fetch data based on the determined role
      final results = await Future.wait([
        supabase.from('computers').select().order('created_at', ascending: false),
        supabase.from('orders').select(), // Always fetch orders to be sure, or filter if needed
      ]);

      if (!mounted) return;

      final assets = List<Map<String, dynamic>>.from(results[0]);
      final orders = List<Map<String, dynamic>>.from(results[1]);

      setState(() {
        _allAssets = assets;
        _totalOrders = orders.length;
        
        // Use unique product count (rows) for 'Total Products'
        _availableAssets = assets.length;

        double totalRev = 0;
        // Calculate total revenue from orders
        for (var o in orders) {
          final amt = o['total_amount'];
          if (amt != null) {
            if (amt is num) {
              totalRev += amt.toDouble();
            } else {
              final cleaned = amt.toString().replaceAll(RegExp(r'[^0-9.]'), '');
              totalRev += double.tryParse(cleaned) ?? 0.0;
            }
          }
        }
        _totalRevenue = totalRev;
        
        // Sum individual units for internal info if needed
        int totalUnits = 0;
        for (var a in assets) {
          final cleanQty = a['ram']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
          totalUnits += int.tryParse(cleanQty) ?? 0;
        }
        _isLowStock = totalUnits < 10;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Dashboard stats fetch error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAdmin = (_currentRole ?? widget.role) == 'admin';

    if (_isLoading) {
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
              theme.colorScheme.primary.withValues(alpha: 0.03),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, theme, isAdmin),
            if (isAdmin && _isLowStock)
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    int totalUnits = 0;
                    for (var a in _allAssets) {
                      final cleanQty = a['ram']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
                      totalUnits += int.tryParse(cleanQty) ?? 0;
                    }
                    return _buildLowStockNotification(theme, totalUnits);
                  }
                ),
              ),
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

  Widget _buildLowStockNotification(ThemeData theme, int totalUnits) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.error.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low Stock Inventory', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.error, fontSize: 16)),
                const SizedBox(height: 2),
                Text('Only $totalUnits units left in stock. Restock soon.', style: TextStyle(fontSize: 13, color: theme.colorScheme.error.withValues(alpha: 0.8))),
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
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/tech_zone_logo.png', width: 44, height: 44, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAdmin ? 'DASHBOARD' : 'USER HUB',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 2),
                ),
                Text(
                  isAdmin ? 'TechZone Pro' : 'TechZone',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -1, fontSize: 22),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
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
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Explore Collection', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/computers'),
                child: const Text('View All'),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.1),
        const SizedBox(height: 12),
        if (_allAssets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('Empty inventory', style: TextStyle(color: Colors.grey))),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _allAssets.length > 8 ? 8 : _allAssets.length,
            itemBuilder: (context, index) {
              final a = _allAssets[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade50),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                      child: (a['image_url'] != null && a['image_url'].toString().isNotEmpty) 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16), 
                            child: Image.network(
                              a['image_url'], 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.dns_rounded, size: 24, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                            ),
                          ) 
                        : Icon(Icons.dns_rounded, size: 24, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['brand'] ?? 'Premium Tech', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text('Curated for you', style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs. ${a['processor']}', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ).animate().fadeIn(delay: 900.ms),
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
              const SizedBox(width: 12),
              _StatCard(
                label: 'Orders',
                value: _totalOrders.toString(),
                icon: Icons.shopping_basket_rounded,
                color: const Color(0xFF10B981),
                delayMs: 200,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Products',
                value: _availableAssets.toString(),
                icon: Icons.inventory_2_rounded,
                color: _isLowStock ? Colors.redAccent : const Color(0xFF6366F1),
                delayMs: 300,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _AdminActionTile(
                title: 'Orders',
                subtitle: 'Manage activity',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF6366F1),
                onTap: () => Navigator.pushNamed(context, '/orders').then((_) => _fetchStats()),
                delayMs: 100,
              ),
              _AdminActionTile(
                title: 'Products',
                subtitle: 'Add/Edit stock',
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF14B8A6),
                onTap: () async {
                  await Navigator.pushNamed(context, '/computers');
                  _fetchStats();
                },
                delayMs: 200,
              ),
              _AdminActionTile(
                title: 'New Item',
                subtitle: 'Quick register',
                icon: Icons.add_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () async {
                  await Navigator.pushNamed(context, '/add-computer');
                  _fetchStats();
                },
                delayMs: 300,
              ),
              _AdminActionTile(
                title: 'Analytics',
                subtitle: 'Finance reports',
                icon: Icons.analytics_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsPage(totalRevenue: _totalRevenue, totalOrders: _totalOrders))),
                delayMs: 400,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text('Recent Orders Feed', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
               TextButton(onPressed: () => Navigator.pushNamed(context, '/orders'), child: const Text('Global History')),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
        const SizedBox(height: 12),
        _buildRecentOrders(theme),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildRecentOrders(ThemeData theme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase.from('orders').select().order('created_at', ascending: false).limit(5),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('No recent orders activity', style: TextStyle(color: Colors.grey))),
          );
        }
        
        final recentOrders = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: recentOrders.length,
          itemBuilder: (context, index) {
            final order = recentOrders[index];
            final status = order['status'] ?? 'Processing';
            final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
            
            Color statusColor = Colors.orange;
            if (status == 'Delivered' || status == 'Completed') statusColor = Colors.green;
            if (status == 'Cancelled') statusColor = Colors.red;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade50),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.receipt_rounded, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #${order['id'].toString().substring(0,8)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text('Rs. ${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                ],
              ),
            );
          },
        );
      },
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
      width: 170,
      height: 170,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 25, offset: const Offset(0, 12)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const Spacer(),
          Text(value, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color, letterSpacing: -1.2)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade300, letterSpacing: 0.5)),
        ],
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.2, end: 0).shimmer(delay: (delayMs + 400).ms, duration: 1.5.seconds);
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
          color: color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)]
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 18, letterSpacing: -0.8)
            ),
            const SizedBox(height: 2),
            Text(
              subtitle, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w700)
            ),
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
          BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.35), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('PREMIUM ACCESS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Your personalized inventory hub is ready.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, fontWeight: FontWeight.w500)),
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
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
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
              Text('Products', style: TextStyle(color: color.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
