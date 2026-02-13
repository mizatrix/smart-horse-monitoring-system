
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_horse/services/mock_data_service.dart';
import '../horse_details_screen.dart';
import '../add_edit_horse_screen.dart';
import '../stats_screen.dart';
import '../stable_management_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../services/theme_provider.dart';
import '../../services/locale_provider.dart';
import '../../services/app_strings.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  String _statusFilter = 'All';

  void _showNotifications() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDFCF8);
    final handleColor = isDark ? Colors.grey[600] : Colors.grey[300];
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;

    final List<Map<String, dynamic>> notifications = [
      {'icon': '🚨', 'text': AppStrings.get('notif_heart_elevated', lang), 'time': AppStrings.get('time_5m', lang), 'urgent': true},
      {'icon': '💧', 'text': AppStrings.get('notif_hydration', lang), 'time': AppStrings.get('time_15m', lang), 'urgent': true},
      {'icon': '📅', 'text': AppStrings.get('notif_farrier', lang), 'time': AppStrings.get('time_1h', lang), 'urgent': false},
      {'icon': '✅', 'text': AppStrings.get('notif_feed_done', lang), 'time': AppStrings.get('time_3h', lang), 'urgent': false},
      {'icon': '🌡️', 'text': AppStrings.get('notif_heat', lang), 'time': AppStrings.get('time_4h', lang), 'urgent': true},
      {'icon': '💉', 'text': AppStrings.get('notif_vaccine', lang), 'time': AppStrings.get('time_6h', lang), 'urgent': false},
      {'icon': '🐴', 'text': AppStrings.get('notif_new_horse', lang), 'time': AppStrings.get('time_1d', lang), 'urgent': false},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.get('notifications', lang),
                        style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.get('clear_all', lang),
                          style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final notifBg = notif['urgent']
                        ? Colors.red.withOpacity(isDark ? 0.1 : 0.05)
                        : (isDark ? const Color(0xFF2A2A2A) : Colors.white);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: notifBg,
                        borderRadius: BorderRadius.circular(15),
                        border: notif['urgent'] ? Border.all(color: Colors.red.withOpacity(0.15)) : null,
                        boxShadow: [BoxShadow(color: (isDark ? Colors.black : Colors.grey).withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif['icon'], style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif['text'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
                                const SizedBox(height: 4),
                                Text(notif['time'], style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.08);
    final searchBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    List<Horse> horses = mockService.horses;

    // Apply filters
    if (_statusFilter != 'All') {
      horses = horses.where((h) => h.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      horses = horses.where((h) =>
          h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          h.breed.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EquiGuard',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8D6E63),
                          ),
                        ),
                        Text(
                          '${AppStrings.get('good_evening', lang)}, Moataz 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showNotifications,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)],
                        ),
                        child: const Stack(
                          children: [
                            Icon(Icons.notifications_none, size: 24, color: Color(0xFF8D6E63)),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Environment / Weather Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4DB6AC), Color(0xFF00695C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00695C).withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '28°C • ${AppStrings.get('partly_cloudy', lang)}',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            '${AppStrings.get('humidity', lang)} 62% • ${AppStrings.get('wind', lang)} 12 km/h • ${AppStrings.get('uv_index', lang)} 5',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HSI: 128',
                            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(AppStrings.get('heat_stress', lang), style: GoogleFonts.poppins(color: Colors.white60, fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Quick Stats Row
              Row(
                children: [
                  _buildQuickStat('${mockService.horses.length}', AppStrings.get('total', lang), Icons.pets, const Color(0xFF8D6E63), cardColor, textColor, subtextColor, shadowColor),
                  const SizedBox(width: 8),
                  _buildQuickStat('${mockService.criticalCount + mockService.warningCount}', AppStrings.get('alerts', lang), Icons.warning_amber_rounded, Colors.orange, cardColor, textColor, subtextColor, shadowColor),
                  const SizedBox(width: 8),
                  _buildQuickStat('${mockService.avgHeartRate.toStringAsFixed(0)}', AppStrings.get('avg_hr', lang), Icons.monitor_heart, Colors.redAccent, cardColor, textColor, subtextColor, shadowColor),
                  const SizedBox(width: 8),
                  _buildQuickStat('7', AppStrings.get('tasks', lang), Icons.check_circle_outline, Colors.green, cardColor, textColor, subtextColor, shadowColor),
                ],
              ),
              const SizedBox(height: 15),

              // Dashboard Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(
                      AppStrings.get('wellness_dashboard', lang),
                      Icons.speed,
                      const Color(0xFFD2B48C),
                      Colors.white,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StatsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDashboardCard(
                      AppStrings.get('monitoring_management', lang),
                      Icons.shield_outlined,
                      const Color(0xFF00695C),
                      Colors.white,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StableManagementScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Search Bar
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: GoogleFonts.poppins(fontSize: 14, color: textColor),
                  decoration: InputDecoration(
                    hintText: AppStrings.get('search_horses', lang),
                    hintStyle: GoogleFonts.poppins(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SizedBox(
                height: 35,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    {'key': 'All', 'label': AppStrings.get('all', lang)},
                    {'key': 'Stable', 'label': AppStrings.get('stable_status', lang)},
                    {'key': 'Warning', 'label': AppStrings.get('warning', lang)},
                    {'key': 'Critical', 'label': AppStrings.get('critical', lang)},
                  ].map((filter) {
                    final isSelected = _statusFilter == filter['key'];
                    Color chipColor;
                    switch (filter['key']) {
                      case 'Stable': chipColor = Colors.green; break;
                      case 'Warning': chipColor = Colors.orange; break;
                      case 'Critical': chipColor = Colors.red; break;
                      default: chipColor = const Color(0xFF00695C);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filter['label']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : chipColor,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) => setState(() => _statusFilter = filter['key']!),
                        backgroundColor: chipColor.withOpacity(0.1),
                        selectedColor: chipColor,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Horses Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppStrings.get('horses', lang)} (${horses.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() { _searchQuery = ''; _statusFilter = 'All'; }),
                    child: Text(
                      AppStrings.get('reset', lang),
                      style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                  ),
                ],
              ),

              // Horse List
              AnimationLimiter(
                child: horses.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 60, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text(AppStrings.get('no_horses_found', lang), style: GoogleFonts.poppins(color: subtextColor)),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: horses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final horse = horses[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildHorseListItem(context, horse, isDark, lang, cardColor, textColor, subtextColor, shadowColor),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 80), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditHorseScreen()),
          );
        },
        backgroundColor: const Color(0xFFD2B48C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon, Color color,
      Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
            Text(label, style: GoogleFonts.poppins(fontSize: 9, color: subtextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 22),
                Icon(Icons.arrow_forward_ios, color: iconColor.withOpacity(0.6), size: 14),
              ],
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorseListItem(BuildContext context, Horse horse, bool isDark, String lang,
      Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    Color statusColor;
    String statusText;
    switch (horse.status) {
      case 'Critical':
        statusColor = Colors.red;
        statusText = AppStrings.get('critical', lang);
        break;
      case 'Warning':
        statusColor = Colors.orange;
        statusText = AppStrings.get('warning', lang);
        break;
      default:
        statusColor = Colors.green;
        statusText = AppStrings.get('healthy', lang);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HorseDetailsScreen(horse: horse),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: horse.id,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                  image: DecorationImage(
                    image: AssetImage(horse.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    horse.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${horse.breed} • ${horse.age} ${AppStrings.get('yrs', lang)}',
                        style: GoogleFonts.poppins(color: subtextColor, fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.monitor_heart, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${horse.currentHeartRate.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(color: subtextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.poppins(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
