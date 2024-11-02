import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/util/catogoryselectionlist.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/recipe_main_screen.dart';
import 'package:simple_tools/views/screens/pomodorotimer/pomodorohome';
import 'dart:convert';

import '../../studytimer/studytimerhomescreen.dart';

class ProductivityPage extends StatefulWidget {
  const ProductivityPage({super.key});

  @override
  State<ProductivityPage> createState() => _ProductivityPageState();
}

class _ProductivityPageState extends State<ProductivityPage> {
  final List<Widget> _toolCards = [];
  final List<Tool> _selectedTools = [];

  @override
  void initState() {
    super.initState();
    // Load saved tools or use defaults
    _loadSavedTools();
  }

  void _loadSavedTools() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTools = prefs.getStringList('selectedTools');

    if (savedTools != null) {
      // Load saved tools
      for (var toolJson in savedTools) {
        final Map<String, dynamic> toolMap = json.decode(toolJson);
        final tool = ToolsList.allTools.firstWhere(
          (t) => t.title == toolMap['title'],
          orElse: () => ToolsList.allTools[0],
        );
        _selectedTools.add(tool);
      }
    } else {
      // Add default tools if no saved tools exist
      _selectedTools.addAll([
        Tool(
          title: AppConstants.pomodorotimer,
          icon: Icons.timer,
          nextScreen: PomodoroHome(),
        ),
        Tool(
          title: AppConstants.studyTimer,
          icon: Icons.school,
          nextScreen: StudyTimerHomeScreen(),
        ),
        Tool(
          title: AppConstants.reciepeOrganizer,
          icon: Icons.task_alt,
          nextScreen: RecipeMainScreen(),
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
    await prefs.setStringList('selectedTools', toolsToSave);
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
          // Only show delete dialog for non-default tools
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
    return title == AppConstants.pomodorotimer ||
        title == AppConstants.studyTimer ||
        title == AppConstants.reciepeOrganizer;
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
          'Productivity Tools',
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
                  'Boost your productivity with these tools',
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
