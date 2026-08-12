import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('La CLI ajoute, complète et supprime une tâche', () async {
    final directory = await Directory.systemTemp.createTemp('tasks_cli_');
    
    // Correction : utilise tearDown au lieu de addTearDown
    tearDown(() => directory.delete(recursive: true));

    final filePath = '${directory.path}/tasks.json';

    Future<ProcessResult> runCli(List<String> args) {
      return Process.run(
        Platform.resolvedExecutable,
        ['run', 'bin/tasks.dart', ...args, '--file', filePath],
      );
    }

    // Test 1: Ajouter une tâche
    final addResult = await runCli(['add', 'CLI test', 'high']);
    expect(addResult.exitCode, 0);

    final data = jsonDecode(await File(filePath).readAsString()) as List<dynamic>;
    expect(data, hasLength(1));
    final id = (data.single as Map<String, dynamic>)['id'] as String;

    // Test 2: Compléter la tâche
    final completeResult = await runCli(['complete', id]);
    expect(completeResult.exitCode, 0);

    final completedData =
        jsonDecode(await File(filePath).readAsString()) as List<dynamic>;
    // Correction : utilise true au lieu de isTrue
    expect(
      (completedData.single as Map<String, dynamic>)['isCompleted'],
      true,
    );

    // Test 3: Supprimer la tâche
    final deleteResult = await runCli(['delete', id]);
    expect(deleteResult.exitCode, 0);

    final finalData =
        jsonDecode(await File(filePath).readAsString()) as List<dynamic>;
    // Correction : compare avec [] au lieu d'utiliser isEmpty
    expect(finalData, []);
  });
}