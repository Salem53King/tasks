import 'task.dart';

class SimpleTask extends Task {
  SimpleTask({
    required super.id,
    required super.title,
    super.priority = Priority.medium,
    super.dueDate,
    super.isCompleted = false,
  });

  @override
  String getTaskType() => 'SimpleTask';

  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! String || title is! String) {
      throw const FormatException(
        'Une tâche simple doit contenir un id et un title valides.',
      );
    }

    return SimpleTask(
      id: id,
      title: title,
      priority: Task.priorityFromJson(json['priority']),
      dueDate: Task.dateFromJson(json['dueDate']),
      isCompleted: Task.boolFromJson(json['isCompleted']),
    );
  }
}
