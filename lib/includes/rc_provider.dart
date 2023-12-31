import 'dart:convert';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redmine_client/controllers/db.dart';
import 'package:redmine_client/controllers/api.dart';
import 'package:redmine_client/models/user.dart';
import 'package:redmine_client/models/issue_details.dart';

class RedmineClientProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  bool loginInProcess = false;
  bool isTasksLoaded = false;

  bool loadingProcess = false;
  bool showPassword = false;
  bool showAlert = false;

  String hostURL = '';
  String userLogin = '';
  String userPassword = '';

  TextEditingController urlController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late Future<User> currentUser;
  late Future<List> userTasks;
  late Future<IssueDetails> taskDetails;

  bool internetConnection = true;

  RedmineClientProvider() {
    checkInternetConnection();
  }

  void autoLogIn(BuildContext widgetContext) async {
    loginInProcess = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedHostURL = prefs.getString('host_url');
    final String? savedUserLogin = prefs.getString('user_login');
    final String? savedUserPassword = prefs.getString('user_password');
    final bool? lastLoginSuccess = prefs.getBool('last_login_success');

    if (savedHostURL != null &&
        savedUserLogin != null &&
        savedUserPassword != null) {
      hostURL = savedHostURL;
      userLogin = savedUserLogin;
      userPassword = savedUserPassword;

      urlController.text = savedHostURL;
      loginController.text = savedUserLogin;
      passwordController.text = savedUserPassword;

      if (lastLoginSuccess == true) {
        loginUser(false, widgetContext);
      }
    }
  }

  checkInternetConnection() async {
    print('checkInternetConnection');
    internetConnection = true;
    return;

    final result = await Ping('projects.rebsoc.com', count: 1).stream.first;
    internetConnection = result.response?.ip != null;
    notifyListeners();
  }

  void setSaveLoginOption(bool? saveLogin) async {
    notifyListeners();
  }

  void toggleLoading(bool loadingAnimation) {
    loadingProcess = loadingAnimation;
    notifyListeners();
  }

  void previewPassword(bool state) {
    showPassword = state;
    notifyListeners();
  }

  void refreshInternetConnectionStatus(BuildContext widgetContext) async {
    await checkInternetConnection();
    getTasks(widgetContext);
  }

  void logout(BuildContext widgetContext) async {
    showAlertDialog('Information', 'You have logged out', '/login', widgetContext);

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('user_password', "");
    prefs.setBool('last_login_success', false);

    userPassword = '';
    isLoggedIn = false;
    isTasksLoaded = false;
  }

  void showAlertDialog(String title, String message, String redirect, BuildContext context) {
    final alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            context.go(redirect);
            context.pop();
          },
          child: const Text('OK'),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> loginUser(bool showConfirmMsg, BuildContext widgetContext) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    toggleLoading(true);

    hostURL = urlController.text;
    userLogin = loginController.text;
    userPassword = passwordController.text;

    prefs.setString('host_url', urlController.text);
    prefs.setString('user_login', loginController.text);
    prefs.setString('user_password', passwordController.text);

    if (internetConnection) {
      ApiController apiController = ApiController(
        hostURL: hostURL,
        login: userLogin,
        password: userPassword,);

      currentUser = apiController.getCurrentUser();
    } else {
      currentUser = getStoredUserData();
    }

    currentUser.then((userData) {
      if (internetConnection) {
        prefs.setBool('last_login_success', true);
        prefs.setString('user_data', jsonEncode(userData.toJson()));
      }

      hostURL = urlController.text;
      userLogin = loginController.text;
      userPassword = passwordController.text;
      isLoggedIn = true;

      toggleLoading(false);
      showAlertDialog('Information', 'You have successfully logged into account', '/tasks', widgetContext);
      loginInProcess = false;
    }).catchError((error) {
      prefs.setBool('last_login_success', false);

      toggleLoading(false);
      showAlertDialog('Information', 'Unable to login: $error', '/login', widgetContext);
      loginInProcess = false;
    });
  }

  Future<User> getStoredUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userDataJSON = prefs.getString('user_data');

    if (userDataJSON != null) {
      return User.fromJson(jsonDecode(userDataJSON));
    } else {
      throw Exception('No internet connection');
    }
  }

  Future<void> getTasks(BuildContext widgetContext) async {
    DbController dbController = DbController();

    if (internetConnection) {
      ApiController apiController = ApiController(
        hostURL: hostURL,
        login: userLogin,
        password: userPassword,);

      userTasks = apiController.getAssignedTasks();
    } else {
      userTasks = dbController.getStoredIssues();
    }

    isTasksLoaded = true;

    userTasks.then((issues) {
      if (internetConnection) {
        dbController.storeIssuesToDb(issues);
      }
    }).catchError((error) {
      isTasksLoaded = false;
      showAlertDialog('Information', 'Unable load tasks list: $error', '/tasks', widgetContext);
    });
  }

  Future<void> getTaskDetails(int taskID, BuildContext widgetContext) async {
    DbController dbController = DbController();

    if (internetConnection) {
      ApiController apiController = ApiController(
        hostURL: hostURL,
        login: userLogin,
        password: userPassword,);

      taskDetails = apiController.getIssueDetails(taskID);
    } else {
      taskDetails = dbController.getStoredIssueDetails(taskID);
    }

    taskDetails.then((issueDetails) {
      if (internetConnection) {
        dbController.storeIssueDetailsToDb(issueDetails);
        dbController.storeJournalsToDb(issueDetails.id, issueDetails.journals);
      }
    }).catchError((error) {
      showAlertDialog('Information', 'Unable load task details: $error', '/tasks', widgetContext);
    });
  }
}