
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.6)),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.4)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 0.7)),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
    );
    _loaderFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.6, 1.0)),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A1209), const Color(0xFF0D2818), const Color(0xFF0A0A0A)]
                    : [const Color(0xFFF5EDE0), const Color(0xFFE8D5B7), const Color(0xFFD2B48C)],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(
                  progress: _particleController.value,
                  isDark: isDark,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo with glow
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD2B48C).withOpacity(
                                    0.2 + _shimmerController.value * 0.2,
                                  ),
                                  blurRadius: 40 + _shimmerController.value * 20,
                                  spreadRadius: 5 + _shimmerController.value * 10,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF8D6E63).withOpacity(0.1),
                                  blurRadius: 60,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFD2B48C),
                                    const Color(0xFF8D6E63),
                                    Color.lerp(
                                      const Color(0xFF8D6E63),
                                      const Color(0xFFD2B48C),
                                      _shimmerController.value,
                                    )!,
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Image.asset(
                                    'assets/icons/app_icon.png',
                                    fit: BoxFit.contain,
                                    color: Colors.white,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // App name
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: isDark
                              ? [const Color(0xFFD2B48C), Colors.white, const Color(0xFFD2B48C)]
                              : [const Color(0xFF5D4037), const Color(0xFF8D6E63), const Color(0xFF5D4037)],
                        ).createShader(bounds),
                        child: Text(
                          AppStrings.get('app_name', lang),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Decorative line
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: Container(
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              isDark ? const Color(0xFFD2B48C) : const Color(0xFF8D6E63),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        AppStrings.get('splash_tagline', lang),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : const Color(0xFF8D6E63).withOpacity(0.8),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Loading indicator
                  FadeTransition(
                    opacity: _loaderFade,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? const Color(0xFFD2B48C) : const Color(0xFF8D6E63),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lang == 'ar' ? 'جارِ التحميل...' : 'Loading...',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? Colors.grey[600] : const Color(0xFF8D6E63).withOpacity(0.5),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _ParticlePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFFD2B48C) : const Color(0xFF8D6E63)).withOpacity(0.08);

    final random = math.Random(42); // Seeded for consistent positions
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final radius = 1.0 + random.nextDouble() * 2.5;

      final y = (baseY - progress * speed * size.height * 0.3) % size.height;
      final opacity = (0.03 + random.nextDouble() * 0.08) * (1 - (y / size.height).abs());

      paint.color = (isDark ? const Color(0xFFD2B48C) : const Color(0xFF8D6E63))
          .withOpacity(opacity.clamp(0.0, 0.15));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => progress != oldDelegate.progress;
}
