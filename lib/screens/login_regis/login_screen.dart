// LoginScreen.dart
import 'package:cookie_jar/screens/admin/admin_homepage_screen.dart';
import 'package:cookie_jar/screens/homepage_screen.dart';
import 'package:cookie_jar/screens/login_regis/registrasi_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Anda masih bisa menggunakannya untuk sesi
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _supabaseClient = Supabase.instance.client;
  var obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(BuildContext context) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final AuthResponse authResponse = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (!mounted) return;

      if (authResponse.user != null) {
        final userId = authResponse.user!.id;

        // Ambil role dari tabel Users
        final profileResponse =
            await _supabaseClient
                .from('Users')
                .select('role')
                .eq('id', userId)
                .single(); // .single() akan error jika tidak ada atau lebih dari 1, pastikan RLS benar

        final userRole =
            profileResponse['role'] as String? ??
            'pembeli'; // Default ke 'pembeli'

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userId', userId);
        await prefs.setString('userRole', userRole); // Simpan role

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login berhasil!')));

        if (userRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminHomepageScreen(),
            ),
          );
        } else {
          // 'pembeli' atau role lain
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomepageScreen(),
            ), // Ganti dengan halaman pembeli Anda
          );
        }
      } else {
        // Ini jarang terjadi jika signInWithPassword tidak melempar error,
        // tapi sebagai fallback jika user null tanpa exception.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal: Pengguna tidak ditemukan.'),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI Anda tetap sama, hanya modifikasi tombol onPressed dan loading state)
    // Contoh modifikasi pada ElevatedButton:
    // child: ElevatedButton(
    //   onPressed: _isLoading ? null : () => _signIn(context),
    //   child: _isLoading
    //       ? const SizedBox(
    //           height: 20,
    //           width: 20,
    //           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
    //         )
    //       : const Text('Login'),
    //   // ... sisa style Anda
    // ),

    // ... (Sisa UI Anda yang sudah ada)
    // Ganti onPressed pada ElevatedButton Anda dari logika lama menjadi:
    // onPressed: _isLoading ? null : () => _signIn(context),
    // Dan jika _isLoading true, tampilkan CircularProgressIndicator di dalam tombol.
    // Contoh lengkap untuk tombol:
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg', // ganti sesuai path gambar Anda
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Container(
              height: 550,
              width: 900,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    /* ... Bagian Kiri ... */
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6A1A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 35,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Selamat \ndatang di \nCookie Jar',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 60,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Cookies lezat, tak kenal hambar!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    /* ... Bagian Kanan: Form Login ... */
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center, // Diubah agar form lebih ke tengah
                        children: [
                          const Text(
                            'Login Akun',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 42),
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ), // Sesuai kode Anda
                                borderSide: BorderSide(
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Kata Sandi',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                15,
                              ), // Sesuai kode Anda
                              border: Border.all(color: Colors.orangeAccent),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: passwordController,
                                    obscureText: obscure,
                                    decoration: const InputDecoration(
                                      hintText: 'Masukkan Kata Sandi',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const SizedBox(height: 60), // Anda menggunakan Expanded, jadi ini mungkin tidak perlu
                          const Spacer(), // Menggunakan Spacer untuk mendorong tombol ke bawah
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6A1A),
                                foregroundColor: Colors.white,
                                overlayColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => _signIn(context), // GANTI DI SINI
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                      : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Belum punya akun? Yuk langsung ',
                                style: TextStyle(fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Daftar!',
                                  style: TextStyle(
                                    color: Color(0xFFFF6A1A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ), // Memberi sedikit ruang di bawah
                        ],
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
}
