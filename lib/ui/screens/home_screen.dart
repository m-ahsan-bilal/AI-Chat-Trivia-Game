// lib/screens/home_screen.dart
import 'package:ai_chat_trivia/core/models/lobby.dart';
import 'package:ai_chat_trivia/core/providers/lobby_provider.dart';
import 'package:ai_chat_trivia/core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_lobby_screen.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LobbyProvider>(context, listen: false).loadLobbies();
    });
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Chat Game'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return PopupMenuButton(
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutConfirmation();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          userProvider.currentUser!.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userProvider.currentUser!.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildLobbyList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateLobby,
        icon: const Icon(Icons.add),
        label: const Text('Create Lobby'),
      ),
    );
  }

  Widget _buildLobbyList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inviteCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter invite code',
                    prefixIcon: Icon(Icons.vpn_key),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _joinLobbyWithCode,
                child: const Text('Join'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<LobbyProvider>(
            builder: (context, lobbyProvider, _) {
              if (lobbyProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (lobbyProvider.lobbies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No lobbies available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create one to get started!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: lobbyProvider.loadLobbies,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lobbyProvider.lobbies.length,
                  itemBuilder: (context, index) {
                    final lobby = lobbyProvider.lobbies[index];
                    return _buildLobbyCard(lobby);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLobbyCard(Lobby lobby) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[600],
          child: Icon(
            lobby.isPrivate ? Icons.lock : Icons.public,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                lobby.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (lobby.triviaActive)
              const Icon(Icons.quiz, color: Colors.deepPurple, size: 20),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text('Players: ${lobby.currentPlayers}/${lobby.maxHumans}'),
                const SizedBox(width: 12),
                const Icon(Icons.smart_toy, size: 16, color: Colors.deepPurple),
                const SizedBox(width: 4),
                Text('Bots: ${lobby.bots.length}'),
              ],
            ),
            Text('Code: ${lobby.inviteCode}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _joinLobby(lobby),
      ),
    );
  }

  void _joinLobbyWithCode() async {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an invite code')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    final success = await lobbyProvider.joinLobby(
      inviteCode,
      userProvider.currentUser!.userId,
    );

    if (success) {
      // Find the lobby by invite code
      final lobby = lobbyProvider.lobbies.firstWhere(
        (l) => l.inviteCode == inviteCode,
        orElse: () => lobbyProvider.lobbies.first,
      );

      _navigateToLobby(lobby.lobbyId, lobby.name);
      _inviteCodeController.clear();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join lobby')),
      );
    }
  }

  void _joinLobby(Lobby lobby) {
    _navigateToLobby(lobby.lobbyId, lobby.name);
  }

  void _navigateToCreateLobby() async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser!.userId;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateLobbyScreen(userId: userId),
      ),
    );
    // Refresh lobby list after returning from create lobby
    Provider.of<LobbyProvider>(context, listen: false).loadLobbies();
  }

  void _navigateToLobby(String lobbyId, String lobbyName) async {
    // Fetch full lobby info before navigating
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    await lobbyProvider.fetchLobbyInfo(lobbyId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LobbyScreen(
          lobbyId: lobbyId,
          lobbyName: lobbyName,
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<UserProvider>(context, listen: false).logout();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
