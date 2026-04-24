import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _itemCount = 0;
  int _categoryCount = 0;
  int _transactionCount = 0;
  double _totalRevenue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final items = await apiService.getItems();
      final categories = await apiService.getCategories();
      final transactions = await apiService.getUserTransactions();

      double revenue = 0;
      for (var tx in transactions) {
        revenue += double.tryParse(tx['total_price'].toString()) ?? 0;
      }

      setState(() {
        _itemCount = items.length;
        _categoryCount = categories.length;
        _transactionCount = transactions.length;
        _totalRevenue = revenue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatLargeNumber(double num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toStringAsFixed(0);
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: Colors.white70),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white60)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white60),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Admin Console',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadStats),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              apiService.clearToken();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _loadStats,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      top: 120, left: 20, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Quick Stats",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildStatCard(
                              'Revenue',
                              'IDR ${_formatLargeNumber(_totalRevenue)}',
                              Icons.payments,
                              Colors.green),
                          _buildStatCard(
                              'Bookings',
                              _transactionCount.toString(),
                              Icons.shopping_bag,
                              Colors.orange),
                          _buildStatCard('Destinations', _itemCount.toString(),
                              Icons.beach_access, Colors.blue),
                          _buildStatCard(
                              'Categories',
                              _categoryCount.toString(),
                              Icons.category,
                              Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text("Management",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 15),
                      _buildMenuTile(
                          'Manage Destinations',
                          'Edit or remove destinations',
                          Icons.edit_location_alt_rounded,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ManageDestinationsScreen()))),
                      _buildMenuTile(
                          'Add New Destination',
                          'Create new packages',
                          Icons.add_location_alt_rounded,
                          () => Navigator.pushNamed(context, '/admin_add_item')
                              .then((_) => _loadStats())),
                      _buildMenuTile(
                          'Transaction History',
                          'View all bookings',
                          Icons.history_edu_rounded,
                          () => Navigator.pushNamed(context, '/transactions')),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class ManageDestinationsScreen extends StatefulWidget {
  const ManageDestinationsScreen({super.key});
  @override
  State<ManageDestinationsScreen> createState() =>
      _ManageDestinationsScreenState();
}

class _ManageDestinationsScreenState extends State<ManageDestinationsScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await apiService.getItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _delete(int id) async {
    await http.delete(Uri.parse('${ApiService.baseUrl}/items/$id'),
        headers: {'Authorization': 'Bearer ${apiService.getToken()}'});
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Manage Destinations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
          itemCount: _items.length,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(_items[index]['nama_destination'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _delete(_items[index]['id_destination'])),
            ),
          ),
        ),
      ),
    );
  }
}

