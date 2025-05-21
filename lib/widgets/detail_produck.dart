import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPanel extends StatelessWidget {
  final Map product;
final VoidCallback onClose;

  DetailPanel({
  required this.product,
  required this.onClose,
});

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      width: 500,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween, // supaya teks dan ikon di ujung kanan kiri
            children: [
              const Text(
                'Detail menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(
                image: NetworkImage(product['link_foto']),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product['nama_produk'] ?? '-',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                formatRupiah.format(product['harga'] ?? 0),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Stock : ${product['stok'] ?? '-'}"),
          const SizedBox(height: 20),
          Text(product['deskripsi'] ?? 'Tidak ada deskripsi'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 1,
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
