import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:redmine_client/models/user.dart';
import 'package:redmine_client/components/user_info.dart';

class NavBar extends StatelessWidget {
  const NavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    late Future<User> currentUser = appProvider.currentUser;

    double drawerHeadingHeight = 100;

    List<String> mainMenuItems = ['User Account', 'My Tasks', 'About'];

    List<Widget> mainMenuWidgets(List<String> mainMenuItems) {
      List<Widget> list = <Widget>[];
      List<Widget> headerContent = <Widget>[];

      if (appProvider.isLoggedIn) {
        drawerHeadingHeight = 275;

        headerContent.add(
          FutureBuilder<User>(
            future: currentUser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return UserInfo(
                  avatarURL: snapshot.data!.avatarUrl,
                  firstName: snapshot.data!.firstName,
                  lastName: snapshot.data!.lastName,
                  email: snapshot.data!.email,
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        );
      } else {
        headerContent.add(
          const Text(
            'Main Menu',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      list.add(
        SizedBox(
          height: drawerHeadingHeight,
          child: DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(children: headerContent),
          ),
        ),
      );
      
      for (var i = 0; i < mainMenuItems.length; i++) {
        list.add(
          ListTile(
            title: Text(mainMenuItems[i]),
            selected: false,
            onTap: () {
              switch (i) {
                case 0:
                  context.go('/login');
                  context.pop();
                  break;
                case 1:
                  context.go('/tasks');
                  context.pop();
                  break;
                case 2:
                  context.go('/about');
                  context.pop();
                  break;
              }
            },
          ),
        );
      }

      return list;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Redmine Client app')),
      body: Center(
        child: child,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: mainMenuWidgets(mainMenuItems),
        ),
      ),
    );
  }
}
