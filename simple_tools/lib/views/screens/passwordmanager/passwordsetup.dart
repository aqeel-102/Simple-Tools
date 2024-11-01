import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordSetup extends StatefulWidget {
  const PasswordSetup({super.key});

  @override
  _PasswordSetupState createState() => _PasswordSetupState();
}

class _PasswordSetupState extends State<PasswordSetup> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _answer1Controller = TextEditingController();
  final TextEditingController _answer2Controller = TextEditingController();
  final TextEditingController _answer3Controller = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorText;
  bool _hasPassword = false;
  bool _isPasswordEnabled = true;

  final _formKey = GlobalKey<FormState>();

  // Predefined security questions
  final List<String> _securityQuestions = [
    "What was the name of your first pet?",
    "In which city were you born?",
    "What is your mother's maiden name?"
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingPassword();
  }

  Future<void> _checkExistingPassword() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedPassword = prefs.getString('app_password');
      final bool? isEnabled = prefs.getBool('password_enabled');
      setState(() {
        _hasPassword = savedPassword != null;
        _isPasswordEnabled = isEnabled ?? true;
      });
    } catch (e) {
      debugPrint('Error checking existing password: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _answer1Controller.dispose();
    _answer2Controller.dispose();
    _answer3Controller.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateSecurityAnswer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Answer is required';
    }
    if (value.length < 3) {
      return 'Answer must be at least 3 characters';
    }
    return null;
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorText = 'Passwords do not match';
      });
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('app_password', _passwordController.text);
      await prefs.setString('security_question1', _securityQuestions[0]);
      await prefs.setString('security_question2', _securityQuestions[1]);
      await prefs.setString('security_question3', _securityQuestions[2]);
      await prefs.setString(
          'security_answer1', _answer1Controller.text.toLowerCase());
      await prefs.setString(
          'security_answer2', _answer2Controller.text.toLowerCase());
      await prefs.setString(
          'security_answer3', _answer3Controller.text.toLowerCase());
      await prefs.setBool('password_enabled', true);

      setState(() {
        _hasPassword = true;
        _isPasswordEnabled = true;
        _errorText = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and security questions saved successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorText = 'Error saving password. Please try again.';
      });
      debugPrint('Error saving password: $e');
    }
  }

  Future<void> _togglePassword() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('password_enabled', !_isPasswordEnabled);

      setState(() {
        _isPasswordEnabled = !_isPasswordEnabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isPasswordEnabled ? 'Password enabled' : 'Password disabled'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error toggling password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_hasPassword) ...[
                      const Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Secure Your Data',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Set up a password and security questions to protect your information',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                validator: _validatePassword,
                                decoration: InputDecoration(
                                  labelText: 'Create Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: _validatePassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setState(() =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Security Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(3, (index) {
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _securityQuestions[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: [
                                    _answer1Controller,
                                    _answer2Controller,
                                    _answer3Controller,
                                  ][index],
                                  validator: _validateSecurityAnswer,
                                  decoration: const InputDecoration(
                                    labelText: 'Your Answer',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _savePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Set Up Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          title: const Text('Password Protection'),
                          subtitle:
                              Text(_isPasswordEnabled ? 'Enabled' : 'Disabled'),
                          trailing: Switch(
                            value: _isPasswordEnabled,
                            onChanged: (value) => _togglePassword(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _hasPassword = false;
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                              _answer1Controller.clear();
                              _answer2Controller.clear();
                              _answer3Controller.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Change Password'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
