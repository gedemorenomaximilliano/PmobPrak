import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/api_service.dart';

class RatingDialog extends StatefulWidget {
  final int itemId;
  final Function() onSubmitted;
  const RatingDialog({super.key, required this.itemId, required this.onSubmitted});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 3.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRating() async {
    setState(() => _isLoading = true);
    try {
      await apiService.submitRating(widget.itemId, _rating.toInt(), _commentController.text);
      if (!mounted) return;
      widget.onSubmitted();
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D2B4E),
      title: const Text('Rate Destination', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) => setState(() => _rating = rating),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Leave a comment', hintStyle: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
        _isLoading ? const CircularProgressIndicator() : TextButton(onPressed: _submitRating, child: const Text('Submit', style: TextStyle(color: Colors.white))),
      ],
    );
  }
}
