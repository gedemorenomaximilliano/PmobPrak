import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class ItineraryScreen extends StatefulWidget {
  final String destinationName;
  final int destinationId;
  final List<Map<String, dynamic>>? itineraryItems;
  final String? rawItineraryText;

  const ItineraryScreen({
    super.key,
    required this.destinationName,
    required this.destinationId,
    this.itineraryItems,
    this.rawItineraryText,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  List<Map<String, dynamic>>? _items;
  String? _rawFallback;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.itineraryItems != null && widget.itineraryItems!.isNotEmpty) {
      setState(() {
        _items = widget.itineraryItems;
        _rawFallback = widget.rawItineraryText;
        _loading = false;
      });
      return;
    }

    if (widget.rawItineraryText != null && widget.rawItineraryText!.isNotEmpty) {
      setState(() {
        _rawFallback = widget.rawItineraryText;
        _loading = false;
      });
      return;
    }

    try {
      final data = await apiService.getDestinationById(widget.destinationId);
      if (!mounted) return;
      final structured = data['itinerary_items'] as List?;
      if (structured != null && structured.isNotEmpty) {
        setState(() {
          _items = structured.cast<Map<String, dynamic>>();
          _rawFallback = data['itinerary']?.toString();
          _loading = false;
        });
      } else {
        final raw = data['itinerary']?.toString();
        if (raw != null && raw.isNotEmpty) {
          setState(() { _rawFallback = raw; _loading = false; });
        } else {
          setState(() { _items = []; _loading = false; });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.destinationName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), kNavyDark, Color(0xFF0A1A2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_items != null && _items!.isNotEmpty) return _buildStructured();
    if (_rawFallback != null && _rawFallback!.isNotEmpty) return _buildRawFallback();
    return _buildEmpty();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(3, (i) => _shimmerCard(i)),
        ],
      ),
    );
  }

  Widget _shimmerCard(int index) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 12,
        top: index == 0 ? 20 : 0,
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 60,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed to load itinerary',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _init();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.route, color: Colors.white24, size: 64),
        ),
        const SizedBox(height: 20),
        const Text(
          'No itinerary available',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check back later for schedule updates',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ]),
    );
  }

  static const _accent = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFF8F00),
    Color(0xFFE53935),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
  ];

  Widget _buildStructured() {
    final items = _items!;
    return Column(
      children: [
        _buildHeader(items.length),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = items[i];
              final time = item['time']?.toString() ?? '';
              final activity = item['activity']?.toString() ?? '';
              final c = _accent[i % _accent.length];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    border: Border(
                      left: BorderSide(color: c, width: 4),
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (time.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: c.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Text(
                          activity,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.schedule, color: Colors.amber, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity Timeline',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count ${count == 1 ? 'activity' : 'activities'} planned',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildRawFallback() {
    final lines = _rawFallback!.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Column(
      children: [
        _buildHeader(lines.length),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final line = lines[i].trim();
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    border: Border(
                      left: BorderSide(
                        color: _accent[i % _accent.length],
                        width: 4,
                      ),
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
