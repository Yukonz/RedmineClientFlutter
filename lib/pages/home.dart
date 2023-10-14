// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:redmine_client/includes/rc_provider.dart';
// import 'package:redmine_client/pages/account.dart';
// import 'package:redmine_client/pages/tasks.dart';
// import 'package:redmine_client/pages/about.dart';
// import 'package:redmine_client/models/user.dart';
//
// import 'package:redmine_client/components/user_info.dart';
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     Widget currentPage;
//
//     var appProvider = context.watch<RedmineClientProvider>();
//
//     bool singleTaskSelected = appProvider.currentTaskID > 0;
//
//     late Future<User> currentUser = appProvider.currentUser;
//
//     switch (appProvider.currentPageID) {
//       case 0:
//         currentPage = const AccountPage();
//         break;
//       case 1:
//         currentPage = const TasksPage();
//         break;
//       case 2:
//         currentPage = const AboutPage();
//         break;
//       default:
//         throw UnimplementedError(
//             'No page added for ${appProvider.currentPageID}');
//     }
//
//     double drawerHeadingHeight = 100;
//
//     List<String> mainMenuItems = ['User Account', 'My Tasks', 'About'];
//
//     List<Widget> mainMenuWidgets(List<String> mainMenuItems) {
//       List<Widget> list = <Widget>[];
//       List<Widget> headerContent = <Widget>[];
//
//       if (appProvider.isLoggedIn) {
//         drawerHeadingHeight = 275;
//
//         headerContent.add(
//           FutureBuilder<User>(
//             future: currentUser,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 return UserInfo(
//                   avatarURL: snapshot.data!.avatarUrl,
//                   firstName: snapshot.data!.firstName,
//                   lastName: snapshot.data!.lastName,
//                   email: snapshot.data!.email,
//                 );
//               } else if (snapshot.hasError) {
//                 return Text('${snapshot.error}');
//               }
//
//               // By default, show a loading spinner.
//               return const CircularProgressIndicator();
//             },
//           ),
//         );
//       } else {
//         headerContent.add(
//           const Text(
//             'Main Menu',
//             style: TextStyle(color: Colors.white),
//           ),
//         );
//       }
//
//       list.add(
//         SizedBox(
//           height: drawerHeadingHeight,
//           child: DrawerHeader(
//             decoration: const BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Column(children: headerContent),
//           ),
//         ),
//       );
//
//       for (var i = 0; i < mainMenuItems.length; i++) {
//         list.add(
//           ListTile(
//             title: Text(mainMenuItems[i]),
//             selected: appProvider.currentPageID == i,
//             onTap: () {
//               // Update the state of the app
//               appProvider.setCurrentPage(i);
//               // Then close the drawer
//               Navigator.pop(context);
//
//               if (singleTaskSelected) {
//                 appProvider.backToTasksList();
//               }
//             },
//           ),
//         );
//       }
//       return list;
//     }
//
//     if (appProvider.showAlert) {
//       appProvider.showAlert = false;
//
//       return Container(
//         color: Colors.white,
//         child: AlertDialog(
//           title: const Text("Information"),
//           content: Text(appProvider.alertMessage),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 appProvider.setCurrentPage(appProvider.currentPageID);
//               },
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (appProvider.loadingProcess) {
//       return Scaffold(
//         backgroundColor: const Color.fromRGBO(0, 128, 255, 1),
//         body: Center(
//           child: LoadingAnimationWidget.beat(
//             color: Colors.white,
//             size: 75,
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Redmine Client app')),
//       body: Center(
//         child: AccountPage(),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: mainMenuWidgets(mainMenuItems),
//         ),
//       ),
//     );
//   }
// }
