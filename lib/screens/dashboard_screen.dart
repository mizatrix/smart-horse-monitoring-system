
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_horse/screens/tabs/home_tab.dart';
import 'package:smart_horse/screens/tabs/stats_tab.dart';
import 'package:smart_horse/screens/stable_management_screen.dart';
import 'package:smart_horse/screens/settings_screen.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabPulseController;
  late Animation<double> _fabPulse;

  final List<Widget> _tabs = [
    const HomeTab(),
    const StatsTab(),
    const SizedBox(), // Placeholder for center FAB
    const StableManagementScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fabPulse = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _fabPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final navBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedColor = isDark ? const Color(0xFFD2B48C) : const Color(0xFF8D6E63);
    final unselectedColor = isDark ? Colors.grey[600] : Colors.grey[400];

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 2) {
                Navigator.pushNamed(context, '/ar_scan');
              } else {
                setState(() => _currentIndex = index);
              }
            },
            backgroundColor: navBgColor,
            selectedItemColor: selectedColor,
            unselectedItemColor: unselectedColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_currentIndex == 0 ? 6 : 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == 0 ? const Color(0xFFD2B48C).withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.grid_view_rounded, size: 22),
                ),
                label: AppStrings.get('home', lang),
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_currentIndex == 1 ? 6 : 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == 1 ? const Color(0xFFD2B48C).withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_outlined, size: 22),
                ),
                label: AppStrings.get('stats', lang),
              ),
              const BottomNavigationBarItem(icon: SizedBox(height: 22), label: ''),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_currentIndex == 3 ? 6 : 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == 3 ? const Color(0xFFD2B48C).withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(FontAwesomeIcons.shop, size: 18),
                ),
                label: AppStrings.get('stable', lang),
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_currentIndex == 4 ? 6 : 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == 4 ? const Color(0xFFD2B48C).withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.settings_outlined, size: 22),
                ),
                label: AppStrings.get('settings', lang),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabPulse,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD2B48C), Color(0xFF8D6E63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD2B48C).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/ar_scan'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
