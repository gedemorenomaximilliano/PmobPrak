import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
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
      backgroundColor: const Color(0xFF0A1A2B),
      appBar: AppBar(
        title: const Text('My Tickets',
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
      ),
      body: Container(
        color: const Color(0xFF0D2137),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _error != null
                ? _buildError()
                : _buildTickets(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text('Failed to load tickets',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadTransactions,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
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
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
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
        padding:
            const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 24),
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
    final firstItem = details.isNotEmpty ? details[0]['item'] : null;
    final itemName = firstItem?['name'] ?? 'Destination';
    final totalQty = details.fold<int>(
        0, (sum, d) => sum + ((d['quantity'] as int?) ?? 0));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.confirmation_number,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('E-Ticket',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      Text('Order #${tx['id']}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43E97B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF43E97B).withValues(alpha: 0.4)),
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
          _ScallopDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              children: [
                _ticketRow('Destination',
                    details.length > 1
                        ? '$itemName +${details.length - 1} more'
                        : itemName,
                    icon: Icons.place_outlined),
                const SizedBox(height: 8),
                _ticketRow('Booking Code', code,
                    icon: Icons.qr_code, accent: true),
                const SizedBox(height: 8),
                _ticketRow('Visitors', '$totalQty pax',
                    icon: Icons.people_outline),
                const SizedBox(height: 8),
                _ticketRow('Date', _formatDate(tx['created_at']),
                    icon: Icons.calendar_today_outlined),
                const SizedBox(height: 8),
                _ticketRow('Time',
                    _formatDateTime(tx['created_at']).split(', ').last,
                    icon: Icons.access_time),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                _ticketRow('Total Paid', _formatIDR(tx['total_price']),
                    icon: Icons.payments_outlined, bold: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _showQRCode(tx, code),
                icon: const Icon(Icons.qr_code_2, size: 18),
                label: const Text('Show QR Ticket',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kSkyBlue,
                  side: BorderSide(color: kSkyBlue.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketRow(String label, String value,
      {IconData? icon, bool accent = false, bool bold = false}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: accent ? kSkyBlue : Colors.white30, size: 15),
          const SizedBox(width: 8),
        ],
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const Spacer(),
        Text(value,
            style: TextStyle(
              color: accent ? kSkyBlue : Colors.white,
              fontWeight:
                  bold || accent ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
            )),
      ],
    );
  }

  void _showQRCode(Map<String, dynamic> tx, String code) {
    final details = tx['details'] as List? ?? [];
    final totalQty = details.fold<int>(
        0, (sum, d) => sum + ((d['quantity'] as int?) ?? 0));
    final qrData =
        'JEBAK-BW|$code|TX:${tx['id']}|QTY:$totalQty|TOTAL:${tx['total_price']}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF0D2B4E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Scan this QR Code',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              const SizedBox(height: 4),
              const Text('Show this at the entrance',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kBlueMid.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Color(0xFF1565C0),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(code,
                          style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: 3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _qrInfoRow(Icons.place_outlined,
                  details.isNotEmpty ? (details[0]['item']?['name'] ?? 'Destination') : 'Destination'),
              const SizedBox(height: 8),
              _qrInfoRow(Icons.people_outline, '$totalQty visitors'),
              const SizedBox(height: 8),
              _qrInfoRow(Icons.payments_outlined, _formatIDR(tx['total_price'])),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlueMid,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Close',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qrInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white30, size: 16),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }
}

class _ScallopDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF0D2B4E),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final dashCount = (constraints.maxWidth / 6).floor();
                return Row(
                  children: List.generate(
                    dashCount,
                    (_) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: 1,
                        color: Colors.white12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: 12,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF0D2B4E),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
