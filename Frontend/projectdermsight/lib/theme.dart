import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xff2BA36A);
  static const Color background = Color(0xffF6F6F6);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
  );
}