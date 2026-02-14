
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _cartCount = 0;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'icon': Icons.grid_view_rounded},
    {'key': 'iot', 'icon': Icons.sensors},
    {'key': 'tack', 'icon': Icons.inventory_2},
    {'key': 'feed', 'icon': Icons.grass},
    {'key': 'grooming', 'icon': Icons.brush},
    {'key': 'health', 'icon': Icons.medical_services},
  ];

  final List<Map<String, dynamic>> _products = [
    // IoT Sensors
    {'name': 'Smart Heart Rate Monitor', 'nameAr': 'مراقب نبضات القلب الذكي', 'category': 'iot', 'price': 299.99, 'rating': 4.8, 'image': Icons.monitor_heart, 'color': Colors.redAccent, 'desc': 'Real-time equine cardiac monitoring', 'descAr': 'مراقبة القلب في الوقت الفعلي'},
    {'name': 'GPS Tracker Collar', 'nameAr': 'طوق تتبع GPS', 'category': 'iot', 'price': 189.99, 'rating': 4.6, 'image': Icons.gps_fixed, 'color': Colors.blueAccent, 'desc': 'Live location tracking', 'descAr': 'تتبع الموقع المباشر'},
    {'name': 'Temperature Sensor Band', 'nameAr': 'حزام استشعار الحرارة', 'category': 'iot', 'price': 149.99, 'rating': 4.7, 'image': Icons.thermostat, 'color': Colors.orangeAccent, 'desc': '24/7 temperature monitoring', 'descAr': 'مراقبة الحرارة على مدار الساعة'},
    {'name': 'Smart Feeder Pro', 'nameAr': 'وحدة التغذية الذكية برو', 'category': 'iot', 'price': 449.99, 'rating': 4.9, 'image': Icons.set_meal, 'color': Colors.green, 'desc': 'Automated feeding schedules', 'descAr': 'جداول تغذية آلية'},
    {'name': 'Gait Analysis Sensor', 'nameAr': 'مستشعر تحليل المشية', 'category': 'iot', 'price': 349.99, 'rating': 4.5, 'image': Icons.directions_walk, 'color': Colors.purple, 'desc': 'Movement & lameness detection', 'descAr': 'كشف الحركة والعرج'},
    {'name': 'Hydration Monitor', 'nameAr': 'مراقب الترطيب', 'category': 'iot', 'price': 199.99, 'rating': 4.4, 'image': Icons.water_drop, 'color': Colors.cyan, 'desc': 'Water intake tracking', 'descAr': 'تتبع استهلاك المياه'},

    // Tack & Equipment
    {'name': 'Premium Leather Saddle', 'nameAr': 'سرج جلد فاخر', 'category': 'tack', 'price': 1299.99, 'rating': 4.9, 'image': Icons.chair, 'color': const Color(0xFF8D6E63), 'desc': 'Hand-crafted English saddle', 'descAr': 'سرج إنجليزي مصنوع يدوياً'},
    {'name': 'Nylon Halter Set', 'nameAr': 'طقم خطام نايلون', 'category': 'tack', 'price': 34.99, 'rating': 4.3, 'image': Icons.link, 'color': Colors.teal, 'desc': 'Adjustable fit', 'descAr': 'مقاس قابل للتعديل'},
    {'name': 'Riding Boots Pro', 'nameAr': 'أحذية ركوب برو', 'category': 'tack', 'price': 249.99, 'rating': 4.7, 'image': Icons.hiking, 'color': Colors.brown, 'desc': 'Leather riding boots', 'descAr': 'أحذية ركوب جلدية'},
    {'name': 'Riding Helmet Elite', 'nameAr': 'خوذة ركوب إيليت', 'category': 'tack', 'price': 179.99, 'rating': 4.8, 'image': Icons.sports_motorsports, 'color': Colors.grey, 'desc': 'ASTM/SEI certified', 'descAr': 'شهادة ASTM/SEI'},

    // Feed & Supplements
    {'name': 'Premium Hay Blend', 'nameAr': 'مزيج تبن فاخر', 'category': 'feed', 'price': 89.99, 'rating': 4.6, 'image': Icons.grass, 'color': Colors.green, 'desc': 'Timothy & Alfalfa mix, 50lb', 'descAr': 'مزيج تيموثي والبرسيم'},
    {'name': 'Electrolyte Paste', 'nameAr': 'معجون إلكتروليت', 'category': 'feed', 'price': 24.99, 'rating': 4.5, 'image': Icons.science, 'color': Colors.amber, 'desc': 'Rapid rehydration', 'descAr': 'ترطيب سريع'},
    {'name': 'Joint Support Plus', 'nameAr': 'دعم المفاصل بلس', 'category': 'feed', 'price': 59.99, 'rating': 4.8, 'image': Icons.fitness_center, 'color': Colors.deepOrange, 'desc': 'Glucosamine & MSM formula', 'descAr': 'تركيبة جلوكوزامين'},
    {'name': 'Omega-3 Oil', 'nameAr': 'زيت أوميغا-3', 'category': 'feed', 'price': 39.99, 'rating': 4.4, 'image': Icons.opacity, 'color': Colors.indigo, 'desc': 'For coat & hoof health', 'descAr': 'لصحة الشعر والحافر'},

    // Grooming
    {'name': 'Grooming Kit Deluxe', 'nameAr': 'طقم تنظيف فاخر', 'category': 'grooming', 'price': 69.99, 'rating': 4.7, 'image': Icons.brush, 'color': Colors.pink, 'desc': '8-piece complete set', 'descAr': 'طقم كامل 8 قطع'},
    {'name': 'Mane & Tail Shampoo', 'nameAr': 'شامبو العرف والذيل', 'category': 'grooming', 'price': 19.99, 'rating': 4.3, 'image': Icons.shower, 'color': Colors.lightBlue, 'desc': 'Natural botanical formula', 'descAr': 'تركيبة نباتية طبيعية'},
    {'name': 'Hoof Pick & Brush', 'nameAr': 'فرشاة وأداة الحافر', 'category': 'grooming', 'price': 14.99, 'rating': 4.5, 'image': Icons.cleaning_services, 'color': Colors.blueGrey, 'desc': 'Ergonomic design', 'descAr': 'تصميم مريح'},

    // Health
    {'name': 'First Aid Kit Equine', 'nameAr': 'طقم إسعافات أولية', 'category': 'health', 'price': 79.99, 'rating': 4.9, 'image': Icons.medical_services, 'color': Colors.red, 'desc': 'Complete 40-piece kit', 'descAr': 'طقم كامل 40 قطعة'},
    {'name': 'Fly Spray Organic', 'nameAr': 'رذاذ حشرات عضوي', 'category': 'health', 'price': 29.99, 'rating': 4.2, 'image': Icons.bug_report, 'color': Colors.lime, 'desc': 'Chemical-free protection', 'descAr': 'حماية خالية من المواد الكيميائية'},
    {'name': 'Wound Care Gel', 'nameAr': 'جل العناية بالجروح', 'category': 'health', 'price': 22.99, 'rating': 4.6, 'image': Icons.healing, 'color': Colors.teal, 'desc': 'Antiseptic formula', 'descAr': 'تركيبة مطهرة'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final catKey = _categories[_tabController.index]['key'];
    var filtered = catKey == 'all' ? _products : _products.where((p) => p['category'] == catKey).toList();
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
          p['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['nameAr'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.08);

    final catLabels = {
      'all': lang == 'ar' ? 'الكل' : 'All',
      'iot': lang == 'ar' ? 'مستشعرات' : 'IoT',
      'tack': lang == 'ar' ? 'معدات' : 'Tack',
      'feed': lang == 'ar' ? 'أعلاف' : 'Feed',
      'grooming': lang == 'ar' ? 'تنظيف' : 'Groom',
      'health': lang == 'ar' ? 'صحة' : 'Health',
    };

    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        title: Text(lang == 'ar' ? 'المتجر' : 'Shop', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        actions: [
          Stack(children: [
            IconButton(icon: Icon(Icons.shopping_cart_outlined, color: textColor), onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang == 'ar' ? 'السلة فارغة' : 'Cart is empty'), duration: const Duration(seconds: 1)));
            }),
            if (_cartCount > 0)
              Positioned(right: 8, top: 8, child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )),
          ]),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)]),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.poppins(fontSize: 14, color: textColor),
                decoration: InputDecoration(
                  hintText: lang == 'ar' ? 'البحث في المنتجات...' : 'Search products...',
                  hintStyle: GoogleFonts.poppins(color: subtextColor, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: subtextColor, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Category tabs
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _tabController.index == index;
                return GestureDetector(
                  onTap: () => _tabController.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8D6E63) : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: isSelected ? const Color(0xFF8D6E63).withOpacity(0.3) : shadowColor, blurRadius: isSelected ? 12 : 4, offset: const Offset(0, 3))],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(cat['icon'], color: isSelected ? Colors.white : subtextColor, size: 22),
                      const SizedBox(height: 4),
                      Text(catLabels[cat['key']]!, style: GoogleFonts.poppins(color: isSelected ? Colors.white : subtextColor, fontSize: 9, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                );
              },
            ),
          ),

          // Products count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: lang == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
              child: Text('${products.length} ${lang == 'ar' ? 'منتج' : 'products'}',
                  style: GoogleFonts.poppins(color: subtextColor, fontSize: 12)),
            ),
          ),

          // Products grid
          Expanded(
            child: products.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.shopping_bag_outlined, size: 60, color: subtextColor.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text(lang == 'ar' ? 'لا توجد منتجات' : 'No products found', style: GoogleFonts.poppins(color: subtextColor)),
                  ]))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(product, isDark, lang, cardColor, textColor, subtextColor, shadowColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark, String lang,
      Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    final Color productColor = product['color'];

    return GestureDetector(
      onTap: () => _showProductDetail(product, isDark, lang),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Product icon area
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: productColor.withOpacity(isDark ? 0.15 : 0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Center(child: Icon(product['image'], color: productColor, size: 40)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang == 'ar' ? product['nameAr'] : product['name'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: textColor),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(lang == 'ar' ? product['descAr'] : product['desc'],
                  style: GoogleFonts.poppins(color: subtextColor, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$${product['price'].toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF8D6E63))),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  Text('${product['rating']}', style: GoogleFonts.poppins(color: subtextColor, fontSize: 11)),
                ]),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showProductDetail(Map<String, dynamic> product, bool isDark, String lang) {
    final Color productColor = product['color'];
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: productColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(product['image'], color: productColor, size: 50),
          ),
          const SizedBox(height: 20),
          Text(lang == 'ar' ? product['nameAr'] : product['name'],
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: textColor), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text(' ${product['rating']}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            Text(' • ', style: TextStyle(color: Colors.grey[400])),
            Text(lang == 'ar' ? product['descAr'] : product['desc'], style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
          ]),
          const SizedBox(height: 20),
          Text('\$${product['price']}', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF8D6E63))),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _cartCount++);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(lang == 'ar' ? 'تمت الإضافة إلى السلة' : 'Added to cart'),
                    backgroundColor: const Color(0xFF8D6E63), duration: const Duration(seconds: 1),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(lang == 'ar' ? 'إضافة إلى السلة' : 'Add to Cart',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
