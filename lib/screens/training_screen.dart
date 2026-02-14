
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedProgram = -1;

  final List<Map<String, dynamic>> _programs = [
    {
      'name': 'Dressage', 'nameAr': 'الترويض',
      'icon': Icons.self_improvement, 'color': const Color(0xFF8D6E63),
      'duration': '12 weeks', 'durationAr': '12 أسبوع',
      'difficulty': 'Advanced', 'difficultyAr': 'متقدم',
      'desc': 'Classical dressage movements and collection exercises',
      'descAr': 'حركات الترويض الكلاسيكية وتمارين التجميع',
      'exercises': [
        {'name': 'Half-Pass', 'nameAr': 'نصف تمريرة', 'sets': '4x', 'done': true},
        {'name': 'Piaffe', 'nameAr': 'بيافيه', 'sets': '3x', 'done': true},
        {'name': 'Passage', 'nameAr': 'باساج', 'sets': '3x', 'done': false},
        {'name': 'Flying Change', 'nameAr': 'تغيير طائر', 'sets': '5x', 'done': false},
      ],
      'progress': 0.65,
    },
    {
      'name': 'Show Jumping', 'nameAr': 'قفز الحواجز',
      'icon': Icons.height, 'color': Colors.blueAccent,
      'duration': '8 weeks', 'durationAr': '8 أسابيع',
      'difficulty': 'Intermediate', 'difficultyAr': 'متوسط',
      'desc': 'Jump technique, course navigation, and timing',
      'descAr': 'تقنية القفز والتنقل في المسار والتوقيت',
      'exercises': [
        {'name': 'Cavaletti', 'nameAr': 'كافاليتي', 'sets': '6x', 'done': true},
        {'name': 'Oxer Jumps', 'nameAr': 'قفزات أوكسر', 'sets': '4x', 'done': true},
        {'name': 'Grid Work', 'nameAr': 'عمل الشبكة', 'sets': '3x', 'done': true},
        {'name': 'Course Run', 'nameAr': 'جولة المسار', 'sets': '2x', 'done': false},
      ],
      'progress': 0.78,
    },
    {
      'name': 'Endurance', 'nameAr': 'التحمل',
      'icon': Icons.timer, 'color': Colors.green,
      'duration': '16 weeks', 'durationAr': '16 أسبوع',
      'difficulty': 'Advanced', 'difficultyAr': 'متقدم',
      'desc': 'Long-distance conditioning and trail fitness',
      'descAr': 'تكييف المسافات الطويلة واللياقة البدنية',
      'exercises': [
        {'name': 'Interval Trot', 'nameAr': 'خبب متقطع', 'sets': '30 min', 'done': true},
        {'name': 'Hill Work', 'nameAr': 'عمل التلال', 'sets': '20 min', 'done': false},
        {'name': 'Long Canter', 'nameAr': 'كانتر طويل', 'sets': '15 min', 'done': false},
        {'name': 'Recovery Walk', 'nameAr': 'مشي الاسترداد', 'sets': '10 min', 'done': false},
      ],
      'progress': 0.35,
    },
    {
      'name': 'Ground Work', 'nameAr': 'العمل الأرضي',
      'icon': Icons.accessibility_new, 'color': Colors.orange,
      'duration': '6 weeks', 'durationAr': '6 أسابيع',
      'difficulty': 'Beginner', 'difficultyAr': 'مبتدئ',
      'desc': 'Trust building, lunging, and in-hand work',
      'descAr': 'بناء الثقة والتدريب الأرضي والعمل باليد',
      'exercises': [
        {'name': 'Lunging Circle', 'nameAr': 'دائرة اللونج', 'sets': '10 min', 'done': true},
        {'name': 'Desensitizing', 'nameAr': 'إزالة الحساسية', 'sets': '15 min', 'done': true},
        {'name': 'Leading Patterns', 'nameAr': 'أنماط القيادة', 'sets': '10 min', 'done': true},
        {'name': 'Liberty Work', 'nameAr': 'عمل الحرية', 'sets': '10 min', 'done': true},
      ],
      'progress': 1.0,
    },
    {
      'name': 'Recovery', 'nameAr': 'التعافي',
      'icon': Icons.spa, 'color': Colors.teal,
      'duration': '4 weeks', 'durationAr': '4 أسابيع',
      'difficulty': 'Easy', 'difficultyAr': 'سهل',
      'desc': 'Post-competition rest, stretching, and rehab',
      'descAr': 'الراحة بعد المنافسة والتمدد وإعادة التأهيل',
      'exercises': [
        {'name': 'Walking', 'nameAr': 'المشي', 'sets': '20 min', 'done': true},
        {'name': 'Stretching', 'nameAr': 'التمدد', 'sets': '15 min', 'done': true},
        {'name': 'Cold Therapy', 'nameAr': 'العلاج بالبرودة', 'sets': '10 min', 'done': false},
        {'name': 'Massage', 'nameAr': 'التدليك', 'sets': '15 min', 'done': false},
      ],
      'progress': 0.50,
    },
  ];

  final List<Map<String, dynamic>> _recentLog = [
    {'date': 'Feb 13', 'dateAr': '13 فبراير', 'program': 'Dressage', 'programAr': 'الترويض', 'horse': 'Thunder', 'duration': '45 min', 'notes': 'Good collection, needs work on transitions', 'notesAr': 'تجميع جيد، يحتاج عمل على الانتقالات'},
    {'date': 'Feb 12', 'dateAr': '12 فبراير', 'program': 'Jumping', 'programAr': 'قفز الحواجز', 'horse': 'Spirit', 'duration': '30 min', 'notes': 'Clean rounds at 1.1m', 'notesAr': 'جولات نظيفة على 1.1م'},
    {'date': 'Feb 11', 'dateAr': '11 فبراير', 'program': 'Ground Work', 'programAr': 'العمل الأرضي', 'horse': 'Bella', 'duration': '40 min', 'notes': 'Excellent liberty work response', 'notesAr': 'استجابة ممتازة في عمل الحرية'},
    {'date': 'Feb 10', 'dateAr': '10 فبراير', 'program': 'Endurance', 'programAr': 'التحمل', 'horse': 'Thunder', 'duration': '60 min', 'notes': 'HR recovered well, HR avg 120bpm', 'notesAr': 'تعافى النبض جيداً، متوسط 120 نبضة/دقيقة'},
  ];

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.08);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(lang == 'ar' ? 'تدريب الخيول' : 'Horse Training', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8D6E63),
          labelColor: const Color(0xFF8D6E63),
          unselectedLabelColor: subtextColor,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: lang == 'ar' ? 'البرامج' : 'Programs'),
            Tab(text: lang == 'ar' ? 'السجل' : 'Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgramsTab(isDark, lang, cardColor, textColor, subtextColor, shadowColor),
          _buildLogTab(isDark, lang, cardColor, textColor, subtextColor, shadowColor),
        ],
      ),
    );
  }

  Widget _buildProgramsTab(bool isDark, String lang, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF6D4C41).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
            ),
            child: Row(children: [
              SizedBox(
                width: 70, height: 70,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: _programs.map((p) => p['progress'] as double).reduce((a, b) => a + b) / _programs.length,
                    strokeWidth: 6, backgroundColor: Colors.white24,
                    color: const Color(0xFFD2B48C),
                  ),
                  Text('${((_programs.map((p) => p['progress'] as double).reduce((a, b) => a + b) / _programs.length) * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
              ),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lang == 'ar' ? 'التقدم الكلي' : 'Overall Progress', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(lang == 'ar' ? '${_programs.length} برامج نشطة' : '${_programs.length} active programs',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(lang == 'ar' ? '🔥 3 أيام متصلة' : '🔥 3 day streak',
                    style: GoogleFonts.poppins(color: const Color(0xFFD2B48C), fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          Text(lang == 'ar' ? 'البرامج التدريبية' : 'Training Programs', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(height: 12),

          ...List.generate(_programs.length, (index) {
            final program = _programs[index];
            final isExpanded = _selectedProgram == index;
            final Color progColor = program['color'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardColor, borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 3))],
                border: isExpanded ? Border.all(color: progColor.withOpacity(0.3), width: 1.5) : null,
              ),
              child: Column(children: [
                // Header
                GestureDetector(
                  onTap: () => setState(() => _selectedProgram = isExpanded ? -1 : index),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: progColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                        child: Icon(program['icon'], color: progColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lang == 'ar' ? program['nameAr'] : program['name'],
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: progColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(lang == 'ar' ? program['difficultyAr'] : program['difficulty'],
                                style: GoogleFonts.poppins(color: progColor, fontSize: 9, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text(lang == 'ar' ? program['durationAr'] : program['duration'],
                              style: GoogleFonts.poppins(color: subtextColor, fontSize: 11)),
                        ]),
                      ])),
                      // Circular progress
                      SizedBox(
                        width: 40, height: 40,
                        child: Stack(alignment: Alignment.center, children: [
                          CircularProgressIndicator(value: program['progress'], strokeWidth: 3, backgroundColor: progColor.withOpacity(0.1), color: progColor),
                          Text('${(program['progress'] * 100).toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: textColor)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: subtextColor),
                    ]),
                  ),
                ),
                // Expanded exercises
                if (isExpanded) ...[
                  Divider(height: 1, color: subtextColor.withOpacity(0.15)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(lang == 'ar' ? program['descAr'] : program['desc'],
                          style: GoogleFonts.poppins(color: subtextColor, fontSize: 12)),
                      const SizedBox(height: 14),
                      Text(lang == 'ar' ? 'التمارين' : 'Exercises', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
                      const SizedBox(height: 8),
                      ...List.generate((program['exercises'] as List).length, (i) {
                        final ex = program['exercises'][i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: progColor.withOpacity(isDark ? 0.08 : 0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: ex['done'] ? progColor : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(color: progColor.withOpacity(0.5), width: 2),
                              ),
                              child: ex['done'] ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(lang == 'ar' ? ex['nameAr'] : ex['name'],
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: textColor,
                                    decoration: ex['done'] ? TextDecoration.lineThrough : null))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: progColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(ex['sets'], style: GoogleFonts.poppins(color: progColor, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        );
                      }),
                    ]),
                  ),
                ],
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogTab(bool isDark, String lang, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recentLog.length,
      itemBuilder: (context, index) {
        final log = _recentLog[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF8D6E63).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(lang == 'ar' ? log['programAr'] : log['program'],
                      style: GoogleFonts.poppins(color: const Color(0xFF8D6E63), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text('🐴 ${log['horse']}', style: GoogleFonts.poppins(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ]),
              Text(lang == 'ar' ? log['dateAr'] : log['date'], style: GoogleFonts.poppins(color: subtextColor, fontSize: 11)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.timer_outlined, color: subtextColor, size: 14),
              const SizedBox(width: 4),
              Text(log['duration'], style: GoogleFonts.poppins(color: subtextColor, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            Text(lang == 'ar' ? log['notesAr'] : log['notes'], style: GoogleFonts.poppins(color: textColor, fontSize: 13)),
          ]),
        );
      },
    );
  }
}
