class Task {
  final String title;
  final String status;
  final DateTime? deadline;
  final Map<String, dynamic> extra;

  Task({
    required this.title,
    required this.status,
    this.deadline,
    this.extra = const {},
  });
}
