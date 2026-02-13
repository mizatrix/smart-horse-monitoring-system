
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class ArScanScreen extends StatefulWidget {
  const ArScanScreen({super.key});

  @override
  State<ArScanScreen> createState() => _ArScanScreenState();
}

class _ArScanScreenState extends State<ArScanScreen> with TickerProviderStateMixin {
  CameraController? _controller;
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _resultSlideController;
  late AnimationController _tagFloatController;
  late Animation<double> _resultSlide;
  
  int _scanPhase = 0; // 0=scanning, 1=detected, 2=showing results
  double _scanProgress = 0.0;
  Timer? _progressTimer;
  Timer? _phaseTimer;

  // Simulated AR data
  final Map<String, dynamic> _detectedData = {
    'name': 'Thunder',
    'breed': 'Arabian',
    'id': '#8392-Alpha',
    'microchip': '900-234-567-8901',
    'hr': 42,
    'temp': 37.8,
    'hydration': 87,
    'gait': 'Normal',
    'stress': 18,
    'respiration': 16,
    'weight': '485 kg',
    'status': 'Healthy',
    'age': '7 yrs',
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _resultSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resultSlide = CurvedAnimation(parent: _resultSlideController, curve: Curves.easeOutCubic);

    _tagFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Animate scan progress
    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_scanPhase == 0 && mounted) {
        setState(() {
          _scanProgress = (_scanProgress + 0.025).clamp(0.0, 1.0);
        });
        if (_scanProgress >= 1.0) {
          timer.cancel();
          _onScanComplete();
        }
      }
    });
  }

  void _onScanComplete() {
    if (!mounted) return;
    setState(() => _scanPhase = 1);
    _phaseTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _scanPhase = 2);
        _resultSlideController.forward();
      }
    });
  }

  void _rescan() {
    setState(() {
      _scanPhase = 0;
      _scanProgress = 0.0;
    });
    _resultSlideController.reset();
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_scanPhase == 0 && mounted) {
        setState(() {
          _scanProgress = (_scanProgress + 0.025).clamp(0.0, 1.0);
        });
        if (_scanProgress >= 1.0) {
          timer.cancel();
          _onScanComplete();
        }
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras[0], ResolutionPreset.high);
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      // Camera not available, show fallback
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    _resultSlideController.dispose();
    _tagFloatController.dispose();
    _progressTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Feed or fallback with horse image
          if (_controller != null && _controller!.value.isInitialized)
            CameraPreview(_controller!)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                    Colors.black,
                  ],
                ),
              ),
            ),

          // After detection, overlay the horse image on top of camera
          if (_scanPhase >= 1)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _scanPhase >= 1 ? 0.6 : 0.0,
                child: Image.asset(
                  'assets/images/horse_avatar_1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Dark overlay for contrast
          Container(color: Colors.black.withOpacity(_scanPhase == 2 ? 0.45 : 0.3)),

          // Scanning overlay
          if (_scanPhase == 0)
            _buildScanningOverlay(),

          // Corner brackets reticle
          if (_scanPhase <= 1)
            Center(child: _buildCornerReticle()),

          // Detection banner
          if (_scanPhase == 1)
            _buildDetectionBanner(lang),

          // Floating AR tags (after detection)
          if (_scanPhase == 2)
            _buildFloatingTags(lang),

          // HUD UI
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(lang),
                const Spacer(),
                if (_scanPhase == 2)
                  _buildArHealthPanel(lang),
              ],
            ),
          ),

          // Scan progress indicator
          if (_scanPhase == 0)
            _buildProgressIndicator(lang),
        ],
      ),
    );
  }

  Widget _buildTopBar(String lang) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _scanPhase == 2 ? Colors.greenAccent.withOpacity(0.5) : const Color(0xFFCEB8A4).withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: _scanPhase == 2
                            ? Colors.greenAccent.withOpacity(0.5 + _pulseController.value * 0.5)
                            : Color.lerp(const Color(0xFFCEB8A4), Colors.white, _pulseController.value),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  _scanPhase == 2 ? AppStrings.get('ar_linked', lang) : AppStrings.get('ar_view_active', lang),
                  style: GoogleFonts.robotoMono(
                    color: _scanPhase == 2 ? Colors.greenAccent : const Color(0xFFCEB8A4),
                    fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (_scanPhase == 2)
            GestureDetector(
              onTap: _rescan,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.refresh, color: Colors.white, size: 24),
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return AnimatedBuilder(
      animation: _scanLineController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ScannerPainter(scanValue: _scanLineController.value, progress: _scanProgress),
        );
      },
    );
  }

  Widget _buildCornerReticle() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + _pulseController.value * 0.02;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 260, height: 260,
            child: CustomPaint(
              painter: CornerBracketPainter(
                color: _scanPhase == 1 ? Colors.greenAccent : const Color(0xFFCEB8A4),
                progress: _scanProgress,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(String lang) {
    return Positioned(
      bottom: 120, left: 0, right: 0,
      child: Column(
        children: [
          Text(
            '${AppStrings.get('scanning', lang)} ${(_scanProgress * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.robotoMono(color: const Color(0xFFCEB8A4), fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.5),
          ),
          const SizedBox(height: 15),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 80), height: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: _scanProgress, backgroundColor: Colors.white.withOpacity(0.15), color: const Color(0xFFCEB8A4)),
            ),
          ),
          const SizedBox(height: 10),
          Text(AppStrings.get('hold_steady', lang), style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDetectionBanner(String lang) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + value * 0.2,
            child: Opacity(
              opacity: value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
                    const SizedBox(width: 12),
                    Text(AppStrings.get('horse_detected', lang), style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingTags(String lang) {
    return AnimatedBuilder(
      animation: _tagFloatController,
      builder: (context, child) {
        final screenW = MediaQuery.of(context).size.width;
        final screenH = MediaQuery.of(context).size.height;
        final float = _tagFloatController.value * 6;

        return Stack(
          children: [
            Positioned(left: screenW * 0.15, top: screenH * 0.25 + float, child: _buildFloatingTag(AppStrings.get('head', lang), '✓ ${AppStrings.get('normal', lang)}', Colors.greenAccent)),
            Positioned(right: screenW * 0.1, top: screenH * 0.35 - float, child: _buildFloatingTag(AppStrings.get('chest', lang), '42 ${AppStrings.get('bpm', lang)}', const Color(0xFFCEB8A4))),
            Positioned(left: screenW * 0.2, top: screenH * 0.50 + float * 0.5, child: _buildFloatingTag(AppStrings.get('legs', lang), AppStrings.get('gait_ok', lang), Colors.cyan)),
            Positioned(right: screenW * 0.15, top: screenH * 0.45 - float * 0.7, child: _buildFloatingTag(AppStrings.get('body', lang), '37.8°C', Colors.orangeAccent)),
          ],
        );
      },
    );
  }

  Widget _buildFloatingTag(String label, String value, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.6), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('$label: $value', style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArHealthPanel(String lang) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(_resultSlide),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFCEB8A4).withOpacity(0.3)),
          boxShadow: [BoxShadow(color: const Color(0xFFCEB8A4).withOpacity(0.15), blurRadius: 30, spreadRadius: 5)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Horse Identity
            Row(
              children: [
                Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCEB8A4), width: 2),
                    image: const DecorationImage(image: AssetImage('assets/images/horse_avatar_1.png'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_detectedData['name'], style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Row(children: [
                        Text('${_detectedData['breed']} • ${_detectedData['age']}', style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(AppStrings.get('healthy', lang), style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      Text('ID: ${_detectedData['id']} • Chip: ${_detectedData['microchip']}', style: GoogleFonts.robotoMono(color: Colors.grey[600], fontSize: 9)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.verified, color: Colors.greenAccent, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Divider(color: Colors.grey[800], height: 1),
            const SizedBox(height: 15),

            // Vitals Grid — Row 1
            Row(children: [
              Expanded(child: _buildVitalCard(AppStrings.get('heart_rate', lang), '${_detectedData['hr']}', AppStrings.get('bpm', lang), Icons.monitor_heart, const Color(0xFFE57373), true)),
              const SizedBox(width: 10),
              Expanded(child: _buildVitalCard(AppStrings.get('temperature', lang), '${_detectedData['temp']}', '°C', Icons.thermostat, Colors.orangeAccent, false)),
              const SizedBox(width: 10),
              Expanded(child: _buildVitalCard(AppStrings.get('respiration', lang), '${_detectedData['respiration']}', '/min', Icons.air, Colors.cyanAccent, false)),
            ]),
            const SizedBox(height: 10),
            // Vitals Grid — Row 2
            Row(children: [
              Expanded(child: _buildVitalCard(AppStrings.get('hydration_label', lang), '${_detectedData['hydration']}', '%', Icons.water_drop, Colors.blueAccent, false)),
              const SizedBox(width: 10),
              Expanded(child: _buildVitalCard(AppStrings.get('stress_label', lang), '${_detectedData['stress']}', '/100', Icons.psychology, Colors.purpleAccent, false)),
              const SizedBox(width: 10),
              Expanded(child: _buildVitalCard(AppStrings.get('gait', lang), '', AppStrings.get('normal', lang), Icons.directions_walk, Colors.greenAccent, false)),
            ]),
            const SizedBox(height: 15),

            // Action buttons
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD2B48C), Color(0xFF8D6E63)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(AppStrings.get('view_full_report', lang), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _rescan,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white24)),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(String label, String value, String unit, IconData icon, Color color, bool showPulse) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        if (showPulse)
          _buildPulsingText(value, color)
        else
          Text(value.isEmpty ? unit : value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: value.isEmpty ? 11 : 15)),
        if (value.isNotEmpty)
          Text(unit, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 9)),
        Text(label, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 8)),
      ]),
    );
  }

  Widget _buildPulsingText(String value, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + _pulseController.value * 0.05,
          child: Text(value, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        );
      },
    );
  }
}

// Scanning line + grid painter
class ScannerPainter extends CustomPainter {
  final double scanValue;
  final double progress;
  ScannerPainter({required this.scanValue, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFCEB8A4).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final scanY = size.height * scanValue;
    final linePaint = Paint()
      ..color = const Color(0xFFCEB8A4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), linePaint);

    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [const Color(0xFFCEB8A4).withOpacity(0.2), const Color(0xFFCEB8A4).withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, scanY - 80, size.width, 80));

    canvas.drawRect(Rect.fromLTWH(0, scanY - 80, size.width, 80), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Corner bracket reticle painter
class CornerBracketPainter extends CustomPainter {
  final Color color;
  final double progress;
  CornerBracketPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final cornerLength = 35.0;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);
    canvas.drawLine(Offset(w, 0), Offset(w - cornerLength, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), paint);
    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cornerLength), paint);
    canvas.drawLine(Offset(w, h), Offset(w - cornerLength, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);

    final centerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = w / 2;
    final cy = h / 2;
    canvas.drawLine(Offset(cx - 15, cy), Offset(cx + 15, cy), centerPaint);
    canvas.drawLine(Offset(cx, cy - 15), Offset(cx, cy + 15), centerPaint);
  }

  @override
  bool shouldRepaint(covariant CornerBracketPainter oldDelegate) => color != oldDelegate.color;
}
