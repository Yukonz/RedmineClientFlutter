import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() {
  runApp(const RedmineClient());
}

class RedmineClient extends StatelessWidget {
  const RedmineClient({super.key});

  static const appTitle = 'Redmine Client App';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      home: MainPage(title: appTitle),
    );
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

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    StatefulWidget currentPage;

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
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      body: Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Colors.white,
          size: 75,
        ),
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
  bool _loginInProcess = false;

  TextEditingController urlController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final ButtonStyle loginBtnStyle =
  ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 26),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10)
  );

  Widget loadingAnimation()
  {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      body: Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Colors.white,
          size: 70,
        ),
      ),
    );
  }

  Widget loginForm()
  {
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
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
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
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loginInProcess = true;
                        });
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
    Widget currentAction;

    if (_loginInProcess) {
      currentAction = loadingAnimation();
    } else {
      currentAction = loginForm();
    }

    return currentAction;
  }
}