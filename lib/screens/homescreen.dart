import 'package:cookie_jar/widgets/create_product.dart';
import 'package:cookie_jar/widgets/detail_produck.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  final String role;

  const Homepage({super.key, this.role = 'Pembeli'});

  @override
  State<Homepage> createState() => _HomepageState();
}


class _HomepageState extends State<Homepage> {
  final supabase = Supabase.instance.client;
  List data = [];
  Map? selectedProduct;
  bool showDetail = false;
  String role = 'Pembeli';

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    role = widget.role;
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
          if (role == 'Admin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const SubmitForm(),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Jika layar lebar (misalnya desktop), gunakan Row
            if (constraints.maxWidth > 1000) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildGridView()),
                  if (role != 'Admin' && selectedProduct != null)
                    SizedBox(
                      width: 500,
                      child: DetailPanel(
                        product: selectedProduct!,
                        onClose: () {
                          setState(() {
                            selectedProduct = null;
                          });
                        },
                      ),
                    ),
                ],
              );
            } else {
              // Jika layar sempit (misalnya mobile/tablet), tampilkan GridView + Detail di bawahnya
              return Stack(
                children: [
                  SingleChildScrollView(child: _buildGridView()),
                  if (role != 'Admin' && selectedProduct != null)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedProduct = null;
                          });
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap:
                                    () {}, // mencegah menutup saat klik isi detail
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: showDetail ? 1.0 : 0.0,
                                    child: AnimatedScale(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      scale: showDetail ? 1.0 : 0.9,
                                      child: DetailPanel(
                                        product: selectedProduct!,
                                        onClose: () async {
                                          setState(() {
                                            showDetail = false;
                                          });
                                          await Future.delayed(
                                            const Duration(milliseconds: 300),
                                          );
                                          setState(() {
                                            selectedProduct = null;
                                          });
                                        },
                                      ),
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
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          int itemsPerRow =
              (screenWidth / 280).floor(); // bisa diubah sesuai kebutuhan
          itemsPerRow = itemsPerRow < 1 ? 1 : itemsPerRow;

          double spacing = 20;
          double itemWidth =
              (screenWidth - ((itemsPerRow + 1) * spacing)) / itemsPerRow;

          return Padding(
            padding: EdgeInsets.all(spacing),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children:
                  data.map((e) {
                    return GestureDetector(
                      onTap: () {
                        if (role != 'Admin') {
                          setState(() {
                            selectedProduct = e;
                            showDetail = true;
                          });
                        }
                      },
                      child: SizedBox(
                        width: itemWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(e['link_foto'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(e['nama_produk'] ?? 'Tanpa Nama'),
                            const SizedBox(height: 10),
                            Text(formatRupiah.format(e['harga'] ?? 0)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          );
        },
      ),
    );
  }
}
