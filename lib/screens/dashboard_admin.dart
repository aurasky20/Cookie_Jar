import 'package:cookie_jar/login/login.dart';
import 'package:cookie_jar/widgets/card_data_insight.dart';
import 'package:cookie_jar/widgets/create_product.dart';
import 'package:cookie_jar/widgets/detail_produck.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final supabase = Supabase.instance.client;
  List data = [];
  Map? selectedProduct;
  bool showDetail = false;
  String role = 'Admin'; // Role di-set ke Admin

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final response = await supabase.from('produk').select('*');
    setState(() {
      data = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daftar Kue Kering'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
  builder: (context, constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari di sini...',
                      hintStyle: GoogleFonts.dmSans(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              if (role == 'Admin')
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const SubmitForm(),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Tambah Produk',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: cardDataInsight(
                        title: 'Jumlah Produk',
                        amount: data.length,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: cardDataInsight(
                        title: 'Jumlah Pengguna',
                        amount: 100, // Ganti jika bisa dinamis
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                SizedBox(
                  height: constraints.maxHeight * 0.6,
                  child: _buildGridView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
),

    );
  }

  Widget _buildGridView() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      int itemsPerRow = (screenWidth / 250).floor();
      itemsPerRow = itemsPerRow < 1 ? 1 : itemsPerRow;

      double spacing = 20;
      double itemWidth = (screenWidth - ((itemsPerRow + 1) * spacing)) / itemsPerRow;

      return GridView.builder(
        padding: EdgeInsets.all(spacing),
        itemCount: data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemsPerRow,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final e = data[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedProduct = e;
                showDetail = true;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: (e['link_foto'] != null &&
                              e['link_foto'].toString().startsWith('http'))
                          ? NetworkImage(e['link_foto'])
                          : const AssetImage('assets/no_image.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(e['nama_produk'] ?? 'Tanpa Nama'),
                const SizedBox(height: 5),
                Text(formatRupiah.format(e['harga'] ?? 0)),
              ],
            ),
          );
        },
      );
    },
  );
}

}
