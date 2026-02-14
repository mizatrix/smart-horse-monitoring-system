
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';
import 'add_edit_horse_screen.dart';
import 'training_screen.dart';
import 'shop_screen.dart';

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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _vitalAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _vitalProgress = CurvedAnimation(parent: _vitalAnimController, curve: Curves.easeOutCubic);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _vitalAnimController.dispose();
    _tabController.dispose();
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

    Color statusColor = horse.status == 'Critical' ? Colors.red : (horse.status == 'Warning' ? Colors.orange : Colors.green);
    String statusText;
    switch (horse.status) {
      case 'Critical': statusText = AppStrings.get('critical', lang); break;
      case 'Warning': statusText = AppStrings.get('warning', lang); break;
      default: statusText = AppStrings.get('healthy', lang);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF8D6E63),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.white),
                onPressed: () => setState(() => isFavorite = !isFavorite),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditHorseScreen(horse: horse))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Hero(tag: horse.id, child: Image.asset(horse.imageUrl, fit: BoxFit.cover)),
                Container(decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ))),
                Positioned(bottom: 60, left: 20, right: 20, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(horse.name, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('${horse.breed} • ${horse.gender} • ${horse.age} ${AppStrings.get('yrs', lang)}',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                        child: Text(statusText, style: GoogleFonts.poppins(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ],
                )),
              ]),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: isDark ? const Color(0xFF121212) : const Color(0xFFFDFCF8),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF8D6E63),
                  labelColor: const Color(0xFF8D6E63),
                  unselectedLabelColor: subtextColor,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                  tabs: [
                    Tab(text: lang == 'ar' ? 'نظرة عامة' : 'Overview'),
                    Tab(text: lang == 'ar' ? 'العلامات' : 'Vitals'),
                    Tab(text: lang == 'ar' ? 'الصحة' : 'Health'),
                    Tab(text: lang == 'ar' ? 'السجل' : 'History'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(horse, isDark, lang, cardColor, textColor, subtextColor, shadowColor, statusColor),
            _buildVitalsTab(horse, isDark, lang, cardColor, textColor, subtextColor, shadowColor),
            _buildHealthTab(horse, isDark, lang, cardColor, textColor, subtextColor, shadowColor),
            _buildHistoryTab(horse, isDark, lang, cardColor, textColor, subtextColor, shadowColor),
          ],
        ),
      ),
    );
  }

  // ============ OVERVIEW TAB ============
  Widget _buildOverviewTab(Horse horse, bool isDark, String lang, Color cardColor, Color textColor, Color subtextColor, Color shadowColor, Color statusColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Quick info tags
        Row(children: [
          _buildInfoTag(Icons.location_on, horse.location, const Color(0xFF00695C), isDark),
          const SizedBox(width: 8),
          _buildInfoTag(Icons.memory, horse.microchipId, Colors.blueGrey, isDark),
          const SizedBox(width: 8),
          _buildInfoTag(Icons.scale, '${horse.weight.toStringAsFixed(0)} kg', Colors.brown, isDark),
        ]),
        const SizedBox(height: 20),

        // Profile grid
        Text(lang == 'ar' ? 'الملف الشخصي' : 'Profile', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1, mainAxisSpacing: 10, crossAxisSpacing: 10,
          children: [
            _buildProfileCard(Icons.pets, lang == 'ar' ? 'السلالة' : 'Breed', horse.breed, const Color(0xFF8D6E63), cardColor, textColor, subtextColor, shadowColor),
            _buildProfileCard(Icons.cake, lang == 'ar' ? 'العمر' : 'Age', '${horse.age} ${lang == 'ar' ? 'سنة' : 'yrs'}', Colors.purple, cardColor, textColor, subtextColor, shadowColor),
            _buildProfileCard(horse.gender == 'Mare' ? Icons.female : Icons.male, lang == 'ar' ? 'الجنس' : 'Gender', horse.gender, Colors.indigo, cardColor, textColor, subtextColor, shadowColor),
            _buildProfileCard(Icons.scale, lang == 'ar' ? 'الوزن' : 'Weight', '${horse.weight.toStringAsFixed(0)} kg', Colors.brown, cardColor, textColor, subtextColor, shadowColor),
            _buildProfileCard(Icons.location_on, lang == 'ar' ? 'الموقع' : 'Location', horse.location, const Color(0xFF00695C), cardColor, textColor, subtextColor, shadowColor),
            _buildProfileCard(Icons.memory, lang == 'ar' ? 'الشريحة' : 'Chip', horse.microchipId.length > 10 ? '${horse.microchipId.substring(0, 10)}...' : horse.microchipId, Colors.blueGrey, cardColor, textColor, subtextColor, shadowColor),
          ],
        ),
        const SizedBox(height: 20),

        // Quick actions
        Text(lang == 'ar' ? 'الإجراءات السريعة' : 'Quick Actions', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildActionButton(lang == 'ar' ? 'جدولة\nزيارة' : 'Schedule\nVisit', Icons.calendar_today, const Color(0xFF00695C), isDark)),
          const SizedBox(width: 10),
          Expanded(child: _buildActionButton(lang == 'ar' ? 'تعيين\nتنبيه' : 'Set\nAlert', Icons.notifications_active, Colors.orange, isDark)),
          const SizedBox(width: 10),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingScreen())),
            child: _buildActionCardContent(lang == 'ar' ? 'سجل\nالتدريب' : 'Training\nLog', Icons.fitness_center, const Color(0xFF6D4C41), isDark),
          )),
          const SizedBox(width: 10),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
            child: _buildActionCardContent(lang == 'ar' ? 'شراء\nمستشعر' : 'Buy\nSensor', Icons.sensors, const Color(0xFF8D6E63), isDark),
          )),
        ]),
        const SizedBox(height: 20),

        // Owner info
        Text(lang == 'ar' ? 'معلومات المالك' : 'Owner Info', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)]),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63).withOpacity(0.12), shape: BoxShape.circle,
              ),
              child: const Center(child: Text('M', style: TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.bold, fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Moataz', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
              Text(lang == 'ar' ? 'المالك الرئيسي' : 'Primary Owner', style: GoogleFonts.poppins(color: subtextColor, fontSize: 11)),
            ])),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF00695C).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.phone, color: Color(0xFF00695C), size: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF8D6E63).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.email, color: Color(0xFF8D6E63), size: 18),
            ),
          ]),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  // ============ VITALS TAB ============
  Widget _buildVitalsTab(Horse horse, bool isDark, String lang, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppStrings.get('vitals', lang), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 15),
        AnimatedBuilder(
          animation: _vitalProgress,
          builder: (context, child) => Column(children: [
            Row(children: [
              Expanded(child: _buildAnimatedVitalCard(AppStrings.get('heart_rate', lang), horse.currentHeartRate, AppStrings.get('bpm', lang), Icons.monitor_heart, Colors.redAccent, _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor)),
              const SizedBox(width: 10),
              Expanded(child: _buildAnimatedVitalCard(AppStrings.get('temperature', lang), horse.currentTemp, '°C', Icons.thermostat, Colors.orangeAccent, _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor)),
              const SizedBox(width: 10),
              Expanded(child: _buildAnimatedVitalCard(AppStrings.get('respiration', lang), horse.currentRespiration.toDouble(), '/min', Icons.air, Colors.cyan, _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildAnimatedVitalCard(lang == 'ar' ? 'الترطيب' : 'Hydration', horse.hydrationLevel, '%', Icons.water_drop, Colors.blueAccent, _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor)),
              const SizedBox(width: 10),
              Expanded(child: _buildAnimatedVitalCard(lang == 'ar' ? 'التوتر' : 'Stress', horse.stressIndex.toDouble(), '/100', Icons.psychology, Colors.purple, _vitalProgress.value, cardColor, textColor, subtextColor, shadowColor)),
              const SizedBox(width: 10),
              Expanded(child: _buildGaitCard(horse.gaitScore, cardColor, textColor, subtextColor, shadowColor, lang)),
            ]),
          ]),
        ),
        const SizedBox(height: 25),

        // Heart Rate Chart
        Text('${AppStrings.get('heart_rate', lang)} (24h)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 15),
        Container(
          height: 180, padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10)]),
          child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: (isDark ? Colors.grey[700]! : Colors.grey).withOpacity(0.1), strokeWidth: 1)),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 6,
                getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8),
                  child: Text('${value.toInt()}h', style: GoogleFonts.poppins(color: subtextColor, fontSize: 9))))),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: horse.heartRateHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true, color: Colors.redAccent, barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.redAccent.withOpacity(0.2), Colors.redAccent.withOpacity(0.0)],
              )),
            )],
          )),
        ),
        const SizedBox(height: 25),

        // Temperature Chart
        Text('${AppStrings.get('temperature', lang)} (24h)', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 15),
        Container(
          height: 180, padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 10)]),
          child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: (isDark ? Colors.grey[700]! : Colors.grey).withOpacity(0.1), strokeWidth: 1)),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 6,
                getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8),
                  child: Text('${value.toInt()}h', style: GoogleFonts.poppins(color: subtextColor, fontSize: 9))))),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: horse.tempHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true, color: Colors.orangeAccent, barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.orangeAccent.withOpacity(0.2), Colors.orangeAccent.withOpacity(0.0)],
              )),
            )],
          )),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  // ============ HEALTH TAB ============
  Widget _buildHealthTab(Horse horse, bool isDark, String lang, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lang == 'ar' ? 'السجل الصحي' : 'Health Record', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 15),
        _buildHealthInfoRow(Icons.verified_user, AppStrings.get('vaccination', lang), horse.vaccinationStatus,
          horse.vaccinationStatus == 'Up to date' ? Colors.green : (horse.vaccinationStatus == 'Due Soon' ? Colors.orange : Colors.red), cardColor, textColor, subtextColor, shadowColor),
        _buildHealthInfoRow(Icons.calendar_today, lang == 'ar' ? 'آخر زيارة بيطرية' : 'Last Vet Visit', horse.lastVetVisit, const Color(0xFF00695C), cardColor, textColor, subtextColor, shadowColor),
        _buildHealthInfoRow(Icons.directions_walk, lang == 'ar' ? 'تقييم المشية' : 'Gait Assessment', horse.gaitScore,
          horse.gaitScore == 'Normal' ? Colors.green : Colors.orange, cardColor, textColor, subtextColor, shadowColor),
        _buildHealthInfoRow(Icons.water_drop, lang == 'ar' ? 'مستوى الترطيب' : 'Hydration Level', '${horse.hydrationLevel.toStringAsFixed(0)}%',
          horse.hydrationLevel > 70 ? Colors.blue : Colors.orange, cardColor, textColor, subtextColor, shadowColor),
        _buildHealthInfoRow(Icons.psychology, lang == 'ar' ? 'مؤشر التوتر' : 'Stress Index', '${horse.stressIndex}/100',
          horse.stressIndex < 30 ? Colors.green : (horse.stressIndex < 60 ? Colors.orange : Colors.red), cardColor, textColor, subtextColor, shadowColor),
        _buildHealthInfoRow(Icons.scale, lang == 'ar' ? 'الوزن' : 'Weight', '${horse.weight.toStringAsFixed(1)} kg', Colors.brown, cardColor, textColor, subtextColor, shadowColor),
        _buildHealthInfoRow(Icons.location_on, AppStrings.get('location', lang), horse.location, const Color(0xFF8D6E63), cardColor, textColor, subtextColor, shadowColor),

        const SizedBox(height: 25),

        // Vaccination timeline
        Text(lang == 'ar' ? 'جدول التطعيمات' : 'Vaccination Schedule', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        ..._buildVaccTimeline(isDark, lang, cardColor, textColor, subtextColor, shadowColor),
        const SizedBox(height: 30),
      ]),
    );
  }

  List<Widget> _buildVaccTimeline(bool isDark, String lang, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    final items = [
      {'name': lang == 'ar' ? 'تطعيم الإنفلونزا' : 'Influenza Vaccine', 'date': 'Jan 2026', 'status': 'done'},
      {'name': lang == 'ar' ? 'تطعيم الكزاز' : 'Tetanus', 'date': 'Mar 2026', 'status': 'done'},
      {'name': lang == 'ar' ? 'تطعيم المشقلبة' : 'Strangles', 'date': 'Jun 2026', 'status': 'upcoming'},
      {'name': lang == 'ar' ? 'فحص أسنان' : 'Dental Check', 'date': 'Aug 2026', 'status': 'upcoming'},
    ];

    return items.map((item) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: item['status'] == 'done' ? Colors.green : const Color(0xFF8D6E63).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: item['status'] == 'done'
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : const Icon(Icons.circle, color: Color(0xFF8D6E63), size: 10),
          ),
          if (item != items.last) Container(width: 2, height: 30, color: subtextColor.withOpacity(0.2)),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 5)]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(item['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: textColor)),
            Text(item['date']!, style: GoogleFonts.poppins(color: subtextColor, fontSize: 11)),
          ]),
        )),
      ]),
    )).toList();
  }

  // ============ HISTORY TAB ============
  Widget _buildHistoryTab(Horse horse, bool isDark, String lang, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    final events = [
      {'icon': Icons.monitor_heart, 'title': lang == 'ar' ? 'فحص قلب' : 'Heart Check', 'desc': lang == 'ar' ? 'نبضات طبيعية ${horse.currentHeartRate.toStringAsFixed(0)} bpm' : 'Normal ${horse.currentHeartRate.toStringAsFixed(0)} bpm', 'date': 'Feb 13', 'color': Colors.redAccent},
      {'icon': Icons.fitness_center, 'title': lang == 'ar' ? 'جلسة تدريب' : 'Training Session', 'desc': lang == 'ar' ? 'ترويض - 45 دقيقة' : 'Dressage - 45 min', 'date': 'Feb 12', 'color': const Color(0xFF8D6E63)},
      {'icon': Icons.medical_services, 'title': lang == 'ar' ? 'زيارة بيطرية' : 'Vet Visit', 'desc': lang == 'ar' ? 'فحص روتيني - كل شيء طبيعي' : 'Routine check - all normal', 'date': 'Feb 10', 'color': const Color(0xFF00695C)},
      {'icon': Icons.vaccines, 'title': lang == 'ar' ? 'تطعيم' : 'Vaccination', 'desc': lang == 'ar' ? 'تطعيم الإنفلونزا المعزز' : 'Influenza booster administered', 'date': 'Jan 28', 'color': Colors.purple},
      {'icon': Icons.scale, 'title': lang == 'ar' ? 'قياس الوزن' : 'Weight Check', 'desc': '${horse.weight.toStringAsFixed(0)} kg', 'date': 'Jan 25', 'color': Colors.brown},
      {'icon': Icons.directions_walk, 'title': lang == 'ar' ? 'تحليل المشية' : 'Gait Analysis', 'desc': horse.gaitScore, 'date': 'Jan 20', 'color': Colors.cyan},
      {'icon': Icons.grass, 'title': lang == 'ar' ? 'تغيير النظام الغذائي' : 'Diet Change', 'desc': lang == 'ar' ? 'تمت إضافة مكمل المفاصل' : 'Added joint supplement', 'date': 'Jan 15', 'color': Colors.green},
      {'icon': Icons.spa, 'title': lang == 'ar' ? 'زيارة البيطار' : 'Farrier Visit', 'desc': lang == 'ar' ? 'حدوة جديدة - كل الأربعة' : 'New shoes - all four hooves', 'date': 'Jan 10', 'color': Colors.amber},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final Color eventColor = event['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: eventColor.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(event['icon'] as IconData, color: eventColor, size: 18),
              ),
              if (index < events.length - 1)
                Container(width: 2, height: 40, color: subtextColor.withOpacity(0.15)),
            ]),
            const SizedBox(width: 14),
            Expanded(child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 5)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(event['title'] as String, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
                  Text(event['date'] as String, style: GoogleFonts.poppins(color: subtextColor, fontSize: 11)),
                ]),
                const SizedBox(height: 4),
                Text(event['desc'] as String, style: GoogleFonts.poppins(color: subtextColor, fontSize: 12)),
              ]),
            )),
          ]),
        );
      },
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _buildInfoTag(IconData icon, String text, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: GoogleFonts.poppins(color: color, fontSize: 9, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _buildProfileCard(IconData icon, String label, String value, Color color, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: textColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: subtextColor)),
      ]),
    );
  }

  Widget _buildAnimatedVitalCard(String label, double value, String unit, IconData icon, Color color,
      double animProgress, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    final displayValue = (value * animProgress);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)]),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(displayValue.toStringAsFixed(value > 100 ? 0 : 1), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        Text(unit, style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
        Text(label, style: GoogleFonts.poppins(fontSize: 9, color: subtextColor)),
      ]),
    );
  }

  Widget _buildGaitCard(String gaitScore, Color cardColor, Color textColor, Color subtextColor, Color shadowColor, String lang) {
    Color color = gaitScore == 'Normal' ? Colors.green : (gaitScore == 'Slight Lameness' ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8)]),
      child: Column(children: [
        Icon(Icons.directions_walk, color: color, size: 20),
        const SizedBox(height: 6),
        Text(gaitScore == 'Normal' ? '✓' : '!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(lang == 'ar' ? 'المشية' : 'Gait', style: GoogleFonts.poppins(fontSize: 10, color: subtextColor)),
        Text(gaitScore, style: GoogleFonts.poppins(fontSize: 8, color: subtextColor)),
      ]),
    );
  }

  Widget _buildHealthInfoRow(IconData icon, String label, String value, Color color, Color cardColor, Color textColor, Color subtextColor, Color shadowColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: shadowColor, blurRadius: 5)]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.poppins(color: subtextColor, fontSize: 13))),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
      ]),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, bool isDark) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${label.replaceAll('\n', ' ')} tapped'), duration: const Duration(seconds: 1))),
      child: _buildActionCardContent(label, icon, color, isDark),
    );
  }

  Widget _buildActionCardContent(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08), borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }
}
