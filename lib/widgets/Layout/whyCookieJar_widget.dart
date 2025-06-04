import 'package:flutter/material.dart';

class WhyCookieJarWidget extends StatelessWidget {
  const WhyCookieJarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      color: Color(0xFFF5F5F5),
      child: Column(
        children: [
          Text(
            "Kenapa Harus Membeli Kue Kering Di Cookie Jar ?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureCard(
                image:
                    "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=300",
                title: "Rasa Paling Lezat",
                description:
                    "Di Cookie Jar, kami percaya bahwa setiap gigitan kue kering haruslah sebuah pengalaman istimewa. Oleh karena itu, kami hanya menggunakan bahan-bahan berkualitas premium, resep warisan yang telah teruji, dan sentuhan cinta dalam setiap adonan",
              ),
              _buildFeatureCard(
                image:
                    "https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=300",
                title: "Pengiriman Cepat",
                description:
                    "Dengan aplikasi Cookie Jar, memesan kue kering favorit kini semudah sentuhan jari. Nikmati kemudahan menjelajahi beragam pilihan, melakukan pemesanan cepat, dan memilih opsi pengiriman yang fleksibel sesuai kebutuhan Anda.",
              ),
              _buildFeatureCard(
                image:
                    "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=300",
                title: "Komunitas Pecinta Kue",
                description:
                    "Lebih dari sekadar toko kue online, Cookie Jar adalah komunitas para pecinta kue kering. Kami berkomitmen untuk memberikan pelayanan terbaik, mulai dari proses pemesanan yang mulus hingga layanan pelanggan yang responsif dan ramah.",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String image,
    required String title,
    required String description,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFD7CCC8),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
