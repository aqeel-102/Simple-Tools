import 'package:flutter/material.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/views/screens/studytimer/taskmodel.dart';

class TaskEditBottomSheet extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskEditBottomSheet({super.key, this.task, required this.onSave});

  @override
  _TaskEditBottomSheetState createState() => _TaskEditBottomSheetState();
}

class _TaskEditBottomSheetState extends State<TaskEditBottomSheet> {
  late String taskName;
  late List<SubTask> subTasks;

  @override
  void initState() {
    super.initState();
    taskName = widget.task?.name ?? '';
    subTasks = widget.task?.subTasks ??
        [SubTask(name: 'Study Session 1', timer: 25 * 60)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              widget.task == null ? 'Create New Task' : 'Edit Task',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.mainColor,
                  ),
            ),
            SizedBox(height: 24),
            _buildTaskNameField(),
            SizedBox(height: 24),
            Text(
              'Study Sessions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 16),
            ...subTasks.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildSubTaskField(entry.key, entry.value),
              );
            }),
            _buildAddSubTaskButton(),
            SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Task Name',
        hintText: 'Enter task name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppConstants.mainColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(Icons.edit_outlined, color: AppConstants.mainColor),
        floatingLabelStyle: TextStyle(color: AppConstants.mainColor),
      ),
      style: TextStyle(fontSize: 16),
      initialValue: taskName,
      onChanged: (value) => taskName = value,
    );
  }

  Widget _buildSubTaskField(int index, SubTask subTask) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Session ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.mainColor,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red[400]),
                onPressed: () {
                  setState(() {
                    if (subTasks.length > 1) {
                      subTasks.removeAt(index);
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Session Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  initialValue: subTask.name,
                  onChanged: (value) {
                    setState(() {
                      subTasks[index] =
                          SubTask(name: value, timer: subTasks[index].timer);
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: (subTask.timer ~/ 60).toString(),
                  onChanged: (value) {
                    setState(() {
                      subTasks[index] = SubTask(
                        name: subTasks[index].name,
                        timer: (int.tryParse(value) ?? 0) * 60,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddSubTaskButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            subTasks.add(SubTask(
                name: 'Study Session ${subTasks.length + 1}', timer: 25 * 60));
          });
        },
        icon: Icon(Icons.add_circle_outline, color: AppConstants.mainColor),
        label: Text(
          'Add Study Session',
          style: TextStyle(color: AppConstants.mainColor),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              try {
                if (_validateTask()) {
                  widget.onSave(Task(name: taskName, subTasks: subTasks));
                } else {
                  throw Exception('Please fill all fields correctly');
                }
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.mainColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Save'),
          ),
        ),
      ],
    );
  }

  bool _validateTask() {
    return taskName.isNotEmpty &&
        subTasks.isNotEmpty &&
        subTasks.every((st) => st.name.isNotEmpty && st.timer > 0);
  }
}
