import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:redmine_client/components/navbar.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    if (!appProvider.isLoggedIn && !appProvider.loginInProcess) {
      appProvider.autoLogIn(context);
    }

    return NavBar(
      child: child,
    );
  }
}
