
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class FacilityMapScreen extends StatefulWidget {
  const FacilityMapScreen({super.key});

  @override
  State<FacilityMapScreen> createState() => _FacilityMapScreenState();
}

class _FacilityMapScreenState extends State<FacilityMapScreen> {
  int? _selectedStall;

  List<Map<String, dynamic>> _getStalls(String lang) => [
    {'id': 'A1', 'horse': 'Thunder 5', 'status': AppStrings.get('occupied', lang), 'temp': '22°C', 'water': '85%'},
    {'id': 'A2', 'horse': 'Spirit 3', 'status': AppStrings.get('occupied', lang), 'temp': '21°C', 'water': '92%'},
    {'id': 'A3', 'horse': null, 'status': AppStrings.get('available', lang), 'temp': '20°C', 'water': '100%'},
    {'id': 'A4', 'horse': 'Luna 7', 'status': AppStrings.get('occupied', lang), 'temp': '23°C', 'water': '78%'},
    {'id': 'B1', 'horse': 'Bella 2', 'status': AppStrings.get('occupied', lang), 'temp': '22°C', 'water': '88%'},
    {'id': 'B2', 'horse': null, 'status': AppStrings.get('maintenance', lang), 'temp': '–', 'water': '–'},
    {'id': 'B3', 'horse': 'Charlie 4', 'status': AppStrings.get('occupied', lang), 'temp': '21°C', 'water': '95%'},
    {'id': 'B4', 'horse': 'Rocky 9', 'status': AppStrings.get('occupied', lang), 'temp': '22°C', 'water': '81%'},
    {'id': 'C1', 'horse': 'Max 6', 'status': AppStrings.get('occupied', lang), 'temp': '23°C', 'water': '90%'},
    {'id': 'C2', 'horse': null, 'status': AppStrings.get('available', lang), 'temp': '20°C', 'water': '100%'},
    {'id': 'C3', 'horse': 'Daisy 8', 'status': AppStrings.get('occupied', lang), 'temp': '22°C', 'water': '87%'},
    {'id': 'C4', 'horse': 'Apollo 12', 'status': AppStrings.get('occupied', lang), 'temp': '21°C', 'water': '93%'},
  ];

  List<Map<String, dynamic>> _getPaddocks(String lang) => [
    {'name': '${AppStrings.get('paddock', lang)} A', 'size': '2 ${lang == "ar" ? "هكتار" : "hectares"}', 'horses': 4, 'condition': lang == 'ar' ? 'ممتاز' : 'Excellent', 'color': Colors.green},
    {'name': '${AppStrings.get('paddock', lang)} B', 'size': '1.5 ${lang == "ar" ? "هكتار" : "hectares"}', 'horses': 3, 'condition': lang == 'ar' ? 'جيد' : 'Good', 'color': Colors.lightGreen},
    {'name': '${AppStrings.get('arena', lang)}', 'size': '60x20m', 'horses': 2, 'condition': lang == 'ar' ? 'ممتاز' : 'Excellent', 'color': const Color(0xFFD2B48C)},
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

    final stalls = _getStalls(lang);
    final paddocks = _getPaddocks(lang);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppStrings.get('facility_map', lang), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legend
            Row(children: [
              _buildLegendDot(Colors.green, AppStrings.get('occupied', lang)),
              const SizedBox(width: 12),
              _buildLegendDot(Colors.grey, AppStrings.get('empty', lang)),
              const SizedBox(width: 12),
              _buildLegendDot(Colors.orange, AppStrings.get('maint', lang)),
            ]),
            const SizedBox(height: 16),

            // Barn Layout
            Text(AppStrings.get('barn_layout', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 6),
            Text(AppStrings.get('tap_stall_details', lang), style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.9),
              itemCount: stalls.length,
              itemBuilder: (context, index) {
                final stall = stalls[index];
                final isSelected = _selectedStall == index;
                Color statusColor = stall['horse'] != null ? Colors.green : (stall['status'] == AppStrings.get('maintenance', lang) ? Colors.orange : Colors.grey);

                return GestureDetector(
                  onTap: () => setState(() => _selectedStall = isSelected ? null : index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00695C).withOpacity(isDark ? 0.3 : 0.1) : cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? const Color(0xFF00695C) : statusColor.withOpacity(0.3), width: isSelected ? 2 : 1),
                      boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF00695C).withOpacity(0.15), blurRadius: 8)] : [BoxShadow(color: shadowColor, blurRadius: 4)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(stall['id'], style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                        const SizedBox(height: 3),
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                        const SizedBox(height: 3),
                        Text(stall['horse'] ?? '—', style: GoogleFonts.poppins(fontSize: 9, color: subtextColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Detail Card
            if (_selectedStall != null) ...[
              const SizedBox(height: 16),
              _buildStallDetail(stalls[_selectedStall!], cardColor, textColor, subtextColor, lang),
            ],

            const SizedBox(height: 25),

            // Outdoor Zones
            Text(AppStrings.get('outdoor_zones', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 12),
            ...paddocks.map((p) => _buildPaddockCard(p, cardColor, textColor, subtextColor, shadowColor, lang)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
    ]);
  }

  Widget _buildStallDetail(Map<String, dynamic> stall, Color cardColor, Color textColor, Color subtextColor, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00695C).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('${AppStrings.get('stall', lang)} ${stall['id']}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: (stall['horse'] != null ? Colors.green : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(stall['status'], style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: stall['horse'] != null ? Colors.green : Colors.grey)),
            ),
          ]),
          const Divider(height: 18),
          if (stall['horse'] != null) _buildDetailRow(Icons.pets, AppStrings.get('horse_label', lang), stall['horse'], textColor, subtextColor),
          _buildDetailRow(Icons.thermostat, AppStrings.get('temp_label', lang), stall['temp'], textColor, subtextColor),
          _buildDetailRow(Icons.water_drop, AppStrings.get('water_label', lang), stall['water'], textColor, subtextColor),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: const Color(0xFF00695C)),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.poppins(fontSize: 12, color: subtextColor)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
      ]),
    );
  }

  Widget _buildPaddockCard(Map<String, dynamic> p, Color cardColor, Color textColor, Color subtextColor, Color shadowColor, String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: (p['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.park, color: p['color'], size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor, fontSize: 14)),
            Text('${p['size']} • ${p['horses']} ${AppStrings.get('horses', lang)}', style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: (p['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(p['condition'], style: GoogleFonts.poppins(fontSize: 10, color: p['color'], fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}
