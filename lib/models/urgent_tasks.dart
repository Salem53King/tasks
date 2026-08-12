import 'package:tasks/exceptions/task_exceptions.dart';
import 'task.dart';

class UrgentTasks extends Task {
  final String urgencyReason;

  UrgentTasks({
    required super.id,
    required super.title,
    required this.urgencyReason,
    super.priority = Priority.high,
    super.dueDate,
    super.isCompleted = false,
  }) {
    if (urgencyReason.trim().isEmpty) {
      throw const InvalidTaskException(
        'La raison de l\'urgence ne peut pas être vide.',
      );
    }
  }

  @override
  String getTaskType() => 'UrgentTask';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'urgencyReason': urgencyReason,
  };

  factory UrgentTasks.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final reason = json['urgencyReason'];
    if (id is! String || title is! String || reason is! String) {
      throw const InvalidTaskException(
        'Une tâche urgente doit contenir id, title et urgencyReason.',
      );
    }

    return UrgentTasks(
      id: id,
      title: title,
      urgencyReason: reason,
      isCompleted: Task.boolFromJson(json['isCompleted']),
      priority: Task.priorityFromJson(
        json['priority'],
        fallback: Priority.high,
      ),
      dueDate: Task.dateFromJson(json['dueDate']),
    );
  }
}
