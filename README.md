# Task Manager CLI

Application Dart en ligne de commande permettant de gérer des tâches avec une persistance locale dans un fichier JSON.

## Fonctionnalités

- ajout de tâches simples ;
- ajout de tâches urgentes avec une raison d'urgence ;
- liste des tâches ;
- tri par priorité, date limite ou titre ;
- marquage d'une tâche comme terminée ;
- suppression d'une tâche ;
- sérialisation/désérialisation JSON ;
- exceptions personnalisées ;
- tests unitaires et test de la CLI ;
- intégration continue avec GitHub Actions.

## Architecture

```text
bin/
  tasks.dart                 # Point d'entrée CLI

lib/
  exceptions/                # Exceptions métier et repository
  models/                    # Task, SimpleTask, UrgentTasks
  repository/                # Persistance JSON générique + TaskRepository
  services/                  # Logique métier
```

`Task` est abstraite et implémente `TaskOperations`. `SimpleTask` et `UrgentTasks` héritent de `Task`. `Repository<T>` est réellement générique et `TaskRepository` le spécialise pour `Task`.

## Installation

```bash
dart pub get
```

## Utilisation

Afficher l'aide :

```bash
dart run bin/tasks.dart help
```

Ajouter une tâche :

```bash
dart run bin/tasks.dart add "Apprendre Dart" high
```

Ajouter une échéance :

```bash
dart run bin/tasks.dart add "Préparer le projet" medium 2026-08-20T18:00:00
```

Ajouter une tâche urgente :

```bash
dart run bin/tasks.dart add-urgent "Corriger le bug" "Production indisponible"
```

Lister par priorité :

```bash
dart run bin/tasks.dart list priority
```

Lister par date limite :

```bash
dart run bin/tasks.dart list dueDate
```

Lister en ordre décroissant :

```bash
dart run bin/tasks.dart list priority desc
```

Compléter une tâche :

```bash
dart run bin/tasks.dart complete <id>
```

Supprimer une tâche :

```bash
dart run bin/tasks.dart delete <id>
```

Par défaut, les données sont enregistrées dans `tasks.json`. Pour utiliser un autre fichier :

```bash
dart run bin/tasks.dart list --file data/tasks.json
```

## Tests et analyse

```bash
dart test
dart analyze
```

Les tests couvrent la création, l'héritage, la sérialisation JSON, la persistance, les exceptions, le tri.

## CI/CD

Le fichier `.github/workflows/ci.yml` configure GitHub Actions. À chaque `push` ou `pull request` sur `main`, les dépendances sont installées, le projet est analysé et les tests sont exécutés.
