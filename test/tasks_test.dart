import 'package:tasks/models/simple_tasks.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/models/urgent_tasks.dart';
import 'package:test/test.dart';

void main() {
  test('Une tâche simple est correctement créée', () {
    final task = SimpleTask(
      id: 'test_1',
      title: 'Tâche de test',
      priority: Priority.high,
    );
    expect(task.id, 'test_1');
    expect(task.title, 'Tâche de test');
    expect(task.priority, Priority.high);
    expect(task.getTaskType(), 'SimpleTask');
  });

  test('Une tâche urgente hérite de Task', () {
    final task = UrgentTasks(
      id: 'urgent_1',
      title: 'Urgence critique',
      urgencyReason: 'Serveur indisponible',
    );
    expect(task, isA<Task>());
    expect(task.priority, Priority.high);
    expect(task.urgencyReason, 'Serveur indisponible');
  });

  test('Une tâche terminée n’est plus en retard', () {
    final task = SimpleTask(
      id: 'late',
      title: 'Tâche en retard',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    expect(task.isOverdue(), isTrue);
    task.markAsCompleted();
    expect(task.isCompleted, isTrue);
    expect(task.isOverdue(), isFalse);
  });

  test('La sérialisation conserve le type urgent', () {
    final original = UrgentTasks(
      id: 'urgent_json',
      title: 'Déployer',
      urgencyReason: 'Production',
    );
    final restored = Task.fromJson(original.toJson());
    expect(restored, isA<UrgentTasks>());
    expect(restored.id, original.id);
    expect((restored as UrgentTasks).urgencyReason, 'Production');
  });
}
