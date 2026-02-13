
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:async';

class ArScanScreen extends StatefulWidget {
  const ArScanScreen({super.key});

  @override
  State<ArScanScreen> createState() => _ArScanScreenState();
}

class _ArScanScreenState extends State<ArScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late AnimationController _animationController;
  bool _isScanning = true;
  Timer? _scanTimer;

  // Mock Data for "Detected" Horse
  final Map<String, dynamic> _detectedData = {
    'name': 'Thunder',
    'hr': '42 BPM',
    'temp': '37.8°C',
    'status': 'Healthy'
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Simulate scan completion after 3 seconds
    _scanTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFCEB8A4))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Feed
          CameraPreview(_controller!),

          // Scanning Overlay (Grid + Line)
          if (_isScanning)
             _buildScanningOverlay(),

          // HUD UI (Always visible)
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFCEB8A4)),
                        ),
                        child: Text(
                          'AR VIEW ACTIVE',
                          style: GoogleFonts.robotoMono(
                            color: const Color(0xFFCEB8A4),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Detected Horse Card (Pops up after scan)
                 if (!_isScanning)
                   _buildDetectedHorseCard(),
              ],
            ),
          ),
          
          // Center Reticle
          if (_isScanning)
             const Center(
               child: Icon(Icons.filter_center_focus, color: Colors.white54, size: 300),
             ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerPainter(_animationController.value),
        );
      },
    );
  }

  Widget _buildDetectedHorseCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCEB8A4).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCEB8A4).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/image1.png'), // Mock image
                radius: 30,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _detectedData['name'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: #8392-Alpha',
                    style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 30),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHudStat('Heart Rate', _detectedData['hr'], Icons.monitor_heart),
              _buildHudStat('Temp', _detectedData['temp'], Icons.thermostat),
               _buildHudStat('Status', _detectedData['status'], Icons.health_and_safety),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHudStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFCEB8A4), size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }
}

class ScannerPainter extends CustomPainter {
  final double scanValue;
  ScannerPainter(this.scanValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCEB8A4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final scanY = size.height * scanValue;
    
    // Draw scanning line
    canvas.drawLine(
      Offset(0, scanY),
      Offset(size.width, scanY),
      paint
    );
    
    // Draw glow
    final glowPaint = Paint()
      ..color = const Color(0xFFCEB8A4).withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 50, size.width, 50),
      glowPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
