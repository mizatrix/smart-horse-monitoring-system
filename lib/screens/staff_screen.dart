
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _team = [
    {'name': 'Ahmed Al-Rashid', 'role': 'Head Trainer', 'avatar': 'assets/images/horse_avatar_1.png', 'status': 'On Shift', 'horses': 4, 'tasks': 6, 'experience': '8 yrs', 'phone': '+971 50 123 4567'},
    {'name': 'Dr. Sarah Williams', 'role': 'Veterinarian', 'avatar': 'assets/images/horse_avatar_2.png', 'status': 'On Shift', 'horses': 10, 'tasks': 3, 'experience': '12 yrs', 'phone': '+971 55 987 6543'},
    {'name': 'Omar Khayyam', 'role': 'Stable Hand', 'avatar': 'assets/images/horse_avatar_3.png', 'status': 'On Shift', 'horses': 6, 'tasks': 8, 'experience': '3 yrs', 'phone': '+971 52 456 7890'},
    {'name': 'Fatima Noor', 'role': 'Groomer', 'avatar': 'assets/images/horse_avatar_4.png', 'status': 'Off Today', 'horses': 5, 'tasks': 0, 'experience': '5 yrs', 'phone': '+971 54 321 0987'},
    {'name': 'Dr. Ahmed Hassan', 'role': 'Equine Dentist', 'avatar': 'assets/images/horse_avatar_1.png', 'status': 'Upcoming', 'horses': 0, 'tasks': 2, 'experience': '10 yrs', 'phone': '+971 56 111 2222'},
  ];

  final List<Map<String, dynamic>> _leaderboard = [
    {'name': 'Ahmed Al-Rashid', 'points': 2340, 'tasksCompleted': 187, 'streak': 14, 'badge': '🏆'},
    {'name': 'Omar Khayyam', 'points': 2180, 'tasksCompleted': 165, 'streak': 9, 'badge': '🥈'},
    {'name': 'Fatima Noor', 'points': 1920, 'tasksCompleted': 142, 'streak': 7, 'badge': '🥉'},
    {'name': 'Dr. Sarah Williams', 'points': 1750, 'tasksCompleted': 98, 'streak': 5, 'badge': '⭐'},
    {'name': 'Dr. Ahmed Hassan', 'points': 1200, 'tasksCompleted': 45, 'streak': 3, 'badge': '⭐'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.05);
    final tabBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppStrings.get('staff_screen', lang), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: tabBg, borderRadius: BorderRadius.circular(14)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: const Color(0xFF00695C), borderRadius: BorderRadius.circular(12)),
              labelColor: Colors.white,
              unselectedLabelColor: subtextColor,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: AppStrings.get('team', lang)),
                Tab(text: AppStrings.get('leaderboard', lang)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTeamTab(cardColor, textColor, subtextColor, shadowColor, lang, isDark),
          _buildLeaderboardTab(cardColor, textColor, subtextColor, shadowColor, lang),
        ],
      ),
    );
  }

  Widget _buildTeamTab(Color cardColor, Color textColor, Color subtextColor, Color shadowColor, String lang, bool isDark) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _team.length,
        itemBuilder: (context, index) {
          final member = _team[index];
          String statusText = member['status'] == 'On Shift' ? AppStrings.get('on_shift', lang)
              : member['status'] == 'Off Today' ? AppStrings.get('off_today', lang)
              : AppStrings.get('upcoming', lang);
          Color statusColor = member['status'] == 'On Shift' ? Colors.green : (member['status'] == 'Off Today' ? Colors.grey : Colors.orange);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(radius: 28, backgroundImage: AssetImage(member['avatar'])),
                          Positioned(bottom: 0, right: 0, child: Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: cardColor, width: 2)),
                          )),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                            Text(member['role'], style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF00695C))),
                            const SizedBox(height: 4),
                            Row(children: [
                              _buildStatChip('${member['horses']} 🐴', subtextColor, isDark),
                              const SizedBox(width: 6),
                              _buildStatChip('${member['tasks']} ${AppStrings.get('tasks', lang)}', subtextColor, isDark),
                              const SizedBox(width: 6),
                              _buildStatChip(member['experience'], subtextColor, isDark),
                            ]),
                          ],
                        ),
                      ),
                      Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(statusText, style: GoogleFonts.poppins(fontSize: 9, color: statusColor, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        Icon(Icons.phone, color: const Color(0xFF00695C), size: 18),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String text, Color subtextColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: subtextColor.withOpacity(isDark ? 0.15 : 0.08), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 9, color: subtextColor)),
    );
  }

  Widget _buildLeaderboardTab(Color cardColor, Color textColor, Color subtextColor, Color shadowColor, String lang) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final entry = _leaderboard[index];
          bool isTop3 = index < 3;
          Color rankColor = index == 0 ? Colors.amber : (index == 1 ? Colors.grey : (index == 2 ? Colors.brown : subtextColor));

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isTop3 ? Border.all(color: rankColor.withOpacity(0.3)) : null,
                    boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: rankColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Center(child: Text(entry['badge'], style: const TextStyle(fontSize: 16))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                            Row(children: [
                              Text('${entry['tasksCompleted']} ${AppStrings.get('tasks', lang)}', style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                              Text(' • ', style: GoogleFonts.poppins(color: subtextColor)),
                              Text('🔥 ${entry['streak']}d', style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange)),
                            ]),
                          ],
                        ),
                      ),
                      Text('${entry['points']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: rankColor)),
                      Text(' pts', style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
