import 'package:flutter/material.dart';

class ScrollableTimeWheel extends StatefulWidget {
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
  _ScrollableTimeWheelState createState() => _ScrollableTimeWheelState();
}

class _ScrollableTimeWheelState extends State<ScrollableTimeWheel> {
  int selectedValue = 0;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            squeeze: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() {
                selectedValue = index;
              });
              widget.onChanged(index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                bool isSelected = index == selectedValue;
                return Center(
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      color: isSelected ? Color(0xffdcd8d7) : Colors.white,
                      fontSize: isSelected ? 30 : 24,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
              childCount: widget.max + 1,
            ),
          ),
        ),
      ],
    );
  }
}
