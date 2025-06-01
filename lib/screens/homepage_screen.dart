import 'package:cookie_jar/models/cookies.dart';
import 'package:cookie_jar/widgets/Layout/card_widget.dart';
import 'package:cookie_jar/widgets/Layout/carousel.dart';
import 'package:cookie_jar/widgets/Layout/footer_screen.dart';
import 'package:cookie_jar/widgets/Layout/header_screen.dart';
import 'package:cookie_jar/widgets/Layout/whyCookieJar_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cookie_jar/widgets/detail_produck.dart';

class HomepageScreen extends StatefulWidget {
  final String role;

  const HomepageScreen({super.key, this.role = 'Pembeli'});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Cookies> cookies = [];
  List<Cookies> popularCookies = [];
  List<Cookies> recommendedCookies = [];
  List<Cookies> newCookies = [];
  Cookies? selectedProduct;
  bool isLoading = true;

  // Animation controller for slide animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide animation from right to left
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right
      end: Offset.zero, // End at current position
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Opacity animation for overlay
    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    getData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    try {
      final response = await supabase.from('produk').select('*');

      final newResponse = await supabase
          .from('produk')
          .select('*')
          .order('created_at', ascending: false)
          .limit(6);

      setState(() {
        cookies = response.map((item) => Cookies.fromJson(item)).toList();
        // Simulate popular and recommended cookies
        popularCookies = cookies.take(6).toList();
        recommendedCookies = cookies.skip(6).take(6).toList();
        newCookies = newResponse.map((item) => Cookies.fromJson(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  void _showProductDetail(Cookies product) {
    setState(() {
      selectedProduct = product;
    });
    _animationController.forward();
  }

  void _hideProductDetail() {
    _animationController.reverse().then((_) {
      setState(() {
        selectedProduct = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const HeaderWidget(),

                        // Carousel
                        const CarouselWidget(),

                        // Popular Cookies Section
                        _buildSectionTitle("Kue Kering Paling Dicari"),
                        _buildHorizontalCookiesList(popularCookies),

                        _buildSectionTitle("Kue Kering Paling Baru"),
                        _buildHorizontalCookiesList(newCookies),

                        const SizedBox(height: 80),
                        // Why Cookie Jar Section
                        const WhyCookieJarWidget(),

                        const SizedBox(height: 60),

                        // Recommended Section
                        _buildSectionTitle("Rekomendasi"),
                        _buildHorizontalCookiesList(recommendedCookies),

                        const SizedBox(height: 60),

                        // Footer
                        const FooterWidget(),
                      ],
                    ),
                  ),

                  // Animated Detail Modal sliding from right
                  if (selectedProduct != null)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return GestureDetector(
                            onTap: _hideProductDetail,
                            child: Container(
                              color: Colors.black.withOpacity(
                                _opacityAnimation.value,
                              ),
                              child: Row(
                                children: [
                                  // Empty space on the left - tap to close
                                  Expanded(
                                    flex:
                                        MediaQuery.of(context).size.width > 768
                                            ? 2
                                            : 1,
                                    child: Container(),
                                  ),
                                  // Detail panel sliding from right
                                  SlideTransition(
                                    position: _slideAnimation,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width >
                                                  768
                                              ? 450 // Desktop width
                                              : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.85, // Mobile width
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: GestureDetector(
                                        onTap:
                                            () {}, // Prevent closing when tapping on panel
                                        child: Material(
                                          color: Colors.transparent,
                                          child: DetailPanel(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height,
                                            product: {
                                              'nama_produk':
                                                  selectedProduct!.namaProduk,
                                              'harga': selectedProduct!.harga,
                                              'stok': selectedProduct!.stok,
                                              'komposisi':
                                                  selectedProduct!.komposisi,
                                              'deskripsi':
                                                  selectedProduct!.deskripsi,
                                              'link_foto':
                                                  selectedProduct!.linkFoto,
                                            },
                                            onClose: _hideProductDetail,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHorizontalCookiesList(List<Cookies> cookiesList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: SizedBox(
        height: 280,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: cookiesList.length,
          itemBuilder: (context, index) {
            return CardWidget(
              cookie: cookiesList[index],
              onTap: () {
                if (widget.role != 'Admin') {
                  _showProductDetail(cookiesList[index]);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
