
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';
import 'feeding_log_screen.dart';

class StableManagementScreen extends StatefulWidget {
  const StableManagementScreen({super.key});

  @override
  State<StableManagementScreen> createState() => _StableManagementScreenState();
}

class _StableManagementScreenState extends State<StableManagementScreen> {

  List<Map<String, dynamic>> _getDailyOps(String lang) => [
    {'task': AppStrings.get('morning_feed', lang), 'icon': Icons.grass, 'done': true, 'staff': 'Ahmed', 'time': '06:00', 'priority': AppStrings.get('high', lang), 'est': '45 min', 'navigable': true},
    {'task': AppStrings.get('water_trough_check', lang), 'icon': Icons.water_drop, 'done': true, 'staff': 'Omar', 'time': '07:00', 'priority': AppStrings.get('high', lang), 'est': '15 min', 'navigable': false},
    {'task': AppStrings.get('stall_mucking', lang), 'icon': Icons.cleaning_services, 'done': true, 'staff': 'Fatima', 'time': '08:00', 'priority': AppStrings.get('medium', lang), 'est': '90 min', 'navigable': false},
    {'task': AppStrings.get('turnout_paddock', lang), 'icon': Icons.nature_people, 'done': false, 'staff': 'Ahmed', 'time': '09:00', 'priority': AppStrings.get('medium', lang), 'est': '30 min', 'navigable': false},
    {'task': AppStrings.get('afternoon_feed_task', lang), 'icon': Icons.restaurant, 'done': false, 'staff': 'Omar', 'time': '12:00', 'priority': AppStrings.get('high', lang), 'est': '30 min', 'navigable': true},
    {'task': AppStrings.get('equipment_check', lang), 'icon': Icons.build, 'done': false, 'staff': 'Fatima', 'time': '14:00', 'priority': AppStrings.get('low', lang), 'est': '20 min', 'navigable': false},
    {'task': AppStrings.get('evening_feed', lang), 'icon': Icons.dinner_dining, 'done': false, 'staff': 'Ahmed', 'time': '17:00', 'priority': AppStrings.get('high', lang), 'est': '45 min', 'navigable': true},
    {'task': AppStrings.get('night_check', lang), 'icon': Icons.nights_stay, 'done': false, 'staff': 'Omar', 'time': '21:00', 'priority': AppStrings.get('high', lang), 'est': '20 min', 'navigable': false},
  ];

  List<Map<String, dynamic>> _getHealthTasks(String lang) => [
    {'task': AppStrings.get('hoof_inspection', lang), 'icon': Icons.circle_outlined, 'done': true, 'staff': 'Dr. Sarah', 'time': '08:30', 'priority': AppStrings.get('high', lang), 'est': '60 min'},
    {'task': AppStrings.get('grooming', lang), 'icon': Icons.brush, 'done': false, 'staff': 'Fatima', 'time': '10:00', 'priority': AppStrings.get('medium', lang), 'est': '120 min'},
    {'task': AppStrings.get('vitals_monitoring', lang), 'icon': Icons.monitor_heart, 'done': true, 'staff': 'Dr. Ahmed', 'time': '07:00', 'priority': AppStrings.get('high', lang), 'est': '45 min'},
    {'task': AppStrings.get('medication_admin', lang), 'icon': Icons.medication, 'done': false, 'staff': 'Dr. Sarah', 'time': '09:00', 'priority': AppStrings.get('high', lang), 'est': '30 min'},
    {'task': AppStrings.get('wound_dressing', lang), 'icon': Icons.healing, 'done': false, 'staff': 'Dr. Ahmed', 'time': '11:00', 'priority': AppStrings.get('medium', lang), 'est': '25 min'},
  ];

  // Track done state separately
  final List<bool> _dailyDone = [true, true, true, false, false, false, false, false];
  final List<bool> _healthDone = [true, false, true, false, false];

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

    final dailyOps = _getDailyOps(lang);
    final healthTasks = _getHealthTasks(lang);

    int totalTasks = _dailyDone.length + _healthDone.length;
    int completedTasks = _dailyDone.where((d) => d).length + _healthDone.where((d) => d).length;
    double progress = completedTasks / totalTasks;

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
                  Text(AppStrings.get('stable_management', lang), style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 5),
                  Text(AppStrings.get('daily_ops_subtitle', lang), style: GoogleFonts.poppins(color: subtextColor, fontSize: 13)),
                  const SizedBox(height: 20),

                  // Progress Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF4DB6AC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: const Color(0xFF00695C).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 65, height: 65,
                          child: Stack(fit: StackFit.expand, children: [
                            CircularProgressIndicator(value: progress, strokeWidth: 7, backgroundColor: Colors.white.withOpacity(0.2), color: Colors.white),
                            Center(child: Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                          ]),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.get('todays_progress', lang), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('$completedTasks / $totalTasks ${AppStrings.get('tasks_completed', lang)}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 8),
                              Row(children: [
                                _buildMiniStat('${_dailyDone.where((d) => d).length}/${_dailyDone.length}', AppStrings.get('ops', lang)),
                                const SizedBox(width: 12),
                                _buildMiniStat('${_healthDone.where((d) => d).length}/${_healthDone.length}', AppStrings.get('health', lang)),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Heat Stress
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.deepOrange, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${AppStrings.get('heat_stress_index', lang)}: 128', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange)),
                              Text(AppStrings.get('moderate_risk', lang), style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text(AppStrings.get('caution', lang), style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Daily Operations
                  Text(AppStrings.get('daily_operations', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  ...dailyOps.asMap().entries.map((e) => _buildTaskItem(e.key, e.value, _dailyDone, cardColor, textColor, subtextColor, shadowColor)),
                  const SizedBox(height: 25),

                  // Health Maintenance
                  Text(AppStrings.get('health_maintenance', lang), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  ...healthTasks.asMap().entries.map((e) => _buildTaskItem(e.key, e.value, _healthDone, cardColor, textColor, subtextColor, shadowColor)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
      ]),
    );
  }

  Widget _buildTaskItem(int index, Map<String, dynamic> task, List<bool> doneList, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    bool isDone = doneList[index];
    Color priorityColor = task['priority'] == 'High' || task['priority'] == 'عالية' ? Colors.red : (task['priority'] == 'Medium' || task['priority'] == 'متوسطة' ? Colors.orange : Colors.green);

    return GestureDetector(
      onTap: () {
        if (task['navigable'] == true) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedingLogScreen()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDone ? Colors.green.withOpacity(0.1) : const Color(0xFF00695C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(task['icon'], color: isDone ? Colors.green : const Color(0xFF00695C), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(task['task'], style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 13,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Colors.grey : textColor,
                      ), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(task['priority'], style: GoogleFonts.poppins(fontSize: 8, color: priorityColor, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  Row(children: [
                    Icon(Icons.person_outline, size: 12, color: subtextColor),
                    const SizedBox(width: 2),
                    Text(task['staff'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                    Text(' • ', style: GoogleFonts.poppins(color: subtextColor)),
                    Icon(Icons.access_time, size: 12, color: subtextColor),
                    const SizedBox(width: 2),
                    Text(task['time'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                    Text(' • ', style: GoogleFonts.poppins(color: subtextColor)),
                    Text(task['est'], style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
                  ]),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => doneList[index] = !isDone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: isDone ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? Colors.green : Colors.grey[300]!, width: 2),
                ),
                child: isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
