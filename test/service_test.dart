import 'dart:io';

import 'package:tasks/exceptions/task_exceptions.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/repository/task_repository.dart';
import 'package:tasks/services/task_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late TaskService service;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('tasks_service_');
    service = TaskService(
      TaskRepository(filePath: '${directory.path}/tasks.json'),
    );
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('Le service ajoute une tâche et la persiste', () async {
    await service.addTask(title: 'Nouvelle tâche', priority: Priority.high);

    final tasks = await service.getTasks();

    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Nouvelle tâche');
    expect(tasks.single.priority, Priority.high);
  });

  test('Le service signale une tâche inexistante', () async {
    expect(
      () => service.deleteTask('id_inexistant'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });
}
