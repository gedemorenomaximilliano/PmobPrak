import 'package:flutter/foundation.dart';

class CartService extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void addToCart(Map<String, dynamic> item) {
    _items.add(item);
    notifyListeners();
  }

  void removeFromCart(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      final price = double.tryParse(item['harga'].toString()) ?? 0;
      final pax = (item['pax'] is int) ? (item['pax'] as int) : 1;
      total += price * pax;
    }
    return total;
  }
}

final cartService = CartService();
