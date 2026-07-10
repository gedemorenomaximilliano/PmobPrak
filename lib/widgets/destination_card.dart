import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../screens/aboutDestination.dart';
import '../services/api_service.dart';
import '../constants/colors.dart';

class DestinationCard extends StatefulWidget {
  final Map<String, dynamic> destination;
  final bool hideFavorite;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCart;

  const DestinationCard({
    super.key,
    required this.destination,
    this.hideFavorite = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onAddToCart,
  });

  static final Map<String, Uint8List> _imageCache = {};
  static Map<String, Uint8List> get imageCache => _imageCache;

  static const List<String> _fallbackAssets = [
    'assets/images/baluran.jpg',
    'assets/images/acidicLake.jpg',
    'assets/images/blue fire kawah ijen.jpg',
    'assets/images/de-djawatan.jp.jpg',
    'assets/images/kawahijenvolcano.jpg',
  ];

  static String getFallbackAsset(dynamic id) {
    final index = (id.hashCode.abs()) % _fallbackAssets.length;
    return _fallbackAssets[index];
  }

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  static String _formatPrice(dynamic harga) {
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
        : ratings.map((r) {
            final v = r['rating'];
            if (v is num) return v.toDouble();
            return (num.tryParse(v?.toString() ?? '') ?? 0).toDouble();
          }).fold<double>(0.0, (a, b) => a + b) / ratings.length;
    final String ratingScore = averageRating.toStringAsFixed(1);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DestinationDetailScreen(destination: destination),
        ),
      ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kAccent.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: kAccent.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildDestinationImage(),
                  if (!widget.hideFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildFavoriteButton(),
                    ),
                  if (widget.onAddToCart != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildCartButton(),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            destination['nama_destination'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 12),
                            Text(
                                ratings.isEmpty ? ' New' : ' $ratingScore',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white38, size: 10),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            destination['location'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        destination['deskripsi'] == 'null' ||
                                destination['deskripsi'] == null
                            ? 'No description available'
                            : destination['deskripsi'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kAccent, Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: kAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        price,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
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

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: widget.onFavoriteToggle,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.isFavorite ? Colors.redAccent : Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: widget.onAddToCart,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: kAccent.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: kAccent.withOpacity(0.5), width: 1),
        ),
        child: const Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildDestinationImage() {
    final gambar = widget.destination['gambar'];
    if (gambar != null && gambar.toString().startsWith('data:image')) {
      final key = widget.destination['id_destination'].toString();
      Uint8List? bytes = DestinationCard._imageCache[key];
      if (bytes == null) {
        try {
          final base64String = gambar.toString().split(',').last;
          bytes = apiService.base64ToBytes(base64String);
          DestinationCard._imageCache[key] = bytes;
        } catch (e) {
          return _placeholderImage();
        }
      }
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }
    return _placeholderImage();
  }

  Widget _placeholderImage() {
    final assetPath = DestinationCard.getFallbackAsset(
        widget.destination['id_destination']);
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.landscape, color: Colors.white38, size: 40),
      ),
    );
  }
}
