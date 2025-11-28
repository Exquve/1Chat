import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? darkTheme : lightTheme;
  }

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00A884),
    scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF111B21)),
      titleTextStyle: TextStyle(
        color: Color(0xFF111B21),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE9EDEF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00A884),
      secondary: Color(0xFF25D366),
      surface: Colors.white,
      error: Color(0xFFEF5350),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF00A884),
    scaffoldBackgroundColor: const Color(0xFF0B141A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2C34),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE9EDEF)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE9EDEF),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardColor: const Color(0xFF1F2C34),
    dividerColor: const Color(0xFF2A3942),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00A884),
      secondary: Color(0xFF25D366),
      surface: Color(0xFF1F2C34),
      error: Color(0xFFEF5350),
    ),
    useMaterial3: true,
  );
}
