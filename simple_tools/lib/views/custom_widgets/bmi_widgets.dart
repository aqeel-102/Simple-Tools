import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Custom Container Widget
class CustomContainer extends StatelessWidget {
  final Widget? cardchild;
  final Color? colors;

  const CustomContainer({super.key,
    required this.colors,
    this.cardchild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(10, 8),
            blurRadius: 10,
            color: const Color.fromARGB(255, 78, 78, 78).withOpacity(0.5),
          ),
        ],
      ),
      child: cardchild,
    );
  }
}

// Custom Container Card
class Containcard extends StatelessWidget {
  final IconData icon;
  final String txt;

  const Containcard({super.key,
    required this.icon,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 80,
          color: const Color.fromARGB(255, 172, 171, 170),
        ),
        const SizedBox(height: 20),
        Text(
          txt,
          style: const TextStyle(color: Colors.white60),
        ),
      ],
    );
  }
}

// Round Button Widget
class RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onpressed;

  const RoundButton({
    required this.icon,
    required this.onpressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onpressed,
      constraints: const BoxConstraints.tightFor(
        width: 50.0,
        height: 50.0,
      ),
      shape: const CircleBorder(),
      fillColor: const Color(0xFF4C4F5E),
      child: Icon(icon),
    );
  }
}

