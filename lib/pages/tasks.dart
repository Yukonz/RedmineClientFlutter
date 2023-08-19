import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:redmine_client/models/issue_details.dart';

import 'package:redmine_client/components/tasks_pie_chart.dart';
import 'package:redmine_client/components/loading_animation.dart';
import 'package:redmine_client/components/task_card.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  static const mainTextColor = Color.fromRGBO(51, 64, 84, 1);

  final Color colorUrgent = const Color.fromRGBO(255, 16, 102, 1);
  final Color colorHigh = const Color.fromRGBO(0, 224, 152, 1);
  final Color colorNormal = const Color.fromRGBO(215, 221, 230, 1);
  final Color colorLow = const Color.fromRGBO(0, 128, 255, 1);

  static const TextStyle nameCellStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: mainTextColor);

  static const TextStyle valueCellStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, color: mainTextColor);

  static const TextStyle titleTextStyle = TextStyle(
      fontSize: 28, fontWeight: FontWeight.bold, color: mainTextColor);

  static const TextStyle taskTitleTextStyle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor);

  static const TextStyle taskContentTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, color: mainTextColor);

  static const TextStyle taskInfoTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: mainTextColor);

  static const EdgeInsets tasksCellPadding =
      EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0);

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    int tasksNumberUrgent = 0;
    int tasksNumberHigh = 0;
    int tasksNumberNormal = 0;
    int tasksNumberLow = 0;

    if (appProvider.isLoggedIn && !appProvider.isTasksLoaded) {
      appProvider.getTasks();
    }

    Widget tasksListContent = const Text('Please login to see your tasks');

    Widget taskListHeading = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color.fromRGBO(247, 246, 251, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Row(
          children: [
            const Text('My Tasks', style: titleTextStyle),
            const Spacer(),
            Visibility(
              visible: appProvider.isTaskDetailsLoaded,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  appProvider.backToTasksList();
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (appProvider.isLoggedIn) {
      if (appProvider.currentTaskID != 0) {
        return FutureBuilder<IssueDetails>(
          future: appProvider.taskDetails,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Color cardBorderColor = Colors.white;

              switch (snapshot.data!.priority) {
                case 'Urgent':
                  cardBorderColor = colorUrgent;
                case 'High':
                  cardBorderColor = colorHigh;
                case 'Normal':
                  cardBorderColor = colorNormal;
                case 'Low':
                  cardBorderColor = colorLow;
              }

              String taskDetails =
                  appProvider.removeAllHtmlTags(snapshot.data!.description);

              String taskDate =
                  appProvider.formatDate(snapshot.data!.dateCreated);

              List<Widget> taskJournals = <Widget>[];

              for (var i = 0; i < snapshot.data!.journals.length; i++) {
                String journalNotes = appProvider
                    .removeAllHtmlTags(snapshot.data!.journals[i].notes);

                String journalDate = appProvider
                    .formatDate(snapshot.data!.journals[i].dateCreated);

                taskJournals.add(
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    color: Colors.white,
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            journalNotes,
                            style: taskContentTextStyle,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                snapshot.data!.journals[i].authorName,
                                style: taskInfoTextStyle,
                              ),
                              const Spacer(),
                              Text(
                                journalDate,
                                style: taskInfoTextStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                    taskListHeading,
                    Expanded(
                      child: ListView(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.5),
                            ),
                            color: Colors.white,
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 0,
                            ),
                            child: ClipPath(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: cardBorderColor,
                                      width: 6,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '#${snapshot.data!.id} - ${snapshot.data!.subject}',
                                      style: taskTitleTextStyle,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      taskDetails,
                                      style: taskContentTextStyle,
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Text(
                                          snapshot.data!.author,
                                          style: taskInfoTextStyle,
                                        ),
                                        const Spacer(),
                                        Text(
                                          taskDate,
                                          style: taskInfoTextStyle,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Column(children: taskJournals)
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
      } else {
        tasksListContent = FutureBuilder<List<dynamic>?>(
          future: appProvider.userTasks,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<TaskCard> taskCards = <TaskCard>[];

              for (var i = 0; i < snapshot.data!.length; i++) {
                switch (snapshot.data![i].priority) {
                  case 'Urgent':
                    tasksNumberUrgent++;
                  case 'High':
                    tasksNumberHigh++;
                  case 'Normal':
                    tasksNumberNormal++;
                  case 'Low':
                    tasksNumberLow++;
                }

                taskCards.add(TaskCard(
                  id: snapshot.data![i].id,
                  priority: snapshot.data![i].priority,
                  subject: snapshot.data![i].subject,
                  author: snapshot.data![i].author,
                  date: appProvider.formatDate(snapshot.data![i].dateCreated),
                ));
              }

              Widget taskListBody =
                  Expanded(child: ListView(children: taskCards));

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    taskListHeading,
                    TasksPieChart(
                      urgent: tasksNumberUrgent,
                      high: tasksNumberHigh,
                      normal: tasksNumberNormal,
                      low: tasksNumberLow,
                    ),
                    taskListBody,
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

    return tasksListContent;
  }
}
