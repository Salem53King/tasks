import 'task.dart';
import 'urgent_tasks.dart';

void displayTasks(
  List<Task> tasks, {
  String sortBy = 'priority',
  bool descending = false,
}) {
  if (tasks.isEmpty) {
    print('Aucune tâche.');
    return;
  }

  final sorted = [...tasks];
  int compare(Task a, Task b) {
    switch (sortBy) {
      case 'priority':
        return a.priority.index.compareTo(b.priority.index);
      case 'dueDate':
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      case 'title':
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      default:
        return 0;
    }
  }

  sorted.sort(compare);
  final displayList = descending ? sorted.reversed.toList() : sorted;

  print('--- ${displayList.length} tâche(s) ---');
  for (var i = 0; i < displayList.length; i++) {
    final task = displayList[i];
    final status = task.isCompleted ? '[X]' : '[ ]';
    final priority = task.priority.name.toUpperCase();
    final due = task.dueDate == null
        ? ''
        : ' | échéance: ${task.dueDate!.toLocal()}';
    final type = task is UrgentTasks ? ' | URGENT: ${task.urgencyReason}' : '';

    print('${i + 1}. $status [$priority] ${task.title}$due$type');
    print('   ID: ${task.id}');
  }
}
