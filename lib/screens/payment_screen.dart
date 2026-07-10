import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'snap_webview_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  final List<Map<String, dynamic>>? destinations;
  const PaymentScreen({super.key, required this.destination, this.destinations});

  List<Map<String, dynamic>> get effectiveDestinations =>
      destinations ?? [destination];

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _pax = 1;
  bool _isLoading = false;

  int _parsePrice(dynamic harga) {
    if (harga == null) return 0;
    try {
      String priceStr = harga.toString();
      if (priceStr.contains('.')) {
        priceStr = priceStr.substring(0, priceStr.indexOf('.'));
      }
      priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
      if (priceStr.isEmpty) return 0;
      return int.parse(priceStr);
    } catch (e) {
      return 0;
    }
  }

  int get _basePrice => _parsePrice(widget.destination['harga']);
  int get _totalPrice => _basePrice * _pax;
  bool get _isMultiItem => widget.destinations != null;

  int _tax(int amount) => (amount * 0.11).round();

  int get _multiTotalPrice {
    int total = 0;
    for (final d in widget.effectiveDestinations) {
      final price = _parsePrice(d['harga']);
      final pax = d['pax'] is int ? d['pax'] as int : 1;
      total += price * pax;
    }
    return total;
  }

  String _formatIDR(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'IDR ${buf.toString()}';
  }

  Future<void> _pay() async {
    setState(() => _isLoading = true);

    try {
      final baseTotal = _isMultiItem ? _multiTotalPrice : _totalPrice;
      final tax = _tax(baseTotal);
      final grandTotal = baseTotal + tax;

      Map<String, dynamic> orderRes;

      if (_isMultiItem) {
        // Build one transaction with ALL cart items
        final itemsList = widget.destinations!.map((item) {
          final pax = item['pax'] is int ? item['pax'] as int : 1;
          return {
            'id': item['id_destination'] ?? 1,
            'quantity': pax,
          };
        }).toList();

        orderRes = await apiService.createTransaction({
          'items': itemsList,
          'tax_rate': 0.11,
        });
      } else {
        orderRes = await apiService.createTransaction({
          'items': [
            {
              'id': widget.destination['id_destination'] ?? 1,
              'quantity': _pax,
            }
          ],
          'tax_rate': 0.11,
        });
      }

      final orderId = orderRes['data']['id'];
      final snapRes = await apiService.createSnapToken(orderId);
      final snapToken = snapRes['snap_token'];
      final redirectUrl = snapRes['redirect_url'];

      if (_isMultiItem) {
        cartService.clearCart();
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SnapWebViewScreen(
            snapToken: snapToken,
            redirectUrl: redirectUrl,
            orderId: orderId.toString(),
            destination: widget.destination,
            pax: _isMultiItem ? 0 : _pax,
            total: grandTotal,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            stops: [0.0, 0.30, 0.65],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDestinationSummary(),
                      const SizedBox(height: 20),
                      if (!_isMultiItem) _buildPaxSelector(),
                      const SizedBox(height: 20),
                      _buildOrderSummary(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Booking & Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDestinationSummary() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: _buildDestinationImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.destination['nama_destination'] ?? 'Unknown',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Row(children: [
                  const FaIcon(FontAwesomeIcons.solidStar,
                      color: Color(0xFFFFA000), size: 14),
                  const SizedBox(width: 4),
                  Text(
                      '${widget.destination['rating']?.toString() ?? '0.0'} (${widget.destination['review'] ?? 0} reviews)',
                      style: const TextStyle(
                          color: Color(0xFFFFA000), fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                Text(
                  widget.destination['deskripsi'] == 'null' ||
                          widget.destination['deskripsi'] == null
                      ? 'No description available'
                      : widget.destination['deskripsi'],
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationImage() {
    final gambar = widget.destination['gambar'];
    if (gambar != null && gambar.toString().startsWith('data:image')) {
      try {
        final base64String = gambar.toString().split(',').last;
        final bytes = apiService.base64ToBytes(base64String);
        return Image.memory(
          bytes,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderImage(),
        );
      } catch (e) {
        return _placeholderImage();
      }
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      height: 160,
      color: const Color(0xFF2C3E50),
      child: const Center(
          child:
              FaIcon(FontAwesomeIcons.image, color: Colors.white54, size: 60)),
    );
  }

  Widget _buildPaxSelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Number of Visitors'),
          const SizedBox(height: 16),
          Row(children: [
            _buildCounterButton(FontAwesomeIcons.minus, () {
              if (_pax > 1) setState(() => _pax--);
            }),
            const SizedBox(width: 16),
            Text('$_pax',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 16),
            _buildCounterButton(FontAwesomeIcons.plus, () {
              if (_pax < 20) setState(() => _pax++);
            }),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatIDR(_basePrice),
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 2),
                Text(_formatIDR(_totalPrice),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    if (_isMultiItem) {
      final total = _multiTotalPrice;
      final tax = _tax(total);
      final grandTotal = total + tax;
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Order Summary'),
            const SizedBox(height: 12),
            ...widget.destinations!.map((item) {
              final price = _parsePrice(item['harga']);
              final pax = item['pax'] is int ? item['pax'] as int : 1;
              return _summaryRow(
                '${item['nama_destination'] ?? 'Item'} × $pax pax',
                _formatIDR(price * pax),
              );
            }),
            _summaryRow('Tax (11%)', _formatIDR(tax)),
            const Divider(color: Colors.white12, height: 24),
            _summaryRow('Total', _formatIDR(grandTotal),
                bold: true, accent: true),
          ],
        ),
      );
    }

    final tax = _tax(_totalPrice);
    final grandTotal = _totalPrice + tax;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Order Summary'),
          const SizedBox(height: 12),
          _summaryRow(
              '${widget.destination['nama_destination'] ?? 'Destination'} × $_pax pax',
              _formatIDR(_totalPrice)),
          _summaryRow('Tax (11%)', _formatIDR(tax)),
          const Divider(color: Colors.white12, height: 24),
          _summaryRow('Total', _formatIDR(grandTotal),
              bold: true, accent: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, bool accent = false}) {
    final style = TextStyle(
      color: accent ? const Color(0xFF42A5F5) : Colors.white60,
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  Widget _buildPayButton() {
    final baseTotal = _isMultiItem ? _multiTotalPrice : _totalPrice;
    final tax = _tax(baseTotal);
    final grandTotal = baseTotal + tax;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: const Color(0xFF0A1A2B),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GradientButton('Pay ${_formatIDR(grandTotal)}', _pay,
              height: 56, radius: 16),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
            child: FaIcon(icon, color: const Color(0xFF42A5F5), size: 18)),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14));
  }
}
