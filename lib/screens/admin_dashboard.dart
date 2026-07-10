import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'admin_edit_item_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await apiService.getAdminDashboard();
      if (!mounted) return;
      setState(() { _stats = data; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatNumber(dynamic val) {
    final num = double.tryParse(val.toString()) ?? 0;
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toStringAsFixed(num == num.roundToDouble() ? 0 : 1);
  }

  String _formatCurrency(dynamic val) {
    final num = double.tryParse(val.toString()) ?? 0;
    if (num >= 1000000) return 'Rp${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return 'Rp${(num / 1000).toStringAsFixed(1)}K';
    return 'Rp${num.toStringAsFixed(0)}';
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Admin Console',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadStats),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await apiService.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text('Failed to load dashboard',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadStats,
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 130, left: 20, right: 20, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 16),
            if (_hasMonthlyData('monthly_revenue')) ..._buildRevenueChart(),
            const SizedBox(height: 16),
            if (_hasMonthlyData('monthly_users')) ..._buildUsersChart(),
            const SizedBox(height: 16),
            _buildRecentLists(),
            const SizedBox(height: 16),
            _buildManagement(),
          ],
        ),
      ),
    );
  }

  bool _hasMonthlyData(String key) {
    final list = _stats?[key];
    return list is List && list.isNotEmpty;
  }

  Widget _buildQuickStats() {
    final s = _stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Stats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 14),
        GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.65,
          children: [
            _buildStatCard('Revenue', _formatCurrency(s?['total_revenue'] ?? 0),
                Icons.payments, Colors.greenAccent),
            _buildStatCard('Orders', '${s?['total_orders'] ?? 0}',
                Icons.shopping_bag, Colors.orangeAccent),
            _buildStatCard('Items', '${s?['total_items'] ?? 0}',
                Icons.beach_access, Colors.blueAccent),
            _buildStatCard('Users', '${s?['total_users'] ?? 0}',
                Icons.people, Colors.purpleAccent),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildRevenueChart() {
    final list = (_stats!['monthly_revenue'] as List).cast<Map<String, dynamic>>();
    final maxY = list.fold<double>(0, (p, e) => p > (e['total'] as num).toDouble() ? p : (e['total'] as num).toDouble());
    return [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.trending_up, color: Colors.greenAccent, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Monthly Revenue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
      const SizedBox(height: 14),
      Container(
        height: 180,
        padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY * 1.2,
            barTouchData: BarTouchData(enabled: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY * 0.3,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= list.length) return const SizedBox();
                    final month = list[idx]['month'] as String;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(month.length >= 7 ? month.substring(5) : month,
                          style: const TextStyle(color: Colors.white38, fontSize: 9)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: list.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: (e.value['total'] as num).toDouble(),
                    color: Colors.greenAccent,
                    width: 14,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildUsersChart() {
    final list = (_stats!['monthly_users'] as List).cast<Map<String, dynamic>>();
    final maxY = list.fold<double>(0, (p, e) => p > (e['count'] as num).toDouble() ? p : (e['count'] as num).toDouble());
    return [
      const SizedBox(height: 4),
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_add, color: Colors.blueAccent, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('New Users',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
      const SizedBox(height: 14),
      Container(
        height: 160,
        padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxY * 1.4).clamp(4, double.infinity),
            barTouchData: BarTouchData(enabled: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= list.length) return const SizedBox();
                    final month = list[idx]['month'] as String;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(month.length >= 7 ? month.substring(5) : month,
                          style: const TextStyle(color: Colors.white38, fontSize: 9)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: list.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: (e.value['count'] as num).toDouble(),
                    color: Colors.blueAccent,
                    width: 14,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ];
  }

  Widget _buildRecentLists() {
    final orders = (_stats?['recent_orders'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final users = (_stats?['recent_users'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildRecentCard('New Orders', Icons.receipt, Colors.orangeAccent, orders, (o) => [
          Text(o['user_name']?.toString() ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          Text('Rp${_formatNumber(o['total_price'])} · ${o['status']}',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ])),
        const SizedBox(width: 10),
        Expanded(child: _buildRecentCard('New Users', Icons.person, Colors.blueAccent, users, (u) => [
          Text(u['name']?.toString() ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(u['email']?.toString() ?? '',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ])),
      ],
    );
  }

  Widget _buildRecentCard(
    String title,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> items,
    List<Widget> Function(Map<String, dynamic>) buildLines,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('No data', style: TextStyle(color: Colors.white30, fontSize: 12)),
            )
          else
            ...items.take(5).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildLines(item),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings, color: Colors.amber, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Management',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 14),
        _buildMenuTile(
          'Manage Destinations',
          'Edit or remove destinations',
          Icons.edit_location_alt_rounded,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageDestinationsScreen())),
        ),
        const SizedBox(height: 10),
        _buildMenuTile(
          'Add New Destination',
          'Create new packages',
          Icons.add_location_alt_rounded,
          () => Navigator.pushNamed(context, '/admin_add_item').then((_) => _loadStats()),
        ),
        const SizedBox(height: 10),
        _buildMenuTile(
          'Transaction History',
          'View all bookings',
          Icons.history_edu_rounded,
          () => Navigator.pushNamed(context, '/transactions'),
        ),
      ],
    );
  }

  Widget _buildMenuTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class ManageDestinationsScreen extends StatefulWidget {
  const ManageDestinationsScreen({super.key});
  @override
  State<ManageDestinationsScreen> createState() => _ManageDestinationsScreenState();
}

class _ManageDestinationsScreenState extends State<ManageDestinationsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      final items = await apiService.getItems();
      if (!mounted) return;
      setState(() { _items = items; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D2B4E),
        title: const Text('Delete Destination', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure? This cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await apiService.deleteItem(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      _loadItems();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _editItem(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminEditItemScreen(item: item)),
    );
    if (result == true) _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Manage Destinations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2, color: Colors.white24, size: 56),
                        SizedBox(height: 16),
                        Text('No destinations yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadItems,
                    color: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: _buildThumbnail(item),
                              ),
                            ),
                            title: Text(item['nama_destination'] ?? 'Unknown',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(item['location'] ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    onPressed: () => _editItem(item)),
                                IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () => _delete(item['id_destination'])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildThumbnail(Map<String, dynamic> item) {
    final gambar = item['gambar'];
    if (gambar != null && gambar.toString().startsWith('data:image')) {
      try {
        final bytes = apiService.base64ToBytes(gambar.toString().split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      } catch (_) {}
    }
    return Image.asset(
      _fallbackAssets[(item['id_destination']?.hashCode ?? 0).abs() % _fallbackAssets.length],
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
        child: const Icon(Icons.landscape, color: Colors.white38, size: 22),
      ),
    );
  }

  static const List<String> _fallbackAssets = [
    'assets/images/baluran.jpg',
    'assets/images/acidicLake.jpg',
    'assets/images/blue fire kawah ijen.jpg',
    'assets/images/de-djawatan.jp.jpg',
    'assets/images/kawahijenvolcano.jpg',
  ];
}
