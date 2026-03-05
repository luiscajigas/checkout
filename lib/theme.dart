import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4A6CF7);
  static const background = Color(0xFFF0F2F8);
  static const white = Colors.white;
  static const textDark = Color(0xFF1A1A2E);
  static const textGrey = Color(0xFF9B9BB4);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: false,
      );
}