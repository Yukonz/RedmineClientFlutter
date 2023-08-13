import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:redmine_client/pages/home.dart';

void main() {
  runApp(const RedmineClient());
}

class RedmineClient extends StatelessWidget {
  const RedmineClient({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RedmineClientProvider(),
      child: MaterialApp(
        title: 'Redmine Client App',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}