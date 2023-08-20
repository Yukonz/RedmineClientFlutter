import 'package:flutter/material.dart';

class TaskTitleCard extends StatelessWidget {
  static const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);
  
  final Color colorUrgent = const Color.fromRGBO(255, 16, 102, 1);
  final Color colorHigh = const Color.fromRGBO(0, 224, 152, 1);
  final Color colorNormal = const Color.fromRGBO(215, 221, 230, 1);
  final Color colorLow = const Color.fromRGBO(0, 128, 255, 1);

  static const TextStyle taskTitleTextStyle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor);
  
  static const TextStyle taskContentTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, color: mainTextColor);

  static const TextStyle taskInfoTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: mainTextColor);

  const TaskTitleCard({
    super.key,
    required this.id,
    required this.priority,
    required this.subject,
    required this.details,
    required this.author,
    required this.date,
  });

  final int id;
  final String priority;
  final String subject;
  final String details;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
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
                '#$id - $subject',
                style: taskTitleTextStyle,
              ),
              const SizedBox(height: 10),
              Text(
                details,
                style: taskContentTextStyle,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    author,
                    style: taskInfoTextStyle,
                  ),
                  const Spacer(),
                  Text(
                    date,
                    style: taskInfoTextStyle,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
