import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/task_database.dart';
// ❌ REMOVE import '../models/task.dart'; because Task is already available via task_database.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await TaskDatabase.instance.readAllTasks();
    setState(() {
      tasks = data;
    });
  }

  Future<void> _addOrEditTask({Task? task}) async {
    final titleController = TextEditingController(text: task?.title ?? '');
    final categoryController = TextEditingController(text: task?.category ?? '');
    String priority = task?.priority ?? 'Medium';
    DateTime dueDate = task?.dueDate ?? DateTime.now().add(const Duration(hours: 1));

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              DropdownButton<String>(
                value: priority,
                items: ['High', 'Medium', 'Low'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => priority = val);
                },
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100));
                  if (picked != null) {
                    final time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.fromDateTime(dueDate));
                    if (time != null) {
                      dueDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                    }
                  }
                },
                child: Text('Pick Due Date: ${DateFormat.yMd().add_jm().format(dueDate)}'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                final newTask = Task(
                  id: task?.id,
                  title: titleController.text,
                  category: categoryController.text,
                  priority: priority,
                  dueDate: dueDate,
                  isDone: task?.isDone ?? false,
                );
                if (task == null) {
                  await TaskDatabase.instance.create(newTask);
                } else {
                  await TaskDatabase.instance.update(newTask);
                }
                _loadTasks();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _deleteTask(int id) async {
    await TaskDatabase.instance.delete(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Task Manager')),
      body: ListView(
        children: tasks.map<Widget>((t) => ListTile(
          title: Text(t.title),
          subtitle: Text('${t.category} | ${t.priority} | ${DateFormat.yMd().add_jm().format(t.dueDate)}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTask(t.id!),
          ),
          onTap: () => _addOrEditTask(task: t),
        )).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTask(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
