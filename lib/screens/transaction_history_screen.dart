import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final transactions = await apiService.getUserTransactions();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  List<dynamic> get _completedTransactions =>
      _transactions.where((tx) => tx['status'] == 'completed').toList();

  List<dynamic> get _pendingTransactions =>
      _transactions.where((tx) => tx['status'] != 'completed').toList();

  String _formatIDR(dynamic amount) {
    final num = double.tryParse(amount.toString()) ?? 0;
    final s = num.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _bookingCode(dynamic tx) {
    final id = tx['id'] ?? 0;
    final hash = id.hashCode.isNegative ? -id.hashCode : id.hashCode;
    return 'BW${hash.toRadixString(36).toUpperCase().padLeft(6, '0').substring(0, 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Bookings',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTransactions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Purchase History'),
            Tab(text: 'Tickets'),
          ],
        ),
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
            : _error != null
                ? _buildError()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPurchaseHistory(),
                      _buildTickets(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          Text(_error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label:
                const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistory() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, color: Colors.white24, size: 56),
            SizedBox(height: 16),
            Text('No purchases yet',
                style: TextStyle(color: Colors.white54, fontSize: 16)),
            SizedBox(height: 8),
            Text('Your booking history will appear here',
                style: TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return _buildPurchaseCard(tx);
        },
      ),
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> tx) {
    final status = tx['status'] ?? 'pending';
    final details = tx['details'] as List? ?? [];
    final isCompleted = status == 'completed';
    final statusColor = isCompleted ? const Color(0xFF43E97B) : Colors.amber;
    final statusBg = isCompleted
        ? const Color(0xFF43E97B).withOpacity(0.15)
        : Colors.amber.withOpacity(0.15);

    return GestureDetector(
      onTap: () => _showTransactionDetail(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${tx['id']}',
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status.toString().toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (details.isNotEmpty)
              ...details.map((d) => _buildDetailRow(d)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(tx['created_at']),
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
                  Text(_formatIDR(tx['total_price']),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(Map<String, dynamic> detail) {
    final item = detail['item'];
    final name = item?['name'] ?? 'Item';
    final quantity = detail['quantity'] ?? 1;
    final price = detail['price'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildItemThumbnail(item),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Qty: $quantity',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text(_formatIDR(price),
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildItemThumbnail(Map<String, dynamic>? item) {
    if (item == null) {
      return const Icon(Icons.landscape, color: Colors.white38, size: 20);
    }
    final image = item['image'];
    if (image != null && image.toString().startsWith('data:image')) {
      try {
        final bytes =
            apiService.base64ToBytes(image.toString().split(',').last);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
        );
      } catch (_) {}
    }
    return const Icon(Icons.landscape, color: Colors.white38, size: 20);
  }

  Widget _buildTickets() {
    if (_completedTransactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number, color: Colors.white24, size: 56),
            SizedBox(height: 16),
            Text('No tickets yet',
                style: TextStyle(color: Colors.white54, fontSize: 16)),
            SizedBox(height: 8),
            Text('Completed bookings will appear as tickets',
                style: TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _completedTransactions.length,
        itemBuilder: (context, index) {
          final tx = _completedTransactions[index];
          return _buildTicketCard(tx);
        },
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> tx) {
    final details = tx['details'] as List? ?? [];
    final code = _bookingCode(tx);
    final firstItem =
        details.isNotEmpty ? details[0]['item'] : null;
    final itemName = firstItem?['name'] ?? 'Destination';
    final totalQty =
        details.fold<int>(0, (sum, d) => sum + ((d['quantity'] as int?) ?? 0));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D2B4E)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                const Text('E-Ticket',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43E97B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF43E97B).withOpacity(0.5)),
                  ),
                  child: const Text('PAID',
                      style: TextStyle(
                          color: Color(0xFF43E97B),
                          fontWeight: FontWeight.w800,
                          fontSize: 10)),
                ),
              ],
            ),
          ),
          _DashedDivider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ticketRow('Destination', details.length > 1
                    ? '$itemName +${details.length - 1} more'
                    : itemName),
                _ticketRow('Booking Code', code, accent: true),
                _ticketRow('Visitors', '$totalQty pax'),
                _ticketRow('Date', _formatDate(tx['created_at'])),
                const Divider(color: Colors.white12, height: 20),
                _ticketRow('Total Paid', _formatIDR(tx['total_price']),
                    bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketRow(String label, String value,
      {bool accent = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value,
              style: TextStyle(
                color: accent ? kSkyBlue : Colors.white,
                fontWeight: bold || accent ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> tx) {
    final details = tx['details'] as List? ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D2B4E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${tx['id']}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tx['status'] == 'completed'
                          ? const Color(0xFF43E97B).withOpacity(0.15)
                          : Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        (tx['status'] ?? 'pending').toString().toUpperCase(),
                        style: TextStyle(
                            color: tx['status'] == 'completed'
                                ? const Color(0xFF43E97B)
                                : Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(_formatDate(tx['created_at']),
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 16),
              ...details.map((d) {
                final item = d['item'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildItemThumbnail(item),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item?['name'] ?? 'Item',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                                '${d['quantity']}x  ${_formatIDR(d['price'])}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                          _formatIDR(
                              (double.tryParse(d['price'].toString()) ?? 0) *
                                  (d['quantity'] ?? 1)),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text(_formatIDR(tx['total_price']),
                        style: const TextStyle(
                            color: kAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 17)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final dashCount = (constraints.maxWidth / 8).floor();
        return Row(
          children: List.generate(
            dashCount,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 1,
                color: Colors.white12,
              ),
            ),
          ),
        );
      },
    );
  }
}
