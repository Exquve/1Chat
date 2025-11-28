import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/chats_list_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '1Chat',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: const LoginScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/chats') {
              final args = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder: (context) => ChatsListScreen(
                  userName: args['name']!,
                  userPhone: args['phone']!,
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
