import 'package:cookie_jar/screens/dashboard_admin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/screens/homescreen.dart';
import 'package:cookie_jar/login/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://namsmqlsgletflprfurx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hbXNtcWxzZ2xldGZscHJmdXJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1OTY0OTgsImV4cCI6MjA2MjE3MjQ5OH0.2HUS3jzQgs8T5IuOEpzHqSfS4_2nnYyTxrAGpE86nBI',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role') ?? 'user';

    if (isLoggedIn) {
      if (role == 'admin') {
        return const DashboardAdmin();
      } else {
        return const Homepage();
      }
    } else {
      return Homepage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookie Jar',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: getStartPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data as Widget;
          }
        },
      ),
    );
  }
}
