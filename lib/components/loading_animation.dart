import 'package:flutter/material.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Spacer(),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromRGBO(0, 128, 255, 1),
          ),
        ),
        Spacer(),
      ],
    );
  }
}
