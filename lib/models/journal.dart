class Journal {
  final int id;
  final int authorId;

  final String notes;
  final String dateCreated;

  const Journal({
    required this.id,
    required this.authorId,
    required this.notes,
    required this.dateCreated,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id:          json['id'],
      authorId:    json['author']['id'],
      notes:       json['notes'],
      dateCreated: json['created_on'],
    );
  }
}