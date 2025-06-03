import 'package:cookie_jar/models/cookies.dart';
import 'package:cookie_jar/widgets/Layout/footer_screen.dart';
import 'package:cookie_jar/widgets/Layout/header_screen.dart';
import 'package:cookie_jar/widgets/admin/admin_editMenu.dart';
import 'package:cookie_jar/widgets/admin/admin_tambahMenu.dart';
import 'package:cookie_jar/widgets/admin/admin_card_widget.dart'; // Import AdminCardWidget yang sudah diupdate
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminHomepageScreen extends StatefulWidget {
  const AdminHomepageScreen({super.key});

  @override
  State<AdminHomepageScreen> createState() => _AdminHomepageScreenState();
}

class _AdminHomepageScreenState extends State<AdminHomepageScreen> {
  final supabase = Supabase.instance.client;
  List<Cookies> cookies = [];
  int totalProducts = 0;
  int totalUsers = 0; 
  bool isPageLoading = true;
  bool showModal = false;
  Cookies? editingProduct;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getData() async {
    if (!mounted) return;
    setState(() {
      isPageLoading = true;
    });
    try {
      final productsResponse = await supabase.from('produk').select('*').order('created_at', ascending: false);
      final usersCount = 30;

      if (!mounted) return;
      setState(() {
        cookies = productsResponse.map((item) => Cookies.fromJson(item)).toList();
        totalProducts = cookies.length;
        totalUsers = usersCount; 
        isPageLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { isPageLoading = false; });
      print('Error fetching data: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddProductModal() {
    setState(() {
      editingProduct = null;
      showModal = true;
    });
  }

  void _showEditProductModal(Cookies product) {
    setState(() {
      editingProduct = product;
      showModal = true;
    });
  }

  Future<void> _deleteProduct(Cookies product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${product.namaProduk}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() => isPageLoading = true);
      try {
        if (product.linkFoto != null && product.linkFoto!.isNotEmpty) {
           if (product.linkFoto!.contains('/products/')) {
            final fileKey = product.linkFoto!.split('/products/').last.split('?').first;
             if(fileKey.isNotEmpty) await supabase.storage.from('products').remove([fileKey]);
           }
        }
        await supabase.from('produk').delete().eq('id', product.id as Object);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menghapus produk: $e'), backgroundColor: Colors.red),
        );
      } finally {
         if (!mounted) return;
         setState(() => isPageLoading = false);
         await getData();
          if (mounted && !(ModalRoute.of(context)?.isActive == false && ModalRoute.of(context)?.isCurrent == false)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil dihapus'), backgroundColor: Colors.green),
            );
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isPageLoading && !showModal
          ? const Center(child: CircularProgressIndicator(color: Color(0xffFF8E37)))
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeaderWidget(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildStatCard(title: 'Total Produk', value: totalProducts.toString(), color: const Color(0xFFFFF3E0), textColor: const Color(0xFFE65100), icon: Icons.inventory_2_outlined, iconColor: const Color(0xFFE65100))),
                                const SizedBox(width: 20),
                                Expanded(child: _buildStatCard(title: 'Total Pengguna', value: totalUsers.toString(), color: const Color(0xFFEFEBE9), textColor: const Color(0xFF4E342E), icon: Icons.people_outline, iconColor: const Color(0xFF4E342E))),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Daftar Semua Kue Kering', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Updated GridView with 6 cards per row
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6, // Changed from 4 to 6
                                childAspectRatio: 0.75, // Adjusted aspect ratio
                                crossAxisSpacing: 15, // Reduced spacing
                                mainAxisSpacing: 15,
                              ),
                              itemCount: cookies.length + 1, 
                              itemBuilder: (context, index) {
                                if (index == 0) return _buildAddProductStaticCard();
                                final product = cookies[index - 1];
                                return _buildNewProductCard(product); // Using new card widget
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      const FooterWidget(),
                    ],
                  ),
                ),
                if (showModal) _buildModalDialog(),
              ],
            ),
    );
  }

  Widget _buildModalDialog() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: editingProduct == null
                ? AdminTambahMenuWidget(
                    height: 700,
                    onClose: () => setState(() => showModal = false),
                    onSuccess: () {
                      setState(() => showModal = false);
                      getData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Produk berhasil ditambahkan!'), backgroundColor: Colors.green),
                      );
                    },
                  )
                : AdminEditMenuWidget(
                    product: editingProduct!,
                    height: 700,
                    onClose: () => setState(() => showModal = false),
                    onSuccess: () {
                      setState(() => showModal = false);
                      getData();
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Produk berhasil diperbarui!'), backgroundColor: Colors.green),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddProductStaticCard() {
    return InkWell(
      onTap: _showAddProductModal,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 40, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'Tambah Menu Baru',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color, 
    required Color textColor, 
    required IconData icon,
    required Color iconColor, 
  }) {
    return Container(
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Row( 
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15, 
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New method using AdminCardWidget
  Widget _buildNewProductCard(Cookies product) {
    // Convert Cookies object to Map for AdminCardWidget
    final productMap = {
      'nama_produk': product.namaProduk,
      'harga': product.harga,
      'stok': product.stok,
      'link_foto': product.linkFoto,
      'komposisi': product.komposisi,
      'terjual': product.terjual,
    };

    return AdminCardWidget(
      product: productMap,
      onTap: () {
        // Handle product tap if needed
        print('Product tapped: ${product.namaProduk}');
      },
      onEdit: () => _showEditProductModal(product),
      onDelete: () => _deleteProduct(product),
    );
  }
}