import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedTools {
  static final List<Map<String, dynamic>> savedTools = [];
  static const String _storageKey = 'saved_tools';

  // Load saved tools from SharedPreferences
  static Future<void> loadSavedTools() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedToolsJson = prefs.getString(_storageKey);

    if (savedToolsJson != null) {
      final List<dynamic> decodedList = json.decode(savedToolsJson);
      savedTools.clear();
      for (var item in decodedList) {
        // Note: We can't store Widget objects in SharedPreferences
        // So we'll store the tool data without the Widget
        savedTools.add({
          'title': item['title'],
          'icon': item['icon'],
          // The nextScreen will be reconstructed when needed
        });
      }
    }
  }

  // Save current tools to SharedPreferences
  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> storableTools = savedTools
        .map((tool) => {
              'title': tool['title'],
              'icon': tool['icon'],
            })
        .toList();

    await prefs.setString(_storageKey, json.encode(storableTools));
  }

  static Future<void> removeTool(String title) async {
    savedTools.removeWhere((tool) => tool['title'] == title);
    await _saveToPrefs();
  }

  static Future<void> addTool(
      String title, String icon, Widget nextScreen) async {
    // Check if tool already exists
    if (!savedTools.any((tool) => tool['title'] == title)) {
      savedTools.add({
        'title': title,
        'icon': icon,
        'nextScreen': nextScreen,
      });
      await _saveToPrefs();
    }
  }

  static bool isToolSaved(String title) {
    return savedTools.any((tool) => tool['title'] == title);
  }
}
