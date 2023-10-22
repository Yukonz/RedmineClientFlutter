import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/components/tasks_list_heading.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:redmine_client/includes/rc_helper.dart';
import 'package:redmine_client/models/issue_details.dart';

import 'package:redmine_client/components/loading_animation.dart';
import 'package:redmine_client/components/task_title_card.dart';
import 'package:redmine_client/components/task_journal_card.dart';

class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({required this.taskID, super.key});

  final int taskID;

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    appProvider.getTaskDetails(taskID, context);

    return FutureBuilder<IssueDetails>(
      future: appProvider.taskDetails,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> taskJournals = <Widget>[];

          for (var i = 0; i < snapshot.data!.journals.length; i++) {
            taskJournals.add(
              TaskJournalCard(
                note: RcHelper
                    .removeAllHtmlTags(snapshot.data!.journals[i].notes),
                author: snapshot.data!.journals[i].authorName,
                date: RcHelper
                    .formatDate(snapshot.data!.journals[i].dateCreated),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Column(
              children: [
                const TasksListHeading(singleTaskSelected: true),
                Expanded(
                  child: ListView(
                    children: [
                      TaskTitleCard(
                        id: snapshot.data!.id,
                        priority: snapshot.data!.priority,
                        subject: snapshot.data!.subject,
                        details: RcHelper
                            .removeAllHtmlTags(snapshot.data!.description),
                        author: snapshot.data!.author,
                        date: RcHelper
                            .formatDate(snapshot.data!.dateCreated),
                      ),
                      Column(children: taskJournals),
                    ],
                  ),
                )
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const LoadingAnimation();
      },
    );
  }
}
