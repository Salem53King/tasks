import 'dart:io';

import 'package:tasks/models/simple_tasks.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/repository/task_repository.dart';
import 'package:test/test.dart';

void main() {
  test('Le repository sauvegarde puis recharge les tâches', () async {
    final directory = await Directory.systemTemp.createTemp('tasks_repo_');
    addTearDown(() => directory.delete(recursive: true));

    final repository = TaskRepository(filePath: '${directory.path}/tasks.json');
    final task = SimpleTask(
      id: 'persisted',
      title: 'Persister',
      priority: Priority.medium,
    );

    await repository.saveAll([task]);
    final loaded = await repository.loadAll();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'persisted');
    expect(loaded.single.title, 'Persister');
  });

  test('Un fichier JSON inexistant retourne une liste vide', () async {
    final directory = await Directory.systemTemp.createTemp('tasks_empty_');
    addTearDown(() => directory.delete(recursive: true));

    final repository = TaskRepository(
      filePath: '${directory.path}/missing.json',
    );
    expect(await repository.loadAll(), isEmpty);
  });
}
