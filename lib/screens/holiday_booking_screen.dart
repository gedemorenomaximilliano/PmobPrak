import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/gradient_button.dart';
import 'snap_webview_screen.dart';

class HolidayBookingScreen extends StatefulWidget {
  final dynamic destination;
  const HolidayBookingScreen({super.key, required this.destination});

  @override
  State<HolidayBookingScreen> createState() => _HolidayBookingScreenState();
}

class _HolidayBookingScreenState extends State<HolidayBookingScreen> {
  DateTime? _date;
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
  int _tax(int amount) => (amount * 0.11).round();

  String _formatIDR(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'IDR ${buf.toString()}';
  }

  Future<void> _submit() async {
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final grandTotal = _totalPrice + _tax(_totalPrice);

      final orderRes = await apiService.createTransaction({
        'items': [{'id': widget.destination['id_destination'], 'quantity': _pax}],
      });
      final orderId = orderRes['data']['id'];

      final snapRes = await apiService.createSnapToken(orderId);
      final snapToken = snapRes['snap_token'];
      final redirectUrl = snapRes['redirect_url'];

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SnapWebViewScreen(
            snapToken: snapToken,
            redirectUrl: redirectUrl,
            orderId: orderId.toString(),
            destination: widget.destination is Map<String, dynamic>
                ? widget.destination as Map<String, dynamic>
                : {'nama_destination': widget.destination['name'] ?? 'Destination', 'id_destination': widget.destination['id_destination']},
            pax: _pax,
            total: grandTotal,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Holiday')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ListTile(
              title: Text(_date == null ? 'Select Holiday Date' : 'Date: ${_date.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Amount of people: '),
                IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _pax = _pax > 1 ? _pax - 1 : 1)),
                Text('$_pax', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _pax++)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Total: ${_formatIDR(_totalPrice + _tax(_totalPrice))}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _isLoading
                ? const CircularProgressIndicator()
                : GradientButton('Book & Pay', _submit),
          ],
        ),
      ),
    );
  }
}
