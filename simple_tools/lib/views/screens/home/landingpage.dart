import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/util/favoritelist.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/recipe_main_screen.dart';
import 'package:simple_tools/views/screens/White%20Noise%20Generator/mainscreennoisegenerator.dart';
import 'package:simple_tools/views/screens/barcodegenerator/barcodegeneratormainscreen.dart';
import 'package:simple_tools/views/screens/barcodescanner/barcodescanner.dart';
import 'package:simple_tools/views/screens/bmi/bmi.dart';
import 'package:simple_tools/views/screens/bmr/bmr.dart';
import 'package:simple_tools/views/screens/chessclock/chesshome.dart';
import 'package:simple_tools/views/screens/compass/compassmain.dart';
import 'package:simple_tools/views/screens/countdowntimer/mainscreenofcountdown.dart';
import 'package:simple_tools/views/screens/home/catogory/health&fitness.dart';
import 'package:simple_tools/views/screens/home/catogory/productivity.dart';
import 'package:simple_tools/views/screens/home/catogory/utilities.dart';
import 'package:simple_tools/views/screens/home/home.dart';
import 'package:simple_tools/views/screens/home/settingpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/kiblafinder/kabbacompassmain.dart';
import 'package:simple_tools/views/screens/passwordmanager/landingforpasswordmanager';
import 'package:simple_tools/views/screens/phoneusageapp/usagehomescreen.dart';
import 'package:simple_tools/views/screens/pomodorotimer/pomodorohome.dart';
import 'package:simple_tools/views/screens/qrgenerator/qrcodegenerator.dart';
import 'package:simple_tools/views/screens/simpackage/prepaid_recharge_calculator.dart';
import 'package:simple_tools/views/screens/sleeptimerecord/sleeptimehomepage.dart';
import 'package:simple_tools/views/screens/timeconverter/timeconverterhome.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakathome.dart';

import '../studytimer/studytimerhomescreen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String userName = "User";
  String? profilePicPath;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSavedTools();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('username') ?? "User";
      profilePicPath = prefs.getString('profile_image');
    });
  }

  Future<void> _loadSavedTools() async {
    await SavedTools.loadSavedTools();

    // Create a new list to store updated tools
    List<Map<String, dynamic>> updatedTools = [];

    // Update each tool with its corresponding screen
    for (var tool in SavedTools.savedTools) {
      updatedTools.add({
        'title': tool['title'],
        'icon': tool['icon'],
        'nextScreen': _getScreenForTool(tool['title']),
      });
    }

    // Update the savedTools list
    SavedTools.savedTools.clear();
    SavedTools.savedTools.addAll(updatedTools);

    if (mounted) {
      setState(() {});
    }
  }

  Widget _getScreenForTool(String title) {
    switch (title) {
      case AppConstants.mobileRecharge:
        return const PrepaidRechargeCalculator();
      case AppConstants.bmi:
        return const Startup();
      case AppConstants.bmr:
        return const BMR();
      case AppConstants.timer:
        return const TimerScreen1();
      case AppConstants.compassTitle:
        return MyRecentCompass();
      case AppConstants.barCode:
        return const BarcodeScanner();
      case AppConstants.qiblaFinderButton:
        return QiblaCompass();
      case AppConstants.zakat:
        return ZakatCalculatorApp();
      case AppConstants.reciepeOrganizer:
        return RecipeMainScreen();
      case AppConstants.whiteNoiseGenerator:
        return WhiteNoiseGenerator();
      case AppConstants.passwordManager:
        return LandingForPasswordManager();
      case AppConstants.chessClock:
        return ChessHome();
      case AppConstants.qrCodeGenerator:
        return QRCodeGenerator();
      case AppConstants.barCodeGEnerator:
        return BarcodeGeneratorMainScreen();
      case AppConstants.pomodorotimer:
        return PomodoroHome();
      case AppConstants.studyTimer:
        return StudyTimerHomeScreen();
      case AppConstants.timeConverter:
        return TimeConverterHome();
      case AppConstants.sleepTimeTracker:
        return SleepTimeHomePage();
      case AppConstants.deviceUsage:
        return UsageHomeScreen();
      default:
        return const SizedBox(); // Fallback widget
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingPage()),
                ).then((_) => _loadUserData());
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppConstants.mainColor.withOpacity(0.1),
                backgroundImage: profilePicPath != null
                    ? FileImage(File(profilePicPath!))
                    : null,
                child: profilePicPath == null
                    ? Icon(
                        Icons.person,
                        color: AppConstants.mainColor,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.mainColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories Section
              Container(
                height: 140,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductivityPage()),
                            );
                          },
                          child: _buildCategoryCard(
                            'Productivity',
                            Icons.rocket_launch_rounded,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HealthAndFitnessPage()),
                            );
                          },
                          child: _buildCategoryCard(
                            'Health & Fitness',
                            Icons.favorite_rounded,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UtilitiesPage()),
                            );
                          },
                          child: _buildCategoryCard(
                            'Utilities',
                            Icons.construction_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Access Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quick Access',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.mainColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SavedTools.savedTools.isEmpty
                              ? Center(
                                  child: Text(
                                    'No tools added to Quick Access yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: SavedTools.savedTools.length,
                                  itemBuilder: (context, index) {
                                    final tool = SavedTools.savedTools[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                tool['nextScreen'],
                                          ),
                                        );
                                      },
                                      onLongPress: () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Remove Tool'),
                                              content: const Text(
                                                  'Do you want to remove this tool from Quick Access?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await SavedTools.removeTool(
                                                        tool['title']);
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Remove'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: _buildToolItem(
                                        tool['title'],
                                        tool['icon'],
                                        tool['nextScreen'],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppConstants.mainColor,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(title: 'Simple Tools'),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingPage()),
            ).then((_) => _loadUserData());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'All Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: AppConstants.mainColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppConstants.mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem(String title, String image, Widget nextScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.secColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.secColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              image,
              width: 24,
              height: 24,
              color: AppConstants.mainColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppConstants.mainColor.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}
