import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../constants/colors.dart';
import '../widgets/gradient_button.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: ListenableBuilder(
          listenable: cartService,
          builder: (context, child) {
            if (cartService.items.isEmpty) {
              return const Center(child: Text('Your cart is empty', style: TextStyle(color: Colors.white70)));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 100, bottom: 20),
                    itemCount: cartService.items.length,
                    itemBuilder: (context, index) {
                      final item = cartService.items[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: (item['gambar'] != null && item['gambar'].toString().startsWith('data:image'))
                                  ? Image.memory(apiService.base64ToBytes(item['gambar'].toString().split(',').last), fit: BoxFit.cover)
                                  : Container(color: Colors.white24, child: const Icon(Icons.landscape, color: Colors.white54)),
                            ),
                          ),
                          title: Text(item['nama_destination'] ?? 'Item', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text('Rp ${item['harga']} (Pax: ${item['pax']})', style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => cartService.removeFromCart(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Rp ${cartService.totalPrice}', style: const TextStyle(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GradientButton('Checkout All', () {
                        if (cartService.items.isNotEmpty) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(destination: cartService.items.first)));
                        }
                      }),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
