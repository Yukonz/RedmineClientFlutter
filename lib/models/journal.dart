class Journal {
  final int id;
  final int authorId;

  final String notes;
  final String authorName;
  final String dateCreated;

  const Journal({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.notes,
    required this.dateCreated,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id:          json['id']           ?? 0,
      authorId:    json['user']['id']   ?? 0,
      authorName:  json['user']['name'] ?? '',
      notes:       json['notes']        ?? '',
      dateCreated: json['created_on']   ?? ''
    );
  }
}