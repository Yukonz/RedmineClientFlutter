import 'package:flutter/material.dart';

const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);
const Color colorUrgent = Color.fromRGBO(255, 16, 102, 1);
const Color colorHigh = Color.fromRGBO(0, 224, 152, 1);
const Color colorNormal = Color.fromRGBO(215, 221, 230, 1);
const Color colorLow = Color.fromRGBO(0, 128, 255, 1);

final ThemeData rcClientTheme = ThemeData(
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: mainTextColor,),
    bodySmall: TextStyle(fontSize: 14.0, color: mainTextColor,),
    bodyMedium: TextStyle(fontSize: 16.0, color: mainTextColor,),
    bodyLarge: TextStyle(fontSize: 18.0, color: mainTextColor,),
  ),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
      .copyWith(background: Colors.white),
  cardColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 2,
      ),
    ),
  ),
);
