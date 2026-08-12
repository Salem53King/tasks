abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class TaskException extends AppException {
  const TaskException(super.message);
}

class TaskNotFoundException extends TaskException {
  final String id;
  const TaskNotFoundException(this.id)
      : super('Tâche avec ID "$id" non trouvée.');
}

class InvalidTaskException extends TaskException {
  const InvalidTaskException(super.message);
}

class RepositoryException extends AppException {
  const RepositoryException(super.message);
}

class RepositoryReadException extends RepositoryException {
  const RepositoryReadException(super.message);
}

class RepositoryWriteException extends RepositoryException {
  const RepositoryWriteException(super.message);
}

class RepositoryFormatException extends RepositoryException {
  const RepositoryFormatException(super.message);
}
