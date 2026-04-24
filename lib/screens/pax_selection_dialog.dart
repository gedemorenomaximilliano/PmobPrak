import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';

class PaxSelectionDialog extends StatefulWidget {
  final dynamic destination;
  const PaxSelectionDialog({super.key, required this.destination});

  @override
  State<PaxSelectionDialog> createState() => _PaxSelectionDialogState();
}

class _PaxSelectionDialogState extends State<PaxSelectionDialog> {
  int _pax = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Visitors'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Destination: ${widget.destination['nama_destination']}'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() => _pax = _pax > 1 ? _pax - 1 : 1),
              ),
              Text('$_pax', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _pax++),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        GradientButton('Add to Cart', () {
          final item = Map<String, dynamic>.from(widget.destination);
          item['pax'] = _pax;
          item['harga'] = (double.parse(item['harga'].toString()) * _pax).toString();
          cartService.addToCart(item);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
        }),
      ],
    );
  }
}
