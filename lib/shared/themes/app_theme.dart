import 'package:flutter/material.dart';
import 'package:first_app/shared/themes/text_theme.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    textTheme: AppTextTheme.lightTextTheme,
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    textTheme: AppTextTheme.darkTextTheme,
  );
}
