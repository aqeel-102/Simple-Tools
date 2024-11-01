import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/util/catogoryselectionlist.dart';
import 'package:simple_tools/views/screens/bmi/bmi.dart';
import 'package:simple_tools/views/screens/bmr/bmr.dart';
import 'dart:convert';

import 'package:simple_tools/views/screens/deviceinfo/deviceinfohomepage';

class HealthAndFitnessPage extends StatefulWidget {
  const HealthAndFitnessPage({super.key});

  @override
  State<HealthAndFitnessPage> createState() => _HealthAndFitnessPageState();
}

class _HealthAndFitnessPageState extends State<HealthAndFitnessPage> {
  final List<Widget> _toolCards = [];
  final List<Tool> _selectedTools = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTools();
  }

  void _loadSavedTools() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTools = prefs.getStringList('selectedHealthTools');

    if (savedTools != null) {
      for (var toolJson in savedTools) {
        final Map<String, dynamic> toolMap = json.decode(toolJson);
        final tool = ToolsList.allTools.firstWhere(
          (t) => t.title == toolMap['title'],
          orElse: () => ToolsList.allTools[0],
        );
        _selectedTools.add(tool);
      }
    } else {
      _selectedTools.addAll([
        Tool(
          title: AppConstants.bmi,
          icon: Icons.monitor_weight_outlined,
          nextScreen: Startup(),
        ),
        Tool(
          title: AppConstants.bmr,
          icon: Icons.local_fire_department_outlined,
          nextScreen: BMR(),
        ),
        Tool(
          title: AppConstants.deviceUsage,
          icon: Icons.timer_outlined,
          nextScreen: DeviceInfoHomePage(),
        ),
      ]);
    }

    _rebuildToolCards();
  }

  void _saveTools() async {
    final prefs = await SharedPreferences.getInstance();
    final toolsToSave = _selectedTools
        .map((tool) => json.encode({
              'title': tool.title,
            }))
        .toList();
    await prefs.setStringList('selectedHealthTools', toolsToSave);
  }

  void _rebuildToolCards() {
    _toolCards.clear();
    for (var tool in _selectedTools) {
      _toolCards.add(
        _buildToolCard(
          title: tool.title,
          nextScreen: tool.nextScreen,
          icon: tool.icon,
        ),
      );
    }
    setState(() {});
  }

  Widget _buildToolCard({
    required String title,
    required Widget nextScreen,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        },
        onLongPress: () {
          if (!_isDefaultTool(title)) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Tool'),
                content: Text('Do you want to remove $title from your tools?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTools
                            .removeWhere((tool) => tool.title == title);
                        _rebuildToolCards();
                        _saveTools();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.mainColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppConstants.mainColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDefaultTool(String title) {
    return title == AppConstants.bmi ||
        title == AppConstants.bmr ||
        title == AppConstants.deviceUsage;
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add New Tool'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ToolsList.allTools.length,
                itemBuilder: (context, index) {
                  final tool = ToolsList.allTools[index];
                  bool isAdded =
                      _selectedTools.any((t) => t.title == tool.title);
                  return ListTile(
                    enabled: !isAdded,
                    leading: Icon(tool.icon),
                    title: Text(tool.title),
                    trailing: isAdded ? const Icon(Icons.check) : null,
                    onTap: () {
                      if (!isAdded) {
                        setState(() {
                          _selectedTools.add(tool);
                          _rebuildToolCards();
                          _saveTools();
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppConstants.mainColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: AppConstants.mainColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'Add New Tool',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Health & Fitness Tools',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Track your health and fitness goals',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    ..._toolCards,
                    _buildAddButton(context),
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
