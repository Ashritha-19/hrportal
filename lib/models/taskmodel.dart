enum TaskStatus { pending, inProgress, completed }

class TaskModel {
  final String title;
  final String project;
  final String due;
  final String priority;
  final TaskStatus status;

  TaskModel({
    required this.title,
    required this.project,
    required this.due,
    required this.priority,
    required this.status,
  });
}
