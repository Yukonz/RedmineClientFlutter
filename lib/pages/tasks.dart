import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/components/network_status.dart';
import 'package:redmine_client/components/tasks_list_heading.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:redmine_client/includes/rc_helper.dart';

import 'package:redmine_client/components/tasks_pie_chart.dart';
import 'package:redmine_client/components/loading_animation.dart';
import 'package:redmine_client/components/task_card.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  Key _key = UniqueKey();

  void reloadTasksPage() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    int tasksNumberUrgent = 0;
    int tasksNumberHigh = 0;
    int tasksNumberNormal = 0;
    int tasksNumberLow = 0;

    if (appProvider.isLoggedIn && !appProvider.isTasksLoaded) {
      appProvider.getTasks(context);
    }

    return FutureBuilder<List<dynamic>?>(
      key: _key,
      future: appProvider.userTasks,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const LoadingAnimation();
          }

          List<TaskCard> taskCards = <TaskCard>[];

          tasksNumberUrgent = 0;
          tasksNumberHigh = 0;
          tasksNumberNormal = 0;
          tasksNumberLow = 0;

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
              date: RcHelper.formatDate(snapshot.data![i].dateCreated),
            ));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Column(
              children: [
                const TasksListHeading(singleTaskSelected: false),
                TasksPieChart(
                  urgent: tasksNumberUrgent,
                  high: tasksNumberHigh,
                  normal: tasksNumberNormal,
                  low: tasksNumberLow,
                ),
                const NetworkStatus(),
                Expanded(
                  child: ListView(children: taskCards),
                ),
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
