import 'dart:io';
import 'package:http/http.dart' as http;

class S3Services {
  Future<void> uploadToS3(File file) async {
    final url = Uri.parse(
      'https://webcookiejar5a099-dev.s3.amazonaws.com/product/test123.jpg',
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'image/jpeg', // atau sesuai tipe file kamu
      },
      body: await file.readAsBytes(),
    );

    if (response.statusCode == 200) {
      print('✅ Upload berhasil!');
    } else {
      print('❌ Upload gagal: ${response.statusCode}');
    }
  }
}
