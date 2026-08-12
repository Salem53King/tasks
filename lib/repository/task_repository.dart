import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';

typedef JsonDecoder<T> = T Function(Map<String, dynamic> json);
typedef JsonEncoder<T> = Map<String, dynamic> Function(T value);

class Repository<T> {
  final String filePath;
  final JsonDecoder<T> fromJson;
  final JsonEncoder<T> toJson;

  Repository({
    required this.filePath,
    required this.fromJson,
    required this.toJson,
  });

  Future<List<T>> loadAll() async {
    final file = File(filePath);
    try {
      if (!await file.exists()) return <T>[];
      final content = await file.readAsString();
      if (content.trim().isEmpty) return <T>[];

      final decoded = jsonDecode(content);
      if (decoded is! List) {
        throw const RepositoryFormatException(
          'Le fichier JSON doit contenir une liste de tâches.',
        );
      }

      return decoded.map((item) {
        if (item is! Map) {
          throw const RepositoryFormatException(
            'Chaque tâche JSON doit être un objet.',
          );
        }
        return fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } on RepositoryException {
      rethrow;
    } on FormatException catch (error) {
      throw RepositoryFormatException(
        'JSON invalide dans "$filePath" : ${error.message}',
      );
    } on FileSystemException catch (error) {
      throw RepositoryReadException(
        'Impossible de lire "$filePath" : ${error.message}',
      );
    } catch (error) {
      throw RepositoryReadException(
        'Erreur lors du chargement de "$filePath" : $error',
      );
    }
  }

  Future<void> saveAll(Iterable<T> items) async {
    final file = File(filePath);
    try {
      await file.parent.create(recursive: true);
      final jsonList = items.map(toJson).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } on FileSystemException catch (error) {
      throw RepositoryWriteException(
        'Impossible d\'écrire dans "$filePath" : ${error.message}',
      );
    } catch (error) {
      throw RepositoryWriteException(
        'Erreur lors de la sauvegarde dans "$filePath" : $error',
      );
    }
  }
}

class TaskRepository extends Repository<Task> {
  TaskRepository({required super.filePath})
    : super(fromJson: Task.fromJson, toJson: _taskToJson);
  static Map<String, dynamic> _taskToJson(Task task) => task.toJson();
}
