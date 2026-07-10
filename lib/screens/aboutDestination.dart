import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'pax_selection_dialog.dart';
import 'payment_screen.dart';
import 'itinerary_screen.dart';
import '../widgets/rating_dialog.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late Map<String, dynamic> _destination;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _loadFullDetail();
  }

  Future<void> _loadFullDetail() async {
    try {
      final id = int.tryParse(_destination['id_destination']?.toString() ?? '') ?? 0;
      if (id == 0) return;
      final full = await apiService.getDestinationById(id);
      if (mounted) setState(() => _destination = full);
    } catch (_) {}
  }

  Future<void> _refresh() async {
    final updated = await apiService.getDestinationById(_destination['id_destination']);
    setState(() => _destination = updated);
  }

  @override
  Widget build(BuildContext context) {
    final String destinationTitle =
        _destination['nama_destination'] ?? "Unknown";
    final String priceText = "IDR ${_destination['harga'] ?? '0'}/pax";
    final List<dynamic> ratings = _destination['ratings'] ?? [];
    final double averageRating = ratings.isEmpty
        ? 0.0
        : ratings.map((r) {
            final v = r['rating'];
            if (v is num) return v.toDouble();
            return (num.tryParse(v?.toString() ?? '') ?? 0).toDouble();
          }).fold<double>(0.0, (a, b) => a + b) / ratings.length;
    final String ratingScore = averageRating.toStringAsFixed(1);


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        child: Column(
          children: [
            // Image area
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: (_destination['images'] != null && (_destination['images'] as List).isNotEmpty)
                        ? (_destination['images'] as List).length
                        : 1,
                    itemBuilder: (context, index) {
                      String? imageUrl;
                      if (_destination['images'] != null && (_destination['images'] as List).isNotEmpty) {
                        imageUrl = (_destination['images'] as List)[index]['image'];
                      } else {
                        imageUrl = _destination['gambar'];
                      }

                      Widget imageWidget;
                      if (imageUrl != null && imageUrl.toString().startsWith('data:image')) {
                        try {
                          final bytes = apiService.base64ToBytes(imageUrl.toString().split(',').last);
                          imageWidget = Image.memory(bytes, fit: BoxFit.cover);
                        } catch (e) {
                          imageWidget = Image.asset('assets/images/baluran.jpg', fit: BoxFit.cover);
                        }
                      } else {
                        imageWidget = Image.asset('assets/images/baluran.jpg', fit: BoxFit.cover);
                      }
                      return imageWidget;
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D2B4E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(destinationTitle,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                final id = _destination['id_destination'];
                                final parsedId = int.tryParse(id?.toString() ?? '0') ?? 0;
                                showDialog(
                                  context: context,
                                  builder: (_) => RatingDialog(itemId: parsedId, onSubmitted: _refresh),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(ratingScore,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(priceText,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF42A5F5),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.white54, size: 16),
                          const SizedBox(width: 4),
                          Text(_destination['category']?['name'] ?? 'General',
                              style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on, color: Colors.white54, size: 16),
                          const SizedBox(width: 4),
                          Text(_destination['location'] ?? 'Unknown Location',
                              style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.inventory, color: Colors.white54, size: 16),
                          const SizedBox(width: 4),
                          Text('Stock: ${_destination['stock'] ?? '0'}',
                              style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          const SizedBox(width: 16),
                          const Icon(Icons.date_range, color: Colors.white54, size: 16),
                          const SizedBox(width: 4),
                          Text('${_destination['date_start'] ?? 'N/A'} - ${_destination['date_end'] ?? 'N/A'}',
                              style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("About",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      Text(
                          _destination['deskripsi'] ??
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70, height: 1.6)),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child:                             ElevatedButton(
                              onPressed: () {
                                  final id = int.tryParse(_destination['id_destination']?.toString() ?? '') ?? 0;
                                  final itemsRaw = _destination['itinerary_items'];
                                  final List<Map<String, dynamic>>? itemsList =
                                      (itemsRaw is List) ? itemsRaw.cast<Map<String, dynamic>>() : null;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ItineraryScreen(
                                                destinationName: destinationTitle,
                                                destinationId: id,
                                                itineraryItems: itemsList,
                                                rawItineraryText: _destination['itinerary']?.toString(),
                                              )));
                                },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white10,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.route, color: Colors.white70, size: 18),
                                  SizedBox(width: 8),
                                  Text("View Itinerary",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PaymentScreen(
                                          destination: _destination))),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text("Buy Now",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text("Comments",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 16),
                      _destination['ratings'] != null &&
                              (_destination['ratings'] as List).isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (_destination['ratings'] as List).length,
                              itemBuilder: (context, index) {
                                final r = (_destination['ratings'] as List)[index];
                                return ListTile(
                                  title: Text(r['user']?['name'] ?? 'User',
                                      style: const TextStyle(color: Colors.white)),
                                  subtitle: Text(r['comment'] ?? '',
                                      style: const TextStyle(color: Colors.white70)),
                                  trailing: (r['user_id'] == apiService.currentUserId)
                                      ? IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () async {
                                            try {
                                              await apiService.deleteRating(r['id']);
                                              await _refresh();
                                            } catch (e) {
                                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                            }
                                          },
                                        )
                                      : null,
                                );
                              },
                            )
                          : const Text("No comments yet.",
                              style: TextStyle(color: Colors.white54)),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
