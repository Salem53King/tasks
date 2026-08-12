import 'dart:io';

import 'package:tasks/exceptions/task_exceptions.dart';
import 'package:tasks/models/list_tasks.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/repository/task_repository.dart';
import 'package:tasks/services/task_service.dart';

Future<void> main(List<String> arguments) async {
  try {
    final options = _parseOptions(arguments);
    final filePath = options['file'] ?? 'tasks.json';
    final command = options['command'] as String?;
    final commandArgs = options['args'] as List<String>;

    final service = TaskService(TaskRepository(filePath: filePath));

    if (command == null || command == 'help') {
      _printUsage();
      return;
    }

    switch (command) {
      case 'add':
        await _add(service, commandArgs);
        break;
      case 'add-urgent':
        await _addUrgent(service, commandArgs);
        break;
      case 'list':
        await _list(service, commandArgs);
        break;
      case 'complete':
        _requireArgs(commandArgs, 1, 'complete <id>');
        await service.completeTask(commandArgs[0]);
        print('Tâche "${commandArgs[0]}" marquée comme terminée.');
        break;
      case 'delete':
        _requireArgs(commandArgs, 1, 'delete <id>');
        await service.deleteTask(commandArgs[0]);
        print('Tâche "${commandArgs[0]}" supprimée.');
        break;
      default:
        throw InvalidTaskException('Commande inconnue : "$command".');
    }
  } on AppException catch (error) {
    stderr.writeln('Erreur : $error');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln('Erreur : ${error.message}');
    exitCode = 1;
  }
}

Map<String, dynamic> _parseOptions(List<String> arguments) {
  if (arguments.isEmpty) {
    return {'command': 'help', 'args': <String>[]};
  }

  final remaining = <String>[];
  String? filePath;

  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    if (argument == '--file') {
      if (i + 1 >= arguments.length) {
        throw const InvalidTaskException(
          'La valeur de --file est obligatoire.',
        );
      }
      filePath = arguments[++i];
    } else {
      remaining.add(argument);
    }
  }

  return {
    'command': remaining.isEmpty ? 'help' : remaining.first,
    'args': remaining.skip(1).toList(),
    'file': filePath,
  };
}

Future<void> _add(TaskService service, List<String> args) async {
  _requireArgs(args, 1, 'add <titre> [priority] [dueDate]');
  final priority = args.length >= 2 ? _parsePriority(args[1]) : Priority.medium;
  final dueDate = args.length >= 3 ? _parseDate(args[2]) : null;

  await service.addTask(title: args[0], priority: priority, dueDate: dueDate);
  print('Tâche ajoutée avec succès.');
}

Future<void> _addUrgent(TaskService service, List<String> args) async {
  _requireArgs(args, 2, 'add-urgent <titre> <raison> [dueDate]');
  final dueDate = args.length >= 3 ? _parseDate(args[2]) : null;

  await service.addUrgentTask(
    title: args[0],
    urgencyReason: args[1],
    dueDate: dueDate,
  );
  print('Tâche urgente ajoutée avec succès.');
}

Future<void> _list(TaskService service, List<String> args) async {
  final sortBy = args.isEmpty ? 'priority' : args[0];
  final descending = args.length >= 2 && args[1].toLowerCase() == 'desc';
  final tasks = await service.sortedTasks(
    sortBy: sortBy,
    descending: descending,
  );

  displayTasks(tasks, sortBy: sortBy, descending: descending);
}

Priority _parsePriority(String value) {
  return Priority.values.firstWhere(
    (priority) => priority.name == value.toLowerCase(),
    orElse: () => throw InvalidTaskException(
      'Priorité inconnue : "$value". Utilisez low, medium ou high.',
    ),
  );
}

DateTime _parseDate(String value) {
  try {
    return DateTime.parse(value);
  } on FormatException {
    throw InvalidTaskException(
      'Date invalide : "$value". Utilisez le format ISO-8601.',
    );
  }
}

void _requireArgs(List<String> args, int minimum, String usage) {
  if (args.length < minimum) {
    throw InvalidTaskException('Usage : dart run bin/tasks.dart $usage');
  }
}

void _printUsage() {
  print('''
Gestionnaire de tâches CLI

Commandes :
  add <titre> [priority] [dueDate]
      Ajoute une tâche simple.
      priority : low | medium | high
      dueDate  : date ISO-8601.

  add-urgent <titre> <raison> [dueDate]
      Ajoute une tâche urgente.

  list [priority|dueDate|title] [asc|desc]
      Liste et trie les tâches.

  complete <id>
      Marque une tâche comme terminée.

  delete <id>
      Supprime une tâche.

Option :
  --file <chemin>
      Utilise un fichier JSON différent de tasks.json.

Exemples :
  dart run bin/tasks.dart add "Apprendre Dart" high
  dart run bin/tasks.dart list dueDate
  dart run bin/tasks.dart complete 123456
  dart run bin/tasks.dart delete 123456
''');
}
