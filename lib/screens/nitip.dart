import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final supabase = Supabase.instance.client;
  List data = [];

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: data.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 40,
                  crossAxisSpacing: 40,
                  // childAspectRatio: 4 / 4,
                ),
                itemBuilder: (context, index) {
                  final e = data[index]; // ✅ definisikan variabel e
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(
                      //   height: 250,
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey,
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      // ),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(
                              e['link_foto'] ?? '', // Gunakan URL dari Supabase
                            ), // Gunakan URL dari Supabase
                            fit:BoxFit.cover, // Atur agar gambar mengisi seluruh container
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(e['nama_produk'] ?? 'Tanpa Nama'),
                      const SizedBox(height: 20),
                      Text(formatRupiah.format(e['harga'] ?? 0)),
                    ],
                  );
                },
              ),
            ),

            // Panel Form Tambah
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(130),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 500,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah menu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 260,
                  ),
                  const SizedBox(height: 20),
                  const Text('Nama Kue Kering'),
                  const SizedBox(height: 10),
                  const TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Stok'),
                            SizedBox(height: 10),
                            TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Harga'),
                            SizedBox(height: 10),
                            TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Deskripsi'),
                  const SizedBox(height: 10),
                  const TextField(
                    maxLines: 7,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(child: Text('Submit')),
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
