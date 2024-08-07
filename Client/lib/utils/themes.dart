import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
  ),
  appBarTheme: const AppBarTheme(
    color: Color.fromRGBO(47, 95, 73, 1.0),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(101, 157, 82, 1.0)),
);


ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    color: Color.fromRGBO(47, 95, 73, 1.0),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(21, 59, 48, 1.0),
    brightness: Brightness.dark,
  ),
);
