// lib/main.dart
import 'package:ai_chat_trivia/core/providers/chat_provider.dart';
import 'package:ai_chat_trivia/ui/screens/auth_screen.dart';
import 'package:ai_chat_trivia/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/lobby_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LobbyProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'AI Chat Trivia',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AppWrapper(),
        // routes: {
        //   '/auth': (context) => const AuthScreen(),
        //   '/home': (context) => const HomeScreen(),
        // },
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Load user from preferences when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserFromPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
