class Task {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });
}
