
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricLock = false;
  String _tempUnit = 'Celsius';
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = info.version);
    } catch (_) {}
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    // Theme-aware colors
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final iconBgColor = isDark
        ? const Color(0xFFD2B48C).withOpacity(0.15)
        : const Color(0xFFD2B48C).withOpacity(0.1);
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimationLimiter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  Text(AppStrings.get('settings', lang),
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 5),
                  Text(AppStrings.get('manage_preferences', lang),
                      style: GoogleFonts.poppins(color: subtextColor, fontSize: 14)),
                  const SizedBox(height: 25),

                  // --- Profile Card ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD2B48C), Color(0xFF8D6E63)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFD2B48C).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Moataz',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text('Farm Owner • Premium',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 12)),
                              Text('moataz@equiguard.com',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white60, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- Preferences ---
                  _buildSectionTitle(
                      AppStrings.get('preferences', lang), textColor),

                  _buildToggleTile(
                    AppStrings.get('push_notifications', lang),
                    AppStrings.get('notifications_sub', lang),
                    Icons.notifications_outlined,
                    _notificationsEnabled,
                    (val) => setState(() => _notificationsEnabled = val),
                    cardColor,
                    textColor,
                    subtextColor,
                    iconBgColor,
                    shadowColor,
                  ),

                  _buildToggleTile(
                    AppStrings.get('dark_mode', lang),
                    AppStrings.get('dark_mode_sub', lang),
                    Icons.dark_mode_outlined,
                    isDark,
                    (val) => themeProvider.toggleTheme(),
                    cardColor,
                    textColor,
                    subtextColor,
                    iconBgColor,
                    shadowColor,
                  ),

                  _buildToggleTile(
                    AppStrings.get('language', lang),
                    AppStrings.get('language_sub', lang),
                    Icons.translate,
                    localeProvider.isArabic,
                    (val) => localeProvider.toggleLanguage(),
                    cardColor,
                    textColor,
                    subtextColor,
                    iconBgColor,
                    shadowColor,
                  ),

                  _buildToggleTile(
                    AppStrings.get('biometric_lock', lang),
                    AppStrings.get('biometric_sub', lang),
                    Icons.fingerprint,
                    _biometricLock,
                    (val) => setState(() => _biometricLock = val),
                    cardColor,
                    textColor,
                    subtextColor,
                    iconBgColor,
                    shadowColor,
                  ),

                  _buildOptionTile(
                    AppStrings.get('temperature_unit', lang),
                    _tempUnit,
                    Icons.thermostat,
                    () => setState(() => _tempUnit =
                        _tempUnit == 'Celsius' ? 'Fahrenheit' : 'Celsius'),
                    cardColor,
                    textColor,
                    shadowColor,
                  ),
                  const SizedBox(height: 20),

                  // --- Farm Info ---
                  _buildSectionTitle(
                      AppStrings.get('farm_details', lang), textColor),
                  _buildInfoTile(
                      AppStrings.get('farm_name', lang),
                      'Al-Faris Stables',
                      Icons.home_work,
                      cardColor,
                      textColor,
                      subtextColor,
                      shadowColor),
                  _buildInfoTile(
                      AppStrings.get('location', lang),
                      'Cairo, Egypt',
                      Icons.location_on,
                      cardColor,
                      textColor,
                      subtextColor,
                      shadowColor),
                  _buildInfoTile(
                      AppStrings.get('horses', lang),
                      '50 ${AppStrings.get('registered', lang)}',
                      Icons.pets,
                      cardColor,
                      textColor,
                      subtextColor,
                      shadowColor),
                  _buildInfoTile(
                      AppStrings.get('staff_members', lang),
                      '6 ${AppStrings.get('active', lang)}',
                      Icons.group,
                      cardColor,
                      textColor,
                      subtextColor,
                      shadowColor),
                  const SizedBox(height: 20),

                  // --- Data Management ---
                  _buildSectionTitle(
                      AppStrings.get('data_management', lang), textColor),
                  _buildActionTile(
                    AppStrings.get('export_health_data', lang),
                    AppStrings.get('export_sub', lang),
                    Icons.file_download,
                    const Color(0xFF00695C),
                    cardColor,
                    textColor,
                    subtextColor,
                    shadowColor,
                  ),
                  _buildActionTile(
                    AppStrings.get('backup_sync', lang),
                    AppStrings.get('backup_sub', lang),
                    Icons.cloud_upload,
                    Colors.blue,
                    cardColor,
                    textColor,
                    subtextColor,
                    shadowColor,
                  ),
                  _buildActionTile(
                    AppStrings.get('clear_cache', lang),
                    AppStrings.get('clear_cache_sub', lang),
                    Icons.cached,
                    Colors.orange,
                    cardColor,
                    textColor,
                    subtextColor,
                    shadowColor,
                  ),
                  _buildActionTile(
                    AppStrings.get('clear_all_data', lang),
                    AppStrings.get('clear_all_sub', lang),
                    Icons.delete_forever,
                    Colors.red,
                    cardColor,
                    textColor,
                    subtextColor,
                    shadowColor,
                  ),
                  const SizedBox(height: 20),

                  // --- About ---
                  _buildSectionTitle(
                      AppStrings.get('about', lang), textColor),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: shadowColor, blurRadius: 8)
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFD2B48C),
                                  Color(0xFF8D6E63)
                                ]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.pets,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('EquiGuard',
                                      style:
                                          GoogleFonts.playfairDisplay(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textColor)),
                                  Text(
                                      AppStrings.get('tagline', lang),
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: subtextColor)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFFD2B48C),
                                  Color(0xFF8D6E63)
                                ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('v$_appVersion',
                                  style: GoogleFonts.robotoMono(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(
                            color: isDark
                                ? Colors.grey[700]
                                : Colors.grey[200]),
                        const SizedBox(height: 10),
                        _buildAboutRow('Build', '2026.02.13', textColor, subtextColor),
                        _buildAboutRow('SDK', 'Flutter 3.x', textColor, subtextColor),
                        _buildAboutRow('License', 'Proprietary', textColor, subtextColor),
                        _buildAboutRow('Developer', 'EquiGuard Team', textColor, subtextColor),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _buildAboutAction(
                                    AppStrings.get('support', lang),
                                    Icons.help_outline,
                                    isDark)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildAboutAction(
                                    AppStrings.get('privacy', lang),
                                    Icons.shield_outlined,
                                    isDark)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildAboutAction(
                                    AppStrings.get('terms', lang),
                                    Icons.description_outlined,
                                    isDark)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Logout ---
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,
                              color: Colors.red[isDark ? 300 : 600],
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.get('logout', lang),
                            style: GoogleFonts.poppins(
                              color: Colors.red[isDark ? 300 : 600],
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor)),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color iconBgColor,
    Color shadowColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: const Color(0xFF8D6E63), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: textColor)),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: subtextColor)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00695C),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    String current,
    IconData icon,
    VoidCallback onTap,
    Color cardColor,
    Color textColor,
    Color shadowColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD2B48C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: const Color(0xFF8D6E63), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: textColor))),
            Text(current,
                style: GoogleFonts.poppins(
                    color: const Color(0xFF00695C),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(width: 4),
            Icon(Icons.swap_horiz, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color shadowColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(
                      color: subtextColor, fontSize: 13))),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textColor)),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color shadowColor,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(title), duration: const Duration(seconds: 1)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: textColor)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: subtextColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(
      String label, String value, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: subtextColor)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor)),
        ],
      ),
    );
  }

  Widget _buildAboutAction(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }
}
