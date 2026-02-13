
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class VetRecordsScreen extends StatefulWidget {
  const VetRecordsScreen({super.key});

  @override
  State<VetRecordsScreen> createState() => _VetRecordsScreenState();
}

class _VetRecordsScreenState extends State<VetRecordsScreen> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _upcomingAppointments = [
    {'horse': 'Thunder 5', 'type': 'Annual Vaccination', 'vet': 'Dr. Sarah Williams', 'date': 'Feb 15, 2026', 'time': '10:00 AM', 'details': 'West Nile, Rabies, Tetanus booster. Bring vaccination passport.', 'priority': 'High'},
    {'horse': 'Spirit 3', 'type': 'Dental Float', 'vet': 'Dr. Ahmed Hassan', 'date': 'Feb 18, 2026', 'time': '2:00 PM', 'details': 'Routine dental filing. Fast 4 hours before appointment.', 'priority': 'Medium'},
    {'horse': 'Luna 7', 'type': 'Lameness Check', 'vet': 'Dr. Sarah Williams', 'date': 'Feb 20, 2026', 'time': '9:00 AM', 'details': 'Follow-up on left foreleg lameness observed last week.', 'priority': 'High'},
  ];

  final List<Map<String, dynamic>> _pastRecords = [
    {'horse': 'Bella 2', 'type': 'Deworming', 'vet': 'Dr. Omar Farouk', 'date': 'Feb 1, 2026', 'result': 'Completed — Ivermectin administered', 'notes': 'Fecal egg count was 450 EPG. Schedule recheck in 14 days.', 'attachments': 2, 'followUp': 'Feb 15, 2026'},
    {'horse': 'Charlie 4', 'type': 'Wound Treatment', 'vet': 'Dr. Sarah Williams', 'date': 'Jan 28, 2026', 'result': 'Healing well — sutures to be removed in 5 days', 'notes': 'Laceration on right hindquarter. Keep dry and clean. Antibiotic course completed.', 'attachments': 3, 'followUp': 'Feb 3, 2026'},
    {'horse': 'Rocky 9', 'type': 'Pre-purchase Exam', 'vet': 'Dr. Ahmed Hassan', 'date': 'Jan 20, 2026', 'result': 'Passed — no significant findings', 'notes': 'Full 5-stage vetting completed. X-rays clear. Blood work normal.', 'attachments': 5, 'followUp': null},
    {'horse': 'Max 6', 'type': 'Colic Assessment', 'vet': 'Dr. Omar Farouk', 'date': 'Jan 15, 2026', 'result': 'Resolved — impaction cleared with mineral oil', 'notes': 'Monitor feed intake for 48h. Increase water access. Reduce grain temporarily.', 'attachments': 1, 'followUp': 'Jan 17, 2026'},
    {'horse': 'Daisy 8', 'type': 'Annual Health Check', 'vet': 'Dr. Sarah Williams', 'date': 'Jan 10, 2026', 'result': 'All clear — excellent condition', 'notes': 'Weight 520 kg, BCS 5/9, teeth good, feet good. Vaccinations up to date.', 'attachments': 4, 'followUp': null},
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
    final infoBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppStrings.get('veterinary_records', lang), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: widget)),
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF00695C), size: 20),
                  const SizedBox(width: 8),
                  Text(AppStrings.get('upcoming_appointments', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                ]),
                const SizedBox(height: 12),
                ..._upcomingAppointments.map((apt) => _buildAppointmentCard(apt, cardColor, textColor, subtextColor, shadowColor, infoBg, lang)),
                const SizedBox(height: 25),

                Row(children: [
                  const Icon(Icons.history, color: Color(0xFF8D6E63), size: 20),
                  const SizedBox(width: 8),
                  Text(AppStrings.get('treatment_history', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                ]),
                const SizedBox(height: 12),
                ..._pastRecords.asMap().entries.map((entry) => _buildPastRecordCard(entry.key, entry.value, cardColor, textColor, subtextColor, shadowColor, lang)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get('upcoming_appointments', lang)), duration: const Duration(seconds: 1)));
        },
        backgroundColor: const Color(0xFF00695C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(AppStrings.get('new_record', lang), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt, Color cardColor, Color textColor, Color subtextColor, Color shadowColor, Color infoBg, String lang) {
    Color priorityColor = apt['priority'] == 'High' ? Colors.red : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: priorityColor.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.medical_services, color: Color(0xFF00695C), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt['type'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                Text(apt['horse'], style: GoogleFonts.poppins(color: subtextColor, fontSize: 12)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(apt['priority'], style: GoogleFonts.poppins(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.person_outline, size: 14, color: subtextColor),
            const SizedBox(width: 4),
            Text(apt['vet'], style: GoogleFonts.poppins(fontSize: 12, color: subtextColor)),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 14, color: subtextColor),
            const SizedBox(width: 4),
            Text('${apt['date']} at ${apt['time']}', style: GoogleFonts.poppins(fontSize: 12, color: subtextColor)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: infoBg, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.info_outline, size: 14, color: subtextColor),
              const SizedBox(width: 6),
              Flexible(child: Text(apt['details'], style: GoogleFonts.poppins(fontSize: 11, color: subtextColor))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPastRecordCard(int index, Map<String, dynamic> record, Color cardColor, Color textColor, Color subtextColor, Color shadowColor, String lang) {
    bool isExpanded = _expandedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: isExpanded ? 12 : 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF8D6E63), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD2B48C), width: 2))),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record['type'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
                  Text('${record['horse']} • ${record['date']}', style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
                ],
              )),
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (record['attachments'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.attach_file, size: 12, color: Colors.blue),
                      Text('${record['attachments']}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue)),
                    ]),
                  ),
                const SizedBox(width: 6),
                AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 300), child: Icon(Icons.expand_more, size: 20, color: subtextColor)),
              ]),
            ]),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12, left: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.withOpacity(0.15))),
                      child: Row(children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Flexible(child: Text(record['result'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[800]))),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.person_outline, size: 14, color: subtextColor),
                      const SizedBox(width: 4),
                      Text(record['vet'], style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
                    ]),
                    const SizedBox(height: 4),
                    Text(record['notes'], style: GoogleFonts.poppins(fontSize: 11, color: subtextColor, height: 1.5)),
                    if (record['followUp'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFD2B48C).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.event, size: 12, color: Color(0xFF8D6E63)),
                          const SizedBox(width: 4),
                          Text('${AppStrings.get('follow_up', lang)}: ${record['followUp']}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF8D6E63), fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
