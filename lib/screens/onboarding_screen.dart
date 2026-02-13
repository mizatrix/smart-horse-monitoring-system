
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: const [
              IntroPage(
                imagePath: 'assets/images/image7.png',
                title: 'Real-time Health Monitoring',
                description: 'Track your horse\'s vitals 24/7 with precision IoT sensors to ensure peak performance.',
              ),
              IntroPage(
                imagePath: 'assets/images/image7.png',
                title: 'AI-Powered Insights',
                description: 'Detect early signs of illness and injury with our advanced predictive algorithms.',
              ),
              IntroPage(
                imagePath: 'assets/images/image19.svg',
                isSvg: true,
                title: 'Stay Connected Anywhere',
                description: 'Monitor location, activity, and stable conditions from anywhere in the world.',
              ),
            ],
          ),
          
          // Bottom Controls
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                // Next / Done
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Start',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: Text(
                          'Next',
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isSvg;

  const IntroPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    this.isSvg = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: isSvg ? null : DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
               // Fallback for SVG if needed, but using PNGs is safer for now
              child: isSvg ? Center(child: Icon(Icons.location_on, size: 100, color: Theme.of(context).colorScheme.primary)) : null,
            ),
          ),
          
          // Text
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay( // Classy serif for headers
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
