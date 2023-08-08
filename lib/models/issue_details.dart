import 'issue.dart';
import 'journal.dart';
import 'attachment.dart';

class IssueDetails extends Issue {
  final String description;
  final List<Journal> journals;
  final List<Attachment> attachments;

  const IssueDetails({
    required super.id,
    required super.priority,
    required super.author,
    required super.assignedTo,
    required super.subject,
    required super.dateCreated,
    required this.description,
    required this.journals,
    required this.attachments,
  });

  factory IssueDetails.fromJson(Map<String, dynamic> json) {
    List<Attachment> issueAttachments = <Attachment>[];
    List<Journal> issueJournals = <Journal>[];

    for (var i = 0; i < json['attachments'].length; i++) {
      issueAttachments.add(Attachment.fromJson(json['attachments'][i]));
    }

    for (var i = 0; i < json['journals'].length; i++) {
      issueJournals.add(Journal.fromJson(json['journals'][i]));
    }

    return IssueDetails(
      id:          json['id'],
      priority:    json['priority']['name'],
      author:      json['author']['name'],
      assignedTo:  json['assigned_to']['name'],
      subject:     json['subject'],
      dateCreated: json['created_on'],
      description: json['description'],
      journals:    issueJournals,
      attachments: issueAttachments,
    );
  }
}