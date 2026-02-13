import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ar_scan_screen.dart';
import 'screens/feeding_log_screen.dart';
import 'screens/vet_records_screen.dart';
import 'services/mock_data_service.dart';
import 'services/theme_provider.dart';
import 'services/locale_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockDataService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const EquiGuardApp(),
    ),
  );
}

// Custom fade-slide route transition
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeSlideRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            final slideTween = Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            );
            return FadeTransition(
              opacity: fadeTween.animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: SlideTransition(
                position: slideTween.animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

class EquiGuardApp extends StatelessWidget {
  const EquiGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'EquiGuard',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(
          themeProvider.lightTheme.textTheme,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: themeProvider.darkTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(
          themeProvider.darkTheme.textTheme,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: localeProvider.locale,
      // Enable RTL for Arabic
      builder: (context, child) {
        return Directionality(
          textDirection: localeProvider.isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const SplashScreen();
            break;
          case '/onboarding':
            page = const OnboardingScreen();
            break;
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/dashboard':
            page = const DashboardScreen();
            break;
          case '/ar_scan':
            page = const ArScanScreen();
            break;
          case '/feeding_log':
            page = const FeedingLogScreen();
            break;
          case '/vet_records':
            page = const VetRecordsScreen();
            break;
          default:
            page = const SplashScreen();
        }
        return FadeSlideRoute(page: page);
      },
    );
  }
}
