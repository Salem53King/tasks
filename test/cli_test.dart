import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory directory;
  late String filePath;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('tasks_cli_');
    filePath = '${directory.path}/tasks.json';
    print('📁 Répertoire temporaire: ${directory.path}');
  });

  tearDown(() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  Future<ProcessResult> runCli(List<String> args) async {
    // Méthode plus robuste pour trouver le chemin du projet
    final scriptPath = Platform.script.toFilePath();
    print('📄 Script path: $scriptPath');

    // Remonter jusqu'à la racine du projet
    var currentDir = File(scriptPath).parent;
    print('📂 Current dir: ${currentDir.path}');

    // Chercher le dossier bin/ à partir du répertoire courant
    String? projectPath;
    for (var i = 0; i < 5; i++) {
      final binPath = '${currentDir.path}/bin/tasks.dart';
      if (File(binPath).existsSync()) {
        projectPath = currentDir.path;
        break;
      }
      currentDir = currentDir.parent;
    }

    if (projectPath == null) {
      // Essayer une autre approche : utiliser le répertoire de travail courant
      final cwd = Directory.current.path;
      print('📂 Current working directory: $cwd');

      if (File('$cwd/bin/tasks.dart').existsSync()) {
        projectPath = cwd;
      }
    }

    if (projectPath == null) {
      // Dernier recours : chercher dans tout le système
      final allPaths = [
        Directory.current.path,
        Platform.script.toFilePath(),
        '.',
      ];

      for (final path in allPaths) {
        final testPath = '$path/bin/tasks.dart';
        if (File(testPath).existsSync()) {
          projectPath = path;
          break;
        }
      }
    }

    if (projectPath == null) {
      fail('Impossible de trouver le fichier bin/tasks.dart');
    }

    final tasksPath = '$projectPath/bin/tasks.dart';
    print('📄 Fichier tasks.dart trouvé: $tasksPath');

    if (!File(tasksPath).existsSync()) {
      fail('Le fichier tasks.dart n\'existe pas à : $tasksPath');
    }

    final result = await Process.run(
      Platform.resolvedExecutable,
      ['run', tasksPath, ...args, '--file', filePath],
      workingDirectory: projectPath,
      runInShell: Platform.isWindows,
    );

    print('🚀 Exit code: ${result.exitCode}');
    if (result.stdout.toString().isNotEmpty) {
      print('📤 Stdout: ${result.stdout}');
    }
    if (result.stderr.toString().isNotEmpty) {
      print('📥 Stderr: ${result.stderr}');
    }

    return result;
  }

  test('La CLI ajoute, complète et supprime une tâche', () async {
    // Ajouter une tâche
    print('\n=== 1. AJOUT DE LA TÂCHE ===');
    final addResult = await runCli(['add', 'CLI test', 'high']);
    expect(addResult.exitCode, 0, reason: 'Erreur: ${addResult.stderr}');

    final file = File(filePath);
    expect(file.existsSync(), true);

    String content = await file.readAsString();
    print('📄 Contenu après ajout: $content');

    final data = jsonDecode(content) as List<dynamic>;
    expect(data, hasLength(1));

    final id = (data.single as Map<String, dynamic>)['id'] as String;
    expect(id, isNotEmpty);
    print('✅ ID de la tâche: $id');

    // Compléter la tâche
    print('\n=== 2. COMPLÉTION DE LA TÂCHE ===');
    final completeResult = await runCli(['complete', id]);
    expect(
      completeResult.exitCode,
      0,
      reason: 'Erreur: ${completeResult.stderr}',
    );

    content = await file.readAsString();
    print('📄 Contenu après complétion: $content');

    final completedData = jsonDecode(content) as List<dynamic>;
    expect(completedData, hasLength(1));
    expect((completedData.single as Map<String, dynamic>)['isCompleted'], true);
    print('✅ Tâche complétée');

    // Supprimer la tâche
    print('\n=== 3. SUPPRESSION DE LA TÂCHE ===');
    final deleteResult = await runCli(['delete', id]);
    expect(deleteResult.exitCode, 0, reason: 'Erreur: ${deleteResult.stderr}');

    content = await file.readAsString();
    print('📄 Contenu après suppression: $content');

    // Vérifier le contenu après suppression
    final finalData = jsonDecode(content) as List<dynamic>;
    print('📊 Nombre de tâches après suppression: ${finalData.length}');

    // Afficher les tâches restantes si elles existent
    if (finalData.isNotEmpty) {
      print('⚠️ Tâches restantes:');
      for (var task in finalData) {
        print('  - $task');
      }
    }

    expect(
      finalData,
      [],
      reason: 'La liste devrait être vide après suppression',
    );
    print('✅ Tâche supprimée avec succès');
    print('\n🎉 Test réussi!');
  });
}
