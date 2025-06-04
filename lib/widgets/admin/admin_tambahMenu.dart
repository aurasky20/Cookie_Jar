import 'dart:io';
import 'dart:math';
import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:http/http.dart' as http;

class AdminTambahMenuWidget extends StatefulWidget {
  final double height;
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  const AdminTambahMenuWidget({
    super.key,
    required this.height,
    required this.onClose,
    required this.onSuccess,
  });

  @override
  State<AdminTambahMenuWidget> createState() => _AdminTambahMenuWidgetState();
}

class _AdminTambahMenuWidgetState extends State<AdminTambahMenuWidget> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _komposisiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  Uri? imageUrl; // Untuk menyimpan URL gambar yang diunggah

  final _picker = ImagePicker();

  String displayImageUrl = '';

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _komposisiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // upload() async {
  //   try {
  //     imageUrl = await Utils.pickAndUploadImage();
  //     if (imageUrl != null) {
  //       _showSnackBar('Gambar berhasil diunggah: $imageUrl');
  //     } else {
  //       _showSnackBar('Gagal mengunggah gambar', isError: true);
  //     }
  //     setState(() {});
  //   } catch (e) {
  //     _showSnackBar('Error: $e', isError: true);
  //   }
  // }

  // Future<String?> _uploadImage() async {
  //   if (_selectedImageFile == null && _selectedImageBytes == null) return null;
  //   if (_selectedImageName == null) return null;

  //   try {
  //     // Mendapatkan ekstensi dari nama file
  //     final fileExtension = _selectedImageName!.split('.').last;
  //     final fileName =
  //         'product_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

  //     final Uint8List imageBytes;
  //     if (kIsWeb) {
  //       imageBytes = _selectedImageBytes!;
  //     } else {
  //       imageBytes = await _selectedImageFile!.readAsBytes();
  //     }

  //     await supabase.storage
  //         .from('products')
  //         .uploadBinary(
  //           fileName,
  //           imageBytes, // Gunakan imageBytes untuk upload
  //           fileOptions: FileOptions(
  //             contentType: 'image/$fileExtension',
  //             upsert: false,
  //           ),
  //         );

  //     return supabase.storage.from('products').getPublicUrl(fileName);
  //   } catch (e) {
  //     throw Exception('Error mengunggah gambar: $e');
  //   }
  // }

  XFile? _pickedXFile; // XFile dari image_picker
  String? _uploadedUrl;
  bool _isUploading = false;

  Future<void> uploadToS3() async {
    if (_pickedXFile == null) return;

    setState(() {
      _isUploading = true;
    });

    // Buat nama file unik
    final fileName = 'flutter_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bucketUrl =
        'https://webcookiejar5a099-dev.s3.ap-southeast-2.amazonaws.com/product/$fileName';

    try {
      // Baca bytes dengan cara yang sesuai
      late final Uint8List bytes;
      if (kIsWeb) {
        // Di web, XFile punya method readAsBytes()
        bytes = await _pickedXFile!.readAsBytes();
      } else {
        // Di mobile/desktop, kita bisa konversi XFile ke File dart:io
        final file = File(_pickedXFile!.path);
        bytes = await file.readAsBytes();
      }

      final response = await http.put(
        Uri.parse(bucketUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: bytes,
      );

      if (response.statusCode == 200) {
        setState(() {
          _uploadedUrl = bucketUrl;
          _isUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Upload berhasil!')));
      } else {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload gagal: HTTP ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error saat upload: $e')));
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedXFile = picked;
        _uploadedUrl = null;
      });
    }
  }

  int generate5DigitRandom() {
    final _random = Random();
    return 10000 + _random.nextInt(90000);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedXFile == null) {
      // Cek keduanya
      _showSnackBar('Silakan pilih gambar produk.', isError: true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isUploading = true;
    });

    try {
      if (_pickedXFile != null) {
        // Jika ada gambar yang dipilih, upload ke S3
        await uploadToS3();
      }
      if (_uploadedUrl == null) {
        throw Exception('Gagal mengunggah gambar');
      }

      await supabase.from('produk').insert({
        'nama_produk': _namaController.text.trim(),
        'harga': int.parse(_hargaController.text.trim()),
        'stok': int.parse(_stokController.text.trim()),
        'komposisi': _komposisiController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'link_foto': _uploadedUrl,
        'terjual': 0,
        'id' : generate5DigitRandom(),
      });

      print('✅ Produk berhasil ditambahkan: ${_namaController.text.trim()}');
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambah Produk Baru',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5D4037),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xff5D4037)),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          pickImage();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          width: 550,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child:
                              (_pickedXFile == null)
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 40,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pilih Gambar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  )
                                  : Image.network(
                                    _pickedXFile!.path,
                                    fit: BoxFit.cover,
                                    height: 500,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildModalTextFormField(
                      controller: _namaController,
                      label: 'Nama Menu',
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalTextFormField(
                            controller: _stokController,
                            label: 'Stok',
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    v!.isEmpty
                                        ? 'Wajib'
                                        : (int.tryParse(v) == null
                                            ? 'Angka'
                                            : null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModalTextFormField(
                            controller: _hargaController,
                            label: 'Harga',
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    v!.isEmpty
                                        ? 'Wajib'
                                        : (int.tryParse(v) == null
                                            ? 'Angka'
                                            : null),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModalTextFormField(
                      controller: _komposisiController,
                      label: 'Komposisi',
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildModalTextFormField(
                      controller: _deskripsiController,
                      label: 'Deskripsi Menu',
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_pickedXFile == null) {
                            _showSnackBar('Silahkan pilih gambar!');
                            return;
                          }
                          _submitForm.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF8E37),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isUploading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Simpan Menu',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.dmSans(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[700]),
          fillColor: Colors.grey[50],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffFF8E37), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}