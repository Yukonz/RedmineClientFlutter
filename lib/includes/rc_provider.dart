import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:redmine_client/controllers/db.dart';
import 'package:redmine_client/controllers/api.dart';
import 'package:redmine_client/models/user.dart';
import 'package:redmine_client/models/issue_details.dart';

class RedmineClientProvider extends ChangeNotifier {
  int currentPageID = 0;
  int currentTaskID = 0;

  bool isLoggedIn = false;
  bool isTasksLoaded = false;

  bool loadingProcess = false;
  bool showPassword = false;
  bool showAlert = false;

  String hostURL = '';
  String userLogin = '';
  String userPassword = '';

  String alertMessage = '';

  TextEditingController urlController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late Future<User> currentUser;
  late Future<List> userTasks;
  late Future<IssueDetails> taskDetails;

  bool internetConnection = false;

  RedmineClientProvider() {
    checkInternetConnection();
    autoLogIn();
  }

  void autoLogIn() async {
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
        loginUser(false);
      }

      notifyListeners();
    }
  }

  void checkInternetConnection() async {
    internetConnection = await InternetConnectionChecker().hasConnection;
    notifyListeners();
  }

  void setSaveLoginOption(bool? saveLogin) async {
    notifyListeners();
  }

  void toggleLoading(bool loadingAnimation) {
    loadingProcess = loadingAnimation;
    notifyListeners();
  }

  void showAlertMessage(String message, int pageID) {
    showAlert = true;
    alertMessage = message;
    currentPageID = pageID;

    notifyListeners();
  }

  void backToTasksList() {
    currentTaskID = 0;
    notifyListeners();
  }

  void setCurrentPage(int index) {
    currentPageID = index;
    notifyListeners();
  }

  void previewPassword(bool state) {
    showPassword = state;
    notifyListeners();
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('user_password', "");
    prefs.setBool('last_login_success', false);

    userPassword = '';
    isLoggedIn = false;
    isTasksLoaded = false;
    currentTaskID = 0;

    showAlertMessage('You have logged out', 0);
    notifyListeners();
  }

  Future<void> loginUser(bool showConfirmMsg) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    toggleLoading(true);

    hostURL = urlController.text;
    userLogin = loginController.text;
    userPassword = passwordController.text;

    prefs.setString('host_url', urlController.text);
    prefs.setString('user_login', loginController.text);
    prefs.setString('user_password', passwordController.text);

    if (internetConnection == true) {
      ApiController apiController = ApiController(
        hostURL: hostURL,
        login: userLogin,
        password: userPassword,);

      currentUser = apiController.getCurrentUser();
    } else {
      currentUser = getStoredUserData();
    }

    currentUser.then((userData) {
      if (internetConnection == true) {
        prefs.setBool('last_login_success', true);
        prefs.setString('user_data', jsonEncode(userData.toJson()));
      }

      hostURL = urlController.text;
      userLogin = loginController.text;
      userPassword = passwordController.text;
      isLoggedIn = true;

      toggleLoading(false);
      notifyListeners();

      if (showConfirmMsg && internetConnection == true) {
        showAlertMessage('You have successfully logged into account', 1);
      } else {
        currentPageID = 1;
        notifyListeners();
      }
    }).catchError((error) {
      prefs.setBool('last_login_success', false);

      toggleLoading(false);
      showAlertMessage('Unable to login: $error', 0);
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

  Future<void> getTasks() async {
    DbController dbController = DbController();

    if (internetConnection == true) {
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
      if (internetConnection == true) {
        DbController dbController = DbController();
        dbController.storeIssuesToDb(issues);
      }
    }).catchError((error) {
      isTasksLoaded = false;
      showAlertMessage('Unable load tasks list: $error', 0);
    });
  }

  Future<void> getTaskDetails(int taskID) async {
    currentTaskID = taskID;

    notifyListeners();

    ApiController apiController = ApiController(
      hostURL: hostURL,
      login: userLogin,
      password: userPassword,);

    taskDetails = apiController.getIssueDetails(taskID);

    taskDetails.then((issueDetails) {
      DbController dbController = DbController();
      dbController.storeIssueDetailsToDb(issueDetails);
      dbController.storeJournalsToDb(issueDetails.id, issueDetails.journals);
    }).catchError((error) {
      currentTaskID = 0;
      showAlertMessage('Unable load task details: $error', 1);
    });
  }
}