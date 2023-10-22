import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:redmine_client/includes/rc_provider.dart';

class LoginForm extends StatelessWidget {
  static ButtonStyle loginBtnStyle = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 26),
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
  );

  const LoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appProvider = context.watch<RedmineClientProvider>();

    final formKey = GlobalKey<FormState>();

    Widget formLoadingAnimation = SizedBox(
      height: 310,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: Center(
          child: LoadingAnimationWidget.beat(
            color: const Color.fromRGBO(0, 128, 255, 1),
            size: 75,
          ),
        ),
      ),
    );

    Widget loginForm = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10,
          ),
          child: TextFormField(
            controller: appProvider.urlController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(fontSize: 22),
              labelText: "Host URL",
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
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10,
          ),
          child: TextFormField(
            controller: appProvider.loginController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelStyle: TextStyle(fontSize: 22),
              labelText: "Login",
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
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10,
          ),
          child: TextFormField(
            controller: appProvider.passwordController,
            obscureText: !appProvider.showPassword,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Password",
              labelStyle: const TextStyle(fontSize: 22),
              suffixIcon: IconButton(
                icon: Icon(
                  appProvider.showPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  appProvider
                      .previewPassword(!appProvider.showPassword);
                },
              ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  appProvider.loginUser(true, context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill input'),
                    ),
                  );
                }
              },
              style: loginBtnStyle,
              child: const Text('Login'),
            ),
          ),
        ),
      ],
    );

    var loginWidgetContent =
        appProvider.loadingProcess ? formLoadingAnimation : loginForm;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: loginWidgetContent,
            ),
          )
        ],
      ),
    );
  }
}
