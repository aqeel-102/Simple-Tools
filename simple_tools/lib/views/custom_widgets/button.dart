import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  final String value;
  final VoidCallback onPressed;

  const BottomButton({
    required this.value,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          Theme.of(context).colorScheme.primary, // Use your theme's main color
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }
}