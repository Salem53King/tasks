import 'dart:io';

import 'package:test/test.dart';
import 'package:tasks/models/simple_tasks.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/repository/task_repository.dart';
import 'package:tasks/services/task_service.dart';

void main() {
  test('Le service trie les tâches par priorité', () async {
    final directory = await Directory.systemTemp.createTemp('tasks_sort_');
    addTearDown(() => directory.delete(recursive: true));

    final repository = TaskRepository(
      filePath: '${directory.path}/tasks.json',
    );
    await repository.saveAll([
      SimpleTask(id: 'low', title: 'Faible', priority: Priority.low),
      SimpleTask(id: 'high', title: 'Haute', priority: Priority.high),
      SimpleTask(id: 'medium', title: 'Moyenne', priority: Priority.medium),
    ]);

    final service = TaskService(repository);
    final tasks = await service.sortedTasks(sortBy: 'priority');
    expect(tasks.map((task) => task.id), ['low', 'medium', 'high']);
  });

  test('Le service trie les tâches par date limite', () async {
    final directory = await Directory.systemTemp.createTemp('tasks_due_');
    addTearDown(() => directory.delete(recursive: true));

    final repository = TaskRepository(
      filePath: '${directory.path}/tasks.json',
    );
    await repository.saveAll([
      SimpleTask(
        id: 'late',
        title: 'Plus tard',
        dueDate: DateTime(2026, 8, 20),
      ),
      SimpleTask(
        id: 'soon',
        title: 'Bientôt',
        dueDate: DateTime(2026, 8, 13),
      ),
    ]);

    final service = TaskService(repository);
    final tasks = await service.sortedTasks(sortBy: 'dueDate');
    expect(tasks.map((task) => task.id), ['soon', 'late']);
  });
}
