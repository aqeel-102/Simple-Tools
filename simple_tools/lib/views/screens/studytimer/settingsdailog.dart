import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final int initialBreakTime;
  final Function(int) onSave;

  const SettingsDialog(
      {super.key, required this.initialBreakTime, required this.onSave});

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late int breakTime;

  @override
  void initState() {
    super.initState();
    breakTime = widget.initialBreakTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration:
                const InputDecoration(labelText: 'Break time (minutes)'),
            keyboardType: TextInputType.number,
            onChanged: (value) => breakTime = int.tryParse(value) ?? 5,
            controller: TextEditingController(text: breakTime.toString()),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            try {
              if (breakTime <= 0) {
                throw Exception('Break time must be greater than 0');
              }
              widget.onSave(breakTime);
            } catch (e) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
        ),
      ],
    );
  }
}
