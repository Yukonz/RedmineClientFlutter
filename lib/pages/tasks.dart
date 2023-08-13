import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:redmine_client/models/issue_details.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  static const mainTextColor = Color.fromRGBO(51, 64, 84, 1);

  final Color colorUrgent = const Color.fromRGBO(255, 16, 102, 1);
  final Color colorHigh = const Color.fromRGBO(0, 224, 152, 1);
  final Color colorNormal = const Color.fromRGBO(215, 221, 230, 1);
  final Color colorLow = const Color.fromRGBO(0, 128, 255, 1);

  static const TextStyle nameCellStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: mainTextColor
  );

  static const TextStyle valueCellStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: mainTextColor
  );

  static const TextStyle titleTextStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: mainTextColor
  );

  static const TextStyle taskTitleTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: mainTextColor
  );

  static const TextStyle taskContentTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: mainTextColor
  );

  static const TextStyle taskInfoTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: mainTextColor
  );

  static const EdgeInsets tasksCellPadding = EdgeInsets.symmetric(
      vertical: 1.0,
      horizontal: 5.0
  );

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    int tasksNumber = 0;
    int tasksNumberUrgent = 0;
    int tasksNumberHigh = 0;
    int tasksNumberNormal = 0;
    int tasksNumberLow = 0;

    Widget tasksListContent = const SizedBox();

    Widget taskListHeading = Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: const Color.fromRGBO(247, 246, 251, 1),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(children: [
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
            ])));

    if (appProvider.isLoggedIn) {
      if (appProvider.isTaskDetailsLoaded) {
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

              String taskDetails = appProvider.removeAllHtmlTags(snapshot.data!.description);
              String taskDate = appProvider.formatDate(snapshot.data!.dateCreated);

              List<Widget> taskJournals = <Widget>[];

              for (var i = 0; i < snapshot.data!.journals.length; i++) {
                String journalNotes = appProvider.removeAllHtmlTags(snapshot.data!.journals[i].notes);
                String journalDate = appProvider.formatDate(snapshot.data!.journals[i].dateCreated);

                taskJournals.add(Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    color: Colors.white,
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 0),
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(children: [
                          Text(journalNotes, style: taskContentTextStyle),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(snapshot.data!.journals[i].authorName, style: taskInfoTextStyle),
                              const Spacer(),
                              Text(journalDate, style: taskInfoTextStyle),
                            ],
                          )
                        ]))));
              }

              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(children: [
                    taskListHeading,
                    Expanded(
                        child: ListView(children: [
                          Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.5),
                              ),
                              color: Colors.white,
                              clipBehavior: Clip.hardEdge,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 0),
                              child: ClipPath(
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                              color: cardBorderColor, width: 6),
                                        ),
                                      ),
                                      child: Column(children: [
                                        Text(
                                            '#${snapshot.data!.id} - ${snapshot.data!.subject}',
                                            style: taskTitleTextStyle),
                                        const SizedBox(height: 10),
                                        Text(taskDetails,
                                            style: taskContentTextStyle),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            Text(snapshot.data!.author,
                                                style: taskInfoTextStyle),
                                            const Spacer(),
                                            Text(taskDate,
                                                style: taskInfoTextStyle),
                                          ],
                                        )
                                      ])))),
                          Column(children: taskJournals)
                        ]))
                  ]));
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const CircularProgressIndicator();
          },
        );
      }

      if (appProvider.isTasksLoaded) {
        tasksListContent = FutureBuilder<List<dynamic>?>(
            future: appProvider.userTasks,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('My Tasks', style: titleTextStyle);
              } else {
                List<Card> taskCards = <Card>[];

                for (var i = 0; i < snapshot.data!.length; i++) {
                  String taskDate = appProvider.formatDate(snapshot.data![i].dateCreated);
                  Color cardBorderColor = Colors.white;

                  switch (snapshot.data![i].priority) {
                    case 'Urgent':
                      tasksNumberUrgent++;
                      cardBorderColor = colorUrgent;
                    case 'High':
                      tasksNumberHigh++;
                      cardBorderColor = colorHigh;
                    case 'Normal':
                      tasksNumberNormal++;
                      cardBorderColor = colorNormal;
                    case 'Low':
                      tasksNumberLow++;
                      cardBorderColor = colorLow;
                  }

                  taskCards.add(Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.5),
                      ),
                      color: Colors.white,
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.symmetric(vertical: 7.5),
                      child: ClipPath(
                          child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      color: cardBorderColor, width: 6),
                                ),
                              ),
                              child: InkWell(
                                  onTap: () {
                                    appProvider.getTaskDetails(snapshot.data![i].id);
                                  },
                                  child: Table(
                                      columnWidths: const <int,
                                          TableColumnWidth>{
                                        0: FlexColumnWidth(25),
                                        1: FlexColumnWidth(75),
                                      },
                                      defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                                padding: tasksCellPadding,
                                                child: Text('ID:',
                                                    style: nameCellStyle),
                                              )),
                                          TableCell(
                                              child: Padding(
                                                padding: tasksCellPadding,
                                                child: Text(
                                                    '${snapshot.data![i].id}',
                                                    style: valueCellStyle),
                                              )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text('Subject:',
                                                    style: nameCellStyle),
                                              )),
                                          TableCell(
                                              child: Padding(
                                                padding: tasksCellPadding,
                                                child: Text(
                                                    snapshot.data![i].subject,
                                                    style: valueCellStyle),
                                              )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text('Author:',
                                                    style: nameCellStyle),
                                              )),
                                          TableCell(
                                              child: Padding(
                                                padding: tasksCellPadding,
                                                child: Text(
                                                    snapshot.data![i].author,
                                                    style: valueCellStyle),
                                              )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text('Date:',
                                                    style: nameCellStyle),
                                              )),
                                          TableCell(
                                              child: Padding(
                                                padding: tasksCellPadding,
                                                child: Text(
                                                    taskDate,
                                                    style: valueCellStyle),
                                              )),
                                        ]),
                                      ]
                                  )
                              )
                          )
                      )
                  )
                  );
                }

                tasksNumber = snapshot.data!.length;

                Widget pieChart = SizedBox(
                    height: 150,
                    child: SfCircularChart(
                        annotations: <CircularChartAnnotation>[
                          CircularChartAnnotation(
                              widget: Text('$tasksNumber',
                                  style: const TextStyle(color: mainTextColor, fontSize: 28, fontWeight: FontWeight.bold)))
                        ],
                        tooltipBehavior: TooltipBehavior(enable: true),
                        legend: const Legend(isVisible: true),
                        series: [
                          DoughnutSeries<_ChartData, String>(
                              dataSource: [
                                _ChartData('Urgent', tasksNumberUrgent, colorUrgent),
                                _ChartData('High', tasksNumberHigh, colorHigh),
                                _ChartData('Normal', tasksNumberNormal, colorNormal),
                                _ChartData('Low', tasksNumberLow, colorLow)
                              ],
                              pointColorMapper: (_ChartData data, _) =>
                              data.color,
                              xValueMapper: (_ChartData data, _) =>
                              '${data.x}: ${data.y}',
                              yValueMapper: (_ChartData data, _) => data.y,
                              name: 'Tasks')
                        ]
                    )
                );

                Widget taskListBody = Expanded(
                    child: ListView(
                        children: taskCards
                    )
                );

                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(children: [
                      taskListHeading,
                      pieChart,
                      taskListBody
                    ]
                    )
                );
              }
            });
      } else {
        appProvider.getTasks();
      }
    }

    if (!appProvider.isLoggedIn || !appProvider.isTasksLoaded ||
        (appProvider.showTaskID != 0 && !appProvider.isTaskDetailsLoaded)) {
      tasksListContent = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(children: [
            taskListHeading,
            const Spacer(),
            const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(0, 128, 255, 1)
                )
            ),
            const Spacer(),
          ]));
    }

    return tasksListContent;
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);

  final String x;
  final int y;
  final Color color;
}
