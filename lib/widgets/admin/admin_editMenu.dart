import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cookie_jar/models/cookies.dart'; // Import model Cookies Anda

class AdminEditMenuWidget extends StatefulWidget {
  final Cookies product; // Menerima objek Cookies
  final double height;
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  const AdminEditMenuWidget({
    super.key,
    required this.product,
    required this.height,
    required this.onClose,
    required this.onSuccess,
  });

  @override
  State<AdminEditMenuWidget> createState() => _AdminEditMenuWidgetState();
}

class _AdminEditMenuWidgetState extends State<AdminEditMenuWidget> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _komposisiController = TextEditingController();
  final _deskripsiController = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _populateForm();
  }

  void _populateForm() {
    _namaController.text = widget.product.namaProduk;
    _hargaController.text = widget.product.harga.toString();
    _stokController.text = widget.product.stok.toString();
    _komposisiController.text = widget.product.komposisi ?? '';
    _deskripsiController.text = widget.product.deskripsi ?? '';
    _existingImageUrl = widget.product.linkFoto; // atau 'link_gambar'
  }

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
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, maxHeight: 1024, imageQuality: 80,
      );
      if (image != null) {
        if (!mounted) return;
        setState(() { _selectedImage = File(image.path); });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error memilih gambar: $e', isError: true);
    }
  }

  Future<String?> _uploadImageAndUpdate(String? oldImageUrl) async {
    if (_selectedImage == null) return oldImageUrl;

    try {
      final fileExtension = _selectedImage!.path.split('.').last;
      final newFileName = 'product_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final bytes = await _selectedImage!.readAsBytes();

      await supabase.storage.from('cookies').uploadBinary(
        newFileName, bytes,
        fileOptions: FileOptions(contentType: 'image/$fileExtension', upsert: false),
      );
      final newPublicUrl = supabase.storage.from('cookies').getPublicUrl(newFileName);

      if (oldImageUrl != null && oldImageUrl.isNotEmpty && oldImageUrl != newPublicUrl) {
         if (oldImageUrl.contains('cookies/')) {
            try {
                final oldFileKey = oldImageUrl.split('cookies/').last.split('?').first;
                if (oldFileKey.isNotEmpty) await supabase.storage.from('cookies').remove([oldFileKey]);
            } catch (e) {
                print('Gagal menghapus gambar lama dari storage: $e');
            }
        }
      }
      return newPublicUrl;
    } catch (e) {
      throw Exception('Error mengunggah gambar baru: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      String? finalImageUrl = _existingImageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _uploadImageAndUpdate(_existingImageUrl);
      }

      await supabase.from('produk').update({
        'nama_produk': _namaController.text.trim(),
        'harga': int.parse(_hargaController.text.trim()),
        'stok': int.parse(_stokController.text.trim()),
        'komposisi': _komposisiController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'link_foto': finalImageUrl, // atau 'link_gambar'
      }).eq('id', widget.product.id as Object);

      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (!mounted) return;
      setState(() { _isLoading = false; });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Layout dan Form Fields dari AdminEditMenuWidget sebelumnya...
    // Pastikan semua controller dan validator sudah sesuai.
    // Tombol close akan memanggil widget.onClose
    // Tombol submit akan memanggil _submitForm
    return Container( // Wrapper dasar
      height: widget.height,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Produk', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff5D4037))),
              IconButton(icon: const Icon(Icons.close, color: Color(0xff5D4037)), onPressed: widget.onClose),
            ],
          ),
          const Divider(height:20),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                          ),
                          child: _buildModalImagePreview(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildModalTextFormField(controller: _namaController, label: 'Nama Menu', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                    const SizedBox(height: 12),
                     Row(children: [
                        Expanded(child: _buildModalTextFormField(controller: _stokController, label: 'Stok', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib' : (int.tryParse(v) == null ? 'Angka' : null))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModalTextFormField(controller: _hargaController, label: 'Harga', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib' : (int.tryParse(v) == null ? 'Angka' : null))),
                    ]),
                    const SizedBox(height: 12),
                    _buildModalTextFormField(controller: _komposisiController, label: 'Komposisi', maxLines: 3, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                    const SizedBox(height: 12),
                    _buildModalTextFormField(controller: _deskripsiController, label: 'Deskripsi Menu', maxLines: 4, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                    const SizedBox(height: 24),
                     SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                         style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF8E37),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading 
                               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                               : Text('Simpan Perubahan', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
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
  
  Widget _buildModalImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.file(_selectedImage!, fit: BoxFit.cover, width: 150, height: 150));
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.network(_existingImageUrl!, fit: BoxFit.cover, width:150, height: 150, errorBuilder: (c,e,s) => Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 40)));
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[500]), const SizedBox(height: 8), Text('Ganti Gambar', style: TextStyle(fontSize: 12, color: Colors.grey[600]))]);
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xffFF8E37), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}