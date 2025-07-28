import 'package:ai_chat_trivia/main.dart';
import 'package:ai_chat_trivia/ui/screens/auth_screen.dart';
import 'package:ai_chat_trivia/ui/screens/create_lobby_screen.dart';
import 'package:ai_chat_trivia/ui/screens/home_screen.dart';
import 'package:ai_chat_trivia/ui/screens/lobby_screen.dart';
import 'package:ai_chat_trivia/ui/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash screen',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/app',
      name: 'app',
      builder: (context, state) => const AppWrapper(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home_screen',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/create_lobby',
      name: 'createLobby',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return CreateLobbyScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) {
        final lobbyId = state.pathParameters['lobbyId']!;
        final userId = state.pathParameters['userId']!;
        return LobbyScreen(
          lobbyId: lobbyId,
          lobbyName: userId,
        );
      },
    ),
  ],
);
