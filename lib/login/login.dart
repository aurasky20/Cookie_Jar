import 'package:cookie_jar/screens/dashboard_admin.dart';
import 'package:flutter/material.dart';
import 'package:cookie_jar/screens/homescreen.dart';
import 'package:cookie_jar/login/regis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ganti dengan widget gambar background Anda
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
                  // Kiri: Card Oranye
                  Expanded(
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
                  // Kanan: Form Login
                  Expanded(
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
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                borderRadius: BorderRadius.circular(15),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: passwordController,
                                    obscureText: obscure,
                                    style: TextStyle(),
                                    decoration: InputDecoration(
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
                                  icon:
                                      obscure
                                          ? Icon(Icons.visibility)
                                          : Icon(Icons.visibility_off),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: const SizedBox()),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6A1A),
                                foregroundColor: Colors.white,
                                overlayColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () async {
                                final email = emailController.text.trim();
                                final password = passwordController.text;

                                final prefs =
                                    await SharedPreferences.getInstance();
                                final response = await Supabase
                                    .instance
                                    .client
                                    .auth
                                    .signInWithPassword(
                                      email: email,
                                      password: password,
                                    );

                                if (response.session != null) {
                                  // print('Login berhasil');
                                  await prefs.setBool('isLoggedIn', true);
                                  await prefs.setString('role', 'admin');

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const DashboardAdmin(),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('login gagal'),
                                          content: Text(
                                            'email atau password salah',
                                          ),
                                        ),
                                  );
                                }
                                // if (email == 'admin@admin.com' &&
                                //     password == 'admin123') {}
                                // else {
                                // await prefs.setBool('isLoggedIn', true);
                                // await prefs.setString('role', 'user');

                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const Homepage(),
                                //   ),
                                // );
                                // }
                              },
                              child: const Text(
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
                                      builder: (context) => const RegisPage(),
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
