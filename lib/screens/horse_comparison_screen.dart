
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class HorseComparisonScreen extends StatefulWidget {
  const HorseComparisonScreen({super.key});

  @override
  State<HorseComparisonScreen> createState() => _HorseComparisonScreenState();
}

class _HorseComparisonScreenState extends State<HorseComparisonScreen> with SingleTickerProviderStateMixin {
  Horse? _horseA;
  Horse? _horseB;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectHorse(int slot) {
    final mockService = Provider.of<MockDataService>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final lang = localeProvider.locale.languageCode;

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.get('select_horse', lang), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 12),
            ...mockService.horses.map((horse) => ListTile(
              leading: CircleAvatar(backgroundImage: AssetImage(horse.imageUrl)),
              title: Text(horse.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor)),
              subtitle: Text('${horse.breed} • ${horse.age} ${AppStrings.get('yrs', lang)}', style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey)),
              onTap: () {
                setState(() {
                  if (slot == 0) _horseA = horse;
                  else _horseB = horse;
                  if (_horseA != null && _horseB != null) _animController.forward(from: 0);
                });
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
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
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppStrings.get('compare_horses', lang), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Horse Selection
            Row(
              children: [
                Expanded(child: _buildSelectorCard(0, _horseA, cardColor, textColor, subtextColor, lang)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('VS', style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                Expanded(child: _buildSelectorCard(1, _horseB, cardColor, textColor, subtextColor, lang)),
              ],
            ),
            const SizedBox(height: 20),

            if (_horseA != null && _horseB != null) ...[
              // Comparison Bars
              _buildComparisonSection(AppStrings.get('heart_rate', lang), _horseA!.currentHeartRate, _horseB!.currentHeartRate, 80, Colors.red, cardColor, textColor, subtextColor),
              _buildComparisonSection(AppStrings.get('temperature', lang), _horseA!.currentTemp, _horseB!.currentTemp, 42, Colors.orange, cardColor, textColor, subtextColor),
              _buildComparisonSection(AppStrings.get('hydration_label', lang), _horseA!.hydrationLevel, _horseB!.hydrationLevel, 100, Colors.blue, cardColor, textColor, subtextColor),
              _buildComparisonSection(AppStrings.get('stress_label', lang), _horseA!.stressIndex.toDouble(), _horseB!.stressIndex.toDouble(), 100, Colors.purple, cardColor, textColor, subtextColor),
              _buildComparisonSection(AppStrings.get('respiration', lang), _horseA!.currentRespiration.toDouble(), _horseB!.currentRespiration.toDouble(), 30, Colors.teal, cardColor, textColor, subtextColor),
              const SizedBox(height: 20),

              //  Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF00695C).withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.get('summary', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildSummaryColumn(_horseA!, textColor, subtextColor, lang)),
                        Container(width: 1, height: 200, color: subtextColor.withOpacity(0.2)),
                        Expanded(child: _buildSummaryColumn(_horseB!, textColor, subtextColor, lang)),
                      ],
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.compare_arrows, size: 60, color: subtextColor.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text(AppStrings.get('select_two_horses', lang), style: GoogleFonts.poppins(color: subtextColor, fontSize: 14)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorCard(int slot, Horse? horse, Color cardColor, Color textColor, Color subtextColor, String lang) {
    return GestureDetector(
      onTap: () => _selectHorse(slot),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: horse != null ? const Color(0xFF00695C).withOpacity(0.3) : subtextColor.withOpacity(0.15)),
        ),
        child: horse != null
            ? Column(children: [
                CircleAvatar(radius: 30, backgroundImage: AssetImage(horse.imageUrl)),
                const SizedBox(height: 8),
                Text(horse.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                Text('${horse.breed} • ${horse.age} ${AppStrings.get('yrs', lang)}', style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
              ])
            : Column(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: subtextColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.add, color: subtextColor, size: 28),
                ),
                const SizedBox(height: 8),
                Text(AppStrings.get('select_horse', lang), style: GoogleFonts.poppins(color: subtextColor, fontSize: 12)),
              ]),
      ),
    );
  }

  Widget _buildComparisonSection(String label, double valueA, double valueB, double max, Color color, Color cardColor, Color textColor, Color subtextColor) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        double aWidth = (valueA / max).clamp(0.0, 1.0) * _animController.value;
        double bWidth = (valueB / max).clamp(0.0, 1.0) * _animController.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: textColor)),
              const SizedBox(height: 8),
              Row(children: [
                Text(_horseA!.name, style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(children: [
                    Container(height: 8, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                    FractionallySizedBox(widthFactor: aWidth, child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)))),
                  ]),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 40, child: Text(valueA.toStringAsFixed(1), style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.end)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Text(_horseB!.name, style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(children: [
                    Container(height: 8, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                    FractionallySizedBox(widthFactor: bWidth, child: Container(height: 8, decoration: BoxDecoration(color: color.withOpacity(0.6), borderRadius: BorderRadius.circular(4)))),
                  ]),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 40, child: Text(valueB.toStringAsFixed(1), style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.bold, color: color.withOpacity(0.7)), textAlign: TextAlign.end)),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryColumn(Horse horse, Color textColor, Color subtextColor, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(radius: 22, backgroundImage: AssetImage(horse.imageUrl)),
          const SizedBox(height: 6),
          Text(horse.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
          const SizedBox(height: 10),
          _buildSummaryRow(AppStrings.get('breed', lang), horse.breed, subtextColor),
          _buildSummaryRow(AppStrings.get('age', lang), '${horse.age} ${AppStrings.get('yrs', lang)}', subtextColor),
          _buildSummaryRow(AppStrings.get('status', lang), horse.status, subtextColor),
          _buildSummaryRow(AppStrings.get('location', lang), horse.location, subtextColor),
          _buildSummaryRow(AppStrings.get('gait', lang), horse.gaitAnalysis, subtextColor),
          _buildSummaryRow(AppStrings.get('vacc', lang), horse.vaccinationStatus, subtextColor),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(label, style: GoogleFonts.poppins(fontSize: 10, color: subtextColor))),
        Flexible(child: Text(value, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: subtextColor), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
