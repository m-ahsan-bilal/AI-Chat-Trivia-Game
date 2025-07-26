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
        title: const Text('AI Trivia Chat Game'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return PopupMenuButton(
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutConfirmation();
                  } else if (value == 'stats') {
                    _showServerStats();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'stats',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Server Stats'),
                      ],
                    ),
                  ),
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
                    helperText: 'Join private lobbies with invite code',
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
          backgroundColor:
              lobby.isPrivate ? Colors.red.shade600 : Colors.blue.shade600,
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
            if (lobby.hasTriviaActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.quiz, color: Colors.deepPurple, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'TRIVIA',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text('${lobby.currentPlayers}/${lobby.maxHumans}'),
                const SizedBox(width: 16),
                const Icon(Icons.smart_toy, size: 16, color: Colors.deepPurple),
                const SizedBox(width: 4),
                Text('${lobby.currentBots}/${lobby.maxBots} bots'),
                const SizedBox(width: 16),
                const Icon(Icons.chat, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text('${lobby.messageCount} msgs'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.vpn_key, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Code: ${lobby.inviteCode}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                if (lobby.isPrivate) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.lock, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  const Text(
                    'Private',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.public, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text(
                    'Public',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ],
            ),
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

    final success = await lobbyProvider.joinLobbyByInvite(
      inviteCode,
      userProvider.currentUser!.userId,
    );

    if (success) {
      // Refresh lobbies to get updated info
      await lobbyProvider.loadLobbies();

      // Find the lobby by invite code
      final lobby = lobbyProvider.lobbies.cast<Lobby?>().firstWhere(
            (l) => l?.inviteCode == inviteCode,
            orElse: () => null,
          );

      if (lobby != null) {
        _navigateToLobby(lobby.lobbyId, lobby.name);
        _inviteCodeController.clear();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined lobby but could not navigate')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to join lobby. Check the invite code.')),
      );
    }
  }

  void _joinLobby(Lobby lobby) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);

    // For public lobbies, use the new public join endpoint
    bool success;
    if (lobby.isPrivate) {
      success = await lobbyProvider.joinLobbyByInvite(
        lobby.inviteCode,
        userProvider.currentUser!.userId,
      );
    } else {
      success = await lobbyProvider.joinPublicLobby(
        lobby.lobbyId,
        userProvider.currentUser!.userId,
      );
    }

    if (success) {
      _navigateToLobby(lobby.lobbyId, lobby.name);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lobby.currentPlayers >= lobby.maxHumans
                ? 'Lobby is full'
                : 'Failed to join lobby',
          ),
        ),
      );
    }
  }

  void _navigateToCreateLobby() async {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser!.userId;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateLobbyScreen(userId: userId),
      ),
    );
    // Refresh lobby list after returning from create lobby
    if (mounted) {
      Provider.of<LobbyProvider>(context, listen: false).loadLobbies();
    }
  }

  void _navigateToLobby(String lobbyId, String lobbyName) async {
    // Fetch full lobby info before navigating
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    await lobbyProvider.fetchLobbyInfo(lobbyId);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            lobbyId: lobbyId,
            lobbyName: lobbyName,
          ),
        ),
      );
    }
  }

  void _showServerStats() async {
    final lobbyProvider = Provider.of<LobbyProvider>(context, listen: false);
    final stats = await lobbyProvider.apiService.getServerStats();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Statistics'),
        content: stats != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Users: ${stats['total_users']}'),
                  Text('Total Lobbies: ${stats['total_lobbies']}'),
                  Text('Active Lobbies: ${stats['active_lobbies']}'),
                  Text('Total Messages: ${stats['total_messages']}'),
                  Text('Total Bots: ${stats['total_bots']}'),
                  const SizedBox(height: 8),
                  const Text('AI Providers:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Hugging Face: ${stats['ai_providers']['huggingface'] ? "✅" : "❌"}'),
                  Text(
                      'Ollama: ${stats['ai_providers']['ollama'] ? "✅" : "❌"}'),
                  Text(
                      'Enhanced Rules: ${stats['ai_providers']['enhanced_rules'] ? "✅" : "❌"}'),
                ],
              )
            : const Text('Failed to load server stats'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
