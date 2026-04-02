import 'package:flutter/material.dart';

void main() {
  runApp(const KawahIjenApp());
}

class KawahIjenApp extends StatelessWidget {
  const KawahIjenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kawah Ijen Detail',
      theme: ThemeData(
        fontFamily: 'Material Design Icons', // Menggunakan font default untuk Material Design
      ),
      home: const KawahIjenDetailScreen(),
    );
  }
}

class KawahIjenDetailScreen extends StatelessWidget {
  const KawahIjenDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna kustom dari desain
    const Color darkBlue = Color(0xFF1E3A5F);
    const Color buttonBlue = Color(0xFF4C84B9);

    // Variabel data palsu (palsu untuk replikasi)
    final String destinationTitle = "Kawah Ijen";
    final String locationText = "Banyuwangi, Jawa Timur";
    final String priceText = "IDR 500K/pax";
    final String ratingScore = "4,9";
    final String reviewCount = "(455 Review)";
    final String aboutTitle = "About Destination";
    final String aboutParagraph =
        "Ijen Crater is a majestic volcanic wonder famous for its turquoise acidic lake and the rare, electric-blue fire. As a highlight of \"The Sunrise of Java,\" it offers a breathtaking trekking experience and stunning sunrise views that define";
    final String readMoreText = "Read More";
    final String buttonText = "See Initerary"; // Teks persis seperti gambar

    // Placeholder image path (anda perlu mengganti ini dengan aset anda nanti)
    final String backgroundImage = 'assets/images/baluran.jpg'; // Contoh URL
    final List<String> galleryImages = [
      'https://via.placeholder.com/150x150.png?text=Kawah+Danau', // Contoh URL
      'https://via.placeholder.com/150x150.png?text=Api+Biru', // Contoh URL
      'https://via.placeholder.com/150x150.png?text=Matahari+Terbit', // Contoh URL
      'https://via.placeholder.com/150x150.png?text=Kawah+Asap', // Contoh URL
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // Untuk menyembunyikan status bar dan menampilkan latar belakang
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: null, // Menghapus tombol back default
      ),
      body: Stack(
        children: [
          // 1. Gambar Latar Belakang Layar Penuh
          Positioned.fill(
            child: ClipRRect(
              child: Image.asset(
                backgroundImage, // Ganti dengan Image.asset('assets/gambar_latar.png')
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Panel Konten Putih Melengkung
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65, // Menutupi sekitar 65% layar bawah
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40.0), // Sudut melengkung atas
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sudut kecil melengkung di panel putih (mirip gambar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bagian Judul dan Hati
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destinationTitle,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            locationText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.favorite_border, color: Colors.grey, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bagian Harga
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bagian Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        ratingScore,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reviewCount,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bagian Galeri Thumbnail
                  Row(
                    children: [
                      _buildGalleryThumbnail(galleryImages[0]),
                      const SizedBox(width: 12),
                      _buildGalleryThumbnail(galleryImages[1]),
                      const SizedBox(width: 12),
                      _buildGalleryThumbnail(galleryImages[2]),
                      const SizedBox(width: 12),
                      _buildGalleryThumbnail(galleryImages[3]),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bagian 'About Destination'
                  Text(
                    aboutTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Paragraf 'About Destination'
                  RichText(
                    text: TextSpan(
                      text: aboutParagraph,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' $readMoreText',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),

                  // Bagian Tombol 'See Initerary'
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Tambahkan aksi tombol
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBlue, // Warna tombol kustom
                          foregroundColor: Colors.white, // Warna teks putih
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk membangun thumbnail galeri
  Widget _buildGalleryThumbnail(String imageUrl) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1, // Persegi
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // Melengkung internal sedikit lebih kecil
            child: Image.network(
              imageUrl,// Ganti dengan Image.asset('assets/gambar_thumbnail.png')
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}