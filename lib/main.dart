import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redmine_client/models/user.dart';
import 'package:redmine_client/controllers/api.dart';

void main() {
  runApp(const RedmineClient());
}

class RedmineClient extends StatelessWidget {
  const RedmineClient({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RedmineClientState(),
      child: MaterialApp(
        title: 'Redmine Client App',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const MainPage(title: 'Redmine Client App'),
      ),
    );
  }
}

class RedmineClientState extends ChangeNotifier {
  int showPageID = 0;

  bool isLoggedIn = false;
  bool isTasksLoaded = false;
  bool loadingProcess = false;
  bool showAlert = false;
  bool? saveLoginDetails = false;

  String hostURL = '';
  String userLogin = '';
  String userPassword = '';

  String alertMessage = '';

  TextEditingController urlController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late Future<User> currentUser;
  late Future<List> userTasks;

  RedmineClientState() {
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
        loginUser();
      }

      notifyListeners();

      return;
    }
  }

  void setSaveLoginOption(bool? saveLogin) async {
    saveLoginDetails = saveLogin;
    notifyListeners();
  }

  void toggleLoading(bool loadingAnimation) {
    loadingProcess = loadingAnimation;
    notifyListeners();
  }

  void showAlertMessage(String message, int pageID) {
    showAlert = true;
    alertMessage = message;
    showPageID = pageID;

    notifyListeners();
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('user_password', "");
    prefs.setBool('last_login_success', false);

    userPassword = '';
    isLoggedIn = false;
    isTasksLoaded = false;

    showAlertMessage('You have logged out', 0);
    notifyListeners();
  }

  Future<void> loginUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    toggleLoading(true);

    if (saveLoginDetails == true) {
      prefs.setString('host_url', urlController.text);
      prefs.setString('user_login', loginController.text);
      prefs.setString('user_password', passwordController.text);
    }

    ApiController apiController = ApiController(
        hostURL: urlController.text,
        login: loginController.text,
        password: passwordController.text);

    currentUser = apiController.getCurrentUser();

    currentUser.then((userData) {
      prefs.setBool('last_login_success', true);

      hostURL = urlController.text;
      userLogin = loginController.text;
      userPassword = passwordController.text;
      isLoggedIn = true;

      toggleLoading(false);
      notifyListeners();
      showAlertMessage('You have successfully logged into account', 1);
    }).catchError((error) {
      prefs.setBool('last_login_success', false);

      toggleLoading(false);
      showAlertMessage('Unable to login: $error', 0);
    });
  }

  Future<void> getTasks() async {
    ApiController apiController = ApiController(
        hostURL: urlController.text,
        login: loginController.text,
        password: passwordController.text);

    toggleLoading(true);

    userTasks = apiController.getAssignedTasks();

    userTasks.then((userData) {
      toggleLoading(false);
      isTasksLoaded = true;
      notifyListeners();
    }).catchError((error) {
      toggleLoading(false);
      showAlertMessage('Unable to login: $error', 0);
    });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void showTasksPage() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    StatefulWidget currentPage;

    var appState = context.watch<RedmineClientState>();

    bool isLoggedIn = appState.isLoggedIn;
    bool loadingProcess = appState.loadingProcess;
    bool showAlert = appState.showAlert;

    int showPageID = appState.showPageID;
    String alertMessage = appState.alertMessage;

    late Future<User> currentUser = appState.currentUser;

    switch (_selectedIndex) {
      case 0:
        currentPage = const AccountPage();
        break;
      case 1:
        currentPage = const TasksPage();
        break;
      case 2:
        currentPage = const AboutPage();
        break;
      default:
        throw UnimplementedError('No page added for $_selectedIndex');
    }

    const userDetailsTextStyle = TextStyle(fontSize: 18, color: Colors.white);

    List<String> mainMenuItems = ['User Account', 'My Tasks', 'About'];

    List<Widget> mainMenuWidgets(List<String> mainMenuItems) {
      List<Widget> list = <Widget>[];
      List<Widget> headerContent = <Widget>[];

      if (isLoggedIn) {
        headerContent.add(
          FutureBuilder<User>(
            future: currentUser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: [
                  Text(snapshot.data!.login, style: userDetailsTextStyle),
                  Text(snapshot.data!.email, style: userDetailsTextStyle),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                    child: const Text('Logout'),
                    onPressed: () {
                      appState.logout();
                    },
                  ),
                ]);
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

      list.add(DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
          child: Column(children: headerContent)));

      for (var i = 0; i < mainMenuItems.length; i++) {
        list.add(
          ListTile(
            title: Text(mainMenuItems[i]),
            selected: _selectedIndex == i,
            onTap: () {
              // Update the state of the app
              _onItemTapped(i);
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        );
      }
      return list;
    }

    if (showAlert) {
      appState.showAlert = false;

      return Container(
          color: Colors.white,
          child: AlertDialog(
            title: const Text("Information"),
            content: Text(alertMessage),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    _selectedIndex = showPageID;
                  });
                },
              ),
            ],
          ));
    } else if (loadingProcess) {
      return Scaffold(
        backgroundColor: Color.fromRGBO(0, 128, 255, 1),
        body: Center(
          child: LoadingAnimationWidget.beat(
            color: Colors.white,
            size: 75,
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: currentPage,
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
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  static const mainTextColor = Color.fromRGBO(51, 64, 84, 1);
  static const TextStyle nameCellStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainTextColor);
  static const TextStyle valueCellStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainTextColor);
  static const TextStyle titleTextStyle = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: mainTextColor);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<RedmineClientState>();

    Widget tasksListContent = const SizedBox();

    Widget taskListHeading = Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: const Color.fromRGBO(247, 250, 250, 1),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Text('My Tasks', style: titleTextStyle),
        ));

    if (appState.isLoggedIn) {
      if (appState.isTasksLoaded) {
        tasksListContent = FutureBuilder<List<dynamic>?>(
            future: appState.userTasks,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('My Tasks', style: titleTextStyle);
              } else {
                List<TableRow> tableRows = <TableRow>[];

                for (var i = 0; i < snapshot.data!.length; i++) {
                  tableRows.add(TableRow(children: [
                    TableCell(
                        child: Table(
                            border: const TableBorder(bottom: BorderSide()),
                            columnWidths: const <int, TableColumnWidth>{
                              0: FlexColumnWidth(25),
                              1: FlexColumnWidth(75),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text('ID:', style: nameCellStyle),
                                  )
                                ),
                                TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text('${snapshot.data![i].id}', style: valueCellStyle),
                                    )
                                ),
                              ]),
                              TableRow(children: [
                                const TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text('Subject:', style: nameCellStyle),
                                    )
                                ),
                                TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(snapshot.data![i].subject, style: valueCellStyle),
                                    )
                                ),
                              ]),
                              TableRow(children: [
                                const TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text('Author:', style: nameCellStyle),
                                    )
                                ),
                                TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(snapshot.data![i].author, style: valueCellStyle),
                                    )
                                ),
                              ]),
                              TableRow(children: [
                                const TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text('Date:', style: nameCellStyle),
                                    )
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(snapshot.data![i].dateCreated, style: valueCellStyle),
                                  )
                                ),
                              ]),
                            ]))
                  ]));
                }

                return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(children: [
                      taskListHeading,
                      Expanded(
                          child: SingleChildScrollView(
                              child: Table(
                                  columnWidths: const <int, TableColumnWidth>{
                                    0: FlexColumnWidth(25),
                                    1: FlexColumnWidth(75),
                                  }, defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                    children: tableRows
                              )
                          )
                      )
                    ]));
              }
            });
      } else {
        appState.getTasks();
      }
    }

    if (!appState.isLoggedIn || !appState.isTasksLoaded) {
      tasksListContent = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(children: [
            taskListHeading,
            const SizedBox(height: 150.0),
            const CircularProgressIndicator()
          ]));
    }

    return tasksListContent;
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<RedmineClientState>();

    ApiController apiController = ApiController(
        hostURL: appState.hostURL,
        login: appState.userLogin,
        password: appState.userPassword);

    if (appState.isLoggedIn == true) {}

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'About this application',
                style: optionStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();

  final ButtonStyle loginBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 26),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10));

  Widget loginForm() {
    var appState = context.watch<RedmineClientState>();

    bool? saveLoginDetails = appState.saveLoginDetails;

    TextEditingController urlController = appState.urlController;
    TextEditingController loginController = appState.loginController;
    TextEditingController passwordController = appState.passwordController;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Host URL"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter host URL';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  controller: loginController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Login"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Login';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  autofocus: true,
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                    ),
                    child: CheckboxListTile(
                      title: const Text('Save Login Details'),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: saveLoginDetails,
                      onChanged: (bool? newValue) {
                        appState.setSaveLoginOption(newValue);
                      },
                    ),
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        appState.loginUser();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    style: loginBtnStyle,
                    child: const Text('Login'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loginForm();
  }
}
