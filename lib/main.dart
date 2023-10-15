import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:redmine_client/pages/about.dart';
import 'package:redmine_client/pages/account.dart';
import 'package:redmine_client/pages/tasks.dart';
import 'package:redmine_client/pages/task_details.dart';
import 'package:redmine_client/components/navbar.dart';

void main() {
  runApp(const RedmineClient());
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  navigatorKey: _navigatorKey,
  routes: [
    ShellRoute(
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: NavBar(
            child: child,
          ),
        );
      },
      routes: [
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const AccountPage();
          },
        ),
        GoRoute(
          name: 'tasks',
          path: '/tasks',
          builder: (BuildContext context, GoRouterState state) {
            return const TasksPage();
          },
          routes: <GoRoute>[
            GoRoute(
              name: 'task_details',
              path: ':taskID',
              builder: (BuildContext context, GoRouterState state) {
                return TaskDetailsPage(taskID: int.parse(state.pathParameters['taskID']!));
              },
            ),
          ],
        ),
        GoRoute(
          name: 'about',
          path: '/about',
          builder: (BuildContext context, GoRouterState state) {
            return const AboutPage();
          },
        ),
      ],
    ),
  ],
);

class RedmineClient extends StatelessWidget {
  const RedmineClient({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RedmineClientProvider(),
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'Redmine Client App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
      ),
    );
  }
}