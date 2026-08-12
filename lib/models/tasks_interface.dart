// lib/models/task.dart
import 'package:tasks/models/task.dart';

abstract interface class TaskOperations {
  String get id;
  String get title;
  bool get isCompleted;
  Priority get priority;
  DateTime? get dueDate;

  void markAsCompleted();
  bool isOverdue();
  String getTaskType();
  Map<String, dynamic> toJson();
}
