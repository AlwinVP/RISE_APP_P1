import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    required this.task,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text('${task.category} | ${task.priority} | ${DateFormat.yMd().add_jm().format(task.dueDate)}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
