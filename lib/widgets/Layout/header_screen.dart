import 'dart:ui';
import 'package:cookie_jar/models/cookies.dart';
import 'package:cookie_jar/screens/homepage_screen.dart';
import 'package:cookie_jar/screens/login_regis/login_screen.dart';
import 'package:cookie_jar/screens/login_regis/registrasi_screen.dart';
import 'package:cookie_jar/services/supabase_widget.dart'; // Asumsi SupabaseService ada di sini
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

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
            .textSearch(
              'nama_produk',
              query,
              config: 'english',
            ); // Sesuaikan kolom dan config
        if (response is List) {
          results = response.map((item) => Cookies.fromJson(item)).toList();
        }
      }
      widget.onSearchResults?.call(results);
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pencarian gagal: $e')));
      }
    } finally {
      if (mounted) {
        // Tambahkan pengecekan mounted di sini juga
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
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        break;
      case 'register':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegistrasiScreen()),
        );
        break;
      case 'logout':
        try {
          await supabase.auth.signOut();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);
          await prefs.remove('role'); // Hapus role juga

          // Pastikan context masih valid sebelum navigasi jika ada operasi async sebelumnya
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomepageScreen(),
              ), // Navigasi ke LoginScreen
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
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
                child: Icon(Icons.cookie, color: Colors.white, size: 20),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
              child: Icon(Icons.person, color: Colors.white),
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
