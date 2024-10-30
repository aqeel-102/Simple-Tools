import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final Icon icon;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
