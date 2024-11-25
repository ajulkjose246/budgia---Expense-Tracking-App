import 'package:budgia/main.dart';
import 'package:budgia/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgia/utils/currency_utils.dart';
import 'package:budgia/utils/language_utils.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _nameController = TextEditingController();
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0E21),
            const Color(0xFF0A0E21).withOpacity(0.8),
            Colors.indigo.withOpacity(0.3),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.04),
                  // Updated Welcome Text styling with responsive font sizes
                  Text(
                    'Welcome to\nBudgia',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 32 : 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Let\'s personalize your experience',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),

                  // Input Fields with responsive spacing
                  _buildInputField(
                    controller: _nameController,
                    label: 'Your Name',
                    icon: Icons.person_outline,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildDropdownField(
                    value: _selectedCurrency,
                    label: 'Currency',
                    icon: Icons.attach_money,
                    items: CurrencyUtils.currencies.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency['code'].toString(),
                        child: Text(
                          '${currency['name']} (${currency['symbol']})',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCurrency = value!),
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  _buildDropdownField(
                    value: _selectedLanguage,
                    label: 'Language',
                    icon: Icons.language,
                    items: LanguageUtils.languages.map((language) {
                      return DropdownMenuItem(
                        value: language['code'],
                        child: Text(
                          language['name']!,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedLanguage = value!),
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: screenSize.height * 0.06),

                  // Updated Continue Button with responsive height
                  SizedBox(
                    width: double.infinity,
                    height: screenSize.height * 0.07,
                    child: ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Add bottom padding to ensure content is visible above system navigation
                  SizedBox(height: screenSize.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated input field styling with responsiveness
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isSmallScreen ? 13 : 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: isSmallScreen ? 20 : 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isSmallScreen ? 12 : 16,
          ),
        ),
      ),
    );
  }

  // Updated dropdown styling with responsiveness
  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF0A0E21),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isSmallScreen ? 13 : 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: isSmallScreen ? 20 : 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isSmallScreen ? 12 : 16,
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Name must be at least 3 characters long')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('selected_currency', _selectedCurrency);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setBool('hasSeenIntro', true);

    if (mounted) {
      // Update the app's locale before navigation
      final myAppState = context.findAncestorStateOfType<MyAppState>();
      myAppState?.setLocale(Locale(_selectedLanguage));

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
