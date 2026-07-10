import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/destination_card.dart';
import '../screens/pax_selection_dialog.dart';
import '../constants/colors.dart';

class ExplorePlacesScreen extends StatefulWidget {
  const ExplorePlacesScreen({super.key});

  @override
  State<ExplorePlacesScreen> createState() => _ExplorePlacesScreenState();
}

class _ExplorePlacesScreenState extends State<ExplorePlacesScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _error;
  Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _loadFavorites();
  }

  Future<void> _fetchItems() async {
    try {
      final items = await apiService.getItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await apiService.getFavorites();
      if (mounted) {
        setState(() {
          _favoriteIds = favorites
              .map((f) => int.tryParse(f['item']?['id']?.toString() ?? '') ?? 0)
              .where((id) => id > 0)
              .toSet();
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite(Map<String, dynamic> destination) async {
    final itemId = int.tryParse(destination['id_destination']?.toString() ?? '') ?? 0;
    if (itemId == 0) return;
    final isFav = _favoriteIds.contains(itemId);
    setState(() {
      if (isFav) {
        _favoriteIds.remove(itemId);
      } else {
        _favoriteIds.add(itemId);
      }
    });
    try {
      await apiService.toggleFavorite(itemId, isFav);
    } catch (e) {
      setState(() {
        if (isFav) {
          _favoriteIds.add(itemId);
        } else {
          _favoriteIds.remove(itemId);
        }
      });
    }
  }

  void _showPaxDialog(Map<String, dynamic> destination) {
    showDialog(
      context: context,
      builder: (_) => PaxSelectionDialog(destination: destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Explore Places',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: kAccent,
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.white54, size: 48),
                                const SizedBox(height: 16),
                                Text(_error!,
                                    style: const TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                        _error = null;
                                      });
                                      _fetchItems();
                                    },
                                    child: const Text('Retry',
                                        style: TextStyle(color: Colors.white))),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.58,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final d = _items[index];
                              final itemId = int.tryParse(
                                      d['id_destination']?.toString() ?? '') ??
                                  0;
                              return DestinationCard(
                                destination: d,
                                isFavorite: _favoriteIds.contains(itemId),
                                onFavoriteToggle: () => _toggleFavorite(d),
                                onAddToCart: () => _showPaxDialog(d),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
    );
  }
}
