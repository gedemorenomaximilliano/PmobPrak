import 'package:flutter/material.dart';
import 'aboutDestination.dart'; // Pastikan nama file ini benar di folder kamu

class ExplorePlacesScreen extends StatelessWidget {
  const ExplorePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Background Gradien Asli Bima
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F7FA), // Biru muda di atas
                  Color(0xFF1E3A5F), // Biru dibawah
                ],
              ),
            ),
          ),
          // 2. Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Header (Sekarang ada parameter context buat Back Button)
                  _buildHeader(context),

                  const SizedBox(height: 20),

                  // Judul Utama dengan Bayangan
                  const Text(
                    'Explore Places',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Bagian Tempat Tanggal 1 (GRID 2x2)
                  _buildPlaceSection(
                    context,
                    'Available 25 Feb 2026',
                    _buildDate1Places(),
                  ),

                  const SizedBox(height: 25),

                  // Bagian Tempat Tanggal 2 (ROW)
                  _buildPlaceSection(
                    context,
                    'Available 26 Feb 2026',
                    _buildDate2Places(),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header (Ada Tombol Back + Profil Indah)
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // TOMBOL BACK BIAR BISA BALIK KE GEDE
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A5F)),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 5),

        // Widget Profil Kustom Bima
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: const Center(
                      child: Icon(Icons.person, color: Color(0xFFFFD54F), size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Text('Indah', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.menu, color: Colors.black, size: 28),
      ],
    );
  }

  Widget _buildPlaceSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        content,
      ],
    );
  }

  // Grid Kartu Tanggal 1 (2x2 - Total 4 Kartu)
  Widget _buildDate1Places() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.75,
      children: const [
        CustomPlaceCard(
          imageUrl: 'assets/images/acidicLake.jpg',
          name: 'Kawah Ijen',
          location: 'Desa Tamansari, Banyuwangi',
          rating: 4.9,
          reviews: 455,
        ),
        CustomPlaceCard(
          imageUrl: 'assets/images/baluran.jpg',
          name: 'Baluran',
          location: 'Situbondo, Jawa Timur',
          rating: 4.9,
          reviews: 455,
        ),
        CustomPlaceCard(
          imageUrl: 'assets/images/baluran.jpg', // Ganti aset gambarnya nanti Bim
          name: 'Green Island',
          location: 'Dusun Pancer, Banyuwangi',
          rating: 4.9,
          reviews: 455,
        ),
        CustomPlaceCard(
          imageUrl: 'assets/images/baluran.jpg',
          name: 'Pulau Tabuhan',
          location: 'Desa Bangsring, Banyuwangi',
          rating: 4.9,
          reviews: 455,
        ),
      ],
    );
  }

  // Row Kartu Tanggal 2 (Baris Horizontal - 2 Kartu)
  Widget _buildDate2Places() {
    return Row(
      children: const [
        Expanded(
          child: CustomPlaceCard(
            imageUrl: 'assets/images/de-djawatan.jp.jpg',
            name: 'De-Djawatan',
            location: 'Purwosari, Banyuwangi',
            rating: 4.9,
            reviews: 455,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: CustomPlaceCard(
            imageUrl: 'assets/images/baluran.jpg',
            name: 'Kawah Ijen 2',
            location: 'Desa Tamansari, Banyuwangi',
            rating: 4.9,
            reviews: 455,
          ),
        ),
      ],
    );
  }
}

// WIDGET KARTU - SUDAH ADA NAVIGASI & VARIABEL LENGKAP
class CustomPlaceCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final int reviews;

  const CustomPlaceCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // NAVIGASI KE DETAIL
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KawahIjenApp()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                  const SizedBox(height: 2),
                  Text(location, style: TextStyle(fontSize: 9, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                      const SizedBox(width: 4),
                      Text('($reviews)', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}