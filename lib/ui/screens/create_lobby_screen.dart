// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:ai_chat_trivia/core/providers/lobby_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lobby_screen.dart';

class CreateLobbyScreen extends StatefulWidget {
  const CreateLobbyScreen({super.key, required String userId});

  @override
  _CreateLobbyScreenState createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends State<CreateLobbyScreen> {
  final _nameController = TextEditingController();
  final _maxPlayersController = TextEditingController(text: '5');
  final _maxBotsController = TextEditingController(text: '1');
  bool _isPrivate = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lobby'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.group_add,
                size: 60,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 20),
              const Text(
                'Create a New Lobby',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Lobby Name',
                  prefixIcon: Icon(Icons.chat),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _maxPlayersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Players',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _maxBotsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Bots',
                  prefixIcon: Icon(Icons.smart_toy),
                  border: OutlineInputBorder(),
                  helperText: '0-2 bots allowed',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Private Lobby'),
                subtitle: const Text('Only accessible via invite code'),
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _createLobby,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Lobby'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createLobby() async {
    final name = _nameController.text.trim();
    final maxPlayers = int.tryParse(_maxPlayersController.text) ?? 5;
    final maxBots = int.tryParse(_maxBotsController.text) ?? 1;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a lobby name')),
      );
      return;
    }
    if (maxBots < 0 || maxBots > 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max bots must be between 0 and 2')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final result =
        await Provider.of<LobbyProvider>(context, listen: false).createLobby(
      name: name,
      maxHumans: maxPlayers,
      maxBots: maxBots,
      isPrivate: _isPrivate,
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            lobbyId: result['lobby_id'],
            lobbyName: result['name'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create lobby')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxPlayersController.dispose();
    _maxBotsController.dispose();
    super.dispose();
  }
}
