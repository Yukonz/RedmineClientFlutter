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

    for (var i = 0; i < json['issue']['attachments'].length; i++) {
      issueAttachments.add(Attachment.fromJson(json['issue']['attachments'][i]));
    }

    for (var i = 0; i < json['issue']['journals'].length; i++) {
      issueJournals.add(Journal.fromJson(json['issue']['journals'][i]));
    }

    return IssueDetails(
      id:          json['issue']['id'],
      priority:    json['issue']['priority']['name'],
      author:      json['issue']['author']['name'],
      assignedTo:  json['issue']['assigned_to']['name'],
      subject:     json['issue']['subject'],
      dateCreated: json['issue']['created_on'],
      description: json['issue']['description'],
      journals:    issueJournals,
      attachments: issueAttachments,
    );
  }
}