import 'dart:ui';

import 'package:cookie_jar/login/login.dart';
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffD5DEDD), Color(0xffEEEFDA)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return Column(
                    children: [
                      Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Colors.white.withOpacity(.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1000),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    "Cookie jar",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Material(
                                  borderRadius: BorderRadius.circular(100000),
                                  clipBehavior: Clip.hardEdge,
                                  child: InkWell(
                                    // focusColor: Colors.blue.withOpacity(0.6),
                                    hoverColor: Colors.blue.withOpacity(0.6),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          1000,
                                        ),
                                        border: Border.all(),
                                        color: Colors.blue.withOpacity(0.1),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Login Admin",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(Icons.login),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: constraints.maxHeight - 69,
                              child: _buildGridView(),
                            ),
                          ),
                          if (selectedProduct != null)
                            SizedBox(
                              width: 500,
                              height: constraints.maxHeight - 69,
                              child: DetailPanel(
                                height: constraints.maxHeight - 69,
                                product: selectedProduct!,
                                onClose: () {
                                  setState(() {
                                    selectedProduct = null;
                                  });
                                },
                              ),
                            ),
                        ],
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
                                          MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        opacity: showDetail ? 1.0 : 0.0,
                                        child: AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          scale: showDetail ? 1.0 : 0.9,
                                          child: DetailPanel(
                                            height: constraints.maxHeight - 69,
                                            product: selectedProduct!,
                                            onClose: () async {
                                              setState(() {
                                                showDetail = false;
                                              });
                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
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
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return LayoutBuilder(
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
          child: SingleChildScrollView(
            // physics: NeverScrollableScrollPhysics(),
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
                      child: Stack(
                        children: [
                          Container(
                            width: itemWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white.withOpacity(0.6),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          e['link_foto'] ?? '',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    e['nama_produk'] ?? 'Tanpa Nama',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(formatRupiah.format(e['harga'] ?? 0)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
