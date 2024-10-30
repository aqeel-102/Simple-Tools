import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? _imagePath;
  String _username = '';
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('profile_image');
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', _imagePath ?? '');
    await prefs.setString('username', _username);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      await _saveUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppConstants.mainColor.withOpacity(0.1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18),
                      color: Colors.white,
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).primaryColor.withOpacity(0.05),
              prefixIcon: Icon(
                Icons.person_outline,
                color: Theme.of(context).primaryColor,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            controller: TextEditingController(text: _username),
            onChanged: (value) {
              _username = value;
              _saveUserData();
            },
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Simple Tools',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 48,
                  height: 48,
                ),
                children: const [
                  Text('A collection of simple and useful tools.'),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Add privacy policy navigation
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () {
              // Add terms of service navigation
            },
          ),
        ],
      ),
    );
  }
}
