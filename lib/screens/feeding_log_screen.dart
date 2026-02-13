
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class FeedingLogScreen extends StatefulWidget {
  const FeedingLogScreen({super.key});

  @override
  State<FeedingLogScreen> createState() => _FeedingLogScreenState();
}

class _FeedingLogScreenState extends State<FeedingLogScreen> {
  List<Map<String, dynamic>> _getFeedingSchedule(String lang) => [
    {'time': '06:00', 'type': AppStrings.get('morning_hay', lang), 'amount': '4 kg', 'calories': '~3,200 kcal', 'staff': 'Ahmed', 'notes': 'Timothy hay mix', 'icon': Icons.grass},
    {'time': '07:30', 'type': AppStrings.get('grain_mix', lang), 'amount': '1.5 kg', 'calories': '~2,100 kcal', 'staff': 'Ahmed', 'notes': 'Oats + barley blend', 'icon': Icons.grain},
    {'time': '08:00', 'type': AppStrings.get('supplements', lang), 'amount': '250 ml', 'calories': '~120 kcal', 'staff': 'Fatima', 'notes': 'Vitamin E + Selenium + Omega-3', 'icon': Icons.medication},
    {'time': '12:00', 'type': AppStrings.get('midday_hay', lang), 'amount': '3 kg', 'calories': '~2,400 kcal', 'staff': 'Omar', 'notes': 'Alfalfa cubes', 'icon': Icons.grass},
    {'time': '14:00', 'type': AppStrings.get('water_check', lang), 'amount': '–', 'calories': '–', 'staff': 'Omar', 'notes': lang == 'ar' ? 'تأكد من 30-50 لتر يومياً' : 'Ensure 30-50L intake daily', 'icon': Icons.water_drop},
    {'time': '17:00', 'type': AppStrings.get('evening_grain', lang), 'amount': '1.5 kg', 'calories': '~2,100 kcal', 'staff': 'Fatima', 'notes': 'Performance feed blend', 'icon': Icons.dinner_dining},
    {'time': '18:30', 'type': AppStrings.get('evening_hay', lang), 'amount': '5 kg', 'calories': '~4,000 kcal', 'staff': 'Ahmed', 'notes': lang == 'ar' ? 'تبن عشبي — مغذي بطيء' : 'Grass hay — slow feeder', 'icon': Icons.grass},
    {'time': '20:00', 'type': AppStrings.get('salt_block', lang), 'amount': 'Ad lib', 'calories': '–', 'staff': 'Omar', 'notes': lang == 'ar' ? 'ملح هيمالايا' : 'Himalayan salt lick', 'icon': Icons.circle},
  ];

  final List<bool> _doneList = [true, true, true, false, false, false, false, false];

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

    final schedule = _getFeedingSchedule(lang);
    int completed = _doneList.where((d) => d).length;
    double progress = completed / _doneList.length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppStrings.get('feeding_log', lang), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD2B48C), Color(0xFF8D6E63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFFD2B48C).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 60, height: 60,
                    child: Stack(fit: StackFit.expand, children: [
                      CircularProgressIndicator(value: progress, strokeWidth: 6, backgroundColor: Colors.white.withOpacity(0.2), color: Colors.white),
                      Center(child: Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                    ]),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.get('daily_feeding_progress', lang), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('$completed / ${_doneList.length} ${AppStrings.get('completed', lang)}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 6),
                        Row(children: [
                          _buildProgressTag('~13,920 kcal', Icons.local_fire_department, Colors.orangeAccent),
                          const SizedBox(width: 8),
                          _buildProgressTag('~15.25 kg', Icons.scale, Colors.white),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schedule List
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: schedule.length,
                  itemBuilder: (context, index) {
                    final item = schedule[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: _buildFeedingItem(item, index, cardColor, textColor, subtextColor, shadowColor, isDark)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildFeedingItem(Map<String, dynamic> item, int index, Color cardColor, Color textColor, Color subtextColor, Color shadowColor, bool isDark) {
    bool isDone = _doneList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: isDone ? null : Border.all(color: (isDark ? Colors.grey[700]! : Colors.grey).withOpacity(0.1)),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDone ? Colors.green.withOpacity(0.1) : const Color(0xFFD2B48C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: [
              Icon(item['icon'], color: isDone ? Colors.green : const Color(0xFF8D6E63), size: 18),
              const SizedBox(height: 2),
              Text(item['time'], style: GoogleFonts.robotoMono(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['type'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: textColor, decoration: isDone ? TextDecoration.lineThrough : null)),
                Row(children: [
                  Text('${item['amount']}', style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
                  if (item['calories'] != '–') ...[
                    Text(' • ', style: GoogleFonts.poppins(color: subtextColor)),
                    Text(item['calories'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange[700])),
                  ],
                ]),
                Row(children: [
                  Icon(Icons.person_outline, size: 12, color: subtextColor),
                  const SizedBox(width: 2),
                  Text(item['staff'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                  Text(' • ', style: GoogleFonts.poppins(color: subtextColor)),
                  Flexible(child: Text(item['notes'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor), overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _doneList[index] = !isDone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? Colors.green : Colors.grey[300]!, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
          ),
        ],
      ),
    );
  }
}
