import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/destination_card.dart';
import '../screens/pax_selection_dialog.dart';
import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SortOption { newest, oldest, priceLow, priceHigh, locationAz }

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  List<dynamic> _destinations = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userProfile;
  Uint8List? _profileImageBytes;
  bool _profileLoading = true;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  SortOption _sortOption = SortOption.newest;

  static const _navIcons = [
    Icons.search_rounded,
    Icons.shopping_cart_outlined,
    Icons.home_outlined,
    Icons.confirmation_number_outlined,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await apiService.getUserProfile();
      Uint8List? bytes;
      if (user['profile_picture'] != null) {
        try {
          final b64 = user['profile_picture'].toString().split(',').last;
          bytes = apiService.base64ToBytes(b64);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _userProfile = user;
          _profileImageBytes = bytes;
          _profileLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  Future<void> _loadDestinations() async {
    try {
      final items = await apiService.getItems();
      if (mounted) {
        final cats = <String>{'All'};
        for (final item in items) {
          final cat = item['category'];
          if (cat != null && cat is Map) {
            final name = cat['name'];
            if (name != null) cats.add(name.toString());
          }
        }
        setState(() {
          _destinations = items;
          _categories = cats.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredDestinations {
    List<dynamic> list;
    if (_selectedCategory == 'All') {
      list = List.from(_destinations);
    } else {
      list = _destinations.where((d) {
        final cat = d['category'];
        if (cat is Map) return cat['name']?.toString() == _selectedCategory;
        return false;
      }).toList();
    }

    list.sort((a, b) {
      switch (_sortOption) {
        case SortOption.newest:
          return (b['date_start'] ?? '').compareTo(a['date_start'] ?? '');
        case SortOption.oldest:
          return (a['date_start'] ?? '').compareTo(b['date_start'] ?? '');
        case SortOption.priceLow:
          return _priceNum(a).compareTo(_priceNum(b));
        case SortOption.priceHigh:
          return _priceNum(b).compareTo(_priceNum(a));
        case SortOption.locationAz:
          return (a['location'] ?? '').toString().compareTo(
              (b['location'] ?? '').toString());
      }
    });

    return list;
  }

  double _priceNum(dynamic d) {
    try {
      return double.parse(d['harga'].toString());
    } catch (_) {
      return 0;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/explore');
        break;
      case 1:
        Navigator.pushNamed(context, '/cart');
        break;
      case 2:
        _loadDestinations();
        setState(() => _selectedIndex = 2);
        break;
      case 3:
        Navigator.pushNamed(context, '/tickets');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
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
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D2B4E), Color(0xFF0A1A2B)],
            stops: [0.0, 0.28, 0.58],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error!,
                                    style: const TextStyle(
                                        color: Colors.white)),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _loadDestinations,
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  label: const Text('Tap to retry',
                                      style:
                                          TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _loadDestinations();
                            },
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.only(bottom: 100),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildHeroText(),
                                  const SizedBox(height: 14),
                                  _buildSectionTitle(
                                      'Our Destination'),
                                  const SizedBox(height: 8),
                                  _buildCategoryChips(),
                                  const SizedBox(height: 8),
                                  _buildSortChips(),
                                  const SizedBox(height: 12),
                                  _buildCards(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        icons: _navIcons,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (_profileLoading)
            const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2)
          else
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kAccent, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null,
                    child: _profileImageBytes == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${_userProfile?['name']?.split(' ').first ?? 'User'}',
                      style: const TextStyle(
                        color: kAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'Explore Banyuwangi',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(height: 1.25),
          children: [
            const TextSpan(
              text: 'Discover the\n',
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  color: Colors.white),
            ),
            const TextSpan(
              text: 'Beauty of ',
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
            TextSpan(
              text: 'Banyuwangi',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [kAccent, Color(0xFF1976D2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(
                    const Rect.fromLTWH(0, 0, 220, 50),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title,
          style: const TextStyle(
              color: kAccent,
              fontSize: 16,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [kAccent, Color(0xFFFF8F00)],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? kAccent
                      : Colors.white.withOpacity(0.12),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kAccent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categoryIcon(cat),
                    size: 16,
                    color: isSelected ? Colors.white70 : Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'alam':
        return Icons.forest;
      case 'budaya':
        return Icons.museum;
      case 'pantai':
      case 'beach':
        return Icons.waves;
      case 'gunung':
      case 'mountain':
        return Icons.terrain;
      case 'kuliner':
      case 'food':
        return Icons.restaurant;
      case 'belanja':
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.explore;
    }
  }

  Widget _buildSortChips() {
    final entries = [
      (SortOption.newest, Icons.new_releases_outlined, 'Newest'),
      (SortOption.oldest, Icons.history, 'Oldest'),
      (SortOption.priceLow, Icons.trending_down, 'Lowest Price'),
      (SortOption.priceHigh, Icons.trending_up, 'Highest Price'),
      (SortOption.locationAz, Icons.location_on_outlined, 'Location'),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (option, icon, label) = entries[i];
          final isSelected = option == _sortOption;
          return GestureDetector(
            onTap: () => setState(() => _sortOption = option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? kAccent.withOpacity(0.6)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 14,
                      color: isSelected ? kAccent : Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCards() {
    final filtered = _filteredDestinations;
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('No destinations available',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return SizedBox(
      height: 380,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 8),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final d = filtered[i];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 200,
              child: DestinationCard(
                destination: d,
                onAddToCart: () => _showPaxDialog(d),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    const double barH = 64;
    const double bubbleD = 52;
    const double peekH = 22;
    const double totalH = barH + peekH;

    final int count = icons.length;
    final double screenW = MediaQuery.of(context).size.width;
    final double slotW = screenW / count;
    final double bubbleLeft =
        slotW * selectedIndex + (slotW - bubbleD) / 2;

    return SizedBox(
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barH,
              decoration: BoxDecoration(
                color: const Color(0xFF1B3464),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: barH,
              child: Row(
                children: List.generate(count, (i) {
                  if (i == selectedIndex) {
                    return SizedBox(width: slotW);
                  }
                  return InkWell(
                    onTap: () {
                      onTap(i);
                    },
                    child: SizedBox(
                      width: slotW,
                      height: barH,
                      child: Center(
                        child: Icon(icons[i],
                            color: Colors.white.withOpacity(0.48),
                            size: 25),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 270),
            curve: Curves.easeInOut,
            left: bubbleLeft,
            top: (peekH + barH / 2) - bubbleD / 2,
            child: Container(
              width: bubbleD,
              height: bubbleD,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [kAccent, Color(0xFFFF8F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withOpacity(0.55),
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child:
                  Icon(icons[selectedIndex], color: Colors.white, size: 27),
            ),
          ),
        ],
      ),
    );
  }
}
