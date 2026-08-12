abstract interface class TaskOperations {
  void markAsCompleted();
  bool isOverdue();
  Map<String, dynamic> toJson();
}
