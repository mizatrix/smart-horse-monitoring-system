
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_horse/services/mock_data_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.1);

    final dayLetterKeys = ['day_m', 'day_t', 'day_w', 'day_th', 'day_f', 'day_s', 'day_su'];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('wellness_statistics', lang),
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                Text(AppStrings.get('overall_health', lang), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 20),
                
                // Pie Chart Section
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: stableCount.toDouble(),
                          title: '${((stableCount / total) * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: warningCount.toDouble(),
                          title: '${((warningCount / total) * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.redAccent,
                          value: criticalCount.toDouble(),
                          title: '${((criticalCount / total) * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                 const SizedBox(height: 20),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     _buildLegendItem(AppStrings.get('stable_status', lang), Colors.green, stableCount, textColor),
                     _buildLegendItem(AppStrings.get('warning', lang), Colors.orange, warningCount, textColor),
                     _buildLegendItem(AppStrings.get('critical', lang), Colors.redAccent, criticalCount, textColor),
                   ],
                 ),

                const SizedBox(height: 40),
                Text(AppStrings.get('vital_trends', lang), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 15),
                
                // Bar Chart
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 5)),
                    ],
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
                              if (value.toInt() < dayLetterKeys.length) {
                                 return Text(AppStrings.get(dayLetterKeys[value.toInt()], lang), style: GoogleFonts.poppins(color: subtextColor, fontSize: 10));
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
                              toY: 35.0 + (index % 3) * 5,
                              color: const Color(0xFFD2B48C),
                              width: 15,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, Color textColor) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text('$label ($count)', style: GoogleFonts.poppins(color: textColor.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }
}
