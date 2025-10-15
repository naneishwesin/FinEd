// lib/pages/initial_profile_setup_page.dart
import 'package:flutter/material.dart';

import '../main_app.dart';
import '../utils/page_transitions.dart';

class InitialProfileSetupPage extends StatefulWidget {
  const InitialProfileSetupPage({super.key});

  @override
  _InitialProfileSetupPageState createState() =>
      _InitialProfileSetupPageState();
}

class _InitialProfileSetupPageState extends State<InitialProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCurrency = 'THB';
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  final List<Map<String, String>> _currencies = [
    {'code': 'THB', 'name': 'Thai Baht (฿)'},
    {'code': 'USD', 'name': 'US Dollar (\$)'},
    {'code': 'EUR', 'name': 'Euro (€)'},
    {'code': 'GBP', 'name': 'British Pound (£)'},
    {'code': 'JPY', 'name': 'Japanese Yen (¥)'},
  ];

  final List<String> _languages = [
    'English',
    'ไทย (Thai)',
    '中文 (Chinese)',
    '日本語 (Japanese)',
  ];
  final List<String> _themes = ['Light', 'Dark', 'Auto'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Setup Your Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 48, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      "Let's personalize your experience",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tell us a bit about yourself to get started",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Personal Information Section
              _buildSectionHeader("Personal Information", Icons.person),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: "Phone Number (Optional)",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 30),

              // Preferences Section
              _buildSectionHeader("Preferences", Icons.settings),
              const SizedBox(height: 16),

              // Currency Selection
              _buildDropdownField(
                label: "Default Currency",
                icon: Icons.attach_money,
                value: _selectedCurrency,
                items: _currencies
                    .map(
                      (currency) => DropdownMenuItem(
                        value: currency['code'],
                        child: Text(currency['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Language Selection
              _buildDropdownField(
                label: "Language",
                icon: Icons.language,
                value: _selectedLanguage,
                items: _languages
                    .map(
                      (language) => DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Theme Selection
              _buildDropdownField(
                label: "Theme",
                icon: Icons.palette,
                value: _selectedTheme,
                items: _themes
                    .map(
                      (theme) =>
                          DropdownMenuItem(value: theme, child: Text(theme)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Complete Setup",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Skip for now button
              Center(
                child: TextButton(
                  onPressed: _skipSetup,
                  child: const Text(
                    "Skip for now",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Setting up your profile..."),
              ],
            ),
          );
        },
      );

      // Simulate profile setup delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile setup completed successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Save onboarding completion status
        // TODO: Save onboarding completion to database
        // await DatabaseService().saveOnboardingCompleted(true);

        // Navigate to main app
        AnimatedNavigation.replaceWithAnimation(context, MainApp());
      });
    }
  }

  void _skipSetup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Skip Setup?"),
          content: const Text(
            "You can set up your profile later in the settings. Continue to the app?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Save onboarding completion status
                // TODO: Save onboarding completion to database
                // await DatabaseService().saveOnboardingCompleted(true);

                AnimatedNavigation.replaceWithAnimation(context, MainApp());
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Skip", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
