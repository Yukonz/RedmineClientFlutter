import 'package:flutter/material.dart';

class TaskJournalCard extends StatelessWidget {
  static const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);

  static const TextStyle taskContentTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, color: mainTextColor);

  static const TextStyle taskInfoTextStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: mainTextColor);

  const TaskJournalCard({
    super.key,
    required this.note,
    required this.author,
    required this.date,
  });

  final String note;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
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
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              note,
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
            ),
          ],
        ),
      ),
    );
  }
}
