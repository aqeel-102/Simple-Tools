import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Main widget for the Time Converter screen
class TimeConverterHome extends StatefulWidget {
  const TimeConverterHome({super.key});

  @override
  State<TimeConverterHome> createState() => _TimeConverterHomeState();
}

class _TimeConverterHomeState extends State<TimeConverterHome> {
  // List to store selected timezones with abbreviations
  List<String> selectedTimezones = [
    'Europe/London', // GMT
    'America/New_York', // EST
    'Europe/Paris', // CET
    'Asia/Kolkata', // IST
    'Asia/Shanghai', // CST
    'Asia/Tokyo', // JST
    'Australia/Sydney', // AET
    'Asia/Dubai',
    'America/Los_Angeles',
    'Asia/Singapore',
    'Europe/Berlin',
    'Asia/Hong_Kong',
    'America/Chicago',
    'Pacific/Auckland',
    'Asia/Seoul',
    'Europe/Moscow',
    'Asia/Karachi'
  ];

  // List to store currently displayed timezones (max 4)
  List<String> displayedTimezones = [];

  // Map to store the current time for each timezone
  Map<String, DateTime> timesByZone = {};

  // Current base time used for calculations
  DateTime baseTime = DateTime.now();

  // Time format state (24/12 hour)
  bool is24HourFormat = true;

  @override
  void initState() {
    super.initState();
    // Initialize timezone data
    tz.initializeTimeZones();

    // Load any previously saved timezones and preferences
    _loadSavedTimezones();
    _loadTimeFormat();

    // Set initial times for all timezones
    _initializeTimesByZone();
  }

  // Sets current time for all selected timezones
  void _initializeTimesByZone() {
    for (var timezone in selectedTimezones) {
      final location = tz.getLocation(timezone);
      timesByZone[timezone] = tz.TZDateTime.now(location);
    }
  }

  // Loads previously saved timezones from device storage
  Future<void> _loadSavedTimezones() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimezones = prefs.getStringList('saved_timezones');
    if (savedTimezones != null) {
      setState(() {
        selectedTimezones = savedTimezones;
        displayedTimezones = savedTimezones.take(4).toList();
        _initializeTimesByZone();
      });
    } else {
      setState(() {
        displayedTimezones = selectedTimezones.take(4).toList();
      });
    }
  }

  // Loads saved time format preference
  Future<void> _loadTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      is24HourFormat = prefs.getBool('is_24_hour_format') ?? true;
    });
  }

  // Saves time format preference
  Future<void> _saveTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_24_hour_format', is24HourFormat);
  }

  // Saves current timezone selection to device storage
  Future<void> _saveTimezones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_timezones', selectedTimezones);
  }

  // Updates all timezone times when one is changed
  void _updateAllTimes(String changedTimezone, DateTime newTime) {
    final location = tz.getLocation(changedTimezone);
    final tzDateTime = tz.TZDateTime.from(newTime, location);

    setState(() {
      // Update each timezone based on the changed time
      for (var timezone in selectedTimezones) {
        if (timezone != changedTimezone) {
          final targetLocation = tz.getLocation(timezone);
          timesByZone[timezone] =
              tz.TZDateTime.from(tzDateTime, targetLocation);
        }
      }
      timesByZone[changedTimezone] = newTime;
    });
  }

  // Gets timezone abbreviation
  String _getTimezoneAbbr(String timezone) {
    switch (timezone) {
      case 'Europe/London':
        return 'GMT';
      case 'America/New_York':
        return 'EST';
      case 'Europe/Paris':
        return 'CET';
      case 'Asia/Kolkata':
        return 'IST';
      case 'Asia/Shanghai':
        return 'CST';
      case 'Asia/Tokyo':
        return 'JST';
      case 'Australia/Sydney':
        return 'AET';
      default:
        return timezone.split('/').last.replaceAll('_', ' ');
    }
  }

  // Formats timezone offset to display (e.g. UTC+9:00)
  String _getFormattedOffset(String timezone) {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = (offset.inMinutes % 60).abs();
    return 'UTC${hours >= 0 ? '+' : ''}$hours:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Zone Converter'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // Time format toggle button
          IconButton(
            icon: Icon(
                is24HourFormat ? Icons.access_time : Icons.access_time_filled),
            onPressed: () {
              setState(() {
                is24HourFormat = !is24HourFormat;
                _saveTimeFormat();
              });
            },
            tooltip: '${is24HourFormat ? "12" : "24"} hour format',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                baseTime = DateTime.now();
                _initializeTimesByZone();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: displayedTimezones.length + 1,
              itemBuilder: (context, index) {
                // Add timezone button at the end of the list
                if (index == displayedTimezones.length) {
                  return _buildAddTimezoneButton(context);
                }

                // Display timezone cards
                final timezone = displayedTimezones[index];
                final time = timesByZone[timezone] ?? DateTime.now();
                final location = tz.getLocation(timezone);

                return _buildTimezoneCard(context, timezone, time, location);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Builds the "Add Timezone" button
  Widget _buildAddTimezoneButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Time Zone'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          padding: const EdgeInsets.all(16),
        ),
        onPressed: () {
          if (displayedTimezones.length >= 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please delete a timezone card before adding a new one'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            _showAddTimezoneDialog(context);
          }
        },
      ),
    );
  }

  // Shows dialog to add a new timezone
  Future<void> _showAddTimezoneDialog(BuildContext context) async {
    List<String> allTimezones = tz.timeZoneDatabase.locations.keys.toList()
      ..sort();
    String searchQuery = '';
    List<String> filteredTimezones = allTimezones;

    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  const Text('Select Timezone'),
                  const SizedBox(height: 8),
                  TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z]'))
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                        filteredTimezones = allTimezones
                            .where((timezone) =>
                                timezone.toLowerCase().contains(searchQuery))
                            .toList();
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredTimezones.length,
                  itemBuilder: (context, index) {
                    final timezone = filteredTimezones[index];
                    final location = tz.getLocation(timezone);
                    final now = tz.TZDateTime.now(location);

                    return ListTile(
                      title: Text(
                          '${_getTimezoneAbbr(timezone)} - ${timezone.split('/').last.replaceAll('_', ' ')}'),
                      subtitle:
                          Text('${timezone}\n${_getFormattedOffset(timezone)}'),
                      trailing: Text(
                        DateFormat(is24HourFormat ? 'HH:mm' : 'hh:mm a')
                            .format(now),
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(timezone);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );

    // Add the selected timezone if it's not already in the list
    if (selected != null && !selectedTimezones.contains(selected)) {
      setState(() {
        selectedTimezones.add(selected);
        if (displayedTimezones.length < 4) {
          displayedTimezones.add(selected);
        }
        final location = tz.getLocation(selected);
        timesByZone[selected] = tz.TZDateTime.now(location);
        _saveTimezones();
      });
    }
  }

  // Builds a card displaying timezone information
  Widget _buildTimezoneCard(BuildContext context, String timezone,
      DateTime time, tz.Location location) {
    return Dismissible(
      key: Key(timezone),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          displayedTimezones.remove(timezone);
          _saveTimezones();
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTimezoneHeader(context, timezone, location),
                  ),
                  _buildTimeDisplay(context, time),
                ],
              ),
              const SizedBox(height: 16),
              _buildTimeControls(context, timezone, time),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the header section of the timezone card
  Widget _buildTimezoneHeader(
      BuildContext context, String timezone, tz.Location location) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getTimezoneAbbr(timezone)} - ${timezone.split('/').last.replaceAll('_', ' ')}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                _getFormattedOffset(timezone),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormat('EEE, MMM d').format(tz.TZDateTime.now(location)),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Builds the time display section
  Widget _buildTimeDisplay(BuildContext context, DateTime time) {
    return GestureDetector(
      onTap: () {
        _showTimePickerDialog(context, time);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat(is24HourFormat ? 'HH:mm' : 'hh:mm a').format(time),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Shows time picker dialog
  void _showTimePickerDialog(BuildContext context, DateTime initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: is24HourFormat,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newTime = DateTime(
        initialTime.year,
        initialTime.month,
        initialTime.day,
        picked.hour,
        picked.minute,
      );
      _updateAllTimes(selectedTimezones[0], newTime);
    }
  }

  // Builds the time control sliders
  Widget _buildTimeControls(
      BuildContext context, String timezone, DateTime time) {
    // Convert hours and minutes to a single value between 0-720 (12*60) or 0-1440 (24*60)
    double timeValue;
    double maxValue;
    if (is24HourFormat) {
      timeValue = time.hour * 60 + time.minute.toDouble();
      maxValue = 1439; // 23 hours 59 minutes
    } else {
      int hour12 = time.hour % 12;
      timeValue = hour12 * 60 + time.minute.toDouble();
      maxValue = 719; // 11 hours 59 minutes
    }

    return Row(
      children: [
        const Icon(Icons.access_time, size: 20),
        const SizedBox(width: 8),
        const Text('Time: '),
        Expanded(
          child: Slider(
            value: timeValue,
            min: 0,
            max: maxValue,
            divisions: maxValue.toInt(),
            label: is24HourFormat
                ? '${(timeValue ~/ 60).toString().padLeft(2, '0')}:${(timeValue % 60).round().toString().padLeft(2, '0')}'
                : '${((timeValue ~/ 60) % 12 == 0 ? 12 : (timeValue ~/ 60) % 12).toString().padLeft(2, '0')}:${(timeValue % 60).round().toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}',
            onChanged: (value) {
              int hours;
              if (is24HourFormat) {
                hours = value ~/ 60;
              } else {
                int hour12 = value ~/ 60;
                bool isPM = time.hour >= 12;
                hours = isPM
                    ? (hour12 == 0 ? 12 : hour12) + 12
                    : (hour12 == 0 ? 0 : hour12);
              }
              final minutes = (value % 60).round();
              final newTime = DateTime(
                time.year,
                time.month,
                time.day,
                hours,
                minutes,
              );
              _updateAllTimes(timezone, newTime);
            },
          ),
        ),
      ],
    );
  }
}
