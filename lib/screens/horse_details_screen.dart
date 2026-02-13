
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';
import 'add_edit_horse_screen.dart';

class HorseDetailsScreen extends StatefulWidget {
  final Horse horse;
  const HorseDetailsScreen({super.key, required this.horse});

  @override
  State<HorseDetailsScreen> createState() => _HorseDetailsScreenState();
}

class _HorseDetailsScreenState extends State<HorseDetailsScreen>
    with TickerProviderStateMixin {
  bool isFavorite = false;
  late AnimationController _vitalAnimController;
  late Animation<double> _vitalProgress;

  @override
  void initState() {
    super.initState();
    _vitalAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _vitalProgress = CurvedAnimation(
      parent: _vitalAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _vitalAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horse = widget.horse;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.06);

    Color statusColor = horse.status == 'Critical'
        ? Colors.red
        : (horse.status == 'Warning' ? Colors.orange : Colors.green);

    String statusText;
    switch (horse.status) {
      case 'Critical': statusText = AppStrings.get('critical', lang); break;
      case 'Warning': statusText = AppStrings.get('warning', lang); break;
      default: statusText = AppStrings.get('healthy', lang);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF8D6E63),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.white,
                ),
                onPressed: () => setState(() => isFavorite = !isFavorite),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditHorseScreen(horse: horse),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: horse.id,
                    child: Image.asset(horse.imageUrl, fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          horse.name,
                          style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${horse.breed} • ${horse.gender} • ${horse.age} ${AppStrings.get('yrs', lang)}',
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusText,
                                style: GoogleFonts.poppins(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Cards
                  Row(
                    children: [
                      _buildInfoTag(Icons.location_on, horse.location, const Color(0xFF00695C), isDark),
                      const SizedBox(width: 8),
                      _buildInfoTag(Icons.memory, horse.microchipId, Colors.blueGrey, isDark),
                      const SizedBox(width: 8),
                      _buildInfoTag(Icons.scale, '${horse.weight.toStringAsFixed(0)} kg', Colors.brown, isDark),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Vitals Section
                  Text(AppStrings.get('vitals', lang), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),
                  AnimatedBuilder(
                    animation: _vitalProgress,
                    builder: (context, child) {
                      return Row(
                        children: [
                          Expanded(child: _buildAnimatedVitalCard(
                            AppStrings.get('heart_rate', lang), horse.currentHeartRate,
                            AppStrings.get('bpm', lang), Icons.monitor_heart, Colors.redAccent,
                            _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildAnimatedVitalCard(
                            AppStrings.get('temperature', lang), horse.currentTemp,
                            '°C', Icons.thermostat, Colors.orangeAccent,
                            _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildAnimatedVitalCard(
                            AppStrings.get('respiration', lang), horse.currentRespiration.toDouble(),
                            '/min', Icons.air, Colors.cyan,
                            _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor,
                          )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _vitalProgress,
                    builder: (context, child) {
                      return Row(
                        children: [
                          Expanded(child: _buildAnimatedVitalCard(
                            lang == 'ar' ? 'الترطيب' : 'Hydration', horse.hydrationLevel,
                            '%', Icons.water_drop, Colors.blueAccent,
                            _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildAnimatedVitalCard(
                            lang == 'ar' ? 'التوتر' : 'Stress', horse.stressIndex.toDouble(),
                            '/100', Icons.psychology, Colors.purple,
                            _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildGaitCard(horse.gaitScore, cardColor, textColor, subtextColor, shadowColor, lang)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 25),

                  // Heart Rate Chart
                  Text('${AppStrings.get('heart_rate', lang)} (24h)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10)],
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(color: (isDark ? Colors.grey[700]! : Colors.grey).withOpacity(0.1), strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 6,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('${value.toInt()}h', style: GoogleFonts.poppins(color: subtextColor, fontSize: 9)),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: horse.heartRateHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                            isCurved: true,
                            color: Colors.redAccent,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.redAccent.withOpacity(0.2), Colors.redAccent.withOpacity(0.0)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Health Info Section
                  Text(lang == 'ar' ? 'السجل الصحي' : 'Health Record', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  _buildHealthInfoRow(Icons.verified_user, AppStrings.get('vaccination', lang), horse.vaccinationStatus,
                    horse.vaccinationStatus == 'Up to date' ? Colors.green : (horse.vaccinationStatus == 'Due Soon' ? Colors.orange : Colors.red), cardColor, textColor, subtextColor, shadowColor),
                  _buildHealthInfoRow(Icons.calendar_today, lang == 'ar' ? 'آخر زيارة بيطرية' : 'Last Vet Visit', horse.lastVetVisit, const Color(0xFF00695C), cardColor, textColor, subtextColor, shadowColor),
                  _buildHealthInfoRow(Icons.directions_walk, lang == 'ar' ? 'تقييم المشية' : 'Gait Assessment', horse.gaitScore,
                    horse.gaitScore == 'Normal' ? Colors.green : Colors.orange, cardColor, textColor, subtextColor, shadowColor),
                  _buildHealthInfoRow(Icons.location_on, AppStrings.get('location', lang), horse.location, const Color(0xFF8D6E63), cardColor, textColor, subtextColor, shadowColor),

                  const SizedBox(height: 25),

                  // Action Buttons
                  Text(lang == 'ar' ? 'الإجراءات' : 'Actions', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildActionButton(lang == 'ar' ? 'جدولة\nزيارة' : 'Schedule\nVisit', Icons.calendar_today, const Color(0xFF00695C), isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(lang == 'ar' ? 'تعيين\nتنبيه' : 'Set\nAlert', Icons.notifications_active, Colors.orange, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(lang == 'ar' ? 'معلومات\nالمالك' : 'Owner\nInfo', Icons.person, const Color(0xFF8D6E63), isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(lang == 'ar' ? 'حذف\nالحصان' : 'Delete\nHorse', Icons.delete_outline, Colors.red, isDark)),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedVitalCard(String label, double value, String unit, IconData icon, Color color,
      double animProgress, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    final displayValue = (value * animProgress);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            displayValue.toStringAsFixed(value > 100 ? 0 : 1),
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text(unit, style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: subtextColor)),
        ],
      ),
    );
  }

  Widget _buildGaitCard(String gaitScore, Color cardColor, Color textColor, Color subtextColor, Color shadowColor, String lang) {
    Color color = gaitScore == 'Normal' ? Colors.green : (gaitScore == 'Slight Lameness' ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(Icons.directions_walk, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            gaitScore == 'Normal' ? '✓' : '!',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(lang == 'ar' ? 'المشية' : 'Gait', style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
          Text(gaitScore, style: GoogleFonts.poppins(fontSize: 8, color: subtextColor)),
        ],
      ),
    );
  }

  Widget _buildHealthInfoRow(IconData icon, String label, String value, Color color,
      Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(color: subtextColor, fontSize: 13)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, bool isDark) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${label.replaceAll('\n', ' ')} tapped'), duration: const Duration(seconds: 1)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
