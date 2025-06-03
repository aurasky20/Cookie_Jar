import 'dart:io';
import 'dart:typed_data'; // Untuk Uint8List
import 'package:cookie_jar/utils/Utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  File? _selectedImageFile; // Untuk mobile/desktop
  Uint8List? _selectedImageBytes; // Untuk pratinjau di web
  String? _selectedImageName; // Untuk nama file dan ekstensi

  Uri? imageUrl; // Untuk menyimpan URL gambar yang diunggah

  bool _isLoading = false;
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

  String extractImagePath(String fullUrl) {
    final regex = RegExp(
      r'^.*?\.(jpg|png|jpeg|gif|webp|bmp)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(fullUrl);

    debugPrint('Extracted image path: $match');
    return match?.group(0) ?? '';
  }

  upload() async {
    try {
      imageUrl = await Utils.pickAndUploadImage();

      displayImageUrl = extractImagePath(imageUrl.toString());

      if (imageUrl != null) {
        _showSnackBar('Gambar berhasil diunggah: $imageUrl');
      } else {
        _showSnackBar('Gagal mengunggah gambar', isError: true);
      }
      setState(() {});
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  // Future<void> _pickImage() async {
  //   try {
  //     final XFile? image = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       maxWidth: 1024,
  //       maxHeight: 1024,
  //       imageQuality: 80,
  //     );

  //     if (image != null) {
  //       final bytes = await image.readAsBytes();
  //       if (!mounted) return;
  //       setState(() {
  //         if (kIsWeb) {
  //           _selectedImageBytes = bytes;
  //         } else {
  //           _selectedImageFile = File(image.path);
  //         }
  //         _selectedImageName = image.name; // Simpan nama file untuk ekstensi
  //       });
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     _showSnackBar('Error memilih gambar: $e', isError: true);
  //   }
  // }

  Future<String?> _uploadImage() async {
    if (_selectedImageFile == null && _selectedImageBytes == null) return null;
    if (_selectedImageName == null) return null;

    try {
      // Mendapatkan ekstensi dari nama file
      final fileExtension = _selectedImageName!.split('.').last;
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      final Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = _selectedImageBytes!;
      } else {
        imageBytes = await _selectedImageFile!.readAsBytes();
      }

      await supabase.storage
          .from('products')
          .uploadBinary(
            fileName,
            imageBytes, // Gunakan imageBytes untuk upload
            fileOptions: FileOptions(
              contentType: 'image/$fileExtension',
              upsert: false,
            ),
          );

      return supabase.storage.from('products').getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Error mengunggah gambar: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageFile == null && _selectedImageBytes == null) {
      // Cek keduanya
      _showSnackBar('Silakan pilih gambar produk.', isError: true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = await _uploadImage();
      if (imageUrl == null) {
        throw Exception('Gagal mengunggah gambar');
      }

      await supabase.from('produk').insert({
        'nama_produk': _namaController.text.trim(),
        'harga': int.parse(_hargaController.text.trim()),
        'stok': int.parse(_stokController.text.trim()),
        'komposisi': _komposisiController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'link_foto': imageUrl,
        'terjual': 0,
      });

      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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

  // Widget _buildImagePreview() {
  //   if (kIsWeb && _selectedImageBytes != null) {
  //     return ClipRRect(
  //       borderRadius: BorderRadius.circular(11),
  //       child: Image.memory(
  //         _selectedImageBytes!,
  //         fit: BoxFit.cover,
  //         width: 150,
  //         height: 150,
  //       ),
  //     );
  //   } else if (!kIsWeb && _selectedImageFile != null) {
  //     return ClipRRect(
  //       borderRadius: BorderRadius.circular(11),
  //       child: Image.file(
  //         _selectedImageFile!,
  //         fit: BoxFit.cover,
  //         width: 150,
  //         height: 150,
  //       ),
  //     );
  //   } else {

  //   }
  // }

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
                          upload();
                        },
                        child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child:
                              (imageUrl == null)
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
                                    displayImageUrl,
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
                          if (imageUrl == null) {
                            _showSnackBar('Silahkan pilih gambar!');
                            return;
                          }
                          _submitForm;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF8E37),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
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
