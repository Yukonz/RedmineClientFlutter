import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';

class UserInfo extends StatelessWidget {
  static const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);

  static const userDetailsTextStyle = TextStyle(
    fontSize: 18,
    color: Colors.white,
  );

  const UserInfo({
    super.key,
    required this.avatarURL,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String avatarURL;
  final String firstName;
  final String lastName;
  final String email;

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    Widget userAvatar = const Icon(Icons.person_2_rounded, size: 40, color: Colors.white);

    if (appProvider.internetConnection == true) {
      userAvatar = CircleAvatar(
        backgroundImage: NetworkImage(avatarURL),
        maxRadius: 30,
        minRadius: 30,
      );
    }

    return Column(
      children: [
        userAvatar,
        const SizedBox(height: 10.0),
        Text(
            '$firstName $lastName',
            style: userDetailsTextStyle),
        Text(
          email,
          style: userDetailsTextStyle,
        ),
        const SizedBox(height: 10.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          ),
          child: const Text('Logout'),
          onPressed: () {
            appProvider.logout();
          },
        ),
      ],
    );
  }
}
