class Task {
  final int? id;
  final String title;
  final String category;
  final String priority;
  final DateTime dueDate;
  final bool isDone;

  Task({
    this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      priority: map['priority'],
      dueDate: DateTime.parse(map['dueDate']),
      isDone: map['isDone'] == 1,
    );
  }
}
