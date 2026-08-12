import 'dart:math';

import 'package:tasks/exceptions/task_exceptions.dart';
import 'package:tasks/models/simple_tasks.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/models/urgent_tasks.dart';
import 'package:tasks/repository/task_repository.dart';

class TaskService {
  final TaskRepository repository;

  const TaskService(this.repository);

  Future<List<Task>> getTasks() => repository.loadAll();

  Future<void> addTask({
    required String title,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) async {
    final task = SimpleTask(
      id: _generateId(),
      title: title.trim(),
      priority: priority,
      dueDate: dueDate,
    );
    final tasks = await repository.loadAll();
    tasks.add(task);
    await repository.saveAll(tasks);
  }

  Future<void> addUrgentTask({
    required String title,
    required String urgencyReason,
    DateTime? dueDate,
  }) async {
    final task = UrgentTasks(
      id: _generateId(),
      title: title.trim(),
      urgencyReason: urgencyReason.trim(),
      dueDate: dueDate,
    );
    final tasks = await repository.loadAll();
    tasks.add(task);
    await repository.saveAll(tasks);
  }

  Future<void> deleteTask(String id) async {
    final tasks = await repository.loadAll();
    final index = tasks.indexWhere((task) => task.id == id);
    if (index == -1) throw TaskNotFoundException(id);
    tasks.removeAt(index);
    await repository.saveAll(tasks);
  }

  Future<Task> getTaskById(String id) async {
    final tasks = await repository.loadAll();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } on StateError {
      throw TaskNotFoundException(id);
    }
  }

  Future<void> completeTask(String id) async {
    final tasks = await repository.loadAll();
    final index = tasks.indexWhere((task) => task.id == id);
    if (index == -1) throw TaskNotFoundException(id);
    tasks[index].markAsCompleted();
    await repository.saveAll(tasks);
  }

  Future<List<Task>> sortedTasks({
    String sortBy = 'priority',
    bool descending = false,
  }) async {
    final tasks = await repository.loadAll();

    int compare(Task a, Task b) {
      switch (sortBy) {
        case 'priority':
          return a.priority.index.compareTo(b.priority.index);
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case 'title':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        default:
          throw InvalidTaskException(
            'Tri inconnu : "$sortBy". Utilisez priority, dueDate ou title.',
          );
      }
    }

    tasks.sort(compare);
    return descending ? tasks.reversed.toList() : tasks;
  }

  String _generateId() {
    final random = Random();
    return '${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 32)}';
  }
}
