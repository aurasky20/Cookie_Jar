import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPanel extends StatelessWidget {
  final Map product;
  final VoidCallback onClose;
  double height;

  DetailPanel({
    required this.product,
    required this.onClose,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'IDR ',
      decimalDigits: 0,
    );

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xffFFF8E1), // Light cream background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff5D4037),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Yuk cek detail menunya!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff8D6E63),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xffFFAB40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                          product['link_foto'] != null
                              ? Image.network(
                                product['link_foto'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product Name and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['nama_produk'] ?? 'Nama Produk',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff5D4037),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cookies',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xffA1887F),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                      Text(
                        formatRupiah.format(product['harga'] ?? 0),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff5D4037),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stock Information
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFE0B2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stok : ${product['stok'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff5D4037),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff5D4037),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['deskripsi'] ?? 'Tidak ada deskripsi tersedia.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xffA1887F),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 20),

                  // Composition if available
                  if (product['komposisi'] != null &&
                      product['komposisi'].toString().isNotEmpty) ...[
                    const Text(
                      'Komposisi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff5D4037),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product['komposisi'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xffA1887F),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Checkout Button - Fixed at bottom
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add checkout functionality here
                  print('Checkout pressed for ${product['nama_produk']}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF8A50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Check Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
