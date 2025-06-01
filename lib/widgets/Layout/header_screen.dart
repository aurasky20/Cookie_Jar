import 'dart:ui';
import 'package:cookie_jar/models/cookies.dart';
import 'package:cookie_jar/services/supabase_widget.dart'; // Asumsi SupabaseService ada di sini
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

// Asumsikan path ini benar, sesuaikan jika perlu
import 'package:cookie_jar/login/login.dart'; 
import 'package:cookie_jar/login/regis.dart';

class HeaderWidget extends StatefulWidget {
  final Function(List<Cookies>)? onSearchResults;

  const HeaderWidget({super.key, this.onSearchResults});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  // Mendapatkan instance Supabase client
  final supabase = Supabase.instance.client;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      widget.onSearchResults?.call([]);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // final results = await SupabaseService.searchCookies(query); // Baris asli
      // Ganti dengan implementasi searchCookies Anda jika SupabaseService tidak ada atau berbeda
      // Contoh placeholder jika SupabaseService.searchCookies tidak tersedia:
      List<Cookies> results = [];
      if (query.isNotEmpty) {
        // Simulasi pencarian, ganti dengan logika Supabase Anda
        final response = await supabase
            .from('produk') // Asumsi tabel produk
            .select()
            .textSearch('nama_produk', query, config: 'english'); // Sesuaikan kolom dan config
        if (response is List) {
            results = response.map((item) => Cookies.fromJson(item)).toList();
        }
      }
      widget.onSearchResults?.call(results);
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pencarian gagal: $e')),
        );
      }
    } finally {
      if (mounted) { // Tambahkan pengecekan mounted di sini juga
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'login':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
        break;
      case 'register':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RegisPage()));
        break;
      case 'logout':
        try {
          await supabase.auth.signOut();
          // Pastikan untuk mengarahkan pengguna dan membersihkan state jika perlu
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false, // Hapus semua rute sebelumnya
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout gagal: $e')),
            );
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan pengguna saat ini untuk menentukan item menu
    final currentUser = supabase.auth.currentUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFF795548), // Warna coklat tua
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cookie,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "COOKIE JAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Search Bar
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _searchController,
                onSubmitted: _performSearch,
                style: TextStyle(color: Colors.black87), // Warna teks input
                decoration: InputDecoration(
                  hintText: "Ingin cari kue kering apa hari ini?",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: _isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12.0), // Disesuaikan paddingnya
                          child: SizedBox(
                            width: 16, // Ukuran disesuaikan agar pas
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0), // Disesuaikan paddingnya
                          child: Icon(Icons.search, color: Colors.grey[600]),
                        ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchResults?.call([]);
                            setState(() {}); // Update UI untuk menghilangkan clear button
                          },
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20, // Disesuaikan paddingnya
                    vertical: 12,   // Disesuaikan paddingnya
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // Update UI for clear button visibility
                  if (value.isEmpty) {
                    widget.onSearchResults?.call([]);
                  }
                  // Pertimbangkan untuk menambahkan debounce jika pencarian dilakukan secara live
                },
              ),
            ),
          ),

          // User Icon with PopupMenuButton
          PopupMenuButton<String>(
            offset: const Offset(0, 50), // Posisi popup di bawah avatar
            onSelected: (value) => _handleMenuSelection(value, context),
            tooltip: "Menu Pengguna",
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> menuItems = [];
              if (currentUser != null) {
                // Pengguna sudah login
                menuItems.add(
                  PopupMenuItem<String>(
                    enabled: false, // Tidak bisa diklik
                    child: Text(
                      currentUser.email ?? 'Pengguna Terautentikasi',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                );
                menuItems.add(const PopupMenuDivider());
                menuItems.add(
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black54, size: 20),
                        SizedBox(width: 8),
                        Text('Keluar'),
                      ],
                    ),
                  ),
                );
              } else {
                // Pengguna belum login (Guest)
                menuItems.add(
                  const PopupMenuItem<String>(
                    enabled: false, // Tidak bisa diklik
                    child: Text(
                      'Guest',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                );
                menuItems.add(const PopupMenuDivider());
                menuItems.add(
                  const PopupMenuItem<String>(
                    value: 'login',
                    child: Row(
                      children: [
                        Icon(Icons.login, color: Colors.black54, size: 20),
                        SizedBox(width: 8),
                        Text('Masuk'),
                      ],
                    ),
                  ),
                );
                menuItems.add(
                  const PopupMenuItem<String>(
                    value: 'register',
                    child: Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.black54, size: 20),
                        SizedBox(width: 8),
                        Text('Registrasi'),
                      ],
                    ),
                  ),
                );
              }
              return menuItems;
            },
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
