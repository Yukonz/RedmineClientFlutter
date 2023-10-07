class Journal {
  final int taskId;
  final int id;
  final int authorId;

  final String notes;
  final String authorName;
  final String dateCreated;

  const Journal({
    required this.taskId,
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.notes,
    required this.dateCreated,
  });

  factory Journal.fromJson(int taskId, Map<String, dynamic> json) {
    return Journal(
      taskId:      taskId,
      id:          json['id']           ?? 0,
      authorId:    json['user']['id']   ?? 0,
      authorName:  json['user']['name'] ?? '',
      notes:       json['notes']        ?? '',
      dateCreated: json['created_on']   ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'author_id': authorId,
      'author_name': authorName,
      'notes': notes,
      'date_created': dateCreated,
      'hash': hashCode,
    };
  }
}