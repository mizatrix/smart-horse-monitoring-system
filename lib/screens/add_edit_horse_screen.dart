
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_horse/services/mock_data_service.dart';
import 'package:uuid/uuid.dart';
import '../services/theme_provider.dart';
import '../services/locale_provider.dart';
import '../services/app_strings.dart';

class AddEditHorseScreen extends StatefulWidget {
  final Horse? horse;

  const AddEditHorseScreen({super.key, this.horse});

  @override
  State<AddEditHorseScreen> createState() => _AddEditHorseScreenState();
}

class _AddEditHorseScreenState extends State<AddEditHorseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _customBreedController;
  String _selectedStatus = 'Stable';
  String? _selectedBreed;

  static const List<String> _breeds = [
    'Arabian', 'Thoroughbred', 'Quarter Horse', 'Appaloosa', 'Morgan',
    'Paint Horse', 'Friesian', 'Andalusian', 'Clydesdale', 'Mustang',
    'Hanoverian', 'Warmblood', 'Tennessee Walker', 'Saddlebred',
    'Standardbred', 'Shire', 'Percheron', 'Belgian', 'Lipizzaner',
    'Akhal-Teke', 'Haflinger', 'Lusitano', 'Trakehner', 'Other',
  ];

  String _selectedAvatar = 'assets/images/default_horse_avatar.png';
  final List<String> _avatars = [
    'assets/images/default_horse_avatar.png',
    'assets/images/horse_avatar_1.png',
    'assets/images/horse_avatar_2.png',
    'assets/images/horse_avatar_3.png',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.horse?.name ?? '');
    _ageController = TextEditingController(text: widget.horse?.age.toString() ?? '');
    _customBreedController = TextEditingController();

    if (widget.horse != null) {
      _selectedStatus = widget.horse!.status;
      _selectedAvatar = widget.horse!.imageUrl;
      if (_breeds.contains(widget.horse!.breed)) {
        _selectedBreed = widget.horse!.breed;
      } else {
        _selectedBreed = 'Other';
        _customBreedController.text = widget.horse!.breed;
      }
    }
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
    final fillColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey[50]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.horse == null ? AppStrings.get('add_horse', lang) : AppStrings.get('edit_horse', lang),
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Selection
              Center(
                child: GestureDetector(
                  onTap: () => _showAvatarPicker(isDark, cardColor, textColor, lang),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: AssetImage(_selectedAvatar), fit: BoxFit.cover),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFF00695C), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField(AppStrings.get('name', lang), _nameController, Icons.pets, fillColor, textColor),
              const SizedBox(height: 20),
              _buildBreedDropdown(fillColor, textColor, cardColor, lang),
              if (_selectedBreed == 'Other') ...[
                const SizedBox(height: 12),
                _buildTextField(lang == 'ar' ? 'سلالة مخصصة' : 'Custom Breed', _customBreedController, Icons.edit, fillColor, textColor),
              ],
              const SizedBox(height: 20),
              _buildTextField(AppStrings.get('age', lang), _ageController, Icons.cake, fillColor, textColor, isNumber: true),
              const SizedBox(height: 20),

              Text(AppStrings.get('health_status', lang), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 10),
              _buildStatusSelector(isDark, lang),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveHorse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    AppStrings.get('save_horse', lang),
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker(bool isDark, Color cardColor, Color textColor, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang == 'ar' ? 'اختر صورة' : 'Choose Avatar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = _avatars[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedAvatar == _avatars[index] ? const Color(0xFF00695C) : Colors.transparent,
                          width: 3,
                        ),
                        image: DecorationImage(image: AssetImage(_avatars[index]), fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, Color fillColor, Color textColor, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(color: textColor),
      validator: (value) => value!.isEmpty ? '$label required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: textColor.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFF00695C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
        ),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }

  Widget _buildStatusSelector(bool isDark, String lang) {
    final statuses = [
      {'key': 'Stable', 'label': AppStrings.get('stable_status', lang)},
      {'key': 'Warning', 'label': AppStrings.get('warning', lang)},
      {'key': 'Critical', 'label': AppStrings.get('critical', lang)},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: statuses.map((status) {
        bool isSelected = _selectedStatus == status['key'];
        Color color = status['key'] == 'Stable' ? Colors.green : (status['key'] == 'Warning' ? Colors.orange : Colors.red);
        return GestureDetector(
          onTap: () => setState(() => _selectedStatus = status['key']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
            ),
            child: Text(
              status['label']!,
              style: GoogleFonts.poppins(
                color: isSelected ? color : (isDark ? Colors.grey[400] : Colors.grey),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBreedDropdown(Color fillColor, Color textColor, Color cardColor, String lang) {
    return DropdownButtonFormField<String>(
      value: _selectedBreed,
      validator: (value) => value == null ? (lang == 'ar' ? 'يرجى اختيار السلالة' : 'Please select a breed') : null,
      style: GoogleFonts.poppins(color: textColor),
      decoration: InputDecoration(
        labelText: AppStrings.get('breed', lang),
        labelStyle: GoogleFonts.poppins(color: textColor.withOpacity(0.6)),
        prefixIcon: const Icon(Icons.category, color: Color(0xFF00695C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
        ),
        filled: true,
        fillColor: fillColor,
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00695C)),
      dropdownColor: cardColor,
      borderRadius: BorderRadius.circular(15),
      isExpanded: true,
      menuMaxHeight: 300,
      items: _breeds.map((breed) {
        return DropdownMenuItem(
          value: breed,
          child: Text(breed, style: GoogleFonts.poppins(fontSize: 14)),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedBreed = value),
    );
  }

  void _saveHorse() {
    if (_formKey.currentState!.validate()) {
      final mockService = Provider.of<MockDataService>(context, listen: false);
      final breed = _selectedBreed == 'Other' ? _customBreedController.text : (_selectedBreed ?? '');

      if (_selectedBreed == 'Other' && _customBreedController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a custom breed name', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newHorse = Horse(
        id: widget.horse?.id ?? const Uuid().v4(),
        name: _nameController.text,
        breed: breed,
        age: int.tryParse(_ageController.text) ?? 5,
        imageUrl: _selectedAvatar,
        status: _selectedStatus,
        location: widget.horse?.location ?? 'Stall 1',
        currentHeartRate: widget.horse?.currentHeartRate ?? 35.0,
        currentTemp: widget.horse?.currentTemp ?? 37.5,
        currentRespiration: widget.horse?.currentRespiration ?? 15,
        heartRateHistory: widget.horse?.heartRateHistory ?? [],
        tempHistory: widget.horse?.tempHistory ?? [],
      );

      if (widget.horse == null) {
        mockService.addHorse(newHorse);
      } else {
        mockService.updateHorse(newHorse);
      }

      Navigator.pop(context);
    }
  }
}
