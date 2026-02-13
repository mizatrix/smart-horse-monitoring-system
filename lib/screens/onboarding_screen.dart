import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  bool onLastPage = false;
  int _currentPage = 0;
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  final List<Color> _lightGradients = [
    const Color(0xFFF5E6D3),
    const Color(0xFFE3F2FD),
    const Color(0xFFE8F5E9),
  ];

  final List<Color> _darkGradients = [
    const Color(0xFF1A1510),
    const Color(0xFF101520),
    const Color(0xFF101A14),
  ];

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _buttonScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final gradientColors = isDark ? _darkGradients : _lightGradients;
    final bgEnd = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors[_currentPage],
              bgEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                      onLastPage = (index == 2);
                    });
                  },
                  children: [
                    IntroPage(
                      imagePath: 'assets/images/onboarding_monitor.png',
                      title: AppStrings.get('onboarding_title_1', lang),
                      description: AppStrings.get('onboarding_desc_1', lang),
                      icon: Icons.monitor_heart,
                      iconColor: const Color(0xFFE57373),
                    ),
                    IntroPage(
                      imagePath: 'assets/images/onboarding_ai.png',
                      title: AppStrings.get('onboarding_title_2', lang),
                      description: AppStrings.get('onboarding_desc_2', lang),
                      icon: Icons.psychology,
                      iconColor: const Color(0xFF7986CB),
                    ),
                    IntroPage(
                      imagePath: 'assets/images/onboarding_location.png',
                      title: AppStrings.get('onboarding_title_3', lang),
                      description: AppStrings.get('onboarding_desc_3', lang),
                      icon: Icons.language,
                      iconColor: const Color(0xFF81C784),
                    ),
                  ],
                ),
              ),

              // Bottom Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 30, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: const Color(0xFF8D6E63),
                        dotColor: (isDark
                                ? const Color(0xFF8D6E63)
                                : const Color(0xFFD2B48C))
                            .withOpacity(0.3),
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Skip
                          GestureDetector(
                            onTap: () => _controller.jumpToPage(2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Text(
                                AppStrings.get('skip', lang),
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          // Next / Get Started
                          onLastPage
                              ? ScaleTransition(
                                  scale: _buttonScale,
                                  child: GestureDetector(
                                    onTap: () =>
                                        Navigator.pushReplacementNamed(
                                            context, '/login'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 35, vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFD2B48C),
                                            Color(0xFF8D6E63)
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFD2B48C)
                                                .withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppStrings.get(
                                                'get_started', lang),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            localeProvider.isArabic
                                                ? Icons
                                                    .arrow_back_rounded
                                                : Icons
                                                    .arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    _controller.nextPage(
                                      duration: const Duration(
                                          milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8D6E63),
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          AppStrings.get('next', lang),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          localeProvider.isArabic
                                              ? Icons.arrow_back_rounded
                                              : Icons
                                                  .arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IntroPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isSvg;
  final IconData icon;
  final Color iconColor;

  const IntroPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    this.isSvg = false,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );
    _slideUp = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(
          parent: _controller,
          curve:
              const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve:
              const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.35;

    final titleColor =
        isDark ? const Color(0xFFE0E0E0) : Colors.black87;
    final descColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: widget.isSvg
                    ? null
                    : DecorationImage(
                        image: AssetImage(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
              ),
              child: widget.isSvg
                  ? Center(
                      child: ScaleTransition(
                        scale: _iconScale,
                        child: Icon(Icons.location_on,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 30),

            FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _iconScale,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: widget.iconColor.withOpacity(
                              isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(widget.icon,
                            color: widget.iconColor, size: 28),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: descColor,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
