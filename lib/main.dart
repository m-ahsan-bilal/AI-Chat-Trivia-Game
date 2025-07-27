// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers
import 'core/providers/user_provider.dart';
import 'core/providers/lobby_provider.dart';
import 'core/providers/chat_provider.dart';

// Theme
import 'core/theme/app_theme.dart';

// Screens
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: '🎮 AI Chat Trivia',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Home widget
            home: const AppWrapper(),

            // Global error handling
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _buildErrorWidget(errorDetails);
              };
              return child!;
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    return Scaffold(
      backgroundColor: AppTheme.errorColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${errorDetails.exception}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    switch (state) {
      case AppLifecycleState.paused:
        // App is in background
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App is back in foreground
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        // App is being closed
        _handleAppDetached();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeApp() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Initialize user provider (this loads user from preferences)
    if (mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserFromPrefs();

      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _handleAppPaused() {
    // Disconnect from chat if connected
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.isConnected) {
      chatProvider.disconnect();
    }
  }

  void _handleAppResumed() {
    // Refresh data when app comes back
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    lobbyProvider.refreshLobbies();

    // Refresh user data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.refreshUserData();
  }

  void _handleAppDetached() {
    // Clean up when app is closing
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

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

// Global app configuration
class AppConfig {
  static const String appName = 'AI Chat Trivia';
  static const String appVersion = '2.0.0';
  static const String appDescription =
      'Real-time AI-powered chat and trivia game';

  // Feature flags
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableSoundEffects = true;
  static const bool enableDebugMode = false;

  // API configuration
  static const String apiBaseUrl =
      'https://aichatapi-production.up.railway.app';
  static const String wsBaseUrl = 'wss://aichatapi-production.up.railway.app';

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;
  static const double defaultElevation = 8.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
}
