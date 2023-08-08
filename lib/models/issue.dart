class Issue {
  final int id;
  final String priority;
  final String author;
  final String assignedTo;
  final String subject;
  final String dateCreated;

  const Issue({
    required this.id,
    required this.priority,
    required this.author,
    required this.assignedTo,
    required this.subject,
    required this.dateCreated
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id:          json['id'],
      priority:    json['priority']['name'],
      author:      json['author']['name'],
      assignedTo:  json['assigned_to']['name'],
      subject:     json['subject'],
      dateCreated: json['created_on'],
    );
  }
}