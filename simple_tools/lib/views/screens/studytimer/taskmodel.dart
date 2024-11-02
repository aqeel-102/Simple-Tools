class Task {
  final String name;
  final List<SubTask> subTasks;

  Task({required this.name, required this.subTasks}) {
    if (name.isEmpty) {
      throw ArgumentError('Task name cannot be empty');
    }
    if (subTasks.isEmpty) {
      throw ArgumentError('Task must have at least one subtask');
    }
  }

  int get totalTime => subTasks.fold(0, (sum, subTask) => sum + subTask.timer);

  factory Task.fromJson(String json) {
    try {
      final parts = json.split('|');
      if (parts.length != 2) throw FormatException('Invalid task format');

      final subTaskParts = parts[1].split(',');
      return Task(
        name: parts[0],
        subTasks: subTaskParts.map((e) {
          final subTaskData = e.split(':');
          if (subTaskData.length != 2) {
            throw FormatException('Invalid subtask format');
          }

          return SubTask(
              name: subTaskData[0], timer: int.parse(subTaskData[1]));
        }).toList(),
      );
    } catch (e) {
      throw FormatException('Failed to parse task: $e');
    }
  }

  String toJson() =>
      '$name|${subTasks.map((st) => '${st.name}:${st.timer}').join(',')}';
}

class SubTask {
  final String name;
  final int timer;

  SubTask({required this.name, required this.timer}) {
    if (name.isEmpty) {
      throw ArgumentError('Subtask name cannot be empty');
    }
    if (timer <= 0) {
      throw ArgumentError('Timer must be greater than 0');
    }
  }
}
