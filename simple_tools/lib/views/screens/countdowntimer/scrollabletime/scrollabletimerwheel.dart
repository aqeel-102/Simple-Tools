import 'package:flutter/material.dart';

class ScrollableTimeWheel extends StatelessWidget {
  final String label;
  final int max;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const ScrollableTimeWheel({
    super.key,
    required this.label,
    required this.max,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        SizedBox(
          height: 100,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 30,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                );
              },
              childCount: max + 1,
            ),
          ),
        ),
      ],
    );
  }
}
