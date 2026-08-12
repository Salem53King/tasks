import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory directory;
  late String filePath;

  // Configuration avant les tests
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('tasks_cli_');
    filePath = '${directory.path}/tasks.json';
  });

  // Nettoyage après les tests
  tearDown(() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  Future<ProcessResult> runCli(List<String> args) {
    return Process.run(Platform.resolvedExecutable, [
      'run',
      'bin/tasks.dart',
      ...args,
      '--file',
      filePath,
    ]);
  }

  test('La CLI ajoute, complète et supprime une tâche', () async {
    // Ajouter une tâche
    final addResult = await runCli(['add', 'CLI test', 'high']);
    expect(addResult.exitCode, 0);

    final data =
        jsonDecode(await File(filePath).readAsString()) as List<dynamic>;
    expect(data, hasLength(1));
    final id = (data.single as Map<String, dynamic>)['id'] as String;

    // Compléter la tâche
    final completeResult = await runCli(['complete', id]);
    expect(completeResult.exitCode, 0);

    final completedData =
        jsonDecode(await File(filePath).readAsString()) as List<dynamic>;
    expect((completedData.single as Map<String, dynamic>)['isCompleted'], true);

    // Supprimer la tâche
    final deleteResult = await runCli(['delete', id]);
    expect(deleteResult.exitCode, 0);

    final finalData =
        jsonDecode(await File(filePath).readAsString()) as List<dynamic>;
    expect(finalData, []);
  });
}
