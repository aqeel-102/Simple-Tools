import 'package:flutter/material.dart';

class NoiseCustom extends StatelessWidget {
  final Widget title;
  final String sound;
  final IconData icon;  // Icon parameter

  const NoiseCustom({super.key,
    required this.title,
    required this.sound,
    required this.icon,  // Accept icon as a parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,  // Display the passed icon
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 10),
          title,  // Display the title below the icon
        ],
      ),
    );
  }
}

