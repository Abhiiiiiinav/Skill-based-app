import 'task.dart';

class Skills {
  final String id;
  final String title;
  final String? category;
  final int completedDays;
  final int totalDays;
  final List<Task>? tasks;

  Skills({
    required this.id,
    required this.title,
    this.category,
    required this.totalDays,
    required this.completedDays,
    this.tasks,
  });

  
  double get progress {
    if (tasks == null || tasks!.isEmpty) return 0.0;
    final completedTasks = tasks!.where((task) => task.isCompleted).length;
    return completedTasks / tasks!.length;
  }

  
  factory Skills.fromMap(Map<String, dynamic> map, String id) {
    return Skills(
      id: id,
      title: map['title'] ?? '',
      category: map['category'],
      completedDays: map['completedDays'] ?? 0,
      totalDays: map['totalDays'] ?? 0,
      tasks: []
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'completedDays': completedDays,
      'totalDays': totalDays,
      
    };
  }
}
