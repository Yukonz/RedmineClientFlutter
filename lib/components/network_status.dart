import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';

class NetworkStatus extends StatelessWidget {
  static const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);

  static const TextStyle titleTextStyle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor);

  const NetworkStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    Widget networkStatusText = const Text('No internet connection', style: titleTextStyle);
    if (appProvider.internetConnection == true) {
      networkStatusText = const Text('Real-time data', style: titleTextStyle);
    }

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
            networkStatusText,
            const Spacer(),
            Visibility(
              visible: !appProvider.internetConnection,
              child: IconButton(
                icon: const Icon(Icons.warning_amber_rounded),
                onPressed: () {
                  appProvider.checkInternetConnection();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
