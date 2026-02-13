
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_horse/services/mock_data_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../services/theme_provider.dart';
import '../../services/locale_provider.dart';
import '../../services/app_strings.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;
    final criticalCount = mockService.criticalCount;
    final warningCount = mockService.warningCount;
    final stableCount = mockService.stableCount;
    final total = mockService.horses.length;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.06);

    final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: AnimationLimiter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Header
                  Text(
                    AppStrings.get('statistics', lang),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppStrings.get('health_overview', lang),
                    style: GoogleFonts.poppins(color: subtextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 25),

                  // Summary Cards Row
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard(AppStrings.get('total', lang), '$total', Icons.pets, const Color(0xFF00695C), cardColor, textColor, subtextColor, shadowColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSummaryCard(AppStrings.get('stable_status', lang), '$stableCount', Icons.check_circle_outline, Colors.green, cardColor, textColor, subtextColor, shadowColor)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSummaryCard(AppStrings.get('alert', lang), '${warningCount + criticalCount}', Icons.warning_amber, Colors.orange, cardColor, textColor, subtextColor, shadowColor)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Pie Chart
                  Text(AppStrings.get('health_distribution', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 35,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: stableCount.toDouble(),
                                  title: '${((stableCount / total) * 100).toStringAsFixed(0)}%',
                                  radius: 45,
                                  titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.orange,
                                  value: warningCount.toDouble(),
                                  title: '${((warningCount / total) * 100).toStringAsFixed(0)}%',
                                  radius: 45,
                                  titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.redAccent,
                                  value: criticalCount.toDouble(),
                                  title: '${((criticalCount / total) * 100).toStringAsFixed(0)}%',
                                  radius: 55,
                                  titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendRow(AppStrings.get('stable_status', lang), Colors.green, stableCount, textColor),
                              const SizedBox(height: 12),
                              _buildLegendRow(AppStrings.get('warning', lang), Colors.orange, warningCount, textColor),
                              const SizedBox(height: 12),
                              _buildLegendRow(AppStrings.get('critical', lang), Colors.redAccent, criticalCount, textColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Temperature Trends
                  Text(AppStrings.get('temp_trends', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
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
                          getDrawingHorizontalLine: (value) => FlLine(color: (isDark ? Colors.grey[800]! : Colors.grey).withOpacity(0.1), strokeWidth: 1),
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
                            spots: List.generate(24, (i) => FlSpot(i.toDouble(), 37.2 + (i % 5) * 0.15 + (i > 12 ? 0.3 : 0))),
                            isCurved: true,
                            color: Colors.orangeAccent,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.orangeAccent.withOpacity(0.2), Colors.orangeAccent.withOpacity(0.0)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Weekly Heart Rate
                  Text(AppStrings.get('weekly_avg_hr', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10)],
                    ),
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < dayKeys.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(AppStrings.get(dayKeys[value.toInt()], lang), style: GoogleFonts.poppins(color: subtextColor, fontSize: 10)),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: 32.0 + (index * 2.5) + (index % 3 == 0 ? 5 : 0),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD2B48C), Color(0xFF00695C)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Activity Log
                  Text(AppStrings.get('recent_activity', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),
                  _buildActivityItem(AppStrings.get('act_health_check', lang), AppStrings.get('act_health_check_sub', lang), Icons.check_circle, Colors.green, AppStrings.get('time_2h', lang), cardColor, textColor, subtextColor, shadowColor, isDark),
                  _buildActivityItem(AppStrings.get('act_alert_resolved', lang), AppStrings.get('act_alert_sub', lang), Icons.healing, Colors.blue, AppStrings.get('time_4h', lang), cardColor, textColor, subtextColor, shadowColor, isDark),
                  _buildActivityItem(AppStrings.get('act_vet_scheduled', lang), AppStrings.get('act_vet_sub', lang), Icons.calendar_today, Colors.purple, AppStrings.get('time_6h', lang), cardColor, textColor, subtextColor, shadowColor, isDark),
                  _buildActivityItem(AppStrings.get('act_feeding', lang), AppStrings.get('act_feeding_sub', lang), Icons.restaurant, Colors.orange, AppStrings.get('time_8h', lang), cardColor, textColor, subtextColor, shadowColor, isDark),
                  _buildActivityItem(AppStrings.get('act_new_horse', lang), AppStrings.get('act_new_horse_sub', lang), Icons.add_circle_outline, const Color(0xFF00695C), AppStrings.get('time_1d', lang), cardColor, textColor, subtextColor, shadowColor, isDark),

                  const SizedBox(height: 30),

                  // Monthly Summary
                  Text(AppStrings.get('monthly_summary', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildMonthCard(AppStrings.get('vet_visits', lang), '12', Icons.medical_services, Colors.blue, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMonthCard(AppStrings.get('feed_cost', lang), '\$2,400', Icons.attach_money, Colors.green, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMonthCard(AppStrings.get('health_checks', lang), '48', Icons.monitor_heart, Colors.red, isDark)),
                    ],
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

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color,
      Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, Color color, int count, Color textColor) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text('$label ($count)', style: GoogleFonts.poppins(fontSize: 12, color: textColor.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color, String time,
      Color cardColor, Color textColor, Color subtextColor, Color shadowColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
        ],
      ),
    );
  }

  Widget _buildMonthCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ],
      ),
    );
  }
}
