import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/aboutDestination.dart';
import '../screens/pax_selection_dialog.dart';
import '../services/api_service.dart';

class DestinationCard extends StatefulWidget {
  final dynamic destination;
  final bool hideFavorite;
  const DestinationCard({super.key, required this.destination, this.hideFavorite = false});

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    // In a production app, you would check if this item is in the user's favorites list
    // For now, we'll keep it simple
  }

  Future<void> _toggleFavorite() async {
    final itemId = widget.destination['id_destination'];
    try {
      setState(() => _isFavorite = !_isFavorite);
      await apiService.toggleFavorite(itemId, !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  String _formatPrice(dynamic harga) {
    if (harga == null) return 'Contact for price';

    try {
      String priceStr = harga.toString();
      if (priceStr.contains('.')) {
        priceStr = priceStr.substring(0, priceStr.indexOf('.'));
      }
      priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
      if (priceStr.isEmpty) return 'Contact for price';

      int priceInt = int.parse(priceStr);
      if (priceInt == 0) return 'Contact for price';

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
    final destination = widget.destination;
    final price = _formatPrice(destination['harga']);
    
    final List<dynamic> ratings = destination['ratings'] ?? [];
    final double averageRating = ratings.isEmpty
        ? 0.0
        : ratings.map((r) => (r['rating'] as num)).reduce((a, b) => a + b) / ratings.length;
    final String ratingScore = averageRating.toStringAsFixed(1);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DestinationDetailScreen(destination: destination),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            destination['nama_destination'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(ratings.isEmpty ? ' New' : ' $ratingScore',
                                style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white38, size: 12),
                        const SizedBox(width: 4),
                        Text(destination['location'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white38, fontSize: 11)),
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
    final destination = widget.destination;
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
    return Image.asset(
      'assets/images/baluran.jpg',
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
