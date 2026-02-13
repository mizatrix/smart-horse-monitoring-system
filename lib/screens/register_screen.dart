import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String _selectedRole = 'Owner';

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );
    _slideUp =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() async {
    final lang = Provider.of<LocaleProvider>(context, listen: false)
        .locale
        .languageCode;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('agree_terms_error', lang),
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lang = localeProvider.locale.languageCode;

    final bgGradient = isDark
        ? [const Color(0xFF101A14), const Color(0xFF121212)]
        : [const Color(0xFFE8F5E9), const Color(0xFFFDFCF8)];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF4E342E);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final inputFillColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8);
    final inputBorderColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    final roles = [
      AppStrings.get('owner', lang),
      AppStrings.get('stable_manager', lang),
      AppStrings.get('veterinarian', lang),
      AppStrings.get('trainer', lang),
      AppStrings.get('caretaker', lang),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    // Back Button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: (isDark ? Colors.black : Colors.grey)
                                        .withOpacity(0.08),
                                    blurRadius: 8),
                              ],
                            ),
                            child: Icon(Icons.arrow_back_ios_new,
                                size: 18, color: textColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00695C)
                                .withOpacity(isDark ? 0.1 : 0.2),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_add_outlined,
                          size: 40, color: Color(0xFF00695C)),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppStrings.get('create_account', lang),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get('join_subtitle', lang),
                      style:
                          GoogleFonts.poppins(fontSize: 13, color: subtextColor),
                    ),
                    const SizedBox(height: 28),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : Colors.grey)
                                .withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label(AppStrings.get('full_name', lang),
                                subtextColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: textColor),
                              decoration: _inputDecoration(
                                hint: lang == 'ar' ? 'الاسم' : 'John Doe',
                                icon: Icons.person_outline,
                                fillColor: inputFillColor,
                                borderColor: inputBorderColor,
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? AppStrings.get('enter_name', lang)
                                  : null,
                            ),
                            const SizedBox(height: 18),

                            _label(
                                AppStrings.get('email', lang), subtextColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: textColor),
                              decoration: _inputDecoration(
                                hint: 'your@email.com',
                                icon: Icons.email_outlined,
                                fillColor: inputFillColor,
                                borderColor: inputBorderColor,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppStrings.get('enter_email', lang);
                                }
                                if (!v.contains('@')) {
                                  return AppStrings.get('valid_email', lang);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            _label(
                                AppStrings.get('role', lang), subtextColor),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: roles.first,
                              decoration: _inputDecoration(
                                hint: '',
                                icon: Icons.badge_outlined,
                                fillColor: inputFillColor,
                                borderColor: inputBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              dropdownColor: cardColor,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF00695C)),
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: textColor),
                              items: roles
                                  .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r,
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: textColor))))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedRole = v!),
                            ),
                            const SizedBox(height: 18),

                            _label(AppStrings.get('password', lang),
                                subtextColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: textColor),
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                fillColor: inputFillColor,
                                borderColor: inputBorderColor,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppStrings.get(
                                      'enter_a_password', lang);
                                }
                                if (v.length < 6) {
                                  return AppStrings.get(
                                      'password_min_length', lang);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            _label(AppStrings.get('confirm_password', lang),
                                subtextColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: textColor),
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                fillColor: inputFillColor,
                                borderColor: inputBorderColor,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppStrings.get(
                                      'confirm_password_error', lang);
                                }
                                if (v != _passwordController.text) {
                                  return AppStrings.get(
                                      'passwords_dont_match', lang);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Terms
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (v) =>
                                        setState(() => _agreedToTerms = v!),
                                    activeColor: const Color(0xFF00695C),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: subtextColor),
                                      children: [
                                        TextSpan(
                                            text: AppStrings.get(
                                                'agree_terms', lang)),
                                        TextSpan(
                                          text: AppStrings.get(
                                              'terms_conditions', lang),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0xFF00695C),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                            text:
                                                AppStrings.get('and', lang)),
                                        TextSpan(
                                          text: AppStrings.get(
                                              'privacy_policy', lang),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0xFF00695C),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00695C),
                                  disabledBackgroundColor:
                                      const Color(0xFF00695C).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                  elevation: 3,
                                  shadowColor: const Color(0xFF00695C)
                                      .withOpacity(0.3),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5),
                                      )
                                    : Text(
                                        AppStrings.get(
                                            'create_account', lang),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.get('have_account', lang),
                            style: GoogleFonts.poppins(
                                color: subtextColor, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          child: Text(
                            AppStrings.get('sign_in', lang),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF00695C),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 13, color: color));
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color fillColor,
    required Color borderColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF00695C), size: 20),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color(0xFF00695C), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
