class Skills {
  final String id;
  final String title;
  final String ?category;
  final int completedDays;
  final int totalDays;
  final List<String> ?tasks;

  Skills({
  required this.id,
  required this.title,
  this.category,
  required this.totalDays,
  required this.completedDays,
  this.tasks

});

}





