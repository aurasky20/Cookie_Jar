import 'package:cookie_jar/database/simpan.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Container(
        child: Column(
          children: [
            TextField(
              controller: username,
              decoration: const InputDecoration(hintText: 'Username'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            TextField(
              controller: password,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () {
                Data();
              },
              child: const Text('Sumbit'),
            ),
          ],
        ),
      ),
    );
  }
}
