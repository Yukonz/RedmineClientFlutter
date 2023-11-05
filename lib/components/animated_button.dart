import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  const AnimatedButton({
    super.key,
    required this.loading,
    required this.text,
    required this.loadingText,
    required this.color,
    required this.textColor,
    required this.onTapAction,
  });

  final bool loading;
  final String text;
  final String loadingText;
  final Color color;
  final Color textColor;
  final Function onTapAction;

  @override
  Widget build(BuildContext context) {
    TextStyle buttonTextStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: textColor,
    );

    String buttonText = text;
    Widget loadingAnimation = Container();

    if (loading) {
      loadingAnimation = SizedBox(
        height: 20.0,
        width: 35.0,
        child: Container(
          padding: const EdgeInsets.only(left: 15.0),
          child: const CircularProgressIndicator(color: Colors.white,),
        ),
      );

      buttonText = loadingText;
    }

    return SizedBox(
      width: 200.0,
      child: InkWell(
        onTap: (){
          if (!loading) {
            onTapAction();
          }
        },
        child: Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(children: [
            const Spacer(),
            Text(
              buttonText,
              style: buttonTextStyle,
            ),
            loadingAnimation,
            const Spacer(),
          ]),
        ),
      ),
    );
  }
}
