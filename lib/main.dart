import 'package:cookie_jar/database/auth.dart';
import 'package:cookie_jar/database/get_data.dart';
import 'package:cookie_jar/login/login.dart';
import 'package:cookie_jar/screens/homescreen.dart';
// import 'package:cookie_jar/database/simpan.dart';
// import 'package:cookie_jar/view/homepage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://namsmqlsgletflprfurx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hbXNtcWxzZ2xldGZscHJmdXJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1OTY0OTgsImV4cCI6MjA2MjE3MjQ5OH0.2HUS3jzQgs8T5IuOEpzHqSfS4_2nnYyTxrAGpE86nBI',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginPage(),
    );
  }
}
