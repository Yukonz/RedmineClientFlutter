import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/components/login_form.dart';
import '../includes/rc_provider.dart';

class AccountPage extends StatelessWidget {

  const AccountPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    if (!appProvider.isLoggedIn) {
      appProvider.autoLogIn();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: const LoginForm(),
      ),
    );
  }
}
