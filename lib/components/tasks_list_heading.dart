import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';

class TasksListHeading extends StatelessWidget {
  static const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);

  static const TextStyle titleTextStyle = TextStyle(
      fontSize: 28, fontWeight: FontWeight.bold, color: mainTextColor);

  const TasksListHeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    bool singleTaskSelected = appProvider.currentTaskID > 0;

    return Container(
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
              visible: singleTaskSelected,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  appProvider.backToTasksList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
