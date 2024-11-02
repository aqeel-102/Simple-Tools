import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:simple_tools/util/app_constants.dart';

class PomodoroHome extends StatefulWidget {
  @override
  _PomodoroHomeState createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome> {
  int _workDuration = 25 * 60;
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;
  int _remainingTime = 25 * 60;
  int _completedPomodoros = 0;
  int _pomodorosUntilLongBreak = 4;
  bool _isWorking = true;
  bool _isRunning = false;
  Timer? _timer;
  AudioPlayer _audioPlayer = AudioPlayer();
  List<Task> _tasks = [];
  TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadTasks();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _workDuration =
          prefs.getInt('workDuration') ?? AppConstants.defaultWorkDuration;
      _shortBreakDuration = prefs.getInt('shortBreakDuration') ??
          AppConstants.defaultShortBreakDuration;
      _longBreakDuration = prefs.getInt('longBreakDuration') ??
          AppConstants.defaultLongBreakDuration;
      _pomodorosUntilLongBreak = prefs.getInt('pomodorosUntilLongBreak') ??
          AppConstants.defaultPomodorosUntilLongBreak;
      _remainingTime = _workDuration;
    });
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = tasksJson
            .map((taskJson) => Task.fromJson(json.decode(taskJson)))
            .toList();
      });
    }
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('workDuration', _workDuration);
    prefs.setInt('shortBreakDuration', _shortBreakDuration);
    prefs.setInt('longBreakDuration', _longBreakDuration);
    prefs.setInt('pomodorosUntilLongBreak', _pomodorosUntilLongBreak);
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson =
        _tasks.map((task) => json.encode(task.toJson())).toList();
    prefs.setStringList('tasks', tasksJson);
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _playAlarm();
          _switchMode();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingTime = _isWorking
          ? _workDuration
          : (_completedPomodoros % _pomodorosUntilLongBreak == 0
              ? _longBreakDuration
              : _shortBreakDuration);
    });
  }

  void _switchMode() {
    setState(() {
      if (_isWorking) {
        _completedPomodoros++;
        _isWorking = false;
        _remainingTime = _completedPomodoros % _pomodorosUntilLongBreak == 0
            ? _longBreakDuration
            : _shortBreakDuration;
      } else {
        _isWorking = true;
        _remainingTime = _workDuration;
      }
    });
  }

  void _playAlarm() async {
    await _audioPlayer.play(AssetSource(AppConstants.alarmSoundPath));
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(_taskController.text));
        _taskController.clear();
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.pomodoroAppBarTitle),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                color: AppConstants.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _isWorking
                            ? AppConstants.workTimeText
                            : AppConstants.breakTimeText,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _formatTime(_remainingTime),
                        style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _isRunning ? _pauseTimer : _startTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.textColor,
                            ),
                            child: Text(_isRunning
                                ? AppConstants.pauseButtonText
                                : AppConstants.startButtonText),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _resetTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.textColor,
                            ),
                            child: Text(AppConstants.resetButtonText),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${AppConstants.completedPomodorosText}: $_completedPomodoros',
                        style: TextStyle(
                            fontSize: 18, color: AppConstants.textColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: AppConstants.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.settingsText,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textColor)),
                      SizedBox(height: 10),
                      _buildDurationSetting(
                          AppConstants.workDurationText,
                          _workDuration,
                          (value) => setState(() => _workDuration = value)),
                      _buildDurationSetting(
                          AppConstants.shortBreakDurationText,
                          _shortBreakDuration,
                          (value) =>
                              setState(() => _shortBreakDuration = value)),
                      _buildDurationSetting(
                          AppConstants.longBreakDurationText,
                          _longBreakDuration,
                          (value) =>
                              setState(() => _longBreakDuration = value)),
                      _buildNumberSetting(
                          AppConstants.pomodorosUntilLongBreakText,
                          _pomodorosUntilLongBreak,
                          (value) =>
                              setState(() => _pomodorosUntilLongBreak = value)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _saveSettings();
                          _resetTimer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.textColor,
                        ),
                        child: Text(AppConstants.saveSettingsButtonText),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: AppConstants.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.tasksText,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textColor)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _taskController,
                              maxLength: 15,
                              decoration: InputDecoration(
                                hintText: AppConstants.enterTaskHintText,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: AppConstants.textColor
                                          .withOpacity(0.5)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                      color: AppConstants.textColor
                                          .withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: AppConstants.textColor),
                                ),
                                fillColor:
                                    AppConstants.textColor.withOpacity(0.1),
                                filled: true,
                                hintStyle: TextStyle(
                                    color: AppConstants.textColor
                                        .withOpacity(0.5)),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              style: TextStyle(color: AppConstants.textColor),
                              cursorColor: AppConstants.textColor,
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _addTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.textColor,
                            ),
                            child: Text(AppConstants.addTaskButtonText),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_tasks[index].name,
                                style:
                                    TextStyle(color: AppConstants.textColor)),
                            leading: Checkbox(
                              value: _tasks[index].isCompleted,
                              onChanged: (bool? value) {
                                setState(() {
                                  _tasks[index].isCompleted = value!;
                                });
                                _saveTasks();
                              },
                              fillColor: WidgetStateProperty.all(
                                  AppConstants.activeColor),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete,
                                  color: AppConstants.textColorBlack),
                              onPressed: () => _deleteTask(index),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSetting(
      String label, int duration, Function(int) onChanged) {
    return ListTile(
      title: Text(label, style: TextStyle(color: AppConstants.textColor)),
      trailing: DropdownButton<int>(
        value: duration ~/ 60,
        items: List.generate(60, (index) => index + 1)
            .map((int value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value ${AppConstants.minuteText}',
                      style: TextStyle(color: AppConstants.textColor)),
                ))
            .toList(),
        onChanged: (int? value) {
          if (value != null) {
            onChanged(value * 60);
          }
        },
        dropdownColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildNumberSetting(String label, int value, Function(int) onChanged) {
    return ListTile(
      title: Text(label, style: TextStyle(color: AppConstants.textColor)),
      trailing: DropdownButton<int>(
        value: value,
        items: List.generate(10, (index) => index + 1)
            .map((int value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value',
                      style: TextStyle(color: AppConstants.textColor)),
                ))
            .toList(),
        onChanged: (int? value) {
          if (value != null) {
            onChanged(value);
          }
        },
        dropdownColor: AppConstants.primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _taskController.dispose();
    super.dispose();
  }
}

class Task {
  String name;
  bool isCompleted;

  Task(this.name, {this.isCompleted = false});

  Map<String, dynamic> toJson() => {
        'name': name,
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        json['name'],
        isCompleted: json['isCompleted'],
      );
}
