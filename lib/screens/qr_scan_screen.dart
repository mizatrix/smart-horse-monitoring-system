
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> with SingleTickerProviderStateMixin {
  bool _scanning = true;
  bool _found = false;
  Horse? _detectedHorse;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    // Simulate scan
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final mockService = Provider.of<MockDataService>(context, listen: false);
        setState(() {
          _scanning = false;
          _found = true;
          _detectedHorse = mockService.horses[0];
        });
      }
    });
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  void _rescan() {
    setState(() { _scanning = true; _found = false; _detectedHorse = null; });
    _scanLineController.repeat();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final mockService = Provider.of<MockDataService>(context, listen: false);
        final horses = mockService.horses;
        setState(() {
          _scanning = false;
          _found = true;
          _detectedHorse = horses[DateTime.now().second % horses.length];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(AppStrings.get('qr_scanner', lang), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_scanning) ...[
              // QR Frame
              Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4DB6AC), width: 3),
                ),
                child: Stack(
                  children: [
                    // Corner accents
                    ..._buildCorners(),
                    // Scan line
                    AnimatedBuilder(
                      animation: _scanLineController,
                      builder: (context, _) {
                        return Positioned(
                          top: _scanLineController.value * 244,
                          left: 5, right: 5,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFF4DB6AC), Colors.transparent]),
                              boxShadow: [BoxShadow(color: const Color(0xFF4DB6AC).withOpacity(0.5), blurRadius: 10)],
                            ),
                          ),
                        );
                      },
                    ),
                    Center(
                      child: Icon(Icons.qr_code_2, size: 80, color: Colors.white.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(AppStrings.get('point_at_qr', lang), style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Color(0xFF4DB6AC), strokeWidth: 2),
            ] else if (_found && _detectedHorse != null) ...[
              // Horse Quick Card
              _buildHorseCard(_detectedHorse!, lang),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _rescan,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(AppStrings.get('scan_another', lang), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB6AC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 20.0;
    const color = Color(0xFF4DB6AC);
    return [
      Positioned(top: 0, left: 0, child: Container(width: size, height: size, decoration: const BoxDecoration(border: Border(top: BorderSide(color: color, width: 4), left: BorderSide(color: color, width: 4))))),
      Positioned(top: 0, right: 0, child: Container(width: size, height: size, decoration: const BoxDecoration(border: Border(top: BorderSide(color: color, width: 4), right: BorderSide(color: color, width: 4))))),
      Positioned(bottom: 0, left: 0, child: Container(width: size, height: size, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: color, width: 4), left: BorderSide(color: color, width: 4))))),
      Positioned(bottom: 0, right: 0, child: Container(width: size, height: size, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: color, width: 4), right: BorderSide(color: color, width: 4))))),
    ];
  }

  Widget _buildHorseCard(Horse horse, String lang) {
    Color statusColor = horse.status == 'Critical' ? Colors.red : (horse.status == 'Warning' ? Colors.orange : Colors.green);
    String statusText = horse.status == 'Critical' ? AppStrings.get('critical', lang) : (horse.status == 'Warning' ? AppStrings.get('warning', lang) : AppStrings.get('healthy', lang));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF4DB6AC).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: const Color(0xFF4DB6AC).withOpacity(0.15), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: AssetImage(horse.imageUrl)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(horse.name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    Text('${horse.breed} • ${horse.age} ${AppStrings.get('yrs', lang)} • ${horse.gender}', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(statusText, style: GoogleFonts.poppins(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVitalChip(AppStrings.get('heart_rate', lang), '${horse.currentHeartRate.toStringAsFixed(0)}', AppStrings.get('bpm', lang), Colors.redAccent),
              _buildVitalChip(AppStrings.get('temperature', lang), '${horse.currentTemp.toStringAsFixed(1)}', '°C', Colors.orange),
              _buildVitalChip(AppStrings.get('hydration_label', lang), '${horse.hydrationLevel.toStringAsFixed(0)}', '%', Colors.blue),
              _buildVitalChip(AppStrings.get('stress_label', lang), '${horse.stressIndex}', '/100', Colors.purple),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 14),
              const SizedBox(width: 4),
              Text(horse.location, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
              const Spacer(),
              Icon(Icons.memory, color: Colors.grey[600], size: 14),
              const SizedBox(width: 4),
              Text(horse.microchipId, style: GoogleFonts.robotoMono(color: Colors.grey[500], fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalChip(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(unit, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}
