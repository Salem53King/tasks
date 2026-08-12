

import '../exceptions/task_exceptions.dart';
import 'simple_tasks.dart';
import 'tasks_interface.dart';
import 'urgent_tasks.dart';

enum Priority { low, medium, high }

abstract class Task implements TaskOperations {
  String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.priority = Priority.medium,
    this.dueDate,
    this.isCompleted = false,
  }) {
    if (id.trim().isEmpty) {
      throw const InvalidTaskException('L\'ID d\'une tâche ne peut pas être vide.');
    }
    if (title.trim().isEmpty) {
      throw const InvalidTaskException('Le titre d\'une tâche ne peut pas être vide.');
    }
  }

  @override
  void markAsCompleted() => isCompleted = true;

  @override
  bool isOverdue() {
    final deadline = dueDate;
    return deadline != null && DateTime.now().isAfter(deadline) && !isCompleted;
  }

  String getTaskType();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'taskType': getTaskType(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final taskType = json['taskType'];
    if (taskType is! String || taskType.trim().isEmpty) {
      throw const InvalidTaskException(
        'Le champ "taskType" est obligatoire et doit être une chaîne.',
      );
    }

    switch (taskType) {
      case 'SimpleTask':
        return SimpleTask.fromJson(json);
      case 'UrgentTask':
        return UrgentTasks.fromJson(json);
      default:
        throw InvalidTaskException('Type de tâche inconnu : "$taskType".');
    }
  }

  static Priority priorityFromJson(
    dynamic value, {
    Priority fallback = Priority.medium,
  }) {
    if (value is! String) return fallback;
    return Priority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => fallback,
    );
  }

  static DateTime? dateFromJson(dynamic value) {
    if (value == null || value == '') return null;
    if (value is! String) {
      throw const InvalidTaskException(
        'Le champ "dueDate" doit être une date ISO-8601.',
      );
    }
    try {
      return DateTime.parse(value);
    } on FormatException {
      throw InvalidTaskException('Date invalide : "$value".');
    }
  }

  static bool boolFromJson(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'true':
          return true;
        case 'false':
          return false;
      }
    }
    throw const InvalidTaskException(
      'Le champ "isCompleted" doit être un booléen.',
    );
  }
}
