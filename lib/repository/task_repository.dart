// lib/repository/task_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:tasks/models/task.dart';
import 'package:tasks/exceptions/task_exceptions.dart';

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
      // Propager les exceptions spécifiques au repository
      rethrow;
    } on FormatException catch (error) {
      throw RepositoryFormatException(
        'JSON invalide dans "$filePath" : ${error.message}',
      );
    } on FileSystemException catch (error) {
      throw RepositoryReadException(
        'Impossible de lire "$filePath" : ${error.message}',
      );
    } on TypeError catch (error) {
      // Erreur de type (ex: fromJson retourne le mauvais type)
      throw RepositoryFormatException(
        'Erreur de type lors du chargement de "$filePath" : $error',
      );
    } on StateError catch (error) {
      // Erreur d'état (ex: accès à un élément null)
      throw RepositoryReadException(
        'Erreur d\'état lors du chargement de "$filePath" : $error',
      );
    } on ArgumentError catch (error) {
      // Erreur d'argument (ex: mauvais format de date)
      throw RepositoryFormatException(
        'Erreur d\'argument dans "$filePath" : ${error.message}',
      );
    }
    // Les autres exceptions (NullError, etc.) ne sont pas attrapées
    // et remontent pour être visibles en développement
  }

  Future<void> saveAll(Iterable<T> items) async {
    final file = File(filePath);
    try {
      await file.parent.create(recursive: true);
      final jsonList = items.map(toJson).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } on RepositoryException {
      // Propager les exceptions spécifiques au repository
      rethrow;
    } on FileSystemException catch (error) {
      throw RepositoryWriteException(
        'Impossible d\'écrire dans "$filePath" : ${error.message}',
      );
    } on StateError catch (error) {
      throw RepositoryWriteException(
        'Erreur d\'état lors de la sauvegarde dans "$filePath" : $error',
      );
    } on ArgumentError catch (error) {
      throw RepositoryWriteException(
        'Erreur d\'argument lors de la sauvegarde dans "$filePath" : ${error.message}',
      );
    }
    // Les autres exceptions remontent normalement
  }
}

class TaskRepository extends Repository<Task> {
  TaskRepository({required super.filePath})
    : super(fromJson: Task.fromJson, toJson: _taskToJson);

  static Map<String, dynamic> _taskToJson(Task task) => task.toJson();
}
