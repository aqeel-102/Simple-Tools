import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:simple_tools/views/screens/studytimer/settingsdailog.dart';
import 'package:simple_tools/views/screens/studytimer/taskmodel.dart';

import 'bottomsheet.dart';

// View Models
class StudyTimerViewModel extends ChangeNotifier {
  int totalStudyTime = 0;
  int currentSessionTime = 0;

  int breakTime = 5 * 60;
  List<Task> tasks = [];
  bool isStudying = false;
  bool isResting = false;
  bool studyingsession = false;
  bool isPaused = false;
  int completedSessions = 0;
  int currentTaskIndex = 0;
  int currentSubTaskIndex = 0;
  int elapsedTime = 0;

  String get timerStatusText {
    try {
      if (isStudying) {
        return 'Studying: ${tasks[currentTaskIndex].name} - ${tasks[currentTaskIndex].subTasks[currentSubTaskIndex].name}';
      } else if (isResting) {
        return 'Break Time';
      } else {
        return 'Ready';
      }
    } catch (e) {
      return 'Add a task to get started';
    }
  }

  List<Map<String, dynamic>> get nextSubTasks {
    if (tasks.isEmpty) return [];

    try {
      List<Map<String, dynamic>> nextTasks = [];
      int taskIndex = currentTaskIndex;
      int subTaskIndex = currentSubTaskIndex + 1;

      while (nextTasks.length < 3 && taskIndex < tasks.length) {
        if (subTaskIndex < tasks[taskIndex].subTasks.length) {
          nextTasks.add({
            'name':
                '${tasks[taskIndex].name} - ${tasks[taskIndex].subTasks[subTaskIndex].name}',
            'time': tasks[taskIndex].subTasks[subTaskIndex].timer
          });
          subTaskIndex++;
        } else {
          taskIndex++;
          subTaskIndex = 0;
        }
      }

      return nextTasks;
    } catch (e) {
      debugPrint('Error getting next subtasks: $e');
      return [];
    }
  }

  void calculateTotalStudyTime() {
    try {
      totalStudyTime = tasks.fold(0, (sum, task) => sum + task.totalTime);
      currentSessionTime = totalStudyTime;
    } catch (e) {
      debugPrint('Error calculating study time: $e');
      totalStudyTime = 0;
      currentSessionTime = 0;
    }
  }

  Future<void> loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final tasksList = prefs.getStringList('study_tasks') ?? [];
      tasks = tasksList.map((e) => Task.fromJson(e)).toList();

      breakTime = prefs.getInt('break_time') ?? 5 * 60;
      completedSessions = prefs.getInt('completed_sessions') ?? 0;
      totalStudyTime = prefs.getInt('total_study_time') ?? 0;

      calculateTotalStudyTime();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Reset to defaults
      tasks = [];
      breakTime = 5 * 60;
      completedSessions = 0;
      totalStudyTime = 0;
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'study_tasks', tasks.map((e) => e.toJson()).toList());
      await prefs.setInt('break_time', breakTime);
      await prefs.setInt('completed_sessions', completedSessions);
      await prefs.setInt('total_study_time', totalStudyTime);
    } catch (e) {
      debugPrint('Error saving data: $e');
      throw Exception('Failed to save data');
    }
  }

  void startStudySession() {
    try {
      if (tasks.isEmpty) throw Exception('No tasks available');

      isStudying = true;
      isPaused = false;
      currentSessionTime =
          tasks[currentTaskIndex].subTasks[currentSubTaskIndex].timer;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting session: $e');
      stopSession();
    }
  }

  void stopSession() {
    isStudying = false;
    isResting = false;
    isPaused = false;
    elapsedTime = 0;
    notifyListeners();
  }

  void pauseSession() {
    isPaused = true;
    notifyListeners();
  }

  void resumeSession() {
    isPaused = false;
    notifyListeners();
  }

  Future<void> onTimerComplete() async {
    try {
      // Play completion sound
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/buzzer.mp3'));
      await Future.delayed(const Duration(seconds: 3));
      await player.stop();

      if (isStudying) {
        currentSubTaskIndex++;

        // Check if there are more subtasks in current task
        if (currentSubTaskIndex < tasks[currentTaskIndex].subTasks.length) {
          // Move to next subtask
          currentSessionTime =
              tasks[currentTaskIndex].subTasks[currentSubTaskIndex].timer;
          // Ensure we're still in study mode
          isStudying = true;
          isResting = false;
          studyingsession = true;
        } else {
          // Current task complete, move to next task
          currentTaskIndex++;
          currentSubTaskIndex = 0;

          if (currentTaskIndex < tasks.length) {
            // Start break before next task
            isStudying = false;
            isResting = true;
            studyingsession = true;
            currentSessionTime = breakTime * 60; // Convert minutes to seconds
          } else {
            // All tasks complete
            isStudying = false;
            isResting = false;
            studyingsession = false;
            completedSessions++;
            totalStudyTime +=
                tasks.fold(0, (sum, task) => sum + task.totalTime);
          }
        }
      } else if (isResting) {
        // Break complete, start next task
        isResting = false;
        isStudying = true;
        studyingsession = true;
        currentSubTaskIndex = 0;
        if (currentTaskIndex < tasks.length) {
          currentSessionTime =
              tasks[currentTaskIndex].subTasks[currentSubTaskIndex].timer;
        } else {
          // Safety check in case currentTaskIndex is out of bounds
          stopSession();
          return;
        }
      }

      elapsedTime = 0;
      notifyListeners();
      await saveData();
    } catch (e) {
      debugPrint('Error completing timer: $e');
      stopSession();
    }
  }

  void addTask(Task task) {
    try {
      tasks.add(task);
      calculateTotalStudyTime();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      throw Exception('Failed to add task');
    }
  }

  void updateTask(Task oldTask, Task newTask) {
    try {
      int index = tasks.indexOf(oldTask);
      if (index == -1) throw Exception('Task not found');

      tasks[index] = newTask;
      calculateTotalStudyTime();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
      throw Exception('Failed to update task');
    }
  }

  void removeTask(int index) {
    try {
      if (index < 0 || index >= tasks.length) {
        throw RangeError('Invalid task index');
      }
      tasks.removeAt(index);
      calculateTotalStudyTime();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing task: $e');
      throw Exception('Failed to remove task');
    }
  }
}

// Widgets
class StudyTimerHomeScreen extends StatefulWidget {
  const StudyTimerHomeScreen({super.key});

  @override
  StudyTimerHomeScreenState createState() => StudyTimerHomeScreenState();
}

class StudyTimerHomeScreenState extends State<StudyTimerHomeScreen> {
  final StudyTimerViewModel viewModel = StudyTimerViewModel();
  final CountDownController controller = CountDownController();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    viewModel.loadData();
    viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Timer'),
        backgroundColor: AppConstants.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimerCard(context),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildTaskList(context),
              const SizedBox(height: AppConstants.smallSpacing),
              _buildAddTaskButton(context),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildStatsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Text(
              viewModel.timerStatusText,
              style: AppConstants.headlineSmall,
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            CircularCountDownTimer(
              duration: viewModel.currentSessionTime,
              initialDuration: viewModel.elapsedTime,
              controller: controller,
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 3,
              ringColor: Colors.grey[300]!,
              fillColor: AppConstants.mainColor,
              backgroundColor: AppConstants.secColor,
              strokeWidth: 15.0,
              strokeCap: StrokeCap.round,
              textStyle: const TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textFormat: CountdownTextFormat.MM_SS,
              isReverse: true,
              isTimerTextShown: true,
              autoStart: false,
              onComplete: () async {
                try {
                  await audioPlayer
                      .play(AssetSource('sounds/notification.mp3'));
                  await Future.delayed(Duration(seconds: 3));
                  audioPlayer.stop();

                  bool? shouldContinue = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Subtask Completed'),
                        content: Text(
                            'Do you want to continue to the next subtask?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldContinue == true) {
                    await viewModel.onTimerComplete();
                    if (viewModel.isStudying || viewModel.isResting) {
                      controller.restart(
                          duration: viewModel.currentSessionTime);
                    }
                  } else {
                    viewModel.stopSession();
                  }
                } catch (e) {
                  debugPrint('Error in timer completion: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error completing timer')));
                  viewModel.stopSession();
                }
              },
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    try {
                      if (!viewModel.isStudying && !viewModel.isResting) {
                        viewModel.startStudySession();
                        controller.restart(
                            duration: viewModel.currentSessionTime -
                                viewModel.elapsedTime);
                      } else if (viewModel.isPaused) {
                        viewModel.resumeSession();
                        controller.resume();
                      } else {
                        viewModel.pauseSession();
                        controller.pause();
                        final time = controller.getTime();
                        viewModel.elapsedTime = time != null
                            ? viewModel.currentSessionTime - int.parse(time)
                            : 0;
                      }
                    } catch (e) {
                      debugPrint('Error toggling timer: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error controlling timer')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.mainColor,
                  ),
                  child: Text(!viewModel.isStudying && !viewModel.isResting
                      ? 'Start'
                      : viewModel.isPaused
                          ? 'Resume'
                          : 'Pause'),
                ),
                if (viewModel.isStudying || viewModel.isResting) ...[
                  ElevatedButton(
                    onPressed: () {
                      try {
                        viewModel.stopSession();
                        controller.reset();
                      } catch (e) {
                        debugPrint('Error stopping timer: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error stopping timer')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Stop'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        controller.restart(
                            duration: viewModel.currentSessionTime);
                        viewModel.elapsedTime = 0;
                      } catch (e) {
                        debugPrint('Error restarting timer: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error restarting timer')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Restart'),
                  ),
                ],
              ],
            ),
            if (viewModel.isStudying) ...[
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                'Next Sub-tasks:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.mainColor,
                    ),
              ),
              const SizedBox(height: 4),
              ...viewModel.nextSubTasks.take(2).map((task) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: AppConstants.secColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task['name'].split(' - ')[1],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.mainColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${task['time'] ~/ 60} min',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.mainColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text('Tasks', style: AppConstants.headlineSmall),
          ),
          viewModel.tasks.isEmpty
              ? Center(
                  child: Text('No tasks',
                      style: Theme.of(context).textTheme.bodyMedium),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: viewModel.tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskTile(
                        context, viewModel.tasks[index], index);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, Task task, int index) {
    return ListTile(
      title: Text(task.name),
      subtitle: Text('Total time: ${task.totalTime ~/ 60} minutes'),
      onTap: () {
        _showTaskDetailsDialog(context, task, index);
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showAddTaskBottomSheet(context, task: task),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              try {
                if (viewModel.isStudying &&
                    viewModel.currentTaskIndex == index) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Cannot delete task while it is in progress')));
                  return;
                }
                viewModel.removeTask(index);
                await viewModel.saveData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error removing task')));
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, Task task, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total time: ${task.totalTime ~/ 60} minutes'),
              SizedBox(height: 8),
              Text('Subtasks:'),
              ...task.subTasks.map((subtask) =>
                  Text('- ${subtask.name}: ${subtask.timer ~/ 60} minutes')),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Start'),
              onPressed: () {
                try {
                  Navigator.of(context).pop();
                  viewModel.studyingsession =
                      true; // Changed from studyingsession to viewModel.studyingsession
                  viewModel.currentTaskIndex = index;
                  viewModel.currentSubTaskIndex = 0;
                  viewModel.startStudySession();
                  controller.restart(duration: viewModel.currentSessionTime);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error starting task')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showAddTaskBottomSheet(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.mainColor,
      ),
      child: const Text('Add Task'),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Text('Study Statistics', style: AppConstants.headlineSmall),
            const SizedBox(height: AppConstants.smallSpacing),
            Text('Completed Sessions: ${viewModel.completedSessions}'),
            Text('Total Study Time: ${viewModel.totalStudyTime ~/ 60} minutes'),
          ],
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context, {Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TaskEditBottomSheet(
          task: task,
          onSave: (newTask) async {
            try {
              if (task == null) {
                viewModel.addTask(newTask);
              } else {
                viewModel.updateTask(task, newTask);
              }
              await viewModel.saveData();
              Navigator.of(context).pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error saving task: ${e.toString()}')));
            }
          },
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SettingsDialog(
          initialBreakTime: viewModel.breakTime ~/ 60,
          onSave: (newBreakTime) async {
            try {
              viewModel.breakTime = newBreakTime * 60;
              await viewModel.saveData();
              Navigator.of(context).pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving settings')));
            }
          },
        );
      },
    );
  }
}
