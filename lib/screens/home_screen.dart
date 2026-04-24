import 'package:flutter/material.dart';
import 'aboutDestination.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  List<dynamic> _destinations = [];
  List<dynamic> _popularDestinations = [];
  bool _isLoading = true;
  String? _error;

  static const _navIcons = [
    Icons.search_rounded,
    Icons.shopping_cart_outlined,
    Icons.home_outlined,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      final destinations = await apiService.getDestinations();
      final popular = await apiService.getPopularDestinations();
      setState(() {
        _destinations = destinations;
        _popularDestinations = popular;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
        Navigator.pushNamed(context, '/favorites');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  // FIXED: Safe price formatter for the list
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
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.white)))
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeroText(),
                                const SizedBox(height: 28),
                                _buildSectionTitle('Best Destination'),
                                const SizedBox(height: 14),
                                _buildCards(),
                                const SizedBox(height: 28),
                                _buildSectionTitle('New Tours'),
                                const SizedBox(height: 14),
                                _buildList(),
                                const SizedBox(height: 24),
                              ],
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
          FutureBuilder<Map<String, dynamic>>(
            future: apiService.getUserProfile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(color: Colors.white, strokeWidth: 2);
              }
              final user = snapshot.data!;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    backgroundImage: user['image'] != null
                        ? NetworkImage(user['image'])
                        : null,
                    child: user['image'] == null
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user['name'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
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
        text: const TextSpan(
          style: TextStyle(height: 1.25),
          children: [
            TextSpan(
              text: 'Discover the\n',
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  color: Colors.white),
            ),
            TextSpan(
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
                  color: Color(0xFF42A5F5)),
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
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildCards() {
    if (_popularDestinations.isEmpty) {
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
        itemCount: _popularDestinations.length,
        itemBuilder: (_, i) =>
            DestinationCard(destination: _popularDestinations[i]),
      ),
    );
  }

  // FIXED: The popular tours list
  Widget _buildList() {
    if (_destinations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child:
            Text('No tours available', style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _destinations.length,
      itemBuilder: (_, i) {
        final d = _destinations[i];

        // FIXED: Use the safe formatter for price
        final price = _formatPrice(d['harga']);
        final rating = d['rating']?.toString() ?? '0.0';
        final reviews = d['review'] ?? 0;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DestinationDetailScreen(destination: d)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B3E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF2C3E50).withOpacity(0.3),
                    child: const Center(
                      child: Icon(Icons.landscape,
                          color: Colors.white54, size: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['nama_destination'] ?? 'Unknown',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFA000), size: 13),
                          const SizedBox(width: 4),
                          Text('$rating  •  $price',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                          d['deskripsi'] == 'null' || d['deskripsi'] == null
                              ? 'No description available'
                              : d['deskripsi'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white38, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Bottom navigation bar
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
    final double bubbleLeft = slotW * selectedIndex + (slotW - bubbleD) / 2;

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
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
                  if (i == selectedIndex) return SizedBox(width: slotW);
                  return GestureDetector(
                    onTap: () {
                      onTap(i);
                      // Force rebuild to update gradient position
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: slotW,
                      height: barH,
                      child: Center(
                        child: Icon(icons[i],
                            color: Colors.white.withOpacity(0.48), size: 25),
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
            top: 0,
            child: Container(
              width: bubbleD,
              height: bubbleD,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFADD8F7), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withOpacity(0.55),
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icons[selectedIndex], color: Colors.white, size: 27),
            ),
          ),
        ],
      ),
    );
  }
}
