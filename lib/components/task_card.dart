import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';

class TaskCard extends StatelessWidget {
  static const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);
  static const Color colorUrgent = Color.fromRGBO(255, 16, 102, 1);
  static const Color colorHigh = Color.fromRGBO(0, 224, 152, 1);
  static const Color colorNormal = Color.fromRGBO(215, 221, 230, 1);
  static const Color colorLow = Color.fromRGBO(0, 128, 255, 1);

  static const TextStyle nameCellStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: mainTextColor,
  );

  static const TextStyle valueCellStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: mainTextColor,
  );

  static const EdgeInsets tasksCellPadding = EdgeInsets.symmetric(
    vertical: 1.0,
    horizontal: 5.0,
  );

  const TaskCard({
    super.key,
    required this.id,
    required this.priority,
    required this.subject,
    required this.author,
    required this.date,
  });

  final int id;
  final String priority;
  final String subject;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    Color cardBorderColor = Colors.white;

    switch (priority) {
      case 'Urgent':
        cardBorderColor = colorUrgent;
      case 'High':
        cardBorderColor = colorHigh;
      case 'Normal':
        cardBorderColor = colorNormal;
      case 'Low':
        cardBorderColor = colorLow;
    }

    return Card(
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
              left: BorderSide(color: cardBorderColor, width: 6),
            ),
          ),
          child: InkWell(
            onTap: () {
              context.go('/tasks/$id');
            },
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(25),
                1: FlexColumnWidth(75),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: tasksCellPadding,
                        child: Text(
                          'ID:',
                          style: nameCellStyle,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: tasksCellPadding,
                        child: Text(
                          '$id',
                          style: valueCellStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'Subject:',
                          style: nameCellStyle,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: tasksCellPadding,
                        child: Text(
                          subject,
                          style: valueCellStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'Author:',
                          style: nameCellStyle,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: tasksCellPadding,
                        child: Text(
                          author,
                          style: valueCellStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'Date:',
                        style: nameCellStyle,
                      ),
                    )),
                    TableCell(
                      child: Padding(
                        padding: tasksCellPadding,
                        child: Text(
                          date,
                          style: valueCellStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
