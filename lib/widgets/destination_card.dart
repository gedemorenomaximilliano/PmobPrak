import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/payment_screen.dart';
import '../services/api_service.dart';

class DestinationCard extends StatelessWidget {
  final dynamic destination;
  const DestinationCard({super.key, required this.destination});

  String _formatPrice(dynamic harga) {
    if (harga == null) return 'Contact for price';

    try {
      String priceStr = harga.toString();

      // Remove decimal part (.00)
      if (priceStr.contains('.')) {
        priceStr = priceStr.substring(0, priceStr.indexOf('.'));
      }

      // Remove any non-numeric characters
      priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');

      if (priceStr.isEmpty) return 'Contact for price';

      int priceInt = int.parse(priceStr);
      if (priceInt == 0) return 'Contact for price';

      // Format with thousand separators
      final s = priceInt.toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
        buf.write(s[i]);
      }
      return 'IDR ${buf.toString()}';
    } catch (e) {
      return 'Contact for price';
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _formatPrice(destination['harga']);
    final rating = destination['rating']?.toString() ?? '0.0';
    final reviews = destination['review'] ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(destination: destination),
        ),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2B3E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _buildDestinationImage(),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination['nama_destination'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.solidStar,
                          color: Color(0xFFFFA000),
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '$rating ($reviews Review)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFFA000),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        destination['deskripsi'] == 'null' ||
                                destination['deskripsi'] == null
                            ? 'No description available'
                            : destination['deskripsi'],
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        price,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationImage() {
    if (destination['gambar'] != null &&
        destination['gambar'].toString().startsWith('data:image')) {
      try {
        final base64String = destination['gambar'].toString().split(',').last;
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
      color: const Color(0xFF2C3E50).withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.landscape,
          color: Colors.white54,
          size: 48,
        ),
      ),
    );
  }
}
