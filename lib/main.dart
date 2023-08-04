import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isLoggedIn = false;
  bool loadingProcess = false;
  bool? saveLoginDetails = false;

  String hostURL = '';
  String userLogin = '';
  String userPassword = '';

  TextEditingController urlController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RedmineClientState() {
    autoLogIn();
  }

  void autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedHostURL = prefs.getString('host_url');
    final String? savedUserLogin = prefs.getString('user_login');
    final String? savedUserPassword = prefs.getString('user_password');

    if (savedHostURL != null && savedUserLogin != null && savedUserPassword != null) {
      isLoggedIn = true;
      hostURL = savedHostURL;
      userLogin = savedUserLogin;
      userPassword = savedUserPassword;

      urlController.text = savedHostURL;
      loginController.text = savedUserLogin;
      passwordController.text = savedUserPassword;

      notifyListeners();

      return;
    }
  }

  void setSaveLoginOption(bool? saveLogin) async {
    saveLoginDetails = saveLogin;
    notifyListeners();
  }

  void toggleLoading()
  {
    loadingProcess = !loadingProcess;
    notifyListeners();
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_password', "");
    userPassword = '';
    isLoggedIn = false;

    notifyListeners();
  }

  Future<void> loginUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    toggleLoading();

    if (saveLoginDetails == true) {
      prefs.setString('host_url', urlController.text);
      prefs.setString('user_login', loginController.text);
      prefs.setString('user_password', passwordController.text);
    }

    hostURL = urlController.text;
    userLogin = loginController.text;
    userPassword = passwordController.text;
    isLoggedIn = true;

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 2000), () {
      toggleLoading();
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

  @override
  Widget build(BuildContext context) {
    StatefulWidget currentPage;

    var appState = context.watch<RedmineClientState>();

    bool loadingProcess = appState.loadingProcess;

    switch (_selectedIndex) {
      case 0:
        currentPage = AccountPage();
        break;
      case 1:
        currentPage = TasksPage();
        break;
      case 2:
        currentPage = AboutPage();
        break;
      default:
        throw UnimplementedError('No page added for $_selectedIndex');
    }

    List<String> mainMenuItems = ['User Account', 'My Tasks', 'About'];

    List<Widget> mainMenuWidgets(List<String> mainMenuItems)
    {
      List<Widget> list = <Widget>[];

      list.add(const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text(
          'Main Menu',
          style: TextStyle(color: Colors.white),
        ),
      ));

      for(var i = 0; i < mainMenuItems.length; i++){
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

    if (loadingProcess) {
      return Scaffold(
        backgroundColor: Colors.amberAccent,
        body: Center(
          child: LoadingAnimationWidget.inkDrop(
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
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Tasks',
                style: optionStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
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
  final ButtonStyle loginBtnStyle =
  ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 26),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10)
  );

  Widget loginForm()
  {
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
                      border: OutlineInputBorder(),
                      labelText: "Host URL"
                  ),
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
                      border: OutlineInputBorder(),
                      labelText: "Login"
                  ),
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
                      border: OutlineInputBorder(),
                      labelText: "Password"
                  ),
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
                  child:
                    CheckboxListTile(
                      title: const Text('Save Login Details'),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: saveLoginDetails,
                      onChanged: (bool? newValue) {
                        appState.setSaveLoginOption(newValue);
                      },
                    ),
                )
              ),
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