import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Jika fungsi S3 Anda memerlukan mime type:
// import 'package:mime/mime.dart';

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

  // Untuk pratinjau lokal
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  // Untuk URL gambar setelah diunggah ke S3
  String? s3ImageUrl;

  bool _isLoading = false; // Untuk loading state keseluruhan form
  bool _isUploadingImage = false; // Untuk loading state spesifik unggah gambar S3

  final _picker = ImagePicker();

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _komposisiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImageName = pickedFile.name;
      if (kIsWeb) {
        _selectedImageBytes = await pickedFile.readAsBytes();
        _selectedImageFile = null; // Pastikan file null untuk web
      } else {
        _selectedImageFile = File(pickedFile.path);
        _selectedImageBytes = null; // Pastikan bytes null untuk non-web
      }
      // Reset s3ImageUrl karena gambar baru telah dipilih untuk pratinjau.
      // Ini akan diisi lagi SETELAH gambar baru ini diunggah ke S3.
      s3ImageUrl = null;
      setState(() {}); // Perbarui UI untuk menampilkan pratinjau
    } else {
      _showSnackBar('Tidak ada gambar yang dipilih.', isError: true);
    }
  }

  // --- GANTIKAN DENGAN FUNGSI UNGGAH S3 ANDA ---
  // Contoh kerangka, Anda harus mengimplementasikannya
  Future<String?> _yourActualS3UploadFunction(dynamic imageData, String fileName) async {
    // imageData bisa berupa File atau Uint8List
    // fileName adalah nama file yang diinginkan di S3
    _showSnackBar("Mulai mengunggah ke S3...", isError: false);
    await Future.delayed(const Duration(seconds: 3)); // Simulasi proses unggah

    // Logika unggah S3 Anda di sini
    // if (unggah berhasil) {
    //   return "URL_GAMBAR_DARI_S3/$fileName";
    // } else {
    //   return null;
    // }
    // Contoh kembalian sukses:
    return "https://s3.your-region.amazonaws.com/your-bucket-name/uploads/$fileName";
    // Contoh kembalian gagal:
    // return null;
  }
  // --- AKHIR FUNGSI UNGGAH S3 ---


  Future<void> _saveMenu() async { // Menggantikan _uploadToS3AndSaveForm atau nama serupa
    if (!_formKey.currentState!.validate()) return;

    // Cek apakah ada gambar yang perlu diproses (baik lokal atau sudah ada URL S3)
    if (_selectedImageFile == null && _selectedImageBytes == null && s3ImageUrl == null) {
      _showSnackBar('Silakan pilih gambar produk terlebih dahulu.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true; // Loading untuk keseluruhan proses
    });

    String? finalImageUrlForSupabase = s3ImageUrl; // Gunakan URL S3 yang sudah ada jika gambar tidak diubah

    try {
      // Jika ada gambar lokal yang baru dipilih (artinya s3ImageUrl di-reset menjadi null oleh _pickImage)
      if ((_selectedImageFile != null || _selectedImageBytes != null) && finalImageUrlForSupabase == null) {
        setState(() {
          _isUploadingImage = true;
        });

        dynamic imageData = kIsWeb ? _selectedImageBytes : _selectedImageFile;
        String fileName = _selectedImageName ?? DateTime.now().millisecondsSinceEpoch.toString() + (kIsWeb ? '.jpg' : _selectedImageFile!.path.split('.').last);
        
        finalImageUrlForSupabase = await _yourActualS3UploadFunction(imageData!, fileName);

        setState(() {
          _isUploadingImage = false;
        });

        if (finalImageUrlForSupabase == null) {
          _showSnackBar('Gagal mengunggah gambar ke S3. Silakan coba lagi.', isError: true);
          setState(() { _isLoading = false; });
          return;
        }
        // Update s3ImageUrl di state agar jika terjadi error setelah ini dan UI dibangun ulang, Image.network bisa digunakan
        setState(() {
          s3ImageUrl = finalImageUrlForSupabase;
        });
        _showSnackBar('Gambar berhasil diunggah ke S3.');
      }

      if (finalImageUrlForSupabase == null) {
        _showSnackBar('URL gambar tidak tersedia untuk disimpan.', isError: true);
        setState(() { _isLoading = false; });
        return;
      }
      
      // Lanjutkan menyimpan data produk ke tabel Supabase
      await supabase.from('produk').insert({
        'nama_produk': _namaController.text.trim(),
        'harga': int.parse(_hargaController.text.trim()),
        'stok': int.parse(_stokController.text.trim()),
        'komposisi': _komposisiController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'link_foto': finalImageUrlForSupabase, // Gunakan URL gambar dari S3
        'terjual': 0,
      });

      if (!mounted) return;
      _showSnackBar('Menu berhasil ditambahkan!');
      widget.onSuccess();

    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error saat menyimpan: ${e.toString()}', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isUploadingImage = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
      ),
    );
  }

  Widget _buildImagePreview() {
    // Prioritas 1: Pratinjau lokal dari gambar yang baru dipilih (web)
    if (_selectedImageBytes != null && kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
          width: 500,
          height: 500,
        ),
      );
    }
    // Prioritas 2: Pratinjau lokal dari gambar yang baru dipilih (mobile/desktop)
    else if (_selectedImageFile != null && !kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: 500,
          height: 500,
        ),
      );
    }
    // Prioritas 3: Gambar dari S3 jika sudah diunggah dan tidak ada pratinjau lokal aktif
    else if (s3ImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          s3ImageUrl!,
          fit: BoxFit.cover,
          width: 500,
          height: 500,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container( /* ... widget loading Anda ... */ );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container( /* ... widget error Anda ... */ );
          },
        ),
      );
    }
    // Prioritas 4: Placeholder jika tidak ada gambar sama sekali ATAU sedang proses unggah awal
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isUploadingImage) ...[ // Tampilkan loading HANYA jika sedang upload DAN belum ada pratinjau/S3 URL
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Mengunggah gambar...'),
          ] else ...[
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
        ],
      );
    }
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
                        onTap: (_isLoading || _isUploadingImage) ? null : _pickImage,
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
                          child: _buildImagePreview(),
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
                            validator: (v) => v!.isEmpty
                                ? 'Wajib'
                                : (int.tryParse(v) == null ? 'Angka' : null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModalTextFormField(
                            controller: _hargaController,
                            label: 'Harga',
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty
                                ? 'Wajib'
                                : (int.tryParse(v) == null ? 'Angka' : null),
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
                        onPressed: (_isLoading || _isUploadingImage)
                            ? null
                            : _saveMenu, // Panggil _saveMenu
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF8E37),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading // Cukup _isLoading karena itu mencakup _isUploadingImage
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