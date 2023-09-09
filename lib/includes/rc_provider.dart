import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  RedmineClientProvider() {
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

    ApiController apiController = ApiController(
      hostURL: hostURL,
      login: userLogin,
      password: userPassword,);

    currentUser = apiController.getCurrentUser();

    currentUser.then((userData) {
      prefs.setBool('last_login_success', true);

      hostURL = urlController.text;
      userLogin = loginController.text;
      userPassword = passwordController.text;
      isLoggedIn = true;

      toggleLoading(false);
      notifyListeners();

      if (showConfirmMsg) {
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

  Future<void> getTasks() async {
    ApiController apiController = ApiController(
      hostURL: hostURL,
      login: userLogin,
      password: userPassword,);

    userTasks = apiController.getAssignedTasks();

    isTasksLoaded = true;

    userTasks.then((issues) {
      DbController dbController = DbController();
      dbController.storeIssuesToDb(issues);
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